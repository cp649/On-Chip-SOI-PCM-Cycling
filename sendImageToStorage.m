% Save image as both png and .mat file for further analysis. The png image
% has the title added for information on pulses sent and cycle number.
function sendImageToStorage(ih,image, ChipName, DeviceName,cycle,state,imgDir)
fileName = (['sam',num2str(ChipName),'_dev',num2str(DeviceName),'_date',num2str(date),datestr(now,'HHMMSS'),'_cyc',num2str(cycle),'_ts',state]);
fileName = strcat(imgDir,fileName);
saveas(ih,strcat(fileName,'.png'),'png');
save(strcat(fileName,'.mat'), 'image');
end