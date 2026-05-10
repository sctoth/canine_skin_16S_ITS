#!/bin/bash
#SBATCH --job-name=16S_learnErrors
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_dada2_analysis/learnErrors/CH001_learnErrors_%A.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_dada2_analysis/learnErrors/CH001_learnErrors_%A.err
#SBATCH -p bigmem

set -euo pipefail

# Paths
BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data"
INPUT_DIR="${BASE_DIR}/processed/CH_All_16S/02_trunc_output/CH001"
OUT_DIR="${BASE_DIR}/dada2_analysis/CH_All_16S/01_learnErrors_output/CH001"
mkdir -p "${OUT_DIR}"
cd "${OUT_DIR}"
# Activate environment
source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate /home5/sctoth/miniconda3/envs/r_env

# Export vars
export INPUT_DIR OUT_DIR
# Run Rscript with array ID
Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/main_scripts/02_asv_analysis/01_learnErrors_indiv.R