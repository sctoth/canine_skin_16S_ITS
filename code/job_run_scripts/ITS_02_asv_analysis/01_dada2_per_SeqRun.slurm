#!/bin/bash
#SBATCH --job-name=ITS_seqrun4_dada2
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/ITS_dada2_analysis_final/Seq_Run4_pool_dada2%A.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/ITS_dada2_analysis_final/Seq_Run4_pool_dada2%A.err
#SBATCH --mem=32G
#SBATCH --cpus-per-task=16
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1

set -euo pipefail

# Change with every job submission
SEQ_RUN="Seq_Run4"

# Paths
BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data"
INPUT_DIR="${BASE_DIR}/processed/CH_All_ITS_updated/filtered/${SEQ_RUN}"
LEARNERROR_DIR="${BASE_DIR}/dada2_analysis_final/CH_All_ITS/${SEQ_RUN}/learnerrors_output"
DADA2_DIR="${BASE_DIR}/dada2_analysis_final/CH_All_ITS/${SEQ_RUN}/dada2_output_pool" 
mkdir -p "${LEARNERROR_DIR}" "${DADA2_DIR}"

# Activate environment
source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate /home5/sctoth/miniconda3/envs/r_env


# Export vars
export INPUT_DIR LEARNERROR_DIR DADA2_DIR
# Run Rscript with array ID
/home5/sctoth/miniconda3/envs/r_env/bin/Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/job_run_scripts/ITS_02_asv_analysis/01_dada2_per_SeqRun.R