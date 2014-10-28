function im = readImage(filename)
    [~,fileroot,fileext] = fileparts(filename);
    if strcmp(fileext, ".hdr")
        [r g b] = pfs_read_rgb(filename);
        im(:,:,1) = r;
        im(:,:,2) = g;
        im(:,:,3) = b;
    else
        im = imread(filename);
    end
end
