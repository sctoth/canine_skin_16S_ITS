#!/bin/bash
#SBATCH --job-name=16S_derep
#SBATCH --array=1-496%10
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_dada2_analysis/derep/derep_%A_%a.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_dada2_analysis/derep/derep_%A_%a.err
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G

set -euo pipefail

# Paths
BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data"
INPUT_DIR="${BASE_DIR}/processed/CH_All_16S/02_trunc_output"
OUT_DIR="${BASE_DIR}/dada2_analysis/CH_All_16S/01_derep_output"
mkdir -p "${OUT_DIR}"
cd "${OUT_DIR}"
# Activate environment
source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate /home5/sctoth/miniconda3/envs/r_env

# Export vars
export INPUT_DIR OUT_DIR
export SLURM_ARRAY_TASK_ID

# Run Rscript with array ID
Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/job_runs/16S_processing_02/01_derep_array.R