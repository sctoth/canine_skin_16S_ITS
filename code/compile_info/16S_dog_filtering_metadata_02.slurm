#!/bin/bash
#SBATCH --job-name=read_counts_summary
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/code/compile_info/logs/dog_seq_metadata_%j.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/code/compile_info/logs/dog_seq_metadata_%j.err

set -euo pipefail

BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data"
RAW_DIR="$BASE_DIR/raw/CH_All_16S/CH_All_16S_multiqc"
TRIMMED_DIR="$BASE_DIR/processed/CH_All_16S/01_trimleft_output/trimleft_multiqc_output"
TRUNC_DIR="$BASE_DIR/processed/CH_All_16S/02_trunc_output/trunc_multiqc_output"
METADATA="$BASE_DIR/metadata/CH-All_16S_Metadata_20220124.tsv"
OUT_DIR="$BASE_DIR/processed/CH_All_16S/summary_read_counts"

mkdir -p "$OUT_DIR"

# Loop through all subdirectory variations
for proc_txt in "$TRUNC_DIR"/{CH,Chlor,Kit}*_multiqc_report_data/multiqc_fastqc.txt; do
    [[ -f "$proc_txt" ]] || continue

    ch_base=$(basename "$(dirname "$proc_txt")")
    ch_name=${ch_base%%_multiqc_report_data}
    
    raw_txt="$RAW_DIR/${ch_name}_multiqc_report_data/multiqc_fastqc.txt"
    trimmed_txt="$TRIMMED_DIR/${ch_name}_multiqc_report_data/multiqc_fastqc.txt"
    out_csv="$OUT_DIR/${ch_name}_raw_trimmed_trunc_counts_metadata.csv"

    if [[ ! -f "$raw_txt" ]] || [[ ! -f "$trimmed_txt" ]]; then
        echo "Skipping $ch_name: missing required multiqc files" >&2
        continue
    fi

    awk -F '\t' -v raw_file="$raw_txt" -v proc_file="$proc_txt" -v trimmed_file="$trimmed_txt" -v meta_file="$METADATA" -v out_file="$out_csv" '
    function csv_escape(x, y) {
        y = x
        gsub(/"/, "\"\"", y)
        return "\"" y "\""
    }

    function normalize_sample(sample_full, s) {
    s = sample_full
    # 1. Handle the _F and _R suffixes (order matters)
    sub(/_[FR]$/, "", s)
    sub(/16S_[FR]$/, "", s)
    
    # 2. Standardize the 16S suffix
    sub(/16S$/, "", s)
    sub(/-16S$/, "", s)
    
    # 3. Handle specific suffixes found in filenames
    sub(/_S[0-9]+_L[0-9]+_R[12]_[0-9]+$/, "", s)
    sub(/_filt$/, "", s)
    sub(/_trunc$/, "", s)
    
    # 4. Remove dog prefixes and D0
    sub(/^CH0*/, "", s)
    sub(/D0/, "", s)
    
    # 5. Final cleanup
    gsub(/-/, "", s)
    gsub(/_/, "", s) # Added to catch lingering underscores before IDs
    return s
}


    function load_counts(file, arr, seen_arr) {
        local_sample_col = 0
        local_total_col = 0
        while ((getline line < file) > 0) {
            n = split(line, cols, "\t")
            if (local_sample_col == 0) {
                for (i = 1; i <= n; i++) {
                    if (cols[i] == "Sample") local_sample_col = i
                    if (cols[i] == "Total Sequences") local_total_col = i
                }
                continue
            }
            sample_full = cols[local_sample_col]
            sample_id = normalize_sample(sample_full)
            total = cols[local_total_col] + 0
            
            # This sums R1 and R2 together into the same sample_id key
            arr[sample_id] += total
            seen_arr[sample_id] = 1
        }
        close(file)
    }

    BEGIN {
        OFS = ","
        # Load all three stages. "seen" keeps track of every unique sample ID found.
        load_counts(raw_file, raw_counts, seen)
        load_counts(trimmed_file, trimmed_counts, seen)
        load_counts(proc_file, trunc_counts, seen)

        # Load Metadata
        meta_header = 1
        while ((getline line < meta_file) > 0) {
            n = split(line, m, "\t")
            if (meta_header) {
                for (i = 1; i <= n; i++) midx[m[i]] = i
                meta_header = 0
                continue
            }
            s_id = m[midx["Sample_Unique"]]
            dog[s_id] = m[midx["Dog_ID"]]
            site[s_id] = m[midx["Sample_Site"]]
            cat[s_id] = m[midx["Collection_Cat"]]
            surg[s_id] = m[midx["Surgery_Type"]]
        }
        close(meta_file)

        # Write Header
        print "Sample,Raw_Sum,Trimmed_Sum,Trunc_Sum,Dog_ID,Sample_Site,Collection_Cat,Surgery_Type" > out_file
        
        # Write Data
        for (s in seen) {
            printf "%s,%s,%s,%s,%s,%s,%s,%s\n", \
                csv_escape(s), \
                raw_counts[s] + 0, \
                trimmed_counts[s] + 0, \
                trunc_counts[s] + 0, \
                csv_escape(dog[s]), \
                csv_escape(site[s]), \
                csv_escape(cat[s]), \
                csv_escape(surg[s]) >> out_file
        }
    } '
done
