#!/bin/bash
#SBATCH --job-name=16S_quality_check_cutadapt
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/CH_All_16S_quality_check_cutadapt_logs/cutadapt_quality_check_%j.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/CH_All_16S_quality_check_cutadapt_logs/cutadapt_quality_check_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --time=04:00:00

set -euo pipefail

# Paths
BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_16S/cutadapt_output"
OUT_DIR="${BASE_DIR}/read_quality_results"

mkdir -p "${OUT_DIR}"
cd "${OUT_DIR}"

# Activate conda R environment
source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate /home5/sctoth/miniconda3/envs/r_env

# Export variables to R
export BASE_DIR OUT_DIR

# Run R script
Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/job_runs/16S_processing/01_cutadapt_read_quality.R