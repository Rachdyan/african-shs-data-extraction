library(pdftools)
library(dplyr)
library(stringr)
library(purrr)
library(writexl)
library(tabulizer)
library(glue)

######## SHS DISTRICT PARAMETER
source("./function/SHS_District_Parameter_Function.R")

shs_parameter_file <- c()
for(i in 2012:2019){
  filename <- glue("./Districts data/{i}-{i+1}/SHS District Parameters.pdf")
  shs_parameter_file <- c(shs_parameter_file, filename)
}

map(shs_parameter_file, get_SHS_Parameter)


######## SHS DISTRICT PROFILE
source("./function/SHS_District_Profile_Function.R")

shs_profile_file <- c()
for(i in 2012:2019){
  filename <- glue("./Districts data/{i}-{i+1}/SHS District Profile.pdf")
  shs_profile_file <- c(shs_profile_file, filename)
}

map(shs_profile_file, get_SHS_Profile)
