#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dada2)
  library(ShortRead)
  library(ggplot2)
})

# Get paths and array task ID (1-based)
input_dir <- Sys.getenv("INPUT_DIR")
out_dir <- Sys.getenv("OUT_DIR")

cat("Data path:", input_dir, "\n")
cat("Output path:", out_dir, "\n")

# Find all fastq files (1-based indexing)
filtFs <- sort(list.files(input_dir, pattern="_F_trunc.fastq.gz$", full.names = TRUE))
filtRs <- sort(list.files(input_dir, pattern="_R_trunc.fastq.gz$", full.names = TRUE))

cat("Found", length(filtFs), "forward and", length(filtRs), "reverse files\n")
if(length(filtFs) == 0 || length(filtRs) == 0) {
  stop("No matching CH001 files found!")
}
sampleNames <- sapply(strsplit(basename(filtFs), "_"), `[`, 1)
names(filtFs) <- sampleNames
names(filtRs) <- sampleNames

errF <- learnErrors(filtFs, multithread=TRUE)
errR <- learnErrors(filtRs, multithread=TRUE)

# Plot errors
errF_plot <- plotErrors(errF, nominalQ = TRUE)
errR_plot <- plotErrors(errR, nominalQ = TRUE)

# Save global error plots
F_learnErrors_global <- file.path(out_dir, "learnErrors_F_CH001.png")
R_learnErrors_global <- file.path(out_dir, "learnErrors_R_CH001.png")
ggsave(F_learnErrors_global, errF_plot, width = 10, height = 8, dpi = 300)
ggsave(R_learnErrors_global, errR_plot, width = 10, height = 8, dpi = 300)

saveRDS(errF, file.path(out_dir, "errF_CH001.rds"))
saveRDS(errR, file.path(out_dir, "errR_CH001.rds"))

cat("CH001 learnErrors complete.\n")
 
