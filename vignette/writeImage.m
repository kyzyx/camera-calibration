function writeImage(im,filename)
    [~,fileroot,fileext] = fileparts(filename);
    if strcmp(fileext, ".hdr")
        pfs_write_rgb(filename, im(:,:,1),im(:,:,2),im(:,:,3));
    else
        imwrite(im, filename);
    end
end
