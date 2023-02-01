
library(pdftools)
library(dplyr)
library(stringr)
library(writexl)
library(tabulizer)
library(strex)
library(scales)

get_SHS_Profile <- function(pdf_file){
  ##Get the Year information from the pdf file directories
  year <- pdf_file %>% str_after_nth("/", 2) %>% str_before_first("/")
  ##Get the page number
  page_num <- pdf_info(pdf_file)$pages
  
  print(paste("Extracting ", year, " SHS Profile data with ", page_num, " pages", sep = ""))
  
  ## Create empty dataframes to store the data
  public_enrolment_data <- tibble()
  enrolment_GES_data <- tibble()
  enrolment_private_data <- tibble()
  enrolment_total_data <- tibble()
  teacher_public_data <- tibble()
  teacher_GES_data <- tibble()
  teacher_private_data <- tibble()
  teacher_total_data <- tibble()
  repeaters_public_data <- tibble()
  repeaters_private_data <- tibble()
  repeaters_total_data <- tibble()
  enrolment_program_public_data <- tibble()
  enrolment_program_private_data <- tibble()
  enrolment_program_total_data <- tibble()
  
  for (i in 1:page_num) {
    temp_public_enrolment <- get_public_enrolment(pdf_file, page = i, year)
    public_enrolment_data <- rbind(public_enrolment_data, temp_public_enrolment )
    
    if(year %in% c("2017-2018", "2018-2019", "2019-2020")){
    temp_enrolment_GES <- get_enrolment_GES(pdf_file, page = i, year)
    enrolment_GES_data <- rbind(enrolment_GES_data, temp_enrolment_GES)
    }
    
    temp_enrolment_private <- get_enrolment_private(pdf_file, page = i, year)
    enrolment_private_data <- rbind(enrolment_private_data, temp_enrolment_private)
    
    if(year != "2012-2013"){
    temp_enrolment_total <- get_enrolment_total(pdf_file, page = i, year)
    enrolment_total_data <- rbind(enrolment_total_data, temp_enrolment_total)
    }
    
    temp_teacher_public <- get_teacher_public(pdf_file, page = i, year)
    teacher_public_data <- rbind(teacher_public_data, temp_teacher_public)
    
    if(year %in% c("2017-2018", "2018-2019", "2019-2020")){
    temp_teacher_GES <- get_teacher_GES(pdf_file, page = i, year)
    teacher_GES_data <- rbind(teacher_GES_data, temp_teacher_GES)
    }
    
    temp_teacher_private <- get_teacher_private(pdf_file, page = i, year)
    teacher_private_data <- rbind(teacher_private_data, temp_teacher_private)
    
    if(year != "2012-2013"){
    temp_teacher_total <- get_teacher_total(pdf_file, page = i, year)
    teacher_total_data <- rbind(teacher_total_data, temp_teacher_total)
    }
    
    temp_repeaters_public <- get_repeaters_public(pdf_file, page = i, year)
    repeaters_public_data <- rbind(repeaters_public_data, temp_repeaters_public)
    
    temp_repeaters_private <- get_repeaters_private(pdf_file, page = i, year)
    repeaters_private_data <- rbind(repeaters_private_data, temp_repeaters_private )
    
    if(year != "2012-2013"){
    temp_repeaters_total <- get_repeaters_total(pdf_file, page = i, year)
    repeaters_total_data <- rbind(repeaters_total_data, temp_repeaters_total)
    }
    
    temp_enrolment_program_public <- get_enrolment_program_public(pdf_file, page = i, year)
    enrolment_program_public_data <- rbind(enrolment_program_public_data, temp_enrolment_program_public)
    
    temp_enrolment_program_private <- get_enrolment_program_private(pdf_file, page = i, year)
    enrolment_program_private_data <- rbind(enrolment_program_private_data, temp_enrolment_program_private)
    
    if(year != "2012-2013"){
    temp_enrolment_program_total <- get_enrolment_program_total(pdf_file, page = i, year)
    enrolment_program_total_data <- rbind(enrolment_program_total_data, temp_enrolment_program_total)
    }
  }
  
  ## Create an Excel Sheet
  sheets <- list("Enrolment Public" = public_enrolment_data,
                 "Enrolment GES (TVET)" = enrolment_GES_data, 
                 "Enrolment Private" = enrolment_private_data, 
                 "Enrolment Total" = enrolment_total_data,
                 "Teachers Public (SHS)" =  teacher_public_data, 
                 "Teachers GES (TVET)" = teacher_GES_data, 
                 "Teachers Private (SHS)" = teacher_private_data, 
                 "Teachers Total" = teacher_total_data,
                 "Repeaters Public" = repeaters_public_data, 
                 "Repeaters Private" = repeaters_private_data, 
                 "Repeaters Total" = repeaters_total_data,
                 "Repeaters by Programs Public" = enrolment_program_public_data, 
                 "Repeaters by Programs Private" = enrolment_program_private_data,
                 "Repeaters by Programs Total" = enrolment_program_total_data)
  
  ## Set up the name of the excel file
  file_name <- paste(paste(year, "SHS District Profile.xlsx"))
  ## Write the excel files
  write_xlsx(sheets, file_name)
  print(paste("Succesfully Written ", file_name, sep = ""))
}

get_area_year<- function(pdf_file, page = NULL, year = "2013-2020"){
  
  ### Set the table location based on the documents year 
  if(year == "2012-2013"){
  info_location <- list(c(top = 20.4236007408225, left = 46.711792860397, bottom = 44.3783663102625, 
                  right = 804.880123133))
  } else{
  info_location <- list(c(top = 33.9390539525713, left = 22.70040530101, bottom = 51.5370819279813, 
                          right = 768.10259025934))
  }
  
  #### Extract the Year, District, Region
  info_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = info_location)
  
  ## Extract the Year, District, Region for 2 different kind of format
  
  if(length(info_data[[1]]) == 1 && year == "2012-2013"){
    district <- info_data[[1]][1] %>% substr(nchar(info_data[[1]][1]) - 47, nchar(info_data[[1]][1])) %>% str_extract("^(.+?),") %>%
      str_replace(",", "")
    
    region <- info_data[[1]][1] %>% substr(nchar(info_data[[1]][1]) - 51, nchar(info_data[[1]][1])) %>% str_extract("[^,]*$") %>% 
      trimws() %>% str_replace(" R[^,]*$", "")
    
    year <- info_data[[1]][1] %>% substr(1, 51) %>% str_extract("[^-]*$") %>% 
      str_replace(" School[^,]*$", "") %>%  str_replace(" / ", "/") %>%
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
      str_replace(" School Year Data", "") %>%  str_replace(" / ", "/") %>%
      trimws()
  }
  
  info_data <- list(year = year, district = district, region = region)
}

get_public_enrolment <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2013-2014", "2014-2015")){
    year_range_loc <- "2013-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {public_enrolment_loc <- list(c(top = 82.9621318840613, left = 39.041431278174, bottom = 148.326235792721, 
                                         right = 240.16175099712))
          },
          "2017-2018" = {public_enrolment_loc <- list(c(top = 85.4129115870713, left = 67.751596482074, bottom = 152.523056405491, 
                                                        right = 276.40313764478))
          },
          "2016-2017" = {public_enrolment_loc <- list(c(top = 81.9202275521012, left = 52.353971132752, bottom = 157.727005286871, 
                                                        right = 344.57687240068))
          },
          "2015-2016" = {public_enrolment_loc <- list(c(top = 91.6801844289437, left = 58.522667228808, bottom = 169.913941808304, 
                                                        right = 268.77589018585))
          },
          "2013-2015" = {public_enrolment_loc <- list(c(top = 85.75564681725, left = 42.589451470659, bottom = 170.30595482546, 
                                                        right = 276.83996481768))
          },
          "2012-2013" = {public_enrolment_loc <- list(c(top = 76.7172998290025, left = 68.271081872888, bottom = 148.581596537303, 
                                                        right = 392.85815533873))
          }
          )

  
  ######## Extract the Public enrolment Data in the pdf file
  public_enrolment_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = public_enrolment_loc)
  data <- public_enrolment_data[[1]][-1,-1]
  
  ######### Create a Dataframe from the extracted data
  df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
               "SH1_Total" = data[1,1], "SH1_Boys" = data[2, 1], 
               "SH1_Girls" = data[3, 1], "SH1_%Girls" = data[4,1],
               "SH2_Total" = data[1, 2], "SH2_Boys" = data[2,2], 
               "SH2_Girls" = data[3,2], "SH2_%Girls" = data[4,2],
               "SH3_Total" = data[1, 3], "SH3_Boys" = data[2,3], 
               "SH3_Girls" = data[3, 3], "SH3_%Girls" = data[4, 3],
               "Total_Total" = data[1,4], "Total_Boys" = data[2, 4],
               "Total_Girls" = data[3, 4], "Total_%Girls" = data[4, 4]
  )
  df <- df %>% mutate_all(na_if, "")
  
  ### Adjust the dataframe for different format in year 2012-2013
  if(year == "2012-2013"){
    df <- df %>% rename(`SH4_Total` = `Total_Total`,
                        `SH4_Boys` = `Total_Boys`,
                        `SH4_Girls` = `Total_Girls`,
                        `SH4_%Girls` = `Total_%Girls`)
    
    df <- df %>% cbind("Total_Total" = data[1,5], "Total_Boys" = data[2, 5],
                       "Total_Girls" = data[3, 5], "Total_%Girls" = data[4, 5])
  }
  return(df)
}

