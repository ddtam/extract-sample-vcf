
/*
This Nextflow script should be run using the config file 
`build-sample-vcf.config`, whose path can be specified using `-c` at execution.
*/

nextflow.enable.dsl=2

// --------
// CHANNELS
// --------

sample_ids =
    Channel
        .fromPath(params.sample_annotation)
        .splitCsv(header: true, sep: '\t')
        .map { row -> row.'Sample ID' }  // pull out column as value

vcfs = 
    Channel
        .fromPath(params.vcf_dir + '/*.vcf.gz')  

// ---------
// PROCESSES
// ---------

process splitOutSample {
    cpus 1
    memory '8 GB'
    input:
        tuple val(sample_id), path(vcf)

    output:
        path "${sample_id}_in_${vcf.simpleName}.vcf.gz", emit: sample_vcfs

    script:
        """
        bcftools view \
            -c 1 -O z \
            -s $sample_id \
            -o ${sample_id}_in_${vcf.simpleName}.vcf.gz \
            $vcf
        """
}

process mergeSampleVCFs {
    publishDir "$params.pub_dir", mode: 'copy'
    cpus 8
    memory '32 GB'

    input:
        tuple val(sample_id), file(sample_vcfs)
    
    output:
        path "${sample_id}.vcf.gz"
        path "${sample_id}.vc.gz.tbi"

    script:
        """
        bcftools concat \
            -O z \
            --threads $task.cpus \
            -o ${sample_id}_unsorted.vcf.gz \
            $sample_vcfs
        
        bcftools sort \
            -O z \
            -o ${sample_id}.vcf.gz \
            ${sample_id}_unsorted.vcf.gz

        tabix -f -p vcf ${sample_id}.vcf.gz
        """
}

// -------------
// MAIN WORKFLOW
// -------------

workflow {
    // Split out each specified sample ID from each VCF
    splitOutSample(
        // Create all combinations of samples and chromosome-wise VCFs so that
        //  all samples are pulled from all vcfs
        sample_ids
            .combine(vcfs)
    )

    // To aggregate sample-wise chromosome-wise VCFs by sample ID, tag each VCF
    //  generated by the sample ID it contains and recombine by this tag
    vcfs_by_sample_ids =
        splitOutSample.out.sample_vcfs
            .map { sample_vcf ->
                def sample_id = sample_vcf.name.toString().tokenize('_').get(0)
                return tuple(sample_id, sample_vcf)
            }
            .groupTuple()

    // Concatenate VCFs collected by sample ID
    mergeSampleVCFs(vcfs_by_sample_ids)
}

