#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: "Whole genome alignment and somatic variant detection"
requirements:
    - class: SchemaDefRequirement
      types:
          - $import: ../types/labelled_file.yml
          - $import: ../types/sequence_data.yml
    - class: SubworkflowFeatureRequirement
    - class: StepInputExpressionRequirement
inputs:
    reference: string
    tumor_sequence:
        type: ../types/sequence_data.yml#sequence_data[]
    tumor_name:
        type: string?
        default: 'tumor'
    normal_sequence:
        type: ../types/sequence_data.yml#sequence_data[]
    normal_name:
        type: string?
        default: 'normal'
    mills:
        type: File
        secondaryFiles: [.tbi]
    known_indels:
        type: File
        secondaryFiles: [.tbi]
    dbsnp_vcf:
        type: File
        secondaryFiles: [.tbi]
    bqsr_intervals:
        type: string[]
    target_intervals:
        type: File
    per_base_intervals:
        type: ../types/labelled_file.yml#labelled_file[]
    per_target_intervals:
        type: ../types/labelled_file.yml#labelled_file[]
    qc_intervals:
        type: File
    summary_intervals:
        type: ../types/labelled_file.yml#labelled_file[]
    omni_vcf:
        type: File
        secondaryFiles: [.tbi]
    picard_metric_accumulation_level:
        type: string
    qc_minimum_mapping_quality:
        type: int?
        default: 0
    qc_minimum_base_quality:
        type: int?
        default: 0
    interval_list:
        type: File
    cosmic_vcf:
        type: File?
        secondaryFiles: [.tbi]
    panel_of_normals_vcf:
        type: File?
        secondaryFiles: [.tbi]
    strelka_cpu_reserved:
        type: int?
        default: 8
    mutect_scatter_count:
        type: int
    mutect_artifact_detection_mode:
        type: boolean
        default: false
    mutect_max_alt_allele_in_normal_fraction:
        type: float?
    mutect_max_alt_alleles_in_normal_count:
        type: int?
    varscan_strand_filter:
        type: int?
        default: 0
    varscan_min_coverage:
        type: int?
        default: 8
    varscan_min_var_freq:
        type: float?
        default: 0.05
    varscan_p_value:
        type: float?
        default: 0.99
    varscan_max_normal_freq:
        type: float?
    pindel_insert_size:
        type: int
        default: 400
    docm_vcf:
        type: File
        secondaryFiles: [.tbi]
    filter_docm_variants:
        type: boolean?
        default: true
    vep_cache_dir:
        type: string
    vep_ensembl_assembly:
        type: string
        doc: "genome assembly to use in vep. Examples: GRCh38 or GRCm38"
    vep_ensembl_version:
        type: string
        doc: "ensembl version - Must be present in the cache directory. Example: 95"
    vep_ensembl_species:
        type: string
        doc: "ensembl species - Must be present in the cache directory. Examples: homo_sapiens or mus_musculus"
    synonyms_file:
        type: File?
    annotate_coding_only:
        type: boolean?
    vep_pick:
        type:
            - "null"
            - type: enum
              symbols: ["pick", "flag_pick", "pick_allele", "per_gene", "pick_allele_gene", "flag_pick_allele", "flag_pick_allele_gene"]
    cle_vcf_filter:
        type: boolean
        default: false
    variants_to_table_fields:
        type: string[]
        default: [CHROM,POS,ID,REF,ALT,set,AC,AF]
    variants_to_table_genotype_fields:
        type: string[]
        default: [GT,AD]
    vep_to_table_fields:
        type: string[]
        default: [HGVSc,HGVSp]
    custom_gnomad_vcf:
        type: File?
        secondaryFiles: [.tbi]
    custom_clinvar_vcf:
        type: File?
        secondaryFiles: [.tbi]
    manta_call_regions:
        type: File?
        secondaryFiles: [.tbi]
    manta_non_wgs:
        type: boolean?
        default: false
    manta_output_contigs:
        type: boolean?
    somalier_vcf:
        type: File