get_enrolment_GES <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year(pdf_file, page = page)
  
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 80.4481278875812, left = 259.01678097077, bottom = 148.326235792721, 
                                                        right = 417.39903274943))
          },
          "2017-2018" = {loc <- list(c(top = 81.7523582333413, left = 287.38479770598, bottom = 153.743240856731, 
                                       right = 454.5500675264))
          }
  )
  
  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc)
  data <- raw_data[[1]][-1,]
  
  ######### Create a Dataframe from the extracted data
  if(is_empty(data)){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "T1_Total" = NA, "T1_Boys" = NA, 
                 "T1_Girls" = NA, "T1_%Girls" = NA,
                 "T2_Total" = NA, "T2_Boys" = NA, 
                 "T2_Girls" = NA, "T2_%Girls" = NA,
                 "T3_Total" = NA, "T3_Boys" = NA, 
                 "T3_Girls" = NA, "T3_%Girls" = NA,
                 "Total_Total" = NA, "Total_Boys" = NA,
                 "Total_Girls" = NA, "Total_%Girls" = NA
    )
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "T1_Total" = data[1,1], "T1_Boys" = data[2, 1], 
                 "T1_Girls" = data[3, 1], "T1_%Girls" = data[4,1],
                 "T2_Total" = data[1, 2], "T2_Boys" = data[2,2], 
                 "T2_Girls" = data[3,2], "T2_%Girls" = data[4,2],
                 "T3_Total" = data[1, 3], "T3_Boys" = data[2,3], 
                 "T3_Girls" = data[3, 3], "T3_%Girls" = data[4, 3],
                 "Total_Total" = data[1,4], "Total_Boys" = data[2, 4],
                 "Total_Girls" = data[3, 4], "Total_%Girls" = data[4, 4]
    )
    df <- df %>% mutate_all(na_if, "")
  }
  
  
}

get_enrolment_private <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2013-2014", "2014-2015")){
    year_range_loc <- "2013-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 82.9621318840613, left = 434.99706072484, bottom = 158.326235792721, 
                                         right = 588.35130451054))
          },
          "2017-2018" = {loc <- list(c(top = 82.9725426845913, left = 463.0913586851, bottom = 153.743240856731, 
                                       right = 625.37589070054))
          },
          "2016-2017" = {loc <- list(c(top = 88.0336773694212, left = 377.58950141421, bottom = 156.504315323411, 
                                       right = 554.87954611651))
          },
          "2015-2016" = {loc <- list(c(top = 185.805173775984, left = 113.53077788617, bottom = 254.259711482934, 
                                       right = 269.9982926449))
          },
          "2013-2015" = {loc <- list(c(top = 85.75564681725, left = 292.589451470659, bottom = 170.30595482546, 
                                              right = 530.83996481768))
          },
          "2012-2013" = {loc <- list(c(top = 76.7172998290025, left = 470.71114343939, bottom = 148.581596537303, 
                                       right = 777.33214272815))
          }
  )
  
  
  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  
  ##### Tidy and clean the data based on several parameter (year range,  number of column, etc)
  if(year == "2012-2013"){
    data <- raw_data[-1, -1]
    if(ncol(data) == 8){
      data <- data[, -c(3,5,7)] 
      }
    }else{
    data <- raw_data[-1,] 
  }
  
  ######### Create a Dataframe from the extracted data
  
  if(is.vector(data) && year == "2012-2013"){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = NA, "SH1_Boys" = NA, 
                 "SH1_Girls" = NA, "SH1_%Girls" = NA,
                 "SH2_Total" = NA, "SH2_Boys" = NA, 
                 "SH2_Girls" = NA, "SH2_%Girls" = NA,
                 "SH3_Total" = NA, "SH3_Boys" = NA, 
                 "SH3_Girls" = NA, "SH3_%Girls" = NA,
                 "SH4_Total" = NA,"SH4_Boys" = NA,
                 "SH4_Girls" = NA,"SH4_%Girls" = NA,
                 "Total_Total" = NA, "Total_Boys" = NA,
                 "Total_Girls" = NA, "Total_%Girls" = NA
    )
    return(df)
    break
  }
  
  
  if(is_empty(data)){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = NA, "SH1_Boys" = NA, 
                 "SH1_Girls" = NA, "SH1_%Girls" = NA,
                 "SH2_Total" = NA, "SH2_Boys" = NA, 
                 "SH2_Girls" = NA, "SH2_%Girls" = NA,
                 "SH3_Total" = NA, "SH3_Boys" = NA, 
                 "SH3_Girls" = NA, "SH3_%Girls" = NA,
                 "Total_Total" = NA, "Total_Boys" = NA,
                 "Total_Girls" = NA, "Total_%Girls" = NA
    )
  } else if(nrow(data) < 4){
    print(paste("There may be some error in extracting Private Enrolment data from pages ", page, ". Please recheck the results", sep =""))
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = data[1,1], "SH1_Boys" = data[2, 1], 
                 "SH1_Girls" = NA, "SH1_%Girls" = data[3,1],
                 "SH2_Total" = data[1, 2], "SH2_Boys" = data[2,2], 
                 "SH2_Girls" = NA, "SH2_%Girls" = data[3,2],
                 "SH3_Total" = data[1, 3], "SH3_Boys" = data[2,3], 
                 "SH3_Girls" = NA, "SH3_%Girls" = data[3, 3],
                 "Total_Total" = data[1,4], "Total_Boys" = data[2, 4],
                 "Total_Girls" = NA, "Total_%Girls" = data[3, 4]
    )
    df <- df %>% mutate_all(na_if, "")
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = data[1,1], "SH1_Boys" = data[2, 1], 
                 "SH1_Girls" = data[3, 1], "SH1_%Girls" = data[4,1],
                 "SH2_Total" = data[1, 2], "SH2_Boys" = data[2,2], 
                 "SH2_Girls" = data[3,2], "SH2_%Girls" = data[4,2],
                 "SH3_Total" = data[1, 3], "SH3_Boys" = data[2,3], 
                 "SH3_Girls" = data[3, 3], "SH3_%Girls" = data[4, 3],
                 "Total_Total" = data[1,4], "Total_Boys" = data[2, 4],
                 "Total_Girls" = data[3, 4], "Total_%Girls" = data[4, 4]
    )
    df <- df %>% mutate_all(na_if, "")
  }
  
  ### Adjust the dataframe for different format in year 2012-2013
  if(year == "2012-2013"){
    df <- df %>% rename(`SH4_Total` = `Total_Total`,
                        `SH4_Boys` = `Total_Boys`,
                        `SH4_Girls` = `Total_Girls`,
                        `SH4_%Girls` = `Total_%Girls`)
    
    df <- df %>% cbind("Total_Total" = data[1,5], "Total_Boys" = data[2, 5],
                       "Total_Girls" = data[3, 5], "Total_%Girls" = data[4, 5])
    df <- df %>% mutate_all(na_if, "")
  }
  return(df)
}

