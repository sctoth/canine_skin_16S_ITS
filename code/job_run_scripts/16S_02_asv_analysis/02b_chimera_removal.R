#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dada2)
  library(ggplot2)
  library(data.table)
})

# Get paths
out_dir2  <- Sys.getenv("DADA2_DIR")
n_threads <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "1"))


cat("Dada2 output path:", out_dir2, "\n")

# Track start time
job_start_time <- Sys.time()
cat("Start time:", format(job_start_time, "%Y-%m-%d %H:%M:%S"), "\n\n")

# 1. Read the CSV file
seqtabAll_dt <- fread(file.path(out_dir2, "canine_skin_microbiome_all_asvs_seqruns.csv"))

# 2. Convert to a standard matrix (assuming the first column contains row names/sample IDs)
seqtabAll_mat <- as.matrix(seqtabAll_dt[, -1, with = FALSE])
rownames(seqtabAll_mat) <- seqtabAll_dt[[1]]

# 3. Ensure data is numeric/integer
class(seqtabAll_mat) <- "integer"

# 4. Run chimera removal on the valid matrix
seqtabNoC <- removeBimeraDenovo(seqtabAll_mat, multithread=n_threads)

# Save results
saveRDS(seqtabNoC, file.path(out_dir2, "canine_skin_microbiome_filtered_nochim_asvs_pseudo.rds"))
seqtabNoC <- readRDS(file.path(out_dir2, "canine_skin_microbiome_filtered_nochim_asvs_pseudo.rds"))
write.csv(seqtabNoC, file.path(out_dir2, "canine_skin_microbiome_filtered_nochim_asvs_pseudo.csv"))

# Final summary
cat("=== ASV TABLE SUMMARY ===\n")
cat("Samples:", ncol(seqtabNoC), "\n")
cat("ASVs:", nrow(seqtabNoC), "\n")
cat("Total reads:", sum(seqtabNoC), "\n")
cat("Mean reads/sample:", round(mean(colSums(seqtabNoC)), 1), "\n")
cat("Median reads/sample:", round(median(colSums(seqtabNoC)), 1), "\n")
cat("Min reads/sample:", min(colSums(seqtabNoC)), "\n")
cat("Max reads/sample:", max(colSums(seqtabNoC)), "\n\n")

# End time and duration
end_time <- Sys.time()
duration <- end_time - job_start_time
cat("End time:", format(end_time, "%Y-%m-%d %H:%M:%S"), "\n")
cat("Total runtime:", round(as.numeric(duration, units="mins"), 1), "minutes\n")
cat("Script complete.\n")