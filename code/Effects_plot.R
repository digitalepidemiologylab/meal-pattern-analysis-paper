library(ggplot2)
library(sjPlot)
library(cowplot)

theme_set(theme_sjplot())

# Read the CSV file
# data <- read.csv("test_breakfast_skip_ratio_for_R.csv")
data <- read.csv("../data/meta_meal_patterns.csv")

# Set the reference level for age_group_2, gender, and bmi_cat to match the Python model
data$age_group_2 <- factor(data$age_group_2, levels = c("<35", "35-50", ">50"))
data$gender <- relevel(factor(data$gender), ref = "male")
data$bmi_cat <- relevel(factor(data$bmi_cat), ref = "Normal")

# Breakfast_skip_ratio  Lunch_skip_ratio  Dinner_skip_ratio  Late_night_skip_ratio

# ### PLotting components
# # Fit the linear model including the interaction between age_group_2 and gender
# breakast_model <- lm(Breakfast_skip_ratio ~ HEI + bmi_cat + age_group_2 * gender + energy_kcal_eaten , data = data)
# summary(breakast_model)
# breakast_model_plot <- plot_model(breakast_model, type = "int", title = "") + labs(x = "Age group", color = "Gender") + 
#   theme(panel.grid = element_blank(), axis.ticks = element_line(), legend.title = element_text(size = 10))
# ggsave(
#   filename = "images/skipRatio_breakast_interaction.png", 
#   plot = breakast_model_plot, width = 5, height = 4,  dpi = 300 
# )
# 
# lunch_model <- lm(Lunch_skip_ratio ~ HEI + bmi_cat + age_group_2 * gender + energy_kcal_eaten , data = data)
# summary(lunch_model)
# lunch_model_plot <- plot_model(lunch_model, type = "int", title = "") + labs(x = "Age group", color = "Gender") + 
#   coord_cartesian(ylim = c(0, 0.25)) +
#   theme(panel.grid = element_blank(), axis.ticks = element_line(), legend.position = "none")
# 
# dinner_model <- lm(Dinner_skip_ratio ~ HEI + bmi_cat + age_group_2 * gender + energy_kcal_eaten , data = data)
# summary(breakast_model)
# dinner_model_plot <- plot_model(dinner_model, type = "int", title = "") + labs(x = "Age group", color = "Gender") + 
#   coord_cartesian(ylim = c(0, 0.25)) +
#   theme(panel.grid = element_blank(), axis.ticks = element_line(), legend.title = element_text(size = 10))
# 
# latenight_model <- lm(Late_night_skip_ratio ~ HEI + bmi_cat + age_group_2 * gender + energy_kcal_eaten , data = data)
# summary(latenight_model)
# latenight_model_plot <- plot_model(latenight_model, type = "int", title = "") + labs(x = "Age group", color = "Gender") + 
#   theme(panel.grid = element_blank(), axis.ticks = element_line(), legend.position = "none")
# 
# combined_singleInteraction_plot <- plot_grid(
#   breakast_model_plot, lunch_model_plot,
#   dinner_model_plot, latenight_model_plot,
#   ncol = 2,         # Number of columns
#   align = "hv"      # Align horizontally and vertically
# )
# 
# combined_singleInteraction_plot
# 
# # Save the combined plot
# ggsave(
#   filename = "images/combined_skipRatio_singleInteraction_plots.png", # File name
#   plot = combined_singleInteraction_plot,                                  
#   width = 7,                                            # Width in inches
#   height = 5.5,                                            # Height in inches
#   dpi = 300                                              # Resolution
# )

