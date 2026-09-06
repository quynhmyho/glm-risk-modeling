# ==============================================================================
# Script 04: Binary Choice and Count Data Generalized Linear Models (GLM)
# Project: Econometric Analysis of Extramarital Affairs (Ray Fair, 1978)
# Author: Ho Quynh My
# ==============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(AER)
  library(MASS)
})

# Load clean dataset
if (!file.exists("data/processed/affairs_cleaned.rds")) {
  source("scripts/01_data_cleaning.R")
}
df_clean <- readRDS("data/processed/affairs_cleaned.rds")

cat("=================================================================\n")
cat(" 1. BINARY CHOICE MODELS: LOGISTIC, PROBIT, CLOGLOG\n")
cat("=================================================================\n")

formula_binary <- has_affair_num ~ rating + yearsmarried + age + religiousness + education + gender + children

# 1.1 Logistic Regression
m_logit <- glm(formula_binary, data = df_clean, family = binomial(link = "logit"))

# 1.2 Probit Regression
m_probit <- glm(formula_binary, data = df_clean, family = binomial(link = "probit"))

# 1.3 Cloglog Regression
m_cloglog <- glm(formula_binary, data = df_clean, family = binomial(link = "cloglog"))

coef_logit <- summary(m_logit)$coefficients
coef_probit <- summary(m_probit)$coefficients
coef_cloglog <- summary(m_cloglog)$coefficients

comp_binary_df <- tibble(
  Variable = rownames(coef_logit),
  Logit_Beta = round(coef_logit[, 1], 4),
  Logit_OR = round(exp(coef_logit[, 1]), 4),
  Logit_Pval = format.pval(coef_logit[, 4], eps = 0.001),
  Probit_Beta = round(coef_probit[, 1], 4),
  Cloglog_Beta = round(coef_cloglog[, 1], 4)
)
print(comp_binary_df)

# Likelihood Ratio Test: Reduced vs Full Model
m_logit_red <- glm(has_affair_num ~ rating + yearsmarried + religiousness, data = df_clean, family = binomial)
lrt_res <- anova(m_logit_red, m_logit, test = "LRT")
cat("\n--- Likelihood Ratio Test (LRT): Full vs Reduced Model ---\n")
print(lrt_res)

# Figure 6: Predicted Probability Curves
df_grid <- tibble(
  yearsmarried = seq(0, 15, length.out = 100),
  rating = 3,
  age = median(df_clean$age),
  religiousness = 3,
  education = median(df_clean$education),
  gender = factor("Nữ", levels = levels(df_clean$gender)),
  children = factor("Có con", levels = levels(df_clean$children))
)

df_grid$Logit <- predict(m_logit, newdata = df_grid, type = "response")
df_grid$Probit <- predict(m_probit, newdata = df_grid, type = "response")
df_grid$Cloglog <- predict(m_cloglog, newdata = df_grid, type = "response")

df_grid_long <- df_grid |>
  pivot_longer(cols = c(Logit, Probit, Cloglog), names_to = "Model", values_to = "Prob")

p_fig6 <- ggplot(df_grid_long, aes(x = yearsmarried, y = Prob, color = Model, linetype = Model)) +
  geom_line(linewidth = 1.2) +
  scale_color_manual(values = c("Logit" = "#2563EB", "Probit" = "#DC2626", "Cloglog" = "#059669")) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Figure 6: Predicted Affair Probabilities Across Years of Marriage",
    subtitle = "Logit vs Probit vs Cloglog (Evaluated at Median/Reference Predictor Profile)",
    x = "Years Married (yearsmarried)",
    y = "Predicted Probability P(Affair = 1)",
    color = "Link Function",
    linetype = "Link Function"
  ) +
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 13),
    panel.grid.minor = element_blank()
  )

ggsave("figures/fig6_predicted_probabilities.png", p_fig6, width = 7.5, height = 4.5, dpi = 300)

cat("=================================================================\n")
cat(" 2. COUNT DATA MODELS: POISSON, OVERDISPERSION TEST, NB\n")
cat("=================================================================\n")

formula_count <- affairs ~ rating + yearsmarried + age + religiousness + education + gender + children

# 2.1 Standard Poisson Model
m_poisson <- glm(formula_count, data = df_clean, family = poisson(link = "log"))

# 2.2 Cameron & Trivedi Overdispersion Test
disp_test <- dispersiontest(m_poisson, alternative = "greater")
cat(sprintf("Overdispersion Test: alpha = %.4f, Z = %.4f, p-value = %.6e\n",
            disp_test$estimate, disp_test$statistic, disp_test$p.value))

# 2.3 Quasi-Poisson Model
m_quasipoisson <- glm(formula_count, data = df_clean, family = quasipoisson(link = "log"))

# 2.4 Negative Binomial Model
m_nb <- glm.nb(formula_count, data = df_clean)

coef_p <- summary(m_poisson)$coefficients
coef_qp <- summary(m_quasipoisson)$coefficients
coef_nb <- summary(m_nb)$coefficients

comp_count_df <- tibble(
  Variable = rownames(coef_p),
  Poisson_Beta = round(coef_p[, 1], 4),
  Poisson_SE = round(coef_p[, 2], 4),
  QuasiPoisson_SE = round(coef_qp[, 2], 4),
  NegBin_Beta = round(coef_nb[, 1], 4),
  NegBin_IRR = round(exp(coef_nb[, 1]), 4),
  NegBin_SE = round(coef_nb[, 2], 4),
  NegBin_Pval = format.pval(coef_nb[, 4], eps = 0.001)
)
print(comp_count_df)

# Save all models
models_list <- list(
  m_logit = m_logit,
  m_probit = m_probit,
  m_cloglog = m_cloglog,
  m_logit_red = m_logit_red,
  m_poisson = m_poisson,
  m_quasipoisson = m_quasipoisson,
  m_nb = m_nb
)
saveRDS(models_list, "data/processed/models.rds")
cat("Script 04 completed successfully!\n")
