
library(pdftools)
library(dplyr)
library(stringr)
library(writexl)
library(tabulizer)
library(strex)

get_SHS_Parameter <- function(pdf_file){
  ##Get the Year information from the pdf file directories
  year <- pdf_file %>% str_after_nth("/", 2) %>% str_before_first("/")
  ##Get the page number
  page_num <- pdf_info(pdf_file)$pages
  
  print(paste("Extracting ", year, " SHS Parameter data with ", page_num, " pages", sep = ""))
  
  ## Create empty dataframes to store the data
  num_of_school_data <- tibble() 
  school_org_data <- tibble()
  classrooms_data <- tibble()
  water_data <- tibble()
  electricity_data <- tibble()
  social_facilities_data <- tibble()
  boarding_facilities_data <- tibble()
  pedagogical_tools_data <- tibble() 
  rates_and_ratio_data <- tibble()
  maths_pass_rate_data <- tibble()
  english_pass_rate_data <- tibble()
  int_science_pass_rate_data <- tibble()
  social_studies_pass_rate_data <- tibble()
  
  ### Loop every page and extract the data
  for (i in 1:page_num) {
    temp_num_of_school <- get_num_of_school(pdf_file, page = i, year)
    num_of_school_data <- rbind(num_of_school_data, temp_num_of_school)
    
    temp_school_org <- get_school_org(pdf_file, page = i, year)
    school_org_data <- rbind(school_org_data, temp_school_org)
    
    temp_classrooms <- get_classrooms(pdf_file, page = i, year)
    classrooms_data <- rbind(classrooms_data, temp_classrooms)
    
    temp_water <- get_water(pdf_file, page = i, year)
    water_data <- rbind(water_data, temp_water)
    
    temp_electricity <- get_electricity(pdf_file, page = i, year)
    electricity_data <- rbind(electricity_data, temp_electricity)
    
    temp_social_facilities <- get_social_facilities(pdf_file, page = i, year)
    social_facilities_data <- rbind(social_facilities_data, temp_social_facilities)
    
    temp_boarding_facilities <- get_boarding_facilities(pdf_file, page = i, year)
    boarding_facilities_data <- rbind(boarding_facilities_data, temp_boarding_facilities)
    
    temp_pedagogical_tools <- get_pedagogical_tools(pdf_file, page = i, year)
    pedagogical_tools_data <- rbind(pedagogical_tools_data, temp_pedagogical_tools)
    
    temp_rates_and_ratio <- get_rates_and_ratio(pdf_file, page = i, year)
    rates_and_ratio_data <- rbind(rates_and_ratio_data, temp_rates_and_ratio)
    
    temp_maths_pass_rate <- get_maths_pass_rate(pdf_file, page = i, year)
    maths_pass_rate_data <- rbind(maths_pass_rate_data, temp_maths_pass_rate )
    
    temp_english_pass_rate <- get_english_pass_rate(pdf_file, page = i, year)
    english_pass_rate_data <- rbind(english_pass_rate_data, temp_english_pass_rate)
    
    temp_int_science_pass_rate <- get_int_science_pass_rate(pdf_file, page = i, year)
    int_science_pass_rate_data <- rbind(int_science_pass_rate_data, temp_int_science_pass_rate)
    
    temp_social_studies_pass_rate <- get_social_studies_pass_rate(pdf_file, page = i, year)
    social_studies_pass_rate_data <- rbind(social_studies_pass_rate_data, temp_social_studies_pass_rate)
    
  }
  
  ## Create an Excel Sheet
  sheets <- list("Number of Schools" = num_of_school_data,
                 "School Organization" = school_org_data, 
                 "Clasrooms" = classrooms_data, 
                 "Water" = water_data,
                 "Electricity" =  electricity_data, 
                 "Social Facilities" = social_facilities_data, 
                 "Boarding-Hotel Facilities" = boarding_facilities_data, 
                 "Pedagogical Tools" = pedagogical_tools_data,
                 "Rates and Ratio" = rates_and_ratio_data, 
                 "Maths WASSCE Core Subject Pass Rates" = maths_pass_rate_data, 
                 "English WASSCE Core Subject Pass Rates" = english_pass_rate_data,
                 "Int Science WASSCE Core Subject Pass Rates" = int_science_pass_rate_data, 
                 "Social Studies WASSCE Core Subject Pass Rates" = social_studies_pass_rate_data
  )
  
  ## Set up the name of the excel file
  file_name <- paste(paste(year, "SHS District Parameter.xlsx"))
  ## Write the excel files
  write_xlsx(sheets, file_name)
  print(paste("Succesfully Written ", file_name, sep = ""))
}

get_area_year_parameter <- function(pdf_file, page = NULL, year){
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2017-2018", "2016-2017", "2015-2016")){
    year_range <- "2015-2018"
  } else if(year %in% c("2012-2013", "2013-2014", "2014-2015")){
    year_range <- "2012-2015"
  } else{
    year_range <- "2018-2020"
  }
  
  ### Set the table location based on the documents year range 
  switch (year_range,
          "2018-2020" = {info_location <- list(c(top = 32.9898961123937, left = 32.517337117597, bottom = 45.2083761540238, 
                                                   right = 804.72527574856))
          },
          "2015-2018" = {info_location <- list(c(top = 31.2345753394312, left = 29.942745029672, bottom = 48.0025125560512, 
                                       right = 802.46556679521))
          },
          "2012-2015" = {info_location <- list(c(top = 14.4077500496587, left = 23.94395461971, bottom = 39.5489024003588, 
                                                 right = 803.31967749128))
          }
  )
  
  #### Extract the Year, District, Region data
  info_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = info_location)

  ## Extract the Year, District, Region for 2 different kind of format
  if(length(info_data[[1]]) == 1){
    #### Extract the District Data
    district <- info_data[[1]][1] %>% substr(nchar(info_data[[1]][1]) - 47, nchar(info_data[[1]][1])) %>% str_extract("^(.+?),") %>%
      str_replace(",", "")
    #### Extract the Region Data
    region <- info_data[[1]][1] %>% substr(nchar(info_data[[1]][1]) - 51, nchar(info_data[[1]][1])) %>% str_extract("[^,]*$") %>% 
      trimws() %>% str_replace(" R[^,]*$", "")
    #### Extract the Year Data
    year <- info_data[[1]][1] %>% substr(1, 51) %>% str_extract("[^-]*$") %>% 
      str_replace(" Sch[^,]*$", "") %>%  str_replace(" / ", "/") %>%
      trimws()
  } else{
    #### Extract the District Data
    district <- info_data[[1]][2] %>% str_extract("^(.+?),") %>%
      str_replace(",", "")
    #### Extract the Region Data
    region <- info_data[[1]][2] %>% str_extract("[^,]*$") %>% 
      trimws() %>% str_replace(" R[^,]*$", "")
    #### Extract the Year Data
    year <- info_data[[1]][1] %>% str_extract("[^-]*$") %>% 
      str_replace(" Sch[^,]*$", "") %>%  str_replace(" / ", "/") %>%
      trimws()
  }

  ## Store the Year, District, Region data in a list
  info_data <- list(year = year, district = district, region = region)
}

