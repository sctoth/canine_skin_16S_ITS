#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dada2)
  library(ShortRead)
  library(ggplot2)
})

input_dir <- Sys.getenv("INPUT_SUBDIR")
sample_name <- Sys.getenv("SAMPLE_NAME")
out_dir <- Sys.getenv("OUT_SUBDIR")
n_threads <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "1"))

cat("Sample:", sample_name, "\n")
cat("Input path:", input_dir, "\n")
cat("Output path:", out_dir, "\n")

if (input_dir == "" || sample_name == "" || out_dir == "") {
  stop("SAMPLE_NAME, INPUT_SUBDIR, and/or OUT_SUBDIR not set")
}

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# Find all fastq files for this sample directory
filtFs <- sort(list.files(input_dir, pattern = "_F_trunc.fastq.gz$", full.names = TRUE))
filtRs <- sort(list.files(input_dir, pattern = "_R_trunc.fastq.gz$", full.names = TRUE))


cat("Found", length(filtFs), "forward and", length(filtRs), "reverse files\n")

if (length(filtFs) == 0 || length(filtRs) == 0) {
  stop("No matching files found")
}

if (length(filtFs) != length(filtRs)) {
  stop("Forward/reverse file counts do not match")
}

sampleNames <- sub("_F_trunc.fastq.gz$", "", basename(filtFs))
names(filtFs) <- sampleNames
names(filtRs) <- sampleNames

# Process ALL files in this directory (one SLURM task = one directory)
for (i in seq_along(filtFs)) {
  curr_name <- sampleNames[i]
  cat(sprintf("Processing %d/%d: %s\n", i, length(filtFs), curr_name))
  
  derepFs <- derepFastq(filtFs[i], verbose = TRUE)
  derepRs <- derepFastq(filtRs[i], verbose = TRUE)
  names(derepFs) <- curr_name
  names(derepRs) <- curr_name
  
  # Save dereplicated objects
  saveRDS(derepFs, file.path(out_dir, paste0("derepF_", curr_name, ".rds")))
  saveRDS(derepRs, file.path(out_dir, paste0("derepR_", curr_name, ".rds")))
  
}

cat(sprintf("%s directory complete (%d pairs)\n", curr_name, length(filtFs)))