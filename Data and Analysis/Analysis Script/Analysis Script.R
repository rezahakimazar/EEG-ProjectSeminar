#REGRESSIONS and ANOVA SCRIPT#


# Load necessary libraries
library(tidyverse)  
library(nlme)   
library(dplyr)
library(ggplot2)


#Load EEG Data
EEG_v1 <- read.csv("E:\\EEG Data\\Behavioural Data\\Original Data\\extracted_data_300-400_v1.csv")
EEG_v2 <- read.csv("E:\\EEG Data\\Behavioural Data\\Original Data\\extracted_data_300-400_v2.csv")
EEG_v3 <- read.csv("E:\\EEG Data\\Behavioural Data\\Original Data\\extracted_data_300-400_v3.csv")

# #Combine EEG Data
combined_EEG <- bind_rows(EEG_v1, EEG_v2, EEG_v3)

##############
combined_EEG <- combined_EEG %>%
  mutate(
    cond = case_when(
      Condition == 1 ~ -1,
      Condition == 2 ~ -1,
      Condition == 3 ~ 1,
      Condition == 4 ~ 1
    ),
    trial_type = case_when(
      Condition == 1 ~ 1,
      Condition == 2 ~ -1,
      Condition == 3 ~ 1,
      Condition == 4 ~ -1
    )
  )

# Run ANOVA
ANOVA <- aov(Value ~ cond * trial_type + Error(Subject / (trial_type * cond)), data = combined_EEG)
summary(ANOVA)

# Run Regression
regression <- lme(Value ~ cond * trial_type, random = ~ 1 | Subject, data = combined_EEG)
summary(regression)
intervals(regression)


#############Interaction Plot
ggplot(combined_EEG, aes(x = cond, y = Value, color = as.factor(trial_type), group = trial_type)) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  stat_summary(fun = mean, geom = "line", aes(group = trial_type), linetype = "solid") +
  stat_summary(fun.data = mean_cl_boot, geom = "errorbar", width = 0.3) +
  labs(title = "Interaction Plot of Condition and Trial Type on Value",
       x = "Condition", y = "Mean Value") +
  scale_x_continuous(breaks = c(-1, 1), labels = c("oddball", "reversal")) +
  scale_color_manual(values = c("-1" = "#800000", "1" = "#87CEEB"), labels = c("-1" = "rare", "1" = "common")) +
  theme_minimal()

# In the Paper
# describe the centering
# write the equation

###############Box Plot
combined_EEG$Type <- with(combined_EEG, ifelse(cond == -1, "Oddball", "Reversal"))
ggplot(combined_EEG, aes(x = interaction(cond, trial_type), y = Value, color = Type)) +
  geom_point(alpha = .1) +
  labs(title = "Point Plot of Value by Condition and Trial Type",
       x = "Condition × Trial Type", y = "Ampliture (µV)") +
  scale_x_discrete(labels = c("-1.-1" = "Oddball/Rare", "-1.1" = "Oddball/Common", 
                              "1.-1" = "Reversal/Rare", "1.1" = "Reversal/Common")) +
  scale_color_manual(values = c("Oddball" = "#800000", "Reversal" = "#87CEEB")) +
  theme_minimal()

###########################################
#Behavioral Analysis
behav_p1 <- read.csv("E:\\EEG Data\\EEG Data for the report\\eegalexa\\Behavioral Data\\OBCP_1.csv")
behav_p2 <- read.csv("E:\\EEG Data\\EEG Data for the report\\eegalexa\\Behavioral Data\\OBCP_2.csv")
behav_p3 <- read.csv("E:\\EEG Data\\EEG Data for the report\\eegalexa\\Behavioral Data\\OBCP_3.csv")
behav_p4 <- read.csv("E:\\EEG Data\\EEG Data for the report\\eegalexa\\Behavioral Data\\OBCP_4.csv")
behav_p5 <- read.csv("E:\\EEG Data\\EEG Data for the report\\eegalexa\\Behavioral Data\\OBCP_5.csv")


#combine behavioral data
combined_behav <- bind_rows(behav_p1, behav_p2, behav_p3, behav_p4, behav_p5)
# Step 1: Calculate the average value per subject in condition 2
average_value_condition2 <- EEG_v1 %>%
  filter(Condition == 2) %>%
  group_by(Subject) %>%
  summarize(avg_value = mean(Value, na.rm = TRUE))

# Step 2: Calculate the average ACC per subject when trial_number_related_to_surprise is 1
average_acc_surprise_1_2 <- combined_behav %>%
  filter(part %in% c("oddball1", "oddball2") & trial_number_related_to_surprise == 1) %>%
  group_by(id) %>%
  summarize(avg_ACC = mean(ACC, na.rm = TRUE))

# Step 3: Merge the two summaries into a single data frame
merged_averages_OB <- merge(average_value_condition2, average_acc_surprise_1_2, by.x = "Subject", by.y = "id")

# Calculate the correlation
correlation_OB_ACC <- cor(merged_averages_OB$avg_value, merged_averages_OB$avg_ACC, use = "complete.obs")

# Print the correlation
print(correlation_OB_ACC)

# Fit a linear regression model
model <- lm(avg_ACC ~ avg_value, data = merged_averages_OB)

