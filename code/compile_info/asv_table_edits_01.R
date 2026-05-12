library(data.table)

df <- fread("/home5/sctoth/projects/dog_skin_microbiomes/data/dada2_analysis/CH_All_16S/03_dada2_output/canine_skin_microbiome_all_asvs.csv")

# Extract ASV sequences (first row) and create mapping
asv_sequences <- df[1, -1]  # All columns except first (samples)
asv_names <- paste0("ASV_", 1:ncol(asv_sequences))
colnames(df)[-1] <- asv_names

cat("1. Extracted ASV sequences")

# Write ASV sequence mapping
asv_map <- data.table(
  asv_id = asv_names,
  sequence = asv_sequences
)
fwrite(asv_map, "/home5/sctoth/projects/dog_skin_microbiomes/data/dada2_analysis/CH_All_16S/03_dada2_output/asv_sequences.csv")

cat("2. Complete: asv_sequences.csv")

# Write the table with numbered ASVs (skip first row of sequences)
df_clean <- df[-1, ]  # Remove first row
fwrite(df_clean, "/home5/sctoth/projects/dog_skin_microbiomes/data/dada2_analysis/CH_All_16S/03_dada2_output/canine_skin_microbiome_all_asvs_names.csv")

cat("3. Complete: canine_skin_microbiome_all_asvs_names.csv") 

# Sum reads per sample - use fwrite for consistency/speed
sample_totals <- data.table(
  sample = df_clean[[1]],
  total_reads = rowSums(df_clean[, -1], na.rm = TRUE)
)

fwrite(sample_totals, "/home5/sctoth/projects/dog_skin_microbiomes/data/dada2_analysis/CH_All_16S/03_dada2_output/canine_skin_microbiome_all_asvs_sample_totals.csv")

cat("4. Complete: canine_skin_microbiome_all_asvs_sample_totals.csv") 

# Load the sequence mapping and the filtered ASV table
filtered_df <- fread("/home5/sctoth/projects/dog_skin_microbiomes/data/dada2_analysis/CH_All_16S/03_dada2_output/canine_skin_microbiome_filtered_nochim_asvs.csv")

# Create named vector for sequence -> ASV_ID matching
names(asv_map$sequence) <- asv_map$asv_id

# Replace column headers in filtered table with actual sequences
colnames(filtered_df)[-1] <- asv_map$sequence[match(colnames(filtered_df)[-1], asv_map$asv_id)]

# Write the updated table with sequence headers
fwrite(filtered_df, "/home5/sctoth/projects/dog_skin_microbiomes/data/dada2_analysis/CH_All_16S/03_dada2_output/canine_skin_microbiome_filtered_nochim_asvs_names.csv")

cat("5. canine_skin_microbiome_filtered_nochim_asvs_names.csv")

# Sum reads per sample - use fwrite for consistency/speed
sample_totals <- data.table(
  sample = filtered_df[[1]],
  total_reads = rowSums(filtered_df[, -1], na.rm = TRUE)
)

fwrite(sample_totals, "/home5/sctoth/projects/dog_skin_microbiomes/data/dada2_analysis/CH_All_16S/03_dada2_output/canine_skin_microbiome_filtered_nochim_sample_totals.csv")

cat("6. Complete: canine_skin_microbiome_filtered_nochim_sample_totals.csv") 