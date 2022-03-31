#!/usr/bin/env bash

# Detect if test_reads are the real thing or git-lfs placeholder
minsize=5000
readsize=$(wc -c < test_reads.fastq.tar.gz)
if [ $minsize -ge $readsize ]; then
    rm test_reads.fastq.tar.gz
    wget https://github.com/mossmatters/HybPiper/raw/develop/test_dataset/test_reads.fastq.tar.gz || curl -O https://github.com/mossmatters/HybPiper/raw/develop/test_dataset/test_reads.fastq.tar.gz
fi


# Unpack the test dataset
tar -zxf test_reads.fastq.tar.gz

# Remove any previous runs
parallel rm -r {} :::: namelist.txt


# Run main HybPiper command with all available CPUs
while read sample_name
do
  hybpiper assemble -r ${sample_name}*.fastq -t test_targets.fasta --prefix ${sample_name} --bwa  --run_intronerate
done < namelist.txt


# Get runs statistics
hybpiper stats test_targets.fasta dna gene namelist.txt


# Get heatmap of length recovery
hybpiper recovery_heatmap seq_lengths.tsv

# Recover DNA and amino-acid sequences
hybpiper retrieve_sequences test_targets.fasta dna --sample_names namelist.txt --fasta_dir 001_dna_seqs
hybpiper retrieve_sequences test_targets.fasta aa --sample_names namelist.txt --fasta_dir 002_aa_seqs


# Recover paralog sequences
hybpiper paralog_retriever namelist.txt test_targets.fasta


echo "DONE!"