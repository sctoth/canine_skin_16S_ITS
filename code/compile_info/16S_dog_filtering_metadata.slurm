#!/bin/bash
#SBATCH --job-name=dog_seq_metadata
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/code/compile_info/logs/dog_seq_metadata_%j.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/code/compile_info/logs/dog_seq_metadata_%j.err

set -euo pipefail

BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data"
RAW_DIR="$BASE_DIR/raw/CH_All_16S/CH_All_16S_multiqc"
PROCESSED_DIR="$BASE_DIR/processed/CH_All_16S/cutadapt_output/multiqc_output"
TRIMMED_DIR="$BASE_DIR/processed/CH_All_16S/filterandtrim/multiqc_output"
METADATA="$BASE_DIR/metadata/CH-All_16S_Metadata_20220124.tsv"
OUT_DIR="$BASE_DIR/processed/CH_All_16S"

mkdir -p "$OUT_DIR"

for proc_txt in "$PROCESSED_DIR"/CH*_multiqc_report_data/multiqc_fastqc.txt; do
  [[ -f "$proc_txt" ]] || continue

  ch_base=$(basename "$(dirname "$proc_txt")")
  ch_name=${ch_base%%_multiqc_report_data}
  raw_txt="$RAW_DIR/${ch_name}_multiqc_report_data/multiqc_fastqc.txt"
  trimmed_txt="$TRIMMED_DIR/${ch_name}_multiqc_report_data/multiqc_fastqc.txt"
  out_csv="$OUT_DIR/${ch_name}_raw_cutadapt_trimmed_counts_metadata.csv"

  if [[ ! -f "$raw_txt" ]]; then
    echo "Skipping $ch_name: missing raw file $raw_txt" >&2
    continue
  fi

  if [[ ! -f "$trimmed_txt" ]]; then
    echo "Skipping $ch_name: missing trimmed file $trimmed_txt" >&2
    continue
  fi

awk -F '\t' -v raw_file="$raw_txt" -v proc_file="$proc_txt" -v trimmed_file="$trimmed_txt" -v meta_file="$METADATA" -v out_file="$out_csv" '
  function csv_escape(x,    y) {
    y = x
    gsub(/"/, "\"\"", y)
    return "\"" y "\""
  }

 function normalize_sample(sample_full,    s) {
  s = sample_full
  
  # Remove ALL suffixes FIRST
  sub(/_S[0-9]+_L[0-9]+_R[12]_[0-9]+$/, "", s)
  sub(/_filt$/, "", s)
  sub(/_[FR]$/, "", s)
  sub(/16S$/, "", s)
  sub(/-16S$/, "", s)
  
  sub(/^CH0*/, "", s)
  
  # CRITICAL: Remove D0 from ALL samples
  sub(/D0/, "", s)
  
  # Remove dashes
  gsub(/-/, "", s)
  
  return s
}

  function load_counts(file, arr,    line, n, i, sample_col, total_col, sample_full, sample_id, total, cols) {
    sample_col = total_col = 0

    while ((getline line < file) > 0) {
      n = split(line, cols, "\t")

      if (sample_col == 0) {
        for (i = 1; i <= n; i++) {
          if (cols[i] == "Sample") sample_col = i
          if (cols[i] == "Total Sequences") total_col = i
        }
        continue
      }

      sample_full = cols[sample_col]
      sample_id = normalize_sample(sample_full)
      total = cols[total_col] + 0

      # Debug only problem cases
      if (sample_full ~ /_filt$/ || sample_full ~ /D0/) {
        print "DEBUG", sample_full, "->", sample_id, "meta=" (sample_id in dog ? "YES" : "NO") > "/dev/stderr"
      }

      arr[sample_id] += total
      seen[sample_id] = 1
    }
    close(file)
  }

  BEGIN {
    OFS = ","

    load_counts(raw_file, raw_counts)
    load_counts(proc_file, proc_counts)
    load_counts(trimmed_file, trimmed_counts)

    meta_header = 1
    while ((getline line < meta_file) > 0) {
      n = split(line, m, "\t")
      if (meta_header) {
        for (i = 1; i <= n; i++) midx[m[i]] = i
        meta_header = 0
        continue
      }

      sample = m[midx["Sample"]]
      dog[sample]  = m[midx["Dog_ID"]]
      site[sample] = m[midx["Sample_Site"]]
      cat[sample]  = m[midx["Collection_Cat"]]
      surg[sample] = m[midx["Surgery_Type"]]

      if (dog[sample] != "") {
        print sprintf("META\t%s\tDog:%s\tSite:%s\tCat:%s", sample, dog[sample], site[sample], cat[sample]) > "/dev/stderr"
      }
    }
    close(meta_file)

    print "Sample,Raw_Count,Cutadapt_Count,Trimmed_Count,Dog_ID,Sample_Site,Collection_Cat,Surgery_Type" > out_file

    for (sample in seen) {
      # Final row debug
      has_meta = (dog[sample] != "" ? "YES" : "NO")
      print sprintf("FINAL\t%s\tRaw:%d\tCut:%d\tTrim:%d\tMeta:%s", 
                    sample, raw_counts[sample], proc_counts[sample], trimmed_counts[sample], has_meta) > "/dev/stderr"

      printf "%s,%s,%s,%s,%s,%s,%s,%s\n", \
        csv_escape(sample), \
        raw_counts[sample] + 0, \
        proc_counts[sample] + 0, \
        trimmed_counts[sample] + 0, \
        csv_escape(dog[sample]), \
        csv_escape(site[sample]), \
        csv_escape(cat[sample]), \
        csv_escape(surg[sample]) >> out_file
    }

    close(out_file)
  }
'
done