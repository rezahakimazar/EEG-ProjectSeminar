library(tidyverse)  
library(nlme)   
library(dplyr)
library(ggplot2)
library(broom)
#Behavioral Analysis
behav_p1 <- read.csv("E:\\EEG Data\\EEG Data for the report\\eegalexa\\Behavioral Data\\OBCP_1.csv")
behav_p2 <- read.csv("E:\\EEG Data\\EEG Data for the report\\eegalexa\\Behavioral Data\\OBCP_2.csv")
behav_p3 <- read.csv("E:\\EEG Data\\EEG Data for the report\\eegalexa\\Behavioral Data\\OBCP_3.csv")
behav_p4 <- read.csv("E:\\EEG Data\\EEG Data for the report\\eegalexa\\Behavioral Data\\OBCP_4.csv")
behav_p5 <- read.csv("E:\\EEG Data\\EEG Data for the report\\eegalexa\\Behavioral Data\\OBCP_5.csv")

#combine behavioral data
combined_behav <- bind_rows(behav_p1, behav_p2, behav_p3, behav_p4, behav_p5)

#remove unnecessary data (practice)
part_to_remove <- c("association1", "association1_timepres", "association2", 
                    "association2_timepres", "changepoint_prac", "oddball_prac")

combined_behav <- combined_behav %>%
  filter(!(part %in% part_to_remove)) %>%
  filter(!(block %in% c("practice_no_timeout", "practice")))

# behavioral analysis (descriptives)

#group the conditions

combined_behav <- combined_behav %>%
  mutate(grouped_part = case_when(
    part %in% c("oddball1", "oddball2") ~ "oddball",
    part == "changepoint" ~ "changepoint",
    TRUE ~ part
  ))

## mean RT and ACC per participant + condition
changepoint_mean <- combined_behav %>%
  group_by(id) %>%
  filter(grouped_part == "changepoint") %>%
  summarize(mean_ACC = mean(ACC),
            sd_ACC = sd(ACC),
            mean_RT = mean(RT, na.rm = T),
            sd_RT = sd(RT, na.rm = T))

# Calculate the mean ACC for part = "oddball1" or part = "oddball2"
oddball_mean <- combined_behav %>%
  group_by(id) %>%
  filter(part %in% c("oddball1", "oddball2")) %>%
  summarize(mean_ACC = mean(ACC),
            sd_ACC = sd(ACC),
            mean_RT = mean(RT, na.rm = T),
            sd_RT = sd(RT, na.rm = T))

behav_descriptives <- bind_rows(changepoint_mean, oddball_mean, .id = "part")

# no participant seems to be completely off  

## mean RT and ACC of 4 trial kinds

combined_behav <- combined_behav %>%
  mutate(trial_kind = ifelse(part == "changepoint" & surprise == "switch", "RL_Rare",
                             ifelse(part %in% c("oddball1", "oddball2") & trans_type == "oddball", "OB_Rare",
                                    ifelse(part == "changepoint" & surprise == "steady", "RL_Common", ifelse(part %in% c("oddball1", "oddball2") & trans_type == "regular", "OB_Common", NA)))))

means_per_trial_kind <- combined_behav %>%
  group_by(trial_kind) %>%
  summarize(
    mean_ACC = mean(ACC),
    sd_ACC = sd(ACC),
    mean_RT = mean(RT, na.rm = T),
    sd_RT = sd(RT, na.rm = T))

# as expected 

## mean RT and ACC in OB +/-1 and CP +/-1

combined_behav <- combined_behav %>%
  mutate(
    trial_number_related_to_surprise = ifelse(part == "changepoint" & surprise == "switch", 0,
                                              ifelse(part %in% c("oddball1", "oddball2") & trans_type == "oddball", 0, NA))
  )

# Adjust the values before and after each 0 entry
combined_behav <- combined_behav %>%
  mutate(
    trial_number_related_to_surprise = case_when(
      #lag(trial_number_related_to_surprise, 3) == 0 ~ 3,
      lead(trial_number_related_to_surprise, 1) == 0 ~ -1,
      lag(trial_number_related_to_surprise, 1) == 0 ~ 1,
      #lag(trial_number_related_to_surprise, 2) == 0 ~ 2,
      TRUE ~ trial_number_related_to_surprise
    )
  )


