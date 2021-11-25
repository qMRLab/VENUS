nextflow.enable.dsl=2
include { getSubSesEntity; checkSesFolders } from './modules/bids_patterns'

params.bids = false 
params.help = false

if (params.platform == "octave"){

    if (params.octave_path){
        log.info "Using Octave executable declared in nextflow.config."
        params.octave = params.octave_path + " --no-gui --eval"
    }else{
        log.info "Using Octave in Docker or (if local) from the sys path."
        params.octave = "octave --no-gui --eval"
    }

    params.runcmd = params.octave 
}

if (params.platform == "matlab"){
   
    if (params.matlab_path){
        log.info "Using MATLAB executable declared in nextflow.config."
        params.matlab = params.matlab_path + " -nodisplay -nosplash -nodesktop -r"
    }else{
        log.info "Using MATLAB from the sys path."
        params.matlab = "matlab -nodisplay -nosplash -nodesktop -r"
    }

    params.runcmd = params.matlab
}

params.wrapper_repo = "https://github.com/qMRLab/qMRWrappers.git"
              
workflow.onComplete {
    log.info "Pipeline completed at: $workflow.complete"
    log.info "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
    log.info "Execution duration: $workflow.duration"
    log.info "Mnemonic ID: $workflow.runName"
}

/*Define bindings for --help*/
if(params.help) {
    usage = file("$baseDir/USAGE")
    cpu_count = Runtime.runtime.availableProcessors()
    bindings = ["ants_dim":"$params.ants_dim",
                "ants_metric":"$params.ants_metric",
                "ants_metric_weight":"$params.ants_metric_weight",
                "ants_metric_bins":"$params.ants_metric_bins",
                "ants_metric_sampling":"$params.ants_metric_sampling",
                "ants_metric_samplingprct":"$params.ants_metric_samplingprct",
                "ants_transform":"$params.ants_transform",
                "ants_convergence":"$params.ants_convergence",
                "ants_shrink":"$params.ants_shrink",
                "ants_smoothing":"$params.ants_smoothing",
                "use_b1cor":"$params.use_b1cor",
                "b1cor_factor":"$params.b1cor_factor",
                "use_bet":"$params.use_bet",
                "bet_recursive":"$params.bet_recursive",
                "bet_threshold":"$params.bet_threshold",
                "platform":"$params.platform",
                "matlab_path":"$params.matlab_path",
                "octave_path":"$params.octave_path",
                "qmrlab_path":"$params.qmrlab_path"
                ]

    engine = new groovy.text.SimpleTemplateEngine()
    template = engine.createTemplate(usage.text).make(bindings)

    print template.toString()
    return
}

entity = checkSesFolders()

