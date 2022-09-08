
# VCF Collation Workflow

This repository contains a Nextflow workflow that produces a single VCF file for a sample that has VCF annotations split across multiple single-chromosome VCF files.

## Inputs

The workflow requires the following inputs:

- Sample annotation file that is tab delimited, with `Sample ID` in the first column
    - Identifier in the `Sample ID` column should match the column identifier within the VCF files
- Directory containing VCF files to be recombined
- Nextflow configuration file, specifying run parameters, including:
    - Path to sample annotation file
    - Path to input directory containing VCFs
    - Path to output directory

## Execution

The workflow is written in Nextflow. A SLURM submission script with the necessary parameters is written at `submit_nf.sh` and can be scheduled using

```
sbatch ./submit_nf.sh
```

## Outputs

Outputs will be found in the output directory specified in the configuration file. One VCF will be present for each Sample ID in the sample annotation, and each .vcf will have a matching .tbi index file.