# Helper function to create plots
create_skip_mealtime_single_interaction_plot <- function(model, y_limits = NULL, hide_legend = FALSE) {
  plot <- plot_model(model, type = "int", title = "") +
    labs(x = "Age group", color = "Gender") +
    theme(
      panel.grid = element_blank(),
      axis.ticks = element_line(size = 0.5, color = "black"),       # Thicker and darker ticks
      axis.line = element_line(size = 0.5, color = "black"),        # Thicker and darker spines
      axis.text = element_text(size = 10, color = "black"),         # Larger and darker tick text
      axis.title = element_text(size = 11, color = "black"),        # Larger and darker axis labels
      legend.title = element_text(size = 10, color = "black"),      # Darker legend title
      legend.position = if (hide_legend) "none" else "right",        # Conditional legend hiding
    )
  if (!is.null(y_limits)) {
    plot <- plot + coord_cartesian(ylim = y_limits)                 # Set y-axis limits if provided
  }
  return(plot)
}

# Fit models
breakfast_model <- lm(Breakfast_skip_ratio ~ HEI + bmi_cat + age_group_2 * gender + energy_kcal_eaten, data = data)
lunch_model <- lm(Lunch_skip_ratio ~ HEI + bmi_cat + age_group_2 * gender + energy_kcal_eaten, data = data)
dinner_model <- lm(Dinner_skip_ratio ~ HEI + bmi_cat + age_group_2 * gender + energy_kcal_eaten, data = data)
latenight_model <- lm(Late_night_skip_ratio ~ HEI + bmi_cat + age_group_2 * gender + energy_kcal_eaten, data = data)

# Create plots
breakfast_plot <- create_skip_mealtime_single_interaction_plot(breakfast_model)
lunch_plot <- create_skip_mealtime_single_interaction_plot(lunch_model, y_limits = c(0, 0.25), hide_legend = TRUE)
dinner_plot <- create_skip_mealtime_single_interaction_plot(dinner_model, y_limits = c(0, 0.25))
latenight_plot <- create_skip_mealtime_single_interaction_plot(latenight_model, hide_legend = TRUE)

# Combine plots
combined_singleInteraction_plot <- plot_grid(
  breakfast_plot, lunch_plot,
  dinner_plot, latenight_plot,
  ncol = 2, align = "hv"
)

combined_singleInteraction_plot

# Save the combined plot
ggsave(
  filename = "../images/fig2/combined_skipRatio_singleInteraction_plots.png",
  plot = combined_singleInteraction_plot,
  width = 7,
  height = 5.5,
  dpi = 300
)

################################################################################################
################################################################################################

#trip_int_breakfast_model <- lm(Breakfast_skip_ratio ~ HEI + age_group_2 * gender * bmi_cat , data = data)
trip_int_breakfast_model <- lm(Breakfast_skip_ratio ~  HEI * gender * age_group_2 + bmi_cat + energy_kcal_eaten , data = data)
summary(trip_int_breakfast_model)
#plot_model(trip_int_breakfast_model, type = "int")
plot_model(trip_int_breakfast_model, type = "pred",  terms = c("HEI", "gender", "age_group_2"))

#trip_int_lunch_model <- lm(Lunch_skip_ratio ~ HEI + age_group_2 * gender * bmi_cat , data = data)
trip_int_lunch_model <- lm(Lunch_skip_ratio ~  HEI * gender * age_group_2 + bmi_cat + energy_kcal_eaten , data = data)
summary(trip_int_lunch_model)
plot_model(trip_int_lunch_model, type = "pred", terms = c("HEI", "gender", "age_group_2"))


#trip_int_dinner_model <- lm(Dinner_skip_ratio ~ HEI + age_group_2 * gender * bmi_cat , data = data)
trip_int_dinner_model <- lm(Dinner_skip_ratio ~  HEI * gender * age_group_2 + bmi_cat + energy_kcal_eaten , data = data)
summary(trip_int_dinner_model)
plot_model(trip_int_dinner_model, type = "pred", terms = c("HEI", "gender", "age_group_2"))

#trip_int_latenight_model <- lm(Late_night_skip_ratio ~ HEI + age_group_2 * gender * bmi_cat , data = data)
trip_int_latenight_model <- lm(Late_night_skip_ratio ~  HEI * gender * age_group_2 + bmi_cat + energy_kcal_eaten , data = data)
summary(trip_int_latenight_model)
plot_model(trip_int_latenight_model, type = "pred", terms = c("HEI", "gender", "age_group_2"))

