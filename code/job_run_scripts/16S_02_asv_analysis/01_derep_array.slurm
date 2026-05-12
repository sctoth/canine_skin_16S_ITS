#!/bin/bash
#SBATCH --job-name=16S_derep_learnerrors
#SBATCH --array=1-22%10
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_dada2_analysis/derep_learnerrors/derep_%A_%a.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_dada2_analysis/derep_learnerrors/derep_%A_%a.err
#SBATCH --mem=8G
#SBATCH --cpus-per-task=8


set -euo pipefail

# Activate environment
source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate /home5/sctoth/miniconda3/envs/r_env

# Paths
BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data"
INPUT_DIR="${BASE_DIR}/processed/CH_All_16S/02_trunc_output"
OUT_DIR="${BASE_DIR}/dada2_analysis/CH_All_16S"
mkdir -p "${OUT_DIR}"
cd "${INPUT_DIR}"

# Get CH*, Kit*, Chlor* subdirs, sorted
SAMPLE_DIRS=($(ls -d {CH*,Kit*,Chlor*}/ 2>/dev/null | sort -V))

if [ $SLURM_ARRAY_TASK_ID -gt ${#SAMPLE_DIRS[@]} ]; then
  echo "Task $SLURM_ARRAY_TASK_ID > ${#SAMPLE_DIRS[@]} directories - skipping"
  exit 0
fi

SAMPLE_SUBDIR=${SAMPLE_DIRS[$((SLURM_ARRAY_TASK_ID-1))]}
SAMPLE_NAME=$(basename "$SAMPLE_SUBDIR")

echo "Task ${SLURM_ARRAY_TASK_ID}/${#SAMPLE_DIRS[@]}: Processing ${SAMPLE_SUBDIR}..."

# Set env vars for R
export INPUT_SUBDIR="${INPUT_DIR}/${SAMPLE_NAME}"
export OUT_SUBDIR="${OUT_DIR}/${SAMPLE_NAME}"
export SAMPLE_NAME="${SAMPLE_NAME}"

mkdir -p "${OUT_SUBDIR}"
cd "${OUT_SUBDIR}"

# Run Rscript
Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/main_scripts/02_asv_analysis/01_derep_array.R

echo "Task ${SLURM_ARRAY_TASK_ID} complete: ${SAMPLE_NAME}"