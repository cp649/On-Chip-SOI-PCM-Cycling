function [ViabPixel, DMA_Am,DMA_Cr,DMA_Contrast] = DMAImFilter(iam, icr,R_Thr,G_Thr,B_Thr)   
   % Differential contrast mask analysis
    iam = double(iam); icr = double(icr);
    diim = abs((icr)-(iam));
    [ViabPixel,mask] = DifferenceFilter(diim,R_Thr,G_Thr,B_Thr);
    BrtAm = repmat((~mask),1,1,3).*iam; bram = sum(sum(BrtAm))/(size(iam,1)*size(iam,2)-ViabPixel(4));
    BrtCr =repmat((~mask),1,1,3).*icr; brcr = sum(sum(BrtCr))/(size(iam,1)*size(iam,2)-ViabPixel(4));
    DMA_Am = sum(sum(repmat((mask),1,1,3).*iam))/ViabPixel(4)./bram;
    DMA_Cr = sum(sum(repmat((mask),1,1,3).*icr))/ViabPixel(4)./brcr;
    DMA_Contrast = DMA_Cr - DMA_Am;
end