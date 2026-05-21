#!/bin/bash
#SBATCH --job-name=fastqc_16S_array
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/code/compile_info/logs/fastqc_%A_%a.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/code/compile_info/logs/fastqc_%A_%a.err
#SBATCH --mem=4G
#SBATCH --cpus-per-task=4
#SBATCH --array=1-22%10

module load fastqc/0.11.9

# Directory paths
DATA_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_16S/02_trunc_output"
OUTPUT_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/processed/CH_All_16S/02_trunc_output/trunc_fastqc_output_02"

mkdir -p "${OUTPUT_DIR}"
cd "${DATA_DIR}"

# Get all target subdirectories, sorted (stripped leading './' using sed)
INPUT_DIRS=($(find . -maxdepth 1 -type d \( -name "CH*" -o -name "Chlor*" -o -name "Kit*" \) | sed 's|^\./||' | sort -V))

if [ $SLURM_ARRAY_TASK_ID -gt ${#INPUT_DIRS[@]} ]; then
    echo "Task $SLURM_ARRAY_TASK_ID > ${#INPUT_DIRS[@]} directories - skipping"
    exit 0
fi

FASTQC_SUBDIR=${INPUT_DIRS[$((SLURM_ARRAY_TASK_ID-1))]}
DOG_NAME=$(basename "$FASTQC_SUBDIR" _fastqc)

# Create an isolated subfolder inside OUTPUT_DIR for this dog to prevent file clutter
SAMPLE_OUTDIR="${OUTPUT_DIR}/${FASTQC_SUBDIR}"
mkdir -p "${SAMPLE_OUTDIR}"

echo "Task ${SLURM_ARRAY_TASK_ID}/${#INPUT_DIRS[@]}: Running FastQC on ${FASTQC_SUBDIR}..."

# Check for fastq files inside the input subdirectory
if ls "${FASTQC_SUBDIR}"/*.fastq.gz >/dev/null 2>&1; then
    # Run FastQC using the 4 allocated threads
    fastqc "${FASTQC_SUBDIR}"/*.fastq.gz \
           --threads 4 \
           --outdir "${SAMPLE_OUTDIR}"
    echo "✓ FastQC complete for: ${DOG_NAME}"
else
    echo "ERROR: No fastq.gz files found in ${DATA_DIR}/${FASTQC_SUBDIR}"
    exit 1
fi


echo "Task ${SLURM_ARRAY_TASK_ID} complete: ${DOG_NAME}"