################################################################################################
################################################################################################

# Load required libraries
library(sjPlot)
library(ggplot2)
library(cowplot)  # You can alternatively use `patchwork` instead of `cowplot`

# Fit the models
trip_int_breakfast_model <- lm(Breakfast_skip_ratio ~ HEI * gender * age_group_2 + bmi_cat + energy_kcal_eaten , data = data)
trip_int_latenight_model <- lm(Late_night_skip_ratio ~ HEI * gender * age_group_2 + bmi_cat + energy_kcal_eaten , data = data)

summary(trip_int_breakfast_model)
summary(trip_int_latenight_model)

# Generate the interaction plots using sjPlot
breakfast_plot <- plot_model(trip_int_breakfast_model, type = "pred", terms = c("HEI", "gender", "age_group_2")) + 
  ggtitle("Age groups") + labs(color = "Gender") + 
  theme_minimal() + 
  theme(
    panel.grid.major = element_blank(), # Remove major y gridlines
    panel.grid.minor = element_blank(),   # Remove all minor gridlines
    axis.line = element_line(size = 0.5, color = "black"),
    axis.text = element_text(size = 10, color = "black"),
    axis.ticks = element_line(size = 0.5, color = "black"),
    plot.title = element_text(size = 10.5, hjust = 0.5),
    strip.text = element_text(size = 10, color = "black", )
  )

latenight_plot <- plot_model(trip_int_latenight_model, type = "pred", terms = c("HEI", "gender", "age_group_2")) + 
  ggtitle("Age groups") + 
  theme_minimal() + labs(color = "Gender") + 
  theme(
    panel.grid.major = element_blank(), # Remove major y gridlines
    panel.grid.minor = element_blank(),   # Remove all minor gridlines
    axis.line = element_line(size = 0.5, color = "black"),
    axis.text = element_text(size = 10, color = "black"),
    axis.ticks = element_line(size = 0.5, color = "black"),
    plot.title = element_text(size = 10.5, hjust = 0.5),
    strip.text = element_text(size = 10, color = "black", )
  )

# Combine the plots into a single image
combined_plot <- plot_grid(breakfast_plot, latenight_plot, ncol = 1, align = "v")

# Display the combined plot
print(combined_plot)

ggsave(
  filename = "../images/fig2/skipRatio_interaction_plots.png", # File name
  plot = combined_plot,                       # Plot to save
  width = 7,                                  # Width in inches
  height = 5.5,                                # Height in inches
  dpi = 300                                   # Resolution
)

################################################################################################
################################################################################################
################################################################################################
################################################################################################

# library(ggplot2)
# library(sjPlot)
# theme_set(theme_sjplot())
# # Load necessary libraries
# library(dplyr)
# library(effsize)
# 
# 
# data <- read.csv("mmm_no_small_cleaned.csv")
# data$fastbroken <- factor(data$fastbroken)
# 
# # Filter data for fastbroken and non-fastbroken meals
# fastbroken_meals <- data %>% filter(fastbroken == "True")
# non_fastbroken_meals <- data %>% filter(fastbroken == "False")
# 
# # List of meal types
# meal_types <- c("Breakfast", "Lunch", "Dinner")
# 
# # Loop through meal types for t-tests and Levene's test
# for (meal in meal_types) {
#   fastbroken <- fastbroken_meals %>% filter(meal_type == meal) %>% pull(energy_kcal_eaten)
#   non_fastbroken <- non_fastbroken_meals %>% filter(meal_type == meal) %>% pull(energy_kcal_eaten)
#   
#   # T-test
#   t_test <- t.test(fastbroken, non_fastbroken, var.equal = FALSE)
#   print(paste0(meal, " - T-test: p-value = ", round(t_test$p.value, 5)))
#   
#   # Levene's Test
#   levene_test <- car::leveneTest(energy_kcal_eaten ~ fastbroken, data = data %>% filter(meal_type == meal))
#   print(paste0(meal, " - Levene's Test: p-value = ", round(levene_test$`Pr(>F)`[1], 5)))
# }
# 
# 


