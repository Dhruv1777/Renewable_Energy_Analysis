setwd("C:/Users/Dhruv/Desktop/(2) World Bank Datasets/renewable energy/V2")
library(tidyverse)
#Standard multivariate regre

#Regression dataset = new_dataframe
final_data <- read.csv("penultimate_df_for_renewable_energy_regression_v2.csv")


final_data_subset <- subset(final_data, select = -c(X2020_private_investment_1, X2020_gini_index_1, X))


final_data_subset_clean <- na.omit(final_data_subset)


#Regression:
set.seed(123)
model <- lm(X2020_renew_energy_1 ~ X2020_access_to_electrcity_1 +
              X2020_gdp_current_1 + X2020_gdp_growth_1 + 
              X2020_gdp_per_capita_1 + X2020_gdp_per_capita_growth_1, 
            data = final_data_subset_clean)

summary(model)



#VIZ 
#Extract coefficients from model
model_coeffs <- coef(model)

#Create a data frame 
coeffs_df <- data.frame(
  Predictor = names(model_coeffs),
  Coefficient = unname(model_coeffs)
)

#Filter out the intercept
coeffs_df_no_intercept <- coeffs_df[coeffs_df$Predictor != "(Intercept)", ]

ggplot(coeffs_df_no_intercept, aes(x = reorder(Predictor, Coefficient), y = Coefficient, fill = Coefficient)) +
  geom_bar(stat = "identity") +
  coord_flip() +  # Flip the axes to make it horizontal; easier to read
  scale_fill_gradient2(low = "darkred", mid = "cyan", high = "darkgreen", midpoint = 0) +
  labs(title = "Variable Co-efficients",
       x = "Predictor Variables",
       y = "Coefficient Value") +
  theme_minimal()



##################################################################################################################
#Checking for multicollinearity


library(usdm)

vif_values <- vif(final_data_subset_clean[, c("X2020_access_to_electrcity_1",
                                              "X2020_gdp_current_1", "X2020_gdp_growth_1",
                                              "X2020_gdp_per_capita_1", "X2020_gdp_per_capita_growth_1")])
vif_values



#######################################################################################################################################################
#Ridge regression, possibly works better than lasso as 3 out of 6 variables are properly statitically significant and one is partially

library(glmnet)

#Extract response variable
y <- final_data_subset_clean$X2020_renew_energy_1

#Extract predictors and convert to matrix
X <- as.matrix(final_data_subset_clean[,c("X2020_access_to_electrcity_1", "X2020_gdp_current_1", 
                                          "X2020_gdp_growth_1", "X2020_gdp_per_capita_1", "X2020_gdp_per_capita_growth_1")])

set.seed(123) 

#Perform ridge regression with cross-validation
cv_ridge <- cv.glmnet(X, y, alpha = 0)
cv_ridge

#Coefficients at best lambda
ridge_coeffs <- coef(cv_ridge, s = "lambda.min")
print(ridge_coeffs)

#Predictions at best lambda
predictions <- predict(cv_ridge, newx = X, s = "lambda.min")
predictions

#Calculating performance metrics for ridge model
#Mean Squared Error (MSE)
mse <- mean((y - predictions)^2)
mse
#[1] 365.604

#RMSE and MAE
rmse <- sqrt(mse)
rmse
#[1] 19.12078

mae <- mean(abs(y - predictions))
mae
#[1] 15.25953

#R-squared calculation
y_mean <- mean(y)
sst <- sum((y - y_mean)^2)
ssr <- sum((y - predictions)^2)
r_squared <- 1 - (ssr / sst)
print(paste("R-squared:", r_squared))
#[1] "R-squared: 0.530473681265283"

#Comparing these metrics to the multivariate ones:

#R-squared - 
#Standard Multivariate linear model: 52.9%
#Ridge Model: 53.04%
#Ridge model perfoprms slightly better

#Calculating MSE, RMSE, MAE for multivariate:
#getting actual values:
actual_values <- final_data_subset_clean$X2020_renew_energy_1
actual_values

predictions_linear <- predict(model, final_data_subset_clean)
mse_linear <- mean((actual_values - predictions_linear)^2)
mse_linear
#[1] 357.1079

rmse_linear <- sqrt(mse_linear)
rmse_linear
#[1] 18.8973

mae_linear <- mean(abs(actual_values - predictions_linear))
mae_linear
#[1] 14.92236

#####################################################################################################################################################################
#Viz
#Convert the sparse matrix to a regular matrix, then to a data frame
coeffs_df <- as.data.frame(as.matrix(ridge_coeffs))

#Add the predictor names
coeffs_df$Predictor <- rownames(coeffs_df)
names(coeffs_df)[1] <- 'Coefficient'

#Filter out the intercept 
coeffs_df_no_intercept <- coeffs_df[coeffs_df$Predictor != "(Intercept)", ]

#Plot
ggplot(coeffs_df_no_intercept, aes(x = reorder(Predictor, Coefficient), y = Coefficient, fill = Coefficient)) +
  geom_bar(stat = "identity") +
  coord_flip() +  # Flip the axes to make it horizontal; easier to read
  scale_fill_gradient2(low = "darkred", mid = "cyan", high = "darkgreen", midpoint = 0) +
  labs(title = "Ridge Regression Coefficients",
       x = "Predictor Variables",
       y = "Coefficient Value") +
  theme_minimal()



