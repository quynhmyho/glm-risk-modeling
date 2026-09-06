# ==============================================================================
# Script 05: Model Diagnostics, Goodness-of-Fit, ROC/AUC, and Evaluation
# Project: Econometric Analysis of Extramarital Affairs (Ray Fair, 1978)
# Author: Ho Quynh My
# ==============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(pROC)
  library(MASS)
})

# Load clean dataset and models
if (!file.exists("data/models.rds")) {
  source("scripts/04_binary_and_count_models.R")
}
df_clean <- readRDS("data/affairs_cleaned.rds")
models <- readRDS("data/models.rds")

m_logit <- models$m_logit
m_probit <- models$m_probit
m_cloglog <- models$m_cloglog
m_poisson <- models$m_poisson
m_nb <- models$m_nb

cat("=================================================================\n")
cat(" 1. GOODNESS-OF-FIT FOR BINARY CHOICE MODELS\n")
cat("=================================================================\n")

mcfadden_r2 <- function(model) {
  1 - (as.numeric(logLik(model)) / as.numeric(logLik(update(model, . ~ 1))))
}

gof_binary_df <- tibble(
  Model = c("Logistic (Logit)", "Probit", "Cloglog"),
  Log_Likelihood = c(as.numeric(logLik(m_logit)), as.numeric(logLik(m_probit)), as.numeric(logLik(m_cloglog))),
  AIC = c(AIC(m_logit), AIC(m_probit), AIC(m_cloglog)),
  BIC = c(BIC(m_logit), BIC(m_probit), BIC(m_cloglog)),
  McFadden_PseudoR2 = c(mcfadden_r2(m_logit), mcfadden_r2(m_probit), mcfadden_r2(m_cloglog))
)
print(gof_binary_df)

cat("=================================================================\n")
cat(" 2. CONFUSION MATRIX & CLASSIFICATION METRICS (THRESHOLD = 0.5)\n")
cat("=================================================================\n")

prob_logit <- predict(m_logit, type = "response")
pred_class_50 <- ifelse(prob_logit > 0.5, "Có", "Không")
cm_tab <- table(Predicted = pred_class_50, Actual = df_clean$has_affair)
print(cm_tab)

TP <- cm_tab["Có", "Có"]
TN <- cm_tab["Không", "Không"]
FP <- cm_tab["Có", "Không"]
FN <- cm_tab["Không", "Có"]

accuracy    <- (TP + TN) / sum(cm_tab)
sensitivity <- TP / (TP + FN)
specificity <- TN / (TN + FP)

cat(sprintf("Accuracy:    %.2f%%\n", accuracy * 100))
cat(sprintf("Sensitivity: %.2f%%\n", sensitivity * 100))
cat(sprintf("Specificity: %.2f%%\n", specificity * 100))

cat("=================================================================\n")
cat(" 3. ROC CURVES & AREA UNDER THE CURVE (AUC)\n")
cat("=================================================================\n")

roc_logit   <- roc(df_clean$has_affair_num, prob_logit, quiet = TRUE)
roc_probit  <- roc(df_clean$has_affair_num, predict(m_probit, type = "response"), quiet = TRUE)
roc_cloglog <- roc(df_clean$has_affair_num, predict(m_cloglog, type = "response"), quiet = TRUE)

cat(sprintf("AUC (Logistic): %.4f\n", auc(roc_logit)))
cat(sprintf("AUC (Probit):   %.4f\n", auc(roc_probit)))
cat(sprintf("AUC (Cloglog):  %.4f\n", auc(roc_cloglog)))

# Figure 7: ROC Curves using ggplot2
df_roc_logit <- tibble(
  FPR = 1 - roc_logit$specificities,
  TPR = roc_logit$sensitivities,
  Model = paste0("Logistic (AUC = ", round(auc(roc_logit), 4), ")")
)
df_roc_probit <- tibble(
  FPR = 1 - roc_probit$specificities,
  TPR = roc_probit$sensitivities,
  Model = paste0("Probit (AUC = ", round(auc(roc_probit), 4), ")")
)
df_roc_cloglog <- tibble(
  FPR = 1 - roc_cloglog$specificities,
  TPR = roc_cloglog$sensitivities,
  Model = paste0("Cloglog (AUC = ", round(auc(roc_cloglog), 4), ")")
)
df_roc_all <- bind_rows(df_roc_logit, df_roc_probit, df_roc_cloglog)

p_fig7 <- ggplot(df_roc_all, aes(x = FPR, y = TPR, color = Model, linetype = Model)) +
  geom_line(linewidth = 1.1) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "gray50") +
  scale_color_manual(values = c("#2563EB", "#059669", "#DC2626")) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Figure 7: Receiver Operating Characteristic (ROC) Curves",
    subtitle = "Discriminative performance: AUC = 0.7117 across all three link functions",
    x = "False Positive Rate (1 - Specificity)",
    y = "True Positive Rate (Sensitivity)"
  ) +
  theme(
    legend.position = "inside",
    legend.position.inside = c(0.7, 0.25),
    legend.background = element_rect(fill = "white", color = "gray80"),
    plot.title = element_text(face = "bold", size = 13),
    panel.grid.minor = element_blank()
  )

ggsave("figures/fig7_roc_curves.png", p_fig7, width = 7, height = 5, dpi = 300)

cat("=================================================================\n")
cat(" 4. COUNT MODEL EVALUATION (POISSON VS NEGATIVE BINOMIAL)\n")
cat("=================================================================\n")

pred_poisson <- predict(m_poisson, type = "response")
pred_nb <- predict(m_nb, type = "response")
actual_count <- df_clean$affairs

rmse_poisson <- sqrt(mean((actual_count - pred_poisson)^2))
rmse_nb <- sqrt(mean((actual_count - pred_nb)^2))
mae_poisson <- mean(abs(actual_count - pred_poisson))
mae_nb <- mean(abs(actual_count - pred_nb))

eval_count_df <- tibble(
  Model = c("Poisson Regression", "Negative Binomial (NB)"),
  AIC = c(AIC(m_poisson), AIC(m_nb)),
  BIC = c(BIC(m_poisson), BIC(m_nb)),
  RMSE = c(rmse_poisson, rmse_nb),
  MAE = c(mae_poisson, mae_nb)
)
print(eval_count_df)

# Figure 8: Boxplot comparison of predicted values
df_pred_comp <- tibble(
  Actual = factor(df_clean$affairs),
  Poisson = pred_poisson,
  NegBin = pred_nb
) |>
  pivot_longer(cols = c(Poisson, NegBin), names_to = "Model", values_to = "Predicted")

p_fig8 <- ggplot(df_pred_comp, aes(x = Actual, y = Predicted, fill = Model)) +
  geom_boxplot(alpha = 0.7, outlier.size = 1) +
  scale_fill_manual(values = c("NegBin" = "#2563EB", "Poisson" = "#DC2626"),
                    labels = c("Negative Binomial", "Poisson Regression")) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Figure 8: Actual vs Predicted Count Distribution (Poisson vs Negative Binomial)",
    subtitle = "NB captures large variances in extreme counts (7 & 12 affairs) and handles excess zeros",
    x = "Actual Number of Extramarital Affairs in Past Year",
    y = "Predicted Affair Count",
    fill = "Model"
  ) +
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 13),
    panel.grid.minor = element_blank()
  )

ggsave("figures/fig8_count_models_comparison.png", p_fig8, width = 7.5, height = 4.5, dpi = 300)
cat("Script 05 completed successfully!\n")
