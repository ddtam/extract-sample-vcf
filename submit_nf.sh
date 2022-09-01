#!/usr/bin/env bash
#
#SBATCH --partition=defq

srun nextflow build-sample-vcf.nf -c build-sample-vcf.config

