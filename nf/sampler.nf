params.publish = 'box'

process mkbox {
  tag "$tag"
  label 'ase'
  publishDir "$params.publish/$tag"

  input:
  tuple val(tag), path(cif)

  output:
  tuple val(tag), path("box.xyz")

  script:
  """
  #!/usr/bin/env python

  from ase.io import read

  cif = read("$cif")

  # box = cif + li somehow add the li to the box

  write('box.xyz', box)
  """
}
