## Project Overview 
This project aims to create regression and predictive models to explain the relationship between the percentage of renewable energy consumption across countries worldwide in 2020 and the chosen predictors.


## Data Source
The data was sourced and final dataset made by downloading multiple files (one for each predictor variable and one for the dependent variable) from the World Bank website: https://data.worldbank.org/indicator. 

These datasets were all licensed under the the CC BY 4.0 license (https://creativecommons.org/licenses/by/4.0/).

After sourcing, extensive data cleaning was performed to prepare the data for this analysis. This included manually removing 'aggregation' in the World Bank data (in addition to country names, the files included aggregate statistics such as for "East Asia & Pacific" etc) as I wanted to focus exclusively on all the countries of the world. 

Formatting transformations were employed to make the dataset usable for regression analysis. It is given here as "cleaned_df_for_renewable_energy_regression" though some further filtering and other such operations were performed in my ‘Analysis’ R file

As such, this constitutes a derivative work and is also shared under the CC BY 4.0 license.
