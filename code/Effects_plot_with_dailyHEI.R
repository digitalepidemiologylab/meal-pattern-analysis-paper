library(ggplot2)
library(sjPlot)
library(cowplot)

theme_set(theme_sjplot())

# Read the CSV file
data <- read.csv("../data/meta_meal_patterns.csv")

# Set the reference level for age_group_2, gender, and bmi_cat to match the Python model
data$age_group_2 <- factor(data$age_group_2, levels = c("<35", "35-50", ">50"))
data$gender      <- relevel(factor(data$gender),    ref = "male")
data$bmi_cat     <- relevel(factor(data$bmi_cat),   ref = "Normal")

# Helper function to create single‐interaction plots
create_skip_mealtime_single_interaction_plot <- function(model, y_limits = NULL, hide_legend = FALSE) {
  p <- plot_model(model, type = "int", title = "") +
    labs(x = "Age group", color = "Gender") +
    theme(
      panel.grid     = element_blank(),
      axis.ticks     = element_line(size = 0.5, color = "black"),
      axis.line      = element_line(size = 0.5, color = "black"),
      axis.text      = element_text(size = 10, color = "black"),
      axis.title     = element_text(size = 11, color = "black"),
      legend.title   = element_text(size = 10, color = "black"),
      legend.position= if (hide_legend) "none" else "right"
    )
  if (!is.null(y_limits)) {
    p <- p + coord_cartesian(ylim = y_limits)
  }
  p
}

# Fit single‐interaction models (with daily_HEI)
breakfast_model <- lm(Breakfast_skip_ratio   ~ daily_HEI + bmi_cat + age_group_2 * gender + energy_kcal_eaten, data = data)
lunch_model     <- lm(Lunch_skip_ratio       ~ daily_HEI + bmi_cat + age_group_2 * gender + energy_kcal_eaten, data = data)
dinner_model    <- lm(Dinner_skip_ratio      ~ daily_HEI + bmi_cat + age_group_2 * gender + energy_kcal_eaten, data = data)
latenight_model <- lm(Late_night_skip_ratio  ~ daily_HEI + bmi_cat + age_group_2 * gender + energy_kcal_eaten, data = data)

# Create single‐interaction plots
breakfast_plot <- create_skip_mealtime_single_interaction_plot(breakfast_model)
lunch_plot     <- create_skip_mealtime_single_interaction_plot(lunch_model,     y_limits = c(0, 0.25), hide_legend = TRUE)
dinner_plot    <- create_skip_mealtime_single_interaction_plot(dinner_model,    y_limits = c(0, 0.25))
latenight_plot <- create_skip_mealtime_single_interaction_plot(latenight_model, hide_legend = TRUE)

# Summaries
summary(breakfast_model)
summary(lunch_model)
summary(dinner_model)
summary(latenight_model)

# Combine and save single‐interaction plots
combined_singleInteraction_plot <- plot_grid(
  breakfast_plot, lunch_plot,
  dinner_plot,    latenight_plot,
  ncol  = 2, align = "hv"
)
print(combined_singleInteraction_plot)
ggsave(
  filename = "../images/fig2/combined_skipRatio_singleInteraction_plots.png",
  plot     = combined_singleInteraction_plot,
  width    = 9.5,
  height   = 5.5,
  dpi      = 300
)

###########################
sink("./meal_skip_models_summary.txt")

cat("Breakfast model\n")
summary(breakfast_model)

cat("\n\nLunch model\n")
summary(lunch_model)

cat("\n\nDinner model\n")
summary(dinner_model)

cat("\n\nLate-night model\n")
summary(latenight_model)

sink()


################################################################################
# Triple‐interaction models (daily_HEI * gender * age_group_2)
trip_int_breakfast_model <- lm(Breakfast_skip_ratio  ~ daily_HEI * gender * age_group_2 + bmi_cat + energy_kcal_eaten, data = data)
trip_int_lunch_model     <- lm(Lunch_skip_ratio      ~ daily_HEI * gender * age_group_2 + bmi_cat + energy_kcal_eaten, data = data)
trip_int_dinner_model    <- lm(Dinner_skip_ratio     ~ daily_HEI * gender * age_group_2 + bmi_cat + energy_kcal_eaten, data = data)
trip_int_latenight_model <- lm(Late_night_skip_ratio ~ daily_HEI * gender * age_group_2 + bmi_cat + energy_kcal_eaten, data = data)