outputs:
##tumor alignment and QC
    tumor_cram:
        type: File
        outputSource: tumor_index_cram/indexed_cram
    tumor_mark_duplicates_metrics:
        type: File
        outputSource: tumor_alignment_and_qc/mark_duplicates_metrics
    tumor_insert_size_metrics:
        type: File
        outputSource: tumor_alignment_and_qc/insert_size_metrics
    tumor_alignment_summary_metrics:
        type: File
        outputSource: tumor_alignment_and_qc/alignment_summary_metrics
    tumor_per_target_coverage_metrics:
        type: File[]
        outputSource: tumor_alignment_and_qc/per_target_coverage_metrics
    tumor_per_target_hs_metrics:
        type: File[]
        outputSource: tumor_alignment_and_qc/per_target_hs_metrics
    tumor_per_base_coverage_metrics:
        type: File[]
        outputSource: tumor_alignment_and_qc/per_base_coverage_metrics
    tumor_per_base_hs_metrics:
        type: File[]
        outputSource: tumor_alignment_and_qc/per_base_hs_metrics
    tumor_summary_hs_metrics:
        type: File[]
        outputSource: tumor_alignment_and_qc/summary_hs_metrics
    tumor_flagstats:
        type: File
        outputSource: tumor_alignment_and_qc/flagstats
    tumor_verify_bam_id_metrics:
        type: File
        outputSource: tumor_alignment_and_qc/verify_bam_id_metrics
    tumor_verify_bam_id_depth:
        type: File
        outputSource: tumor_alignment_and_qc/verify_bam_id_depth
    tumor_insert_size_histogram:
        type: File
        outputSource: tumor_alignment_and_qc/insert_size_histogram
    tumor_gc_bias_metrics:
        type: File
        outputSource: tumor_alignment_and_qc/gc_bias_metrics
    tumor_gc_bias_metrics_chart:
        type: File
        outputSource: tumor_alignment_and_qc/gc_bias_metrics_chart
    tumor_gc_bias_metrics_summary:
        type: File
        outputSource: tumor_alignment_and_qc/gc_bias_metrics_summary
    tumor_wgs_metrics:
        type: File
        outputSource: tumor_alignment_and_qc/wgs_metrics
    tumor_bamcoverage_bigwig:
        type: File
        outputSource: tumor_alignment_and_qc/bamcoverage_bigwig
##normal alignment and qc
    normal_cram:
        type: File
        outputSource: normal_index_cram/indexed_cram
    normal_mark_duplicates_metrics:
        type: File
        outputSource: normal_alignment_and_qc/mark_duplicates_metrics
    normal_insert_size_metrics:
        type: File
        outputSource: normal_alignment_and_qc/insert_size_metrics
    normal_alignment_summary_metrics:
        type: File
        outputSource: normal_alignment_and_qc/alignment_summary_metrics
    normal_per_target_coverage_metrics:
        type: File[]
        outputSource: normal_alignment_and_qc/per_target_coverage_metrics
    normal_per_target_hs_metrics:
        type: File[]
        outputSource: normal_alignment_and_qc/per_target_hs_metrics
    normal_per_base_coverage_metrics:
        type: File[]
        outputSource: normal_alignment_and_qc/per_base_coverage_metrics
    normal_per_base_hs_metrics:
        type: File[]
        outputSource: normal_alignment_and_qc/per_base_hs_metrics
    normal_summary_hs_metrics:
        type: File[]
        outputSource: normal_alignment_and_qc/summary_hs_metrics
    normal_flagstats:
        type: File
        outputSource: normal_alignment_and_qc/flagstats
    normal_verify_bam_id_metrics:
        type: File
        outputSource: normal_alignment_and_qc/verify_bam_id_metrics
    normal_verify_bam_id_depth:
        type: File
        outputSource: normal_alignment_and_qc/verify_bam_id_depth
    normal_insert_size_histogram:
        type: File
        outputSource: normal_alignment_and_qc/insert_size_histogram
    normal_gc_bias_metrics:
        type: File
        outputSource: normal_alignment_and_qc/gc_bias_metrics
    normal_gc_bias_metrics_chart:
        type: File
        outputSource: normal_alignment_and_qc/gc_bias_metrics_chart
    normal_gc_bias_metrics_summary:
        type: File
        outputSource: normal_alignment_and_qc/gc_bias_metrics_summary
    normal_wgs_metrics:
        type: File
        outputSource: normal_alignment_and_qc/wgs_metrics
    normal_bamcoverage_bigwig:
        type: File
        outputSource: normal_alignment_and_qc/bamcoverage_bigwig
