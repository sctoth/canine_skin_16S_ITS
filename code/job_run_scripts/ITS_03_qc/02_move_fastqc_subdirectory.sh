# Create subdirectories from unique Individual names in TSV
awk -F'\t' 'NR>1 && $3!="" && !seen[$3]++ {print $3}' /home5/sctoth/projects/dog_skin_microbiomes/data/metadata/CH-All_ITS_Metadata_20220124.tsv | xargs -I {} mkdir -p "{}"


# Move files into correct subdirectories from unique Individual names in CSV (current directory)

for f in *_filtered_fastqc.{html,zip}; do
    [ -f "$f" ] || continue
    s=$(echo "$f" | sed 's/_filtered_fastqc.*//; s/_1$//; s/_2$//; s/\(-[0-9][A-Za-z][A-Za-z]-ITS\).*/\1/')
    i=$(awk -F$'\t' -v s="$s" 'NR>1 && $1==s {print $3; exit}' /home5/sctoth/projects/dog_skin_microbiomes/data/metadata/CH-All_ITS_Metadata_20220124.tsv)
    if [[ -n "$i" ]]; then
        mkdir -p "$i"
        mv "$f" "$i/"
        echo "Moved $f → $i/ (SampleId: $s)"
    else
        echo "No Individual for $f (SampleId: $s)"
    fi
done
##
for d in */; do mv "$d" "${d%/}_fastqc"; done 