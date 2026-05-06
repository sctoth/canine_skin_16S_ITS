#!/bin/bash
#SBATCH --job-name=16S_trunc_plot_quality
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_processing_02/trimming_read_quality/trimmed_quality_check_%j.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_processing_02/trimming_read_quality/trimmed_quality_check_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --time=04:00:00

set -euo pipefail

# Paths
BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/raw/CH_All_16S"
DATA_DIR="${BASE_DIR}"
OUT_DIR="${DATA_DIR}/read_quality_results_02" 

mkdir -p "${OUT_DIR}"
cd "${OUT_DIR}"

# Activate conda R environment
source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate /home5/sctoth/miniconda3/envs/r_env

# Export variables to R
export DATA_DIR OUT_DIR

# Run R script
Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/job_runs/16S_processing_02/00_filterandtrim_read_quality.R