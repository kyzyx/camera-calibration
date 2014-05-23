function batchconverthdr(imagelist, g):
    [filenames exposures] = textread(inputfiles, "%s %f");
    n = length(filenames);
    for i=1:n
        hdrimage = exp(converthdr(imread(filenames{i}), exposures(i), g));
        pfs_write_image(hdrimage, [filenames{i} ".hdr"]);
    end
