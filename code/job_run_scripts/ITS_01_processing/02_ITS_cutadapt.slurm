#!/bin/bash
#SBATCH --job-name=cutadapt_ITS_array
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/CH_All_ITS_cutadapt_logs/cutadapt_%A_%a.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/CH_All_ITS_cutadapt_logs/cutadapt_%A_%a.err
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --array=1-496%10

module load cutadapt/3.1

DATA_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/raw/CH_All_ITS"
OUTPUT_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_ITS/cutadapt_output"

mkdir -p ${OUTPUT_DIR}
cd ${DATA_DIR}

R1_FILES=($(ls *_R1_001.fastq | sort -V))
R2_FILES=($(ls *_R2_001.fastq | sort -V))

NUM_FILES=${#R1_FILES[@]}
if [ $SLURM_ARRAY_TASK_ID -gt $NUM_FILES ]; then
  echo "Task $SLURM_ARRAY_TASK_ID > $NUM_FILES files - skipping"
  exit 0
fi

R1_FILE=${R1_FILES[$((SLURM_ARRAY_TASK_ID-1))]}
R2_FILE=${R2_FILES[$((SLURM_ARRAY_TASK_ID-1))]}

echo "Task ${SLURM_ARRAY_TASK_ID}: Processing ${R1_FILE} + ${R2_FILE}"

cutadapt \
  -a CTTGGTCATTTAGAGGAAGTAA...GCATCGATGAAGAACGCAGC \
  -A GCTGCGTTCTTCATCGATGC...TTACTTCCTCTAAATGACCAAG \
  -o ${OUTPUT_DIR}/${R1_FILE%.fastq}_trimmed.fastq \
  -p ${OUTPUT_DIR}/${R2_FILE%.fastq}_trimmed.fastq \
  -m 100 \
  ${R1_FILE} ${R2_FILE}

echo "Completed task ${SLURM_ARRAY_TASK_ID}: $(date)"