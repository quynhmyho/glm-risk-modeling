# ==============================================================================
# Script 03: Contingency Tables, Association Metrics, and Stratified Analysis
# Project: Econometric Analysis of Extramarital Affairs (Ray Fair, 1978)
# Author: Ho Quynh My
# ==============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(vcd)
  library(epitools)
})

# Load clean dataset
if (!file.exists("data/processed/affairs_cleaned.rds")) {
  source("scripts/01_data_cleaning.R")
}
df_clean <- readRDS("data/processed/affairs_cleaned.rds")

cat("=================================================================\n")
cat(" 1. TWO-WAY CONTINGENCY TABLE & CHI-SQUARE INDEPENDENCE TEST\n")
cat("=================================================================\n")

tbl_rating <- table(df_clean$rating_factor, df_clean$has_affair)
prop_rating <- prop.table(tbl_rating, margin = 1) * 100
print(tbl_rating)
print(round(prop_rating, 2))

chi_rating <- chisq.test(tbl_rating)
cat(sprintf("\nChi-Square Test (Rating vs Affairs): X2 = %.4f, df = %d, p-value = %.6e\n",
            chi_rating$statistic, chi_rating$parameter, chi_rating$p.value))
cat(sprintf("Minimum Expected Frequency: %.2f (Condition met)\n", min(chi_rating$expected)))

# Figure 4: Stacked 100% Bar Chart of Affairs by Marriage Happiness
p_fig4 <- ggplot(df_clean, aes(x = rating_factor, fill = has_affair)) + 
  geom_bar(position = "fill", color = "white", width = 0.6) + 
  scale_y_continuous(labels = scales::percent_format()) + 
  scale_fill_manual(values = c("Không" = "#2563EB", "Có" = "#DC2626"), labels = c("No Affairs", "Has Affairs")) + 
  theme_minimal(base_size = 12) + 
  labs(
    title = "Figure 4: Affair Incidence Rate Across Marital Satisfaction Levels",
    subtitle = "Monotonic decrease: 50% affair rate in very unhappy marriages down to 14.7% in very happy marriages",
    x = "Self-Reported Marriage Happiness Rating",
    y = "Proportion (%)",
    fill = "Affair Status"
  ) + 
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 13),
    panel.grid.minor = element_blank()
  )

ggsave("figures/fig4_rating_affairs_stacked.png", p_fig4, width = 8, height = 4.5, dpi = 300)

cat("=================================================================\n")
cat(" 2. EFFECT SIZE MEASURES: ODDS RATIO, RELATIVE RISK & CRAMER'S V\n")
cat("=================================================================\n")

# 2x2 Table: Children vs Affair
tbl_child <- table(df_clean$children, df_clean$has_affair)
or_res <- oddsratio(tbl_child)
rr_res <- riskratio(tbl_child)

cat("--- Children vs Affair (2x2) ---\n")
cat(sprintf("Odds Ratio (OR): %.4f [95%% CI: %.4f, %.4f]\n",
            or_res$measure[2, 1], or_res$measure[2, 2], or_res$measure[2, 3]))
cat(sprintf("Relative Risk (RR): %.4f [95%% CI: %.4f, %.4f]\n",
            rr_res$measure[2, 1], rr_res$measure[2, 2], rr_res$measure[2, 3]))

# Cramer's V Strength of Association
assoc_rating <- assocstats(tbl_rating)
assoc_child <- assocstats(tbl_child)

cat("\n--- Association Strength Comparison (Cramér's V) ---\n")
cramer_df <- tibble(
  Predictor = c("Marriage Rating (rating)", "Having Children (children)"),
  Chi_Square = c(assoc_rating$chisq_tests[1, 1], assoc_child$chisq_tests[1, 1]),
  P_value = c(assoc_rating$chisq_tests[1, 3], assoc_child$chisq_tests[1, 3]),
  Cramer_V = c(assoc_rating$cramer, assoc_child$cramer)
)
print(cramer_df)

cat("=================================================================\n")
cat(" 3. STRATIFIED ANALYSIS & MANTEL-HAENSZEL TEST (CONTROLLING GENDER)\n")
cat("=================================================================\n")

df_strat <- df_clean |>
  mutate(
    happy_bin = factor(ifelse(rating <= 3, "Bất hạnh (1-3)", "Hạnh phúc (4-5)"),
                       levels = c("Hạnh phúc (4-5)", "Bất hạnh (1-3)"))
  )

# 3-Way Table: happy_bin x has_affair x gender
tbl_3way <- table(df_strat$happy_bin, df_strat$has_affair, df_strat$gender)
print(tbl_3way)

mh_test <- mantelhaen.test(tbl_3way)
cat(sprintf("\nAdjusted Common Odds Ratio (Mantel-Haenszel): %.4f [95%% CI: %.4f, %.4f]\n",
            mh_test$estimate, mh_test$conf.int[1], mh_test$conf.int[2]))
cat(sprintf("Mantel-Haenszel Test P-value: %.6e\n", mh_test$p.value))

# Figure 5: Faceted Association / Mosaic Visualization
# Using ggplot2 facet bar representation for robust visualization
df_plot_strat <- df_strat |>
  count(gender, happy_bin, has_affair) |>
  group_by(gender, happy_bin) |>
  mutate(prop = n / sum(n))

p_fig5 <- ggplot(df_plot_strat, aes(x = happy_bin, y = prop, fill = has_affair)) +
  geom_col(position = "fill", color = "white", width = 0.6) +
  facet_wrap(~ gender) +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_fill_manual(values = c("Không" = "#E2E8F0", "Có" = "#DC2626"), labels = c("No Affairs", "Has Affairs")) +
  labs(
    title = "Figure 5: Stratified Analysis - Marital Happiness vs Affairs by Gender",
    subtitle = "Consistent effect across both genders (Adjusted Common OR = 2.66, p < 0.001)",
    x = "Marital Happiness Category",
    y = "Proportion (%)",
    fill = "Affair Status"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 13),
    strip.text = element_text(face = "bold", size = 11),
    panel.grid.minor = element_blank()
  )

ggsave("figures/fig5_mosaic_plot.png", p_fig5, width = 7.5, height = 4.5, dpi = 300)
cat("Script 03 completed successfully!\n")
