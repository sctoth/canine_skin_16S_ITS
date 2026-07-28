#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dada2)
  library(ShortRead)
})

# Get paths and array task ID (1-based)
miseq_path <- Sys.getenv("INPUT_DIR")
out_dir <- Sys.getenv("OUT_DIR")
task_id <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))

cutadapt <- "cutadapt"
system2(cutadapt, args = "--version")  # sanity check

cat("Task ID:", task_id, "\n")
cat("Data path:", miseq_path, "\n")
cat("Output path:", out_dir, "\n")

task_id <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))
fnFs.filtN <- sort(list.files(miseq_path, pattern="_F_filtN.fastq.gz$", full.names = TRUE))
fnRs.filtN <- sort(list.files(miseq_path, pattern="_R_filtN.fastq.gz$", full.names = TRUE))
stopifnot(length(fnFs.filtN) == length(fnRs.filtN))

i <- task_id
if (i < 1 || i > length(fnFs.filtN)) stop("task_id out of range: ", i)

fF <- fnFs.filtN[i]
fR <- fnRs.filtN[i]

FWD <- "CTTGGTCATTTAGAGGAAGTAA"   
REV <- "GCTGCGTTCTTCATCGATGC"  

FWD.RC <- dada2:::rc(FWD)
REV.RC <- dada2:::rc(REV)

outF <- file.path(out_dir, basename(sub("_F_filtN.fastq.gz$", "_1.fastq.gz", fF)))
outR <- file.path(out_dir, basename(sub("_R_filtN.fastq.gz$", "_2.fastq.gz", fR)))


# Trim FWD and the reverse-complement of REV off of R1 (forward reads)
R1.flags <- paste("-g", FWD, "-a", REV.RC) 
# Trim REV and the reverse-complement of FWD off of R2 (reverse reads)
R2.flags <- paste("-G", REV, "-A", FWD.RC) 

system2(
  cutadapt,
  args = c(
    R1.flags, R2.flags, "-n", 2,
    "--minimum-length", "1",
    "-o", outF, "-p", outR,
    fF, fR
  )
)

 
 