function [ViabPixel,mask] = DifferenceFilter(diim,R_Thr,G_Thr,B_Thr)
if isa(diim,'uint8')
    diim = double(diim);
end
    R_binary = imbinarize(diim(:,:,1),R_Thr);
    G_binary = imbinarize(diim(:,:,2),G_Thr);
    B_binary = imbinarize(diim(:,:,3),B_Thr);
    mask     = imbinarize(R_binary+G_binary+B_binary,0.5);
    ViabPixel(1) = sum(sum(R_binary));
    ViabPixel(2) = sum(sum(G_binary));
    ViabPixel(3) = sum(sum(B_binary));
    ViabPixel(4) = sum(sum(mask));
end