#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(dada2)
})

base_dir <- Sys.getenv("SEQ_RUN_SUMMARY_DIR")
database_dir <- Sys.getenv("DATABASE_DIR")

# Get Slurm CPUs 
n_cores <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK"))
 
cat(paste("[", Sys.time(), "] Loading ASV sequence table (.rds)...\n"))
 
seqtab <- readRDS(
  file.path(base_dir, "canine_skin_microbiome_filtered_nochim_asvs.rds")
)

# For a standard dada2 seqtab, rows = samples, columns = unique ASV sequences
n_samples <- nrow(seqtab)
n_asvs <- ncol(seqtab)
cat(paste("[", Sys.time(), "] Successfully loaded data matrix:\n"))
cat(paste("    - Total Samples:", n_samples, "\n"))
cat(paste("    - Total Unique ASVs to classify:", n_asvs, "\n"))

set.seed(100) 

# Assign taxonomy
tax <- assignTaxonomy(
  seqtab, 
  file.path(database_dir, "SILVA_SSUfungi_nr99_v138_2_toGenus_trainset.fa.gz"), 
  multithread = n_cores, 
  verbose=TRUE,
  minBoot = 80
)

cat(paste("[", Sys.time(), "] Taxonomy assignment finished successfully.\n"))


saveRDS(tax, file.path(base_dir, "canine_skin_microbiome_filtered_nochim_asvs_taxa.rds")) 
cat(paste("[", Sys.time(), "] Job complete! Exiting script safely.\n"))