get_enrolment_total <- function(pdf_file, page = NULL, year){
  info_data <- get_area_year(pdf_file, page = page)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2013-2014", "2014-2015")){
    year_range_loc <- "2013-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 81.7051298858213, left = 610.97734047892, bottom = 157.125249780421, 
                                         right = 765.58858626285))
          },
          "2017-2018" = {loc <- list(c(top = 84.1927271358313, left = 642.45847301796, bottom = 152.523056405491, 
                                       right = 803.52282058216))
          },
          "2016-2017" = {loc <- list(c(top = 86.8109874059513, left = 609.9005944724, bottom = 154.058935396481, 
                                       right = 771.29566964966))
          },
          "2015-2016" = {loc <- list(c(top = 275.040553286824, left = 115.97558280428, bottom = 352.051908207134, 
                                       right = 266.33108526774))
          },
          "2013-2015" = {loc <- list(c(top = 85.75564681725, left = 492.589451470659, bottom = 170.30595482546, 
                                              right = 730.83996481768))
          }
  )
  
  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  data <- raw_data[-1,]
  
  ######### Create a Dataframe from the extracted data
  if(is_empty(data)){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = NA, "SH1_Boys" = NA, 
                 "SH1_Girls" = NA, "SH1_%Girls" = NA,
                 "SH2_Total" = NA, "SH2_Boys" = NA, 
                 "SH2_Girls" = NA, "SH2_%Girls" = NA,
                 "SH3_Total" = NA, "SH3_Boys" = NA, 
                 "SH3_Girls" = NA, "SH3_%Girls" = NA,
                 "Total_Total" = NA, "Total_Boys" = NA,
                 "Total_Girls" = NA, "Total_%Girls" = NA
    )
  } else if(nrow(data) < 4){
    print(paste("There may be some error in extracting Total Enrolment data from pages ", page, ". Please recheck the results", sep =""))
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = data[1,1], "SH1_Boys" = data[2, 1], 
                 "SH1_Girls" = NA, "SH1_%Girls" = data[3,1],
                 "SH2_Total" = data[1, 2], "SH2_Boys" = data[2,2], 
                 "SH2_Girls" = NA, "SH2_%Girls" = data[3,2],
                 "SH3_Total" = data[1, 3], "SH3_Boys" = data[2,3], 
                 "SH3_Girls" = NA, "SH3_%Girls" = data[3, 3],
                 "Total_Total" = data[1,4], "Total_Boys" = data[2, 4],
                 "Total_Girls" = NA, "Total_%Girls" = data[3, 4]
    )
    df <- df %>% mutate_all(na_if, "")
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = data[1,1], "SH1_Boys" = data[2, 1], 
                 "SH1_Girls" = data[3, 1], "SH1_%Girls" = data[4,1],
                 "SH2_Total" = data[1, 2], "SH2_Boys" = data[2,2], 
                 "SH2_Girls" = data[3,2], "SH2_%Girls" = data[4,2],
                 "SH3_Total" = data[1, 3], "SH3_Boys" = data[2,3], 
                 "SH3_Girls" = data[3, 3], "SH3_%Girls" = data[4, 3],
                 "Total_Total" = data[1,4], "Total_Boys" = data[2, 4],
                 "Total_Girls" = data[3, 4], "Total_%Girls" = data[4, 4]
    )
    df <- df %>% mutate_all(na_if, "")
    return(df)
  }
}

get_teacher_public <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2013-2014", "2014-2015")){
    year_range_loc <- "2013-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 183.522291743531, left = 27.728413293984, bottom = 255.171405643411, 
                                         right = 238.90474899887))
          
          },
          "2017-2018" = {loc <- list(c(top = 189.516944336941, left = 60.912800877001, bottom = 260.432962217861, 
                                       right = 273.66085451976))
          },
          "2016-2017" = {loc <- list(c(top = 302.004420975641, left = 56.022041023145, bottom = 374.143128820021, 
                                       right = 349.46763225454))
          },
          "2015-2016" = {loc <- list(c(top = 83.1233672155737, left = 574.37650494899, bottom = 161.357124594934, 
                                       right = 791.96414266034))
          },
          "2013-2015" = {loc <- list(c(top = 295.75564681725, left = 72.589451470659, bottom = 370.30595482546, 
                                       right = 306.83996481768))
          },
          "2012-2013" = {loc <- list(c(top = 289.914713396962, left = 83.841679493021, bottom = 370.163178054573, 
                                       right = 380.88077255401))
          }
  )
  

  ######## Extract the Public enrolment Data in the pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  data <- raw_data[-1, -1]
  
  ######### Create a Dataframe from the extracted data
  if(is_empty(data)){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Male_Total" = NA, "Male_Trained" = NA, 
                 "Male_Untrained" = NA, "Male_%Trained" = NA,
                 "Female_Total" = NA, "Female_Trained" = NA, 
                 "Female_Untrained" = NA, "Female_%Trained" = NA,
                 "Total_Total" = NA, "Total_Trained" = NA, 
                 "Total_Untrained" = NA, "Total_%Trained" = NA,
                 "%Female_Total" = NA, "%Female_Trained" = NA,
                 "%Female_Untrained" = NA, "%Female_%Trained" = NA
    )
  } else if(nrow(data) < 4){
    print(paste("There may be some error in extracting Teacher Public data from pages ", page, ". Please recheck the results", sep =""))
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Male_Total" = data[1,1], "Male_Trained" = data[2, 1], 
                 "Male_Untrained" = NA, "Male_%Trained" = data[3,1],
                 "Female_Total" = data[1, 2], "Female_Trained" = data[2,2], 
                 "Female_Untrained" = NA, "Female_%Trained" = data[3,2],
                 "Total_Total" = data[1, 3], "Total_Trained" = data[2,3], 
                 "Total_Untrained" = NA, "Total_%Trained" = data[3, 3],
                 "%Female_Total" = data[1,4], "%Female_Trained" = data[2, 4],
                 "%Female_Untrained" = NA, "%Female_%Trained" = data[3, 4]
    )
    df <- df %>% mutate_all(na_if, "")
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Male_Total" = data[1,1], "Male_Trained" = data[2, 1], 
                 "Male_Untrained" = data[3, 1], "Male_%Trained" = data[4,1],
                 "Female_Total" = data[1, 2], "Female_Trained" = data[2,2], 
                 "Female_Untrained" = data[3,2], "Female_%Trained" = data[4,2],
                 "Total_Total" = data[1, 3], "Total_Trained" = data[2,3], 
                 "Total_Untrained" = data[3, 3], "Total_%Trained" = data[4, 3],
                 "%Female_Total" = data[1,4], "%Female_Trained" = data[2, 4],
                 "%Female_Untrained" = data[3, 4], "%Female_%Trained" = data[4, 4]
    )
    df <- df %>% mutate_all(na_if, "")
    return(df)
  }
}

