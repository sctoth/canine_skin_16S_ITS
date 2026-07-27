#!/bin/bash
#SBATCH --job-name=16S_trimming_150_trunc_maxEE22
#SBATCH --array=1-496%15
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_processing_final/truncation/maxEE22_150_trunc_%A_%a.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_processing_final/truncation/maxEE22_150_trunc_%A_%a.err
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G

set -euo pipefail

# Paths
BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data"
INPUT_DIR="${BASE_DIR}/processed/CH_All_16S/01_trimleft_output"
OUT_DIR="${BASE_DIR}/processed/CH_All_16S/06_truncR150_maxEE22_output"
mkdir -p "${OUT_DIR}"
cd "${OUT_DIR}"
# Activate environment
source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate /home5/sctoth/miniconda3/envs/r_env

# Export vars
export INPUT_DIR OUT_DIR
export SLURM_ARRAY_TASK_ID

# Run Rscript with array ID
/home5/sctoth/miniconda3/envs/r_env/bin/Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/job_run_scripts/16S_01_processing/05_filterandtrim_array.R