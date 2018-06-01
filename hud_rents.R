# francisco 
# just playing around with some HUD data on the 50th percentile rent in each county
library(tidyverse)
library(readxl)
# note: they don't have a data dictionary, but 
# rent50_0 = efficiency
# rent50_1 = 1 br
# etc
# read in data: bls wage data and hud median rents data
rents <- read_excel("/href/scratch3/m1fmb02/projects/hud_data/FY2017_50_rev.xlsx", col_names = TRUE)
names(rents)
# create fips variable from hud ids
rents <- rents %>%
  mutate(area_fips = substring(text = .$fips2010, first = 0 , last = 5)) %>%
  mutate(area_fips = as.numeric(area_fips))
head(rents$area_fips)

bls <- read_csv("/href/scratch3/m1fmb02/projects/price-to-wages/qcew/bls_wages.csv")
bls <- bls %>% filter(year == 2017)
bls <- bls %>% 
  mutate(area_fips = as.numeric(area_fips))
# rearrange
rents <- rents %>%
  select(area_fips, everything()) 
  

# simple test
# get hud med rents for 1br
med1br <- rents %>%
  filter(!areaname %in% c("FMR")) %>%
  select(region = area_fips, value = Rent50_1) %>%
  distinct(region, .keep_all = TRUE)

  
# 2 libraries for easy mapping
library(choroplethr)
library(choroplethrMaps)

county_choropleth(med1br, num_colors = 1)

## ideas
# 1. iqr for med rental rates for 1 brs, 2 brs, etc 
# 2. compare that with monthly wages?
# 3. ?????