get_teacher_GES <- function(pdf_file, page = NULL, year){
  info_data <- get_area_year(pdf_file, page = page)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 181.008287747051, left = 252.73177097955, bottom = 262.713417632871, 
                                         right = 418.65603474768))
          
          },
          "2017-2018" = {loc <- list(c(top = 189.516944336941, left = 284.66506419094, bottom = 259.210272254391, 
                                       right = 453.39627914899))
          }
  )
  
  ######## Extract the Public enrolment Data in the pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  data <- raw_data[-1,]
  
  ######### Create a Dataframe from the extracted data
  if(is_empty(data)){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Male_Total" = NA, "Male_Trained" = NA, 
                 "Male_Untrained" = NA, "Male_%Trained" = NA,
                 "Female_Total" = NA, "Female_Trained" = NA, 
                 "Female_Untrained" = NA, "Female_%Trained" = NA,
                 "Total_Total" = NA, "Total_Trained" = NA, 
                 "Total_Untrained" = NA, "Total_%Trained" = NA,
                 "%Female_Total" = NA, "%Female_Trained" = NA,
                 "%Female_Untrained" = NA, "%Female_%Trained" = NA
    )
  } else if(nrow(data) < 4){
    print(paste("There may be some error in extracting Teacher GES data from pages ", page, ". Please recheck the results", sep =""))
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Male_Total" = data[1,1], "Male_Trained" = data[2, 1], 
                 "Male_Untrained" = NA, "Male_%Trained" = data[3,1],
                 "Female_Total" = data[1, 2], "Female_Trained" = data[2,2], 
                 "Female_Untrained" = NA, "Female_%Trained" = data[3,2],
                 "Total_Total" = data[1, 3], "Total_Trained" = data[2,3], 
                 "Total_Untrained" = NA, "Total_%Trained" = data[3, 3],
                 "%Female_Total" = data[1,4], "%Female_Trained" = data[2, 4],
                 "%Female_Untrained" = NA, "%Female_%Trained" = data[3, 4]
    )
    df <- df %>% mutate_all(na_if, "")
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Male_Total" = data[1,1], "Male_Trained" = data[2, 1], 
                 "Male_Untrained" = data[3, 1], "Male_%Trained" = data[4,1],
                 "Female_Total" = data[1, 2], "Female_Trained" = data[2,2], 
                 "Female_Untrained" = data[3,2], "Female_%Trained" = data[4,2],
                 "Total_Total" = data[1, 3], "Total_Trained" = data[2,3], 
                 "Total_Untrained" = data[3, 3], "Total_%Trained" = data[4, 3],
                 "%Female_Total" = data[1,4], "%Female_Trained" = data[2, 4],
                 "%Female_Untrained" = data[3, 4], "%Female_%Trained" = data[4, 4]
    )
    df <- df %>% mutate_all(na_if, "")
    return(df)
  }
}

get_teacher_private <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2013-2014", "2014-2015")){
    year_range_loc <- "2013-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 184.779293741781, left = 431.22605473011, bottom = 255.171405643411, 
                                         right = 592.12231050527))
          },
          "2017-2018" = {loc <- list(c(top = 187.071564410011, left = 461.95510889324, bottom = 257.987582290931, 
                                       right = 630.68632385129))
          },
          "2016-2017" = {loc <- list(c(top = 303.227110939101, left = 383.70295123153, bottom = 374.143128820021, 
                                       right = 575.6652754954))
          },
          "2015-2016" = {loc <- list(c(top = 184.582771316934, left = 631.82942052446, bottom = 254.259711482934, 
                                       right = 794.40894757845))
          },
          "2013-2015" = {loc <- list(c(top = 295.75564681725, left = 292.589451470659, bottom = 370.30595482546, 
                                       right = 536.83996481768))
          },
          "2012-2013" = {loc <- list(c(top = 291.112451675433, left = 459.93149893314, bottom = 366.569963219152, 
                                       right = 767.75023650038))
          }
  )
  
  ######## Extract the Public enrolment Data in the pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  
  ##### Tidy and clean the data based on several parameter (year,  number of column, etc)
  if(year == "2012-2013"){
    data <- raw_data[-1, -1]
    if(ncol(data) == 8){
      data <- data[, -c(3,5,7)] 
    }
  }else{
    data <- raw_data[-1,] 
  }
  
  ######### Create a Dataframe from the extracted data
  if(is.vector(data) && year == "2012-2013"){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = NA, "SH1_Boys" = NA, 
                 "SH1_Girls" = NA, "SH1_%Girls" = NA,
                 "SH2_Total" = NA, "SH2_Boys" = NA, 
                 "SH2_Girls" = NA, "SH2_%Girls" = NA,
                 "SH3_Total" = NA, "SH3_Boys" = NA, 
                 "SH3_Girls" = NA, "SH3_%Girls" = NA,
                 "SH4_Total" = NA,"SH4_Boys" = NA,
                 "SH4_Girls" = NA,"SH4_%Girls" = NA,
                 "Total_Total" = NA, "Total_Boys" = NA,
                 "Total_Girls" = NA, "Total_%Girls" = NA
    )
    return(df)
    break
  }
  
  if(is_empty(data)){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Male_Total" = NA, "Male_Trained" = NA, 
                 "Male_Untrained" = NA, "Male_%Trained" = NA,
                 "Female_Total" = NA, "Female_Trained" = NA, 
                 "Female_Untrained" = NA, "Female_%Trained" = NA,
                 "Total_Total" = NA, "Total_Trained" = NA, 
                 "Total_Untrained" = NA, "Total_%Trained" = NA,
                 "%Female_Total" = NA, "%Female_Trained" = NA,
                 "%Female_Untrained" = NA, "%Female_%Trained" = NA
    )
  } else if(nrow(data) < 4){
    print(paste("There may be some error in extracting Teacher Private data from pages ", page, ". Please recheck the results", sep =""))
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Male_Total" = data[1,1], "Male_Trained" = data[2, 1], 
                 "Male_Untrained" = NA, "Male_%Trained" = data[3,1],
                 "Female_Total" = data[1, 2], "Female_Trained" = data[2,2], 
                 "Female_Untrained" = NA, "Female_%Trained" = data[3,2],
                 "Total_Total" = data[1, 3], "Total_Trained" = data[2,3], 
                 "Total_Untrained" = NA, "Total_%Trained" = data[3, 3],
                 "%Female_Total" = data[1,4], "%Female_Trained" = data[2, 4],
                 "%Female_Untrained" = NA, "%Female_%Trained" = data[3, 4]
    )
    df <- df %>% mutate_all(na_if, "")
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Male_Total" = data[1,1], "Male_Trained" = data[2, 1], 
                 "Male_Untrained" = data[3, 1], "Male_%Trained" = data[4,1],
                 "Female_Total" = data[1, 2], "Female_Trained" = data[2,2], 
                 "Female_Untrained" = data[3,2], "Female_%Trained" = data[4,2],
                 "Total_Total" = data[1, 3], "Total_Trained" = data[2,3], 
                 "Total_Untrained" = data[3, 3], "Total_%Trained" = data[4, 3],
                 "%Female_Total" = data[1,4], "%Female_Trained" = data[2, 4],
                 "%Female_Untrained" = data[3, 4], "%Female_%Trained" = data[4, 4]
    )
    df <- df %>% mutate_all(na_if, "")
    return(df)
  }
}

get_teacher_total <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year(pdf_file, page = page)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2013-2014", "2014-2015")){
    year_range_loc <- "2013-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 186.036295740021, left = 605.94933248594, bottom = 253.914403645161, 
                                         right = 778.15860624529))
          },
          "2017-2018" = {loc <- list(c(top = 185.848874446551, left = 638.02246363207, bottom = 257.987582290931, 
                                       right = 803.08560869973))
          },
          "2016-2017" = {loc <- list(c(top = 297.113661121781, left = 602.56445469161, bottom = 374.143128820021, 
                                       right = 793.30408899201))
          },
          "2015-2016" = {loc <- list(c(top = 292.154187713564, left = 630.6070180654, bottom = 361.831127879554, 
                                       right = 794.40894757845))
          },
          "2013-2015" = {loc <- list(c(top = 295.75564681725, left = 532.589451470659, bottom = 370.30595482546, 
                                       right = 796.83996481768))
          }
  )

  ######## Extract the Public enrolment Data in the pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  data <- raw_data[-1,]
  
  ##### Tidy and clean the data based on several parameter (year range,  number of column, etc)
  if(ncol(data) == 5){
    data <- data[,-3]
  }
  
  if(ncol(data) == 6){
    data <- data[,-c(3,5)]
  }
  
  ######### Create a Dataframe from the extracted data
  if(is_empty(data)){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Male_Total" = NA, "Male_Trained" = NA, 
                 "Male_Untrained" = NA, "Male_%Trained" = NA,
                 "Female_Total" = NA, "Female_Trained" = NA, 
                 "Female_Untrained" = NA, "Female_%Trained" = NA,
                 "Total_Total" = NA, "Total_Trained" = NA, 
                 "Total_Untrained" = NA, "Total_%Trained" = NA,
                 "%Female_Total" = NA, "%Female_Trained" = NA,
                 "%Female_Untrained" = NA, "%Female_%Trained" = NA
    )
  } else if(nrow(data) < 4){
    print(paste("There may be some error in extracting Teacher Total data from pages ", page, ". Please recheck the results", sep =""))
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Male_Total" = data[1,1], "Male_Trained" = data[2, 1], 
                 "Male_Untrained" = NA, "Male_%Trained" = data[3,1],
                 "Female_Total" = data[1, 2], "Female_Trained" = data[2,2], 
                 "Female_Untrained" = NA, "Female_%Trained" = data[3,2],
                 "Total_Total" = data[1, 3], "Total_Trained" = data[2,3], 
                 "Total_Untrained" = NA, "Total_%Trained" = data[3, 3],
                 "%Female_Total" = data[1,4], "%Female_Trained" = data[2, 4],
                 "%Female_Untrained" = NA, "%Female_%Trained" = data[3, 4]
    )
    df <- df %>% mutate_all(na_if, "")
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Male_Total" = data[1,1], "Male_Trained" = data[2, 1], 
                 "Male_Untrained" = data[3, 1], "Male_%Trained" = data[4,1],
                 "Female_Total" = data[1, 2], "Female_Trained" = data[2,2], 
                 "Female_Untrained" = data[3,2], "Female_%Trained" = data[4,2],
                 "Total_Total" = data[1, 3], "Total_Trained" = data[2,3], 
                 "Total_Untrained" = data[3, 3], "Total_%Trained" = data[4, 3],
                 "%Female_Total" = data[1,4], "%Female_Trained" = data[2, 4],
                 "%Female_Untrained" = data[3, 4], "%Female_%Trained" = data[4, 4]
    )
    df <- df %>% mutate_all(na_if, "")
    return(df)
  }
}

