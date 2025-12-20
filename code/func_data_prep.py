nutri_macro_vars = [
    "protein_eaten",
    "fat_eaten",
    "carb_eaten",
    "fiber_eaten",
    "alcohol_eaten",
]
personal_vars = [
    "age",
    "bmi",
    "bmr",
    "height",
    "weight",
    "cohabitants",
    "screen_hours",
    "stress_level",
    "defecate_quantity_per_day",
    "general_hunger_level",
    "morning_hunger_level",
    "evening_hunger_level",
    "mid_hunger_level",
    "shannon_entropy",
    "faith_pd",
    "pielou_evenness",
]
amount_vars = ["eaten_quantity_in_gram", "energy_kcal_eaten"]
nutri_micro_vars = [
    "beta_carotene_eaten",
    "folate_eaten",
    "iron_eaten",
    "magnesium_eaten",
    "niacin_eaten",
    "pantothenic_acid_eaten",
    "cholesterol_eaten",
    "fatty_acids_monounsaturated_eaten",
    "fatty_acids_polyunsaturated_eaten",
    "fatty_acids_saturated_eaten",
    "calcium_eaten",
    "phosphorus_eaten",
    "potassium_eaten",
    "sodium_eaten",
    "zinc_eaten",
    "vitamin_b1_eaten",
    "vitamin_b12_eaten",
    "vitamin_b2_eaten",
    "vitamin_b6_eaten",
    "vitamin_c_eaten",
    "vitamin_d_eaten",
    "salt_eaten",
    "sugar_eaten",
]
nutri_cfg_vars = [
    "dairy_products_meat_fish_eggs_tofu",
    "vegetables_fruits",
    "sweets_salty_snacks_alcohol",
    "non_alcoholic_beverages",
    "grains_potatoes_pulses",
    "oils_fats_nuts",
]
nutri_fg_vars = [
    "meat_fg_eaten",
    "fruits_fg_eaten",
    "vegetables_fg_eaten",
    "dairy_fg_eaten",
    "bread_fg_eaten",
    "oils_nuts_fg_eaten",
    "coffee_fg_eaten",
    "others_fg_eaten",
    "sugary_fg_eaten",
    "grains_cereals_fg_eaten",
    "fast_food_fg_eaten",
    "water_fg_eaten",
    "tea_fg_eaten",
    "alcohol_fg_eaten",
    "vegan_fg_eaten",
]
nutri_DI_vars = [
    "daily_HEI",
    "HEI",
    "aMED",
    "DASH",
    "PDI_Quintile",
    "hPDI_Quintile",
    "mean_dds",
    "mean_shannon_diversity_kcal",
    "mean_mfad_jaccard_kcal",
    "mean_berger_parker_kcal",
    "mean_simpson_diversity_kcal",
    "mean_gini_simpson_diversity_kcal",
    "mean_quantidd_kcal",
    "nova_1_grams",
    "nova_2_grams",
    "nova_3_grams",
    "nova_4_grams",
]

nutri_temp_vars = [
    "eo_freq",
    "eo_space",
    "Breakfast_skip_ratio",
    "Lunch_skip_ratio",
    "Dinner_skip_ratio",
    "Late_night_skip_ratio",
]


def get_var_type(var):
    if var in nutri_macro_vars:
        return "Macronutrients"
    elif var in nutri_micro_vars:
        return "Micronutrients"
    elif var in nutri_cfg_vars:
        return "Combined Food Groups"
    elif var in nutri_fg_vars:
        return "Food Groups"
    elif var in nutri_DI_vars:
        return "Diet Indices"
    elif var in nutri_temp_vars:
        return "Temporal Patterns"
    elif var in personal_vars:
        return "Anthropometrics"
    elif var in amount_vars:
        return "Amounts"
    elif var.startswith("CV_"):
        return "Regularity Indices"
    else:
        return "Others"


def get_var_type_color(var_type):
    if var_type == "Macronutrients":
        return "green"
    elif var_type == "Micronutrients":
        return "limegreen"
    elif var_type == "Combined Food Groups":
        return "purple"
    elif var_type == "Food Groups":
        return "violet"
    elif var_type == "Diet Indices":
        return "royalblue"
    elif var_type == "Temporal Patterns":
        return "orange"
    elif var_type == "Anthropometrics":
        return "red"
    elif var_type == "Amounts":
        return "gold"
    elif var_type == "Regularity Indices":
        return "rosybrown"
    else:
        return "gray"


def process_string(s, ignore_vars=["HEI"], newLineSep=7):
    if s in ignore_vars:
        return s
    if s == "bmi":
        return "BMI"
    if s == "PDI_Quintile":
        return "PDI"
    if s == "hPDI_Quintile":
        return "hPDI"
    if s == "age_group_2":
        return "Age Group"
    if s == "carb_eaten":
        return "Carbohydrate"
    if s == "eo_freq":
        return "EO Frequency"
    if s == "eo_space":
        return "EO Spacing"
    if "nova" in s:
        s = s.replace("_grams", "")
        return s.replace("_", "-").upper()

    s = s.replace("_fg", "")
    # Step 1 & 2: Split the string by "_" and replace "_" with a space, then capitalize the first letter
    parts = s.replace("_eaten", "").split("_")

    # capitalized_parts = [part.capitalize() for part in parts]
    capitalized_parts = [part[0].upper() + part[1:] if part else "" for part in parts]

    # Step 3: If there are more than 3 items, insert "\n" in the middle
    if newLineSep and len(capitalized_parts) > newLineSep and "CV" not in s:
        mid_index = len(capitalized_parts) // 2
        processed_string = (
            " ".join(capitalized_parts[:mid_index])
            + "\n"
            + " ".join(capitalized_parts[mid_index:])
        )
    elif "CV" in s:
        processed_string = (
            capitalized_parts[0] + " (" + " ".join(capitalized_parts[1:]) + ")"
        )
    else:
        processed_string = " ".join(capitalized_parts)

    return processed_string


def scale_feature_by_daily_intake(merged_meals_with_meta, feature_column):
    """
    Scales the given feature column by the total daily intake for each user and meal type.

    Parameters:
    merged_meals_with_meta (pd.DataFrame): DataFrame containing meal data with 'subject_key', 'eaten_date', 'meal_type', and the feature column.
    feature_column (str): The name of the feature column to be scaled.

    Returns:
    pd.DataFrame: DataFrame with scaled feature values for each meal type.
    """
    # Calculate the total feature intake per day for each user
    daily_total_feature = merged_meals_with_meta.groupby(["subject_key", "eaten_date"])[
        feature_column
    ].transform("sum")

    # Scale the feature intake for each meal by the total feature intake of the day
    scaled_feature_column = f"scaled_{feature_column}"
    merged_meals_with_meta[scaled_feature_column] = (
        merged_meals_with_meta[feature_column] / daily_total_feature
    )

    # Group by 'subject_key', 'eaten_date', and 'meal_type', then calculate the sum of the scaled feature intake
    scaled_feature_distribution = (
        merged_meals_with_meta.groupby(["subject_key", "eaten_date", "meal_type"])[
            scaled_feature_column
        ]
        .sum()
        .unstack(fill_value=0)
    )

    # Reset index to make it easier to work with
    scaled_feature_distribution.reset_index(inplace=True)

    return scaled_feature_distribution
