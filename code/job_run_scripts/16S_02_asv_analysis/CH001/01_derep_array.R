#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dada2)
  library(ShortRead)
})

# Get paths and array task ID (1-based)
input_dir <- Sys.getenv("INPUT_DIR")
out_dir <- Sys.getenv("OUT_DIR")
task_id <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))

cat("Task ID:", task_id, "\n")
cat("Data path:", input_dir, "\n")
cat("Output path:", out_dir, "\n")

# Find all fastq files (1-based indexing)
filtF <- sort(list.files(input_dir, pattern="_F_trunc.fastq.gz$", full.names = TRUE))
filtR <- sort(list.files(input_dir, pattern="_R_trunc.fastq.gz$", full.names = TRUE))

if(task_id > length(filtF)) {
  cat("Task", task_id, "exceeds available samples:", length(filtF), "\n")
  q("no")
}

# Select single pair for this task
filtFs <- filtF[task_id]
filtRs <- filtR[task_id]

sampleName <- sapply(strsplit(basename(filtFs), "_"), `[`, 1)
cat(sprintf("Processing sample %d/%d: %s\n", task_id, length(filtF), sampleName))

# input paths
filt_path <- file.path(out_dir)
filtF <- file.path(filt_path, paste0(sampleName, "_F_trunc.fastq.gz"))
filtR <- file.path(filt_path, paste0(sampleName, "_R_trunc.fastq.gz"))

derepFs <- derepFastq(filtF, verbose=TRUE)
derepRs <- derepFastq(filtR, verbose=TRUE) 
names(derepFs) <- sampleName
names(derepRs) <- sampleName

 
