#!/bin/bash
#SBATCH --job-name=16S_learnErrors_dada2_CH2_pool
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_dada2_analysis/Seq_Run2/pool_learnErrors_dada2%A.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_dada2_analysis/Seq_Run2/pool_learnErrors_dada2%A.err
#SBATCH --mem=32G
#SBATCH --cpus-per-task=16
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1

set -euo pipefail

SEQ_RUN="Seq_Run2"

# Paths
BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data"
INPUT_DIR="${BASE_DIR}/processed/CH_All_16S/02_trunc_output/${SEQ_RUN}"
LEARNERROR_DIR="${BASE_DIR}/dada2_analysis/CH_All_16S/${SEQ_RUN}/02_learnerrors_output"
DADA2_DIR="${BASE_DIR}/dada2_analysis/CH_All_16S/${SEQ_RUN}/03_dada2_output_pool" 
mkdir -p "${LEARNERROR_DIR}" "${DADA2_DIR}"

# Activate environment
source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate /home5/sctoth/miniconda3/envs/r_env


# Export vars
export INPUT_DIR LEARNERROR_DIR DADA2_DIR
# Run Rscript with array ID
/home5/sctoth/miniconda3/envs/r_env/bin/Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/main_scripts/02_denoising/01_dada2_pool.R