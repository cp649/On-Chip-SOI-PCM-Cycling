%%
clear all; close all; clc;
addpath('.\ImAnalysis')
% You need the "clear all" as the connections via visa to the machines
% seems to encounter problems with previously stored values (cache memory
% probably).
%% Drivers to install
% Install NI visa from the National Instruments website and make sure you
% have instrument control toolbox and image analysis toolbox in MATLAB
% To install ni-visa_21.5_online.exe from https://www.ni.com/en-us/support/downloads/drivers/download/packaged.ni-visa.442805.html
% Did NOT turn off "Fast startup in Windows". It doesn't seem to have
% created issues
% Recurring issue - short pulses seem to be processed in the second regime (i.e. 205 s period but with correct width).
%

%% Documentation on using the pulsed PCM script
% Cosmin Popescu, 2022 07 09.  MATLAB R2020b.V 1.0
% Tested also on MATLAB R2022b 9.13.0.2049777 and on R2021a 
% Version 2.0 2023 02 15 with screenshot for when direct connection to the
% camera is not possible
% Make sure to have installed the Instrument Control Toolbox for MATLAB
% Also, install the NI VISA interactive control. I belive there are several
% other drivers that should be installed from National instruments to
% interface with both Kiethley 2200-60-2 and Agilent 33250 A.
% Use the NI VISA interactive control to know the names/IDs of the two
% tools. Install the VISA drivers They will both communicate via USB with
% SCPI commands. These are for instance *TRG to trigger a pulse, *RST to
% reset the machine, *CLS to clear it, but also OUTPUT ON.

