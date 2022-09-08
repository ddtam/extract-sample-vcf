#!/usr/bin/env bash
#
#SBATCH --partition=defq

srun nextflow extract-sample-vcf.nf -c extract-sample-vcf.config

