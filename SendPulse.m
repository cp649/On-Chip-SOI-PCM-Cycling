% fgen/fagi is the visa object pointing to the Agilent 
% fkie is the visa object pointing to the Keithley
% The voltage is the voltage drop to be applied to the PCM
% The period is a time duration during which the pulse will take place.
% This is not the same as the width. The width is the pulse width that we
% care about applying to the sample but the period is set such that the
% Agilent can treat it as an oscillating function. 
% tdelay is a built in time delay to allow the power source to reach a
% steady state voltage. 
function [MeasCurr,MeasVolt,MeasResi]=SendPulse(fgen,fkie, Voltage, period, width,tdelay)
    fprintf(fkie,['VOLT ',num2str(Voltage)]); %set crystallization voltage 
    pause(tdelay);
    pause(0.2);
    fprintf(fgen,['pulse:period ',' ',num2str(period)]); %enable output
    fprintf(fgen,['pulse:width ',' ',num2str(width)]); %enable output
    fprintf(fgen,'TRIG:SOUR BUS;*TRG;');
    if width>500E-3
        pause(500E-3);
        fprintf(fkie,['MEAS:CURR?']);
        MeasCurr = fscanf (fkie);
%         fprintf (['Curr: ',MeasCurr]);
        MeasCurr = str2double(MeasCurr);
        fprintf(fkie,['MEAS:VOLT?']);
        MeasVolt = fscanf (fkie);
%         fprintf (['Volt: ',MeasVolt])
        MeasVolt = str2double(MeasVolt);
        MeasResi = MeasVolt/MeasCurr;
%         fprintf(['Resi: ',num2str(MeasResi)]);      
    end
    fprintf(fgen,'*WAI');
    pause(period*1.5);
end