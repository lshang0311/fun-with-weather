# fun-with-weather

An implemention of a fun weather simulator in R programming language.


Ok, some simple explanation for the fun journey.

    Technology stack
       - Markov Chain
       - Random number generator
       - Json
       - Functional programming in R
       - Rcpp
       - Linear Discriminant Analysis (LDA)
       - Linear regression 

    Key features
       - Highly configurable for generating ground truth/training samples
          - Markov Chain to simulate weather conditions, rain/snow/sunny
          - Random number generation to simulate numerical variables, temperature/pressure/humidity
          - Define training set size
          - Define positions
          - Define weather profiles, e.g. high humidity in rain condition.
       - Structured for future extensions
       - Use predictive modelling to generate measurements
       - Feature engineering
       - FP (functional programming) in R

    Simulation methodology 
       - Generate synthetic data as the ground truth
       - Use the ground truth as the data to build predictive models (LDA, LM)
       - Feed new data (time&location) the established predictive models to generate 
	 measurements (weather condition, temperature, pressure, humidity)

    Usage
       - Assume these libraries have been installed: Rcpp, jsonlite, MASS, RUnit
       - For simplicity, all relevant files are placed in the same directory. Load run_weather_simulation.R 
         into RStudio and click "Source" or press Ctrl+Shift+S, weather samples from two test scenarios ("Sydney
	 weather over time" and "Some random time&location on planet Earth") should be 
         displayed in the console.
       - To run test, load run_tests.R into RStudio and click "Source" or press Ctrl+Shift+S, a test report should be produced
         in the console.
       - Users may also want to modify or add test scenarios in the script run_weather_simulation.

    TODO
       So, we had some fun. An arbitray location and time from the blue planet can be selected for producing
       measurements. Maybe we should add more locations in the config.json to make the measurments more plausible?
       We can't predict the weather in London with high accuracy giving our models are trained with three Aussie cities only?

       Assume this simulator is not completely insane, maybe we should modify config.json to produce some data
       for the Martian gamers?

       While it's fun to code in R, a version in Java or Scala could be more fun?