get_repeaters_public <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2013-2014", "2014-2015")){
    year_range_loc <- "2013-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 285.339453601251, left = 134.57358314467, bottom = 355.731565502881, 
                                         right = 308.03985890226))
          },
          "2017-2018" = {loc <- list(c(top = 291.000211304461, left = 173.4002775157, bottom = 358.248159294991, 
                                       right = 338.46342258336))
          },
          "2016-2017" = {loc <- list(c(top = 190.739634300401, left = 152.61454813681, bottom = 265.323722071721, 
                                       right = 344.57687240068))
          },
          "2015-2016" = {loc <- list(c(top = 84.3457696746237, left = 369.01289182816, bottom = 155.245112299674, 
                                       right = 524.25800412783))
          },
          "2013-2015" = {loc <- list(c(top = 185.75564681725, left = 120.589451470659, bottom = 270.30595482546, 
                                       right = 306.83996481768))
          },
          "2012-2013" = {loc <- list(c(top = 182.118268334512, left = 76.655249822191, bottom = 255.180303321283, 
                                       right = 386.86946394637))
          }
  )
  
  ######## Extract the Public enrolment Data in the pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  
  ##### Tidy and clean the data based on several parameter (year range,  number of column, etc)
  if(year == "2012-2013"){
    data <- raw_data[-1, -1]
    if(ncol(data) == 8){
      data <- data[, -c(3,5,7)] 
    }
  }else{
    data <- raw_data[-1,] 
  }
  
  ######### Create a Dataframe from the extracted data
  
  if(is.vector(data) && year == "2012-2013"){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = 0, "SH1_Boys" = 0, 
                 "SH1_Girls" = 0, "SH1_%Girls" = "0.0%",
                 "SH2_Total" = 0, "SH2_Boys" = 0, 
                 "SH2_Girls" = 0, "SH2_%Girls" = "0.0%",
                 "SH3_Total" = 0, "SH3_Boys" = 0, 
                 "SH3_Girls" = 0, "SH3_%Girls" = "0.0%",
                 "SH4_Total" = 0,"SH4_Boys" = 0,
                 "SH4_Girls" = 0,"SH4_%Girls" = "0.0%",
                 "Total_Total" = 0, "Total_Boys" = 0,
                 "Total_Girls" = 0, "Total_%Girls" = "0.0%"
    )
    return(df)
    break
  }
  
  if(is_empty(data) || is.null(nrow(data))){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = NA, "SH1_Boys" = NA, 
                 "SH1_Girls" = NA, "SH1_%Girls" = NA,
                 "SH2_Total" = NA, "SH2_Boys" = NA, 
                 "SH2_Girls" = NA, "SH2_%Girls" = NA,
                 "SH3_Total" = NA, "SH3_Boys" = NA, 
                 "SH3_Girls" = NA, "SH3_%Girls" = NA,
                 "Total_Total" = NA, "Total_Boys" = NA,
                 "Total_Girls" = NA, "Total_%Girls" = NA
    )
  } else if(nrow(data) < 4){
    print(paste("There may be some error in extracting Repeaters Public data from pages ", page, ". Please recheck the results", sep =""))
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = data[1,1], "SH1_Boys" = NA, 
                 "SH1_Girls" = NA, "SH1_%Girls" = data[3,1],
                 "SH2_Total" = data[1, 2], "SH2_Boys" = NA, 
                 "SH2_Girls" = NA, "SH2_%Girls" = data[3,2],
                 "SH3_Total" = data[1, 3], "SH3_Boys" = NA, 
                 "SH3_Girls" = NA, "SH3_%Girls" = data[3, 3],
                 "Total_Total" = data[1,4], "Total_Boys" = NA,
                 "Total_Girls" = NA, "Total_%Girls" = data[3, 4]
    )
    df <- df %>% mutate_all(na_if, "")
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = data[1,1], "SH1_Boys" = data[2, 1], 
                 "SH1_Girls" = data[3, 1], "SH1_%Girls" = data[4,1],
                 "SH2_Total" = data[1, 2], "SH2_Boys" = data[2,2], 
                 "SH2_Girls" = data[3,2], "SH2_%Girls" = data[4,2],
                 "SH3_Total" = data[1, 3], "SH3_Boys" = data[2,3], 
                 "SH3_Girls" = data[3, 3], "SH3_%Girls" = data[4, 3],
                 "Total_Total" = data[1,4], "Total_Boys" = data[2, 4],
                 "Total_Girls" = data[3, 4], "Total_%Girls" = data[4, 4]
    )
    df <- df %>% mutate_all(na_if, "")
  }
  
  if(year == "2012-2013" && ncol(df) != 23){
    df <- df %>% rename(`SH4_Total` = `Total_Total`,
                        `SH4_Boys` = `Total_Boys`,
                        `SH4_Girls` = `Total_Girls`,
                        `SH4_%Girls` = `Total_%Girls`)
    df <- df %>% cbind("Total_Total" = data[1,5], "Total_Boys" = data[2, 5],
                       "Total_Girls" = data[3, 5], "Total_%Girls" = data[4, 5])
    df <- df %>% mutate_all(na_if, "")
  }
  return(df)
}

