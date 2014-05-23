% vignette.m - Recovers a polynomial vignette function from a set of images
%
% Takes in a set of images and a set of binary masks

function coef = vignette(images, masks, d)
    n = size(images,4);
    w = size(images,2);
    h = size(images,1);

    % Construct distance matrix
    rx = (1:w) - (w+1)/2;
    ry = (1:h) - (h+1)/2;
    rtable = repmat((rx.*rx), h, 1) + repmat((ry.*ry)', 1, w);

    % Construct idx->dist table
    idx2dist = sort(unique(reshape(rtable, numel(rtable), [])));

    % Construct dist->idx table, using hack that 2*rs is integer
    dist2idx = spalloc(2*max(idx2dist), 1, length(idx2dist));
    dist2idx(2*idx2dist) = 1:length(idx2dist);

    % Calculate average pixel for each radius
    avgpx = zeros(length(idx2dist), 3, n);
    counts = zeros(length(idx2dist), 3, n);
    for z=1:n
        for i=1:w
            for j=1:h
                if masks(j,i,z) == 0
                    idx = dist2idx(rtable(j,i)*2);
                    avgpx(idx,:,z) += cast(reshape(images(j,i,:,z), 1, 3), "double");
                    counts(idx,:,z) += 1;
                end
            end
        end
    end
    avgpx = avgpx./counts;

    % Construct system with pairs of radii
    numsamples = 4000;
    for ch=1:3
        A = zeros(numsamples, d);
        b = zeros(numsamples,1);
        for i=1:numsamples
            x = randi(length(idx2dist), 1, 2);
            while x(1) == x(2)
                x = randi(length(idx2dist), 1, 2);
            end
            z = randi(n);
            a = avgpx(x(1),ch,z)/avgpx(x(2),ch,z);
            A(i,:) = a*idx2dist(x(2)).^(1:d) - idx2dist(x(1)).^(1:d);
            b(i) = 1 - a;
        end
        % Solve with SVD
        coef(:,ch) = A\b;
    end
