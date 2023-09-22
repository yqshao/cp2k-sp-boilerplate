#!/usr/bin/env nextflow

// This is a demo workflow of running CP2K SP calculations in batches

// include {mkbox} from './nf/sampler'
include {cp2k, mkcp2kinp} from './nf/cp2k.inp'

params.cp2k_inp = 'input/cp2k/*.inp'
params.cif_inp = 'input/cif/*.cif'

workflow {
  ch_cp2k = Channel.fromPath("${params.cp2k_inp}")
  ch_cif = Channel.fromPath("${params.cif_inp}")
  // ch_xyz  = ch_cif | mkbox | map {tag, xyz -> ["$tag/${xyz.baseName}", xyz]}

  ch_cp2k.combine(ch_cif) |
    | map {cp2k, cif -> ["${cp2k.baseName}/${cif.baseNmae}", cif, cp2k]} \
    | mkcp2kinp \
    | cp2k
}
