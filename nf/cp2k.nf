params.publish = 'cp2k'
params.c2pk_aux = './input/cp2k/aux'

process mkcp2kinp{
  tag "$tag"
  label 'ase'
  publishDir "$params.publish/$tag"

  input:
  tuple val(tag), path(xyz), path(skel)

  out:
  tuple val(tag), path("cp2k.inp")

  script:
  """
  #!/usr/bin/env python
  from ase.io import read, write
  from ase.data import chemical_symbols as symbol

  atoms = read('$xyz')

  # generate subsys string
  coord = [
      f"  {symbol[e]} {x} {y} {z}"
      for e, (x, y, z) in zip(atoms.numbers, atoms.positions)
  ]
  cell = [f"  {v} {x} {y} {z}" for v, (x, y, z) in zip("ABC", datum["cell"])]
  subsys = ["&COORD"] + coord + ["&END COORD"] + ["&CELL"] + cell + ["&END CELL"]

  # get subsys position and indent in skeleton
  lines = open(fin).readlines()
  for idx, line in enumerate(lines):
      if "&END SUBSYS" in line:
          indent = len(line) - len(line.lstrip())
          break

  # write cp2k input
  subsys = [" " * (indent + 2) + l + "\n" for l in subsys]
  lines = lines[:idx] + subsys + lines[idx:]
  with open(fout, "w") as f:
      f.writelines(lines)
  """
}


process cp2k {
  tag "$tag"
  label 'cp2k'
  publishDir "$params.publish/$tag"

  input:
  tuple val(name), path(input), path(aux)

  output:
  tuple val(name), path('cp2k.log'), emit:logs
  tuple val(name), path('*.{ener,xyz,stress,cell}'), emit:traj, optional: true
  tuple val(name), path('*.restart'), emit:restart, optional:true

  script:
  """
  #!/bin/bash
  $params.cp2k_cmd -i $input | tee cp2k.log
  """
}