get_num_of_school <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year_parameter(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2015-2016", "2016-2017")){
    year_range_loc <- "2015-2017"
  } else if(year %in% c("2012-2013", "2013-2014", "2014-2015")){
    year_range_loc <- "2012-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 92.8604483163837, left = 67.950929238321, bottom = 157.618392537014, 
                                       right = 289.10541799181))
          },
          "2017-2018" = {loc <- list(c(top = 94.1143399017512, left = 65.874039065278, bottom = 168.372347575331, 
                                       right = 285.05493268248))
          },
          "2015-2017" = {loc <- list(c(top = 97.0143934876588, left = 33.521536467594, bottom = 165.254664153839, 
                                       right = 292.11624636046))
          },
          "2012-2015" = {loc <- list(c(top = 87.4368116397787, left = 31.127141005623, bottom = 154.479884574969, 
                                       right = 299.29943274638))
          }
  )
  
  ### Adjust the year range for the content since there are layout change every several year
  if(year %in% c("2012-2013", "2013-2014", "2014-2015", "2015-2016", "2016-2017")){
    year_range_content <- "2012-2017"
  } else{
    year_range_content <- "2018-2020"
  }
  
  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  
  ##### Tidy and clean the data based on several parameter (year range,  number of column, etc)
  switch (year_range_content,
          "2012-2017" = {
            data <- raw_data[-1, -c(1, 5,8)]
          },
          {if(ncol(raw_data) == 7){
            data <- raw_data[-1, -1]
          } else if(ncol(raw_data) == 8 && all(raw_data[2:5, 2] == "") == "TRUE"){
            data <- raw_data[-1, -c(1:2)]
          } else{
            data <- raw_data[-1, -c(1,3)]
          }
          }
  )
  
  ##### Store the data based on the year range since there are format change in several years
  switch (year_range_content,
          "2012-2017" = {
            if(is_empty(data) || is.null(nrow(data))){
              df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                           "Public_Total" = NA, "Private_Total" = NA,
                           "Total_Sch" = NA,
                           "Public_Urban_Total" = NA, "Private_Urban_Total" = NA,
                           "Urban_Total" = NA,
                           "Public_Urban_%" = NA, "Private_Urban_%" = NA,
                           "Urban_%" = NA,
                           "Public_Rural_Total" = NA, "Private__Rural_Total" = NA, 
                           "Rural_Total" = NA,
                           "Public_Rural_%" = NA, "Private_Rural_%" = NA,
                           "Rural_%" = NA, 
                           "Public_Grand_Total" = NA, "Private_Grand_Total" = NA,
                           "Grand_Total" = NA)
            } else{
              df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                           "Public_Total" = data[1,1], "Private_Total" = data[2,1],
                           "Total_Sch" = data[3,1],
                           "Public_Urban_Total" = data[1,2], "Private_Urban_Total" = data[2,2],
                           "Urban_Total" = data[3,2],
                           "Public_Urban_%" = data[1,3], "Private_Urban_%" = data[2,3],
                           "Urban_%" = data[3,3],
                           "Public_Rural_Total" = data[1,4], "Private__Rural_Total" = data[2,4], 
                           "Rural_Total" = data[3,4],
                           "Public_Rural_%" = data[1,5], "Private_Rural_%" = data[2,5],
                           "Rural_%" = data[3,5], 
                           "Public_Grand_Total" = data[1,6], "Private_Grand_Total" = data[2,6],
                           "Grand_Total" = data[3,6])
              df <- df %>% mutate_all(na_if, "")
              return(df)
            }
          },
          { if(is_empty(data) || is.null(nrow(data))){
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                         "Public_SHS_Total" = NA, "Public_TVET_Total" = NA,
                         "Private_SHS_Total" = NA, "Total_Sch" = NA,
                         "Public_SHS_Urban_Total" = NA, "Public_TVET_Urban_Total" = NA,
                         "Private_SHS_Urban_Total" = NA, "Urban_Total" = NA,
                         "Public_SHS_Urban_%" = NA, "Public_TVET_Urban_%" = NA,
                         "Private_SHS_Urban_%" = NA, "Urban_%" = NA,
                         "Public_SHS_Rural_Total" = NA, "Public_TVET_Rural_Total" = NA,
                         "Private_SHS_Rural_Total" = NA, "Rural_Total" = NA,
                         "Public_SHS_Rural_%" = NA, "Public_TVET_Rural_%" = NA,
                         "Private_SHS_Rural_%" = NA, "Rural_%" = NA, 
                         "Public_SHS_Grand_Total" = NA, "Public_TVET_Grand_Total" = NA,
                         "Private_SHS_Grand_Total" = NA, "Grand_Total" = NA)
          } else{
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                         "Public_SHS_Total" = data[1,1], "Public_TVET_Total" = data[2,1],
                         "Private_SHS_Total" = data[3,1], "Total_Sch" = data[4,1],
                         "Public_SHS_Urban_Total" = data[1,2], "Public_TVET_Urban_Total" = data[2,2],
                         "Private_SHS_Urban_Total" = data[3,2], "Urban_Total" = data[4,2],
                         "Public_SHS_Urban_%" = data[1,3], "Public_TVET_Urban_%" = data[2,3],
                         "Private_SHS_Urban_%" = data[3,3], "Urban_%" = data[4,3],
                         "Public_SHS_Rural_Total" = data[1,4], "Public_TVET_Rural_Total" = data[2,4],
                         "Private_SHS_Rural_Total" = data[3,4], "Rural_Total" = data[4,4],
                         "Public_SHS_Rural_%" = data[1,5], "Public_TVET_Rural_%" = data[2,5],
                         "Private_SHS_Rural_%" = data[3,5], "Rural_%" = data[4,5], 
                         "Public_SHS_Grand_Total" = data[1,6], "Public_TVET_Grand_Total" = data[2,6],
                         "Private_SHS_Grand_Total" = data[3,6], "Grand_Total" = data[4,6])
            df <- df %>% mutate_all(na_if, "")
          }
          }
  )
}

get_school_org <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year_parameter(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2015-2016", "2016-2017")){
    year_range_loc <- "2015-2017"
  } else if(year %in% c("2012-2013", "2013-2014", "2014-2015")){
    year_range_loc <- "2012-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 79.4201202705938, left = 293.99281000846, bottom = 161.283936549504, 
                                       right = 545.69349886602))
          },
          "2017-2018" = {loc <- list(c(top = 80.9395320886913, left = 294.63661109197, bottom = 167.174637774141, 
                                         right = 547.3533791424))
          },
          "2015-2017" = {loc <- loc <- list(c(top = 95.8171957566788, left = 300.90503728441, bottom = 168.846257346789, 
                                              right = 565.07732902516))
          },
          "2012-2015" = {loc <- list(c(top = 82.6480207158387, left = 305.2854214013, bottom = 158.071477767919, 
                                       right = 557.89414263925))
          }
  )
  
  ### Adjust the year range for the content since there are layout change every several year
  if(year %in% c("2012-2013", "2013-2014", "2014-2015", "2015-2016", "2016-2017")){
    year_range_content <- "2012-2017"
  } else{
    year_range_content <- "2018-2020"
  }
  
  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  
  ##### Tidy and clean the data based on several parameter (year range,  number of column, etc)
  if(year_range_content == "2018-2020"){
    raw_data <- cbind(raw_data, "")
    for(i in c(2,4,6)){
      raw_data[3:6, i+1] <- raw_data[3:6, i]
      raw_data[3:6, i] <- raw_data[3:6, i] %>% str_before_nth(" ", 1)
      raw_data[3:6, i+1] <- raw_data[3:6, i+1] %>% str_after_nth(" ", 1)
    }
  }
  
  ##### Tidy and clean the data based on several parameter (year range,  number of column, etc)
  switch (year_range_content,
          "2012-2017" = {
            data <-  raw_data[-1, -c(1, 4)]
          },
          {
            data <- raw_data[-c(1:2), -1]
          }
  )
  
  ##### Store the data based on the year range since there are format change in several years
  switch (year_range_content,
          "2012-2017" = {
            if(is_empty(data) || is.null(nrow(data))){
              df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                           "Boys_Only_Public_Total" = NA, "Girls_Only_Public_Total" = NA,
                           "Co_Educational_Public_Total" = NA, "Public_Total" = NA,
                           "Boys_Only_Public_%" = NA, "Girls_Only_Public_%" = NA,
                           "Co_Educational_Public_%" = NA, "Public_%" = NA,
                           "Boys_Only_Private_Total" = NA, "Girls_Only_Private_Total" = NA,
                           "Co_Educational_Private_Total" = NA, "Private_Total" = NA,
                           "Boys_Only_Private_%" = NA, "Girls_Only_Private_%" = NA,
                           "Co_Educational_Private_%" = NA, "Private_%" = NA)
            } else{
              df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                           "Boys_Only_Public_Total" = data[1,1], "Girls_Only_Public_Total" = data[2,1],
                           "Co_Educational_Public_Total" = data[3,1], "Public_Total" = data[4,1],
                           "Boys_Only_Public_%" = data[1,2], "Girls_Only_Public_%" = data[2,2],
                           "Co_Educational_Public_%" = data[3,2], "Public_%" = data[4,2],
                           "Boys_Only_Private_Total" = data[1,3], "Girls_Only_Private_Total" = data[2,3],
                           "Co_Educational_Private_Total" = data[3,3], "Private_Total" = data[4,3],
                           "Boys_Only_Private_%" = data[1,4], "Girls_Only_Private_%" = data[2,4],
                           "Co_Educational_Private_%" = data[3,4], "Private_%" = data[4,4])
              df <- df %>% mutate_all(na_if, "")
            }
          },
          { if(is_empty(data) || is.null(nrow(data))){
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                         "Boys_Only_Public_SHS_Total" = NA, "Girls_Only_Public_SHS_Total" = NA,
                         "Co_Educational_Public_SHS_Total" = NA, "Public_SHS_Total" = NA,
                         "Boys_Only_Public_SHS_%" = NA, "Girls_Only_Public_SHS_%" = NA,
                         "Co_Educational_Public_SHS_%" = NA, "Public_SHS_%" = NA,
                         "Boys_Only_Public_TVET_Total" = NA, "Girls_Only_Public_TVET_Total" = NA,
                         "Co_Educational_Public_TVET_Total" = NA, "Public_TVET_Total" = NA,
                         "Boys_Only_Public_TVET_%" = NA, "Girls_Only_Public_TVET_%" = NA,
                         "Co_Educational_Public_TVET_%" = NA, "Public_TVET_%" = NA,
                         "Boys_Only_Private_SHS_Total" = NA, "Girls_Only_Private_SHS_Total" = NA,
                         "Co_Educational_Private_SHS_Total" = NA, "Private_SHS_Total" = NA,
                         "Boys_Only_Private_SHS_%" = NA, "Girls_Only_Private_SHS_%" = NA,
                         "Co_Educational_Private_SHS_%" = NA, "Private_SHS_%" = NA)
          } else{
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                         "Boys_Only_Public_SHS_Total" = data[1,1], "Girls_Only_Public_SHS_Total" = data[2,1],
                         "Co_Educational_Public_SHS_Total" = data[3,1], "Public_SHS_Total" = data[4,1],
                         "Boys_Only_Public_SHS_%" = data[1,2], "Girls_Only_Public_SHS_%" = data[2,2],
                         "Co_Educational_Public_SHS_%" = data[3,2], "Public_SHS_%" = data[4,2],
                         "Boys_Only_Public_TVET_Total" = data[1,3], "Girls_Only_Public_TVET_Total" = data[2,3],
                         "Co_Educational_Public_TVET_Total" = data[3,3], "Public_TVET_Total" = data[4,3],
                         "Boys_Only_Public_TVET_%" = data[1,4], "Girls_Only_Public_TVET_%" = data[2,4],
                         "Co_Educational_Public_TVET_%" = data[3,4], "Public_TVET_%" = data[4,4],
                         "Boys_Only_Private_SHS_Total" = data[1,5], "Girls_Only_Private_SHS_Total" = data[2,5],
                         "Co_Educational_Private_SHS_Total" = data[3,5], "Private_SHS_Total" = data[4,5],
                         "Boys_Only_Private_SHS_%" = data[1,6], "Girls_Only_Private_SHS_%" = data[2,6],
                         "Co_Educational_Private_SHS_%" = data[3,6], "Private_SHS_%" = data[4,6])
            df <- df %>% mutate_all(na_if, "")
          }
          }
  )
}

