function coef = dovignette(imagelist, degree)
    [imfiles maskfiles] = textread(imagelist, "%s %s");
    n = length(imfiles);

    for i=1:n
        images(:,:,:,i) = imread(imfiles{i});
        masks(:,:,:,i) = imread(maskfiles{i});
    end

    coef = vignette(images, masks, degree);
