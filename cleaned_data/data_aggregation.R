library("plyr")
library("dplyr")
library("jsonlite")

# Creates aggregated D3 files to compare years and/or state's storm event characteristics

# Read in D3 CSV
dat <- read.csv("data_for_d3.csv")

# Sum direct and indirect deaths/injuries
dat$INJURIES <- dat$INJURIES_DIRECT + dat$INJURIES_INDIRECT
dat$DEATHS <- dat$DEATHS_DIRECT + dat$DEATHS_INDIRECT

# Summarize damage, injuries, death, and counts of weather events BY YEAR
damage <- dat %>% 
  group_by(YEAR, EVENT_TYPE) %>% 
  summarize(DAMAGE_PROPERTY = sum(DAMAGE_PROPERTY_N))

injuries <- dat %>%
  group_by(YEAR, EVENT_TYPE) %>%
  summarize(INJURIES = sum(INJURIES))

deaths <- dat %>% 
  group_by(YEAR, EVENT_TYPE) %>% 
  summarize(DEATHS = sum(DEATHS))

counts <- dat %>%
  group_by(YEAR, EVENT_TYPE) %>%
  summarize(COUNT_EVENTS = n())

# Merge summary dataframes into one dataframe
all <- merge(damage,deaths)
all <- merge(all,injuries)
all <- merge(all, counts)

# Reshape long data into wide data (EVENT_TYPE X Variables)
all <- reshape(all, idvar = "YEAR", timevar = "EVENT_TYPE", direction = "wide")

# Change NAs to 0 for Summing
all[is.na(all)] <- 0

# Rename reshaped variables
names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm'] <- 'DAMAGE_TROPICAL'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire'] <- 'DAMAGE_FIRE'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat'] <- 'DAMAGE_HEAT'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane'] <- 'DAMAGE_HURRICANE'

names(all)[names(all) == 'DEATHS.Excessive Heat'] <- 'DEATH_HEAT'
names(all)[names(all) == 'DEATHS.Tropical Storm'] <- 'DEATH_TROPICAL'
names(all)[names(all) == 'DEATHS.Wildfire'] <- 'DEATH_FIRE'
names(all)[names(all) == 'DEATHS.Hurricane'] <- 'DEATH_HURRICANE'

names(all)[names(all) == 'INJURIES.Excessive Heat'] <- 'INJURIES_HEAT'
names(all)[names(all) == 'INJURIES.Tropical Storm'] <- 'INJURIES_TROPICAL'
names(all)[names(all) == 'INJURIES.Wildfire'] <- 'INJURIES_FIRE'
names(all)[names(all) == 'INJURIES.Hurricane'] <- 'INJURIES_HURRICANE'

names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat'] <- 'COUNT_HEAT'
names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm'] <- 'COUNT_TROPICAL'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire'] <- 'COUNT_FIRE'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane'] <- 'COUNT_HURRICANE'

# Create total variables for each parameter of interst
all$TOTAL_DAMAGE <- all$DAMAGE_TROPICAL + all$DAMAGE_FIRE + all$DAMAGE_HEAT + all$DAMAGE_HURRICANE
all$TOTAL_DEATHS <- all$DEATH_HEAT + all$DEATH_FIRE + all$DEATH_TROPICAL + all$DEATH_HURRICANE
all$TOTAL_INJURIES <- all$INJURIES_FIRE + all$INJURIES_HEAT + all$INJURIES_HURRICANE + all$INJURIES_TROPICAL
all$TOTAL_COUNTS <- all$COUNT_FIRE + all$COUNT_HEAT + all$COUNT_HURRICANE + all$COUNT_TROPICAL

# Drop 2017 (not a complete year, not fully accurate for comparison purposes)
complete <- all[which(all$YEAR != 2017),]

# Save year summaries to CSV and JSON for D3
write.csv(complete, "year_summaries_for_d3.csv", row.names = FALSE)

json_dat <- toJSON(complete)
write(json_dat, "year_summaries_for_d3.json")

# Summarize damage, injuries, death, and counts of weather events BY STATE
damage <- dat %>% 
  group_by(STATE, EVENT_TYPE) %>% 
  summarize(DAMAGE_PROPERTY = sum(DAMAGE_PROPERTY_N))

injuries <- dat %>%
  group_by(STATE, EVENT_TYPE) %>%
  summarize(INJURIES = sum(INJURIES))

deaths <- dat %>% 
  group_by(STATE, EVENT_TYPE) %>% 
  summarize(DEATHS = sum(DEATHS))

counts <- dat %>%
  group_by(STATE, EVENT_TYPE) %>%
  summarize(COUNT_EVENTS = n())

# Merge summary dataframes into one dataframe
all <- merge(damage,deaths)
all <- merge(all,injuries)
all <- merge(all, counts)

# Reshape long data into wide data (EVENT_TYPE X Variables)
all <- reshape(all, idvar = "STATE", timevar = "EVENT_TYPE", direction = "wide")

# Change NAs to 0 for Summing
all[is.na(all)] <- 0

# Rename reshaped variables
names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm'] <- 'DAMAGE_TROPICAL'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire'] <- 'DAMAGE_FIRE'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat'] <- 'DAMAGE_HEAT'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane'] <- 'DAMAGE_HURRICANE'

names(all)[names(all) == 'DEATHS.Excessive Heat'] <- 'DEATH_HEAT'
names(all)[names(all) == 'DEATHS.Tropical Storm'] <- 'DEATH_TROPICAL'
names(all)[names(all) == 'DEATHS.Wildfire'] <- 'DEATH_FIRE'
names(all)[names(all) == 'DEATHS.Hurricane'] <- 'DEATH_HURRICANE'

names(all)[names(all) == 'INJURIES.Excessive Heat'] <- 'INJURIES_HEAT'
names(all)[names(all) == 'INJURIES.Tropical Storm'] <- 'INJURIES_TROPICAL'
names(all)[names(all) == 'INJURIES.Wildfire'] <- 'INJURIES_FIRE'
names(all)[names(all) == 'INJURIES.Hurricane'] <- 'INJURIES_HURRICANE'

names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat'] <- 'COUNT_HEAT'
names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm'] <- 'COUNT_TROPICAL'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire'] <- 'COUNT_FIRE'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane'] <- 'COUNT_HURRICANE'

