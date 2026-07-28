#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dada2)
  library(data.table)
})

# Get paths
target_dir  <- Sys.getenv("SEQRUN_SUMMARY")
base_dir  <- Sys.getenv("BASE_DIR")
n_threads <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "1"))

# Load the seqtab.rds files from each run
seq1 <- readRDS(file.path(base_dir, "Seq_Run1/dada2_output_pool/canine_skin_microbiome_all_asvs.rds"))
seq2 <- readRDS(file.path(base_dir, "Seq_Run2/dada2_output_pool/canine_skin_microbiome_all_asvs.rds"))
seq3 <- readRDS(file.path(base_dir, "Seq_Run3/dada2_output_pool/canine_skin_microbiome_all_asvs.rds"))
seq4 <- readRDS(file.path(base_dir, "Seq_Run4/dada2_output_pool/canine_skin_microbiome_all_asvs.rds"))

# Merge the tables 
canine_skin_microbiome_all_asvs_seqruns <- mergeSequenceTables(seq1, seq2, seq3, seq4)


if (!dir.exists(target_dir)) {
  dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)
}

write.csv(canine_skin_microbiome_all_asvs_seqruns, 
          file = file.path(target_dir, "canine_skin_microbiome_all_asvs_seqruns.csv"), 
          row.names = TRUE)