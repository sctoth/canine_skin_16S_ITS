#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dada2)
  library(data.table)
})

# Get paths
base_dir  <- Sys.getenv("SEQ_RUN_SUMMARY_DIR")

# 2. Read data
df <- fread(file.path(base_dir, "canine_skin_microbiome_all_asvs_seqruns.csv"))

# Extract the FULL sequences directly from the column headers (excluding the first column, e.g., Sample_ID)
full_sequences <- colnames(df)[-1]

# Create your ASV IDs (ASV_1, ASV_2, etc.) based on how many sequences there are
asv_names <- paste0("ASV_", seq_along(full_sequences))

# Rename the columns in your main df to the short ASV IDs in-place (saves massive RAM)
setnames(df, old = 2:ncol(df), new = asv_names)

cat("1. Extracted ASV sequences\n")

# Write the mapping of ASV IDs to the full DNA sequences
asv_map <- list(
  asv_id = asv_names,
  sequence = full_sequences
)
setDT(asv_map)

# Save the full mapping file
fwrite(asv_map, file.path(base_dir, "seqruns_asv_sequences.csv"))

cat("2. Complete: seqruns_asv_sequences.csv\n")

# Write the table with numbered ASVs (skip first row of sequences)
fwrite(df, file.path(base_dir, "canine_skin_microbiome_all_asvs_seqruns_names.csv"))

cat("3. Complete: canine_skin_microbiome_all_asvs_seqruns_names.csv") 

# Sum reads per sample - use fwrite for consistency/speed
sample_totals <- data.table(
  sample = df[[1]],
  total_reads = rowSums(df[, -1], na.rm = TRUE)
)

fwrite(sample_totals, file.path(base_dir, "canine_skin_microbiome_all_asvs_seqruns_sample_totals.csv"))

cat("4. Complete: canine_skin_microbiome_all_asvs_seqruns_sample_totals.csv") 

# Load the sequence mapping and the filtered ASV table
filtered_df <- fread(file.path(base_dir, "canine_skin_microbiome_filtered_nochim_asvs.csv"))

# 1. Create a named vector: names are sequences, values are ASV IDs
seq_to_asv_id <- asv_map$asv_id
names(seq_to_asv_id) <- asv_map$sequence

# 2. Extract current headers (excluding the first column, usually SampleID)
current_headers <- colnames(filtered_df)[-1]

# 3. Match and replace the sequence headers with the corresponding ASV IDs
colnames(filtered_df)[-1] <- seq_to_asv_id[current_headers]

# Write the updated table with sequence headers
fwrite(filtered_df, file.path(base_dir, "canine_skin_microbiome_filtered_nochim_asvs_seqruns_names.csv"))

cat("5. canine_skin_microbiome_filtered_nochim_asvs_seqruns_names.csv")

# Sum reads per sample - use fwrite for consistency/speed
sample_totals <- data.table(
  sample = filtered_df[[1]],
  total_reads = rowSums(filtered_df[, -1], na.rm = TRUE)
)

fwrite(sample_totals, file.path(base_dir, "canine_skin_microbiome_filtered_nochim_asvs_seqruns_sample_totals.csv"))

cat("6. Complete: canine_skin_microbiome_filtered_nochim_asvs_seqruns_sample_totals.csv") 