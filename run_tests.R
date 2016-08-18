# Tests for weather simulator
#
# Created by lshang on Aug 19, 2016
#

library(RUnit)
source('run_weather_simulation.R')

test.suite <- defineTestSuite("test weather simulator",
                              dirs = file.path(getwd()),
                              testFileRegexp = '^\\d+\\.R')

test.result <- runTestSuite(test.suite)
printTextProtocol(test.result)