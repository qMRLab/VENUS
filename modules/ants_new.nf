nextflow.enable.dsl=2

process preprocessMtsat {
    // This notation allows deferring the evaluation of sid 
    // until the process is executed, so that it is in the scope
    tag { sid }

    input:
        tuple val(sid), file(pdw), file(mtw), file(t1w)
    
    output:
        tuple val(sid),\
        path("${sid}_flip-01_mt-on_desc-aligned_MTS.nii.gz"), \
        path("${sid}_flip-01_mt-off_desc-aligned_MTS.nii.gz"), \
        path("${sid}_pdw_to_t1w_displacement.*.mat"), \
        path("${sid}_mtw_to_t1w_displacement.*.mat"), \
        path("${sid}_label-csf.nii.gz"), \
        path("${sid}_label-gm.nii.gz"), \
        path("${sid}_label-wm.nii.gz"), \
        path("${sid}_label-brain.nii.gz"), \
        path("${sid}_fsl_log.txt"), \
        path("${sid}_desc-biascorr_T1w.nii.gz"), \
        emit: mtsat_preprocessed

    script:
        """
        antsRegistration -d $params.ants_dim \
                            --float 0 \
                            -o [${sid}_mtw_to_t1w_displacement.mat,${sid}_flip-01_mt-on_desc-aligned_MTS.nii.gz] \
                            --transform $params.ants_transform \
                            --metric $params.ants_metric[$t1w,$mtw,$params.ants_metric_weight, $params.ants_metric_bins,$params.ants_metric_sampling,$params.ants_metric_samplingprct] \
                            --convergence $params.ants_convergence \
                            --shrink-factors $params.ants_shrink \
                            --smoothing-sigmas $params.ants_smoothing

        antsRegistration -d $params.ants_dim \
                            --float 0 \
                            -o [${sid}_pdw_to_t1w_displacement.mat,${sid}_flip-01_mt-off_desc-aligned_MTS.nii.gz] \
                            --transform $params.ants_transform \
                            --metric $params.ants_metric[$t1w,$pdw,$params.ants_metric_weight, $params.ants_metric_bins,$params.ants_metric_sampling,$params.ants_metric_samplingprct] \
                            --convergence $params.ants_convergence \
                            --shrink-factors $params.ants_shrink \
                            --smoothing-sigmas $params.ants_smoothing
        
        fsl_anat -i $t1w -o ./seg --noreorient --clobber --nocrop --noreg --nononlinreg --nosubcortseg --nocleanup --nobias
        mv seg.anat/T1_fast_pve_0.nii.gz ./${sid}_label-csf.nii.gz
        mv seg.anat/T1_fast_pve_1.nii.gz ./${sid}_label-gm.nii.gz
        mv seg.anat/T1_fast_pve_2.nii.gz ./${sid}_label-wm.nii.gz
        mv seg.anat/T1_biascorr_brain_mask.nii.gz ./${sid}_label-brain.nii.gz
        mv seg.anat/log.txt ./${sid}_fsl_log.txt
        mv seg.anat/T1_biascorr.nii.gz ./${sid}_desc-biascorr_T1w.nii.gz
        """
}

process normalizeToMni152 {
    // This notation allows deferring the evaluation of sid 
    // until the process is executed, so that it is in the scope
    tag { sid }

    input:
        tuple val(sid), file(t1wbiascorr), file(fixed)
    
    output:
        tuple val(sid), \
        path("${sid}_T1w2MNI_0GenericAffine.mat"), \
        path("${sid}_T1w2MNI_1Warp.nii.gz"), \
        emit: mni_normalized

    script:
        """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=2

        antsRegistration \
        --dimensionality 3 \
        --float 0 \
        --output [${sid}_T1w2MNI_,${sid}_desc-mni152_T1w.nii.gz] \
        --interpolation Linear \
        --winsorize-image-intensities [0.005,0.995] \
        --use-histogram-matching 0 \
        --initial-moving-transform [$fixed,$t1wbiascorr,1] \
        --transform Rigid[0.1] \
        --metric MI[$fixed,$t1wbiascorr,1,32,Regular,0.25] \
        --convergence [1000x500x250x0,1e-6,10] \
        --shrink-factors 8x4x2x1 \
        --smoothing-sigmas 3x2x1x0vox \
        --transform Affine[0.1] \
        --metric MI[$fixed,$t1wbiascorr,1,32,Regular,0.25] \
        --convergence [1000x500x250x0,1e-6,10] \
        --shrink-factors 8x4x2x1 \
        --smoothing-sigmas 3x2x1x0vox \
        --transform SyN[0.1,3,0] \
        --metric CC[$fixed,$t1wbiascorr,1,4] \
        --convergence [100x70x50x0,1e-6,10] \
        --shrink-factors 8x4x2x1 \
        --smoothing-sigmas 3x2x1x0vox  \
        --use-estimate-learning-rate-once 1 \
        --verbose
        """
}

process warpMaps {
    // This notation allows deferring the evaluation of sid 
    // until the process is executed, so that it is in the scope
    tag { sid }

    input:
        tuple val(sid), file(affine), file(nonlin), file(mtsat), file(mtr), file(t1map), file(fixed)
    
    output:
        tuple val(sid), \
        path("${sid}_desc-mni152_MTsat.nii.gz"), \
        path("${sid}_desc-mni152_MTRmap.nii.gz"), \
        path("${sid}_desc-mni152_T1map.nii.gz"), \
        emit: warped_maps

    script:
        """
        antsApplyTransforms -d 3 -e 0 -i $mtsat -r $fixed -o tmp.nii.gz -t $affine
        antsApplyTransforms -d 3 -e 0 -i tmp.nii.gz -r $fixed -o ${sid}_desc-mni152_MTsat.nii.gz -t $nonlin
        rm tmp.nii.gz
        antsApplyTransforms -d 3 -e 0 -i $mtr -r $fixed -o tmp.nii.gz -t $affine
        antsApplyTransforms -d 3 -e 0 -i tmp.nii.gz -r $fixed -o ${sid}_desc-mni152_MTRmap.nii.gz -t $nonlin
        rm tmp.nii.gz
        antsApplyTransforms -d 3 -e 0 -i $t1map -r $fixed -o tmp.nii.gz -t $affine
        antsApplyTransforms -d 3 -e 0 -i tmp.nii.gz -r $fixed -o ${sid}_desc-mni152_T1map.nii.gz -t $nonlin
        rm tmp.nii.gz
        """
}