if(params.bids){
    log.info "Input: $params.bids"
    bids = file(params.bids)
    derivativesDir = "$params.qmrlab_derivatives"
    log.info "Derivatives: $params.qmrlab_derivatives"
    log.info "Nextflow Work Dir: $workflow.workDir"


// In future releases of qMRLab, the process will be trigerreed by a list of base file names (i.e. noo need to specify nii/json).
Channel
    .fromFilePairs("$bids/${entity.dirInputLevel}sub-invivo*_flip-{01,02}_mt-{on,off}_MTS.nii*", maxDepth: 3, size: 3, flat: true)
    .multiMap {sid, MToff, MTon, T1w ->
    PDw: tuple(sid, MToff)
    MTw: tuple(sid, MTon)
    T1w: tuple(sid, T1w)
    }
    .set{niiMTS}

Channel
    .fromFilePairs("$bids/${entity.dirInputLevel}sub-invivo*_flip-{01,02}_mt-{on,off}_MTS.json", maxDepth: 3, size: 3, flat: true)
    .multiMap {sid, MToff, MTon, T1w ->
    PDw: tuple(sid, MToff)
    MTw: tuple(sid, MTon)
    T1w: tuple(sid, T1w)
    }
    .set{jsonMTS}

niiMTS.PDw
   .join(jsonMTS.PDw)
   .set {pairPDw}

PDw = pairPDw
        .multiMap { it -> 
                    Nii: tuple(it[0],it[1])
                    Json: tuple(it[0],it[2])
                  }

niiMTS.MTw
   .join(jsonMTS.MTw)
   .set {pairMTw}

MTw = pairMTw
        .multiMap { it -> 
                    Nii: tuple(it[0],it[1]) 
                    Json: tuple(it[0],it[2])
                    }

niiMTS.T1w
   .join(jsonMTS.T1w)
   .set {pairT1w}

T1w = pairT1w
        .multiMap { it -> 
                    Nii:  tuple(it[0],it[1]) 
                    Json: tuple(it[0],it[2])
                    }

PDw.Nii
    .join(MTw.Nii)
    .join(T1w.Nii)
    .set{mtsat_for_alignment}


process publishOutputs {

    exec:
        out = getSubSesEntity("${sid}")

    input:
      tuple val(sid), \
      path(mtw_aligned), path(pdw_aligned), path(pd2t1), path(mt2t1), path(csf), path(gm), path(wm), path(brain), path(log), path(biascorr), \
      path(t1mapnii),path(t1mapjson),path(mtsatmapnii),path(mtsatmapjson),path(qmrlabmodel), \
      path(mtrmapnii), path(mtrmapjson), path(mtrmapqmrlab) // , \
//      path(mni1), path(mni2), path(mni3) Comment in for mni152 alignment 

    publishDir "${derivativesDir}/${out.sub}/${out.ses}anat", mode: 'copy', overwrite: true

    output:
      tuple val(sid), \
      path(mtw_aligned), path(pdw_aligned), path(pd2t1), path(mt2t1), path(csf), path(gm), path(wm), path(brain), path(log), path(biascorr), \
      path(t1mapnii), path(t1mapjson),path(mtsatmapnii),path(mtsatmapjson),path(qmrlabmodel), \
      path(mtrmapnii), path(mtrmapjson), path(mtrmapqmrlab) // ,\
//      path(mni1), path(mni2), path(mni3) Comment in for mni152 alignmend

    script:
        """
        mkdir -p ${derivativesDir}
        """
}

process publishStat {

    exec:
        out = getSubSesEntity("${sid}")

    input:
      tuple val(sid), \
      path(a), path(b), path(c)

    publishDir "${derivativesDir}/${out.sub}/${out.ses}stat", mode: 'copy', overwrite: true

    output:
      tuple val(sid), \
      path(a), path(b), path(c)

    script:
        """
        mkdir -p ${derivativesDir}
        """
}

include { preprocessMtsat; normalizeToMni152; warpMaps} from './modules/ants_new'
include { fitMtsat } from './modules/mt_sat' addParams(runcmd: params.runcmd)
include { fitMtratio } from './modules/mt_ratio' addParams(runcmd: params.runcmd)
include { prepStat } from './modules/statprep' addParams(runcmd: params.runcmd)

workflow {

// NOTE: mtsat_for_alignment is not publishing segmentation outputs with SID so not published
preprocessMtsat(mtsat_for_alignment)

Prec = preprocessMtsat.out.mtsat_preprocessed
        .multiMap { it -> 
                    MTwAl: tuple(it[0],it[1]) 
                    PDwAl: tuple(it[0],it[2])
                    GmMask: tuple(it[0],it[6])
                    WmMask: tuple(it[0],it[7])
                    Mask:  tuple(it[0],it[8])
                    BiasCor:  tuple(it[0],it[10])}

// PDw --> MTw --> T1w order matters
Prec.PDwAl
    .join(Prec.MTwAl)
    .join(T1w.Nii)
    .join(PDw.Json)
    .join(MTw.Json)
    .join(T1w.Json)
    .join(Prec.Mask)
    .set{qmrlab_mtsat}

Prec.PDwAl
    .join(Prec.MTwAl)
    .join(Prec.Mask)
    .set{qmrlab_mtr}

fitMtsat(qmrlab_mtsat)
fitMtratio(qmrlab_mtr)

fitMtsat.out.publish_mtsat
    .join(preprocessMtsat.out.mtsat_preprocessed)
    .join(fitMtratio.out.publish_mtratio)
    .set{publishChannel}



MTSout = fitMtsat.out.publish_mtsat
        .multiMap { it -> 
                    T1map: tuple(it[0],it[1]) 
                    MTsat: tuple(it[0],it[2])
                    }

MTRout = fitMtratio.out.publish_mtratio
        .multiMap { it -> 
                    MTRmap: tuple(it[0],it[1])
                    }

MTSout.MTsat
        .join(MTSout.T1map)
        .join(MTRout.MTRmap)
        .join(Prec.GmMask)
        .join(Prec.WmMask)
        .set{for_stat}

prepStat(for_stat)
publishStat(prepStat.out.publish_stat)

//Channel
//    .fromPath("$bids/mni152_t1w_nlinsym_09c.nii")
//    .set{fixed}
   

// This is a useful trick to mix sid with a const file
// Prec.BiasCor
//    .combine(fixed)
//    .set {to_mni_reg}

// normalizeToMni152(to_mni_reg)

// MNItfm = normalizeToMni152.out.mni_normalized
//                            .multiMap { it -> 
//                                Affine: tuple(it[0],it[1])
//                                Nonlin: tuple(it[0],it[2])}

// MNItfm.Affine
//    .join(MNItfm.Nonlin)
//    .join(MTSout.MTsat)
//    .join(MTRout.MTRmap)
//    .join(MTSout.T1map)
//    .combine(fixed)
//    .set{to_warp}

//warpMaps(to_warp)

// publishChannel
//    .join(warpMaps.out.warped_maps)
//    .set{publishNew}

// publishOutputs(publishNew)

publishOutputs(publishChannel)

}

} else{
        error "ERROR: Argument (--bids) must be passed. See USAGE."

}