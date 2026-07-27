#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dada2)
  library(ShortRead)
  library(Biostrings)
})

# Get paths and array task ID (1-based)
miseq_path <- Sys.getenv("INPUT_DIR")
task_id <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))

cat("Task ID:", task_id, "\n")
cat("Data path:", miseq_path, "\n")
 

# Find all fastq files (1-based indexing)
fnFs <- sort(list.files(miseq_path, pattern="_F_filtN.fastq.gz$", full.names = TRUE))
fnRs <- sort(list.files(miseq_path, pattern="_R_filtN.fastq.gz$", full.names = TRUE))

FWD <- "CTTGGTCATTTAGAGGAAGTAA"   
REV <- "GCTGCGTTCTTCATCGATGC"  

allOrients <- function(primer) {
    # Create all orientations of the input sequence
    require(Biostrings)
    dna <- DNAString(primer)  # The Biostrings works w/ DNAString objects rather than character vectors
    orients <- c(Forward = dna, Complement = Biostrings::complement(dna), Reverse = Biostrings::reverse(dna),
        RevComp = Biostrings::reverseComplement(dna))
    return(sapply(orients, toString))  # Convert back to character vector
}
FWD.orients <- allOrients(FWD)
REV.orients <- allOrients(REV)
 

primerHits <- function(primer, fn) {
    # Counts number of reads in which the primer is found
    nhits <- vcountPattern(primer, sread(readFastq(fn)), fixed = FALSE)
    return(sum(nhits > 0))
}
res <- rbind(
    FWD.ForwardReads = sapply(FWD.orients, primerHits, fn = fnFs[[1]]),
    FWD.ReverseReads = sapply(FWD.orients, primerHits, fn = fnRs[[1]]),
    REV.ForwardReads = sapply(REV.orients, primerHits, fn = fnFs[[1]]),
    REV.ReverseReads = sapply(REV.orients, primerHits, fn = fnRs[[1]])
)


sink("primer_orientation_results.txt")
print(FWD.orients)
print(res)
sink()

 

 