get_classrooms <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year_parameter(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2015-2016", "2016-2017")){
    year_range_loc <- "2015-2017"
  } else if(year %in% c("2012-2013", "2013-2014", "2014-2015")){
    year_range_loc <- "2012-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 89.6827829721838, left = 553.43394346495, bottom = 157.963594178894, 
                                       right = 766.66173986486))
          },
          "2017-2018" = {loc <- list(c(top = 90.5212104981812, left = 554.53963794952, bottom = 164.779218171771, 
                                       right = 779.70908057266))
          },
          "2015-2017" = {loc <- list(c(top = 95.8171957566788, left = 571.66892221812, bottom = 167.649059615809, 
                                       right = 802.12247976029))
          },
          "2012-2015" = {loc <- list(c(top = 76.4508229848487, left = 571.06331768009, bottom = 154.479884574969, 
                                       right = 762.61495463777))
          }
  )
  
  ### Adjust the year range for the content since there are layout change every several year
  if(year %in% c("2012-2013", "2013-2014", "2014-2015", "2015-2016", "2016-2017")){
    year_range_content <- "2012-2017"
  } else{
    year_range_content <- "2018-2020"
  }
  
  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  
  ##### Tidy and clean the data based on several parameter (year range,  number of column, etc)
  switch (year_range_content,
          "2012-2017" = {
            data <-  raw_data[-1, -1]
          },
          {
            if(ncol(raw_data) == 5){
              data <- raw_data[-1, -c(1:2)]
            } else {
              data <- raw_data[-1, -1]
            }
          }
  )
  
  ##### Store the data on a dataframe based on the year range since there are format change in several years
  switch (year_range_content,
          "2012-2017" = {  if(is_empty(data) || is.null(nrow(data))){
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                         "Permanent_Public" = NA, "Temporary_Public" = NA,
                         "Major_Repairs_Public" = NA, "%Major_Repairs_Public" = NA,
                         "Permanent_Private" = NA, "Temporary_Private" = NA,
                         "Major_Repairs_Private" = NA, "%Major_Repairs_Private" = NA)
          } else{
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                         "Permanent_Public" = data[1,1], "Temporary_Public" = data[2,1],
                         "Major_Repairs_Public" = data[3,1], "%Major_Repairs_Public" = data[4,1],
                         "Permanent_Private" = data[1,2], "Temporary_Private" = data[2,2],
                         "Major_Repairs_Private" = data[3,2], "%Major_Repairs_Private" = data[4,2])
            df <- df %>% mutate_all(na_if, "")
          }}
          ,
          {  if(is_empty(data) || is.null(nrow(data))){
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                         "Permanent_Public_SHS" = NA, "Temporary_Public_SHS" = NA,
                         "Major_Repairs_Public_SHS" = NA, "%Major_Repairs_Public_SHS" = NA,
                         "Permanent_Public_TVET" = NA, "Temporary_Public_TVET" = NA,
                         "Major_Repairs_Public_TVET" = NA, "%Major_Repairs_Public_TVET" = NA,
                         "Permanent_Private_SHS" = NA, "Temporary_Private_SHS" = NA,
                         "Major_Repairs_Private_SHS" = NA, "%Major_Repairs_Private_SHS" = NA)
          } else if (nrow(data) < 4){
            print(paste("There may be some error in extracting Classrooms data from pages ", page, ". Please recheck the results", sep =""))
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                         "Permanent_Public_SHS" = data[1,1], "Temporary_Public_SHS" = data[2,1],
                         "Major_Repairs_Public_SHS" = NA, "%Major_Repairs_Public_SHS" = NA,
                         "Permanent_Public_TVET" = data[1,2], "Temporary_Public_TVET" = data[2,2],
                         "Major_Repairs_Public_TVET" = NA, "%Major_Repairs_Public_TVET" = NA,
                         "Permanent_Private_SHS" = data[1,3], "Temporary_Private_SHS" = data[2,3],
                         "Major_Repairs_Private_SHS" = NA, "%Major_Repairs_Private_SHS" = NA)
            df <- df %>% mutate_all(na_if, "")
          } else{
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                         "Permanent_Public_SHS" = data[1,1], "Temporary_Public_SHS" = data[2,1],
                         "Major_Repairs_Public_SHS" = data[3,1], "%Major_Repairs_Public_SHS" = data[4,1],
                         "Permanent_Public_TVET" = data[1,2], "Temporary_Public_TVET" = data[2,2],
                         "Major_Repairs_Public_TVET" = data[3,2], "%Major_Repairs_Public_TVET" = data[4,2],
                         "Permanent_Private_SHS" = data[1,3], "Temporary_Private_SHS" = data[2,3],
                         "Major_Repairs_Private_SHS" = data[3,3], "%Major_Repairs_Private_SHS" = data[4,3])
            df <- df %>% mutate_all(na_if, "")
          }
            } 
  )
  
}

get_water <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year_parameter(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2015-2016", "2016-2017")){
    year_range_loc <- "2015-2017"
  } else if(year %in% c("2012-2013", "2013-2014", "2014-2015")){
    year_range_loc <- "2012-2015"
  } else {
    year_range_loc <- year
  }
  
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 182.055352620274, left = 34.961033125922, bottom = 265.141016903354, 
                                         right = 291.54911400014))
          },
          "2017-2018" = {loc <- list(c(top = 192.326543599071, left = 34.733584234419, bottom = 280.957068886901, 
                                       right = 288.64806208604))
          },
          "2015-2017" = {loc <- list(c(top = 196.381805159459, left = 32.324338736609, bottom = 278.988448597459, 
                                       right = 295.70783955342))
          },
          "2012-2015" = {loc <- list(c(top = 184.409827849599, left = 31.127141005623, bottom = 267.016471287599, 
                                       right = 290.91904862948))
          }
          
  )
  
  ### Adjust the year range for the content since there are layout change every several year
  if(year %in% c("2012-2013", "2013-2014", "2014-2015", "2015-2016", "2016-2017")){
    year_range_content <- "2012-2017"
  } else{
    year_range_content <- "2018-2020"
  }

  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  
  ##### Tidy and clean the data based on several parameter (year range,  number of column, etc)
  if(year_range_content == "2018-2020"){
    raw_data <- cbind(raw_data, "")
    for(i in c(2,4,6)){
      raw_data[3:7, i+1] <- raw_data[3:7, i]
      raw_data[3:7, i] <- raw_data[3:7, i] %>% str_before_nth(" ", 1)
      raw_data[3:7, i+1] <- raw_data[3:7, i+1] %>% str_after_nth(" ", 1)
    }
  }
  
  switch (year_range_content,
          "2012-2017" = {
            data <-  raw_data[-1, -1]
          },
          {
            data <- raw_data[-c(1:2), -1]
          }
  )
  
  ##### Store the data on a dataframe based on the year range since there are format change in several years
  switch (year_range_content,
          "2012-2017" = {if(is_empty(data) || is.null(nrow(data))){
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                         "Pipeborne_Public_Total" = NA, "Borehole_Public_Total" = NA,
                         "Well_Public_Total" = NA, "Other_Public_Total" = NA,
                         "Public_Total" = NA,
                         
                         "Pipeborne_Public_%" = NA, "Borehole_Public_%" = NA,
                         "Well_Public_%" = NA, "Other_Public_%" = NA,
                         "Public_%" = NA,
                         
                         "Pipeborne_Private_Total" = NA, "Borehole_Private_Total" = NA,
                         "Well_Private_Total" = NA, "Other_Private_Total" = NA,
                         "Private_Total" = NA,
                         
                         "Pipeborne_Private_%" = NA, "Borehole_Private_%" = NA,
                         "Well_Private_%" = NA, "Other_Private_%" = NA,
                         "Private_%" = NA)
          } else{
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                         "Pipeborne_Public_Total" = data[1,1], "Borehole_Public_Total" = data[2,1],
                         "Well_Public_Total" = data[3,1], "Other_Public_Total" = data[4,1],
                         "Public_Total" = data[5,1],
                         
                         "Pipeborne_Public_%" = data[1,2], "Borehole_Public_%" = data[2,2],
                         "Well_Public_%" = data[3,2], "Other_Public_%" = data[4,2],
                         "Public_%" = data[5,2],
                         
                         "Pipeborne_Private_Total" = data[1,3], "Borehole_Private_Total" = data[2,3],
                         "Well_Private_Total" = data[3,3], "Other_Private_Total" = data[4,3],
                         "Private_Total" = data[5,3],
                         
                         "Pipeborne_Private_%" = data[1,4], "Borehole_Private_%" = data[2,4],
                         "Well_Private_%" = data[3,4], "Other_Private_%" = data[4,4],
                         "Private_%" = data[5,4])
            df <- df %>% mutate_all(na_if, "")
          }
          },
          {  if(is_empty(data) || is.null(nrow(data))){
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                         "Pipeborne_Public_SHS_Total" = NA, "Borehole_Public_SHS_Total" = NA,
                         "Well_Public_SHS_Total" = NA, "Other_Public_SHS_Total" = NA,
                         "Public_SHS_Total" = NA,
                         
                         "Pipeborne_Public_SHS_%" = NA, "Borehole_Public_SHS_%" = NA,
                         "Well_Public_SHS_%" = NA, "Other_Public_SHS_%" = NA,
                         "Public_SHS_%" = NA,
                         
                         
                         "Pipeborne_Public_TVET_Total" = NA, "Borehole_Public_TVET_Total" = NA,
                         "Well_Public_TVET_Total" = NA, "Other_Public_TVET_Total" = NA,
                         "Public_TVET_Total" = NA,
                         
                         
                         "Pipeborne_Public_TVET_%" = NA, "Borehole_Public_TVET_%" = NA,
                         "Well_Public_TVET_%" = NA, "Other_Public_TVET_%" = NA,
                         "Public_TVET_%" = NA,
                         
                         
                         "Pipeborne_Private_SHS_Total" = NA, "Borehole_Private_SHS_Total" = NA,
                         "Well_Private_SHS_Total" = NA, "Other_Private_SHS_Total" = NA,
                         "Private_SHS_Total" = NA,
                         
                         
                         "Pipeborne_Private_SHS_%" = NA, "Borehole_Private_SHS_%" = NA,
                         "Well_Private_SHS_%" = NA, "Other_Private_SHS_%" = NA,
                         "Private_SHS_%" = NA)
          } else{
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                         "Pipeborne_Public_SHS_Total" = data[1,1], "Borehole_Public_SHS_Total" = data[2,1],
                         "Well_Public_SHS_Total" = data[3,1], "Other_Public_SHS_Total" = data[4,1],
                         "Public_SHS_Total" = data[5,1],
                         
                         "Pipeborne_Public_SHS_%" = data[1,2], "Borehole_Public_SHS_%" = data[2,2],
                         "Well_Public_SHS_%" = data[3,2], "Other_Public_SHS_%" = data[4,2],
                         "Public_SHS_%" = data[5,2],
                         
                         
                         "Pipeborne_Public_TVET_Total" = data[1,3], "Borehole_Public_TVET_Total" = data[2,3],
                         "Well_Public_TVET_Total" = data[3,3], "Other_Public_TVET_Total" = data[4,3],
                         "Public_TVET_Total" = data[5,3],
                         
                         
                         "Pipeborne_Public_TVET_%" = data[1,4], "Borehole_Public_TVET_%" = data[2,4],
                         "Well_Public_TVET_%" = data[3,4], "Other_Public_TVET_%" = data[4,4],
                         "Public_TVET_%" = data[5,4],
                         
                         
                         "Pipeborne_Private_SHS_Total" = data[1,5], "Borehole_Private_SHS_Total" = data[2,5],
                         "Well_Private_SHS_Total" = data[3,5], "Other_Private_SHS_Total" = data[4,5],
                         "Private_SHS_Total" = data[5,5],
                         
                         
                         "Pipeborne_Private_SHS_%" = data[1,6], "Borehole_Private_SHS_%" = data[2,6],
                         "Well_Private_SHS_%" = data[3,6], "Other_Private_SHS_%" = data[4,6],
                         "Private_SHS_%" = data[5,6])
            df <- df %>% mutate_all(na_if, "")
          }
          }
  )

}

