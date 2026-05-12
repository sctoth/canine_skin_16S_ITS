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
cat("Dereplicating forward reads.\n")
derepFs <- derepFastq(filtFs)
names(derepFs) <- sampleNames

cat("Dereplicating reverse reads.\n")
derepRs <- derepFastq(filtRs)
names(derepRs) <- sampleNames

cat("Dereplification complete:", length(derepFs), "forward and", length(derepRs), "reverse objects\n")

# 3) Learn errors 
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

# 4) Denoise
cat("Denoising forward reads.\n")
dadaFs <- dada(derepFs, err=errF, pool="pseudo", multithread=n_threads)

cat("Denoising reverse reads.\n")
dadaRs <- dada(derepRs, err=errR, pool="pseudo", multithread=n_threads)

# 5) Merge, sequence table, chimera removal 
cat("Merging paired-end reads.\n")
mergers <- mergePairs(dadaFs, derepFs, dadaRs, derepRs)

seqtabAll <- makeSequenceTable(mergers)
saveRDS(seqtabAll, file.path(out_dir2, "canine_skin_microbiome_all_asvs.rds"))

seqtabNoC <- removeBimeraDenovo(seqtabAll, multithread=n_threads)
saveRDS(seqtabNoC, file.path(out_dir2, "canine_skin_microbiome_filtered_nochim_asvs.rds"))


seqtabAll <- readRDS("canine_skin_microbiome_all_asvs.rds")
seqtabNoC <- readRDS("canine_skin_microbiome_filtered_nochim_asvs.rds")

write.csv(seqtabNoC, file.path(out_dir2, "canine_skin_microbiome_filtered_nochim_asvs.csv"))