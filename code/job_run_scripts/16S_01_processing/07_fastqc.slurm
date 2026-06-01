#!/bin/bash
#SBATCH --job-name=16S_trimmed_fastqc
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_processing_04/trunc_fastqc/fastqc_%A_%a.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_processing_04/trunc_fastqc/fastqc_%A_%a.err
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G
#SBATCH --array=1-992%20

module load fastqc/0.11.9

BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_16S"
DATA_DIR="${BASE_DIR}/05_truncR175_maxEE2-5_output"
OUTPUT_DIR="${DATA_DIR}/trunc_fastqc_output"

mkdir -p ${OUTPUT_DIR}
cd ${DATA_DIR}
#FILES=($(ls *.fastq.gz | sort -V))
IFS=$'\n' read -d '' -r -a FILES < <(find . -type f -name "*.fastq.gz" | sort -V)

if [ $SLURM_ARRAY_TASK_ID -gt ${#FILES[@]} ]; then
  echo "Task $SLURM_ARRAY_TASK_ID > ${#FILES[@]} files - skipping"
  exit 0
fi
FILE=${FILES[$((SLURM_ARRAY_TASK_ID-1))]}   

echo "Task ${SLURM_ARRAY_TASK_ID}/${#FILES[@]}: ${FILE}"
fastqc -t ${SLURM_CPUS_PER_TASK} -o ${OUTPUT_DIR} "${FILE}"