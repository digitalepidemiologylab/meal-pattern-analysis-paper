# Code Folder

This folder contains Jupyter notebooks and helper scripts for the analysis of dietary patterns, meal timing, and glycemic response.  

The materials are organized into two categories:  
- **Notebooks**: Implement the main analyses and generate figures.  
- **Helper Scripts**: Provide reusable functions and variable definitions to support the analyses.  

---

## 📓 Analysis Notebooks

### 1. `correlation_analysis.ipynb`
- Performs **partial correlation analysis** between a target variable (e.g., eating occasion frequency/spacing) and nutritional or behavioral variables.  
- Adjusts correlations for **covariates** (age, BMI, energy intake).  
- Runs targeted checks of specific associations (e.g., EO frequency vs. BMI, HEI).  

---

### 2. `modeling_scaled_energy_intake.ipynb`
- Scale **meal-specific energy intake** as a percentage of total daily energy intake (TEI).  
- Creates subject-level summaries of scaled energy intake by meal type (Breakfast, Lunch, Dinner, Late Night).  
- Computes correlations between **meal-type TEI% and health/nutritional variables**.  
- Generates a **clustered heatmap** of Pearson correlations for visualization.  
- Fit **mixed-effects models** linking meal-type TEI% to outcomes (e.g., BMI, HEI), adjusted for covariates.  

---

### 3. `modeling_weekend_effects.ipynb`
- Examines **weekday vs. weekend differences** in nutrient intake across meal types and for testing **nutrient intake shifts between weekdays and weekends** across meals  
- Adds a **weekend indicator variable** (Weekday vs. Weekend) and applies **square-root transformation** and back-transforms effects for interpretation.  
- Fits **mixed-effects models** with subject-level random intercepts.  
- Estimates **weekend effect coefficient**, p-values, and significance.  

---

### 4. `modeling_iAUC.ipynb`
- Fits **mixed-effects linear models** to study meal characteristics and postprandial glycemic response (`iAUC`). Predictors used: meal type, macronutrient composition, past meal intake, time since last eating, and demographic covariates.  
- Includes **random intercepts for subjects** to handle repeated measures.  
- Evaluates **multicollinearity** using Variance Inflation Factor (VIF) and runs **residual diagnostics** to assess model assumptions.  
- Tests **transformations** (e.g., square root) of the outcome variable to improve model fit, with **back-transformed effects** for interpretation.  
- Does **robustness checks** for different transformations of the outcome variable with untransformed data.  

---

### 5. `data_prep.ipynb`
For data filtering and quality control of meal logging and metadata datasets. Produces filtered datasets for downstream analysis.
- Merges dietary metadata with meal records and extracts temporal features (date, hour).
-  Defines functions to:
  - Remove low-energy intake days (below a kcal threshold).
  - Exclude users with fewer than a minimum number of valid logging days.
  - Restrict datasets to continuous sequences of valid days (14 days for one cohort, 28 days for another).
- Additionally, also examines the differences in EO frequency on weekends.

---

### 6. `R scripts`
- Contains R scripts for the analysis of skip patterns, meal timing, and glycemic response.
- `Effects_plot_with_dailyHEI.R` Models skip ratios by meal using daily_HEI, demographics, and energy.
    - Single interaction: skip_ratio ~ daily_HEI + bmi_cat + age_group_2 * gender + energy_kcal_eaten.
    - Triple interaction predictions: skip_ratio ~ daily_HEI * gender * age_group_2 + bmi_cat + energy_kcal_eaten
- `Effects_plot.R`: Same framework using HEI instead of daily_HEI.

---

## ⚙️ Helper Scripts

### `func_data_prep.py`
- Contains functions for data_prep.ipynb notebook: 
  - Classifying variables by type.  
  - Assigning colors for visualizations.  
  - Processing variable names for readability.  
  - Scaling features (e.g., energy intake) relative to daily totals.  

---

### `func_modeling.py`
- Utility functions for **statistical modeling and related analyses**:  
  - Variance Inflation Factor (VIF) calculations.  
  - Residual diagnostics (normality tests, QQ plots, histograms).  
  - Transformation utilities (try/recommend transformations, back-transform effects).  
  - Diagnostic for mixed-effects model assumptions.  

---

### `variables.py`
- Central reference list of **variable names**, grouped into categories:  
  - Macronutrients, Micronutrients, Combined food group indices, Food group consumption measures, Personal/demographic variables, Amount-related variables.  


