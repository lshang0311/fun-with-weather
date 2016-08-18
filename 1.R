test.simulator <- function() {
  checkTrue(TRUE, define_constants())
  checkEquals(5, length(generate_timestamps(5)))
  checkEquals(4, length(get_config()))
}

test.markovchain <- function() {
  sourceCpp("markovchain.cpp")
  mat <- matrix(1)
  checkEquals(0, generate_sequence(mat, 1))
  
  mat <- matrix(c(1/3, 1/3, 1/3, 1/3, 1/3, 1/3, 1/3, 1/3, 1/3), nrow = 3, ncol = 3)
  sequence <- generate_sequence(mat,20)
  checkEquals(20, length(sequence))
}

test.deactivation <- function() {
  DEACTIVATED('Deactivating this test function')
}