get_electricity <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year_parameter(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2015-2016", "2016-2017")){
    year_range_loc <- "2015-2017"
  } else if(year %in% c("2012-2013", "2013-2014", "2014-2015")){
    year_range_loc <- "2012-2015"
  } else {
    year_range_loc <- year
  }
  
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 185.720896632764, left = 298.88020202511, bottom = 263.919168899194, 
                                         right = 548.13719487435))
          },
          "2017-2018" = {loc <- list(c(top = 192.925398499661, left = 298.22974049553, bottom = 275.567374781561, 
                                       right = 547.3533791424))
          },
          "2015-2017" = {loc <- list(c(top = 202.367793814389, left = 304.08822367032, bottom = 276.594053135489, 
                                       right = 550.71095625333))
          },
          "2012-2015" = {loc <- list(c(top = 190.395816504529, left = 304.08822367032, bottom = 259.833284901689, 
                                       right = 551.90815398432))
          }
          
  )
  
  ### Adjust the year range for the content since there are layout change every several year
  if(year %in% c("2012-2013", "2013-2014", "2014-2015", "2015-2016", "2016-2017")){
    year_range_content <- "2012-2017"
  } else{
    year_range_content <- "2018-2020"
  }

  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  
  ##### Tidy and clean the data based on several parameter (year range,  number of column, etc)
  if(year_range_content == "2018-2020"){
    if(!(ncol(raw_data) == 7 && all(raw_data[1,c(3,5,7)] == "%"))){
      raw_data <- cbind(raw_data, "")
      for(i in c(2,4,6)){
        if(all(raw_data[3:nrow(raw_data), i] %>% str_detect(" "))){
          raw_data[3:nrow(raw_data), i+1] <- raw_data[3:nrow(raw_data), i]
          raw_data[3:nrow(raw_data), i] <- raw_data[3:nrow(raw_data), i] %>% str_before_nth(" ", 1)
          raw_data[3:nrow(raw_data), i+1] <- raw_data[3:nrow(raw_data), i+1] %>% str_after_nth(" ", 1)
        }
      }
    }
  }
  
  if(year == "2012-2013"){
    new_row <- rep("", 5)
    raw_data <- rbind(raw_data[1:3, ], new_row, raw_data[-(1:3), ]) %>% unname()
  }
  
  switch (year_range_content,
          "2012-2017" = {
            data <-  raw_data[-1, -1]

          },
          {
            data <- raw_data[-c(1:2), -1]
          }
  )
  
  ##### Store the data on a dataframe based on the year range since there are format change in several years
  switch (year_range_content,
          "2012-2017" = {if(is_empty(data) || is.null(nrow(data))){
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                         
                         "Nat_Grid_Public_Total" = NA, "Generator_Public_Total" = NA,
                         "Other_Public_Total" = NA, "Public_Total" = NA,
                         
                         "Nat_Grid_Public_%" = NA, "Generator_Public_%" = data[2,2],
                         "Other_Public_%" = NA, "Public_%" = NA,
                         
                         "Nat_Grid_Private_Total" = NA, "Generator_Private_Total" = NA,
                         "Other_Private_Total" = NA, "Private_Total" = NA,
                         
                         "Nat_Grid_Private_%" = NA, "Generator_Private_%" = NA,
                         "Other_Private_%" = NA, "Private_%" = NA)
          } else{
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                         
                         "Nat_Grid_Public_Total" = data[1,1], "Generator_Public_Total" = data[2,1],
                         "Other_Public_Total" = data[3,1], "Public_Total" = data[4,1],
                         
                         "Nat_Grid_Public_%" = data[1,2], "Generator_Public_%" = data[2,2],
                         "Other_Public_%" = data[3,2], "Public_%" = data[4,2],
                         
                         "Nat_Grid_Private_Total" = data[1,3], "Generator_Private_Total" = data[2,3],
                         "Other_Private_Total" = data[3,3], "Private_Total" = data[4,3],
                         
                         "Nat_Grid_Private_%" = data[1,4], "Generator_Private_%" = data[2,4],
                         "Other_Private_%" = data[3,4], "Private_%" = data[4,4])
            df <- df %>% mutate_all(na_if, "")
          }
            },
          {  ######### Create a Dataframe from the extracted data
            if(is_empty(data) || is.null(nrow(data))){
              df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                           
                           "Nat_Grid_Public_SHS_Total" = NA, "Generator_Public_SHS_Total" = NA,
                           "Other_Public_SHS_Total" = NA, "Public_SHS_Total" = NA,
                           
                           "Nat_Grid_Public_SHS_%" = NA, "Generator_Public_SHS_%" = NA,
                           "Other_Public_SHS_%" = NA, "Public_SHS_%" = NA,
                           
                           "Nat_Grid_Public_TVET_Total" = NA, "Generator_Public_TVET_Total" = NA,
                           "Other_Public_TVET_Total" = NA, "Public_TVET_Total" = NA,
                           
                           "Nat_Grid_Public_TVET_%" = NA, "Generator_Public_TVET_%" = NA,
                           "Other_Public_TVET_%" = NA, "Public_TVET_%" = NA,
                           
                           "Nat_Grid_Private_SHS_Total" = NA, "Generator_Private_SHS_Total" = NA,
                           "Other_Private_SHS_Total" = NA, "Private_SHS_Total" = NA,
                           
                           "Nat_Grid_Private_SHS_%" = NA, "Generator_Private_SHS_%" = NA,
                           "Other_Private_SHS_%" = NA, "Private_SHS_%" = NA)
            } else{
              df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                           
                           "Nat_Grid_Public_SHS_Total" = data[1,1], "Generator_Public_SHS_Total" = data[2,1],
                           "Other_Public_SHS_Total" = data[3,1], "Public_SHS_Total" = data[4,1],
                           
                           "Nat_Grid_Public_SHS_%" = data[1,2], "Generator_Public_SHS_%" = data[2,2],
                           "Other_Public_SHS_%" = data[3,2], "Public_SHS_%" = data[4,2],
                           
                           "Nat_Grid_Public_TVET_Total" = data[1,3], "Generator_Public_TVET_Total" = data[2,3],
                           "Other_Public_TVET_Total" = data[3,3], "Public_TVET_Total" = data[4,3],
                           
                           "Nat_Grid_Public_TVET_%" = data[1,4], "Generator_Public_TVET_%" = data[2,4],
                           "Other_Public_TVET_%" = data[3,4], "Public_TVET_%" = data[4,4],
                           
                           "Nat_Grid_Private_SHS_Total" = data[1,5], "Generator_Private_SHS_Total" = data[2,5],
                           "Other_Private_SHS_Total" = data[3,5], "Private_SHS_Total" = data[4,5],
                           
                           "Nat_Grid_Private_SHS_%" = data[1,6], "Generator_Private_SHS_%" = data[2,6],
                           "Other_Private_SHS_%" = data[3,6], "Private_SHS_%" = data[4,6])
              df <- df %>% mutate_all(na_if, "")
            }
            }
  )


}

