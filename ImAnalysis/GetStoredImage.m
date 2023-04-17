function image = GetStoredImage(filePath,fileName)
    data =load(fullfile(filePath,fileName));
    image = data.image;
end