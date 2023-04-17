% Provides the image mean values, standard deviation and kurtosis (3-rd
% moment of the data). MeanIm converts the iamge to double for analysis.
% The results are given across the three color channels. 
function [result] = MeanIm(image)
    meanValues =squeeze(mean(mean(double(image(:,:,:)))));
    stdIm = std(reshape(double(image(:,:,:)),[numel(image(:,:,1)),3]));
    kurtIm = kurtosis(reshape(double(image(:,:,:)),[numel(image(:,:,1)),3]));
    result = [meanValues';stdIm;kurtIm];
end