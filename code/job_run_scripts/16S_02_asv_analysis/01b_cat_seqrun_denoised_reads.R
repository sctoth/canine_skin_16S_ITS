#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(purrr)
  library(readr)
})

# Get paths
target_dir  <- Sys.getenv("SEQRUN_SUMMARY")
base_dir  <- Sys.getenv("BASE_DIR")
n_threads <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "1"))


seq1 <- file.path(base_dir, "Seq_Run1/03_dada2_output_pool/denoised_reads_per_sample.csv")
seq2 <- file.path(base_dir, "Seq_Run2/03_dada2_output_pool/denoised_reads_per_sample.csv")
seq3 <- file.path(base_dir, "Seq_Run3/03_dada2_output_pool/denoised_reads_per_sample.csv")
seq4 <- file.path(base_dir, "Seq_Run4/03_dada2_output_pool/denoised_reads_per_sample.csv")


denoised_paired_read_count <- list(seq1, seq2, seq3, seq4) %>% 
  map_df(~read_csv(.x))

if (!dir.exists(target_dir)) {
  dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)
}

write.csv(denoised_paired_read_count, 
          file = file.path(target_dir, "denoised_paired_read_count.csv"), 
          row.names = FALSE)