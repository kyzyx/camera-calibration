# convert.py
# Takes output from NiViewer captures and converts it into a suitable
# format for MATLAB processing

import sys
from subprocess import call

if len(sys.argv) < 5:
    print "Usage: python convert.py n_frames frames_per_exposure delta_exposure initial_exposure"
else:
    n = int(sys.argv[1]) # Total number of frames to process
    fpe = int(sys.argv[2]) # Number of frames per exposure
    de = float(sys.argv[3]) # Exposure increment
    initial = float(sys.argv[4]) # Initial exposure

    outputfile = "imagelist.txt"

    o = open(outputfile, "w")
    for idx,i in enumerate(range(0,n,fpe)):
        fname = "image%3d.png"%(idx)
        files = ["RGB:Color_%d.raw"%x for x in range(i,i+fpe)]
        cmd = ["convert", "-size", "640x480", "-depth", "8"] + files + ["-average", fname]
        call(cmd)
        o.write("%s %f\n"%(fname, initial+idx*de))