get_repeaters_private <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2013-2014", "2014-2015")){
    year_range_loc <- "2013-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 285.339453601251, left = 353.29193083902, bottom = 354.474563504641, 
                                         right = 529.2722105931))
          },
          "2017-2018" = {loc <- list(c(top = 291.000211304461, left = 397.15254082964, bottom = 360.693539221921, 
                                       right = 560.99299593383))
          },
          "2016-2017" = {loc <- list(c(top = 189.516944336941, left = 393.48447093924, bottom = 259.210272254391, 
                                       right = 559.77030597037))
          },
          "2015-2016" = {loc <- list(c(top = 166.246734431144, left = 375.12490412342, bottom = 244.480491810514, 
                                       right = 523.03560166878))
          },
          "2013-2015" = {loc <- list(c(top = 185.75564681725, left = 332.589451470659, bottom = 270.30595482546, 
                                       right = 526.83996481768))
          },
          "2012-2013" = {loc <- list(c(top = 182.118268334512, left = 473.10661999633, bottom = 253.982565042812, 
                                       right = 786.91404895593))
          }
  )
  
  ######## Extract the Public enrolment Data in the pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  
  if(year == "2012-2013"){
    data <- raw_data[-1, -1]
    if(ncol(data) == 8){
      data <- data[, -c(3,5,7)] 
    }
  }else{
    data <- raw_data[-1,] 
  }
  
  ######### Create a Dataframe from the extracted data
  if(is.vector(data) && year == "2012-2013"){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = 0, "SH1_Boys" = 0, 
                 "SH1_Girls" = 0, "SH1_%Girls" = "0.0%",
                 "SH2_Total" = 0, "SH2_Boys" = 0, 
                 "SH2_Girls" = 0, "SH2_%Girls" = "0.0%",
                 "SH3_Total" = 0, "SH3_Boys" = 0, 
                 "SH3_Girls" = 0, "SH3_%Girls" = "0.0%",
                 "SH4_Total" = 0,"SH4_Boys" = 0,
                 "SH4_Girls" = 0,"SH4_%Girls" = "0.0%",
                 "Total_Total" = 0, "Total_Boys" = 0,
                 "Total_Girls" = 0, "Total_%Girls" = "0.0%"
    )
    return(df)
    break
  }
  
  if(is_empty(data) || is.null(nrow(data))){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = NA, "SH1_Boys" = NA, 
                 "SH1_Girls" = NA, "SH1_%Girls" = NA,
                 "SH2_Total" = NA, "SH2_Boys" = NA, 
                 "SH2_Girls" = NA, "SH2_%Girls" = NA,
                 "SH3_Total" = NA, "SH3_Boys" = NA, 
                 "SH3_Girls" = NA, "SH3_%Girls" = NA,
                 "Total_Total" = NA, "Total_Boys" = NA,
                 "Total_Girls" = NA, "Total_%Girls" = NA
    )
  } else if(nrow(data) < 4){
    print(paste("There may be some error in extracting Repeaters Private data from pages ", page, ". Please recheck the results", sep =""))
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = data[1,1], "SH1_Boys" = NA, 
                 "SH1_Girls" = NA, "SH1_%Girls" = data[nrow(data),1],
                 "SH2_Total" = data[1, 2], "SH2_Boys" = NA, 
                 "SH2_Girls" = NA, "SH2_%Girls" = data[nrow(data),2],
                 "SH3_Total" = data[1, 3], "SH3_Boys" = NA, 
                 "SH3_Girls" = NA, "SH3_%Girls" = data[nrow(data), 3],
                 "Total_Total" = data[1,4], "Total_Boys" = NA,
                 "Total_Girls" = NA, "Total_%Girls" = data[nrow(data), 4]
    )
    df <- df %>% mutate_all(na_if, "")
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = data[1,1], "SH1_Boys" = data[2, 1], 
                 "SH1_Girls" = data[3, 1], "SH1_%Girls" = data[4,1],
                 "SH2_Total" = data[1, 2], "SH2_Boys" = data[2,2], 
                 "SH2_Girls" = data[3,2], "SH2_%Girls" = data[4,2],
                 "SH3_Total" = data[1, 3], "SH3_Boys" = data[2,3], 
                 "SH3_Girls" = data[3, 3], "SH3_%Girls" = data[4, 3],
                 "Total_Total" = data[1,4], "Total_Boys" = data[2, 4],
                 "Total_Girls" = data[3, 4], "Total_%Girls" = data[4, 4]
    )
    df <- df %>% mutate_all(na_if, "")
  }
  
  if(year == "2012-2013" && ncol(df) != 23){
    df <- df %>% rename(`SH4_Total` = `Total_Total`,
                        `SH4_Boys` = `Total_Boys`,
                        `SH4_Girls` = `Total_Girls`,
                        `SH4_%Girls` = `Total_%Girls`)
    df <- df %>% cbind("Total_Total" = data[1,5], "Total_Boys" = data[2, 5],
                       "Total_Girls" = data[3, 5], "Total_%Girls" = data[4, 5])
    df <- df %>% mutate_all(na_if, "")
  }
  return(df)
}

get_repeaters_total <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year(pdf_file, page = page)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2013-2014", "2014-2015")){
    year_range_loc <- "2013-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 285.339453601251, left = 564.46826654391, bottom = 358.245569499371, 
                                         right = 747.99055828745))
          
          },
          "2017-2018" = {loc <- list(c(top = 288.554831377531, left = 616.01404428972, bottom = 360.693539221921, 
                                       right = 782.29987932084))
          },
          "2016-2017" = {loc <- list(c(top = 188.294254373471, left = 602.56445469161, bottom = 262.878342144791, 
                                       right = 782.29987932084))
          },
          "2015-2016" = {loc <- list(c(top = 283.597370500194, left = 373.90250166437, bottom = 356.941518043344, 
                                       right = 525.48040658688))
          },
          "2013-2015" = {loc <- list(c(top = 185.75564681725, left = 600.589451470659, bottom = 270.30595482546, 
                                       right = 806.83996481768))
          }
  )
  
  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  data <- raw_data[-1,]
  
  ######### Create a Dataframe from the extracted data
  if(is_empty(data) || is.null(nrow(data))){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = NA, "SH1_Boys" = NA, 
                 "SH1_Girls" = NA, "SH1_%Girls" = NA,
                 "SH2_Total" = NA, "SH2_Boys" = NA, 
                 "SH2_Girls" = NA, "SH2_%Girls" = NA,
                 "SH3_Total" = NA, "SH3_Boys" = NA, 
                 "SH3_Girls" = NA, "SH3_%Girls" = NA,
                 "Total_Total" = NA, "Total_Boys" = NA,
                 "Total_Girls" = NA, "Total_%Girls" = NA
    )
  } else if(nrow(data) < 4){
    print(paste("There may be some error in extracting Repeaters Total data from pages ", page, ". Please recheck the results", sep =""))
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = data[1,1], "SH1_Boys" = NA, 
                 "SH1_Girls" = NA, "SH1_%Girls" = data[nrow(data),1],
                 "SH2_Total" = data[1, 2], "SH2_Boys" = NA, 
                 "SH2_Girls" = NA, "SH2_%Girls" = data[nrow(data),2],
                 "SH3_Total" = data[1, 3], "SH3_Boys" = NA, 
                 "SH3_Girls" = NA, "SH3_%Girls" = data[nrow(data), 3],
                 "Total_Total" = data[1,4], "Total_Boys" = NA,
                 "Total_Girls" = NA, "Total_%Girls" = data[nrow(data), 4]
    )
    df <- df %>% mutate_all(na_if, "")
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "SH1_Total" = data[1,1], "SH1_Boys" = data[2, 1], 
                 "SH1_Girls" = data[3, 1], "SH1_%Girls" = data[4,1],
                 "SH2_Total" = data[1, 2], "SH2_Boys" = data[2,2], 
                 "SH2_Girls" = data[3,2], "SH2_%Girls" = data[4,2],
                 "SH3_Total" = data[1, 3], "SH3_Boys" = data[2,3], 
                 "SH3_Girls" = data[3, 3], "SH3_%Girls" = data[4, 3],
                 "Total_Total" = data[1,4], "Total_Boys" = data[2, 4],
                 "Total_Girls" = data[3, 4], "Total_%Girls" = data[4, 4]
    )
    df <- df %>% mutate_all(na_if, "")
    return(df)
  }
}