##variant calling
    mutect_unfiltered_vcf:
        type: File
        outputSource: detect_variants/mutect_unfiltered_vcf
        secondaryFiles: [.tbi]
    mutect_filtered_vcf:
        type: File
        outputSource: detect_variants/mutect_filtered_vcf
        secondaryFiles: [.tbi]
    strelka_unfiltered_vcf:
        type: File
        outputSource: detect_variants/strelka_unfiltered_vcf
        secondaryFiles: [.tbi]
    strelka_filtered_vcf:
        type: File
        outputSource: detect_variants/strelka_filtered_vcf
        secondaryFiles: [.tbi]
    varscan_unfiltered_vcf:
        type: File
        outputSource: detect_variants/varscan_unfiltered_vcf
        secondaryFiles: [.tbi]
    varscan_filtered_vcf:
        type: File
        outputSource: detect_variants/varscan_filtered_vcf
        secondaryFiles: [.tbi]
    pindel_unfiltered_vcf:
        type: File
        outputSource: detect_variants/pindel_unfiltered_vcf
        secondaryFiles: [.tbi]
    pindel_filtered_vcf:
        type: File
        outputSource: detect_variants/pindel_filtered_vcf
        secondaryFiles: [.tbi]
    docm_filtered_vcf:
        type: File
        outputSource: detect_variants/docm_filtered_vcf
        secondaryFiles: [.tbi]
    final_vcf:
        type: File
        outputSource: detect_variants/final_vcf
        secondaryFiles: [.tbi]
    final_filtered_vcf:
        type: File
        outputSource: detect_variants/final_filtered_vcf
        secondaryFiles: [.tbi]
    final_tsv:
        type: File
        outputSource: detect_variants/final_tsv
    vep_summary:
        type: File
        outputSource: detect_variants/vep_summary
    tumor_snv_bam_readcount_tsv:
        type: File
        outputSource: detect_variants/tumor_snv_bam_readcount_tsv
    tumor_indel_bam_readcount_tsv:
        type: File
        outputSource: detect_variants/tumor_indel_bam_readcount_tsv
    normal_snv_bam_readcount_tsv:
        type: File
        outputSource: detect_variants/normal_snv_bam_readcount_tsv
    normal_indel_bam_readcount_tsv:
        type: File
        outputSource: detect_variants/normal_indel_bam_readcount_tsv
    diploid_variants:
        type: File?
        outputSource: manta/diploid_variants
        secondaryFiles: [.tbi]
    somatic_variants:
        type: File?
        outputSource: manta/somatic_variants
        secondaryFiles: [.tbi]
    all_candidates:
        type: File
        outputSource: manta/all_candidates
        secondaryFiles: [.tbi]
    small_candidates:
        type: File
        outputSource: manta/small_candidates
        secondaryFiles: [.tbi]
    tumor_only_variants:
        type: File?
        outputSource: manta/tumor_only_variants
        secondaryFiles: [.tbi]
##sample concordance check
    somalier_concordance_metrics:
        type: File
        outputSource: concordance/somalier_pairs
    somalier_concordance_statistics:
        type: File
        outputSource: concordance/somalier_samples
