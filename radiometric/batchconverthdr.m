function batchconverthdr(imagelist, g)
    [filenames exposures] = textread(imagelist, "%s %f");
    n = length(filenames);
    for i=1:n
        image = imread(filenames{i});
        if ndims(image) < 3
            image(:,:,1) = image(:,:);
            image(:,:,2) = image(:,:,1);
            image(:,:,3) = image(:,:,1);
        end
        w = size(image,2);
        h = size(image,1);
        dimensions = size(image)(1:2);
        R = reshape(exp(g(1,image(:,:,1)+1) - log(exposures(i))), dimensions);
        G = reshape(exp(g(2,image(:,:,2)+1) - log(exposures(i))), dimensions);
        B = reshape(exp(g(3,image(:,:,3)+1) - log(exposures(i))), dimensions);
        pfs_write_rgb([filenames{i} ".hdr"], R, G, B);
    end
