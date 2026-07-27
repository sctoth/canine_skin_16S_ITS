#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dada2)
  library(ShortRead)
})

# Get paths and array task ID (1-based)
miseq_path <- Sys.getenv("INPUT_DIR")
out_dir <- Sys.getenv("OUT_DIR")
task_id <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))

cat("Task ID:", task_id, "\n")
cat("Data path:", miseq_path, "\n")
cat("Output path:", out_dir, "\n")

# Find all fastq files (1-based indexing)
fnFs_all <- sort(list.files(miseq_path, pattern="_F_trimmed.fastq.gz$", full.names = TRUE))
fnRs_all <- sort(list.files(miseq_path, pattern="_R_trimmed.fastq.gz$", full.names = TRUE))

if(task_id > length(fnFs_all)) {
  cat("Task", task_id, "exceeds available samples:", length(fnFs_all), "\n")
  q("no")
}

# Select single pair for this task
fnFs <- fnFs_all[task_id]
fnRs <- fnRs_all[task_id]

sampleName <- sapply(strsplit(basename(fnFs), "_"), `[`, 1)
cat(sprintf("Processing sample %d/%d: %s\n", task_id, length(fnFs_all), sampleName))

# Output paths
filt_path <- file.path(out_dir)
filtF <- file.path(filt_path, paste0(sampleName, "_F_trunc.fastq.gz"))
filtR <- file.path(filt_path, paste0(sampleName, "_R_trunc.fastq.gz"))

# Filter and trim pairs
out <- filterAndTrim(fnFs, filtF, fnRs, filtR, 
                     truncLen=c(200, 150), maxN=0, maxEE=c(2,2), 
                     truncQ=2, rm.phix=TRUE, compress=TRUE, 
                     multithread=TRUE, verbose=TRUE)

cat("Results for", sampleName, ":\n")
print(out)

# Save individual stats
saveRDS(out, file.path(out_dir, sprintf("stats_%s.rds", sampleName)))