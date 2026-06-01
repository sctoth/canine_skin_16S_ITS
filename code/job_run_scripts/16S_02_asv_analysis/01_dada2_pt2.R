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


# 1) Find FASTQ files 
filtFs <- sort(list.files(input_dir, pattern="_F_trunc.fastq.gz$", full.names=TRUE, recursive=TRUE))
filtRs <- sort(list.files(input_dir, pattern="_R_trunc.fastq.gz$", full.names=TRUE, recursive=TRUE))

cat("Found", length(filtFs), "forward and", length(filtRs), "reverse FASTQ files\n")

if (length(filtFs) == 0 || length(filtRs) == 0) stop("No matching FASTQ files found!")
if (length(filtFs) != length(filtRs)) stop("Forward/reverse FASTQ counts do not match!")

sampleNames <- sub("_F_trunc.fastq.gz$", "", basename(filtFs))
names(filtFs) <- sampleNames
names(filtRs) <- sampleNames

if (!identical(
  sub("_F_trunc.fastq.gz$", "", basename(filtFs)),
  sub("_R_trunc.fastq.gz$", "", basename(filtRs))
)) stop("Forward and reverse sample names don't match!")

cat("Any NAs in sample names?", any(is.na(sampleNames)), "\n")
cat("Any duplicate sample names?", any(duplicated(sampleNames)), "\n")
cat(length(sampleNames), "samples to process\n")

# 2) Dereplicate
start_time <- Sys.time()
cat("Dereplicate start time:", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n")

cat("Dereplicating forward reads.\n")
derepFs <- derepFastq(filtFs)
names(derepFs) <- sampleNames

cat("Dereplicating reverse reads.\n")
derepRs <- derepFastq(filtRs)
names(derepRs) <- sampleNames

cat("Dereplification complete:", length(derepFs), "forward and", length(derepRs), "reverse objects\n")

end_time <- Sys.time()
duration <- end_time - start_time
cat("Dereplicate: End time:", format(end_time, "%Y-%m-%d %H:%M:%S"), "\n")
cat("Dereplicate: Total runtime:", round(as.numeric(duration, units="mins"), 1), "minutes\n")

# 3) Learn errors 
start_time <- Sys.time()
cat("Learn errors start time:", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n")

cat("Learning error rates: forward reads.\n")
errF <- learnErrors(derepFs, nbases=1e8, randomize=TRUE, verbose=TRUE, multithread=n_threads)

cat("Learning error rates: reverse reads.\n")
errR <- learnErrors(derepRs, nbases=1e8, randomize=TRUE, verbose=TRUE, multithread=n_threads)

# Save error plots
ggsave(file.path(out_dir, "learnerrors_F_output.png"), plotErrors(errF, nominalQ=TRUE), width=10, height=8, dpi=300)
ggsave(file.path(out_dir, "learnerrors_R_output.png"), plotErrors(errR, nominalQ=TRUE), width=10, height=8, dpi=300)
saveRDS(errF, file.path(out_dir, "errF_output.rds"))
saveRDS(errR, file.path(out_dir, "errR_output.rds"))
cat("learnErrors complete.\n")

errF <- readRDS(file.path(out_dir, "errF_output.rds"))
errR <- readRDS(file.path(out_dir, "errR_output.rds"))

end_time <- Sys.time()
duration <- end_time - start_time
cat("Learnerrors: End time:", format(end_time, "%Y-%m-%d %H:%M:%S"), "\n")
cat("Learnerrors: Total runtime:", round(as.numeric(duration, units="mins"), 1), "minutes\n")

# 4) Denoise
start_time <- Sys.time()
cat("Denoise start time:", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n")

cat("Denoising forward reads.\n")
dadaFs <- dada(derepFs, err=errF, pool="pseudo", multithread=n_threads)

cat("Denoising reverse reads.\n")
dadaRs <- dada(derepRs, err=errR, pool="pseudo", multithread=n_threads)

cat("Saving rds files of dadaR and dadaF objects.\n")
saveRDS(dadaFs, file.path(out_dir2, "dadaFs_canine_skin_microbiome.rds"))
saveRDS(dadaRs, file.path(out_dir2, "dadaRs_canine_skin_microbiome.rds"))

cat("Getting read counts after denoising per sample.\n")
# read counts after denoising, by sample
denoisedF <- sapply(dadaFs, function(x) sum(getUniques(x)))
denoisedR <- sapply(dadaRs, function(x) sum(getUniques(x)))

# combine into a data frame
denoised_counts <- data.frame(
  sample = names(denoisedF),
  denoised_forward = denoisedF,
  denoised_reverse = denoisedR,
  stringsAsFactors = FALSE
)

# save to CSV
write.csv(
  denoised_counts,
  file = file.path(out_dir2, "denoised_reads_per_sample.csv"),
  row.names = FALSE
)

# total reads after denoising, before merging
total_forward_denoised <- sum(denoisedF)
total_reverse_denoised <- sum(denoisedR)

cat(
  "Total forward reads (after denoising, before merging):",
  total_forward_denoised, "\n"
)

cat(
  "Total reverse reads (after denoising, before merging):",
  total_reverse_denoised, "\n"
)


# 5) Merge paired-end reads 

start_time <- Sys.time()

cat(
  "Merging and chimera removal start time:",
  format(start_time, "%Y-%m-%d %H:%M:%S"),
  "\n"
)

cat("Merging paired-end reads.\n")

# merge forward and reverse reads
mergers <- mergePairs(dadaFs, derepFs, dadaRs, derepRs)

# construct ASV table
seqtabAll <- makeSequenceTable(mergers)

cat("Total merged reads:", sum(seqtabAll), "\n")
cat("Number of ASVs before chimera removal:", ncol(seqtabAll), "\n")

# save ASV table before chimera removal
saveRDS(
  seqtabAll,
  file.path(out_dir2, "canine_skin_microbiome_all_asvs.rds")
)

write.csv(
  seqtabAll,
  file.path(out_dir2, "canine_skin_microbiome_all_asvs.csv")
)


end_time <- Sys.time()
duration <- end_time - start_time

cat(
  "Merging paired-end reads End time:",
  format(end_time, "%Y-%m-%d %H:%M:%S"),
  "\n"
)

cat(
  "Merging paired-end reads: Total runtime:",
  round(as.numeric(duration, units = "mins"), 1),
  "minutes\n"
)
# Final summary
cat("=== POST-DENOISING ASV TABLE SUMMARY ===\n")
cat("Samples:", ncol(seqtabAll), "\n")
cat("ASVs:", nrow(seqtabAll), "\n")
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