# Summaries
summary(trip_int_breakfast_model)
summary(trip_int_lunch_model)
summary(trip_int_dinner_model)
summary(trip_int_latenight_model)

# Interaction‐prediction plots with original "Age groups" title
breakfast_pred_plot <- plot_model(
  trip_int_breakfast_model,
  type  = "pred",
  terms = c("daily_HEI", "gender", "age_group_2")
) +
  ggtitle("Age groups") +
  labs(color = "Gender") +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line        = element_line(size = 0.5, color = "black"),
    axis.text        = element_text(size = 10, color = "black"),
    axis.ticks       = element_line(size = 0.5, color = "black"),
    plot.title       = element_text(size = 10.5, hjust = 0.5),
    strip.text       = element_text(size = 10, color = "black")
  )

latenight_pred_plot <- plot_model(
  trip_int_latenight_model,
  type  = "pred",
  terms = c("daily_HEI", "gender", "age_group_2")
) +
  ggtitle("Age groups") +
  labs(color = "Gender") +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line        = element_line(size = 0.5, color = "black"),
    axis.text        = element_text(size = 10, color = "black"),
    axis.ticks       = element_line(size = 0.5, color = "black"),
    plot.title       = element_text(size = 10.5, hjust = 0.5),
    strip.text       = element_text(size = 10, color = "black")
  )

# Create lunch and dinner prediction plots
lunch_pred_plot <- plot_model(
  trip_int_lunch_model,
  type  = "pred",
  terms = c("daily_HEI", "gender", "age_group_2")
) +
  ggtitle("Age groups") +
  labs(color = "Gender") +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line        = element_line(size = 0.5, color = "black"),
    axis.text        = element_text(size = 10, color = "black"),
    axis.ticks       = element_line(size = 0.5, color = "black"),
    plot.title       = element_text(size = 10.5, hjust = 0.5),
    strip.text       = element_text(size = 10, color = "black")
  )

dinner_pred_plot <- plot_model(
  trip_int_dinner_model,
  type  = "pred",
  terms = c("daily_HEI", "gender", "age_group_2")
) +
  ggtitle("Age groups") +
  labs(color = "Gender") +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line        = element_line(size = 0.5, color = "black"),
    axis.text        = element_text(size = 10, color = "black"),
    axis.ticks       = element_line(size = 0.5, color = "black"),
    plot.title       = element_text(size = 10.5, hjust = 0.5),
    strip.text       = element_text(size = 10, color = "black")
  )

# # Combine and save triple‐interaction plots
# combined_tripInteraction_plot <- plot_grid(
#   breakfast_pred_plot,
#   latenight_pred_plot,
#   ncol = 1, align = "v"
# )
# print(combined_tripInteraction_plot)
# ggsave(
#   filename = "images/fig2/skipRatio_interaction_plots.png",
#   plot     = combined_tripInteraction_plot,
#   width    = 7,
#   height   = 5.5,
#   dpi      = 300
# )

right_col <- plot_grid(
  lunch_pred_plot,
  dinner_pred_plot,
  ncol = 1,
  align = "v"
)

# Combine everything: left column (breakfast on top, late night on bottom),
# right column (lunch on top, dinner on bottom)
combined_tripInteraction_plot <- plot_grid(
  plot_grid(breakfast_pred_plot, latenight_pred_plot, ncol = 1, align = "v"),
  right_col,
  ncol = 2,
  rel_widths = c(1, 1)
)

print(combined_tripInteraction_plot)
ggsave(
  filename = "../images/fig2/skipRatio_interaction_plots.png",
  plot     = combined_tripInteraction_plot,
  width    = 14,     
  height   = 5.5,      # Adjust height for two rows
  dpi      = 300
)
