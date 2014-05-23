function hdrimage=converthdr(image, exposure, g)
    w = size(image,2);
    h = size(image,1);
    for i=1:h
        for j=1:w
            for ch=1:3
                hdrimage(i,j,ch) = (g(ch,image(i,j,ch)+1) - log(exposure));
            end
        end
    end