% Once you see the tool in NI visa interactive control, copu their names
% and paste them in the commant visa('NI', 'instrument name here');
% This will create an object that allows MATLAB to point to in order to
% communicate with each tool individually.
% Following, you have the output bufer size set up (legacy from code found
% online as well as fopen to initiate the communication with the
% instrument.
% *IDN is used to indentify the instrument, *RST will reset it, *CLS will
% clear it.


% If the connection to either of the machines is lost (the agilent seems to
% encounter this quite often, turn it off, unplug the usb cable, turn off
% matlab, and the turn it back on, and plug in the 
% cable. Check again in the NI ViSA interactive control if the tool shows
% up normally or with a question mark. If it's a question mark, repeat the
% previous steps.
% For more SCIP commands see https://www.mathworks.com/products/instrument/supported/scpi.html?ef_id=Cj0KCQjwzqSWBhDPARIsAK38LY8yT8ia7ee5HhyXIN4f9ap31xhzO4gj-JonoiqtD93_jsbVlPEk-2kaAndJEALw_wcB:G:s&s_kwcid=AL!8664!3!596332106589!!!g!!&s_eid=psn_135960804626&q=&gclid=Cj0KCQjwzqSWBhDPARIsAK38LY8yT8ia7ee5HhyXIN4f9ap31xhzO4gj-JonoiqtD93_jsbVlPEk-2kaAndJEALw_wcB
% or you can go to the manuals for Kiethley or Agilent and see more
% examples there.

% Add Image Processing Toolbox
% Add Image Acquisition Toolbox
%% Setup variables
ns = 1E-9; us= 1E-6; ms = 1E-3; s =1E0; % Set up units
tam = 15*us; tcr = 0.6*s;    tprt= 500*ms; tdel = 1*s; % Set up amorphization and crystallization times.
Vam = 34;    Vcr = 18;     n_cycles = 40000; % Set up voltages and # of cycles you want. A while loop could also work.
start_cyc = 9019; %64416; % account for extra cycles already run on the sample
VoltPrime = [8,10,12,14]; % Voltages to prime the sample to make subcritical nuclei
% Directory to save imaged and data
ChipName = '1P_CF_THK_1'; DeviceName = '312.2';
% Setup your own folder path for where to store images and data.
imageDir = strcat('.\',ChipName,'\',DeviceName,'\');
mkdir(imageDir);

%% Connect to devices
% Check in NI Visa Interactive control which ports each instrument is
% diplaying
fagi = visa('NI', 'ASRL8::INSTR');
set (fagi,'OutputBufferSize',100000);
fopen(fagi);
fkie = visa('NI', 'USB0::0x05E6::0x2200::9201990::INSTR');
set (fkie,'OutputBufferSize',100000);
fopen(fkie);
%%
%Query Identity string and report
fprintf (fagi, '*IDN?');
idn = fscanf (fagi); fprintf (idn); fprintf ('\n\n')
fprintf (fkie, '*IDN?');
idn = fscanf (fkie); fprintf (idn); fprintf ('\n\n')
%Clear and reset instrument
fprintf (fagi, '*RST'); fprintf (fagi, '*CLS');
fprintf (fkie, '*RST'); fprintf (fkie, '*CLS');
%%
fprintf (fagi, '*RST'); fprintf (fagi, '*CLS');
disp('Initializing Agilent');
InitializeAgilent(fagi);
fprintf (fagi, '*RST'); fprintf (fagi, '*CLS');
pause(1);
fprintf (fagi, '*IDN?');
idn = fscanf (fagi);
fprintf (idn)
fprintf ('\n\n')
InitializeAgilent(fagi);
fprintf (fagi, '*IDN?');
pause(1);
disp('Finished Initialization of Function Generator and Power Supply');
%% First initialization, may be deleted
fprintf(fagi,['pulse:period ',' ',num2str(tcr*2)]); %enable output
fprintf(fagi,['pulse:width ',' ',num2str(tcr)]); %enable output

fprintf(fagi,'OUTPUT ON'); %enable output
% fprintf(fagi,'OUTPUT:TRIGGER {ON}'); %enable output
pause(tcr*2); % put a pause to allow stabilization
%%
% setting up again triger source bus, may delete. You need to triger and
% put wait (i.e. *WAI) so that no new command is done by agilent till the
% pulse is finished (i.e. let the pulse change the PCM before sending more
% turning on again the transistor.
fprintf(fagi,'TRIG:SOUR BUS;*TRG;*WAI');
fprintf(fagi,'*TRG'); %enable output
%%
% Example code to control the Kiehtley.
% Set up the voltage to 1 V and the current to 0.8 A.
% The power supply is not ON yet so you need to set that up.
% I added some pauses to let the tools reach the desired settings (i.e. voltages)
% before sending more commands. Check your own voltage supply for its
% needed rise time.
fprintf(fkie,'VOLT 1'); % set min waveform amplitude
fprintf(fkie,'CURR 0.8'); % set min waveform amplitude
% Leave the current limit at 0.8 or maybe increase it if needed.
pause(2)
%% Turn on the sources
% Turn the sources on. Now you're getting voltage from them.
fprintf(fagi,'OUTPUT ON'); %enable output
fprintf(fkie,'OUTPUT ON'); %enable output
% Get the resistance of your device and verify you are actually connected.
[StrtCurr,StrtVolt,StrtResi]=SendPulse(fagi,fkie,1, 2,1,tdel);
MeasResi = StrtResi;
%% Figure for displaying image and storing image files
image = GetScreenshot;
fh = figure('Name','Camera collected image','NumberTitle','off','Visible','off');
ih = imshow(image,'InitialMagnification',67);
th = title(['Start',datestr(date),' R_{start} = ', num2str(round(StrtResi,3,'significant')),' \Omega']);
% sendImageToStorage(fh, image,ChipName, DeviceName,-1+start_cyc,' Cyc Start  ',imageDir)

%% Voltage level Iteration Loop
percr = 1.1*tcr; perprt = 2*tprt; % Set up periods for the function generator 
peram  = 2*tam;
for i=start_cyc+1:1:n_cycles+start_cyc
    % Amorphize the material.
    ticAm = tic; % Time object to 
    SendPulse(fagi,fkie,Vam, peram,tam,tam); pause(tdel);
    pause(6); %Delay to allow device to come back to equilibrium; May need more

    state = 'amr';
    % Get picture in amorphous state
    image = GetScreenshot; % Collect image from the right-most screen where the AF205
    % is in fullscreen via its software AmScope. For Thorlabs, see the
    % dedicated script. 
    set(ih,'CData',image); drawnow;
    d_tAm = toc(ticAm);
    if(ishghandle(fh))
        set(th,'String',['Cyc. ', num2str(i, '%0.f'),' Amorph. Volt ',num2str(Vam),...
            ' t_{wdt} ', num2str(tam),' s',...
            ' P_{e, Am} ', num2str(round(2*Vam^2/MeasResi*tam/d_tAm,3,'significant')),...
            ' W t_{stg} ',num2str(round(d_tAm,3,'significant')), ' s']);
    end
   
    imam = double(image);
    sendImageToStorage(fh, image,ChipName, DeviceName,i,state,imageDir)
    % Mean image value amorphous
    result = MeanIm(imam)';
    RGBAm = result(1,:); RGBStdAm = result(2,:); RGBKurtAm = result(3,:);
     
    % Pre-treatement to crystallize
    ticCr = tic;
        PrimeNuclei(fagi,fkie,VoltPrime, perprt,tprt,tdel); pause(tdel);
        state = 'prt';
        pause(4);

    % Crystallize
    SendPulse(fagi,fkie,Vcr, percr,tcr,tdel); pause(tdel); 
    pause(8); %Delay to allow state to come back to equilibrium; May need more
    [MeasCurr,MeasVolt,MeasResi]=SendPulse(fagi,fkie,1, 3,2,tdel); pause(tdel);
    MeasCurr = Vcr/MeasResi; MeasVolt = Vcr;
       
    state = 'crs';
    % Get picture in crystalline state
    getImage = true; 
    image = GetScreenshot; % Collect image from the right-most screen where the AF205
    % is in fullscreen via its software AmScope. For Thorlabs, see the
    % dedicated script. 
    set(ih,'CData',image);
    drawnow
    d_tCr = toc(ticCr);
    % Estimate power during crystallization process
    P_cr = (MeasCurr*MeasVolt*tcr + sum(VoltPrime.^2)/MeasResi )/d_tCr; 
    if(ishghandle(fh))
        set(th,'String',['Cyc. ', num2str(i, '%0.f'),' Crystal. Volt ',...
            num2str(Vcr),' t_{wdt} ', num2str(tcr),' s',' '...
            ,num2str(round(MeasVolt,3,'significant')),' V ',num2str(round(MeasCurr,3,'significant')),' A '...
            ,num2str(round(MeasResi,3,'significant')),' \Omega',...
            ' P_{e,Cr} ', num2str(round(P_cr,3,'significant')), ...
            ' W t_{stg}  ',num2str(round(d_tCr,3,'significant')),' s']);
    end

    imcr = double(image);
    sendImageToStorage(ih,image,ChipName, DeviceName,i,state,imageDir);
    % Mean image value crystalline
    result = MeanIm(imcr)';
    RGBCr = result(1,:); RGBStdCr = result(2,:); RGBKurtCr = result(3,:);
    % Clear instruments. I suspect the buffer fills up and you won't be
    % able to send any more commands after a point.
    fprintf (fagi, '*CLS');
    fprintf (fkie, '*CLS');
    
    % Differential contrast mask analysis
    diim = (abs((imcr)-(imam))); % Absolute difference between crs. and amr.
    % Threshold values - selected heuretically. Potential statistical
    % methods are needed for more reliable sample to sample threshold
    % selection
    R_Thr = 10; G_Thr = 10; B_Thr = 10;
    [ViabPix, FOMAm,...
        FOMCr,FOMDiff] = DMAImFilter(imam, imcr,R_Thr,G_Thr,B_Thr);
    % Storing computed statistics in a text log file. 
    fileLog = (['sam',num2str(ChipName),'_dev',num2str(DeviceName)]);
    fileLog= strcat(imageDir,fileLog);
    fid = fopen(fullfile(strcat(fileLog,'.txt')),'a');
    currLog = ['cyc ',num2str(i) ' Vam ',num2str(Vam),' tam ', num2str(tam*1e6), ' us ','VoltPrime ',num2str(VoltPrime),...
        ' tprt ',num2str(tprt),' s ',' Vcr ',num2str(Vcr),' tcr ',num2str(tcr),' s ', 'R ',num2str(MeasResi),' MRGB Am ',num2str(RGBAm),...
        ' MRGB Cr ',num2str(RGBCr), ' Std Am ',num2str(RGBStdAm), ' Std Cr ',...
        num2str(RGBStdCr),' Kurt Am ',num2str(RGBKurtAm), ' Kurt Cr ',num2str(RGBKurtCr),...
        ' ViabPxl ' num2str(ViabPix),' DMAAm ', num2str(FOMAm), ' DMACr ', num2str(FOMCr) ,...
         ' DMADelta ', num2str(FOMDiff),'\n' ];
    fprintf(fid,currLog);
    fclose(fid);

    % Initial resistance measurement to know if we have cooled down enough.
    % Select the appropriate resistance based on your device. Potentially
    % use the initially measured resistance instead of the hard coded one. 
    if MeasResi>54
        pause(10); % Time in seconds
    end
     [MeasCurr,MeasVolt,MeasResi]=SendPulse(fagi,fkie,1, 3,2,tdel); pause(tdel);
    % Select the resistance below which you need the sample to be such that
    % you don't overheat it.
     while MeasResi >51.2
        pause(10);
        [MeasCurr,MeasVolt,MeasResi]=SendPulse(fagi,fkie,1, 1.2,1,tdel); pause(tdel);
     end
     % Code for overamorphizing the sample to promote elemental mixing -
     % work in progress
%      if mod(i,200)==0
%           SendPulse(fagi,fkie,Vam, peram*2,tam*2,tam*2); pause(tdel);
%           [MeasCurr,MeasVolt,MeasResi]=SendPulse(fagi,fkie,1, 3,2,tdel); pause(tdel);
%           while MeasResi >47
%               pause(5);
%               [MeasCurr,MeasVolt,MeasResi]=SendPulse(fagi,fkie,1, 1.2,1,tdel); pause(tdel);
%           end
%      end
end
disp('Done'); beep;
%%
% Collect the image at the end of testing
sendImageToStorage(ih,image,ChipName, DeviceName,i,state,imageDir);
%% Turn off the outputs
fprintf(fagi,'OUTPUT OFF'); disp('Agilent output off');%
fprintf(fkie,'OUTPUT OFF'); disp('Keithley output off');%

%%
fclose(fagi);
fclose(fkie);
close all; clear all;
