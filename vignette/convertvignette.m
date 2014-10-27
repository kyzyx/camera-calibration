function im=convertvignette(image, coef)
    w = size(image,2);
    h = size(image,1);
    d = size(coef,1);

    % Construct distance matrix
    rx = (1:w) - (w+1)/2;
    ry = (1:h) - (h+1)/2;
    rtable = repmat((rx.*rx), h, 1) + repmat((ry.*ry)', 1, w);
    for i=1:h
        for j=1:w
            vtable(i,j,:) = 1 + rtable(i,j).^(1:d)*coef;
        end
    end
    im = image./vtable;
