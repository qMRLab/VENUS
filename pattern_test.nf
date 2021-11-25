nextflow.enable.dsl=2
params.bids = false 
include { getSubSesEntity; checkSesFolders } from './modules/bids_patterns'

entity = checkSesFolders()

if(params.bids){
log.info "Input: $params.bids"
bids = file(params.bids)

Channel
    .fromFilePairs("$bids/${entity.dirInputLevel}sub-invivo*_flip-{01,02}_mt-{on,off}_MTS.nii*", maxDepth: 3, size: 3, flat: true)
    .multiMap {sid, MToff, MTon, T1w ->
    PDw: tuple(sid, MToff)
    MTw: tuple(sid, MTon)
    T1w: tuple(sid, T1w)
    }
    .set{niiMTS}

Channel
    .fromPath("$bids/mni152_t1w_nlinsym_09c.nii")
    .set{a}
   

niiMTS.T1w
    .concat(a)
    .flatten()
    .toList()
    .set{ch}

}
else{

}

include {  } from './modules/ants_new'

workflow {

// NOTE: mtsat_for_alignment is not publishing segmentation outputs with SID so not published
dene(baban)

}