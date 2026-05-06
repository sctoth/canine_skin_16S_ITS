#!/bin/bash
#SBATCH --job-name=fastqc_ITS_array
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/CH_All_ITS_fastqc_logs/fastqc_%A_%a.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/CH_All_ITS_fastqc_logs/fastqc_%A_%a.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --array=1-992%20

module load fastqc/0.11.9

# Directory paths  
DATA_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/raw/CH_All_ITS"
OUTPUT_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_ITS_fastqc"

mkdir -p ${OUTPUT_DIR}

cd ${DATA_DIR}
FILES=($(ls *.fastq.gz | sort -V))

# FIXED INDEXING: SLURM_ARRAY_TASK_ID starts at 1, array at 0
if [ $SLURM_ARRAY_TASK_ID -gt ${#FILES[@]} ]; then
  echo "Task $SLURM_ARRAY_TASK_ID > ${#FILES[@]} files - skipping"
  exit 0
fi
FILE=${FILES[$((SLURM_ARRAY_TASK_ID-1))]}

echo "Task ${SLURM_ARRAY_TASK_ID}/${#FILES[@]}: ${FILE}"
fastqc -t ${SLURM_CPUS_PER_TASK} -o ${OUTPUT_DIR} "${FILE}"