get_enrolment_program_public <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2013-2014", "2014-2015")){
    year_range_loc <- "2013-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 395.955629446671, left = 23.957407299253, bottom = 530.454843258711, 
                                         right = 303.01185090929))
          
          },
          "2017-2018" = {loc <- list(c(top = 399.819618052771, left = 62.135490840465, bottom = 539.206273887681, 
                                       right = 333.5726627295))
          },
          "2016-2017" = {loc <- list(c(top = 412.046517687411, left = 58.467420950073, bottom = 548.987793595394, 
                                       right = 331.12728280257))
          },
          "2015-2016" = {loc <- list(c(top = 407.060018864504, left = 54.855459851651, bottom = 539.079484442176, 
                                       right = 327.45120822037))
          },
          "2013-2015" = {loc <- list(c(top = 410.75564681725, left = 42.589451470659, bottom = 550.30595482546, 
                                       right = 356.83996481768))
          },
          "2012-2013" = {loc <- list(c(top = 412.084017801082, left = 81.446202936077, bottom = 536.648798762141, 
                                       right = 412.02196779427))
          }
  )
  
  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  data <- raw_data[-1, -1]
  
  ##### Tidy and clean the data based on several parameter (year range,  number of column, etc)
  if(nrow(data) == 8 && year_range_loc == "2013-2015"){
    (data <- rbind(data, c(rep(NA, 4))))
    data[9,1] <- sum(as.numeric(sub(",", "", data[,1], fixed = TRUE)), na.rm = T)
    data[9,2] <- sum(as.numeric(sub(",", "", data[,2], fixed = TRUE)), na.rm = T)
    data[9,3] <- sum(as.numeric(sub(",", "", data[,3], fixed = TRUE)), na.rm = T)
    
    percent_girls <- as.numeric(data[9,2])/as.numeric(data[9,3]) %>% as.numeric()
    data[9,4] <- label_percent()(percent_girls)
  }
  
  if(nrow(data) == 8 && (year == "2012-2013")){
    (data <- rbind(data, c(rep(NA, 4))))
  }
  
  ######### Create a Dataframe from the extracted data
  if(is_empty(data) || is.null(nrow(data))){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Boys_Agriculture" = NA, "Boys_Business_Accounting" = NA, 
                 "Boys_Secretarial" = NA, "Boys_General_Science" = NA, 
                 "Boys_Arts" = NA, "Boys_Technicals" = NA,
                 "Boys_Vocational_HEcons" = NA, "Boys_Vis_Arts" = NA,
                 "Boys_Total" = NA,
                 
                 "Girls_Agriculture" = NA, "Girls_Business_Accounting" = NA, 
                 "Girls_Secretarial" = NA, "Girls_General_Science" = NA, 
                 "Girls_Arts" = NA, "Girls_Technicals" = NA,
                 "Girls_Vocational_HEcons" = NA, "Girls_Vis_Arts" = NA,
                 "Girls_Total" = NA,
                 
                 "Total_Agriculture" = NA, "Total_Business_Accounting" = NA, 
                 "Total_Secretarial" = NA, "Total_General_Science" = NA, 
                 "Total_Arts" = NA, "Total_Technicals" = NA,
                 "Total_Vocational_HEcons" = NA, "Total_Vis_Arts" = NA,
                 "Total_Total" = NA,
                 
                 "%Girls_Agriculture" = NA, "%Girls_Business_Accounting" = NA, 
                 "%Girls_Secretarial" = NA, "%Girls_General_Science" = NA, 
                 "%Girls_Arts" = NA, "%Girls_Technicals" = NA,
                 "%Girls_Vocational_HEcons" = NA, "%Girls_Vis_Arts" = NA,
                 "%Girls_Total" = NA
    )
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Boys_Agriculture" = data[1,1], "Boys_Business_Accounting" = data[2, 1], 
                 "Boys_Secretarial" = data[3,1], "Boys_General_Science" = data[4, 1], 
                 "Boys_Arts" = data[5, 1], "Boys_Technicals" = data[6,1],
                 "Boys_Vocational_HEcons" = data[7, 1], "Boys_Vis_Arts" = data[8,1],
                 "Boys_Total" = data[9, 1],
                 
                 "Girls_Agriculture" = data[1,2], "Girls_Business_Accounting" = data[2,2], 
                 "Girls_Secretarial" = data[3,2], "Girls_General_Science" = data[4, 2], 
                 "Girls_Arts" = data[5, 2], "Girls_Technicals" = data[6,2],
                 "Girls_Vocational_HEcons" = data[7, 2], "Girls_Vis_Arts" = data[8,2],
                 "Girls_Total" = data[9, 2],
                 
                 "Total_Agriculture" = data[1,3], "Total_Business_Accounting" = data[2,3], 
                 "Total_Secretarial" = data[3,3], "Total_General_Science" = data[4, 3], 
                 "Total_Arts" = data[5, 3], "Total_Technicals" = data[6,3],
                 "Total_Vocational_HEcons" = data[7, 3], "Total_Vis_Arts" = data[8,3],
                 "Total_Total" = data[9, 3],
                 
                 "%Girls_Agriculture" = data[1,4], "%Girls_Business_Accounting" = data[2,4], 
                 "%Girls_Secretarial" = data[3,4], "%Girls_General_Science" = data[4, 4], 
                 "%Girls_Arts" = data[5, 4], "%Girls_Technicals" = data[6,4],
                 "%Girls_Vocational_HEcons" = data[7, 4], "%Girls_Vis_Arts" = data[8,4],
                 "%Girls_Total" = data[9, 4]
    )
    df <- df %>% mutate_all(na_if, "")
    return(df)
  }
}

get_enrolment_program_private <- function(pdf_file, page = NULL, year){
  #### Extract the Year, District, Region data
  info_data <- get_area_year(pdf_file, page = page, year = year)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2013-2014", "2014-2015")){
    year_range_loc <- "2013-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 394.698627448421, left = 25.214409297497, bottom = 529.197841260467, 
                                         right = 529.2722105931))
          
          },
          "2017-2018" = {loc <- list(c(top = 397.374238125841, left = 54.799351059681, bottom = 537.983583924217, 
                                       right = 596.45100487429))
          },
          "2016-2017" = {loc <- list(c(top = 412.046517687411, left = 54.799351059681, bottom = 548.987793595394, 
                                       right = 570.77451564154))
          },
          "2015-2016" = {loc <- list(c(top = 408.282421323554, left = 56.077862310703, bottom = 539.079484442176, 
                                       right = 543.81644347267))
          },
          "2013-2015" = {loc <- list(c(top = 410.75564681725, left = 42.589451470659, bottom = 550.30595482546, 
                                       right = 606.83996481768))
          },
          "2012-2013" = {loc <- list(c(top = 413.281756079553, left = 467.11792860397, bottom = 539.044275319084, 
                                       right = 796.4959551837))
          }
  )

  ######## Extract the related data from pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  
  ##### Tidy and clean the data based on several parameter (year range,  number of column, etc)
  if(year == "2012-2013"){
    data <- raw_data[-1, -1]
  }else{
    data <- raw_data[-1, -c(1:5)]
  }
  
  if(nrow(data) == 8 && year_range_loc == "2013-2015"){
    (data <- rbind(data, c(rep(NA, 4))))
    data[9,1] <- sum(as.numeric(sub(",", "", data[,1], fixed = TRUE)), na.rm = T)
    data[9,2] <- sum(as.numeric(sub(",", "", data[,2], fixed = TRUE)), na.rm = T)
    data[9,3] <- sum(as.numeric(sub(",", "", data[,3], fixed = TRUE)), na.rm = T)
    
    percent_girls <- as.numeric(data[9,2])/as.numeric(data[9,3]) %>% as.numeric()
    data[9,4] <- label_percent()(percent_girls)
  }
  
  if(nrow(data) == 8 && (year == "2012-2013")){
    (data <- rbind(data, c(rep(NA, 4))))
  }
  
  ######### Create a Dataframe from the extracted data
  if(is_empty(data) || is.null(nrow(data))){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Boys_Agriculture" = NA, "Boys_Business_Accounting" = NA, 
                 "Boys_Secretarial" = NA, "Boys_General_Science" = NA, 
                 "Boys_Arts" = NA, "Boys_Technicals" = NA,
                 "Boys_Vocational_HEcons" = NA, "Boys_Vis_Arts" = NA,
                 "Boys_Total" = NA,
                 
                 "Girls_Agriculture" = NA, "Girls_Business_Accounting" = NA, 
                 "Girls_Secretarial" = NA, "Girls_General_Science" = NA, 
                 "Girls_Arts" = NA, "Girls_Technicals" = NA,
                 "Girls_Vocational_HEcons" = NA, "Girls_Vis_Arts" = NA,
                 "Girls_Total" = NA,
                 
                 "Total_Agriculture" = NA, "Total_Business_Accounting" = NA, 
                 "Total_Secretarial" = NA, "Total_General_Science" = NA, 
                 "Total_Arts" = NA, "Total_Technicals" = NA,
                 "Total_Vocational_HEcons" = NA, "Total_Vis_Arts" = NA,
                 "Total_Total" = NA,
                 
                 "%Girls_Agriculture" = NA, "%Girls_Business_Accounting" = NA, 
                 "%Girls_Secretarial" = NA, "%Girls_General_Science" = NA, 
                 "%Girls_Arts" = NA, "%Girls_Technicals" = NA,
                 "%Girls_Vocational_HEcons" = NA, "%Girls_Vis_Arts" = NA,
                 "%Girls_Total" = NA
    )
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Boys_Agriculture" = data[1,1], "Boys_Business_Accounting" = data[2, 1], 
                 "Boys_Secretarial" = data[3,1], "Boys_General_Science" = data[4, 1], 
                 "Boys_Arts" = data[5, 1], "Boys_Technicals" = data[6,1],
                 "Boys_Vocational_HEcons" = data[7, 1], "Boys_Vis_Arts" = data[8,1],
                 "Boys_Total" = data[9, 1],
                 
                 "Girls_Agriculture" = data[1,2], "Girls_Business_Accounting" = data[2,2], 
                 "Girls_Secretarial" = data[3,2], "Girls_General_Science" = data[4, 2], 
                 "Girls_Arts" = data[5, 2], "Girls_Technicals" = data[6,2],
                 "Girls_Vocational_HEcons" = data[7, 2], "Girls_Vis_Arts" = data[8,2],
                 "Girls_Total" = data[9, 2],
                 
                 "Total_Agriculture" = data[1,3], "Total_Business_Accounting" = data[2,3], 
                 "Total_Secretarial" = data[3,3], "Total_General_Science" = data[4, 3], 
                 "Total_Arts" = data[5, 3], "Total_Technicals" = data[6,3],
                 "Total_Vocational_HEcons" = data[7, 3], "Total_Vis_Arts" = data[8,3],
                 "Total_Total" = data[9, 3],
                 
                 "%Girls_Agriculture" = data[1,4], "%Girls_Business_Accounting" = data[2,4], 
                 "%Girls_Secretarial" = data[3,4], "%Girls_General_Science" = data[4, 4], 
                 "%Girls_Arts" = data[5, 4], "%Girls_Technicals" = data[6,4],
                 "%Girls_Vocational_HEcons" = data[7, 4], "%Girls_Vis_Arts" = data[8,4],
                 "%Girls_Total" = data[9, 4]
    )
    df <- df %>% mutate_all(na_if, "")
    return(df)
  }
}

