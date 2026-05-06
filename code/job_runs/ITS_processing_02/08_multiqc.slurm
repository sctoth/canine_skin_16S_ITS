#!/bin/bash
#SBATCH --job-name=multiqc_ITS_per_dog
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/CH_All_ITS_filterandtrim_multiqc_logs/multiqc_%A_%a.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/CH_All_ITS_filterandtrim_multiqc_logs/multiqc_%A_%a.err
#SBATCH --mem=4G
#SBATCH --cpus-per-task=4
#SBATCH --array=1-22%10

source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate multiqc

# Directory paths
DATA_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_ITS/filterandtrim/fastqc_output"
OUTPUT_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_ITS/filterandtrim/multiqc_output"

mkdir -p "${OUTPUT_DIR}"

cd "${DATA_DIR}"

# Get all *fastqc subdirectories, sorted
FASTQC_DIRS=($(ls -d *_fastqc/ 2>/dev/null | sort -V))

if [ $SLURM_ARRAY_TASK_ID -gt ${#FASTQC_DIRS[@]} ]; then
  echo "Task $SLURM_ARRAY_TASK_ID > ${#FASTQC_DIRS[@]} directories - skipping"
  exit 0
fi


FASTQC_SUBDIR=${FASTQC_DIRS[$((SLURM_ARRAY_TASK_ID-1))]}
DOG_NAME=$(basename "$FASTQC_SUBDIR" _fastqc)

echo "Task ${SLURM_ARRAY_TASK_ID}/${#FASTQC_DIRS[@]}: Processing ${FASTQC_SUBDIR}..."

# Run multiqc on this subdirectory, output to CENTRAL multiqc dir
if ls "${FASTQC_SUBDIR}"/*_fastqc.* >/dev/null 2>&1; then
  multiqc "${FASTQC_SUBDIR}" \
    --title "FastQC MultiQC Report - ${DOG_NAME} (ITS)" \
    --filename "${DOG_NAME}_multiqc_report" \
    --outdir "${OUTPUT_DIR}" \
    --force
  
  echo "✓ Created: ${OUTPUT_DIR}/${DOG_NAME}_multiqc_report.html"
else
  echo "No FastQC files found in ${FASTQC_SUBDIR}"
fi

echo "Task ${SLURM_ARRAY_TASK_ID} complete: ${DOG_NAME}"