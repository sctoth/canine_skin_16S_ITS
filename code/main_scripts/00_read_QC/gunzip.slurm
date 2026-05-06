#!/bin/bash
#SBATCH --job-name=unzip_array
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/CH_All_16S_unzip_logs/unzip_%A_%a.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/CH_All_16S_unzip_logs/unzip_%A_%a.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --array=1-904%20   

cd /home5/sctoth/projects/dog_skin_microbiomes/data/raw/CH_All_16S

# Note: Run this first: ls *.fastq.gz | sort -V > file_list.txt

FILE=$(sed "${SLURM_ARRAY_TASK_ID}p" file_list.txt)
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    echo "ERROR: Task ${SLURM_ARRAY_TASK_ID} - no file found!" >&2
    exit 1
fi

# there are 904 file names in file_list.txt
FILE=$(sed "${SLURM_ARRAY_TASK_ID}p" file_list.txt)

echo "Task ${SLURM_ARRAY_TASK_ID} processing: $FILE"

# Decompress (overwrites .fastq, keeps .gz; use gunzip -k to explicitly keep)
gunzip -k "$FILE"

echo "Completed: $(date)"