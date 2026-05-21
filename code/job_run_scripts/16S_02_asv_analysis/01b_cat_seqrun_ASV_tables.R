#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dada2)
  library(data.table)
})

# Get paths
out_dir2  <- Sys.getenv("DADA2_DIR")
n_threads <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "1"))


cat("Dada2 output path:", out_dir2, "\n")

base_dir <- ("/home5/sctoth/projects/dog_skin_microbiomes/data/dada2_analysis_02/CH_All_16S")
target_dir <- file.path(base_dir, "Seq_Runs_Summary")

# Load the seqtab.rds files from each run
seq1 <- readRDS(file.path(base_dir, "Seq_Run1/03_dada2_output_pool/canine_skin_microbiome_all_asvs.csv"))
seq2 <- readRDS(file.path(base_dir, "Seq_Run2/03_dada2_output_pool/canine_skin_microbiome_all_asvs.csv"))
seq3 <- readRDS(file.path(base_dir, "Seq_Run3/03_dada2_output_pool/canine_skin_microbiome_all_asvs.csv"))
seq4 <- readRDS(file.path(base_dir, "Seq_Run4/03_dada2_output_pool/canine_skin_microbiome_all_asvs.csv"))

# Merge the tables 
canine_skin_microbiome_all_asvs_seqruns <- mergeSequenceTables(seq1, seq2, seq3, seq4)


if (!dir.exists(target_dir)) {
  dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)
}

write.csv(canine_skin_microbiome_all_asvs_seqruns, 
          file = file.path(target_dir, "canine_skin_microbiome_all_asvs_seqruns.csv"), 
          row.names = TRUE)