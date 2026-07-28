#!/bin/bash
# Navigate to the parent directory containing the _multiqc_report_data subdirectories
cd /home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_ITS_updated/filtered/multiqc_output
 
# Create output directory if it doesn't exist
mkdir -p summary

# Initialize the summary file with headers, including Dog_ID and Total_reads
echo "Sample,Dog_ID,Unique_Reads,Duplicate_Reads,Total_reads" > summary/sequence_counts_summary.csv

# Loop over each subdirectory ending with _multiqc_report_data
for subdir in *_multiqc_report_data; do
  if [ -d "$subdir" ]; then
    dog_id=$(echo "$subdir" | sed 's/_multiqc_report_data$//')
    txt_file="$subdir/fastqc_sequence_counts_plot.txt"
    
    if [ -f "$txt_file" ]; then
      # Skip header line, process each data line, add Dog_ID and compute Total_reads
      tail -n +2 "$txt_file" | while read -r sample unique dup; do
        total=$(echo "$unique + $dup" | bc -l)
        echo "$sample,$dog_id,$unique,$dup,$total" >> summary/sequence_counts_summary.csv
      done
    else
      echo "Warning: $txt_file not found" >&2
    fi
  fi
done

echo "Concatenated summary saved to summary/sequence_counts_summary.csv"