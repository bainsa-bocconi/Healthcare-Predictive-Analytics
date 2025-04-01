#loaddata
library(dplyr)
library(magrittr)
library(tidyr)
stays = read.csv("icustays.csv")

length(unique(stays$subject_id))

a = stays %>%
  group_by(subject_id) %>%
  summarise(num_stays = n()) %>%
  arrange(desc(num_stays))
#table(stays$subject_id)

hist(table(stays$subject_id))


# Ensure data is sorted by subject_id and admittime
first_admissions_df <- stays %>%
  arrange(subject_id, intime) %>%  # Sort data by subject_id and admittime
  group_by(subject_id) %>%            # Group data by subject_id
  slice_head(n = 1) %>%                # Select the first row (earliest admission) for each group
  ungroup()

max(table(first_admissions_df$subject_id))

t = read.csv("patients.csv")

first_admissions_df = merge(first_admissions_df, t, by ='subject_id')

first_admissions_df$dod = as.Date(first_admissions_df$dod)

# Assuming your data is in a data frame called icustays_df
# Assuming your data is in a data frame called icustays_df
icustays_clean <- first_admissions_df %>%
  filter(is.na(dod) | dod < intime | dod > outtime)


# Remove specific columns (e.g., 'column1' and 'column2')
icustays_short <- icustays_clean %>%
  select(-first_careunit, -intime, -outtime, -anchor_year, -anchor_year_group)  # Replace with actual column names you want to remove


chartev = read.csv("chartevents.csv.gz")

library(data.table)

# Read the header (no rows) to get the column names
header_dt <- fread("chartevents.csv.gz", nrows = 0)
header_names <- names(header_dt)

# Define the important hadm_ids from your cleaned ICU data
important_hadm_ids <- unique(icustays_short$hadm_id)

# Chunk parameters
chunk_size <- 100000    # Adjust as needed
skip_rows <- 0          # Initial skip
output_file <- "chartevents_filtered.csv"
first_chunk <- TRUE     # To control writing headers only once

repeat {
  # For the first chunk, read with header. For subsequent chunks, read without header.
  if (skip_rows == 0) {
    chunk <- fread("chartevents.csv.gz", nrows = chunk_size)
    header_names <- names(chunk)  # Capture the header names (should match header_dt)
  } else {
    chunk <- fread("chartevents.csv.gz", skip = skip_rows, nrows = chunk_size, header = FALSE)
    # Assign the previously captured header names to the chunk
    setnames(chunk, header_names)
  }
  
  # Break if no more rows are returned
  if (nrow(chunk) == 0) break
  
  # Filter chunk: keep rows where hadm_id is in important_hadm_ids
  chunk_filtered <- chunk[hadm_id %in% important_hadm_ids]
  
  # Write out filtered data: write header only for the first chunk, then append
  if (nrow(chunk_filtered) > 0) {
    if (first_chunk) {
      fwrite(chunk_filtered, file = output_file)
      first_chunk <- FALSE
    } else {
      fwrite(chunk_filtered, file = output_file, append = TRUE)
    }
  }
  
  # Update skip_rows: add the number of rows read in the current chunk
  skip_rows <- skip_rows + nrow(chunk)
  
  cat("Processed", skip_rows, "rows\n")
}

cat("Filtered chartevents have been saved to", output_file, "\n")



