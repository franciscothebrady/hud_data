# francisco 
# just playing around with some HUD data on the 50th percentile rent in each county
library(tidyverse)
library(readxl)
# note: they don't have a data dictionary, but 
# rent50_0 = efficiency
# rent50_1 = 1 br
# etc

rents <- read_excel("/href/scratch3/m1fmb02/projects/hud_rents/FY2017_50_rev.xlsx", col_names = TRUE)
bls <- read_csv("/href/scratch3/m1fmb02/projects/price-to-wages/qcew/bls_wages.csv")
bls <- bls %>% filter(year == 2017)
bls <- bls %>% 
  mutate(area_fips = as.numeric(area_fips))

rents <- rents %>%
  select(area_fips, everything())
         