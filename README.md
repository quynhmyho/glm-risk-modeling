# Discrete Choice & Risk Modeling: Generalized Linear Models (GLM)

[![R](https://img.shields.io/badge/Language-R%204.4+-276DC3.svg?logo=r&logoColor=white)](https://www.r-project.org/)
[![Field](https://img.shields.io/badge/Domain-Quantitative%20Risk%20%7C%20Econometrics-8A2BE2.svg)](#-financial--risk-modeling-applications)
[![Models](https://img.shields.io/badge/Models-Logit%20%7C%20Probit%20%7C%20Negative%20Binomial-059669.svg)](#-core-quantitative-findings)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **Quantitative Portfolio**: Applied Econometric & Statistical Modeling on discrete decisions and event frequencies using Ray Fair's classic dataset ($n = 601$). Demonstrates production-grade competency in **Binary Choice Modeling (Credit PD Analogue)**, **Count Data Overdispersion Correction (Insurance Claim Frequency Analogue)**, and **Stratified Risk Invariance Testing**.

---

## 30-Second Executive Summary

In financial institutions and risk management (Credit Risk, Actuarial Science, Fraud Detection), target variables are rarely continuous Gaussian distributions—they are typically **binary default flags ($Y \in \{0,1\}$)** or **discrete event counts ($Y \in \mathbb{N}_0$) with heavy zero-inflation**. 

This project demonstrates how advanced **Generalized Linear Models (GLMs)** outperform naive OLS regressions:
1. **Binary Probability Modeling**: Benchmarked **Logit**, **Probit**, and **Cloglog** specifications; achieved **$\text{AUC} = 0.7117$** and evaluated cutoff thresholds.
2. **Overdispersion Correction**: Formally detected severe variance overdispersion ($\hat{\alpha} = 6.9430, p < 0.001$) via **Cameron & Trivedi score test** and deployed a **Negative Binomial (NB)** architecture, improving model fit by **$\Delta \text{AIC} = -1402.89$** over standard Poisson.
3. **Subgroup Bias & Confounding Audit**: Executed **Mantel-Haenszel stratified testing**, proving risk effects remain robust and invariant across demographic segments ($\text{Adjusted Common OR} = 2.66, p < 0.001$).
4. **Mathematical Rigor**: Empirically proved the mathematical equivalence between the 2-way log-linear interaction coefficient ($\lambda = 0.9842$) and conditional logistic slope parameter ($\beta = 0.9842$).

---

## Financial & Risk Modeling Applications

While the underlying empirical data investigates extramarital decision-making (Ray Fair, 1978), the exact mathematical and econometric architectures directly map to **Banking, Fintech, and Insurance Risk Analytics**:

```
┌──────────────────────────────────────┐             ┌───────────────────────────────────────────┐
│     Project Methodological Layer     │             │    Banking & Quantitative Risk Analogue   │
├──────────────────────────────────────┼─────────────┼───────────────────────────────────────────┤
│ • Binary GLMs (Logit, Probit, Cloglog│ ──────────► │ • Basel II/III Credit Scoring (PD Model)  │
│   Link functions & ROC/AUC analysis) │             │ • Loan Default / Early Warning Indicator  │
├──────────────────────────────────────┼─────────────┼───────────────────────────────────────────┤
│ • Count GLMs (Poisson vs NegBinomial │ ──────────► │ • Insurance Claim Frequency Modeling      │
│   Overdispersion score test)         │             │ • Operational Loss & Fraud Incident Count │
├──────────────────────────────────────┼─────────────┼───────────────────────────────────────────┤
│ • Stratified Mantel-Haenszel Test    │ ──────────► │ • Fair Lending / Demographic Bias Audit   │
│   & Simpson's Paradox Check          │             │ • Subpopulation Risk Invariance Testing   │
└──────────────────────────────────────┘             └───────────────────────────────────────────┘
```

---

## Core Quantitative Findings

### 1. Headline Model Performance Summary
| Analytical Domain | Model / Method | Key Metric / Statistic | $p$-value | Practical Takeaway |
| :--- | :--- | :--- | :--- | :--- |
| **Statistical Inference** | One-Proportion Z-Test | $\hat{p} = 24.96\%$ [95% CI: $21.59\% - 28.66\%$] | $p = 0.0014$ | Event probability strictly exceeds 20% benchmark. |
| **Bivariate Association** | Chi-Square ($\chi^2$) Test | $\chi^2 = 41.4335$ ($df = 4$) | $p < 0.001$ | Baseline satisfaction strongly correlates with risk. |
| **Stratified Risk** | Mantel-Haenszel Test | $\text{Adjusted Common OR} = 2.6604$ | $p < 0.001$ | Unhappy group has $2.66\times$ higher odds (invariant across genders). |
| **Binary Classification** | Logistic Regression | $\text{AUC} = 0.7117$, McFadden $R^2 = 0.0973$ | $p < 0.001$ | Strong discriminative ability; Logit & Probit yield consistent rankings. |
| **Overdispersion Check** | Cameron & Trivedi Score | $\hat{\alpha} = 6.9430$, $Z = 5.2863$ | $p < 0.001$ | Standard Poisson equidispersion assumption is severely violated. |
| **Count Model Selection** | Negative Binomial vs Poisson | $\text{AIC}: 1475.10 \text{ vs } 2877.99$ | $\Delta \text{AIC} = -1403$ | Negative Binomial captures excess zero & long-tail variance. |

---

### 2. Key Predictor Sensitivities (Odds Ratios & Incidence Rate Ratios)

```text
========================================================================================================
 Predictor Variable        Binary Effect (Logistic OR)           Count Effect (Negative Binomial IRR)
--------------------------------------------------------------------------------------------------------
 Marital Satisfaction      OR = 0.6250 (37.5% drop in odds)      IRR = 0.6599 (34.0% drop in event count)
 Religiousness Level       OR = 0.7222 (27.8% drop in odds)      IRR = 0.6456 (35.4% drop in event count)
 Duration (Years Married)  OR = 1.0999 (10.0% rise per year)     IRR = 1.0879 (8.8% rise per year)
========================================================================================================
*Note: All three predictors are statistically significant at p < 0.01 across both binary and count GLM specifications.
```

---

## Visual Insights Dashboard

<table align="center">
  <tr>
    <td width="50%" align="center">
      <b>Binary Choice Predicted Probabilities</b><br>
      <img src="figures/fig6_predicted_probabilities.png" width="100%" alt="Predicted Probabilities" />
      <br><sub><i>Comparison of Logit, Probit, and Cloglog response curves across marriage duration.</i></sub>
    </td>
    <td width="50%" align="center">
      <b>Model Discrimination (ROC & AUC = 0.7117)</b><br>
      <img src="figures/fig7_roc_curves.png" width="100%" alt="ROC Curves" />
      <br><sub><i>ROC curves confirming robust binary classification power across all three link functions.</i></sub>
    </td>
  </tr>
  <tr>
    <td width="50%" align="center">
      <b>Count Distribution: Poisson vs Negative Binomial</b><br>
      <img src="figures/fig8_count_models_comparison.png" width="100%" alt="Count Models Comparison" />
      <br><sub><i>Negative Binomial accurately models extreme long-tail events (7 & 12 counts) without underestimating variance.</i></sub>
    </td>
    <td width="50%" align="center">
      <b>Risk Segmentation across Satisfaction Levels</b><br>
      <img src="figures/fig4_rating_affairs_stacked.png" width="100%" alt="Risk Segmentation" />
      <br><sub><i>Monotonic risk decline from 50.0% (unhappy cohort) to 14.7% (satisfied cohort).</i></sub>
    </td>
  </tr>
</table>

---

## Streamlined Repository Architecture

```text
├── README.md                           # Executive quantitative risk portfolio documentation
├── .gitignore                          # Clean R / IDE ignore rules
├── QuynhMy.qmd                         # Complete academic research paper & LaTeX formulas (Vietnamese)
├── data/
│   ├── Affairs.csv                     # Original raw dataset (Fair, 1978; n = 601)
│   ├── affairs_cleaned.csv             # Cleaned & feature-engineered dataset
│   ├── affairs_cleaned.rds             # Serialized R dataset object
│   └── models.rds                      # Serialized fitted GLM model objects
├── figures/                            # 300 DPI publication-ready visualizations
│   ├── fig1_affairs_distribution.png
│   ├── fig2_rating_distribution.png
│   ├── fig3_forest_plot_ci.png
│   ├── fig4_rating_affairs_stacked.png
│   ├── fig5_mosaic_plot.png
│   ├── fig6_predicted_probabilities.png
│   ├── fig7_roc_curves.png
│   └── fig8_count_models_comparison.png
└── scripts/                            # Modular, production-ready R scripts
    ├── 01_data_cleaning.R              # Ingestion, validation & factor transformation
    ├── 02_descriptive_and_inference.R  # Descriptive stats, CI estimation & Z-test
    ├── 03_contingency_and_stratified.R # Crosstabs, Chi-square, OR/RR, Mantel-Haenszel
    ├── 04_binary_and_count_models.R    # Binary GLMs (Logit/Probit), Overdispersion test, NB
    ├── 05_model_evaluation.R           # Goodness-of-fit, Confusion matrix, ROC/AUC
    ├── 06_loglinear_and_equivalence.R  # 3-Way Log-linear models & Mathematical equivalence
    └── run_all.R                       # Master pipeline runner
```

---

## 🚀 How to Reproduce

### 1. Clone the Repository
```bash
git clone https://github.com/quynhmyho/glm-risk-modeling.git
cd glm-risk-modeling
```

### 2. Install Required R Libraries
```R
install.packages(c("tidyverse", "AER", "MASS", "pROC", "vcd", "epitools", "scales"))
```

### 3. Run the Entire Pipeline
```bash
Rscript scripts/run_all.R
```
*All models will be estimated, datasets processed, and figures regenerated in `< 20 seconds`.*

---

## Technical Competencies Demonstrated

- **Econometric & Statistical Modeling**: Generalized Linear Models (Logit, Probit, Cloglog, Poisson, Quasi-Poisson, Negative Binomial), Maximum Likelihood Estimation (MLE), Link Functions, Incident Rate Ratios (IRR).
- **Diagnostics & Risk Validation**: Cameron & Trivedi Overdispersion Test, Likelihood Ratio Tests (LRT), Receiver Operating Characteristic (ROC), Area Under Curve (AUC), McFadden Pseudo-$R^2$, Confusion Matrix.
- **Categorical & Stratified Analysis**: Multi-way Contingency Tables, Odds Ratios, Relative Risk, Cramér's V, Mantel-Haenszel Stratification (Simpson's Paradox Auditing), Poisson Log-Linear Modeling.
- **Production R Architecture**: Modular pipeline design, functional programming with `tidyverse`, deterministic random seeds, and reproducible data workflows.

---

## 👤 Author & Contact

- **Ho Quynh My** — *Quantitative Finance & Risk Data Analyst*
- **GitHub**: [@quynhmyho](https://github.com/quynhmyho)
- **Institution**: University of Finance - Marketing (UFM), Ho Chi Minh City, Vietnam
