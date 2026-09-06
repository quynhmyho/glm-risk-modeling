# ==============================================================================
# Script 06: Three-Way Log-Linear Models and Mathematical Equivalence Check
# Project: Econometric Analysis of Extramarital Affairs (Ray Fair, 1978)
# Author: Ho Quynh My
# ==============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
})

# Load clean dataset
if (!file.exists("data/processed/affairs_cleaned.rds")) {
  source("scripts/01_data_cleaning.R")
}
df_clean <- readRDS("data/processed/affairs_cleaned.rds")

cat("=================================================================\n")
cat(" 1. CELL FREQUENCIES FOR 3-WAY CONTINGENCY TABLE\n")
cat("=================================================================\n")

df_tab3 <- df_clean |>
  count(gender, happy_bin, has_affair, name = "Freq")
print(df_tab3)

cat("=================================================================\n")
cat(" 2. ESTIMATING COMPETING 3-WAY LOG-LINEAR MODELS\n")
cat("=================================================================\n")

# M0: Mutual Independence Model
m_log_ind <- glm(Freq ~ gender + happy_bin + has_affair, data = df_tab3, family = poisson)

# M1: Homogeneous Association Model (All 2-way interactions)
m_log_homo <- glm(Freq ~ (gender + happy_bin + has_affair)^2, data = df_tab3, family = poisson)

# M2: Saturated Model (Includes 3-way interaction)
m_log_sat <- glm(Freq ~ gender * happy_bin * has_affair, data = df_tab3, family = poisson)

loglin_comp_df <- tibble(
  Model_Structure = c("Mutual Independence (M0)", "Homogeneous Association (M1)", "Saturated (M2)"),
  Residual_Deviance_G2 = c(m_log_ind$deviance, m_log_homo$deviance, m_log_sat$deviance),
  Degrees_of_Freedom = c(m_log_ind$df.residual, m_log_homo$df.residual, m_log_sat$df.residual),
  AIC = c(AIC(m_log_ind), AIC(m_log_homo), AIC(m_log_sat)),
  P_value = c(
    format.pval(1 - pchisq(m_log_ind$deviance, m_log_ind$df.residual), eps = 0.001),
    format.pval(1 - pchisq(m_log_homo$deviance, m_log_homo$df.residual), eps = 0.001),
    "1.000 (Exact Fit)"
  )
)
print(loglin_comp_df)

cat("=================================================================\n")
cat(" 3. MATHEMATICAL EQUIVALENCE CHECK: LOG-LINEAR VS LOGISTIC REGRESSION\n")
cat("=================================================================\n")

# 2-way interaction coefficient between happy_bin and has_affair from Log-Linear M1
lambda_happy_affair <- coef(m_log_homo)["happy_binBất hạnh:has_affairCó"]

# Equivalent coefficient from Logistic regression with conditional structure
m_logit_simple <- glm(has_affair ~ happy_bin + gender, data = df_clean, family = binomial)
beta_happy_logit <- coef(m_logit_simple)["happy_binBất hạnh"]

cat(sprintf("Log-linear 2-way interaction (lambda):   %.4f\n", lambda_happy_affair))
cat(sprintf("Logistic regression coefficient (beta):   %.4f\n", beta_happy_logit))
cat(sprintf("Absolute Difference:                     %.8f\n", abs(lambda_happy_affair - beta_happy_logit)))

if (abs(lambda_happy_affair - beta_happy_logit) < 1e-6) {
  cat("\n>>> MATHEMATICAL PROOF CONFIRMED: Log-linear interaction term exactly equals Logistic regression coefficient!\n")
}

cat("Script 06 completed successfully!\n")