# Create total variables for each parameter of interst
all$TOTAL_DAMAGE <- all$DAMAGE_TROPICAL + all$DAMAGE_FIRE + all$DAMAGE_HEAT + all$DAMAGE_HURRICANE
all$TOTAL_DEATHS <- all$DEATH_HEAT + all$DEATH_FIRE + all$DEATH_TROPICAL + all$DEATH_HURRICANE
all$TOTAL_INJURIES <- all$INJURIES_FIRE + all$INJURIES_HEAT + all$INJURIES_HURRICANE + all$INJURIES_TROPICAL
all$TOTAL_COUNTS <- all$COUNT_FIRE + all$COUNT_HEAT + all$COUNT_HURRICANE + all$COUNT_TROPICAL

complete <- all

# Save state summaries to CSV and JSON for D3
write.csv(complete, "state_summaries_for_d3.csv", row.names = FALSE)

json_dat <- toJSON(complete)
write(json_dat, "state_summaries_for_d3.json")
###########################PROCESSING FOR STATE BY YEAR##################################
dat <- read.csv("data_for_d3.csv")
# Drop 2017 (not a complete year, not fully accurate for comparison purposes)
dat <- dat[which(dat$YEAR != 2017),]

# Sum direct and indirect deaths/injuries
dat$INJURIES <- dat$INJURIES_DIRECT + dat$INJURIES_INDIRECT
dat$DEATHS <- dat$DEATHS_DIRECT + dat$DEATHS_INDIRECT

# Summarize damage, injuries, death, and counts of weather events BY STATE AND YEAR
damage <- dat %>% 
  group_by(STATE, YEAR, EVENT_TYPE) %>% 
  summarize(DAMAGE_PROPERTY = sum(DAMAGE_PROPERTY_N))

injuries <- dat %>%
  group_by(STATE, YEAR, EVENT_TYPE) %>%
  summarize(INJURIES = sum(INJURIES))

deaths <- dat %>% 
  group_by(STATE, YEAR, EVENT_TYPE) %>% 
  summarize(DEATHS = sum(DEATHS))

counts <- dat %>%
  group_by(STATE, YEAR, EVENT_TYPE) %>%
  summarize(COUNT_EVENTS = n())

# Merge summary dataframes into one dataframe
all <- merge(damage,deaths)
all <- merge(all,injuries)
all <- merge(all, counts)

# Reshape long data into wide data (EVENT_TYPE X Variables)
test <- reshape(all, idvar = c("STATE", "YEAR"), timevar = "EVENT_TYPE", direction = "wide")
all <- reshape(test, idvar = "STATE", timevar = "YEAR", direction = "wide")

# Change NAs to 0 for Summing
all[is.na(all)] <- 0

# Rename all variables to suitable name
names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.1996'] <- 'DAMAGE_TROPICAL_1996'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.1996'] <- 'DAMAGE_FIRE_1996'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.1996'] <- 'DAMAGE_HEAT_1996'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.1996'] <- 'DAMAGE_HURRICANE_1996'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.1997'] <- 'DAMAGE_TROPICAL_1997'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.1997'] <- 'DAMAGE_FIRE_1997'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.1997'] <- 'DAMAGE_HEAT_1997'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.1997'] <- 'DAMAGE_HURRICANE_1997'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.1998'] <- 'DAMAGE_TROPICAL_1998'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.1998'] <- 'DAMAGE_FIRE_1998'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.1998'] <- 'DAMAGE_HEAT_1998'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.1998'] <- 'DAMAGE_HURRICANE_1998'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.1999'] <- 'DAMAGE_TROPICAL_1999'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.1999'] <- 'DAMAGE_FIRE_1999'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.1999'] <- 'DAMAGE_HEAT_1999'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.1999'] <- 'DAMAGE_HURRICANE_1999'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2000'] <- 'DAMAGE_TROPICAL_2000'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2000'] <- 'DAMAGE_FIRE_2000'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2000'] <- 'DAMAGE_HEAT_2000'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2000'] <- 'DAMAGE_HURRICANE_2000'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2001'] <- 'DAMAGE_TROPICAL_2001'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2001'] <- 'DAMAGE_FIRE_2001'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2001'] <- 'DAMAGE_HEAT_2001'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2001'] <- 'DAMAGE_HURRICANE_2001'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2002'] <- 'DAMAGE_TROPICAL_2002'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2002'] <- 'DAMAGE_FIRE_2002'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2002'] <- 'DAMAGE_HEAT_2002'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2002'] <- 'DAMAGE_HURRICANE_2002'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2003'] <- 'DAMAGE_TROPICAL_2003'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2003'] <- 'DAMAGE_FIRE_2003'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2003'] <- 'DAMAGE_HEAT_2003'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2003'] <- 'DAMAGE_HURRICANE_2003'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2004'] <- 'DAMAGE_TROPICAL_2004'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2004'] <- 'DAMAGE_FIRE_2004'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2004'] <- 'DAMAGE_HEAT_2004'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2004'] <- 'DAMAGE_HURRICANE_2004'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2005'] <- 'DAMAGE_TROPICAL_2005'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2005'] <- 'DAMAGE_FIRE_2005'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2005'] <- 'DAMAGE_HEAT_2005'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2005'] <- 'DAMAGE_HURRICANE_2005'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2006'] <- 'DAMAGE_TROPICAL_2006'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2006'] <- 'DAMAGE_FIRE_2006'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2006'] <- 'DAMAGE_HEAT_2006'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2006'] <- 'DAMAGE_HURRICANE_2006'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2007'] <- 'DAMAGE_TROPICAL_2007'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2007'] <- 'DAMAGE_FIRE_2007'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2007'] <- 'DAMAGE_HEAT_2007'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2007'] <- 'DAMAGE_HURRICANE_2007'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2008'] <- 'DAMAGE_TROPICAL_2008'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2008'] <- 'DAMAGE_FIRE_2008'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2008'] <- 'DAMAGE_HEAT_2008'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2008'] <- 'DAMAGE_HURRICANE_2008'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2009'] <- 'DAMAGE_TROPICAL_2009'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2009'] <- 'DAMAGE_FIRE_2009'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2009'] <- 'DAMAGE_HEAT_2009'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2009'] <- 'DAMAGE_HURRICANE_2009'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2010'] <- 'DAMAGE_TROPICAL_2010'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2010'] <- 'DAMAGE_FIRE_2010'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2010'] <- 'DAMAGE_HEAT_2010'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2010'] <- 'DAMAGE_HURRICANE_2010'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2011'] <- 'DAMAGE_TROPICAL_2011'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2011'] <- 'DAMAGE_FIRE_2011'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2011'] <- 'DAMAGE_HEAT_2011'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2011'] <- 'DAMAGE_HURRICANE_2011'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2012'] <- 'DAMAGE_TROPICAL_2012'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2012'] <- 'DAMAGE_FIRE_2012'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2012'] <- 'DAMAGE_HEAT_2012'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2012'] <- 'DAMAGE_HURRICANE_2012'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2013'] <- 'DAMAGE_TROPICAL_2013'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2013'] <- 'DAMAGE_FIRE_2013'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2013'] <- 'DAMAGE_HEAT_2013'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2013'] <- 'DAMAGE_HURRICANE_2013'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2014'] <- 'DAMAGE_TROPICAL_2014'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2014'] <- 'DAMAGE_FIRE_2014'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2014'] <- 'DAMAGE_HEAT_2014'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2014'] <- 'DAMAGE_HURRICANE_2014'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2015'] <- 'DAMAGE_TROPICAL_2015'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2015'] <- 'DAMAGE_FIRE_2015'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2015'] <- 'DAMAGE_HEAT_2015'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2015'] <- 'DAMAGE_HURRICANE_2015'

