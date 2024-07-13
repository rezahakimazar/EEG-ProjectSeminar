#EEG_v1

library(nlme)   
library(dplyr)
library(ggplot2)

#Load & Preprocess the EEG Data
EEG_v1 <- read.csv("E:\\EEG Data\\Behavioural Data\\Original Data\\extracted_data_300-400_v1.csv")

EEG_v1 <- EEG_v1 %>%
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

ANOVA <- aov(Value ~ cond * trial_type + Error(Subject / (trial_type * cond)), data = EEG_v1)
summary(ANOVA)

# Run Regression

regression <- lme(Value ~ cond * trial_type, random = ~ 1 | Subject, data = EEG_v1)
summary(regression)


#############Interaction Plot

ggplot(EEG_v1, aes(x = cond, y = Value, color = as.factor(trial_type), group = trial_type)) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  stat_summary(fun = mean, geom = "line", aes(group = trial_type), linetype = "solid") +
  stat_summary(fun.data = mean_cl_boot, geom = "errorbar", width = 0.3) +
  labs(title = "Interaction Plot of Condition and Trial Type on Value",
       x = "Condition", y = "Mean Value") +
  scale_x_continuous(breaks = c(-1, 1), labels = c("oddball", "reversal")) +
  scale_color_manual(values = c("-1" = "#800000", "1" = "#87CEEB"), labels = c("-1" = "rare", "1" = "common")) +
  theme_minimal()

###############Box Plot

# Create a custom factor for coloring
EEG_v1$Type <- with(EEG_v1, ifelse(cond == -1, "Oddball", "Reversal"))

ggplot(EEG_v1, aes(x = interaction(cond, trial_type), y = Value, color = Type)) +
  geom_point(alpha = .1) +
  labs(title = "Point Plot of Value by Condition and Trial Type",
       x = "Condition × Trial Type", y = "Ampliture (µV)") +
  scale_x_discrete(labels = c("-1.-1" = "Oddball/Rare", "-1.1" = "Oddball/Common", 
                              "1.-1" = "Reversal/Rare", "1.1" = "Reversal/Common")) +
  scale_color_manual(values = c("Oddball" = "#800000", "Reversal" = "#87CEEB")) +
  theme_minimal()

