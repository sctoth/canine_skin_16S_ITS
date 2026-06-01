#!/bin/bash
#SBATCH --job-name=16S_trunc_plot_quality
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_processing_03/truncation_readquality/trimmed_quality_check_%j.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_processing_03/truncation_readquality/trimmed_quality_check_%j.err
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G
#SBATCH --time=10:00:00

set -euo pipefail

# Paths
BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_16S"
DATA_DIR="${BASE_DIR}/05_truncR175_maxEE2-5_output"
OUT_DIR="${DATA_DIR}/read_quality_results" 

mkdir -p "${OUT_DIR}"
cd "${OUT_DIR}"

# Activate conda R environment
source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate /home5/sctoth/miniconda3/envs/r_env

# Export variables to R
export DATA_DIR OUT_DIR

# Run R script
/home5/sctoth/miniconda3/envs/r_env/bin/Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/job_run_scripts/16S_01_processing/06_filterandtrim_read_quality.R