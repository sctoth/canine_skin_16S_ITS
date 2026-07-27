#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dada2)
  library(ShortRead)
})

# Get paths from SLURM environment variables
miseq_path <- Sys.getenv("DATA_DIR")
out_dir <- Sys.getenv("OUT_DIR")

cat("Data path:", miseq_path, "\n")
cat("Output path:", out_dir, "\n")

# Find fastq files
fnFs <- sort(list.files(miseq_path, pattern="_F_trunc.fastq.gz$", full.names = TRUE, recursive = TRUE))
fnRs <- sort(list.files(miseq_path, pattern="_R_trunc.fastq.gz$", full.names = TRUE, recursive = TRUE))

if(length(fnFs) == 0) stop("No forward reads found!")
if(length(fnRs) == 0) stop("No reverse reads found!")
if(length(fnFs) != length(fnRs)) stop("Forward/reverse count mismatch!")

sampleNames <- sapply(strsplit(basename(fnFs), "_"), `[`, 1)

cat(sprintf("Found %d forward, %d reverse files\n", length(fnFs), length(fnRs)))

# Quality plots (first 3 samples)
png(file.path(out_dir, "fwd_quality_profile.png"), width=12, height=8, units="in", res=300)
print(plotQualityProfile(fnFs[1:min(3,length(fnFs))]))
dev.off()

png(file.path(out_dir, "rev_quality_profile.png"), width=12, height=8, units="in", res=300)
print(plotQualityProfile(fnRs[1:min(3,length(fnRs))]))
dev.off()

png(file.path(out_dir, "fwd_quality_all.png"), width=12, height=8, units="in", res=300)
print(plotQualityProfile(fnFs, aggregate=TRUE))
dev.off()

png(file.path(out_dir, "rev_quality_all.png"), width=12, height=8, units="in", res=300)
print(plotQualityProfile(fnRs, aggregate=TRUE))
dev.off()
 