get_enrolment_program_total <- function(pdf_file, page = NULL, year){
  info_data <- get_area_year(pdf_file, page = page)
  
  ### Adjust the year range since there are layout change every several year
  if(year %in% c("2018-2019", "2019-2020")){
    year_range_loc <- "2018-2020"
  } else if(year %in% c("2013-2014", "2014-2015")){
    year_range_loc <- "2013-2015"
  } else {
    year_range_loc <- year
  }
  
  ### Set the table location based on the documents year range
  switch (year_range_loc,
          "2018-2020" = {loc <- list(c(top = 394.698627448421, left = 26.47141129574, bottom = 532.968847255197, 
                                         right = 753.01856628042))
          },
          "2017-2018" = {loc <- list(c(top = 401.042308016231, left = 56.022041023145, bottom = 534.315514033825, 
                                       right = 783.5225692843))
          },
          "2016-2017" = {loc <- list(c(top = 412.046517687411, left = 56.022041023145, bottom = 547.76510363193, 
                                       right = 776.18642950352))
          },
          "2015-2016" = {loc <- list(c(top = 407.060018864504, left = 57.300264769756, bottom = 540.301886901229, 
                                       right = 773.62810577455))
          },
          "2013-2015" = {loc <- list(c(top = 410.75564681725, left = 42.589451470659, bottom = 550.30595482546, 
                                       right = 786.83996481768))
          }
  )
  
  ######## Extract the Public enrolment Data in the pdf file
  raw_data <- extract_tables(pdf_file, page = page, guess = FALSE, area = loc) %>% .[[1]]
  data <- raw_data[-1, -c(1:9)]
  
  if(nrow(data) == 8 && year_range_loc == "2013-2015"){
    (data <- rbind(data, c(rep(NA, 4))))
    data[9,1] <- sum(as.numeric(sub(",", "", data[,1], fixed = TRUE)), na.rm = T)
    data[9,2] <- sum(as.numeric(sub(",", "", data[,2], fixed = TRUE)), na.rm = T)
    data[9,3] <- sum(as.numeric(sub(",", "", data[,3], fixed = TRUE)), na.rm = T)
    
    percent_girls <- as.numeric(data[9,2])/as.numeric(data[9,3]) %>% as.numeric()
    data[9,4] <- label_percent()(percent_girls)
  }
  
  ######### Create a Dataframe from the extracted data
  if(is_empty(data) || is.null(nrow(data))){
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Boys_Agriculture" = NA, "Boys_Business_Accounting" = NA, 
                 "Boys_Secretarial" = NA, "Boys_General_Science" = NA, 
                 "Boys_Arts" = NA, "Boys_Technicals" = NA,
                 "Boys_Vocational_HEcons" = NA, "Boys_Vis_Arts" = NA,
                 "Boys_Total" = NA,
                 
                 "Girls_Agriculture" = NA, "Girls_Business_Accounting" = NA, 
                 "Girls_Secretarial" = NA, "Girls_General_Science" = NA, 
                 "Girls_Arts" = NA, "Girls_Technicals" = NA,
                 "Girls_Vocational_HEcons" = NA, "Girls_Vis_Arts" = NA,
                 "Girls_Total" = NA,
                 
                 "Total_Agriculture" = NA, "Total_Business_Accounting" = NA, 
                 "Total_Secretarial" = NA, "Total_General_Science" = NA, 
                 "Total_Arts" = NA, "Total_Technicals" = NA,
                 "Total_Vocational_HEcons" = NA, "Total_Vis_Arts" = NA,
                 "Total_Total" = NA,
                 
                 "%Girls_Agriculture" = NA, "%Girls_Business_Accounting" = NA, 
                 "%Girls_Secretarial" = NA, "%Girls_General_Science" = NA, 
                 "%Girls_Arts" = NA, "%Girls_Technicals" = NA,
                 "%Girls_Vocational_HEcons" = NA, "%Girls_Vis_Arts" = NA,
                 "%Girls_Total" = NA
    )
  } else{
    df <- tibble("Year" = info_data$year, "District" = info_data$district, "Region" = info_data$region, 
                 "Boys_Agriculture" = data[1,1], "Boys_Business_Accounting" = data[2, 1], 
                 "Boys_Secretarial" = data[3,1], "Boys_General_Science" = data[4, 1], 
                 "Boys_Arts" = data[5, 1], "Boys_Technicals" = data[6,1],
                 "Boys_Vocational_HEcons" = data[7, 1], "Boys_Vis_Arts" = data[8,1],
                 "Boys_Total" = data[9, 1],
                 
                 "Girls_Agriculture" = data[1,2], "Girls_Business_Accounting" = data[2,2], 
                 "Girls_Secretarial" = data[3,2], "Girls_General_Science" = data[4, 2], 
                 "Girls_Arts" = data[5, 2], "Girls_Technicals" = data[6,2],
                 "Girls_Vocational_HEcons" = data[7, 2], "Girls_Vis_Arts" = data[8,2],
                 "Girls_Total" = data[9, 2],
                 
                 "Total_Agriculture" = data[1,3], "Total_Business_Accounting" = data[2,3], 
                 "Total_Secretarial" = data[3,3], "Total_General_Science" = data[4, 3], 
                 "Total_Arts" = data[5, 3], "Total_Technicals" = data[6,3],
                 "Total_Vocational_HEcons" = data[7, 3], "Total_Vis_Arts" = data[8,3],
                 "Total_Total" = data[9, 3],
                 
                 "%Girls_Agriculture" = data[1,4], "%Girls_Business_Accounting" = data[2,4], 
                 "%Girls_Secretarial" = data[3,4], "%Girls_General_Science" = data[4, 4], 
                 "%Girls_Arts" = data[5, 4], "%Girls_Technicals" = data[6,4],
                 "%Girls_Vocational_HEcons" = data[7, 4], "%Girls_Vis_Arts" = data[8,4],
                 "%Girls_Total" = data[9, 4]
    )
    df <- df %>% mutate_all(na_if, "")
    return(df)
  }
}