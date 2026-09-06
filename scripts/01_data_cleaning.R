# ==============================================================================
# Script 01: Data Ingestion, Inspection, and Cleaning
# Project: Econometric Analysis of Extramarital Affairs (Ray Fair, 1978)
# Author: Ho Quynh My
# ==============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
})

# Create directory structure if not exists
dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
dir.create("figures", recursive = TRUE, showWarnings = FALSE)

cat(">>> Step 1: Loading raw data...\n")
raw_data_path <- "data/raw/Affairs.csv"
url_data <- "https://raw.githubusercontent.com/vincentarelbundock/Rdatasets/master/csv/AER/Affairs.csv"

if (!file.exists(raw_data_path)) {
  cat("Downloading raw dataset from source...\n")
  df_raw <- tryCatch({
    read.csv(url_data)
  }, error = function(e) {
    stop("Failed to download dataset. Please check your network connection!")
  })
  write.csv(df_raw, raw_data_path, row.names = FALSE)
} else {
  cat("Loading local raw dataset...\n")
  df_raw <- read.csv(raw_data_path)
}

# Remove redundant index column if present
if ("X" %in% names(df_raw)) {
  df_raw <- df_raw |> select(-X)
}

cat(">>> Step 2: Checking data integrity and missing values...\n")
missing_summary <- colSums(is.na(df_raw))
print(missing_summary)
stopifnot(sum(missing_summary) == 0) # Confirm 0 missing values across 601 rows

cat(">>> Step 3: Feature Engineering and Categorical Encoding...\n")
df_clean <- df_raw |>
  mutate(
    # Binary target variable: 1 if affairs > 0, 0 otherwise
    has_affair = factor(ifelse(affairs > 0, "Có", "Không"), levels = c("Không", "Có")),
    has_affair_num = ifelse(affairs > 0, 1, 0),
    
    # Ordinal discrete categorized target
    affair_cat = factor(
      case_when(
        affairs == 0 ~ "Không (0 lần)",
        affairs >= 1 & affairs <= 3 ~ "Ít (1-3 lần)",
        affairs >= 7 ~ "Nhiều (>=7 lần)"
      ),
      levels = c("Không (0 lần)", "Ít (1-3 lần)", "Nhiều (>=7 lần)"),
      ordered = TRUE
    ),
    
    # Demographic factor normalization
    gender = factor(gender, levels = c("male", "female"), labels = c("Nam", "Nữ")),
    children = factor(children, levels = c("no", "yes"), labels = c("Không có con", "Có con")),
    
    # Ordinal marriage satisfaction rating (1 = Very unhappy, 5 = Very happy)
    rating_factor = factor(
      rating,
      levels = 1:5,
      labels = c("1-Rất bất hạnh", "2-Bất hạnh", "3-Trung bình", "4-Hạnh phúc", "5-Rất hạnh phúc"),
      ordered = TRUE
    ),
    
    # Ordinal religiousness rating (1 = Anti/None, 5 = Very religious)
    religious_factor = factor(
      religiousness,
      levels = 1:5,
      labels = c("1-Không", "2-Hơi tôn giáo", "3-Trung bình", "4-Tôn giáo", "5-Rất tôn giáo"),
      ordered = TRUE
    ),
    
    # Binary satisfaction grouping for stratification / Mantel-Haenszel test
    happy_bin = factor(
      ifelse(rating <= 3, "Bất hạnh", "Hạnh phúc"),
      levels = c("Hạnh phúc", "Bất hạnh")
    )
  )

cat(">>> Step 4: Saving processed dataset...\n")
write.csv(df_clean, "data/processed/affairs_cleaned.csv", row.names = FALSE)
saveRDS(df_clean, "data/processed/affairs_cleaned.rds")

cat("Data cleaning completed successfully! Total observations:", nrow(df_clean), "\n")
