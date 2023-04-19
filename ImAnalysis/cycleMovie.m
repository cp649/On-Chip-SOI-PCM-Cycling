%%
% clear; clc; close all;
filePath = 'E:\CF GSST\1P_CF_THK_1\315.2\';

fileNames = GetSortedMatFileNames(filePath);
movPath  = 'E:\Videos for conf\';

LastCycle = GetLastCycle(fileNames);
cycles = zeros(LastCycle,1);

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
    end
    image = uint8(GetStoredImage(filePath,fileNames(ii+inst).name));
    image(900:920,1000:1180,:) = 0;
    RGB = insertText(image,[0 , 0],[state,' ',num2str(cyc)],'FontSize' ,50,'BoxColor','white','BoxOpacity' ,0);
    writeVideo(v,RGB);
    end
end
close(v); disp('finished')