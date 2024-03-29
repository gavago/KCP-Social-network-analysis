library(tidyverse)
library(magrittr)

# Rdata files output from this file are
# 1. annual dyadic grooming indices.Rdata
# 2. annual dyadic 5m proximity indices.Rdata
# to pass to next script with sna measures function with outputs of sociograms and dataframes
# 3. save dyadic indices data in list columns for 

# 1. Grooming indices ----
# ----- Assemble grooming indices #####
load("data/counts - annual dyadic grooming.Rdata", verbose = T)
load("data/counts - dyadic focal party.Rdata", verbose = T)

#total grooming index - AB gm_gmd / AB total time in party where one was focal

total_gm_gmd %>% nrow() #2412
total_AB_party %>% names()
str(total_gm_gmd)
str(total_AB_party)

total_gm_gmd_index <- total_gm_gmd %>%
  #join count data w total number of times individuals A and B were in same party as one was being focaled
  left_join(., total_AB_party, by = c("ID1", "ID2", "year")) %>% 
  #replace NAs for dyads never observed in same party during focal follow
  mutate_at(vars(ends_with("_party")), .funs = list(function(x) ifelse(is.na(x), 0, x))) %>%
  mutate(gmgmdi = (total_AB_gm_gmd / total_AB_party) * 100) %>% # gm gmd index, percentage of time in party spent grooming each other
  mutate(gmgmdi = ifelse(is.nan(gmgmdi), 0, gmgmdi)) %>% # for 0/0
  select(ID1, ID2, year, total_AB_gm_gmd, total_AB_party, gmgmdi, sex_ID1, sex_ID2, everything()) %>%
  mutate(dyad_sex = ifelse(sex_ID1 == "M" & sex_ID2 == "M", "male", ifelse( sex_ID1 == "F" & sex_ID2 == "F", "female", "mixed" )))
nrow(total_gm_gmd_index) # 2412, 2585, 2657, 2914
head(total_gm_gmd_index)

total_gm_index <- total_gm %>%
  filter(ID1 != "CA" & ID2 != "CA") %>% #never really acheived community member status
  left_join(., total_AB_party, by = c("ID1", "ID2", "year")) %>%
  #replace NAs for dyads never observed in party during focal follow
  mutate_at(vars(ends_with("_party")), .funs = list(function(x) ifelse(is.na(x), 0, x))) %>%
  mutate(gmi = (total_AB_gm / total_AB_party) * 100) %>% # gm gmd index, percentage of time in party spent grooming each other
  mutate(gmi = ifelse(is.nan(gmi), 0, gmi)) %>% #for 0/0
  select(ID1, ID2, year, total_AB_gm, total_AB_party, gmi, sex_ID1, sex_ID2) %>%
  mutate(dyad_sex = ifelse(sex_ID1 == "M" & sex_ID2 == "M", "male", ifelse( sex_ID1 == "F" & sex_ID2 == "F", "female", "mixed" )))
nrow(total_gm_index) # 4824, 5168, 5312,5826

total_gmd_index <- total_gmd %>%
  filter(ID1 != "CA" & ID2 != "CA") %>% #never really acheived community member status
  merge(., total_AB_party, by = c("ID1", "ID2", "year"), all.x = T) %>%
  #replace NAs for dyads never observed in party during focal follow
  mutate_at(vars(ends_with("_party")), .funs = list(function(x) ifelse(is.na(x), 0, x))) %>%
  mutate(gmdi = (total_AB_gmd / total_AB_party) * 100) %>% # gm gmd index, percentage time in party spent grooming each other
  mutate(gmdi = ifelse(is.nan(gmdi), 0, gmdi)) %>% #for 0/0
  select(ID1, ID2, year, total_AB_gmd, total_AB_party, gmdi, sex_ID1, sex_ID2) %>%
  mutate(dyad_sex = ifelse(sex_ID1 == "M" & sex_ID2 == "M", "male", ifelse( sex_ID1 == "F" & sex_ID2 == "F", "female", "mixed" )))
nrow(total_gmd_index) #4824, 5168, 5312, 5826
head(total_gmd_index)

total_gm_gmd_index %>%
  filter(apply(., 1, function(x) any(is.na(x))))

total_gm_index %>%
  filter(apply(., 1, function(x) any(is.na(x))))

total_gmd_index %>%
  filter(apply(., 1, function(x) any(is.na(x))))

#of 3113 (2585) total dyads 90 (69) never observed within same party during a focal follow in ~ 10 yrs
nrow(total_gm_gmd)
total_gm_gmd %>%
  left_join(., total_AB_party, by = c("ID1", "ID2", "year")) %>% #redoing
  filter(is.na(total_AB_party))



