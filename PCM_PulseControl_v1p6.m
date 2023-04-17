%%
clear all; close all; clc;
addpath('C:\Users\popes\Dropbox (MIT)\uHeater\NK EMA IMG\ImAnalysisScripts')
% You need the "clear all" as the connections via visa to the machines
% seems to encounter problems with previously stored values (cache memory
% probably).
%% Drivers to install - may require more than 5 GB of memory
% For Agilent 33250A
% https://www.keysight.com/us/en/lib/software-detail/driver/33250a-function--arbitrary-waveform-generator-ivi-and-matlab-instrument-drivers-1639531.html
% Select the appropriate one for the computer.
% https://www.ivifoundation.org/shared_components/Default.aspx
% Needing visa com
% Installing IviNetSharedComponents_200.exe - Failed
% Installing IviSharedComponents64_261.exe - Succesful
% Attempting Agilent MATLAB installation - Failed
% Installing keysightiolibrariesandvisainterface.mlpkginstall - Succesful
% Driver https://www.tek.com/en/support/software/driver/tekvisa-connectivity-software-v404
% Install for Kiethley for MATLAB
% Open choice instrument manager got automatically installed via this sequence
% Attempting to bypass need for NI VISA instrument control
% Resource information is present (identical for Kiethley but ASRL3 instead of 4 for Agilent)
% Visa fails to find Agilent
% fagi = visa('keysight', 'ASRL3::INSTR'); finds the agilent. Agilent can be controlled.
% Sending *RST via OpenChoice Talk Listener - Kiethley reset, MATLAB needs driver or some restart
% Installing ni-visa_21.5_online.exe from https://www.ni.com/en-us/support/downloads/drivers/download/packaged.ni-visa.442805.html
% Did NOT turn off "Fast startup in Windows". Potentially to create issues.
% Installing default extras
% ASRL4 is used after the drivers are istalled.

% Reocurring issue - short pulses seem to be processed in the second regime (i.e. 205 s period but with correct width).
%

%% Documentation on using the pulsed PCM script
% Cosmin Popescu, 2022 07 09. Made in MATLAB R2020b.V 1.0
% MATLAB R2021a works too V1.1
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
% matlab, and the turn it back on, the agilent back on and plug in the
% cable. Check again in the NI ViSA interactive control if the tool shows
% up normally or with a question mark. If it's a question mark, repeat the
% previous steps. I believe there is some timing issue but I am unsure how
% to fix it now more reliably.

% For more SCIP commands see https://www.mathworks.com/products/instrument/supported/scpi.html?ef_id=Cj0KCQjwzqSWBhDPARIsAK38LY8yT8ia7ee5HhyXIN4f9ap31xhzO4gj-JonoiqtD93_jsbVlPEk-2kaAndJEALw_wcB:G:s&s_kwcid=AL!8664!3!596332106589!!!g!!&s_eid=psn_135960804626&q=&gclid=Cj0KCQjwzqSWBhDPARIsAK38LY8yT8ia7ee5HhyXIN4f9ap31xhzO4gj-JonoiqtD93_jsbVlPEk-2kaAndJEALw_wcB
% or you can go to the manuals for Kiethley or Agilent and see more
% examples there.

