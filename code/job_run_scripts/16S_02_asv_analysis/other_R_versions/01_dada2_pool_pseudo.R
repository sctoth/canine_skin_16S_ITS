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
#start_time <- Sys.time()
#cat("Learn errors start time:", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n")

#cat("Learning error rates: forward reads.\n")
#errF <- learnErrors(derepFs, nbases=1e8, randomize=TRUE, verbose=TRUE, multithread=n_threads)

#cat("Learning error rates: reverse reads.\n")
#errR <- learnErrors(derepRs, nbases=1e8, randomize=TRUE, verbose=TRUE, multithread=n_threads)

# Save error plots
#ggsave(file.path(out_dir, "learnerrors_F_output.png"), plotErrors(errF, nominalQ=TRUE), width=10, height=8, dpi=300)
#ggsave(file.path(out_dir, "learnerrors_R_output.png"), plotErrors(errR, nominalQ=TRUE), width=10, height=8, dpi=300)
#saveRDS(errF, file.path(out_dir, "errF_output.rds"))
#saveRDS(errR, file.path(out_dir, "errR_output.rds"))
#cat("learnErrors complete.\n")

errF <- readRDS(file.path(out_dir, "errF_output.rds"))
errR <- readRDS(file.path(out_dir, "errR_output.rds"))

#end_time <- Sys.time()
#duration <- end_time - start_time
#cat("Learnerrors: End time:", format(end_time, "%Y-%m-%d %H:%M:%S"), "\n")
#cat("Learnerrors: Total runtime:", round(as.numeric(duration, units="mins"), 1), "minutes\n")

# 4) Denoise
start_time <- Sys.time()
cat("Denoise start time:", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n")

cat("Denoising forward reads.\n")
dadaFs <- dada(derepFs, err=errF, pool="pseudo", multithread=n_threads)

cat("Denoising reverse reads.\n")
dadaRs <- dada(derepRs, err=errR, pool="pseudo", multithread=n_threads)
end_time <- Sys.time()
duration <- end_time - start_time
cat("Denoising: End time:", format(end_time, "%Y-%m-%d %H:%M:%S"), "\n")
cat("Denoising: Total runtime:", round(as.numeric(duration, units="mins"), 1), "minutes\n")


# 5) Merge 
start_time <- Sys.time()
cat("Merging start time:", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n")

cat("Merging paired-end reads.\n")
#mergers <- mergePairs(dadaFs, derepFs, dadaRs, derepRs)
mm <- mergePairs(dadaFs, derepFs, dadaRs, derepRs, returnRejects=TRUE, propagateCol="sequence")
# 1. Calculate the number of unmerged reads (from your 'mm' object)
unmerged_count <- sum(sapply(mm, function(x) sum(x$abundance)))

# 2. Calculate total reads after denoising  
total_denoised <- sum(sapply(dadaFs, function(x) sum(x$denoised)))

# 3. Calculate the percentage of reads lost during merging
pct_lost <- (unmerged_count / total_denoised) * 100

# 4. Print the final summary statement
cat(sprintf("A total of %s reads did not merge, representing %.2f%% of the reads lost after denoising.\n", 
            format(unmerged_count, big.mark=","), pct_lost))



#seqtabAll <- makeSequenceTable(mm)
#saveRDS(seqtabAll, file.path(out_dir2, "canine_skin_microbiome_all_asvs.rds"))

end_time <- Sys.time()
duration <- end_time - start_time
cat("Merging End time:", format(end_time, "%Y-%m-%d %H:%M:%S"), "\n")
cat("Merging Total runtime:", round(as.numeric(duration, units="mins"), 1), "minutes\n")

# 5) Chimera removal 
#start_time <- Sys.time()
#cat("Chimera Removal start time:", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n")

#seqtabNoC <- removeBimeraDenovo(seqtabAll, multithread=n_threads)
##saveRDS(seqtabNoC, file.path(out_dir2, "canine_skin_microbiome_filtered_nochim_asvs.rds"))


#seqtabAll <- readRDS(file.path(out_dir2, "canine_skin_microbiome_all_asvs.rds"))
#seqtabNoC <- readRDS(file.path(out_dir2, "canine_skin_microbiome_filtered_nochim_asvs.rds"))

#write.csv(seqtabAll, file.path(out_dir2, "canine_skin_microbiome_all_asvs.csv"))
#write.csv(seqtabNoC, file.path(out_dir2, "canine_skin_microbiome_filtered_nochim_asvs.csv"))
#end_time <- Sys.time()
#duration <- end_time - start_time
#cat("Merging and chimera removal : End time:", format(end_time, "%Y-%m-%d %H:%M:%S"), "\n")
#cat("Merging and chimera removal : Total runtime:", round(as.numeric(duration, units="mins"), 1), "minutes\n")

# Final summary
#cat("=== ASV TABLE SUMMARY ===\n")
#cat("Samples:", ncol(seqtabNoC), "\n")
#cat("ASVs:", nrow(seqtabNoC), "\n")
#cat("Total reads:", sum(seqtabNoC), "\n")
#cat("Mean reads/sample:", round(mean(colSums(seqtabNoC)), 1), "\n")
#cat("Median reads/sample:", round(median(colSums(seqtabNoC)), 1), "\n")
#cat("Min reads/sample:", min(colSums(seqtabNoC)), "\n")
#cat("Max reads/sample:", max(colSums(seqtabNoC)), "\n\n")

# End time and duration
#end_time <- Sys.time()
#duration <- end_time - job_start_time
#cat("End time:", format(end_time, "%Y-%m-%d %H:%M:%S"), "\n")
##cat("Total runtime:", round(as.numeric(duration, units="mins"), 1), "minutes\n")
#cat("Script complete.\n")