names(all)[names(all) == 'DAMAGE_PROPERTY.Tropical Storm.2016'] <- 'DAMAGE_TROPICAL_2016'
names(all)[names(all) == 'DAMAGE_PROPERTY.Wildfire.2016'] <- 'DAMAGE_FIRE_2016'
names(all)[names(all) == 'DAMAGE_PROPERTY.Excessive Heat.2016'] <- 'DAMAGE_HEAT_2016'
names(all)[names(all) == 'DAMAGE_PROPERTY.Hurricane.2016'] <- 'DAMAGE_HURRICANE_2016'

names(all)[names(all) == 'DEATHS.Tropical Storm.1996'] <- 'DEATH_TROPICAL_1996'
names(all)[names(all) == 'DEATHS.Wildfire.1996'] <- 'DEATH_FIRE_1996'
names(all)[names(all) == 'DEATHS.Excessive Heat.1996'] <- 'DEATH_HEAT_1996'
names(all)[names(all) == 'DEATHS.Hurricane.1996'] <- 'DEATH_HURRICANE_1996'

names(all)[names(all) == 'DEATHS.Tropical Storm.1997'] <- 'DEATH_TROPICAL_1997'
names(all)[names(all) == 'DEATHS.Wildfire.1997'] <- 'DEATH_FIRE_1997'
names(all)[names(all) == 'DEATHS.Excessive Heat.1997'] <- 'DEATH_HEAT_1997'
names(all)[names(all) == 'DEATHS.Hurricane.1997'] <- 'DEATH_HURRICANE_1997'

names(all)[names(all) == 'DEATHS.Tropical Storm.1998'] <- 'DEATH_TROPICAL_1998'
names(all)[names(all) == 'DEATHS.Wildfire.1998'] <- 'DEATH_FIRE_1998'
names(all)[names(all) == 'DEATHS.Excessive Heat.1998'] <- 'DEATH_HEAT_1998'
names(all)[names(all) == 'DEATHS.Hurricane.1998'] <- 'DEATH_HURRICANE_1998'

names(all)[names(all) == 'DEATHS.Tropical Storm.1999'] <- 'DEATH_TROPICAL_1999'
names(all)[names(all) == 'DEATHS.Wildfire.1999'] <- 'DEATH_FIRE_1999'
names(all)[names(all) == 'DEATHS.Excessive Heat.1999'] <- 'DEATH_HEAT_1999'
names(all)[names(all) == 'DEATHS.Hurricane.1999'] <- 'DEATH_HURRICANE_1999'

names(all)[names(all) == 'DEATHS.Tropical Storm.2000'] <- 'DEATH_TROPICAL_2000'
names(all)[names(all) == 'DEATHS.Wildfire.2000'] <- 'DEATH_FIRE_2000'
names(all)[names(all) == 'DEATHS.Excessive Heat.2000'] <- 'DEATH_HEAT_2000'
names(all)[names(all) == 'DEATHS.Hurricane.2000'] <- 'DEATH_HURRICANE_2000'

names(all)[names(all) == 'DEATHS.Tropical Storm.2001'] <- 'DEATH_TROPICAL_2001'
names(all)[names(all) == 'DEATHS.Wildfire.2001'] <- 'DEATH_FIRE_2001'
names(all)[names(all) == 'DEATHS.Excessive Heat.2001'] <- 'DEATH_HEAT_2001'
names(all)[names(all) == 'DEATHS.Hurricane.2001'] <- 'DEATH_HURRICANE_2001'

names(all)[names(all) == 'DEATHS.Tropical Storm.2002'] <- 'DEATH_TROPICAL_2002'
names(all)[names(all) == 'DEATHS.Wildfire.2002'] <- 'DEATH_FIRE_2002'
names(all)[names(all) == 'DEATHS.Excessive Heat.2002'] <- 'DEATH_HEAT_2002'
names(all)[names(all) == 'DEATHS.Hurricane.2002'] <- 'DEATH_HURRICANE_2002'

names(all)[names(all) == 'DEATHS.Tropical Storm.2003'] <- 'DEATH_TROPICAL_2003'
names(all)[names(all) == 'DEATHS.Wildfire.2003'] <- 'DEATH_FIRE_2003'
names(all)[names(all) == 'DEATHS.Excessive Heat.2003'] <- 'DEATH_HEAT_2003'
names(all)[names(all) == 'DEATHS.Hurricane.2003'] <- 'DEATH_HURRICANE_2003'

names(all)[names(all) == 'DEATHS.Tropical Storm.2004'] <- 'DEATH_TROPICAL_2004'
names(all)[names(all) == 'DEATHS.Wildfire.2004'] <- 'DEATH_FIRE_2004'
names(all)[names(all) == 'DEATHS.Excessive Heat.2004'] <- 'DEATH_HEAT_2004'
names(all)[names(all) == 'DEATHS.Hurricane.2004'] <- 'DEATH_HURRICANE_2004'

