#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dada2)
  library(data.table)
  library(dplyr)
  library(purrr)
  library(readr)
})

# ---------------------------
# Paths
# ---------------------------
base_dir     <- Sys.getenv("SEQ_RUN_SUMMARY_DIR")
filt_reads   <- Sys.getenv("FILT_READS")
metadata_dir <- Sys.getenv("META_DIR")

# ---------------------------
# Helper: sample name mapping
# ---------------------------
sample_map <- c(
  "1KitCtrl1" = "CH1KitCtrl1b",
  "Kit1" = "CH1KitCtrl1a",
  "3KitCtrl1" = "CH3KitCtrl1",
  "2KitCtrl1" = "CH2KitCtrl1b",
  "Kit2" = "CH2KitCtrl1a",
  "2KitCtrl2" = "CH2KitCtrl2",
  "4KitCtrl"  = "CH4KitCtrl",
  "5KitCtrl"  = "CH5KitCtrla",
  "5bKitCtrl" = "CH5KitCtrlb",
  "6KitCtrl"  = "CH6KitCtrl",
  "Chlor1"    = "Chlor1a",
  "Chlor1b"   = "Chlor1b",
  "Chlor2"    = "Chlor2a",
  "Chlor2b"   = "Chlor2b",
  "Chlor3"    = "Chlor3a",
  "Chlor3b"   = "Chlor3b",
  "12Chlor"   = "12D0Chlor"
)

standardize_sample <- function(df, col = "sample") {
  if (!col %in% names(df)) {
    stop(paste0("Required column '", col, "' not found."))
  }
  df %>% mutate(!!sym(col) := recode(.data[[col]], !!!sample_map))
}

# ---------------------------
# Load metadata
# ---------------------------
metadata <- read.delim(
  file.path(metadata_dir, "CH-All_ITS_Metadata_20220124.tsv"),
  stringsAsFactors = FALSE
)

# ---------------------------
# 1. Raw + filtered counts
# ---------------------------
csv_files   <- list.files(filt_reads, pattern = "\\.csv$", full.names = TRUE)
output_file <- file.path(filt_reads, "raw_filtered_read_count.csv")
csv_files   <- setdiff(csv_files, output_file)

raw_and_filtered_read_count <- csv_files %>%
  map_df(~ read_csv(.x, col_types = cols(.default = "c"), show_col_types = FALSE)) %>%
  type_convert() %>%
  rename(sample = Sample) %>%
  standardize_sample("sample")

write.csv(raw_and_filtered_read_count, output_file, row.names = FALSE)

# ---------------------------
# 2. Denoised reads
# ---------------------------
denoised_read_count <- fread(
  file.path(base_dir, "canine_skin_microbiome_all_asvs_seqruns_sample_totals.csv")
) %>%
  rename(denoised_reads = total_reads)

# safer join instead of match()
denoised_read_count <- denoised_read_count %>%
  left_join(
    metadata %>% select(SampleID, Sample_Unique),
    by = c("sample" = "SampleID")
  ) %>%
  mutate(sample = Sample_Unique) %>%
  select(-Sample_Unique)

# ---------------------------
# 3. Chimera removal
# ---------------------------
chimera_removal_read_count <- fread(
  file.path(base_dir, "canine_skin_microbiome_filtered_nochim_asvs_seqruns_sample_totals.csv")
) %>%
  rename(chimeras_removed_reads = total_reads) %>%
  left_join(
    metadata %>% select(SampleID, Sample_Unique),
    by = c("sample" = "SampleID")
  ) %>%
  mutate(sample = Sample_Unique) %>%
  select(-Sample_Unique)


# If denoised_read_count has a Sample column
if ("Sample" %in% names(denoised_read_count)) {
  denoised_read_count <- denoised_read_count %>% rename(sample = Sample)
}

# If chimera_removal_read_count has a Sample column
if ("Sample" %in% names(chimera_removal_read_count)) {
  chimera_removal_read_count <- chimera_removal_read_count %>% rename(sample = Sample)
}
 

# ---------------------------
# 5. Merge all tables
# ---------------------------
merged_final_df <- raw_and_filtered_read_count %>%
  left_join(chimera_removal_read_count, by = "sample") %>%
  left_join(denoised_read_count, by = "sample") 

# ---------------------------
# 6. Add Individual column
# ---------------------------
merged_final_df <- merged_final_df %>%
  left_join(
    metadata %>% select(Sample_Unique, Individual),
    by = c("sample" = "Sample_Unique")
  ) %>%
  mutate(
    Individual = case_when(
      sample %in% c("CH5KitCtrla", "CH5KitCtrlb", "CH6KitCtrl") ~ "Kit",
      sample %in% c("Chlor1a", "Chlor1b", "Chlor2a", "Chlor2b", "Chlor3a", "Chlor3b") ~ "Chlor",
      TRUE ~ Individual
    )
  )

# ---------------------------
# 7. Final cleanup
# ---------------------------
merged_final_df <- merged_final_df %>%
  select(-any_of("Sample")) %>%
  relocate(
    sample, Individual,
    Raw_Sum, Trimmed_Sum,
    denoised_reads, chimeras_removed_reads
  )

# ---------------------------
# Write output
# ---------------------------
write.csv(
  merged_final_df,
  file.path(base_dir, "seqruns_final_summary_read_counts.csv"),
  row.names = FALSE
)

 