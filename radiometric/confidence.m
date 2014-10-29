function confidence(imagelist)
    [filenames ~] = textread(imagelist, "%s %f");
    n = length(filenames);

    lowerthreshold = 40.0;
    upperthreshold = 230.0;

    for i=1:n
        image = double(imread(filenames{i}));
        if ndims(image) < 3
            image(:,:,1) = image(:,:);
            image(:,:,2) = image(:,:,1);
            image(:,:,3) = image(:,:,1);
        end

        conf = image;
        conf(conf < lowerthreshold) = 0;
        conf(conf > upperthreshold) = -1;
        conf(conf > 0) = (conf(conf > 0) - lowerthreshold)/(upperthreshold-lowerthreshold) * 0.75 + 0.25;
        conf = min(conf, [], 3);
        
        file = fopen([filenames{i} ".conf"], 'w');
        fwrite(file, conf', 'float32');
        fclose(file);
    end