names(all)[names(all) == 'DEATHS.Tropical Storm.2005'] <- 'DEATH_TROPICAL_2005'
names(all)[names(all) == 'DEATHS.Wildfire.2005'] <- 'DEATH_FIRE_2005'
names(all)[names(all) == 'DEATHS.Excessive Heat.2005'] <- 'DEATH_HEAT_2005'
names(all)[names(all) == 'DEATHS.Hurricane.2005'] <- 'DEATH_HURRICANE_2005'

names(all)[names(all) == 'DEATHS.Tropical Storm.2006'] <- 'DEATH_TROPICAL_2006'
names(all)[names(all) == 'DEATHS.Wildfire.2006'] <- 'DEATH_FIRE_2006'
names(all)[names(all) == 'DEATHS.Excessive Heat.2006'] <- 'DEATH_HEAT_2006'
names(all)[names(all) == 'DEATHS.Hurricane.2006'] <- 'DEATH_HURRICANE_2006'

names(all)[names(all) == 'DEATHS.Tropical Storm.2007'] <- 'DEATH_TROPICAL_2007'
names(all)[names(all) == 'DEATHS.Wildfire.2007'] <- 'DEATH_FIRE_2007'
names(all)[names(all) == 'DEATHS.Excessive Heat.2007'] <- 'DEATH_HEAT_2007'
names(all)[names(all) == 'DEATHS.Hurricane.2007'] <- 'DEATH_HURRICANE_2007'

names(all)[names(all) == 'DEATHS.Tropical Storm.2008'] <- 'DEATH_TROPICAL_2008'
names(all)[names(all) == 'DEATHS.Wildfire.2008'] <- 'DEATH_FIRE_2008'
names(all)[names(all) == 'DEATHS.Excessive Heat.2008'] <- 'DEATH_HEAT_2008'
names(all)[names(all) == 'DEATHS.Hurricane.2008'] <- 'DEATH_HURRICANE_2008'

names(all)[names(all) == 'DEATHS.Tropical Storm.2009'] <- 'DEATH_TROPICAL_2009'
names(all)[names(all) == 'DEATHS.Wildfire.2009'] <- 'DEATH_FIRE_2009'
names(all)[names(all) == 'DEATHS.Excessive Heat.2009'] <- 'DEATH_HEAT_2009'
names(all)[names(all) == 'DEATHS.Hurricane.2009'] <- 'DEATH_HURRICANE_2009'

names(all)[names(all) == 'DEATHS.Tropical Storm.2010'] <- 'DEATH_TROPICAL_2010'
names(all)[names(all) == 'DEATHS.Wildfire.2010'] <- 'DEATH_FIRE_2010'
names(all)[names(all) == 'DEATHS.Excessive Heat.2010'] <- 'DEATH_HEAT_2010'
names(all)[names(all) == 'DEATHS.Hurricane.2010'] <- 'DEATH_HURRICANE_2010'

names(all)[names(all) == 'DEATHS.Tropical Storm.2011'] <- 'DEATH_TROPICAL_2011'
names(all)[names(all) == 'DEATHS.Wildfire.2011'] <- 'DEATH_FIRE_2011'
names(all)[names(all) == 'DEATHS.Excessive Heat.2011'] <- 'DEATH_HEAT_2011'
names(all)[names(all) == 'DEATHS.Hurricane.2011'] <- 'DEATH_HURRICANE_2011'

names(all)[names(all) == 'DEATHS.Tropical Storm.2012'] <- 'DEATH_TROPICAL_2012'
names(all)[names(all) == 'DEATHS.Wildfire.2012'] <- 'DEATH_FIRE_2012'
names(all)[names(all) == 'DEATHS.Excessive Heat.2012'] <- 'DEATH_HEAT_2012'
names(all)[names(all) == 'DEATHS.Hurricane.2012'] <- 'DEATH_HURRICANE_2012'

names(all)[names(all) == 'DEATHS.Tropical Storm.2013'] <- 'DEATH_TROPICAL_2013'
names(all)[names(all) == 'DEATHS.Wildfire.2013'] <- 'DEATH_FIRE_2013'
names(all)[names(all) == 'DEATHS.Excessive Heat.2013'] <- 'DEATH_HEAT_2013'
names(all)[names(all) == 'DEATHS.Hurricane.2013'] <- 'DEATH_HURRICANE_2013'

names(all)[names(all) == 'DEATHS.Tropical Storm.2014'] <- 'DEATH_TROPICAL_2014'
names(all)[names(all) == 'DEATHS.Wildfire.2014'] <- 'DEATH_FIRE_2014'
names(all)[names(all) == 'DEATHS.Excessive Heat.2014'] <- 'DEATH_HEAT_2014'
names(all)[names(all) == 'DEATHS.Hurricane.2014'] <- 'DEATH_HURRICANE_2014'

names(all)[names(all) == 'DEATHS.Tropical Storm.2015'] <- 'DEATH_TROPICAL_2015'
names(all)[names(all) == 'DEATHS.Wildfire.2015'] <- 'DEATH_FIRE_2015'
names(all)[names(all) == 'DEATHS.Excessive Heat.2015'] <- 'DEATH_HEAT_2015'
names(all)[names(all) == 'DEATHS.Hurricane.2015'] <- 'DEATH_HURRICANE_2015'

names(all)[names(all) == 'DEATHS.Tropical Storm.2016'] <- 'DEATH_TROPICAL_2016'
names(all)[names(all) == 'DEATHS.Wildfire.2016'] <- 'DEATH_FIRE_2016'
names(all)[names(all) == 'DEATHS.Excessive Heat.2016'] <- 'DEATH_HEAT_2016'
names(all)[names(all) == 'DEATHS.Hurricane.2016'] <- 'DEATH_HURRICANE_2016'

names(all)[names(all) == 'INJURIES.Tropical Storm.1996'] <- 'INJURIES_TROPICAL_1996'
names(all)[names(all) == 'INJURIES.Wildfire.1996'] <- 'INJURIES_FIRE_1996'
names(all)[names(all) == 'INJURIES.Excessive Heat.1996'] <- 'INJURIES_HEAT_1996'
names(all)[names(all) == 'INJURIES.Hurricane.1996'] <- 'INJURIES_HURRICANE_1996'

