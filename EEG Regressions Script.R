#REGRESSIONS SCRIPT#
library(dplyr)
library(ggplot2)
library(tidyverse)
#Load EEG Data
EEG_v1 <- read.csv("E:\\EEG Data\\Behavioural Data\\Original Data\\extracted_data_300-400_v1.csv")
EEG_v2 <- read.csv("E:\\EEG Data\\Behavioural Data\\Original Data\\extracted_data_300-400_v2.csv")
EEG_v3 <- read.csv("E:\\EEG Data\\Behavioural Data\\Original Data\\extracted_data_300-400_v3.csv")

# #Combine EEG Data
combined_EEG <- bind_rows(EEG_v1, EEG_v2, EEG_v3)


#################################3
# Data frame for Oddballs and Commons
oddballs_df <- combined_EEG[combined_EEG$Condition %in% c(1, 2), c("Condition", "Value")]
reversals_df <- combined_EEG[combined_EEG$Condition %in% c(3, 4), c("Condition", "Value")]

######################oddball rare regression
oddballs_rare_df <- combined_EEG[combined_EEG$Condition %in% c(2, 2), c("Condition", "Value")]
# Run a linear regression with Values as the dependent variable and Condition as the independent variable
or_regression_model <- lm(Value ~ Condition, data = oddballs_rare_df)
# Summarize the regression model
summary(or_regression_model)

######################oddball common regression
oddballs_common_df <- combined_EEG[combined_EEG$Condition %in% c(1, 1), c("Condition", "Value")]
# Run a linear regression with Values as the dependent variable and Condition as the independent variable
oc_regression_model <- lm(Value ~ Condition, data = oddballs_common_df)
# Summarize the regression model
summary(oc_regression_model)

######################reversal common regression
reversals_common_df <- combined_EEG[combined_EEG$Condition %in% c(3, 3), c("Condition", "Value")]
# Run a linear regression with Values as the dependent variable and Condition as the independent variable
rc_regression_model <- lm(Value ~ Condition, data = reversals_common_df)
# Summarize the regression model
summary(rc_regression_model)

######################reversal rare regression
reversals_rare_df <- combined_EEG[combined_EEG$Condition %in% c(4, 4), c("Condition", "Value")]
# Run a linear regression with Values as the dependent variable and Condition as the independent variable
rr_regression_model <- lm(Value ~ Condition, data = reversals_rare_df)
# Summarize the regression model
summary(rr_regression_model)

#####################oddball regression
# Run a linear regression with Values as the dependent variable and Condition as the independent variable
ob_regression_model <- lm(Value ~ Condition, data = oddballs_df)
# Summarize the regression model
summary(ob_regression_model)

#####################reversals regression
# Run a linear regression with Values as the dependent variable and Condition as the independent variable
rl_regression_model <- lm(Value ~ Condition, data = reversals_df)
# Summarize the regression model
summary(rl_regression_model)

#####################OPTIONAL VISUALIZATIONS########################
# COMMON AND RARE IN REVERSAL LEARNING
reversals_df$Condition <- factor(reversals_df$Condition, levels = c(3, 4), labels = c("Common", "Rare"))
ggplot(reversals_df, aes(x = Condition, y = Value)) +
  geom_boxplot() +
  stat_summary(fun = "mean", geom = "point", shape = 23, size = 3, fill = "red") + 
  geom_smooth(method = "lm", se = FALSE, aes(group = 1), color = "blue") +
  theme_minimal() +
  labs(title = "How Common and Rare Reversal Learnings Trials Predict the EEG Amplitude",
       x = "Reversal Learning Condition",
       y = "Amplitude")

# COMMON AND RARE IN ODDBALL
oddballs_df$Condition <- factor(oddballs_df$Condition, levels = c(1, 2), labels = c("Common", "Rare"))
ggplot(oddballs_df, aes(x = Condition, y = Value)) +
  geom_boxplot() +
  stat_summary(fun = "mean", geom = "point", shape = 23, size = 3, fill = "red") + 
  geom_smooth(method = "lm", se = FALSE, aes(group = 1), color = "blue") +
  theme_minimal() +
  labs(title = "How Common and Rare Oddball Trials Predict the EEG Amplitude",
       x = "Oddball Condition",
       y = "Amplitude")



