# A fun weather simulator
#
# Created by lshang on Aug 16, 2016
#

define_constants <- function() {
  MINUTE_IN_SECONDS <<- 60
  HOUR_IN_SECONDS <<- MINUTE_IN_SECONDS * 60
  DAY_IN_SECONDS <<-  HOUR_IN_SECONDS * 24
  WEEK_IN_SECONDS <<- DAY_IN_SECONDS * 7
}

generate_timestamps <- function(numOfTimeStamps) {
   timeStamps <- sample(DAY_IN_SECONDS : WEEK_IN_SECONDS, numOfTimeStamps, replace = TRUE) 
   return(cumsum(timeStamps))
}

generate_conditions <- function(states, transitionMatrix, N) {
  sourceCpp("markovchain.cpp")
  tMatrix = matrix(unlist(transitionMatrix), nrow = length(states), byrow = TRUE)
  return(generate_sequence(tMatrix, N))
}

extract_value_range <- function(config, condition, measurement) {
  conditionProfile <- lapply(config$condition_profile[[condition]], function(x) x[x$name == measurement])
  conditionProfile <- Filter(function(x) length(x) > 0, conditionProfile)
  valueRange <- lapply(conditionProfile, '[', c('value'))
  return(valueRange[[1]])
}

generate_weather_samples <- function(config, conditions, measurement) {
  mapper <- unlist(unname(config$weather$stateFullNames))
  conditions <- mapper[conditions + 1]
  valueRange <- lapply(conditions, 
                   function(x) extract_value_range(config, x, measurement))
  
  samples <- sapply(valueRange, 
                function(x) runif(1, min = min(unlist(x)), max = max(unlist(x))))
  samples <- list(samples)
  names(samples) <- measurement
  return(samples)
}

build_location_samples <- function(config, i) {
  # Conditions
  transitionMatrix <- config$weather$transitionMatrix
  conditions <- generate_conditions(config$weather$states, 
                                    transitionMatrix, 
                                    config$training$NUMBER_OF_TRAINING_SAMPLES_PER_LOCATION)
  
  # Weather (CONDITION dependent)
  weatherSamples <- as.data.frame(lapply(config$weather$measurements, 
                            function(x) generate_weather_samples(config, conditions, x)))
  
  # Time stamps
  numOfSamples <- config$training$NUMBER_OF_TRAINING_SAMPLES_PER_LOCATION
  timeStamps <- as.POSIXlt(config$training$TRAINING_START_TIME) + generate_timestamps(numOfSamples)
  timeStamps <- paste(format(timeStamps, "%Y-%m-%dT%H:%M:%OS"), sep = "")
  
  # Positions
  position <- config$location[[i]][["Position"]]
  coordinates <- c("latitude", "longitude", "elevation")
  cvalues <- lapply(1:length(coordinates), function(x) rep(as.numeric(position[x]), numOfSamples))
  names(cvalues) <- coordinates
  
  # Training set
  samples <- cbind(
    as.data.frame(cvalues),
    data.frame(
      LocalTime = weekdays(as.Date(timeStamps)), # Feature engineering
      Conditions = conditions
    ),
    weatherSamples
  )
  
  return(samples)
}

generate_training_samples <- function(config) {
  locationSamples <- lapply(c(1:length(config$location)), 
                          function(x) build_location_samples(config, x))
  return(as.data.frame(do.call(rbind, locationSamples)))
}

simulate <- function(latitude, longitude, elevation, localTime) {
  define_constants()
  config <- get_config()
  if (config$training$reproducible) {set.seed(33)}
  
  # Generate training samples
  trainingSet <- generate_training_samples(config) 
  
  # create models
  fit.condition <- lda(Conditions ~ latitude + longitude + elevation + LocalTime, data = trainingSet)
  fit.temperature <- lm(Temperature ~ latitude + longitude + elevation + LocalTime, data = trainingSet)
  fit.pressure <- lm(Pressure ~ latitude + longitude + elevation + LocalTime, data = trainingSet)
  fit.humidity <- lm(Humidity ~ latitude + longitude + elevation + LocalTime, data = trainingSet)
  
  # predict
  data <- data.frame(latitude = latitude, longitude = longitude, elevation = elevation, 
                      LocalTime = weekdays(as.Date(localTime)))
  
  measurement <- data.frame(
    Conditions = predict(fit.condition, data)$class,
    Temperature = predict(fit.temperature, data),
    Pressure = predict(fit.pressure, data),
    Humidity = predict(fit.humidity, data))
  
  # submit result
  mapper <- unlist(unname(config$weather$stateFullNames))
  measurement$Conditions <- mapper[measurement$Conditions]
  position <- paste(format(data$latitude, digits = 2, nsmall = 2),
                    format(data$longitude, digits = 2, nsmall = 2),
                    format(data$elevation, digits = 2, nsmall = 2),
                    sep = ",")
  record <- cbind(data.frame(Position = position, LocaTime = localTime), 
                  measurement)
  return(record)
}

get_config <- function() {
  config.json <- 'config.json'
  config <- fromJSON(config.json, flatten = FALSE, simplifyVector = FALSE)
  return(config)
}

# ----------------------------------------------------
options(warn = -1)

# Libraries
library(Rcpp)
library(jsonlite)
library(MASS)

# Test scenario - Sydney weather over time
cat("Sydney weather over time:\n")
define_constants()

latitude = -33.86
longitude = 151.21
elevation = 39
localStartTime = "2016-08-18T00:00:00"

n = 10
for (i in 1:n) {
  localTime <- as.POSIXlt(localStartTime) + DAY_IN_SECONDS * (i-1)
  localTime <- paste(format(localTime, "%Y-%m-%dT%H:%M:%OS"), sep = "")
  
  measurement <- simulate(latitude, longitude, elevation, localTime)
  
  write.table(format(measurement, digits=2, nsmall=2), 
              file = "",  
              append = TRUE, sep = "|", quote = FALSE, col.names = FALSE, row.names = FALSE)
}

# Test scenario - some random time&location on planet Earth
cat("\nSome random time&location on planet Earth:\n")
define_constants()

n = 10
latitudes = runif(n, min = -90, max = 90)
longitudes = runif(n, min = -180, max = 180)
elevations = runif(n, min = 0, max = 8448)
localStartTime = "2016-08-18T00:00:00"
localTime = as.POSIXlt(localStartTime) + runif(n, min = 0, max = WEEK_IN_SECONDS)

for (i in 1:n) {
  measurement <- simulate(latitudes[i], longitudes[i], elevations[i], localTime[i])
  write.table(format(measurement, digits = 2, nsmall = 2), 
              file = "",
              append = TRUE, sep = "|", quote = FALSE, col.names = FALSE, row.names = FALSE)
}