# Create the scatter plot with ggplot2
ggplot(merged_averages_OB, aes(x = avg_value, y = avg_ACC)) +
  geom_point() +  # Add points
  geom_smooth(method = "lm", color = "#800000") +  # Add regression line
  labs(
    x = "Average P300 magnitude in OB Trials",
    y = "Average Accuracy in OB+1 Trials",
    title = "Correlation between P300 magnitude and Accuracy in OB condition"
  ) +
  theme_minimal()  # Apply minimal theme

###################

print(paste("Correlation coefficient:", round(correlation_OB_ACC, 2)))

#Reversal Learning
# Step 1: Calculate the average value per subject in condition 4
average_value_condition4 <- EEG_v1 %>%
  filter(Condition == 4) %>%
  group_by(Subject) %>%
  summarize(avg_value = mean(Value, na.rm = TRUE))

# Step 2: Calculate the average ACC per subject when trial_number_related_to_surprise is 1
average_acc_surprise_1_4 <- combined_behav %>%
  filter(part == "changepoint" & trial_number_related_to_surprise == 1) %>%
  group_by(id) %>%
  summarize(avg_ACC = mean(ACC, na.rm = TRUE))

# Step 3: Merge the two summaries into a single data frame
merged_averages_RL <- merge(average_value_condition4, average_acc_surprise_1_4, by.x = "Subject", by.y = "id")

# Calculate the correlation
correlation_RL_ACC <- cor(merged_averages_RL$avg_value, merged_averages_RL$avg_ACC, use = "complete.obs")

# Print the correlation
print(correlation_RL_ACC)

# Fit a linear regression model
model <- lm(avg_ACC ~ avg_value, data = merged_averages_RL)


# Print the correlation coefficient
print(paste("Correlation coefficient:", round(correlation_RL_ACC, 2)))
###############
# Assuming merged_averages_RL is your dataframe
# Create the scatter plot with ggplot2
ggplot(merged_averages_RL, aes(x = avg_value, y = avg_ACC)) +
  geom_point() +  # Add points
  geom_smooth(method = "lm", color = "#87CEEB") +  # Add regression line
  labs(
    x = "Average P300 magnitude in CP Trials",
    y = "Average Accuracy in CP+1 Trials",
    title = "Correlation between P300 magnitude and Accuracy in RL condition"
  ) +
  theme_minimal()  # Apply minimal theme

###################ta inja

#  We only find an association between magnitude and accuracy in RL, not in oddball. This stands in contrast to Nassar, 2019 finding

## q2: higher P300 -\> faster RT in surprise + 1 trial?

#Oddball

# Step 2: Calculate the average ACC per subject when trial_number_related_to_surprise is 1
average_RT_surprise_1_2 <- combined_behav %>%
  filter(part %in% c("oddball1", "oddball2") & trial_number_related_to_surprise == 1) %>%
  group_by(id) %>%
  summarize(avg_RT = mean(RT, na.rm = TRUE))

# Step 3: Merge the two summaries into a single data frame
merged_averages_OB_RT <- merge(average_value_condition2, average_RT_surprise_1_2, by.x = "Subject", by.y = "id")

# Calculate the correlation
correlation_RT_OB <- cor(merged_averages_OB_RT$avg_value, merged_averages_OB_RT$avg_RT, use = "complete.obs")

# Print the correlation
print(correlation_RT_OB)

# Fit a linear regression model
model <- lm(avg_RT ~ avg_value, data = merged_averages_OB_RT)

# Plot the scatter plot
plot(merged_averages_OB$avg_value, merged_averages_OB_RT$avg_RT,
     xlab = "Average P300 magnitude in OB Trials",
     ylab = "Average RT in OB+1 Trials",
     main = "Correlation between P300 magnitude and RT in OB condition")

# Add the regression line
abline(model, col = "red")

# Print the correlation coefficient
print(paste("Correlation coefficient:", round(correlation_RT_OB, 2)))


#For RL

# Step 2: Calculate the average ACC per subject when trial_number_related_to_surprise is 1
average_RT_surprise_1_4 <- combined_behav %>%
  filter(part == "changepoint" & trial_number_related_to_surprise == 1) %>%  group_by(id) %>%
  summarize(avg_RT = mean(RT, na.rm = TRUE))

# Step 3: Merge the two summaries into a single data frame
merged_averages_RL_RT <- merge(average_value_condition4, average_RT_surprise_1_4, by.x = "Subject", by.y = "id")

# Calculate the correlation
correlation_RT_RL <- cor(merged_averages_RL_RT$avg_value, merged_averages_RL_RT$avg_RT, use = "complete.obs")

# Print the correlation
print(correlation_RT_RL)

# Fit a linear regression model
model <- lm(avg_RT ~ avg_value, data = merged_averages_RL_RT)

# Plot the scatter plot
plot(merged_averages_RL_RT$avg_value, merged_averages_RL_RT$avg_RT,
     xlab = "Average P300 magnitude in OB Trials",
     ylab = "Average RT in OB+1 Trials",
     main = "Correlation between P300 magnitude and RT in OB condition")

# Add the regression line
abline(model, col = "red")

# Print the correlation coefficient
print(paste("Correlation coefficient:", round(correlation_RT_RL, 2)))



