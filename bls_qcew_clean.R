# downloading and massaging qcew data
# this is a script to download wage data from the bls
# using their data guides: https://data.bls.gov/cew/doc/titles/area/area_titles.htm, https://www.bls.gov/cew/datatoc.htm,
# https://data.bls.gov/cew/doc/access/csv_data_slices.htm, https://data.bls.gov/cew/doc/titles/area/area_titles.htm

library(dplyr)
library(rvest)
library(tidyverse)
# set proxy (if necessary)
# Sys.setenv(http_proxy="http://proxy-t.XXX.gov:9999")

#### Gathering list of bls data to download ####

# save the url (this may change)
bls_csv_url <- "https://www.bls.gov/cew/datatoc.htm"

# need to download page because of frb firewall
dl_loc <- file.path("/place/you/want/to/download/files")
#### WARNING: these are big files and they take a while to download
download.file(bls_csv_url, file.path(basename(bls_csv_url)))
# read in page
bls_csv_page <- read_html("datatoc.htm")

# create list of csvs we want to download by parsing the bls qcew tables page
bls_list <- bls_csv_page %>% 
  html_nodes("#cew_naics_data") %>%
  html_nodes("a") %>% html_attr("href")

#keep <- grepl(pattern = "qtrly_by_industry", x = bls_list) 
#keep2 <- grepl(pattern = "qtrly_naics10_totals", x = bls_list)
keep3 <- grepl(pattern = "2017", x = bls_list)
bls_list <- bls_list[keep3]


#### download the files we want ####
lapply(bls_list, function(x) if(!file.exists(basename(x))) download.file(x, basename(x)))

bls_files <- list.files(pattern = "*.zip", full.names = TRUE)

clean_new_bls_wages <- function(file){
  # file <- new_bls_files # for testing!
  require(tidyverse)
  require(lubridate)
  require(stringr)
  # get full file path for the directory
  file <- file
  print(file)
  # unzip the dir and get a list of files to search through (we are searching for the "10 Total,")
  bls_zips <- unzip(zipfile = file, list = TRUE)
  # search for the "10 Total, all industry" csv, drop the rest
  target_file <- bls_zips$Name[grep(pattern = "10 Total,", x = bls_zips$Name)]
  # read in file, using full path -- file.path(file, target_file)
  bls_data <- read_csv(unzip(zipfile = file, files = target_file))
  # filter by indistry code = 10, which means totals, and aggregation level (agglvl) 70, 
  # which means at the county level
  bls_data <- bls_data %>% 
    filter(industry_code==10, agglvl_code==70) %>%
    # then select the vars we care about: employment, wages, areas (counties)
    # sanity checks after filtering:
    # table(bls_data$own_title[bls_data$agglvl_code==70]) # "Total Covered"
    # table(bls_data$agglvl_title[bls_data$agglvl_code==70]) # "County, Total Covered"
    # table(bls_data$industry_title[bls_data$agglvl_code==70]) # "Total, All Industries"
    select(area_fips, area_title, industry_code, year, qtr, 
           month1_emplvl, month2_emplvl, month3_emplvl, 
           total_qtrly_wages, avg_wkly_wage)
  # use those variables to create an average quarterly wage.
  bls_data <- bls_data %>% 
    mutate(avg_qtrly_wage = avg_wkly_wage * 12,
           avg_mthly_wage = avg_wkly_wage * 4,
           avg_qtrly_emplvl = (month1_emplvl + month2_emplvl + month3_emplvl/3)) %>%
    select(year, qtr, area_fips, area_title, avg_mthly_wage, avg_qtrly_wage) %>%
    print(head(bls_data))
  return(bls_data)
  system("rm *.zip")
  system("rmdir --help")
}   
# to remove large files already read into the environment
system("rm *.zip")
system("rmdir --help")
#### lapply cleaning function files ####


bls_clean_list <- lapply(bls_files, clean_new_bls_wages)

# turn list of results into dataframe
bls_df <- dplyr::bind_rows(bls_clean_list, .id = NULL) 

write_csv(bls_df, "bls_wages.csv")
