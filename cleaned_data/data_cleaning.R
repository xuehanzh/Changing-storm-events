library("plyr")
library("dplyr")
library("R.utils")
library("jsonlite")

# Unzip all data files, merge, and save merged file (three types: details, location, and fatalities)
setwd("/Users/Robyn/Desktop/INF-554/project-guineapigs/Raw_Data_Files/Details")

gz_files <- list.files(pattern="*.csv")
unzipped <- ldply(.data = gz_files, .fun = gunzip)

csv_files <- list.files(pattern="*.csv")
detail_data <- ldply(.data = csv_files, .fun = read.csv)

write.csv(detail_data, "all_details.csv", row.names = FALSE)

setwd("/Users/Robyn/Desktop/INF-554/project-guineapigs/Raw_Data_Files/Locations")

gz_files <- list.files(pattern="*.csv")
unzipped <- ldply(.data = gz_files, .fun = gunzip)

csv_files <- list.files(pattern="*.csv")
location_data <- ldply(.data = csv_files, .fun = read.csv)
write.csv(location_data, "all_locations.csv", row.names = FALSE)

setwd("/Users/Robyn/Desktop/INF-554/project-guineapigs/Raw_Data_Files/Fatalities")

gz_files <- list.files(pattern="*.csv")
unzipped <- ldply(.data = gz_files, .fun = gunzip)

csv_files <- list.files(pattern="*.csv")
fatal_data <- ldply(.data = csv_files, .fun = read.csv)

write.csv(fatal_data, "all_fatalities.csv", row.names = FALSE)

# View list of weather event types in file
detail_data$EVENT_TYPE <- as.factor(detail_data$EVENT_TYPE)
levels(detail_data$EVENT_TYPE)

# Selected only hurricanes, tropical storms, excessive heat, and wildfires
selected_dat <- detail_data[which(detail_data$EVENT_TYPE == 'Hurricane' | 
                                  detail_data$EVENT_TYPE == 'Tropical Storm' | 
                                  detail_data$EVENT_TYPE == 'Excessive Heat' |
                                  detail_data$EVENT_TYPE == 'Wildfire'), ]

# Remove empty columns
selected_dat$TOR_F_SCALE <- NULL
selected_dat$TOR_LENGTH <- NULL
selected_dat$TOR_OTHER_CZ_FIPS <- NULL
selected_dat$TOR_OTHER_CZ_NAME <- NULL
selected_dat$TOR_OTHER_CZ_STATE <- NULL
selected_dat$TOR_OTHER_WFO <- NULL
selected_dat$TOR_WIDTH <- NULL
selected_dat$MAGNITUDE_TYPE <- NULL

# Save dataframe as CSV and JSON
write.csv(selected_dat, "data_for_d3.csv", row.names = FALSE)

json_dat <- toJSON(selected_dat)
write(json_dat, "data_for_d3.json")