get_social_facilities <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year_parameter(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2015-2016", "2016-2017")){
    year_range_loc <- "2015-2017"
  } else if(year %in% c("2012-2013", "2013-2014", "2014-2015")){
    year_range_loc <- "2012-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 185.720896632764, left = 553.024586891, bottom = 259.031776882544, 
                                         right = 796.17233971942))
          },
          "2017-2018" = {loc <- list(c(top = 191.727688698481, left = 553.34192814834, bottom = 275.567374781561, 
                                       right = 801.26785699402))
          },
          "2015-2017" = {loc <- list(c(top = 202.367793814389, left = 567.47172448713, bottom = 275.396855404499, 
                                       right = 794.93929337438))
          },
          "2012-2015" = {loc <- list(c(top = 190.1, left = 549.8661199491, bottom = 261.030482632679, 
                                       right = 798.53088656733))
          }
  )
  
  ### Adjust the year range for the content since there are layout change every several year
  if(year %in% c("2012-2013", "2013-2014", "2014-2015", "2015-2016", "2016-2017")){
    year_range_content <- "2012-2017"
  } else{
    year_range_content <- "2018-2020"
  }
  
  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  
  ##### Tidy and clean the data based on several parameter (year range,  number of column, etc)
  if(year_range_content == "2018-2020"){
    if(!(ncol(raw_data) == 7 && all(raw_data[1,c(3,5,7)] == "%"))){
      raw_data <- cbind(raw_data, "")
      for(i in c(2,4,6)){
        if(all(raw_data[3:nrow(raw_data), i] %>% str_detect(" "))){
          raw_data[3:nrow(raw_data), i+1] <- raw_data[3:nrow(raw_data), i]
          raw_data[3:nrow(raw_data), i] <- raw_data[3:nrow(raw_data), i] %>% str_before_nth(" ", 1)
          raw_data[3:nrow(raw_data), i+1] <- raw_data[3:nrow(raw_data), i+1] %>% str_after_nth(" ", 1)
        }
      }
    }
  } 
  
  if(year_range_content == "2012-2017"){
    if(ncol(raw_data) == 7){
      raw_data <- raw_data[, -c(4,7)]
    } else if(ncol(raw_data) == 6){
      raw_data <- raw_data[, -4]
    } else{
      raw_data <- raw_data
    }
  }
  
  switch (year_range_content,
          "2012-2017" = {
            data <-  raw_data[-1, -1]
          },
          {
            data <- raw_data[-c(1:2), -1]
          }
  )
  
  ##### Store the data on a dataframe based on the year range since there are format change in several years
  switch (year_range_content,
          "2012-2017" = {if(is_empty(data) || is.null(nrow(data))){
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                         
                         "Toilets_Public_Total" = NA, "Urinal_Public_Total" = NA,
                         "Drinking_Water_Public_Total" = NA, "Electricity_Public_Total" = NA,
                         
                         "Toilets_Public_%" = NA, "Urinal_Public_%" = NA,
                         "Drinking_Water_Public_%" = NA, "Electricity_Public_%" = NA,
                         
                         "Toilets_Private_Total" = NA, "Urinal_Private_Total" = NA,
                         "Drinking_Water_Private_Total" = NA, "Electricity_Private_Total" = NA,
                         
                         "Toilets_Private_%" = NA, "Urinal_Private_%" = NA,
                         "Drinking_Water_Private_%" = NA, "Electricity_Private_%" = NA)
          } else{
            df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                         
                         "Toilets_Public_Total" = data[1,1], "Urinal_Public_Total" = data[2,1],
                         "Drinking_Water_Public_Total" = data[3,1], "Electricity_Public_Total" = data[4,1],
                         
                         "Toilets_Public_%" = data[1,2], "Urinal_Public_%" = data[2,2],
                         "Drinking_Water_Public_%" = data[3,2], "Electricity_Public_%" = data[4,2],
                         
                         "Toilets_Private_Total" = data[1,3], "Urinal_Private_Total" = data[2,3],
                         "Drinking_Water_Private_Total" = data[3,3], "Electricity_Private_Total" = data[4,3],
                         
                         "Toilets_Private_%" = data[1,4], "Urinal_Private_%" = data[2,4],
                         "Drinking_Water_Private_%" = data[3,4], "Electricity_Private_%" = data[4,4])
            df <- df %>% mutate_all(na_if, "")
          }},
          {if(is_empty(data) || is.null(nrow(data))){
              df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                           
                           "Toilets_Public_SHS_Total" = NA, "Urinal_Public_SHS_Total" = NA,
                           "Drinking_Water_Public_SHS_Total" = NA, "Electricity_Public_SHS_Total" = NA,
                           
                           "Toilets_Public_SHS_%" = NA, "Urinal_Public_SHS_%" = NA,
                           "Drinking_Water_Public_SHS_%" = NA, "Electricity_Public_SHS_%" = NA,
                           
                           "Toilets_Public_TVET_Total" = NA, "Urinal_Public_TVET_Total" = NA,
                           "Drinking_Water_Public_TVET_Total" = NA, "Electricity_Public_TVET_Total" = NA,
                           
                           "Toilets_Public_TVET_%" = NA, "Urinal_Public_TVET_%" = NA,
                           "Drinking_Water_Public_TVET_%" = NA, "Electricity_Public_TVET_%" = NA,
                           
                           "Toilets_Private_SHS_Total" = NA, "Urinal_Private_SHS_Total" = NA,
                           "Drinking_Water_Private_SHS_Total" = NA, "Electricity_Private_SHS_Total" = NA,
                           
                           "Toilets_Private_SHS_%" = NA, "Urinal_Private_SHS_%" = NA,
                           "Drinking_Water_Private_SHS_%" = NA, "Electricity_Private_SHS_%" = NA)
            } else{
              df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                           
                           "Toilets_Public_SHS_Total" = data[1,1], "Urinal_Public_SHS_Total" = data[2,1],
                           "Drinking_Water_Public_SHS_Total" = data[3,1], "Electricity_Public_SHS_Total" = data[4,1],
                           
                           "Toilets_Public_SHS_%" = data[1,2], "Urinal_Public_SHS_%" = data[2,2],
                           "Drinking_Water_Public_SHS_%" = data[3,2], "Electricity_Public_SHS_%" = data[4,2],
                           
                           "Toilets_Public_TVET_Total" = data[1,3], "Urinal_Public_TVET_Total" = data[2,3],
                           "Drinking_Water_Public_TVET_Total" = data[3,3], "Electricity_Public_TVET_Total" = data[4,3],
                           
                           "Toilets_Public_TVET_%" = data[1,4], "Urinal_Public_TVET_%" = data[2,4],
                           "Drinking_Water_Public_TVET_%" = data[3,4], "Electricity_Public_TVET_%" = data[4,4],
                           
                           "Toilets_Private_SHS_Total" = data[1,5], "Urinal_Private_SHS_Total" = data[2,5],
                           "Drinking_Water_Private_SHS_Total" = data[3,5], "Electricity_Private_SHS_Total" = data[4,5],
                           
                           "Toilets_Private_SHS_%" = data[1,6], "Urinal_Private_SHS_%" = data[2,6],
                           "Drinking_Water_Private_SHS_%" = data[3,6], "Electricity_Private_SHS_%" = data[4,6])
              df <- df %>% mutate_all(na_if, "")
            }
            }
  )

}

