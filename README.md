# Meal timing effects on dietary quality and glucose response

Analysis code and notebooks accompanying the paper *"Meal timing effects on dietary quality and glucose response: insights from Food & You digital cohort"* (Singh & Salathé).

## Overview

This project investigates how the **temporal structure of eating** (when and how often people eat) relates to **dietary quality**, **BMI**, and **postprandial glycemic response** in real-world, free-living conditions. The analyses use data from the **Food & You** digital cohort, a Swiss study in which participants logged every meal in real time using the AI-assisted **MyFoodRepo** app, with each entry verified by trained annotators.

The final analysis dataset comprises:
- **~960 participants**
- **~13,380 person-days** of dietary records (5–28 days per participant)
- Continuous glucose monitoring (CGM) data for postprandial response analyses

The work covers four main lines of investigation:

1. **Eating occasion (EO) frequency and spacing** — partial correlations with macronutrients, food groups, dietary diversity indices, and meal-skipping behavior; age- and BMI-stratified relationships with the Daily Healthy Eating Index (Daily HEI).
2. **Meal-specific energy distribution and BMI** — mixed-effects models linking the share of daily energy at breakfast / lunch / dinner / late-night to BMI and EO frequency, including mediation analysis to disentangle direct meal-timing effects from frequency-mediated effects.
3. **Weekend vs. weekday patterns** — linear mixed-effects models of nutrient and food-group intake by meal type, with weekend indicators and time-since-last-eaten covariates.
4. **Postprandial glycemic response (iAUC)** — mixed-effects models of square-root-transformed iAUC as a function of meal composition, meal type, baseline glucose, prior carbohydrate intake (1–12 h), prior glucose excursions (1–4 h), and demographics.

See [`code/README.md`](code/README.md) for a detailed description of each notebook and helper script.

## Repository layout

```
.
├── code/         # Jupyter notebooks, R scripts, and Python helpers (see code/README.md)
├── data/         # Processed/derived data files used by the notebooks (not redistributed)
├── images/       # Figures (fig1–fig4 and supplementary)
└── README.md
```

## Data and Code Availability

The analysis code is publicly available on GitHub: [digitalepidemiologylab/meal-pattern-analysis-paper](https://github.com/digitalepidemiologylab/meal-pattern-analysis-paper).

**Metadata containing clinical, demographic, and nutritional variables cannot be deposited publicly due to participant privacy and ethical restrictions.** Access to this metadata can be requested by contacting the corresponding author, subject to institutional ethical compliance.

The Food & You study protocol was approved by the Geneva Ethics Commission (approval number 2017-02124) and registered with the Swiss Federal Office of Public Health (SNCTP000002833) and ClinicalTrials.gov (NCT03848299). Full study details are reported in Héritier et al., *PLOS Digital Health* (2023).

## Citation

If you use this code, please cite the accompanying paper (Singh & Salathé) and the Food & You cohort description (Héritier et al., 2023).

## Contact

Corresponding author: **Marcel Salathé** — marcel.salathe@epfl.ch
Digital Epidemiology Lab, EPFL, Switzerland