#save(total_gm_gmd_index, total_gm_index, total_gmd_index, file = "data/indices - annual dyadic grooming.Rdata")
#write.csv(total_gm_gmd_index, file = "data/total grooming dyadic indices.csv", row.names = F)
#write.csv(total_gm_index, file = "data/grooming given dyadic indices.csv", row.names = F)

# ----- Explore annual grooming indices ####
load("data/annual possible focal dyads.Rdata", verbose = T)
load("data/indices - annual dyadic grooming.Rdata", verbose = T)
load("functions/functions - data preparation.Rdata", verbose = T)
nrow(total_gm_gmd_index) #2412

# unique female and male dyads by year
# no age filter
dir_annual_dyads %>%
  rename(Year = year) %>%
  add_dyad_attr() %>%
  filter(sex_ID1 == sex_ID2) %>%
  group_by(Year, sex_ID1) %>%
  tally()

# unique female and male dyads by year
# with age filter
dir_annual_dyads %>%
  add_dyad_attr() %>%
  add_age() %>%
  filter_age() %>%
  filter(sex_ID1 == sex_ID2) %>%
  group_by(year, sex_ID1) %>%
  tally()


#range
total_gm_gmd_index %>%
  group_by(year) %>%
  summarise(max = max(gmgmdi, na.rm = T), min = min(gmgmdi, na.rm = T),  
            median = median(gmgmdi, na.rm = T), mean = mean(gmgmdi, na.rm = T),
            sd = sd(gmgmdi, na.rm = T))

total_gm_gmd_index %>%
  filter(gmgmdi > 45)



# 2. Prox indices ----
# ----- Assemble time in 5m index #####
load("data/counts - dyadic focal party.Rdata", verbose = T)
load("data/counts - time in 5m.Rdata", verbose = T)

names(total_5m)
nrow(total_5m) #2412, 2597, 2936
names(total_AB_party)


#11/25/20 did not multiply prox index by 100 in original go
index_5m <- total_5m %>%
  left_join(., total_AB_party, by = c("ID1", "ID2", "year")) %>%
  mutate(total_AB_party = ifelse(is.na(total_AB_party), 0 , total_AB_party)) %>% #NAs of total AB party are dyads never seen in groups
  mutate(prox5i = ifelse(total_AB_party == 0, 0, (total_5m/total_AB_party)*100)) %>% # if total AB party is zero, avoid NaN of 0/0
  select(ID1, ID2, year, total_5m, total_AB_party, prox5i, everything()) %>%
  mutate(dyad_sex = ifelse(sex_ID1 == "M" & sex_ID2 == "M", "male", ifelse( sex_ID1 == "F" & sex_ID2 == "F", "female", "mixed" )))
  
range(index_5m$prox5i)

nrow(index_5m) #2412, 2597, 2679, 2936
names(index_5m)

# same sex thresholds for prox networks -----
prox_sex_thresh <- index_5m %>%
  select(year, dyad_sex, ID1,ID2, prox5i) %>%
  filter(dyad_sex != "mixed") %>%
  arrange(dyad_sex, year)%>%
  group_by(dyad_sex,year) %>%
  summarize(mean_prox = mean(prox5i), sd_prox = sd(prox5i)) %>%
  ungroup()
prox_sex_thresh

#save(prox_sex_thresh, file="data/annual thresholds for same sex prox nets.Rdata")


# play w filter same sex prox network ------
load("data/annual thresholds for same sex prox nets.Rdata", verbose = T)

see_prox_filter <- index_5m %>%
  left_join(., prox_sex_thresh, by = c("dyad_sex", "year")) %>%
  mutate(prox5i = case_when(
     dyad_sex != "mixed" & prox5i < mean_prox ~ 100, #(mean_prox - sd_prox) - ??? why 100?
     TRUE ~ prox5i
  ))


# for filtering, < mean prox = 0 is seems way too harsh - removes 2/3s of associations bt females and 1/2 of males'
# and < mean_prox - sd not harsh enough, removes no females.
# best to try calculating betweenness with weights. 3/4/20
index_5m %>% count(dyad_sex)
see_prox_filter %>% filter(prox5i== 100) %>% count(dyad_sex)


index_5m_filtered <- index_5m %>%
  left_join(., prox_sex_thresh, by = c("dyad_sex", "year")) %>%
  mutate(prox5i = case_when(
    dyad_sex != "mixed" & prox5i < mean_prox ~ 0,
    TRUE ~ prox5i
  ))

#save(index_5m, index_5m_filtered, file = "data/indices - annual dyadic 5m proximity.Rdata")

