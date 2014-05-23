function hdrimage=converthdrstack(inputfiles, g)
    [filenames exposures] = textread(inputfiles, "%s %f");
    n = length(filenames);
    orig = imread(filenames{1});
    hat = 0:255;
    hat(129:256) = 255 - hat(129:256);
    w = size(orig,2);
    h = size(orig,1);
    hdrimage = zeros(h,w,3);
    weight = ones(h,w,3);
    for i=1:n
        orig = imread(filenames{i});
        im = converthdr(orig, exposures(i), g);
        for j=1:h
            for k=1:w
                hdrimage(j,k,:) += im(j,k,:).*hat(orig(j,k,:)+1);
                weight(j,k,:) += hat(orig(j,k,:)+1);
            end
        end
    end
    hdrimage = exp(hdrimage./weight);
