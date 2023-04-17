% See also HSVImFilter; iam and icr and the image for amorphous and
% crystalline values while the low and high hues are values from 0 to 1 for
% the hue of the PCM.
function [maskValues,normMeanAm,normMeanCr]=HSVFilter(iam,icr,low_hue, high_hue)
    [maskAm, meanMaskAm,meanBckgAm] = HSVImFilter(iam, low_hue,high_hue);
    [maskCr, meanMaskCr,meanBckgCr] = HSVImFilter(icr, low_hue,high_hue);
    maskValues =[sum(sum(maskAm));sum(sum(maskCr))];
    normMeanAm = meanMaskAm./meanBckgAm;
    normMeanCr = meanMaskCr./meanBckgCr;
end