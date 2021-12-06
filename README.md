# HybPiper

Current version: 1.3.1 (August 2018)

[![DOI](https://zenodo.org/badge/6513/mossmatters/HybPiper.svg)](https://zenodo.org/badge/latestdoi/6513/mossmatters/HybPiper)

--
[Read our article in Applications in Plant Sciences (Open Access)](http://www.bioone.org/doi/full/10.3732/apps.1600016)

by Matt Johnson and Norm Wickett, Chicago Botanic Garden

![](examples/hybpiper_logo.png)

(logo by Elliot Gardner)


### Purpose

HybPiper was designed for targeted sequence capture, in which DNA sequencing libraries are enriched for gene regions of interest, especially for phylogenetics. HybPiper is a suite of Python scripts that wrap and connect bioinformatics tools in order to extract target sequences from high-throughput DNA sequencing reads. 


Targeted bait capture is a technique for sequencing many loci simultaneously based on bait sequences.
HybPiper pipeline starts with high-throughput sequencing reads (for example from Illumina MiSeq), and assigns them to target genes using BLASTx or BWA.
The reads are distributed to separate directories, where they are assembled separately using SPAdes. 
The main output is a FASTA file of the (in frame) CDS portion of the sample for each target region, and a separate file with the translated protein sequence.

# CJJ remove below?
HybPiper also includes post-processing scripts, run after the main pipeline, to also extract the intronic regions flanking each exon, investigate putative paralogs, and calculate sequencing depth. For more information, [please see our wiki](https://github.com/mossmatters/HybPiper/wiki/).

HybPiper is run separately for each sample (single or paired-end sequence reads). When HybPiper generates sequence files from the reads, it does so in a standardized directory hierarchy. Many of the post-processing scripts rely on this directory hierarchy, so do not modify it after running the initial pipeline. It is a good idea to run the pipeline for each sample from the same directory. You will end up with one directory per run of HybPiper, and some of the later scripts take advantage of this predictable directory structure.


---
# Dependencies
* Python 3.6 or later
* [BIOPYTHON 1.80 or later](http://biopython.org/wiki/Main_Page) (For parsing and handling FASTA and FASTQ files, and parsing Exonerate alignments)
* [EXONERATE](http://www.ebi.ac.uk/about/vertebrate-genomics/software/exonerate) (For aligning recovered sequences to target proteins)
* [BLAST command line tools](ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/) (Aligning reads to target protiens)
* [SPAdes](http://bioinf.spbau.ru/en/spades) (Assembling reads into contigs)
* [GNU Parallel](http://www.gnu.org/software/parallel/) (Handles parallelization of searching, assembling, and aligning)
* CJJ: DIAMOND
* CJJ: BBtools (BBmap.sh, BBmerge.sh)

*Required for BWA version of the pipeline and for the intron and depth calculation scripts*:

* [BWA](https://github.com/lh3/bwa) (Aligns reads to target nucleotide sequences)
* [samtools 1.2 or later](https://github.com/samtools/samtools) (Read/Write BAM files to save space).

**NOTE:** A previous version of the pipeline required Velvet and CAP3 for assembly. These have been unreliable at assembling individual genes, and SPAdes has replaced them.

---
# Setup
We have successfully installed HybPiper on MacOSX and Linux (Centos 6). All of the bioinformatics tools can be installed with [homebrew](brew.sh) or [linuxbrew](linuxbrew.sh).

For full installation instructions, please see our wiki page:

[https://github.com/mossmatters/HybPiper/wiki/Installation](https://github.com/mossmatters/HybPiper/wiki/Installation)

Once all dependencies are installed, execute the `run_tests.sh` script from the `test_dataset` directory for a demonstration of HybPiper.


----

# Pipeline Input

Full instructions on running the pipeline, including a step-by-step tutorial using a small test dataset, is available on our wiki:

[https://github.com/mossmatters/HybPiper/wiki](https://github.com/mossmatters/HybPiper/wiki)

### High-Throughput DNA Sequencing Reads

Before running the pipeline, you will need "cleaned" FASTQ file(s)-- one or two depending on whether your sequencing was single or paired-end. Reads should have adapter sequences removed and should be trimmed to remove low quality base calls.

### Target Sequences

You will also need to construct a "target" file of gene regions. The target file should contain one gene region per sequence, with exons "concatenated" into a contiguous sequence. For more information on constructing the target file, see the wiki, or view the example file in: `test_dataset/test_targets.fasta`

There can be more than one "source sequence" for each gene in the target file. This can be useful if the target enrichment baits were designed from multiple sources-- for example a transcriptome in the focal taxon and a distantly related reference genome.

----

# Pipeline Output

HybPiper will map the reads to the target sequences, sort the reads by gene, assemble the reads for each gene separately, align the contigs to the target sequence, and extract a coding sequence from each gene. Output from each of these phases is saved in a standardized directory hierarchy, making it easy for post-processing scripts to summarize information across many samples.

For example, the coding sequence for gene "gene001" for sample "EG30" is saved in a FASTA file:

`EG30/gene001/EG30/sequences/FNA/gene001.FNA`

and a list of genes for which a sequence could be extracted can be found:

`EG30/genes_with_seqs.txt`

For a full description of HybPiper output, [see the wiki](https://github.com/mossmatters/HybPiper/wiki).


-----
# Changelog

**1.4 release candidate** *December, 2021*

This update involves a substantial refactor of the HybPiper pipeline. Changes include:

- **NEW DEPENDENCY**: DIAMOND
- **NEW DEPENDENCY**: BBtools
- **NEW DEPENDENCY**: BioPython 1.80 (contains required bug fixes in the SearchIO Exonerate parser modules).


- The`reads_first.py` module now imports other pipeline modules rather than calling them as external scripts.
- The `exonerate_hits.py` module has been substantially rewritten to use the BioPython SearchIO Exonerate text parser, 
  as this allows much more data recovered from Exonerate search results. 
- The `intronerate.py` module has been removed; this functionality has been moved to `exonerate_hits.py`.
- The `paralog_investigator.py` module has been removed; this functionality has been moved to `exonerate_hits.py`.
- The program DIAMOND can be used in place on BLASTX when mapping reads to target/bait sequences.
- The `reads_first.py` module now accepts read files in compressed gzip format (`*.gz`).
- Logging when running `reads_first.py` has been unified and extended to provide additional debugging information. A 
  single log file is written in the sample directory e.g. `EG30_reads_first_2021-12-02-10_45_56.log`. 
- Checks for all dependencies are noe run by default when `reads_first.py` is run.
- The `reads_first.py` module now checks that the provided target/bait file is formatted correctly and can be 
  translated as expected (in the case of a nucleotide target/bait file). Any issues are printed to screen and logged to 
  file.
- All Exonerate searches are now performed with the option `--refine full`; in the case of failure, a fallback run 
  without this parameter is performed.

- Chimera test (paired reads, supercontigs only) XXX.



- The following **new options/flags** have been added:
    - The flag `--diamond` has been added to `reads_first.py`. When provided, DIAMOND (with default sensitivity `fast`) 
      will be used to map reads against the bait/target file, rather than the default BLASTX.
    - The parameter `--diamond_sensitivity` has been added to `reads_first.py`. DIAMOND will be run with the provided 
      sensitivity (options are `mid-sensitive`, `sensitive`, `more-sensitive`, `very-sensitive`, `ultra-sensitive`).
    - The flag `--run_intronerate` has been added to `reads_first.py`. When used, Intronerate will be run for genes 
      that have more than one exon.
    - The flag `--merged` has been added to `reads_first.py`. XXX.
    - The flag `--nosupercontigs` has been added to `reads_first.py`. XXX.
    - The parameter `--paralog_min_length_percentage` has been added to `reads_first.py`. XXX.
    - The parameter `--bbmap_subfilter` has been added to `reads_first.py`. XXX.
    - The parameter `--bbmap_threads` has been added to `reads_first.py`. XXX.
    - The parameter `--chimeric_supercontig_edit_distance` has been added to `reads_first.py`. XXX.
    - The parameter `--chimeric_supercontig_discordant_reads_cutoff` has been added to `reads_first.py`. XXX.
    - The parameter `--bbmap_threads` has been added to `reads_first.py`. XXX.
    - The parameter `----memory` has been added to `reads_first.py`. XXX.


- The following options/flags have been **changed or removed**:
    - The parameter `--length_pct` has been removed from `reads_first.py` and `exonerate_hits.py`and is no longer used 
      in internal code.
    - The parameter `--thresh` (percent identity threshold for retaining Exonerate hits) for `reads_first.py` now 
      defaults to 55 (previously 65).
    - XXX.
    - check_depend
    
- Paralog by depth warning
- Remove SPAdes folder by default
- Change to Intronerate supercontig file name
- 

    
**1.3.2** *February, 2020*

- Fix for [Issue 41](https://github.com/mossmatters/HybPiper/issues/41) a problem in `intronerate.py` when attempting to resolve overlapping gene annotations.
- Add support in `retrieve_sequences.py` for a list of HybPiper outputs rather than everything in a directory 
- Add support for supercontigs in `get_seq_lengths.py`
- Remove integer requirement for `--cov_cutoff` to accommodate `auto` and `off` settings in Spades.

**1.3.1 IMPORTANT BUG FIX** *August, 2018*

- Reverts a change in 1.3 that changed the behavior when there is only one hit in `exonerate`. Strandedness was not handled properly, leading some sequences to be returned in reverse complement. **Sequences recovered using 1.3 should be re-run with `reads_first.py --no-blast --no-distribute --no-assemble` to repeat just the exonerate step.**


**1.3 The Herbarium Update** *January, 2018*

### Features 
- Added `--exclude`  flag to be the inverse of `--target`: all sequences with the specified string will not be used as targets for exon extraction (they will still be used for read-mapping). Useful if you want to add supercontig sequence to the target file, but not use it for exon extraction.

- Added `--addN` to `intronerate.py`. This feature will add 10 N characters in between joined contig when recovering the supercontig. This is useful for identifying where the intron recovery fails, and for annotation processing (i.e. for GenBank).

- Added a new version of the heatmap script, `gene_recovery_heatmap_ggplot.R`. This script is much simpler and produces nice color PNG images, but struggles a bit on PDF output. The original heatmap script is stil included. *Thanks to Paul Wolf for the ggplot code!*


### Bug Fixes
- Fixed misassembly of supercontigs when there are multiple alignments to different parts of the same exon.
- Fixed poor filtering of GFF results to produce intron/exon annotation.
- Fixed non-propogation of exonerate parameters



**1.2.1** *September, 2017*

### Bug Fixes
- Fixed assembly issue when gene does not have unpaired reads.
- Fixed distribution of targets when unpaired reads present.
- Fixed use of unpaired reads to detect best target.


**1.2** *May, 2017*

### Features 

- Added `--unpaired` flag. When using paired-end sequencing reads, a third read file may be specified with this flag. Reads will be mapped to targets separately, but will be used along with paired reads in contig assembly.

- Added `--target` flag. Adds the ability to choose which of the reference sequences is used for each gene. If `--target` is a file (tab-delimited file with one gene and one target name per line), HybPiper will use that. Otherwise `--target` can be the name of one reference. HybPiper will only use targets with the specified name in the Alignment/Exon Extraction phase. All other targets for that locus will only be used in the Mapping/Read Sorting phase.

- Added `--timeout` flag, which uses GNU Parallel to kill processes (i.e. Spades or Exonerate) if they take X percent longer than average. Use if there are a lot of stuck jobs (`--timeout 1000`)
- Python 3 compatibility

### Bug Fixes
- Can accommodate Solexa FASTQ paired headers
- Fixed `spades_runner.py` not recognizing `--cpu` on redos
- Prints more meaningful messages for some common errors
- Can accommodate `prefix` not being in current directory
- Deletes sorted reads on restart to prevent double counting reads.
- `spades_runner.py` will now respect `--kvals`
- Added initial call to log for `reads_first.py`

---
**1.1** *May, 2016*: Release associated with manuscript in *Applications in Plant Sciences*.

- Added `paralog_investigator.py`, which detects and extracts long exons from putative paralogs in all genes in one sample.

- Added `paralog_retriever.py`, which retrieves sequences generated by `paralog_investigator.py` for many samples (or the coding sequence generated by `exonerate_hits.py` if no paralogs are detected).

- Added a test_dataset of 13 genes for 9 samples, and a shell script to run the test data through the main script and several post-processing scripts.

- Fixed bug involving calling HybPiper with a relative path such as: `../reads_first.py`

- `reads_first.py --check_depend` now checks for SPAdes, BWA, and Samtools

- Full revision of README, which is now shorter. Full tutorials on installing and running HybPiper are now on the Wiki.



**1.0** *Feb, 2016*: Initial fully-featured release associated with submission of manuscript to *Applications in Plant Sciences*.

-- Sequence assembly now uses SPAdes rather than Velvet + CAP3

---

# Citation
Johnson, M. G., Gardner, E. M., Liu, Y., Medina, R., Goffinet, B., Shaw, A. J., Zerega, N. J. C, and  Wickett, N. J. (2016). HybPiper: Extracting Coding Sequence and Introns for Phylogenetics from High-Throughput Sequencing Reads Using Target Enrichment. Applications in Plant Sciences, 4(7), 1600016. doi:10.3732/apps.1600016

