function hdrimage=converthdr(image, exposure, g):
    for i=1:3
        hdrimage(:,:,i) = exp(g(i,image(:,:,i)) - log(exposure));
    end
