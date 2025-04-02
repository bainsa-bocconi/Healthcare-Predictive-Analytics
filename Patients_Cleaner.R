#load libraries
library(dplyr)
library(magrittr)
library(tidyr)

#load stays data
stays = read.csv("icustays.csv")


#check how many different patients there are
length(unique(stays$subject_id))


#count the number of stays for each patient
a = stays %>%
  group_by(subject_id) %>%
  summarise(num_stays = n()) %>%
  arrange(desc(num_stays))
#table(stays$subject_id)

#hist(table(stays$subject_id))


# keep only the first observation from each patient as it is the first time that he has been admitted
first_admissions_df <- stays %>%
  arrange(subject_id, intime) %>%  
  group_by(subject_id) %>%            
  slice_head(n = 1) %>%                
  ungroup()

#max(table(first_admissions_df$subject_id))

#load data for the patients
t = read.csv("patients.csv")

#merge on subject id with stays data
first_admissions_df = merge(first_admissions_df, t, by ='subject_id')

#make sure that dates are dates
first_admissions_df$dod = as.Date(first_admissions_df$dod)


#only keep patients that did not die during their hospital stay
icustays_clean <- first_admissions_df %>%
  filter(is.na(dod) | dod < intime | dod > outtime)


# Remove useless columns
icustays_short <- icustays_clean %>%
  select(-first_careunit, -intime, -outtime, -anchor_year, -anchor_year_group)  # Replace with actual column names you want to remove


#mark the subjects with more than 1 stay as they are the ones being readmitted
tab <- table(stays$subject_id)
repeated_tab <- tab[tab > 1]

# Extract patients that are admitted more than once
repeated <- data.frame(subject_id = as.numeric(names(repeated_tab)), n_stays = as.numeric(repeated_tab))

#merge with the repeated and set the admission number to 1 for the ones that were only admitted once (otherwise they would be NA)
icustays_short_dp = icustays_short %>%
  merge(repeated, by = 'subject_id', all = T)
icustays_short_dp$n_stays[is.na(icustays_short_dp$n_stays)] = 1


#readmitted boolean. 1 if readmitted
icustays_short_dp$readmitted_bool = ifelse(icustays_short_dp$n_stays > 1, 1,0)

#if male, then 1; if female, then 0
icustays_short_dp$gender_bool = ifelse(icustays_short_dp$gender == 'M',1,0 )

write.csv(icustays_short_dp, 'clean_patients_data')
