# ==============================================================================
# Master Pipeline Execution Script
# Project: Econometric Analysis of Extramarital Affairs (Ray Fair, 1978)
# Author: Ho Quynh My
# ==============================================================================

cat("================================================================================\n")
cat(" STARTING COMPLETE ECONOMETRIC & CATEGORICAL ANALYSIS PIPELINE\n")
cat("================================================================================\n")

start_time <- Sys.time()

cat("\n[1/6] Running Data Cleaning & Feature Engineering...\n")
source("scripts/01_data_cleaning.R")

cat("\n[2/6] Running Descriptive Statistics & One-Sample Proportion Inference...\n")
source("scripts/02_descriptive_and_inference.R")

cat("\n[3/6] Running Contingency Tables, OR/RR & Mantel-Haenszel Analysis...\n")
source("scripts/03_contingency_and_stratified.R")

cat("\n[4/6] Running Binary & Count Data Generalized Linear Models (GLM)...\n")
source("scripts/04_binary_and_count_models.R")

cat("\n[5/6] Running Model Diagnostics, Goodness-of-Fit & ROC/AUC Evaluation...\n")
source("scripts/05_model_evaluation.R")

cat("\n[6/6] Running 3-Way Log-Linear Modeling & Mathematical Equivalence Check...\n")
source("scripts/06_loglinear_and_equivalence.R")

end_time <- Sys.time()
cat("\n================================================================================\n")
cat(sprintf(" ALL SCRIPTS EXECUTED SUCCESSFULLY IN %.2f SECONDS!\n", as.numeric(difftime(end_time, start_time, units = "secs"))))
cat(" Generated figures are saved in the 'figures/' directory.\n")
cat(" Processed datasets and models are saved in the 'data/' directory.\n")
cat("================================================================================\n")
