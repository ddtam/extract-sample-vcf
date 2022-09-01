#!/usr/bin/env bash
#
#SBATCH --partition=defq

nextflow build-sample-vcf.nf -c build-sample-vcf.config

