function coef = dovignette(imagelist)
    [imfiles maskfiles] = textread(imagelist, "%s %s");
    n = length(imfiles);

    for i=1:n
        images(:,:,:,i) = imread(imfiles{i});
        masks(:,:,:,i) = imread(maskfiles{i});
    end

    coef = vignette(images, masks, 3);
