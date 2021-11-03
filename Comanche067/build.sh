#!/bin/bash

touch gpp/defines.default
export ReconstructionLevel=PreferredReconstruction
make clean default || make diffComanche067sums
