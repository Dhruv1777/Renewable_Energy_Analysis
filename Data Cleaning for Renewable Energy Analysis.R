library(tidyverse)

setwd("C:/Users/Dhruv/Desktop/(2) World Bank Datasets/renewable energy")
renew_energy_1 <- read.csv("Renewable energy consumption (% of total final energy consumption) - API_EG.FEC.RNEW.ZS_DS2_en_csv_v2_5729390.csv")
access_to_electrcity_1 <- read.csv("Access to electricity (% of population) - API_EG.ELC.ACCS.ZS_DS2_en_csv_v2_5729318.csv")
protected_areas_1 <- read.csv("Terrestrial and marine protected areas (% of total territorial area) - API_ER.PTD.TOTL.ZS_DS2_en_csv_v2_5734623.csv")
private_investment_1 <- read.csv("Investment in energy with private participation (current US$) - API_IE.PPI.ENGY.CD_DS2_en_csv_v2_5734645.csv")
#only 60ish in this
gini_index_1 <- read.csv("Gini index - API_SI.POV.GINI_DS2_en_csv_v2_5728899 (1).csv")
#only 50ish
gdp_current_1 <- read.csv("GDP (current US$) - API_NY.GDP.MKTP.CD_DS2_en_csv_v2_5728855.csv")
#257
gdp_growth_1 <- read.csv("GDP growth (annual %) - API_NY.GDP.MKTP.KD.ZG_DS2_en_csv_v2_5728939.csv")
#256
gdp_per_capita_1 <- read.csv("GDP per capita (current US$) - API_NY.GDP.PCAP.CD_DS2_en_csv_v2_5728786.csv")
#258
gdp_per_capita_growth_1 <- read.csv("GDP per capita growth (annual %) - API_NY.GDP.PCAP.KD.ZG_DS2_en_csv_v2_5695126.csv")
#255


#check if the column is availible in all datasets
datasets <- list(renew_energy_1, access_to_electrcity_1, protected_areas_1, private_investment_1, gini_index_1,
                 gdp_current_1, gdp_growth_1, gdp_per_capita_1, gdp_per_capita_growth_1)
column_name <- "Country.Name"

if (!all(sapply(datasets, function(x) column_name %in% names(x)))) {
  stop("Column not found in all datasets")
}

#check if the column is identical
are_identical <- TRUE
for (i in 2:length(datasets)) {
  if (!identical(datasets[[i - 1]][[column_name]], datasets[[i]][[column_name]])) {
    are_identical <- FALSE
    break
  }
}

if (are_identical) {
  cat("The columns are identical across datasets.\n")
} else {
  cat("The columns are not identical across datasets.\n")
}
#The columns are identical across datasets.

###############################################################################################################################

#getting proper country names
process_dataset <- function(df) {
  # excluding values
  exclude <- exclude <- c("Africa Eastern and Southern", "Africa Western and Central", "Arab World", "Antigua and Barbuda", "Bosnia and Herzegovina", "Central Europe and the Baltics", "Cabo Verde", "Caribbean small states", "East Asia & Pacific (excluding high income)", "Early-demographic dividend", "East Asia & Pacific", "Europe & Central Asia (excluding high income)", "Europe & Central Asia", "Euro area", "European Union", "Fragile and conflict affected situations", "Gambia, The", "High income", "Heavily indebted poor countries (HIPC)", "IBRD only", "IDA & IBRD total", "IDA total", "IDA blend", "IDA only", "Not classified", "St. Kitts and Nevis", "Latin America & Caribbean (excluding high income)", "Latin America & Caribbean", "Least developed countries: UN classification", "Low income", "Lower middle income", "Low & middle income", "Late-demographic dividend", "Macao SAR, China", "St. Martin (French part)", "Middle East & North Africa", "Middle income", "Middle East & North Africa (excluding high income)", "North America", "OECD members", "Other small states", "Pre-demographic dividend", "Pacific island small states", "Post-demographic dividend", "South Asia", "Sub-Saharan Africa (excluding high income)", "Sub-Saharan Africa", "Small states", "Sao Tome and Principe", "Sint Maarten (Dutch part)", "Turks and Caicos Islands", "East Asia & Pacific (IDA & IBRD countries)", "Europe & Central Asia (IDA & IBRD countries)", "Latin America & the Caribbean (IDA & IBRD countries)", "Middle East & North Africa (IDA & IBRD countries)", "South Asia (IDA & IBRD)", "Sub-Saharan Africa (IDA & IBRD countries)", "Upper middle income", "St. Vincent and the Grenadines", "Virgin Islands (U.S.)", "World")
  df <- df[!(df$Country.Name %in% exclude), ]
  
  # re-naming values
  renaming_values <- c("Bahamas, The" = "Bahamas", "Brunei Darussalam" = "Brunei", "Congo, Rep." = "Congo - Brazzaville", "Congo, Dem. Rep." = "Congo - Kinshasa", "Curacao" = "Curaçao", "Cote d'Ivoire" = "Côte d’Ivoire", "Egypt, Arab Rep." = "Egypt", "Hong Kong SAR, China" = "Hong Kong SAR China", "Iran, Islamic Rep." = "Iran", "Kyrgyz Republic" = "Kyrgyzstan", "Lao PDR" = "Laos", "Micronesia, Fed. Sts." = "Micronesia (Federated States of)", "Myanmar" = "Myanmar (Burma)", "Korea, Dem. People's Rep." = "North Korea", "West Bank and Gaza" = "Palestinian Territories", "Russian Federation" = "Russia", "Slovak Republic" = "Slovakia", "Korea, Rep." = "South Korea", "Syrian Arab Republic" = "Syria", "Trinidad and Tobago" = "Trinidad & Tobago", "Turkiye" = "Turkey", "Venezuela, RB" = "Venezuela", "Yemen, Rep." = "Yemen")
  df <- df %>% mutate(Country.Name = recode(Country.Name, !!!renaming_values))
  
  return(df)
}

processed_datasets <- lapply(datasets, process_dataset)


list_names <- c("renew_energy_1", "access_to_electrcity_1", "protected_areas_1", "private_investment_1", "gini_index_1",
                "gdp_current_1", "gdp_growth_1", "gdp_per_capita_1", "gdp_per_capita_growth_1")

for (i in seq_along(processed_datasets)) {
  assign(list_names[i], processed_datasets[[i]], envir = globalenv())
}

##########################################################################################################################
# Start the new dataframe with the common "Country.Name" column from the processed datasets
new_dataframe <- data.frame(Country.Name = processed_datasets[[1]]$Country.Name)

# Loop through the processed datasets and merge the 'X2020' column
for (i in seq_along(processed_datasets)) {
  dataset <- processed_datasets[[i]]
  column_name <- paste0('X2020_', list_names[i]) 
  new_dataframe[[column_name]] <- dataset$X2020
}

# new_dataframe now contains the "Country.Name" column and 9 other columns named 'X2000_renew_energy_1', etc.

view(new_dataframe)

write.csv(new_dataframe, "penultimate_df_for_renewable_energy_regression.csv")
write.csv(protected_areas_1, "protected_areas_modified.csv")