names(all)[names(all) == 'INJURIES.Tropical Storm.1997'] <- 'INJURIES_TROPICAL_1997'
names(all)[names(all) == 'INJURIES.Wildfire.1997'] <- 'INJURIES_FIRE_1997'
names(all)[names(all) == 'INJURIES.Excessive Heat.1997'] <- 'INJURIES_HEAT_1997'
names(all)[names(all) == 'INJURIES.Hurricane.1997'] <- 'INJURIES_HURRICANE_1997'

names(all)[names(all) == 'INJURIES.Tropical Storm.1998'] <- 'INJURIES_TROPICAL_1998'
names(all)[names(all) == 'INJURIES.Wildfire.1998'] <- 'INJURIES_FIRE_1998'
names(all)[names(all) == 'INJURIES.Excessive Heat.1998'] <- 'INJURIES_HEAT_1998'
names(all)[names(all) == 'INJURIES.Hurricane.1998'] <- 'INJURIES_HURRICANE_1998'

names(all)[names(all) == 'INJURIES.Tropical Storm.1999'] <- 'INJURIES_TROPICAL_1999'
names(all)[names(all) == 'INJURIES.Wildfire.1999'] <- 'INJURIES_FIRE_1999'
names(all)[names(all) == 'INJURIES.Excessive Heat.1999'] <- 'INJURIES_HEAT_1999'
names(all)[names(all) == 'INJURIES.Hurricane.1999'] <- 'INJURIES_HURRICANE_1999'

names(all)[names(all) == 'INJURIES.Tropical Storm.2000'] <- 'INJURIES_TROPICAL_2000'
names(all)[names(all) == 'INJURIES.Wildfire.2000'] <- 'INJURIES_FIRE_2000'
names(all)[names(all) == 'INJURIES.Excessive Heat.2000'] <- 'INJURIES_HEAT_2000'
names(all)[names(all) == 'INJURIES.Hurricane.2000'] <- 'INJURIES_HURRICANE_2000'

names(all)[names(all) == 'INJURIES.Tropical Storm.2001'] <- 'INJURIES_TROPICAL_2001'
names(all)[names(all) == 'INJURIES.Wildfire.2001'] <- 'INJURIES_FIRE_2001'
names(all)[names(all) == 'INJURIES.Excessive Heat.2001'] <- 'INJURIES_HEAT_2001'
names(all)[names(all) == 'INJURIES.Hurricane.2001'] <- 'INJURIES_HURRICANE_2001'

names(all)[names(all) == 'INJURIES.Tropical Storm.2002'] <- 'INJURIES_TROPICAL_2002'
names(all)[names(all) == 'INJURIES.Wildfire.2002'] <- 'INJURIES_FIRE_2002'
names(all)[names(all) == 'INJURIES.Excessive Heat.2002'] <- 'INJURIES_HEAT_2002'
names(all)[names(all) == 'INJURIES.Hurricane.2002'] <- 'INJURIES_HURRICANE_2002'

names(all)[names(all) == 'INJURIES.Tropical Storm.2003'] <- 'INJURIES_TROPICAL_2003'
names(all)[names(all) == 'INJURIES.Wildfire.2003'] <- 'INJURIES_FIRE_2003'
names(all)[names(all) == 'INJURIES.Excessive Heat.2003'] <- 'INJURIES_HEAT_2003'
names(all)[names(all) == 'INJURIES.Hurricane.2003'] <- 'INJURIES_HURRICANE_2003'

names(all)[names(all) == 'INJURIES.Tropical Storm.2004'] <- 'INJURIES_TROPICAL_2004'
names(all)[names(all) == 'INJURIES.Wildfire.2004'] <- 'INJURIES_FIRE_2004'
names(all)[names(all) == 'INJURIES.Excessive Heat.2004'] <- 'INJURIES_HEAT_2004'
names(all)[names(all) == 'INJURIES.Hurricane.2004'] <- 'INJURIES_HURRICANE_2004'

names(all)[names(all) == 'INJURIES.Tropical Storm.2005'] <- 'INJURIES_TROPICAL_2005'
names(all)[names(all) == 'INJURIES.Wildfire.2005'] <- 'INJURIES_FIRE_2005'
names(all)[names(all) == 'INJURIES.Excessive Heat.2005'] <- 'INJURIES_HEAT_2005'
names(all)[names(all) == 'INJURIES.Hurricane.2005'] <- 'INJURIES_HURRICANE_2005'

names(all)[names(all) == 'INJURIES.Tropical Storm.2006'] <- 'INJURIES_TROPICAL_2006'
names(all)[names(all) == 'INJURIES.Wildfire.2006'] <- 'INJURIES_FIRE_2006'
names(all)[names(all) == 'INJURIES.Excessive Heat.2006'] <- 'INJURIES_HEAT_2006'
names(all)[names(all) == 'INJURIES.Hurricane.2006'] <- 'INJURIES_HURRICANE_2006'

names(all)[names(all) == 'INJURIES.Tropical Storm.2007'] <- 'INJURIES_TROPICAL_2007'
names(all)[names(all) == 'INJURIES.Wildfire.2007'] <- 'INJURIES_FIRE_2007'
names(all)[names(all) == 'INJURIES.Excessive Heat.2007'] <- 'INJURIES_HEAT_2007'
names(all)[names(all) == 'INJURIES.Hurricane.2007'] <- 'INJURIES_HURRICANE_2007'

names(all)[names(all) == 'INJURIES.Tropical Storm.2008'] <- 'INJURIES_TROPICAL_2008'
names(all)[names(all) == 'INJURIES.Wildfire.2008'] <- 'INJURIES_FIRE_2008'
names(all)[names(all) == 'INJURIES.Excessive Heat.2008'] <- 'INJURIES_HEAT_2008'
names(all)[names(all) == 'INJURIES.Hurricane.2008'] <- 'INJURIES_HURRICANE_2008'

names(all)[names(all) == 'INJURIES.Tropical Storm.2009'] <- 'INJURIES_TROPICAL_2009'
names(all)[names(all) == 'INJURIES.Wildfire.2009'] <- 'INJURIES_FIRE_2009'
names(all)[names(all) == 'INJURIES.Excessive Heat.2009'] <- 'INJURIES_HEAT_2009'
names(all)[names(all) == 'INJURIES.Hurricane.2009'] <- 'INJURIES_HURRICANE_2009'

