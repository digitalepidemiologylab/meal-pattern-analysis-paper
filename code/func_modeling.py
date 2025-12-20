import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from scipy import stats
from statsmodels.formula.api import mixedlm
from statsmodels.stats.diagnostic import het_breuschpagan
from scipy.stats import normaltest
from statsmodels.stats.outliers_influence import variance_inflation_factor
from patsy import dmatrices


def calculate_vif(formula, data):
    # Create design matrices (dependent variable `y` and predictors `X`)
    y, X = dmatrices(formula, data, return_type="dataframe")

    # Calculate VIF for each predictor
    vif = pd.DataFrame(
        {
            "Variable": X.columns,
            "VIF": [variance_inflation_factor(X.values, i) for i in range(X.shape[1])],
        }
    )

    return vif.sort_values("VIF", ascending=False)


def check_residual_normality(model, plot=True):
    """
    Test normality of residuals using:
    1. QQ Plot
    2. D'Agostino-Pearson test
    3. Histogram with normal curve

    Parameters:
    -----------
    model : fitted statsmodels MixedLM model
    plot : bool, optional
        If True, creates visualization plots

    Returns:
    --------
    dict with test results
    """
    residuals = model.resid

    # D'Agostino-Pearson test
    stat, p_value = normaltest(residuals)

    if plot:
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(8, 4))

        # QQ Plot
        stats.probplot(residuals, dist="norm", plot=ax1)
        ax1.set_title("Q-Q Plot of Residuals")

        # Histogram
        sns.histplot(residuals, kde=True, ax=ax2)
        ax2.set_title("Histogram of Residuals")
        plt.tight_layout()
        plt.show()

    return {
        "statistic": stat,
        "p_value": p_value,
        "interpretation": (
            "Residuals are normal"
            if p_value > 0.05
            else "Residuals deviate from normality"
        ),
    }


def check_homoscedasticity(model, plot=True):
    """
    Test homoscedasticity using:
    1. Breusch-Pagan test
    2. Residuals vs Fitted plot

    Parameters:
    -----------
    model : fitted statsmodels MixedLM model
    plot : bool, optional
        If True, creates visualization plots

    Returns:
    --------
    dict with test results
    """
    fitted_values = model.fittedvalues
    residuals = model.resid

    # Breusch-Pagan test
    bp_test = het_breuschpagan(residuals, model.model.exog)

    if plot:
        plt.figure(figsize=(4, 4))
        plt.scatter(fitted_values, residuals, alpha=0.5)
        plt.axhline(y=0, color="r", linestyle="--")
        plt.xlabel("Fitted Values")
        plt.ylabel("Residuals")
        plt.title("Residuals vs Fitted Values")

        # Add a trend line
        z = np.polyfit(fitted_values, residuals, 1)
        p = np.poly1d(z)
        plt.plot(fitted_values, p(fitted_values), "r--", alpha=0.8)

        plt.show()

    return {
        "statistic": bp_test[0],
        "p_value": bp_test[1],
        "interpretation": (
            "Homoscedasticity assumption met"
            if bp_test[1] > 0.05
            else "Heteroscedasticity present"
        ),
    }


def check_random_effects(model, plot=True):
    """
    Analyze random effects distribution using:
    1. QQ Plot of random effects
    2. Shapiro-Wilk test
    3. Distribution plot

    Parameters:
    -----------
    model : fitted statsmodels MixedLM model
    plot : bool, optional
        If True, creates visualization plots

    Returns:
    --------
    dict with test results
    """
    random_effects = model.random_effects
    re_values = np.concatenate([group for group in random_effects.values()])

    # Shapiro-Wilk test
    stat, p_value = stats.shapiro(re_values)

    if plot:
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 5))

        # QQ Plot
        stats.probplot(re_values, dist="norm", plot=ax1)
        ax1.set_title("Q-Q Plot of Random Effects")

        # Distribution plot
        sns.histplot(re_values, kde=True, ax=ax2)
        ax2.set_title("Distribution of Random Effects")
        plt.tight_layout()
        plt.show()

    return {
        "statistic": stat,
        "p_value": p_value,
        "interpretation": (
            "Random effects are normal"
            if p_value > 0.05
            else "Random effects deviate from normality"
        ),
    }


