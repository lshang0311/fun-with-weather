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

    Simulation methodology 
       - Generate sythetic data as the ground truth
       - Use the ground truth to build predictive models (LDA, LM)
       - Feed new data (time&location) the established predictive models to generate 
	 measurements (weather condition, temperature, pressure, humidity)

    Usage
       - Put all files (run_weather_simulation.R, karkovchain.cpp, config.json) in the same 
         directory. Load run_weather_simulation.R into RStudio and click "Source" or press Ctrl+Shift+S, simulated weather samples should be displayed in the console.