get_boarding_facilities <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
    info_data <- get_area_year_parameter(pdf_file, page = page, year = year)
    
    ### Adjust the year range since there are layout change every several year
    if(year %in% c("2018-2019", "2019-2020")){
      year_range_loc <- "2018-2020"
    } else if(year %in% c("2015-2016", "2016-2017")){
      year_range_loc <- "2015-2017"
    } else if(year %in% c("2012-2013", "2013-2014", "2014-2015")){
      year_range_loc <- "2012-2015"
    } else {
      year_range_loc <- year
    }
    
    ### Adjust the year range since there are layout change every several year
    switch (year_range_loc,
            "2018-2020" = {loc <- list(c(top = 305.306397309174, left = 31.14563318201, bottom = 421.503567257444, 
                                         right = 291.09187935494))
            },
            "2017-2018" = {loc <- list(c(top = 319.882637425471, left = 29.942745029672, bottom = 442.049037146531, 
                                         right = 292.2411914896))
            },
            "2015-2017" = {loc <- list(c(top = 319.693171450969, left = 35.915931929565, bottom = 417.863385391779, 
                                         right = 282.53866451258))
            },
            "2012-2015" = {loc <- list(c(top = 307.721194141109, left = 31.127141005623, bottom = 416.666187660789, 
                                         right = 289.72185089849))
            }
            
    )
    
    
    ### Adjust the year range for the content since there are layout change every several year
    if(year %in% c("2012-2013", "2013-2014", "2014-2015", "2015-2016", "2016-2017")){
      year_range_content <- "2012-2017"
    } else{
      year_range_content <- "2018-2020"
    }
    
    ######## Extract the related data from pdf file
    raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
    
    ##### Tidy and clean the data based on several parameter (year range,  number of column, etc)
    if(year_range_content == "2018-2020"){
      if(!(ncol(raw_data) == 7 && all(raw_data[1,c(3,5,7)] == "%"))){
        raw_data <- cbind(raw_data, "")
        for(i in c(2,4,6)){
          if(all(raw_data[3:nrow(raw_data), i] %>% str_detect(" "))){
            raw_data[3:nrow(raw_data), i+1] <- raw_data[3:nrow(raw_data), i]
            raw_data[3:nrow(raw_data), i] <- raw_data[3:nrow(raw_data), i] %>% str_before_nth(" ", 1)
            raw_data[3:nrow(raw_data), i+1] <- raw_data[3:nrow(raw_data), i+1] %>% str_after_nth(" ", 1)
          }
        }
      }
    } 
    
    if(year_range_content == "2012-2017"){
      if(ncol(raw_data) == 7){
        raw_data <- raw_data[, -c(4,7)]
      } else if(ncol(raw_data) == 6){
        raw_data <- raw_data[, -4]
      } else{
        raw_data <- raw_data
      }
    }
    
    switch (year_range_content,
            "2012-2017" = {
              data <-  raw_data[-1, -1]
            },
            {
              data <- raw_data[-c(1:2), -1]
            }
    )
    
    ##### Store the data on a dataframe based on the year range since there are format change in several years
    switch (year_range_content,
            "2012-2017" = {if(is_empty(data) || is.null(nrow(data))){
              df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                           
                           "Day_Only_Public_Total" = NA, "Day_With_Hostel_Public_Total" = NA,
                           "Mainly_Boarding_Public_Total" = NA, "Boarding_Day_Hostel_Public_Total" = NA,
                           "Boarding_Day_Public_Total" = NA, "Public_Total" = NA,
                           
                           "Day_Only_Public_%" = NA, "Day_With_Hostel_Public_%" = NA,
                           "Mainly_Boarding_Public_%" = NA, "Boarding_Day_Hostel_Public_%" = NA,
                           "Boarding_Day_Public_%" = NA,"Public_%" = NA,
                           
                           "Day_Only_Private_Total" = NA, "Day_With_Hostel_Private_Total" = NA,
                           "Mainly_Boarding_Private_Total" = NA, "Boarding_Day_Hostel_Private_Total" = NA,
                           "Boarding_Day_Private_Total" = NA, "Private_Total" = NA,
                           
                           "Day_Only_Private_%" = NA, "Day_With_Hostel_Private_%" = NA,
                           "Mainly_Boarding_Private_%" = NA, "Boarding_Day_Hostel_Private_%" = NA,
                           "Boarding_Day_Private_%" = NA,"Private_%" = NA)
            } else{
              df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                           
                           "Day_Only_Public_Total" = data[1,1], "Day_With_Hostel_Public_Total" = data[2,1],
                           "Mainly_Boarding_Public_Total" = data[3,1], "Boarding_Day_Hostel_Public_Total" = data[4,1],
                           "Boarding_Day_Public_Total" = data[5,1], "Public_Total" = data[6,1],
                           
                           "Day_Only_Public_%" = data[1,2], "Day_With_Hostel_Public_%" = data[2,2],
                           "Mainly_Boarding_Public_%" = data[3,2], "Boarding_Day_Hostel_Public_%" = data[4,2],
                           "Boarding_Day_Public_%" = data[5,2],"Public_%" = data[6,2],

                           "Day_Only_Private_Total" = data[1,3], "Day_With_Hostel_Private_Total" = data[2,3],
                           "Mainly_Boarding_Private_Total" = data[3,3], "Boarding_Day_Hostel_Private_Total" = data[4,3],
                           "Boarding_Day_Private_Total" = data[5,3], "Private_Total" = data[6,3],
                           
                           "Day_Only_Private_%" = data[1,4], "Day_With_Hostel_Private_%" = data[2,4],
                           "Mainly_Boarding_Private_%" = data[3,4], "Boarding_Day_Hostel_Private_%" = data[4,4],
                           "Boarding_Day_Private_%" = data[5,4],"Private_%" = data[6,4])
              df <- df %>% mutate_all(na_if, "")
            }
              },
            {if(is_empty(data) || is.null(nrow(data))){
              df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                           
                           "Day_Only_Public_SHS_Total" = NA, "Day_With_Hostel_Public_SHS_Total" = NA,
                           "Mainly_Boarding_Public_SHS_Total" = NA, "Boarding_Day_Hostel_Public_SHS_Total" = NA,
                           "Boarding_Day_Public_SHS_Total" = NA, "Public_SHS_Total" = NA,
                           
                           "Day_Only_Public_SHS_%" = NA, "Day_With_Hostel_Public_SHS_%" = NA,
                           "Mainly_Boarding_Public_SHS_%" = NA, "Boarding_Day_Hostel_Public_SHS_%" = NA,
                           "Boarding_Day_Public_SHS_%" = NA,"Public_SHS_%" = NA,
                           
                           "Day_Only_Public_TVET_Total" = NA, "Day_With_Hostel_Public_TVET_Total" = NA,
                           "Mainly_Boarding_Public_TVET_Total" = NA, "Boarding_Day_Hostel_Public_TVET_Total" = NA,
                           "Boarding_Day_Public_TVET_Total" = NA,"Public_TVET_Total" = NA,
                           
                           "Day_Only_Public_TVET_%" = NA, "Day_With_Hostel_Public_TVET_%" = NA,
                           "Mainly_Boarding_Public_TVET_%" = NA, "Boarding_Day_Hostel_Public_TVET_%" = NA,
                           "Boarding_Day_Public_TVET_%" = NA,"Public_TVET_%" = NA,
                           
                           "Day_Only_Private_SHS_Total" = NA, "Day_With_Hostel_Private_SHS_Total" = NA,
                           "Mainly_Boarding_Private_SHS_Total" = NA, "Boarding_Day_Hostel_Private_SHS_Total" = NA,
                           "Boarding_Day_Private_SHS_Total" = NA, "Private_SHS_Total" = NA,
                           
                           "Day_Only_Private_SHS_%" = NA, "Day_With_Hostel_Private_SHS_%" = NA,
                           "Mainly_Boarding_Private_SHS_%" = NA, "Boarding_Day_Hostel_Private_SHS_%" = NA,
                           "Boarding_Day_Private_SHS_%" = NA,"Private_SHS_%" = NA)
            } else{
              df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                           
                           "Day_Only_Public_SHS_Total" = data[1,1], "Day_With_Hostel_Public_SHS_Total" = data[2,1],
                           "Mainly_Boarding_Public_SHS_Total" = data[3,1], "Boarding_Day_Hostel_Public_SHS_Total" = data[4,1],
                           "Boarding_Day_Public_SHS_Total" = data[5,1], "Public_SHS_Total" = data[6,1],
                           
                           "Day_Only_Public_SHS_%" = data[1,2], "Day_With_Hostel_Public_SHS_%" = data[2,2],
                           "Mainly_Boarding_Public_SHS_%" = data[3,2], "Boarding_Day_Hostel_Public_SHS_%" = data[4,2],
                           "Boarding_Day_Public_SHS_%" = data[5,2],"Public_SHS_%" = data[6,2],
                           
                           "Day_Only_Public_TVET_Total" = data[1,3], "Day_With_Hostel_Public_TVET_Total" = data[2,3],
                           "Mainly_Boarding_Public_TVET_Total" = data[3,3], "Boarding_Day_Hostel_Public_TVET_Total" = data[4,3],
                           "Boarding_Day_Public_TVET_Total" = data[5,3],"Public_TVET_Total" = data[6,3],
                           
                           "Day_Only_Public_TVET_%" = data[1,4], "Day_With_Hostel_Public_TVET_%" = data[2,4],
                           "Mainly_Boarding_Public_TVET_%" = data[3,4], "Boarding_Day_Hostel_Public_TVET_%" = data[4,4],
                           "Boarding_Day_Public_TVET_%" = data[5,4],"Public_TVET_%" = data[6,4],
                           
                           "Day_Only_Private_SHS_Total" = data[1,5], "Day_With_Hostel_Private_SHS_Total" = data[2,5],
                           "Mainly_Boarding_Private_SHS_Total" = data[3,5], "Boarding_Day_Hostel_Private_SHS_Total" = data[4,5],
                           "Boarding_Day_Private_SHS_Total" = data[5,5], "Private_SHS_Total" = data[6,5],
                           
                           "Day_Only_Private_SHS_%" = data[1,6], "Day_With_Hostel_Private_SHS_%" = data[2,6],
                           "Mainly_Boarding_Private_SHS_%" = data[3,6], "Boarding_Day_Hostel_Private_SHS_%" = data[4,6],
                           "Boarding_Day_Private_SHS_%" = data[5,6],"Private_SHS_%" = data[6,6])
              df <- df %>% mutate_all(na_if, "")
            }
              }
    )
  }