def run_all_diagnostics(model):
    """
    Run all diagnostic tests and print comprehensive results

    Parameters:
    -----------
    model : fitted statsmodels MixedLM model

    Returns:
    --------
    dict with all test results
    """
    print("=== Model Diagnostics ===\n")

    print("1. Residual Normality Test")
    print("--------------------------")
    norm_results = check_residual_normality(model)
    print(f"D'Agostino-Pearson test p-value: {norm_results['p_value']:.4f}")
    print(f"Interpretation: {norm_results['interpretation']}\n")

    print("2. Homoscedasticity Test")
    print("------------------------")
    homo_results = check_homoscedasticity(model)
    print(f"Breusch-Pagan test p-value: {homo_results['p_value']:.4f}")
    print(f"Interpretation: {homo_results['interpretation']}\n")

    print("3. Random Effects Distribution Test")
    print("---------------------------------")
    re_results = check_random_effects(model)
    print(f"Shapiro-Wilk test p-value: {re_results['p_value']:.4f}")
    print(f"Interpretation: {re_results['interpretation']}\n")

    return {
        "normality": norm_results,
        "homoscedasticity": homo_results,
        "random_effects": re_results,
    }


def try_transformations(data, target_col, formula_template, group_col="subject_key"):
    results = {}
    data_orig = data.copy()

    transformations = {
        "original": lambda x: x,
        "log": lambda x: np.log1p(x),
        "sqrt": lambda x: np.sqrt(x),
        "boxcox": lambda x: stats.boxcox(x + 1)[0] if (x >= -1).all() else x,
    }

    for name, transform in transformations.items():
        try:
            # Apply transformation
            data[target_col] = transform(data_orig[target_col])

            # Fit model and store results
            formula = formula_template.format(target_col)
            model = mixedlm(formula, data, groups=group_col)
            # fit = model.fit()
            fit = model.fit(reml=False, maxiter=2000)

            # Calculate residuals and metrics
            residuals = fit.resid
            ks_stat, ks_pval = stats.kstest(residuals, "norm")
            normal_stat = stats.normaltest(residuals)

            results[name] = {
                "aic": fit.aic,
                "bic": fit.bic,
                "log_likelihood": fit.llf,
                "ks_pval": ks_pval,
                "normal_pval": normal_stat[1],
                "skewness": stats.skew(residuals),
                "kurtosis": stats.kurtosis(residuals),
                "scale": fit.scale,
            }

        except Exception as e:
            print(f"Error with {name} transformation: {str(e)}")
            continue

    return pd.DataFrame(results).T.round(4)


def recommend_transformation(results_df):
    """
    Recommend transformation based on normality metrics only (since model fitting failed)
    """
    if results_df.empty:
        return "No valid transformations found"

    # Focus on normality metrics only
    scores = results_df.copy()

    # Calculate composite score based on how close skewness and kurtosis are to 0
    scores["skewness_score"] = abs(scores["skewness"])
    scores["kurtosis_score"] = abs(scores["kurtosis"])
    scores["composite_score"] = scores["skewness_score"] + scores["kurtosis_score"]

    # Return transformation with lowest composite score (closest to normal)
    return scores.sort_values("composite_score").index[0]


# def back_transform_effects(model_data, coef, se, target_col=None, eval_point=None):
#     """
#     Transform coefficient effects back to original scale for sqrt transformation

#     Parameters:
#     -----------
#     model_data : pandas DataFrame
#         DataFrame containing model data
#     coef: coefficient value
#     se: standard error
#     eval_point: value at which to evaluate the effect (defaults to mean)

#     Returns:
#     effect: effect on original scale
#     ci_lower: lower 95% CI
#     ci_upper: upper 95% CI
#     """
#     # Use provided evaluation point or default to mean
#     if eval_point is None:
#         if target_col is None:
#             raise ValueError("target_col must be provided if eval_point is None")
#         eval_point = model_data[target_col].mean()

#     # Calculate effect and CIs
#     effect = 2 * eval_point * coef
#     ci_lower = 2 * eval_point * (coef - 1.96 * se)
#     ci_upper = 2 * eval_point * (coef + 1.96 * se)

#     return effect, ci_lower, ci_upper


def back_transform_effects(coef, se, eval_point):
    """
    Transform coefficient effects back to original scale for sqrt transformation.
    For a model where the dependent variable was sqrt-transformed: y = (β₀ + β₁x)²

    Parameters:
    -----------
    coef: float
        Coefficient value from sqrt-transformed model
    se: float
        Standard error of the coefficient
    eval_point: float
        Value at which to evaluate the effect

    Returns:
    --------
    tuple: (effect, ci_lower, ci_upper)
        effect: effect on original scale
        ci_lower: lower 95% CI
        ci_upper: upper 95% CI
    """
    # Calculate the base square root value
    sqrt_base = np.sqrt(eval_point)

    # Calculate effect using exact transformation
    # For a sqrt-transformed model, the effect is: 2√(mean) * coefficient
    effect = 2 * sqrt_base * coef

    # Calculate confidence intervals
    ci_lower = 2 * sqrt_base * (coef - 1.96 * se)
    ci_upper = 2 * sqrt_base * (coef + 1.96 * se)

    return effect, ci_lower, ci_upper
