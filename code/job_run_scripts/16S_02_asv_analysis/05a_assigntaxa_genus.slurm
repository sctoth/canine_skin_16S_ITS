#!/bin/bash
#SBATCH --job-name=16S_assign_taxa
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_dada2_analysis_final/16S_dada2_assign_taxa_%A.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_dada2_analysis_final/16S_dada2_assign_taxa_%A.err
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1

set -euo pipefail


# Paths
HOME_DIR="/home5/sctoth/projects/dog_skin_microbiomes"
BASE_DIR="${HOME_DIR}/data"
DATABASE_DIR="${HOME_DIR}/database"
SEQ_RUN_SUMMARY_DIR="${BASE_DIR}/dada2_analysis_final/CH_All_16S/Seq_Runs_Summary" 
# Activate environment
source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate /home5/sctoth/miniconda3/envs/r_env


# Export vars
export  SEQ_RUN_SUMMARY_DIR DATABASE_DIR
# Run Rscript with array ID
/home5/sctoth/miniconda3/envs/r_env/bin/Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/job_run_scripts/16S_02_asv_analysis/05b_assigntaxa.R