names(all)[names(all) == 'INJURIES.Tropical Storm.2010'] <- 'INJURIES_TROPICAL_2010'
names(all)[names(all) == 'INJURIES.Wildfire.2010'] <- 'INJURIES_FIRE_2010'
names(all)[names(all) == 'INJURIES.Excessive Heat.2010'] <- 'INJURIES_HEAT_2010'
names(all)[names(all) == 'INJURIES.Hurricane.2010'] <- 'INJURIES_HURRICANE_2010'

names(all)[names(all) == 'INJURIES.Tropical Storm.2011'] <- 'INJURIES_TROPICAL_2011'
names(all)[names(all) == 'INJURIES.Wildfire.2011'] <- 'INJURIES_FIRE_2011'
names(all)[names(all) == 'INJURIES.Excessive Heat.2011'] <- 'INJURIES_HEAT_2011'
names(all)[names(all) == 'INJURIES.Hurricane.2011'] <- 'INJURIES_HURRICANE_2011'

names(all)[names(all) == 'INJURIES.Tropical Storm.2012'] <- 'INJURIES_TROPICAL_2012'
names(all)[names(all) == 'INJURIES.Wildfire.2012'] <- 'INJURIES_FIRE_2012'
names(all)[names(all) == 'INJURIES.Excessive Heat.2012'] <- 'INJURIES_HEAT_2012'
names(all)[names(all) == 'INJURIES.Hurricane.2012'] <- 'INJURIES_HURRICANE_2012'

names(all)[names(all) == 'INJURIES.Tropical Storm.2013'] <- 'INJURIES_TROPICAL_2013'
names(all)[names(all) == 'INJURIES.Wildfire.2013'] <- 'INJURIES_FIRE_2013'
names(all)[names(all) == 'INJURIES.Excessive Heat.2013'] <- 'INJURIES_HEAT_2013'
names(all)[names(all) == 'INJURIES.Hurricane.2013'] <- 'INJURIES_HURRICANE_2013'

names(all)[names(all) == 'INJURIES.Tropical Storm.2014'] <- 'INJURIES_TROPICAL_2014'
names(all)[names(all) == 'INJURIES.Wildfire.2014'] <- 'INJURIES_FIRE_2014'
names(all)[names(all) == 'INJURIES.Excessive Heat.2014'] <- 'INJURIES_HEAT_2014'
names(all)[names(all) == 'INJURIES.Hurricane.2014'] <- 'INJURIES_HURRICANE_2014'

names(all)[names(all) == 'INJURIES.Tropical Storm.2015'] <- 'INJURIES_TROPICAL_2015'
names(all)[names(all) == 'INJURIES.Wildfire.2015'] <- 'INJURIES_FIRE_2015'
names(all)[names(all) == 'INJURIES.Excessive Heat.2015'] <- 'INJURIES_HEAT_2015'
names(all)[names(all) == 'INJURIES.Hurricane.2015'] <- 'INJURIES_HURRICANE_2015'

names(all)[names(all) == 'INJURIES.Tropical Storm.2016'] <- 'INJURIES_TROPICAL_2016'
names(all)[names(all) == 'INJURIES.Wildfire.2016'] <- 'INJURIES_FIRE_2016'
names(all)[names(all) == 'INJURIES.Excessive Heat.2016'] <- 'INJURIES_HEAT_2016'
names(all)[names(all) == 'INJURIES.Hurricane.2016'] <- 'INJURIES_HURRICANE_2016'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.1996'] <- 'COUNT_TROPICAL_1996'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.1996'] <- 'COUNT_FIRE_1996'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.1996'] <- 'COUNT_HEAT_1996'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.1996'] <- 'COUNT_HURRICANE_1996'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.1997'] <- 'COUNT_TROPICAL_1997'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.1997'] <- 'COUNT_FIRE_1997'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.1997'] <- 'COUNT_HEAT_1997'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.1997'] <- 'COUNT_HURRICANE_1997'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.1998'] <- 'COUNT_TROPICAL_1998'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.1998'] <- 'COUNT_FIRE_1998'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.1998'] <- 'COUNT_HEAT_1998'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.1998'] <- 'COUNT_HURRICANE_1998'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.1999'] <- 'COUNT_TROPICAL_1999'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.1999'] <- 'COUNT_FIRE_1999'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.1999'] <- 'COUNT_HEAT_1999'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.1999'] <- 'COUNT_HURRICANE_1999'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2000'] <- 'COUNT_TROPICAL_2000'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2000'] <- 'COUNT_FIRE_2000'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2000'] <- 'COUNT_HEAT_2000'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2000'] <- 'COUNT_HURRICANE_2000'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2001'] <- 'COUNT_TROPICAL_2001'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2001'] <- 'COUNT_FIRE_2001'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2001'] <- 'COUNT_HEAT_2001'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2001'] <- 'COUNT_HURRICANE_2001'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2002'] <- 'COUNT_TROPICAL_2002'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2002'] <- 'COUNT_FIRE_2002'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2002'] <- 'COUNT_HEAT_2002'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2002'] <- 'COUNT_HURRICANE_2002'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2003'] <- 'COUNT_TROPICAL_2003'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2003'] <- 'COUNT_FIRE_2003'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2003'] <- 'COUNT_HEAT_2003'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2003'] <- 'COUNT_HURRICANE_2003'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2004'] <- 'COUNT_TROPICAL_2004'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2004'] <- 'COUNT_FIRE_2004'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2004'] <- 'COUNT_HEAT_2004'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2004'] <- 'COUNT_HURRICANE_2004'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2005'] <- 'COUNT_TROPICAL_2005'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2005'] <- 'COUNT_FIRE_2005'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2005'] <- 'COUNT_HEAT_2005'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2005'] <- 'COUNT_HURRICANE_2005'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2006'] <- 'COUNT_TROPICAL_2006'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2006'] <- 'COUNT_FIRE_2006'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2006'] <- 'COUNT_HEAT_2006'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2006'] <- 'COUNT_HURRICANE_2006'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2007'] <- 'COUNT_TROPICAL_2007'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2007'] <- 'COUNT_FIRE_2007'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2007'] <- 'COUNT_HEAT_2007'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2007'] <- 'COUNT_HURRICANE_2007'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2008'] <- 'COUNT_TROPICAL_2008'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2008'] <- 'COUNT_FIRE_2008'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2008'] <- 'COUNT_HEAT_2008'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2008'] <- 'COUNT_HURRICANE_2008'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2009'] <- 'COUNT_TROPICAL_2009'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2009'] <- 'COUNT_FIRE_2009'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2009'] <- 'COUNT_HEAT_2009'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2009'] <- 'COUNT_HURRICANE_2009'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2010'] <- 'COUNT_TROPICAL_2010'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2010'] <- 'COUNT_FIRE_2010'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2010'] <- 'COUNT_HEAT_2010'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2010'] <- 'COUNT_HURRICANE_2010'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2011'] <- 'COUNT_TROPICAL_2011'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2011'] <- 'COUNT_FIRE_2011'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2011'] <- 'COUNT_HEAT_2011'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2011'] <- 'COUNT_HURRICANE_2011'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2012'] <- 'COUNT_TROPICAL_2012'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2012'] <- 'COUNT_FIRE_2012'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2012'] <- 'COUNT_HEAT_2012'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2012'] <- 'COUNT_HURRICANE_2012'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2013'] <- 'COUNT_TROPICAL_2013'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2013'] <- 'COUNT_FIRE_2013'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2013'] <- 'COUNT_HEAT_2013'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2013'] <- 'COUNT_HURRICANE_2013'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2014'] <- 'COUNT_TROPICAL_2014'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2014'] <- 'COUNT_FIRE_2014'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2014'] <- 'COUNT_HEAT_2014'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2014'] <- 'COUNT_HURRICANE_2014'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2015'] <- 'COUNT_TROPICAL_2015'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2015'] <- 'COUNT_FIRE_2015'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2015'] <- 'COUNT_HEAT_2015'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2015'] <- 'COUNT_HURRICANE_2015'

