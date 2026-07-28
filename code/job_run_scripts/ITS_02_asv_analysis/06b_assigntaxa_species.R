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
  file.path(base_dir, "canine_skin_microbiome_filtered_nochim_asvs_taxa.rds")
)

# For a standard dada2 seqtab, rows = samples, columns = unique ASV sequences
n_asvs <- nrow(seqtab)
cat(paste("[", Sys.time(), "] Successfully loaded data matrix:\n"))
cat(paste("    - Total Unique ASVs to classify:", n_asvs, "\n"))

set.seed(100) 

# Assign taxonomy
tax <- addSpecies(
  seqtab, 
  file.path(database_dir, "SILVA_SSUfungi_assignSpecies.fa.gz"), 
  verbose=TRUE
)
 
cat(paste("[", Sys.time(), "] Taxonomy assignment finished successfully.\n"))


saveRDS(tax, file.path(base_dir, "canine_skin_microbiome_filtered_nochim_asvs_taxa_species.rds"))

cat(paste("[", Sys.time(), "] Job complete! Exiting script safely.\n"))