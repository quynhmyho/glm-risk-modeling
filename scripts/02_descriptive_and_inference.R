# ==============================================================================
# Script 02: Descriptive Statistics and One-Sample Proportion Inference
# Project: Econometric Analysis of Extramarital Affairs (Ray Fair, 1978)
# Author: Ho Quynh My
# ==============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(scales)
})

# Load clean dataset
if (!file.exists("data/processed/affairs_cleaned.rds")) {
  source("scripts/01_data_cleaning.R")
}
df_clean <- readRDS("data/processed/affairs_cleaned.rds")

cat("=================================================================\n")
cat(" 1. DESCRIPTIVE STATISTICS FOR TARGET VARIABLE (affairs)\n")
cat("=================================================================\n")

tab_affairs <- df_clean |>
  count(affairs) |>
  mutate(
    Pct = n / sum(n) * 100,
    CumPct = cumsum(Pct)
  )
print(tab_affairs)

# Figure 1: Distribution of affairs count
p_fig1 <- ggplot(df_clean, aes(x = factor(affairs), fill = has_affair)) +
  geom_bar(color = "white", width = 0.7) +
  scale_fill_manual(values = c("Không" = "#2563EB", "Có" = "#DC2626"), labels = c("No Affairs (0)", "Has Affairs (>0)")) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Figure 1: Frequency Distribution of Extramarital Affairs",
    subtitle = "Severe right-skewness and zero-inflation (75.04% zero counts)",
    x = "Number of Affairs in Past Year (affairs)",
    y = "Count (Frequency)",
    fill = "Status"
  ) +
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 13),
    panel.grid.minor = element_blank()
  )

ggsave("figures/fig1_affairs_distribution.png", p_fig1, width = 7, height = 4.5, dpi = 300)

cat("=================================================================\n")
cat(" 2. SUMMARY STATISTICS FOR CONTINUOUS PREDICTORS\n")
cat("=================================================================\n")

sum_num <- df_clean |>
  summarise(
    across(c(age, yearsmarried, education), list(
      Mean = ~ mean(.x),
      SD = ~ sd(.x),
      Min = ~ min(.x),
      Median = ~ median(.x),
      Max = ~ max(.x)
    ), .names = "{.col}_{.fn}")
  ) |>
  pivot_longer(everything(), names_to = c("Variable", "Metric"), names_sep = "_") |>
  pivot_wider(names_from = "Metric", values_from = "value")
print(sum_num)

# Figure 2: Marital Satisfaction Rating Distribution
p_fig2 <- ggplot(df_clean, aes(x = rating_factor, fill = rating_factor)) +
  geom_bar(color = "white", width = 0.7, show.legend = FALSE) +
  scale_fill_brewer(palette = "Blues") +
  theme_minimal(base_size = 12) +
  labs(
    title = "Figure 2: Self-Reported Marriage Happiness Rating",
    subtitle = "Left-skewed distribution: Majority report high marital happiness (Ratings 4 & 5)",
    x = "Marriage Happiness Rating (1 = Very Unhappy, 5 = Very Happy)",
    y = "Count (Frequency)"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    panel.grid.minor = element_blank()
  )

ggsave("figures/fig2_rating_distribution.png", p_fig2, width = 7, height = 4.5, dpi = 300)

cat("=================================================================\n")
cat(" 3. SUCCESS-FAILURE CONDITION & PROPORTION INFERENCE\n")
cat("=================================================================\n")

n_total <- nrow(df_clean)
n_affair <- sum(df_clean$has_affair == "Có")
p_hat <- n_affair / n_total
se_p <- sqrt(p_hat * (1 - p_hat) / n_total)

cat(sprintf("Total Sample (n): %d\n", n_total))
cat(sprintf("Successes (n*p_hat): %d (>=10: %s)\n", n_affair, n_affair >= 10))
cat(sprintf("Failures (n*(1-p_hat)): %d (>=10: %s)\n", n_total - n_affair, (n_total - n_affair) >= 10))
cat(sprintf("Sample Proportion (p_hat): %.4f (%.2f%%)\n", p_hat, p_hat * 100))
cat(sprintf("Standard Error (SE): %.4f\n", se_p))

# Confidence Intervals (95% & 99%)
prop_95 <- prop.test(x = n_affair, n = n_total, conf.level = 0.95)
binom_95 <- binom.test(x = n_affair, n = n_total, conf.level = 0.95)
prop_99 <- prop.test(x = n_affair, n = n_total, conf.level = 0.99)
binom_99 <- binom.test(x = n_affair, n = n_total, conf.level = 0.99)

cat("\n--- Confidence Interval Comparison ---\n")
ci_summary <- tibble(
  Level = c("95%", "95%", "99%", "99%"),
  Method = c("Normal Approx (prop.test)", "Exact Binomial (binom.test)", "Normal Approx (prop.test)", "Exact Binomial (binom.test)"),
  Lower = c(prop_95$conf.int[1], binom_95$conf.int[1], prop_99$conf.int[1], binom_99$conf.int[1]),
  Upper = c(prop_95$conf.int[2], binom_95$conf.int[2], prop_99$conf.int[2], binom_99$conf.int[2]),
  Margin = Upper - Lower
)
print(ci_summary)

cat("=================================================================\n")
cat(" 4. ONE-PROPORTION HYPOTHESIS TEST (H0: p <= 0.20 vs H1: p > 0.20)\n")
cat("=================================================================\n")

p_0 <- 0.20
res_test <- prop.test(x = n_affair, n = n_total, p = p_0, alternative = "greater", correct = TRUE)
z_score <- sqrt(res_test$statistic) * sign(p_hat - p_0)

cat(sprintf("Hypothesized Proportion (p0): %.2f\n", p_0))
cat(sprintf("Chi-squared Statistic: %.4f\n", res_test$statistic))
cat(sprintf("Normalized Z-score: %.4f\n", z_score))
cat(sprintf("P-value: %.6f (Reject H0 at alpha = 0.05)\n", res_test$p.value))

# Figure 3: Forest Plot for 95% Confidence Interval vs Benchmark
plot_ci <- tibble(
  Metric = "Affair Rate (Sample)",
  p_hat  = p_hat,
  Lower  = prop_95$conf.int[1],
  Upper  = prop_95$conf.int[2]
)

p_fig3 <- ggplot(plot_ci, aes(x = Metric, y = p_hat)) +
  geom_point(size = 4, color = "#1E3A8A") +
  geom_errorbar(aes(ymin = Lower, ymax = Upper), width = 0.15, color = "#DC2626", linewidth = 1.2) +
  geom_hline(yintercept = p_0, linetype = "dashed", color = "#D97706", linewidth = 1) +
  annotate("text", x = 1.25, y = p_0 + 0.035, label = "Threshold H0 (p0 = 20%)", color = "#D97706", fontface = "bold", size = 4) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), limits = c(0.15, 0.32)) +
  labs(
    title = "Figure 3: Forest Plot - 95% Confidence Interval for Affair Proportion",
    subtitle = "Sample p_hat = 24.96% [95% CI: 21.59% - 28.66%], strictly exceeds 20% benchmark",
    y = "Proportion (%)",
    x = ""
  ) +
  coord_flip() +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    panel.grid.minor = element_blank()
  )

ggsave("figures/fig3_forest_plot_ci.png", p_fig3, width = 7, height = 4, dpi = 300)
cat("Script 02 completed successfully!\n")
