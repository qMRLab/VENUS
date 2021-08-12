nextflow.enable.dsl=2
include { getSubSesEntity; checkSesFolders } from './modules/bids_patterns'

params.bids = false 
params.help = false

log.info  "##    # ###### #    # #####   ####  #    #  ####  #####  "
log.info " # #   # #      #    # #    # #    # ##  ## #    # #    # "
log.info " #  #  # #####  #    # #    # #    # # ## # #    # #    # "
log.info " #   # # #      #    # #####  #    # #    # #    # #    # "
log.info " #    ## #      #    # #   #  #    # #    # #    # #    # "
log.info " #     # ######  ####  #    #  ####  #    #  ####  #####  "

/* Call to the mt_sat_wrapper.m will be invoked by params.runcmd.
Depending on the params.platform selection, params.runcmd 
may point to MATLAB or Octave. 
*/
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



Channel
    .fromFilePairs("$bids/${entity.dirInputLevel}sub-invivo*_flip-{01,02}_mt-{on,off}_MTS.nii.gz", maxDepth: 3, size: 3, flat: true)
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
      path(mtw_aligned), path(pdw_aligned)

    publishDir "${derivativesDir}/${out.sub}/${out.ses}anat", mode: 'copy', overwrite: true

    output:
      tuple val(sid), \
      path(mtw_aligned), path(pdw_aligned)

    script:
        """
        mkdir -p ${derivativesDir}
        echo "Transferring ${mtw_aligned} to ${derivativesDir}/${out.sub}/${out.ses}anat folder..."
        """
}

include { alignMtsatInputs; resampleB1; generateRegionMasks } from './modules/ants'

workflow {

alignMtsatInputs(mtsat_for_alignment)
publishOutputs(alignMtsatInputs.out.mtsat_from_alignment)

}







} else{
        error "ERROR: Argument (--bids) must be passed. See USAGE."

}