get_pedagogical_tools <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year_parameter(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2015-2016", "2016-2017")){
    year_range_loc <- "2015-2017"
  } else if(year %in% c("2012-2013", "2013-2014", "2014-2015")){
    year_range_loc <- "2012-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 301.796457028244, left = 302.5457460376, bottom = 432.534193473674, 
                                         right = 545.69349886602))
          },
          "2017-2018" = {loc <- list(c(top = 318.684927624281, left = 303.02057970028, bottom = 438.455907742971, 
                                       right = 543.76024973884))
          },
          "2015-2017" = {loc <- list(c(top = 316.101578258009, left = 301.69382820835, bottom = 445.398933204449, 
                                       right = 557.89414263925))
          },
          "2012-2015" = {loc <- list(c(top = 304.129600948159, left = 300.49663047736, bottom = 434.624153625579, 
                                       right = 560.28853810122))
          }
  )
  
  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  
  data <- raw_data[-c(1,2,5), -1]
  
  ##### Store the data on a dataframe
  if(is_empty(data) || is.null(nrow(data))){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                 
                 "Furniture_Sitting_Places_Public_Total" = NA, "Furniture_Writing_Places_Public_Total" = NA,
                 "Textbook_English_Public_Total" = NA, "Textbook_Mathematics_Public_Total" = NA,
                 "Textbook_Integrated_Science_Public_Total" = NA, "Textbook_Social_Studies_Public_Total" = NA,
                 
                 "Furniture_Sitting_Places_Public_Per_Student" = NA, "Furniture_Writing_Places_Public_Per_Student" = NA,
                 "Textbook_English_Public_Per_Student" = NA, "Textbook_Mathematics_Public_Per_Student" = NA,
                 "Textbook_Integrated_Science_Public_Per_Student" = NA, "Textbook_Social_Studies_Public_Per_Student" = NA,
                 
                 "Furniture_Sitting_Places_Private_Total" = NA, "Furniture_Writing_Places_Private_Total" = NA,
                 "Textbook_English_Private_Total" = NA, "Textbook_Mathematics_Private_Total" = NA,
                 "Textbook_Integrated_Science_Private_Total" = NA, "Textbook_Social_Studies_Private_Total" = NA,
                 
                 "Furniture_Sitting_Places_Private_Per_Student" = NA, "Furniture_Writing_Places_Private_Per_Student" = NA,
                 "Textbook_English_Private_Per_Student" = NA, "Textbook_Mathematics_Private_Per_Student" = NA,
                 "Textbook_Integrated_Science_Private_Per_Student" = NA, "Textbook_Social_Studies_Private_Per_Student" = NA
    )
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                 
                 "Furniture_Sitting_Places_Public_Total" = data[1,1], "Furniture_Writing_Places_Public_Total" = data[2,1],
                 "Textbook_English_Public_Total" = data[3,1], "Textbook_Mathematics_Public_Total" = data[4,1],
                 "Textbook_Integrated_Science_Public_Total" = data[5,1], "Textbook_Social_Studies_Public_Total" = data[6,1],
                 
                 "Furniture_Sitting_Places_Public_Per_Student" = data[1,2], "Furniture_Writing_Places_Public_Per_Student" = data[2,2],
                 "Textbook_English_Public_Per_Student" = data[3,2], "Textbook_Mathematics_Public_Per_Student" = data[4,2],
                 "Textbook_Integrated_Science_Public_Per_Student" = data[5,2], "Textbook_Social_Studies_Public_Per_Student" = data[6,2],
                 
                 "Furniture_Sitting_Places_Private_Total" = data[1,3], "Furniture_Writing_Places_Private_Total" = data[2,3],
                 "Textbook_English_Private_Total" = data[3,3], "Textbook_Mathematics_Private_Total" = data[4,3],
                 "Textbook_Integrated_Science_Private_Total" = data[5,3], "Textbook_Social_Studies_Private_Total" = data[6,3],
                 
                 "Furniture_Sitting_Places_Private_Per_Student" = data[1,4], "Furniture_Writing_Places_Private_Per_Student" = data[2,4],
                 "Textbook_English_Private_Per_Student" = data[3,4], "Textbook_Mathematics_Private_Per_Student" = data[4,4],
                 "Textbook_Integrated_Science_Private_Per_Student" = data[5,4], "Textbook_Social_Studies_Private_Per_Student" = data[6,4]
    )
    df <- df %>% mutate_all(na_if, "")
    return(df)
  }
}

get_rates_and_ratio <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year_parameter(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2015-2016", "2016-2017")){
    year_range_loc <- "2015-2017"
  } else if(year %in% c("2012-2013", "2013-2014", "2014-2015")){
    year_range_loc <- "2012-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 270.028408920004, left = 564.02121892847, bottom = 452.083761540284, 
                                         right = 797.39418772359))
          },
          "2017-2018" = {loc <- list(c(top = 293.533021799361, left = 573.70299476851, bottom = 446.839876351281, 
                                       right = 794.0815981869))
          },
          "2015-2017" = {loc <- list(c(top = 293.354821369289, left = 567.47172448713, bottom = 446.596130935429, 
                                       right = 794.93929337438))
          },
          "2012-2015" = {loc <- list(c(top = 276.382844059429, left = 556.27452675615, bottom = 439.412944549519, 
                                       right = 798.53088656733))
          }
          
  )
  

  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  
  data <- raw_data[-1, -1]
  
  ##### Tidy and clean the data based on several parameter (year range,  number of column, etc)
  if(nrow(data) == 11){
    data <- rbind(data, matrix(NA, 2, 3))
  }
  
  if(nrow(data) == 10){
    data <- rbind(data, matrix(NA, 3, 3))
  }
  
  ######### Create a Dataframe from the extracted data
  if(is_empty(data) || is.null(nrow(data))){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                 
                 "Popn15-17yrs_Total" = NA, "Total_Enrolment" = NA,
                 "Enrol15-17yrs_Total" = NA, "Popn15yrs_Total" = NA,
                 "SHS1_Enrolment_Total" = NA, "Enrol15yrs_Total" = NA,
                 "Gross_Enrollment_Ratio_Total" = NA, "Gross_Admission_Ratio_Total" = NA,
                 "Net_Enrollment_Rate_Total" = NA, "Net_Admission_Rate_Total" = NA,
                 "Completion_Rate_Total" = NA, "Transition_Rate_Total" = NA,
                 "GPI_Total" = NA,
                 
                 "Popn25-27yrs_Male" = NA, "Male_Enrolment" = NA,
                 "Enrol25-27yrs_Male" = NA, "Popn25yrs_Male" = NA,
                 "SHS2_Enrolment_Male" = NA, "Enrol25yrs_Male" = NA,
                 "Gross_Enrollment_Ratio_Male" = NA, "Gross_Admission_Ratio_Male" = NA,
                 "Net_Enrollment_Rate_Male" = NA, "Net_Admission_Rate_Male" = NA,
                 "Completion_Rate_Male" = NA, "Transition_Rate_Male" = NA,
                 "GPI_Male" = NA,
                 
                 "Popn35-37yrs_Female" = NA, "Female_Enrolment" = NA,
                 "Enrol35-37yrs_Female" = NA, "Popn35yrs_Female" = NA,
                 "SHS3_Enrolment_Female" = NA, "Enrol35yrs_Female" =NA,
                 "Gross_Enrollment_Ratio_Female" = NA, "Gross_Admission_Ratio_Female" = NA,
                 "Net_Enrollment_Rate_Female" = NA, "Net_Admission_Rate_Female" = NA,
                 "Completion_Rate_Female" = NA, "Transition_Rate_Female" = NA,
                 "GPI_Female" = NA)
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                 
                 "Popn15-17yrs_Total" = data[1,1], "Total_Enrolment" = data[2,1],
                 "Enrol15-17yrs_Total" = data[3,1], "Popn15yrs_Total" = data[4,1],
                 "SHS1_Enrolment_Total" = data[5,1], "Enrol15yrs_Total" = data[6,1],
                 "Gross_Enrollment_Ratio_Total" = data[7,1], "Gross_Admission_Ratio_Total" = data[8,1],
                 "Net_Enrollment_Rate_Total" = data[9,1], "Net_Admission_Rate_Total" = data[10,1],
                 "Completion_Rate_Total" = data[11, 1], "Transition_Rate_Total" = data[12, 1],
                 "GPI_Total" = data[13, 1],
                 
                 "Popn25-27yrs_Male" = data[1,2], "Male_Enrolment" = data[2,2],
                 "Enrol25-27yrs_Male" = data[3,2], "Popn25yrs_Male" = data[4,2],
                 "SHS2_Enrolment_Male" = data[5,2], "Enrol25yrs_Male" = data[6,2],
                 "Gross_Enrollment_Ratio_Male" = data[7,2], "Gross_Admission_Ratio_Male" = data[8,2],
                 "Net_Enrollment_Rate_Male" = data[9,2], "Net_Admission_Rate_Male" = data[10,2],
                 "Completion_Rate_Male" = data[11, 2], "Transition_Rate_Male" = data[12, 2],
                 "GPI_Male" = data[13, 2],
                 
                 "Popn35-37yrs_Female" = data[1,3], "Female_Enrolment" = data[2,3],
                 "Enrol35-37yrs_Female" = data[3,3], "Popn35yrs_Female" = data[4,3],
                 "SHS3_Enrolment_Female" = data[5,3], "Enrol35yrs_Female" = data[6,3],
                 "Gross_Enrollment_Ratio_Female" = data[7,3], "Gross_Admission_Ratio_Female" = data[8,3],
                 "Net_Enrollment_Rate_Female" = data[9,3], "Net_Admission_Rate_Female" = data[10,3],
                 "Completion_Rate_Female" = data[11, 3], "Transition_Rate_Female" = data[12, 3],
                 "GPI_Female" = data[13, 3]
    )
    df <- df %>% mutate_all(na_if, "")
    return(df)
  }
}