names(all)[names(all) == 'COUNT_EVENTS.Tropical Storm.2016'] <- 'COUNT_TROPICAL_2016'
names(all)[names(all) == 'COUNT_EVENTS.Wildfire.2016'] <- 'COUNT_FIRE_2016'
names(all)[names(all) == 'COUNT_EVENTS.Excessive Heat.2016'] <- 'COUNT_HEAT_2016'
names(all)[names(all) == 'COUNT_EVENTS.Hurricane.2016'] <- 'COUNT_HURRICANE_2016'

# Summarize damage, injuries, death, and counts of weather events BY STATE AND YEAR
damage <- dat %>% 
  group_by(STATE, YEAR) %>% 
  summarize(DAMAGE_PROPERTY = sum(DAMAGE_PROPERTY_N))

injuries <- dat %>%
  group_by(STATE, YEAR) %>%
  summarize(INJURIES = sum(INJURIES))

deaths <- dat %>% 
  group_by(STATE, YEAR) %>% 
  summarize(DEATHS = sum(DEATHS))

counts <- dat %>%
  group_by(STATE, YEAR) %>%
  summarize(COUNT_EVENTS = n())

# Merge summary dataframes into one dataframe
all_totals <- merge(damage,deaths)
all_totals <- merge(all_totals,injuries)
all_totals <- merge(all_totals, counts)

# Reshape long data into wide data (EVENT_TYPE X Variables)
all_totals <- reshape(all_totals, idvar = "STATE", timevar = "YEAR", direction = "wide")

# Rename all variables to suitable name
names(all)[names(all) == 'DAMAGE_PROPERTY.1996'] <- 'DAMAGE_TOTAL_1996'
names(all)[names(all) == 'DAMAGE_PROPERTY.1997'] <- 'DAMAGE_TOTAL_1997'
names(all)[names(all) == 'DAMAGE_PROPERTY.1998'] <- 'DAMAGE_TOTAL_1998'
names(all)[names(all) == 'DAMAGE_PROPERTY.1999'] <- 'DAMAGE_TOTAL_1999'
names(all)[names(all) == 'DAMAGE_PROPERTY.2000'] <- 'DAMAGE_TOTAL_2000'
names(all)[names(all) == 'DAMAGE_PROPERTY.2001'] <- 'DAMAGE_TOTAL_2001'
names(all)[names(all) == 'DAMAGE_PROPERTY.2002'] <- 'DAMAGE_TOTAL_2002'
names(all)[names(all) == 'DAMAGE_PROPERTY.2003'] <- 'DAMAGE_TOTAL_2003'
names(all)[names(all) == 'DAMAGE_PROPERTY.2004'] <- 'DAMAGE_TOTAL_2004'
names(all)[names(all) == 'DAMAGE_PROPERTY.2005'] <- 'DAMAGE_TOTAL_2005'
names(all)[names(all) == 'DAMAGE_PROPERTY.2006'] <- 'DAMAGE_TOTAL_2006'
names(all)[names(all) == 'DAMAGE_PROPERTY.2007'] <- 'DAMAGE_TOTAL_2007'
names(all)[names(all) == 'DAMAGE_PROPERTY.2008'] <- 'DAMAGE_TOTAL_2008'
names(all)[names(all) == 'DAMAGE_PROPERTY.2009'] <- 'DAMAGE_TOTAL_2009'
names(all)[names(all) == 'DAMAGE_PROPERTY.2010'] <- 'DAMAGE_TOTAL_2010'
names(all)[names(all) == 'DAMAGE_PROPERTY.2011'] <- 'DAMAGE_TOTAL_2011'
names(all)[names(all) == 'DAMAGE_PROPERTY.2012'] <- 'DAMAGE_TOTAL_2012'
names(all)[names(all) == 'DAMAGE_PROPERTY.2013'] <- 'DAMAGE_TOTAL_2013'
names(all)[names(all) == 'DAMAGE_PROPERTY.2014'] <- 'DAMAGE_TOTAL_2014'
names(all)[names(all) == 'DAMAGE_PROPERTY.2015'] <- 'DAMAGE_TOTAL_2015'
names(all)[names(all) == 'DAMAGE_PROPERTY.2016'] <- 'DAMAGE_TOTAL_2016'

