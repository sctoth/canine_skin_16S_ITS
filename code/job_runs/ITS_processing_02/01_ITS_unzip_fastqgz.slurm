#!/bin/bash
#SBATCH --job-name=ITS_unzip_array
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/CH_All_ITS_unzip_logs/unzip_%A_%a.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/CH_All_ITS_unzip_logs/unzip_%A_%a.err
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --array=1-992%10   

cd /home5/sctoth/projects/dog_skin_microbiomes/data/raw/CH_All_ITS

# Note: Run this first: ls *.fastq.gz | sort -V > file_list.txt

FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" file_list.txt)
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    echo "ERROR: Task ${SLURM_ARRAY_TASK_ID} - no file found!" >&2
    exit 1
fi


echo "Task ${SLURM_ARRAY_TASK_ID} processing: $FILE"
gunzip -k "$FILE"

echo "Completed: $(date)"