% Add Image Processing Toolbox
% Add Image Acquisition Toolbox
% Add Upload files to your DropBox folder from MATLAB
% Generate token in DropBox via the instructions in the previous MATLAB set
%% Setup variables
ns = 1E-9; us= 1E-6; ms = 1E-3; s =1E0; % Set up units
tam = 10*us; tcr = 0.3*s;    tprt= 500*ms; tdel = 0.4*s; % Set up amorphization and crystallization times.
Vam = 35;    Vcr = 18;     n_cycles = 40000; % Set up voltages and # of cycles you want.
start_cyc = 0; %64416; % account for extra cycles already run on the sample
VoltPrime = [8,10,12];
% Directory to save imaged and data
ChipName = '1P_1220_F_1'; DeviceName = '315.2';
imageDir = strcat('E:\CF GSST\',ChipName,'\',DeviceName,'\');
mkdir(imageDir);

%% Dropbox file saving
% Keep token secret

%% Connect to devices
fagi = visa('NI', 'ASRL8::INSTR');
set (fagi,'OutputBufferSize',100000);
fopen(fagi);
fkie = visa('NI', 'USB0::0x05E6::0x2200::9201990::INSTR');
set (fkie,'OutputBufferSize',100000);
fopen(fkie);
%%
%Query Identity string and report
fprintf (fagi, '*IDN?');
idn = fscanf (fagi);
fprintf (idn)
fprintf ('\n\n')
fprintf (fkie, '*IDN?');
idn = fscanf (fkie);
fprintf (idn)
fprintf ('\n\n')
%Clear and reset instrument
fprintf (fagi, '*RST'); fprintf (fagi, '*CLS');
fprintf (fkie, '*RST'); fprintf (fkie, '*CLS');
%%
fprintf (fagi, '*RST'); fprintf (fagi, '*CLS');
disp('Initialize Agilent');
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
% The power supply is not ON yet so you ened to set that up.
% I added some pauses to let the tools reach the desired settings before
% sending more commands. Those delays may be shortened in the future.
fprintf(fkie,'VOLT 1'); % set min waveform amplitude
fprintf(fkie,'CURR 0.8'); % set min waveform amplitude
% Leave the current limit at 0.8 or maybe increase it if needed.
pause(2)
%% Turn on the sources
% Turn the sources on. Now you're getting voltage from them.
fprintf(fagi,'OUTPUT ON'); %enable output
fprintf(fkie,'OUTPUT ON'); %enable output
[StrtCurr,StrtVolt,StrtResi]=SendPulse(fagi,fkie,1, 2,1,tdel);

%% Initialize the Thorlab Camera

fileDiruc480 = 'C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\';
addpath(fileDiruc480)
%Add NET assembly
% May need to change specific location of library
NET.addAssembly('C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\uc480DotNet.dll')
% Create camera object handle
cam = uc480.Camera;
% Open the first available camera
cam.Init(0);
% Set display mote to bitmap (DiB)
cam.Display.Mode.Set(uc480.Defines.DisplayMode.DiB);
%Set color mode to raw 
cam.PixelFormat.Set(uc480.Defines.ColorMode.SensorRaw16);
% Set trigger mode to software (single image acquisition);
cam.Trigger.Set(uc480.Defines.TriggerMode.Software);
% for i =1:20
% Allocate image memory
[~,MemId] = cam.Memory.Allocate(true);
cam.Timing.Exposure.Set(80);
cam.Gain.Hardware.Scaled.SetMaster(0)
cam.Gain.Hardware.Scaled.SetBlue(40)
cam.Gain.Hardware.Scaled.SetRed(0);
cam.Gain.Hardware.Scaled.SetGreen(0);
cam.Gain.Hardware.Scaled.SetBlue(40);
% Obtain image information
[~, Width,Height, Bits, ~] = cam.Memory.Inquire(MemId);
disp('Finished Initialization of Thorlabs Camera');
%% Get image

cam.Acquisition.Capture(uc480.Defines.DeviceParameter.Wait);
% Copy image from memory
[~, tmp] = cam.Memory.CopyToArray(MemId);

% Reshape image
Data = reshape(uint8(tmp),[Bits/8, Width, Height]);
Data = Data(1:3 , 1:Width , 1:Height);
image = permute(Data,[3,2,1]); image = flip(image,3);
while sum(image(1,1,1)+image(1,1,2)+image(1,1,3)<1)
    cam.Acquisition.Capture(uc480.Defines.DeviceParameter.Wait);
    % Copy image from memory
    [~, tmp] = cam.Memory.CopyToArray(MemId);
    % Reshape image
    Data = reshape(uint8(tmp),[Bits/8, Width, Height]);
    Data = Data(1:3 , 1:Width , 1:Height);
    image = permute(Data,[3,2,1]);
    image = flip(image,3);
end
% image = imadjust(image,stretchlim(image),[0 1]);

fh = figure('Name','ThorCam Image','NumberTitle','off');
ih = imshow(image,'InitialMagnification',67);
th = title(['Start',datestr(date),' R_{start} = ', num2str(round(StrtResi,3,'significant')),' \Omega']);
MeasResi = StrtResi;
pause(0.001);
disp('Got initial image');
%%
% sendImageDropBox(fh, image,[],ChipName, DeviceName,-1+start_cyc,' Cyc Start  ',imageDir)

%% Capture an image
acTime = 80;
cam.Timing.Exposure.Set(acTime);
for z = 1:400
cam.Acquisition.Capture(uc480.Defines.DeviceParameter.Wait);
    % Copy image from memory
    [~, tmp] = cam.Memory.CopyToArray(MemId);
    % Reshape image
    Data = reshape(uint8(tmp),[Bits/8, Width, Height]);
    Data = Data(1:3 , 1:Width , 1:Height);
    image = permute(Data,[3,2,1]);
    image= flip(image,3);
    set(ih,'CData',image);
    drawnow
%     disp(z)
end

%% Voltage level Iteration Loop
percr = 1.1*tcr; perprt = 2*tprt;
peram  = 2*tam;
for i=start_cyc+1:1:n_cycles+start_cyc
    % Amorphize the material.
    ticAm = tic;
    SendPulse(fagi,fkie,Vam, peram,tam,tam); pause(tdel);
%     SendPulse(fagi,fkie,Vam, peram,tam,tam); pause(tdel);
    pause(6); %Delay to allow state to come back to equilibrium; May need more


    state = 'amr'; getImage = true;
    acTime = 80;
    cam.Timing.Exposure.Set(acTime);
    % Get picture in amorphous state
%     image =uint16(zeros([Height, Width, Bits/8]));
%     while(getImage)
        cam.Acquisition.Capture(uc480.Defines.DeviceParameter.Wait);
        % Copy image from memory
        [~, tmp] = cam.Memory.CopyToArray(MemId);

        % Reshape image
        Data = reshape(uint16(tmp),[Bits/8, Width, Height]);
        Data = Data(1:3 , 1:Width , 1:Height);
        Data = permute(Data,[3,2,1]);
        Data = flip(Data,3);
        image = Data;
    set(ih,'CData',image*256);
    drawnow
    d_tAm = toc(ticAm);
    if(ishghandle(fh))
        set(th,'String',['Cyc. ', num2str(i, '%0.f'),' Amorph. Volt ',num2str(Vam),...
            ' t_{wdt} ', num2str(tam),' s',...
            ' P_{e, Am} ', num2str(round(2*Vam^2/MeasResi*tam/d_tAm,3,'significant')),...
            ' W t_{stg} ',num2str(round(d_tAm,3,'significant')), ' s']);
    end
%      if (i<30|| (0<mod(i,25) && mod(i,25)<=2) )
    imam = double(image);
    sendImageDropBox(fh, image,[],ChipName, DeviceName,i,state,imageDir)
    % Mean image value amorphous
    result = MeanIm(imam)';
    RGBAm = result(1,:); RGBStdAm = result(2,:); RGBKurtAm = result(3,:);
%      end
    % Pre-treatement to crystallize
    ticCr = tic;
        PrimeNuclei(fagi,fkie,VoltPrime, perprt,tprt,tdel); pause(tdel);
        state = 'prt';
        pause(4);

    % Crystallize
    SendPulse(fagi,fkie,Vcr, percr,tcr,tdel); pause(tdel);
%     SendPulse(fagi,fkie,Vcr, percr,tcr,tdel); pause(tdel);
 pause(8); %Delay to allow state to come back to equilibrium; May need more
    [MeasCurr,MeasVolt,MeasResi]=SendPulse(fagi,fkie,1, 3,2,tdel); pause(tdel);
    MeasCurr = Vcr/MeasResi; MeasVolt = Vcr;
       
    state = 'crs';
    % Get picture in crystalline state
    %
%     image =uint16(zeros([Height, Width, Bits/8]));
    getImage = true; attempts = 0;
%     cam.Timing.Exposure.Set(acTime);
        cam.Acquisition.Capture(uc480.Defines.DeviceParameter.Wait);
        % Copy image from memory
        [~, tmp] = cam.Memory.CopyToArray(MemId);

        % Reshape image
        Data = reshape(uint16(tmp),[Bits/8, Width, Height]);
        Data = Data(1:3 , 1:Width , 1:Height);
        Data = permute(Data,[3,2,1]);
        Data = flip(Data,3);
        image = Data;
    set(ih,'CData',image*256);
    drawnow
    d_tCr = toc(ticCr);
    % Estimate power during 
    P_cr = (MeasCurr*MeasVolt*tcr + sum(VoltPrime.^2)/MeasResi )/d_tCr; 
    if(ishghandle(fh))
        set(th,'String',['Cyc. ', num2str(i, '%0.f'),' Crystal. Volt ',...
            num2str(Vcr),' t_{wdt} ', num2str(tcr),' s',' '...
            ,num2str(round(MeasVolt,3,'significant')),' V ',num2str(round(MeasCurr,3,'significant')),' A '...
            ,num2str(round(MeasResi,3,'significant')),' \Omega',...
            ' P_{e,Cr} ', num2str(round(P_cr,3,'significant')), ...
            ' W t_{stg}  ',num2str(round(d_tCr,3,'significant')),' s']);
    end
%     if (i<30|| (0<mod(i,25) && mod(i,25)<=2))
    imcr = double(image);
    sendImageDropBox(ih,image,[],ChipName, DeviceName,i,state,imageDir);
    % Mean image value crystalline
    result = MeanIm(imcr)';
    RGBCr = result(1,:); RGBStdCr = result(2,:); RGBKurtCr = result(3,:);
% end
    fprintf (fagi, '*CLS');
    fprintf (fkie, '*CLS');
    
    % Differential contrast mask analysis
    diim = (abs((imcr)-(imam)));
    R_Thr = 3; G_Thr = 4; B_Thr = 5;
    [ViabPix, FOMAm,...
        FOMCr,FOMDiff] = DMAImFilter(imam, imcr,R_Thr,G_Thr,B_Thr);
    fileLog = (['sam',num2str(ChipName),'_dev',num2str(DeviceName)]);
    fileLog= strcat(imageDir,fileLog);
    fid = fopen(fullfile(strcat(fileLog,'.txt')),'a');
    currLog = ['cyc ',num2str(i) ' Vam ',num2str(Vam),' tam ', num2str(tam*1e6), ' us ','VoltPrime ',num2str(VoltPrime),...
        ' tprt ',num2str(tprt),' s ',' Vcr ',num2str(Vcr),' tcr ',num2str(tcr),' s ', 'R ',num2str(MeasResi),' MRGB Am ',num2str(RGBAm),...
        ' MRGB Cr ',num2str(RGBCr), ' Std Am ',num2str(RGBStdAm), ' Std Cr ',...
        num2str(RGBStdCr),' Kurt Am ',num2str(RGBKurtAm), ' Kurt Cr ',num2str(RGBKurtCr),...
        ' ViabPxl ' num2str(ViabPix),' DMAAm ', num2str(FOMAm), ' DMACr ', num2str(FOMCr) ,...
         ' DMADelta ', num2str(FOMDiff) ,' Exp Time ',num2str(acTime),'\n' ];
    fprintf(fid,currLog);
    fclose(fid);


    if MeasResi>54
        pause(10);
    end
     [MeasCurr,MeasVolt,MeasResi]=SendPulse(fagi,fkie,1, 3,2,tdel); pause(tdel);
     while MeasResi >47
        pause(5);
        [MeasCurr,MeasVolt,MeasResi]=SendPulse(fagi,fkie,1, 1.2,1,tdel); pause(tdel);
     end
end
disp('Done'); beep;
%%
sendImageDropBox(ih,image,[],ChipName, DeviceName,i,state,imageDir);
%% Turn off the outputs
fprintf(fagi,'OUTPUT OFF'); disp('Agilent output off');%
fprintf(fkie,'OUTPUT OFF'); disp('Keithley output off');%

%%
fclose(fagi);
fclose(fkie);
cam.Exit;
close all; clear all;