# perhabs RT is different between them - CP/OB +1 could be slower
means_per_trial_number <- combined_behav %>%
  filter(!is.na(trial_number_related_to_surprise)) %>%
  group_by(part, trial_number_related_to_surprise) %>%
  summarize(
    mean_RT = mean(RT, na.rm = TRUE),
    sd_RT = sd(RT, na.rm = TRUE),
    mean_ACC = mean(ACC),
    sd_ACC = sd(ACC),
  )

# possible: t-test between accuracy 

# behavioral analysis: learning

#Question: Significantly lower accuracy in Surprise + 1 trial than in Surprise - 1 Trial? If no significant difference, we can talk about learning.

t_test_behav_plusminus1 <- combined_behav %>%
  filter(trial_number_related_to_surprise %in% c(-1, 1)) %>%
  group_by(grouped_part) %>%
  do(tidy(t.test(RT ~ trial_number_related_to_surprise, data = .)))

# non significant in both conditions -> there was learning in both conditions!
#plot

means_per_trial_number <- combined_behav %>%
  filter(trial_number_related_to_surprise %in% c(-1, 0, 1)) %>%
  group_by(grouped_part, trial_number_related_to_surprise) %>%
  summarize(
    mean_ACC = mean(ACC, na.rm = TRUE),
    sd_ACC = sd(ACC, na.rm = TRUE)
  )

ggplot(means_per_trial_number, aes(x = as.factor(trial_number_related_to_surprise), y = mean_ACC, color = grouped_part, group = grouped_part)) +
  geom_line() +
  geom_point() +
  geom_errorbar(aes(ymin = mean_ACC - sd_ACC, ymax = mean_ACC + sd_ACC), width = 0.1) +
  labs(title = "Mean Accuracy by Trial Number Related to Surprise",
       x = "Trial Number Related to Surprise",
       y = "Mean Accuracy",
       color = "Group") +
  theme_minimal()


# EEG + behavioral analysis

## q1: higher P300 -\> more accurate in surprise + 1 trial?

#Hyp.: Relation P300 - Accuracy in both conditions

#P300 indexes learning, surprise trial offers opportunity to learn In both RL and OB condition. As Nassar, 2019 identified P300 as a signal being differentially interpreted downstream, P300 not specifically related to updating per se (as in RL)

#condition 2 = OB rare condition 4 = RV rare

#For OB


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

print(paste("Correlation coefficient:", round(correlation_OB_ACC, 2)))


#For RL
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

# Print the correlation coefficient
print(paste("Correlation coefficient:", round(correlation_RL_ACC, 2)))

#-\> We only find an association between magnitude and accuracy in RL, not in oddball. This stands in contrast to Nassar, 2019 finding

## q2: higher P300 -\> faster RT in surprise + 1 trial?

#Hyp.:
  
 # same argumentation

#For OB

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
ggplot(merged_averages_OB, aes(x = avg_value, y = merged_averages_OB_RT$avg_RT)) +
  geom_point() +  # Add points
  geom_smooth(method = "lm", color = "#800000") +  # Add regression line
  labs(
    x = "Average P300 magnitude in OB Trials",
    y = "Average RT in OB+1 Trials",
    title = "Correlation between P300 magnitude and RT in OB condition"
  ) +
  theme_minimal()  # Apply minimal theme


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

# Create the scatter plot with ggplot2
ggplot(merged_averages_RL_RT, aes(x = avg_value, y = avg_RT)) +
  geom_point() +  # Add points
  geom_smooth(method = "lm", color = "#87CEEB") +  # Add regression line
  labs(
    x = "Average P300 magnitude in OB Trials",
    y = "Average RT in OB+1 Trials",
    title = "Correlation between P300 magnitude and RT in OB condition"
  ) +
  theme_minimal()  # Apply minimal theme

# Print the correlation coefficient
print(paste("Correlation coefficient:", round(correlation_RT_RL, 2)))