get_maths_pass_rate <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year_parameter(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2015-2016", "2016-2017")){
    year_range_loc <- "2015-2017"
  } else if(year %in% c("2012-2013", "2013-2014", "2014-2015")){
    year_range_loc <- "2012-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 483.851809648514, left = 56.954297200855, bottom = 535.169425823361, 
                                         right = 728.97069949046))
          },
          "2017-2018" = {loc <- list(c(top = 483.968880188071, left = 62.280909661718, bottom = 540.261240843858, 
                                       right = 222.77402302076))
          },
          "2015-2017" = {loc <- list(c(top = 481.314865134009, left = 35.915931929565, bottom = 541.174751683286, 
                                       right = 229.86196434922))
          },
          "2012-2015" = {loc <- list(c(top = 469.342887824159, left = 35.915931929565, bottom = 525.611181180474, 
                                       right = 226.27037115626))
          }
          
  )
  
  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  data <- raw_data[-1, -1]
  
  ######### Create a Dataframe from the extracted data
  if(is_empty(data) || is.null(nrow(data))){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                 
                 "Maths_Total" = NA, "Maths_Boys_Total" = NA,
                 "Maths_Girls_Total" = NA,
                 
                 "Maths_Total_Pass" = NA, "Maths_Boys_Pass" = NA,
                 "Maths_Girls_Pass" = NA,
                 
                 "Maths_Total_%Pass" = NA, "Maths_Boys_%Pass" = NA,
                 "Maths_Girls_%Pass" = NA)
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                 
                 "Maths_Total" = data[1,1], "Maths_Boys_Total" = data[2,1],
                 "Maths_Girls_Total" = data[3,1],
                 
                 "Maths_Total_Pass" = data[1,2], "Maths_Boys_Pass" = data[2,2],
                 "Maths_Girls_Pass" = data[3,2],
                 
                 "Maths_Total_%Pass" = data[1,3], "Maths_Boys_%Pass" = data[2,3],
                 "Maths_Girls_%Pass" = data[3,3]
    )
    df <- df %>% mutate_all(na_if, "")
    return(df)
  }
}

get_english_pass_rate <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year_parameter(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2015-2016", "2016-2017")){
    year_range_loc <- "2015-2017"
  } else if(year %in% c("2012-2013", "2013-2014", "2014-2015")){
    year_range_loc <- "2012-2015"
  } else {
    year_range_loc <- year
  }
  
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 483.851809648514, left = 56.954297200855, bottom = 535.169425823361, 
                                         right = 728.97069949046))
          },
          "2017-2018" = {loc <- list(c(top = 485.166589989261, left = 62.280909661718, bottom = 543.854370247419, 
                                       right = 396.44194419286))
          },
          "2015-2017" = {loc <- list(c(top = 480.117667403029, left = 31.127141005623, bottom = 539.9775539523, 
                                       right = 421.4136013069))
          },
          "2012-2015" = {loc <- list(c(top = 469.342887824159, left = 32.324338736609, bottom = 531.597169835402, 
                                       right = 417.82200811394))
          }
          
  )

  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  data <- raw_data[-1, -1]
  
  ######### Create a Dataframe from the extracted data
  if(is_empty(data) || is.null(nrow(data))){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                 
                 "English_Total" = NA, "English_Boys_Total" = NA,
                 "English_Girls_Total" = NA,
                 
                 "English_Total_Pass" = NA, "English_Boys_Pass" = NA,
                 "English_Girls_Pass" = NA,
                 
                 "English_Total_%Pass" = NA, "English_Boys_%Pass" = NA,
                 "English_Girls_%Pass" = NA)
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                 
                 "English_Total" = data[1,4], "English_Boys_Total" = data[2,4],
                 "English_Girls_Total" = data[3,4],
                 
                 "English_Total_Pass" = data[1,5], "English_Boys_Pass" = data[2,5],
                 "English_Girls_Pass" = data[3,5],
                 
                 "English_Total_%Pass" = data[1,6], "English_Boys_%Pass" = data[2,6],
                 "English_Girls_%Pass" = data[3,6]
    )
    df <- df %>% mutate_all(na_if, "")
    return(df)
  }
}

get_int_science_pass_rate <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year_parameter(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2015-2016", "2016-2017")){
    year_range_loc <- "2015-2017"
  } else if(year %in% c("2012-2013", "2013-2014", "2014-2015")){
    year_range_loc <- "2012-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 483.851809648514, left = 56.954297200855, bottom = 535.169425823361, 
                                         right = 728.97069949046))
          },
          "2017-2018" = {loc <- list(c(top = 483.968880188071, left = 59.885490059344, bottom = 540.261240843858, 
                                       right = 558.13276735309))
          },
          "2015-2017" = {loc <- list(c(top = 481.314865134009, left = 32.324338736609, bottom = 542.371949414271, 
                                       right = 585.42969045191))
          },
          "2012-2015" = {loc <- list(c(top = 468.737283286129, left = 32.324338736609, bottom = 529.202774373431, 
                                       right = 592.61287683783))
          }
          
  )

  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  data <- raw_data[-1, -1]
  
  ######### Create a Dataframe from the extracted data
  if(is_empty(data) || is.null(nrow(data))){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                 
                 "Int_Science_Total" = NA, "Int_Science_Boys_Total" = NA,
                 "Int_Science_Girls_Total" = NA,
                 
                 "Int_Science_Total_Pass" = NA, "Int_Science_Boys_Pass" = NA,
                 "Int_Science_Girls_Pass" = NA,
                 
                 "Int_Science_Total_%Pass" = NA, "Int_Science_Boys_%Pass" = NA,
                 "Int_Science_Girls_%Pass" = NA)
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                 
                 "Int_Science_Total" = data[1,7], "Int_Science_Boys_Total" = data[2,7],
                 "Int_Science_Girls_Total" = data[3,7],
                 
                 "Int_Science_Total_Pass" = data[1,8], "Int_Science_Boys_Pass" = data[2,8],
                 "Int_Science_Girls_Pass" = data[3,8],
                 
                 "Int_Science_Total_%Pass" = data[1,9], "Int_Science_Boys_%Pass" = data[2,9],
                 "Int_Science_Girls_%Pass" = data[3,9]
    )
    df <- df %>% mutate_all(na_if, "")
    return(df)
  }
}

get_social_studies_pass_rate <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year_parameter(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2015-2016", "2016-2017")){
    year_range_loc <- "2015-2017"
  } else if(year %in% c("2012-2013", "2013-2014", "2014-2015")){
    year_range_loc <- "2012-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 483.851809648514, left = 56.954297200855, bottom = 535.169425823361, 
                                         right = 728.97069949046))
          },
          "2017-2018" = {loc <- list(c(top = 485.166589989261, left = 59.885490059344, bottom = 537.865821241484, 
                                       right = 717.42817091094))
          },
          "2015-2017" = {loc <- list(c(top = 480.117667403029, left = 33.521536467594, bottom = 542.371949414271, 
                                       right = 792.54489791241))
          },
          "2012-2015" = {loc <- list(c(top = 468.145690093169, left = 29.929943274638, bottom = 528.005576642445, 
                                       right = 798.53088656733))
          }
          
  )
  
  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  data <- raw_data[-1, -1]
  
  ######### Create a Dataframe from the extracted data
  if(is_empty(data) || is.null(nrow(data))){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                 
                 "Social_Studies_Total" = NA, "Social_Studies_Boys_Total" = NA,
                 "Social_Studies_Girls_Total" = NA,
                 
                 "Social_Studies_Total_Pass" = NA, "Social_Studies_Boys_Pass" = NA,
                 "Social_Studies_Girls_Pass" = NA,
                 
                 "Social_Studies_Total_%Pass" = NA, "Social_Studies_Boys_%Pass" = NA,
                 "Social_Studies_Girls_%Pass" = NA)
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region,
                 
                 "Social_Studies_Total" = data[1,10], "Social_Studies_Boys_Total" = data[2,10],
                 "Social_Studies_Girls_Total" = data[3,10],
                 
                 "Social_Studies_Total_Pass" = data[1,11], "Social_Studies_Boys_Pass" = data[2,11],
                 "Social_Studies_Girls_Pass" = data[3,11],
                 
                 "Social_Studies_Total_%Pass" = data[1,12], "Social_Studies_Boys_%Pass" = data[2,12],
                 "Social_Studies_Girls_%Pass" = data[3,12]
    )
    df <- df %>% mutate_all(na_if, "")
    return(df)
  }
}