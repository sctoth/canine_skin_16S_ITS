#!/bin/bash
#SBATCH --job-name=ITS_filtered
#SBATCH --array=1-496%20
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/ITS_processing_updated/trimming/filtered_%A_%a.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/ITS_processing_updated/trimming/filtered_%A_%a.err
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G

set -euo pipefail

# Paths
BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data"
INPUT_DIR="${BASE_DIR}/processed/CH_All_ITS_updated/removed_primers"
OUT_DIR="${BASE_DIR}/processed/CH_All_ITS_updated/filtered"
mkdir -p "${OUT_DIR}"
cd "${OUT_DIR}"
# Activate environment
source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate /home5/sctoth/miniconda3/envs/r_env

# Export vars
export INPUT_DIR OUT_DIR
export SLURM_ARRAY_TASK_ID

# Run Rscript with array ID
Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/job_run_scripts/ITS_01_processing_2/03_filterandtrim_array.R
