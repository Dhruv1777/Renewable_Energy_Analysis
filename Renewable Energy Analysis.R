#Standard multivariate regression

#Regression dataset = new_dataframe
final_data <- read.csv("penultimate_df_for_renewable_energy_regression.csv")


final_data_subset <- subset(final_data, select = -c(X2020_private_investment_1, X2020_gini_index_1, X))


final_data_subset_clean <- na.omit(final_data_subset)


#Regression:
set.seed(123)
model <- lm(X2020_renew_energy_1 ~ X2020_access_to_electrcity_1 + X2020_protected_areas_1 + 
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
  labs(title = "Varaible Co-efficients",
       x = "Predictor Variables",
       y = "Coefficient Value") +
  theme_minimal()



##################################################################################################################
#Checking for multicollinearity


library(usdm)

vif_values <- vif(final_data_subset_clean[, c("X2020_access_to_electrcity_1", "X2020_protected_areas_1",
                                              "X2020_gdp_current_1", "X2020_gdp_growth_1",
                                              "X2020_gdp_per_capita_1", "X2020_gdp_per_capita_growth_1")])
print(vif_values)



#######################################################################################################################################################
#Ridge regression, possibly works better than lasso as 3 out of 6 variables are properly statitically significant and one is partially

library(glmnet)

#Extract response variable
y <- final_data_subset_clean$X2020_renew_energy_1

#Extract predictors and convert to matrix
X <- as.matrix(final_data_subset_clean[,c("X2020_access_to_electrcity_1", "X2020_protected_areas_1", "X2020_gdp_current_1", "X2020_gdp_growth_1", "X2020_gdp_per_capita_1", "X2020_gdp_per_capita_growth_1")])

set.seed(123) 

#Perform ridge regression with cross-validation
cv_ridge <- cv.glmnet(X, y, alpha = 0)
cv_ridge

#Plot to visualize cross-validation results and the chosen lambda
plot(cv_ridge)

#Coefficients at best lambda
ridge_coeffs <- coef(cv_ridge, s = "lambda.min")
print(ridge_coeffs)

#Predictions at best lambda
predictions <- predict(cv_ridge, newx = X, s = "lambda.min")
predictions

#Calculating performance metrics
#Mean Squared Error (MSE)
mse <- mean((y - predictions)^2)
print(paste("Mean Squared Error (MSE):", mse))

#RMSE and MAE
rmse <- sqrt(mse)
print(paste("Root Mean Squared Error (RMSE):", rmse))

mae <- mean(abs(y - predictions))
print(paste("Mean Absolute Error (MAE):", mae))

#R-squared calculation
y_mean <- mean(y)
sst <- sum((y - y_mean)^2)
ssr <- sum((y - predictions)^2)
r_squared <- 1 - (ssr / sst)
print(paste("R-squared:", r_squared))




#check for Heteroscedasticity
#Calculate residuals
residuals_ridge <- as.vector(y) - as.vector(predictions)

#Breusch-Pagan test
library(lmtest)
bp_test <- bptest(residuals_ridge ~ as.vector(predictions))
print(bp_test)

#Goldfeld-Quandt test
gq_test <- gqtest(residuals_ridge ~ as.vector(predictions))
print(gq_test)

#Unable to prove Heteroscedasticity

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



