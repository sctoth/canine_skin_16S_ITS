#!/bin/bash

# Define paths
KIT_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_16S/06_truncR150_maxEE22_output/Kit"
CHLOR_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_16S/06_truncR150_maxEE22_output/Chlor"
RUN1_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_16S/06_truncR150_maxEE22_output/Seq_Run1"
RUN2_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_16S/06_truncR150_maxEE22_output/Seq_Run2"
RUN3_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_16S/06_truncR150_maxEE22_output/Seq_Run3"
RUN4_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_16S/06_truncR150_maxEE22_output/Seq_Run4"


# Ensure target directories exist
mkdir -p "$RUN1_DIR"
mkdir -p "$RUN2_DIR"
mkdir -p "$RUN3_DIR"
mkdir -p "$RUN4_DIR"

cd "/home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_16S/05_truncR175_maxEE2-5_output" 

mv "CH001" "Seq_Run1"
mv "CH003" "Seq_Run2"
mv "CH005" "Seq_Run1"
mv "CH006" "Seq_Run1"
mv "CH008" "Seq_Run1"
mv "CH009" "Seq_Run3"
mv "CH011" "Seq_Run2"
mv "CH012" "Seq_Run1"
mv "CH013" "Seq_Run2"
mv "CH014" "Seq_Run2"
mv "CH016" "Seq_Run2"
mv "CH017" "Seq_Run4"
mv "CH018" "Seq_Run4"
mv "CH019" "Seq_Run4"
mv "CH020" "Seq_Run3"
mv "CH021" "Seq_Run4"
mv "CH022" "Seq_Run3"
mv "CH023" "Seq_Run4"
mv "CH024" "Seq_Run3"
mv "CH025" "Seq_Run3"

# Move files strictly adhering to the first column names in your image
for file in "$KIT_DIR"/*_trunc.fastq.gz; do
    [ -e "$file" ] || continue
    filename=$(basename "$file")

    # Match exact prefixes from your column layout
    case "$filename" in
        Kit1-16S*)
            mv "$file" "$RUN1_DIR/" ;;
        CH1KitCtrl1-*)
            mv "$file" "$RUN2_DIR/" ;;
        Kit2-16S*)
            mv "$file" "$RUN1_DIR/" ;;
        CH2KitCtrl1-*)
            mv "$file" "$RUN2_DIR/" ;;
        CH2KitCtrl2-*)
            mv "$file" "$RUN2_DIR/" ;;
        CH3KitCtrl1-*)
            mv "$file" "$RUN2_DIR/" ;;
        CH4-Kit-Ctrl*)
            mv "$file" "$RUN3_DIR/" ;;
        CH5-Kit-Ctrl*)
            mv "$file" "$RUN3_DIR/" ;;
        CH5b-Kit-Ctrl*)
            mv "$file" "$RUN4_DIR/" ;;
        CH6-Kit-Ctrl*)
            mv "$file" "$RUN4_DIR/" ;;
        *)
            echo "Warning: No explicit matching row rule for $filename. Skipping." ;;
    esac
done

# Move files strictly adhering to the first column names in your image
for file in "$CHLOR_DIR"/*_trunc.fastq.gz; do
    [ -e "$file" ] || continue
    filename=$(basename "$file")

    # Match exact prefixes from your column layout
    case "$filename" in
        Chlor1-16S*)
            mv "$file" "$RUN1_DIR/" ;;
        Chlor1b-16S*)
            mv "$file" "$RUN2_DIR/" ;;
        Chlor2-16S*)
            mv "$file" "$RUN1_DIR/" ;;
        Chlor2b-16S*)
            mv "$file" "$RUN2_DIR/" ;;
        Chlor3-16S*)
            mv "$file" "$RUN1_DIR/" ;;
        Chlor3b-16S*)
            mv "$file" "$RUN2_DIR/" ;;
        *)
            echo "Warning: No explicit matching row rule for $filename. Skipping." ;;
    esac
done
echo "File sorting completed successfully."