# 3. Save dyadic indices data as list columns for purrr -------
source("functions/functions - sna measures and plot.R")
load("data/indices - annual dyadic grooming.Rdata", verbose = T)
load("data/indices - annual dyadic 5m proximity.Rdata", verbose = T)


names(total_gm_gmd_index)
names(index_5m)


# where dyad ids and their indices are separate dataframes for each year year and dyad_sex
g_data_gmgmd_sex_sep <- total_gm_gmd_index %>%
  select(year, dyad_sex, ID1,ID2, gmgmdi) %>%
  filter(dyad_sex != "mixed") %>%
  # nest all dyad ids and indices within year and dyad sex
  nest(data = c(ID1,ID2, gmgmdi)) %>% #data = c(ID1,ID2, gmgmdi) # <- in windows
  arrange(dyad_sex, year) 

g_data_gm_sex_sep <- total_gm_index %>%
  select(year, dyad_sex, ID1,ID2, gmi) %>%
  filter(dyad_sex != "mixed") %>%
  # nest all dyad ids and indices within year and dyad sex
  nest(data = c(ID1,ID2, gmi)) %>% #data = c(ID1,ID2, gmgmdi) # <- in windows
  arrange(dyad_sex, year) 

g_data_prox_sex_sep <- index_5m %>%
  select(year, dyad_sex, ID1,ID2, prox5i) %>%
  filter(dyad_sex != "mixed") %>%
  # nest all dyad ids and indices within year and dyad sex
  nest(data = c(ID1,ID2, prox5i)) %>%
  arrange(dyad_sex, year) 


g_data_gmgmd_sex_comb <- total_gm_gmd_index %>%
  mutate(dyad_sex = "any_combo") %>%
  select(year, dyad_sex, ID1,ID2, gmgmdi) %>%
  # nest all dyad ids and indices within year and dyad sex
  nest(data = c(ID1,ID2, gmgmdi)) %>%
  arrange(year)

g_data_gm_sex_comb <- total_gm_index %>%
  mutate(dyad_sex = "any_combo") %>%
  select(year, dyad_sex, ID1,ID2, gmi) %>%
  # nest all dyad ids and indices within year and dyad sex
  nest(data = c(ID1,ID2, gmi)) %>%
  arrange(year)


g_data_prox_sex_comb <- index_5m %>%
  mutate(dyad_sex = "any_combo") %>%
  select(year, dyad_sex, ID1,ID2, prox5i) %>%
  # nest all dyad ids and indices within year and dyad sex
  nest(data = c(ID1,ID2, prox5i)) %>%
  arrange(year)


# save(g_data_gmgmd_sex_comb,
#     g_data_gm_sex_comb,
#      g_data_prox_sex_comb,
#     g_data_gmgmd_sex_sep,
#      g_data_gm_sex_sep,
#      g_data_prox_sex_sep, file = "data/list column dyadic data prox & gm by year & dyad-sex year.Rdata")


# graveyard ----
# ----- Sex specific networks of indices ####

fem_gmgmdi <- total_gm_gmd_index %>%
  filter(sex_ID1 == "F", sex_ID2 == "F")
nrow(fem_gmgmdi) #1054
head(fem_gmgmdi)

male_gmgmdi <- total_gm_gmd_index %>%
  filter(sex_ID1 == "M", sex_ID2 == "M")
nrow(male_gmgmdi) #421
head(male_gmgmdi)

fem_gmi <- total_gm_index %>%
  filter(sex_ID1 == "F", sex_ID2 == "F")
nrow(fem_gmi) #2108 rows w non-grooming dyads included, 401 w out
head(fem_gmi)

male_gmi <- total_gm_index %>%
  filter(sex_ID1 == "M", sex_ID2 == "M")
nrow(male_gmi) #842 rows w non-grooming dyads included
head(male_gmi)

fem_gmdi <- total_gmd_index %>%
  filter(sex_ID1 == "F", sex_ID2 == "F")
nrow(fem_gmdi) #2108 rows w non-grooming dyads included, 84 w out
head(fem_gmdi)

male_gmi %>%
  filter(total_AB_gm != 0) %>% nrow() 

male_gmdi <- total_gmd_index %>%
  filter(sex_ID1 == "M", sex_ID2 == "M")
nrow(male_gmdi) #782 rows w non-grooming dyads included,405 without
head(male_gmdi)

# ----- Sex specific 5m ####
female_prox5i <- index_5m %>%
  filter(sex_ID1 == "F", sex_ID2 == "F")

male_prox5i <- index_5m %>%
  filter(sex_ID1 == "M", sex_ID2 == "M")

nrow(female_prox5i) #1062
nrow(male_prox5i) #421


index_5m$dyad_sex <- "any_combo"
female_prox5i$dyad_sex <- "female"
male_prox5i$dyad_sex <- "male"