names(all)[names(all) == 'INJURIES.1996'] <- 'INJURIES_TOTAL_1996'
names(all)[names(all) == 'INJURIES.1997'] <- 'INJURIES_TOTAL_1997'
names(all)[names(all) == 'INJURIES.1998'] <- 'INJURIES_TOTAL_1998'
names(all)[names(all) == 'INJURIES.1999'] <- 'INJURIES_TOTAL_1999'
names(all)[names(all) == 'INJURIES.2000'] <- 'INJURIES_TOTAL_2000'
names(all)[names(all) == 'INJURIES.2001'] <- 'INJURIES_TOTAL_2001'
names(all)[names(all) == 'INJURIES.2002'] <- 'INJURIES_TOTAL_2002'
names(all)[names(all) == 'INJURIES.2003'] <- 'INJURIES_TOTAL_2003'
names(all)[names(all) == 'INJURIES.2004'] <- 'INJURIES_TOTAL_2004'
names(all)[names(all) == 'INJURIES.2005'] <- 'INJURIES_TOTAL_2005'
names(all)[names(all) == 'INJURIES.2006'] <- 'INJURIES_TOTAL_2006'
names(all)[names(all) == 'INJURIES.2007'] <- 'INJURIES_TOTAL_2007'
names(all)[names(all) == 'INJURIES.2008'] <- 'INJURIES_TOTAL_2008'
names(all)[names(all) == 'INJURIES.2009'] <- 'INJURIES_TOTAL_2009'
names(all)[names(all) == 'INJURIES.2010'] <- 'INJURIES_TOTAL_2010'
names(all)[names(all) == 'INJURIES.2011'] <- 'INJURIES_TOTAL_2011'
names(all)[names(all) == 'INJURIES.2012'] <- 'INJURIES_TOTAL_2012'
names(all)[names(all) == 'INJURIES.2013'] <- 'INJURIES_TOTAL_2013'
names(all)[names(all) == 'INJURIES.2014'] <- 'INJURIES_TOTAL_2014'
names(all)[names(all) == 'INJURIES.2015'] <- 'INJURIES_TOTAL_2015'
names(all)[names(all) == 'INJURIES.2016'] <- 'INJURIES_TOTAL_2016'

names(all)[names(all) == 'DEATHS.1996'] <- 'DEATHS_TOTAL_1996'
names(all)[names(all) == 'DEATHS.1997'] <- 'DEATHS_TOTAL_1997'
names(all)[names(all) == 'DEATHS.1998'] <- 'DEATHS_TOTAL_1998'
names(all)[names(all) == 'DEATHS.1999'] <- 'DEATHS_TOTAL_1999'
names(all)[names(all) == 'DEATHS.2000'] <- 'DEATHS_TOTAL_2000'
names(all)[names(all) == 'DEATHS.2001'] <- 'DEATHS_TOTAL_2001'
names(all)[names(all) == 'DEATHS.2002'] <- 'DEATHS_TOTAL_2002'
names(all)[names(all) == 'DEATHS.2003'] <- 'DEATHS_TOTAL_2003'
names(all)[names(all) == 'DEATHS.2004'] <- 'DEATHS_TOTAL_2004'
names(all)[names(all) == 'DEATHS.2005'] <- 'DEATHS_TOTAL_2005'
names(all)[names(all) == 'DEATHS.2006'] <- 'DEATHS_TOTAL_2006'
names(all)[names(all) == 'DEATHS.2007'] <- 'DEATHS_TOTAL_2007'
names(all)[names(all) == 'DEATHS.2008'] <- 'DEATHS_TOTAL_2008'
names(all)[names(all) == 'DEATHS.2009'] <- 'DEATHS_TOTAL_2009'
names(all)[names(all) == 'DEATHS.2010'] <- 'DEATHS_TOTAL_2010'
names(all)[names(all) == 'DEATHS.2011'] <- 'DEATHS_TOTAL_2011'
names(all)[names(all) == 'DEATHS.2012'] <- 'DEATHS_TOTAL_2012'
names(all)[names(all) == 'DEATHS.2013'] <- 'DEATHS_TOTAL_2013'
names(all)[names(all) == 'DEATHS.2014'] <- 'DEATHS_TOTAL_2014'
names(all)[names(all) == 'DEATHS.2015'] <- 'DEATHS_TOTAL_2015'
names(all)[names(all) == 'DEATHS.2016'] <- 'DEATHS_TOTAL_2016'

names(all)[names(all) == 'COUNT_EVENTS.1996'] <- 'COUNT_TOTAL_1996'
names(all)[names(all) == 'COUNT_EVENTS.1997'] <- 'COUNT_TOTAL_1997'
names(all)[names(all) == 'COUNT_EVENTS.1998'] <- 'COUNT_TOTAL_1998'
names(all)[names(all) == 'COUNT_EVENTS.1999'] <- 'COUNT_TOTAL_1999'
names(all)[names(all) == 'COUNT_EVENTS.2000'] <- 'COUNT_TOTAL_2000'
names(all)[names(all) == 'COUNT_EVENTS.2001'] <- 'COUNT_TOTAL_2001'
names(all)[names(all) == 'COUNT_EVENTS.2002'] <- 'COUNT_TOTAL_2002'
names(all)[names(all) == 'COUNT_EVENTS.2003'] <- 'COUNT_TOTAL_2003'
names(all)[names(all) == 'COUNT_EVENTS.2004'] <- 'COUNT_TOTAL_2004'
names(all)[names(all) == 'COUNT_EVENTS.2005'] <- 'COUNT_TOTAL_2005'
names(all)[names(all) == 'COUNT_EVENTS.2006'] <- 'COUNT_TOTAL_2006'
names(all)[names(all) == 'COUNT_EVENTS.2007'] <- 'COUNT_TOTAL_2007'
names(all)[names(all) == 'COUNT_EVENTS.2008'] <- 'COUNT_TOTAL_2008'
names(all)[names(all) == 'COUNT_EVENTS.2009'] <- 'COUNT_TOTAL_2009'
names(all)[names(all) == 'COUNT_EVENTS.2010'] <- 'COUNT_TOTAL_2010'
names(all)[names(all) == 'COUNT_EVENTS.2011'] <- 'COUNT_TOTAL_2011'
names(all)[names(all) == 'COUNT_EVENTS.2012'] <- 'COUNT_TOTAL_2012'
names(all)[names(all) == 'COUNT_EVENTS.2013'] <- 'COUNT_TOTAL_2013'
names(all)[names(all) == 'COUNT_EVENTS.2014'] <- 'COUNT_TOTAL_2014'
names(all)[names(all) == 'COUNT_EVENTS.2015'] <- 'COUNT_TOTAL_2015'
names(all)[names(all) == 'COUNT_EVENTS.2016'] <- 'COUNT_TOTAL_2016'
