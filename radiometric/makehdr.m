% makehdr.m - Get response function from a set of registered images
%
% Takes in a file containing a list of images and their exposure times.
% image1.png 0.33
% image2.png 0.66
% etc.
% 
% Returns the response function g

function g = makehdr(inputfiles, lambda)
    [filenames exposures] = textread(inputfiles, "%s %f");
    logE = log(exposures);
    n = length(filenames);

    for i=1:n
        im(:,:,:,i) = imread(filenames{i});
    end

    sz = numel(im(:,:,1,1));
    images = reshape(im, [sz, 3, n]);

    % Simple hat function for weighting
    w = 0:255;
    w(129:256) = 255 - w(129:256);

    subsample = 400;
    for i=1:3
        %[g(i,:), _] = gsolve(reshape(images(:,i,:), [sz, n]), logE, lambda, w);
        [g(i,:), _] = gsolve(reshape(images(1:subsample:sz,i,:), [ceil(sz/subsample), n]), logE, lambda, w);
    end

    % TODO: Color balancing
