#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dada2)
  library(ggplot2)
})

# Get paths
input_dir <- Sys.getenv("INPUT_DIR")
out_dir   <- Sys.getenv("LEARNERROR_DIR")
out_dir2  <- Sys.getenv("DADA2_DIR")
n_threads <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "1"))

cat("Filtered FASTQ path:", input_dir, "\n")
cat("Learn-error output path:", out_dir, "\n")
cat("Dada2 output path:", out_dir2, "\n")

# Track start time
job_start_time <- Sys.time()
cat("Start time:", format(job_start_time, "%Y-%m-%d %H:%M:%S"), "\n\n")


# Find forward FASTQ files 
filtFs <- sort(list.files(input_dir, pattern="_1_filtered.fastq.gz$", full.names=TRUE, recursive=TRUE))
 
cat("Found", length(filtFs), "forward reads\n")

 
sampleNames <- sub("_1_filtered.fastq.gz$", "", basename(filtFs))
names(filtFs) <- sampleNames
  

cat("Any NAs in sample names?", any(is.na(sampleNames)), "\n")
cat("Any duplicate sample names?", any(duplicated(sampleNames)), "\n")
cat(length(sampleNames), "samples to process\n")

# Dereplicate
start_time <- Sys.time()
cat("Dereplicate start time:", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n")

cat("Dereplicating forward reads.\n")
derepFs <- derepFastq(filtFs)
names(derepFs) <- sampleNames
 
cat("Dereplification complete:", length(derepFs), "forward reads\n")

end_time <- Sys.time()
duration <- end_time - start_time
cat("Dereplicate: End time:", format(end_time, "%Y-%m-%d %H:%M:%S"), "\n")
cat("Dereplicate: Total runtime:", round(as.numeric(duration, units="mins"), 1), "minutes\n")

# Learn errors 
start_time <- Sys.time()
cat("Learn errors start time:", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n")

cat("Learning error rates: forward reads.\n")
errF <- learnErrors(derepFs, nbases=1e8, randomize=TRUE, verbose=TRUE, multithread=n_threads)
 
# Save error plots
p_err <- plotErrors(errF, nominalQ=TRUE)
ggsave(file.path(out_dir, "learnerrors_F_output.png"), plot=p_err, width=10, height=8, dpi=300)
cat("learnErrors complete.\n")


end_time <- Sys.time()
duration <- end_time - start_time
cat("Learnerrors: End time:", format(end_time, "%Y-%m-%d %H:%M:%S"), "\n")
cat("Learnerrors: Total runtime:", round(as.numeric(duration, units="mins"), 1), "minutes\n")

# 4) Denoise
start_time <- Sys.time()
cat("Denoise start time:", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n")

cat("Denoising forward reads.\n")
dadaFs <- dada(derepFs, err=errF, pool=TRUE, multithread=n_threads)
 
cat("Getting read counts after denoising per sample.\n")
# read counts after denoising, by sample
denoisedF <- sapply(dadaFs, function(x) sum(getUniques(x)))
 
# combine into a data frame
denoised_counts <- data.frame(
  sample = names(denoisedF),
  denoised_forward = denoisedF,
  stringsAsFactors = FALSE
)

# save to CSV
write.csv(
  denoised_counts,
  file = file.path(out_dir2, "denoised_fwd_reads_per_sample.csv"),
  row.names = FALSE
)

# total reads after denoising, before merging
total_forward_denoised <- sum(denoisedF)

cat(
  "Total forward reads (after denoising):",
  total_forward_denoised, "\n"
)


# construct ASV table
seqtabAll <- makeSequenceTable(dadaFs)

cat("Total reads:", sum(seqtabAll), "\n")
cat("Number of ASVs before chimera removal:", ncol(seqtabAll), "\n")

# save ASV table before chimera removal
saveRDS(
  seqtabAll,
  file.path(out_dir2, "canine_skin_microbiome_all_asvs.rds")
)
 

end_time <- Sys.time()
duration <- end_time - start_time

# Final summary
cat("=== POST-DENOISING ASV TABLE SUMMARY ===\n")
cat("Samples:", nrow(seqtabAll), "\n")
cat("ASVs:", ncol(seqtabAll), "\n")
cat("Total reads:", sum(seqtabAll), "\n")
cat("Mean reads/sample:", round(mean(colSums(seqtabAll)), 1), "\n")
cat("Median reads/sample:", round(median(colSums(seqtabAll)), 1), "\n")
cat("Min reads/sample:", min(colSums(seqtabAll)), "\n")
cat("Max reads/sample:", max(colSums(seqtabAll)), "\n\n")


# End time and duration
end_time <- Sys.time()
duration <- end_time - job_start_time
cat("End time:", format(end_time, "%Y-%m-%d %H:%M:%S"), "\n")
cat("Total runtime:", round(as.numeric(duration, units="mins"), 1), "minutes\n")
cat("Script complete.\n")