steps:
    tumor_alignment_and_qc:
        run: wgs_alignment.cwl
        in:
            reference: reference
            sequence: tumor_sequence
            mills: mills
            known_indels: known_indels
            dbsnp_vcf: dbsnp_vcf
            omni_vcf: omni_vcf
            intervals: qc_intervals
            picard_metric_accumulation_level: picard_metric_accumulation_level
            bqsr_intervals: bqsr_intervals
            minimum_mapping_quality: qc_minimum_mapping_quality
            minimum_base_quality: qc_minimum_base_quality
            per_base_intervals: per_base_intervals
            per_target_intervals: per_target_intervals
            summary_intervals: summary_intervals
            sample_name: tumor_name
        out:
            [bam, mark_duplicates_metrics, insert_size_metrics, insert_size_histogram, alignment_summary_metrics, gc_bias_metrics, gc_bias_metrics_chart, gc_bias_metrics_summary, wgs_metrics, flagstats, verify_bam_id_metrics, verify_bam_id_depth, per_base_coverage_metrics, per_base_hs_metrics, per_target_coverage_metrics, per_target_hs_metrics, summary_hs_metrics, bamcoverage_bigwig] 
    normal_alignment_and_qc:
        run: wgs_alignment.cwl
        in:
            reference: reference
            sequence: normal_sequence
            mills: mills
            known_indels: known_indels
            dbsnp_vcf: dbsnp_vcf
            omni_vcf: omni_vcf
            intervals: qc_intervals
            picard_metric_accumulation_level: picard_metric_accumulation_level
            bqsr_intervals: bqsr_intervals
            minimum_mapping_quality: qc_minimum_mapping_quality
            minimum_base_quality: qc_minimum_base_quality
            per_base_intervals: per_base_intervals
            per_target_intervals: per_target_intervals
            summary_intervals: summary_intervals
            sample_name: normal_name
        out:
            [bam, mark_duplicates_metrics, insert_size_metrics, insert_size_histogram, alignment_summary_metrics, gc_bias_metrics, gc_bias_metrics_chart, gc_bias_metrics_summary, wgs_metrics, flagstats, verify_bam_id_metrics, verify_bam_id_depth, per_base_coverage_metrics, per_base_hs_metrics, per_target_coverage_metrics, per_target_hs_metrics, summary_hs_metrics, bamcoverage_bigwig] 
    concordance:
        run: ../tools/concordance.cwl
        in:
            reference: reference
            bam_1: tumor_alignment_and_qc/bam
            bam_2: normal_alignment_and_qc/bam
            vcf: somalier_vcf
        out:
            [somalier_pairs, somalier_samples]
    detect_variants:
        run: detect_variants.cwl
        in:
            reference: reference
            tumor_bam: tumor_alignment_and_qc/bam
            normal_bam: normal_alignment_and_qc/bam
            interval_list: interval_list
            dbsnp_vcf: dbsnp_vcf
            cosmic_vcf: cosmic_vcf
            panel_of_normals_vcf: panel_of_normals_vcf
            strelka_exome_mode:
                default: false
            strelka_cpu_reserved: strelka_cpu_reserved
            mutect_scatter_count: mutect_scatter_count
            mutect_artifact_detection_mode: mutect_artifact_detection_mode
            mutect_max_alt_allele_in_normal_fraction: mutect_max_alt_allele_in_normal_fraction
            mutect_max_alt_alleles_in_normal_count: mutect_max_alt_alleles_in_normal_count
            varscan_strand_filter: varscan_strand_filter
            varscan_min_coverage: varscan_min_coverage
            varscan_min_var_freq: varscan_min_var_freq
            varscan_p_value: varscan_p_value
            varscan_max_normal_freq: varscan_max_normal_freq
            pindel_insert_size: pindel_insert_size
            docm_vcf: docm_vcf
            filter_docm_variants: filter_docm_variants
            vep_cache_dir: vep_cache_dir
            vep_ensembl_assembly: vep_ensembl_assembly
            vep_ensembl_version: vep_ensembl_version
            vep_ensembl_species: vep_ensembl_species
            synonyms_file: synonyms_file
            annotate_coding_only: annotate_coding_only
            vep_pick: vep_pick
            cle_vcf_filter: cle_vcf_filter
            variants_to_table_fields: variants_to_table_fields
            variants_to_table_genotype_fields: variants_to_table_genotype_fields
            vep_to_table_fields: vep_to_table_fields
            custom_gnomad_vcf: custom_gnomad_vcf
            custom_clinvar_vcf: custom_clinvar_vcf
        out:
            [mutect_unfiltered_vcf, mutect_filtered_vcf, strelka_unfiltered_vcf, strelka_filtered_vcf, varscan_unfiltered_vcf, varscan_filtered_vcf, pindel_unfiltered_vcf, pindel_filtered_vcf, docm_filtered_vcf, final_vcf, final_filtered_vcf, final_tsv, vep_summary, tumor_snv_bam_readcount_tsv, tumor_indel_bam_readcount_tsv, normal_snv_bam_readcount_tsv, normal_indel_bam_readcount_tsv]
    manta: 
        run: ../tools/manta_somatic.cwl
        in:
            normal_bam: normal_alignment_and_qc/bam
            tumor_bam: tumor_alignment_and_qc/bam
            reference: reference
            non_wgs: manta_non_wgs
            output_contigs: manta_output_contigs
        out:
            [diploid_variants, somatic_variants, all_candidates, small_candidates, tumor_only_variants]
    tumor_bam_to_cram:
        run: ../tools/bam_to_cram.cwl
        in:
            bam: tumor_alignment_and_qc/bam
            reference: reference
        out:
            [cram]
    tumor_index_cram:
         run: ../tools/index_cram.cwl
         in:
            cram: tumor_bam_to_cram/cram
         out:
            [indexed_cram]
    normal_bam_to_cram:
        run: ../tools/bam_to_cram.cwl
        in:
            bam: normal_alignment_and_qc/bam
            reference: reference
        out:
            [cram]
    normal_index_cram:
         run: ../tools/index_cram.cwl
         in:
            cram: normal_bam_to_cram/cram
         out:
            [indexed_cram]

