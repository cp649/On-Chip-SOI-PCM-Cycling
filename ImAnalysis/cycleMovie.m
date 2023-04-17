%%
% clear; clc; close all;
filePath = 'E:\CF GSST\1P_CF_THK_1\315.2\';
% filePath = 'C:\Users\popes\Dropbox (MIT)\CF GSST\1S_CF_150_1\305.2\';
fileNames = GetSortedMatFileNames(filePath);
movPath  = 'E:\Videos for conf\';
% movPath  = 'C:\Users\popes\Desktop\';
LastCycle = GetLastCycle(fileNames);
cycles = zeros(LastCycle,1);
% fig = figure('NumberTitle','off','Visible','on'); 
v = VideoWriter(fullfile(movPath,'THK_315_End2.avi'));
v.FrameRate = 4;
open(v);
SelectedCycles = [69400:1:69420]*2;
for ii = SelectedCycles
    for inst = 0:1 %0  - amr; 1 - crs
    cyc = GetCycleNumber(fileNames(ii+inst).name);
    state = GetState(fileNames(ii+inst).name);
    if strcmp(state,'art')
        state = 'Start ';
    enddirSb2Se3 = 'C:\Users\popes\Dropbox (MIT)\Lincoln Labs PCM Project\';
ka =importdata(fullfile(dirSb2Se3,'Delan 2020 Sb2Se3 k a.csv')); 
kc =importdata(fullfile(dirSb2Se3,'Delan 2020 Sb2Se3 k c.csv')); 
na =importdata(fullfile(dirSb2Se3,'Delan 2020 Sb2Se3 n a.csv')); 
nc =importdata(fullfile(dirSb2Se3,'Delan 2020 Sb2Se3 n c.csv')); 
%Chen, C., Li, W., Zhou, Y., Chen, C., Luo, M., Liu, X., Zeng, K., Yang, B., Zhang, C., Han, J. and Tang, J., 2015. Optical properties of amorphous and polycrystalline Sb2Se3 thin films prepared by thermal evaporation. Applied Physics Letters, 107(4), p.043905.

ncom_am = interp1(na(:,1),na(:,2),wavelength*1e3,'pchip','extrap')+1i*interp1(ka(:,1),ka(:,2),wavelength*1e3,'pchip','extrap');
ncom_cr = interp1(nc(:,1),nc(:,2),wavelength*1e3,'pchip','extrap')+1i*interp1(kc(:,1),kc(:,2),wavelength*1e3,'pchip','extrap');

    image = uint8(GetStoredImage(filePath,fileNames(ii+inst).name));
    image(900:920,1000:1180,:) = 0;
    RGB = insertText(image,[0 , 0],[state,' ',num2str(cyc)],'FontSize' ,50,'BoxColor','white','BoxOpacity' ,0);
    writeVideo(v,RGB);
    end
end
close(v); disp('finished')