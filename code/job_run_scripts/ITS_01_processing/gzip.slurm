#!/bin/bash
#SBATCH --job-name=zip_array
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/CH_All_ITS_zip_logs/zip_%A_%a.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/CH_All_ITS_zip_logs/zip_%A_%a.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --array=1-992%10   

cd /home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_ITS/cutadapt_output

# Note: Run this first: ls *.fastq | sort -V > file_list.txt

FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" file_list.txt)
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    echo "ERROR: Task ${SLURM_ARRAY_TASK_ID} - no file found!" >&2
    exit 1
fi

echo "Task ${SLURM_ARRAY_TASK_ID} processing: $FILE"

# Decompress (overwrites .fastq, keeps .gz; use gunzip -k to explicitly keep)
gzip -k "$FILE"

echo "Completed: $(date)"