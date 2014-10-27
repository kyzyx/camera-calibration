function batchconvertvignette(imagelist, coef)
    [filenames] = textread(imagelist, "%s");
    n = length(filenames);

    % Construct distance matrix
    tmp = imread(filenames{1});
    w = size(tmp,2);
    h = size(tmp,1);
    d = size(coef,1);
    rx = (1:w) - (w+1)/2;
    ry = (1:h) - (h+1)/2;
    rtable = repmat((rx.*rx), h, 1) + repmat((ry.*ry)', 1, w);

    for i=1:h
        for j=1:w
            vtable(i,j,:) = 1 + rtable(i,j).^(1:d)*coef;
        end
    end

    for i=1:n
        image = imread(filenames{i});
        if length(size(image)) != 3
            im(:,:,1) = image;
            im(:,:,2) = image;
            im(:,:,3) = image;
            image = im;
        end
        vcim = image./vtable;
        [~,fileroot,fileext] = fileparts(filenames{i});
        imwrite(vcim, [fileroot "_corrected" fileext]);
    end
