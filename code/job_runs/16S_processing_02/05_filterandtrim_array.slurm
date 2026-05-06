#!/bin/bash
#SBATCH --job-name=16S_trimming
#SBATCH --array=1-496%15
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_processing_02/trimming/trimLeft_%A_%a.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_processing_02/trimming/trimLeft_%A_%a.err
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G

set -euo pipefail

# Paths
BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data"
INPUT_DIR="${BASE_DIR}/processed_02/CH_All_16S/trimleft_output_02"
OUT_DIR="${BASE_DIR}/processed_02/CH_All_16S/trunc_output"
mkdir -p "${OUT_DIR}"
cd "${OUT_DIR}"
# Activate environment
source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate /home5/sctoth/miniconda3/envs/r_env

# Export vars
export INPUT_DIR OUT_DIR
export SLURM_ARRAY_TASK_ID

# Run Rscript with array ID
Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/job_runs/16S_processing_02/05_filterandtrim_array.R