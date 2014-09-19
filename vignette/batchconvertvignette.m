function batchconvertvignette(imagelist, coef):
    [filenames] = textread(inputfiles, "%s");
    n = length(filenames);
    for i=1:n
        vcim = convertvignette(imread(filenames{i}), coef);
        [~,fileroot,fileext] = fileparts(filenames{i})
        imwrite(vcim, [fileroot "_corrected" fileext])
    end
