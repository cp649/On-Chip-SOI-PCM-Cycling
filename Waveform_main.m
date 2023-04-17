% error('Dont reinitiate')

clear; clc; close all;

fagi = visa('NI', 'ASRL7::INSTR');
set (fagi,'OutputBufferSize',100000);
fopen(fagi);
fkie = visa('NI', 'USB0::0x05E6::0x2200::9201990::INSTR');
set (fkie,'OutputBufferSize',100000);
fopen(fkie);
%%
% fosc = visa('NI','USB0::0x0699::0x0373::C011714::INSTR');
% set (fosc,'OutputBufferSize',800000);
% fopen(fosc);
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
% fprintf (fosc, '*IDN?');
% idn = fscanf (fosc);
% fprintf (idn)
% fprintf ('\n\n')
%Clear and reset instrument
fprintf (fagi, '*RST'); fprintf (fagi, '*CLS');
fprintf (fkie, '*RST'); fprintf (fkie, '*CLS');
% fprintf (fosc, '*RST'); fprintf (fosc, '*CLS');
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

fprintf(fagi,'OUTPUT ON'); %enable output
% fprintf(fagi,'OUTPUT:TRIGGER {ON}'); %enable output
pause(2); % put a pause to allow stabilization
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
[StrtCurr,StrtVolt,StrtResi]=SendPulse(fagi,fkie,1, 2,1,0.4)

%% Attempt waveform collection - code from the Tektronix manual
%/* Set up conditional acquisition */
% fprintf(fosc,'ACQUIRE:STATE OFF');
% fprintf(fosc,'SELECT:CH1 ON');
% fprintf(fosc,'ACQUIRE:MODE SAMPLE');
% fprintf(fosc,'ACQUIRE:STOPAFTER SEQUENCE');
% fprintf(fosc,'TRIGGER:A:LOWERTHRESHOLD:CH1 2');
% fprintf(fosc,'DAT:ENC ASC'); pause(0.01); fprintf(fosc,'DAT:ENC?'); fscanf(fosc)
% fprintf(fosc,'WFMOUTPRE:ENCDG ASC'); pause(0.01); fprintf(fosc,'WFMOUTPRE:ENCDG?'); fscanf(fosc)
% fprintf(fosc,'*CLS');
% fprintf(fosc,'SAV:WAVE<REF1>');

%%
%/* Acquire waveform data */
% fprintf(fosc,'ACQUIRE:STATE ON'); pause(0.01);
% SendPulse(fagi,fkie,3, 30E-6,3E-6,0.4)
% 
% %/* Set up the measurement parameters */
% fprintf(fosc,'MEASUREMENT:IMMED:TYPE AMPLITUDE');
% fprintf(fosc,'MEASUREMENT:IMMED:SOURCE CH1');
% % /* Take amplitude measurement */
% fprintf(fosc,'MEASUREMENT:IMMED:VALUE?');
% fprintf(fosc,'RECA:WAVE<REF1>');
% 
% fprintf(fosc,'MEASU?');fscanf(fosc)
% % 2-53 
% fprintf(fosc,'DAT:SOU:REF<1>');
% fprintf(fosc,'DAT:ENC:ASC'); pause(0.01); fprintf(fosc,'DAT:ENC?'); fscanf(fosc)
% fprintf(fosc,'DATA:RESOLUTION?'); fscanf(fosc)
% fprintf(fosc,'*ESR?'); fscanf(fosc)
% fprintf(fosc,'DATA:COMPOSITION:AVAILABLE?'); fscanf(fosc)
% fprintf(fosc,'DATA:DEST?'); fscanf(fosc)
% fprintf(fosc,'DATA:STAR?'); fscanf(fosc)
% fprintf(fosc,'DATA:STOP?'); fscanf(fosc)
% fprintf(fosc,'WFMOutpre?');  waveFormPreamble = fscanf(fosc);
% fprintf(fosc,'*OPC'); fprintf(fosc,'CURVE?');  [A,count,msg]  =fread(fosc);
% fprintf(fosc,'WFMOUTPRE:XUNIT?'); unitX = fscanf(fosc)
% fprintf(fosc,'WFMOUTPRE:YUNIT?'); unitY = fscanf(fosc)


%% Code from MATLAB
myScope = oscilloscope();
availableResources = getResources(myScope);
myScope.Resource = 'USB0::0x0699::0x0373::C011714::0::INSTR';
connect(myScope);
get(myScope);
%%
% Automatically configuring the instrument based on the input signal.
figure;hold on;
pulseValues = [0.5  1 2];
highVload =[];
lowVload =[];
gateV =[];
 for index = 1:numel(pulseValues)
%index=1;
%SendPulse(fagi,fkie,35, 30E-6,pulseWidth*1E-6,0.4);
    pulseWidth = pulseValues(index);
myScope.autoSetup;
SendPulse(fagi,fkie,35, 30E-6,pulseWidth*1E-6,0.4);

myScope.AcquisitionTime = 4E-8;

myScope.WaveformLength = 1.00000e+05;

myScope.TriggerMode = 'normal';
myScope.TriggerSlope = 'falling';
myScope.TriggerLevel = 6;
myScope.TriggerSource = 'CH2';
enableChannel(myScope, 'CH1');
enableChannel(myScope, 'CH2');
enableChannel(myScope, 'CH3');

setVerticalCoupling (myScope, 'CH1', 'DC');
setVerticalCoupling (myScope, 'CH2', 'DC');
setVerticalCoupling (myScope, 'CH3', 'DC');
% setVerticalRange (myScope, 'CH1', 10);
% setVerticalRange (myScope, 'CH1', 10);
% setVerticalRange (myScope, 'CH1', 20);


configureChannel(myScope,'CH1','VerticalRange',5)
configureChannel(myScope,'CH2','VerticalRange',10)
configureChannel(myScope,'CH3','VerticalRange',1)
offset = configureChannel(myScope,'CH1','VerticalOffset');
configureChannel(myScope,'CH1','VerticalOffset',43)
configureChannel(myScope,'CH2','VerticalOffset',26)
configureChannel(myScope,'CH3','VerticalOffset',0)
% w = getWaveform(myScope);
myScope.SingleSweepMode = 'on'; pause(0.5);
SendPulse(fagi,fkie,35, 30E-6,pulseWidth*1E-6,0.4);
[beforeLoad,afterLoad,mosfet ]= getWaveform(myScope, 'acquisition', false);
plot(linspace(0,myScope.AcquisitionTime,numel(beforeLoad))*25E8-50,beforeLoad,'-r'); hold on;
plot(linspace(0,myScope.AcquisitionTime,numel(beforeLoad))*25E8-50,afterLoad); hold on;
plot(linspace(0,myScope.AcquisitionTime,numel(beforeLoad))*25E8-50,mosfet,'-k'); hold on;
xlabel('Time (\mus)'); xlim([-0.5 1+pulseWidth])
ylabel('Voltage (V)');disp('Collected Waveform');
highVload = [highVload,beforeLoad'];
lowVload = [lowVload,afterLoad'];
gateV = [gateV,mosfet'];
 end
 time = linspace(0,myScope.AcquisitionTime,numel(beforeLoad))*25E8-50;
%%
FontSize = 15;
% time = linspace(0,myScope.AcquisitionTime,numel(waveformArray))*1E7-50;
figure; hold on;
plot(time,highVload(:,1),'-k','LineWidth',2)
plot(time,highVload(:,2),'--r','LineWidth',1.5)
plot(time,highVload(:,3),'-.b','LineWidth',1)
ylabel('Voltage before load (V)');
% yyaxis right;
% plot(time,gateForms(:,1),'-k','LineWidth',2)
% plot(time,gateForms(:,2),'--r','LineWidth',1.5)
% plot(time,gateForms(:,3),'-.b','LineWidth',1)
xlabel('Time (\mus)'); xlim([-0.5 3]); box on;
% ylabel('Gate Voltage (V)');
legend('500 ns','1 \mus','2 \mus','Location','best','box','off')
% legend('200 ns','300 ns','500 ns','Location','best','box','off')
set(gca,'FontWeight','bold','FontName','Helvetica','FontSize',FontSize)
set(gca,'XColor','k','YColor','k')

figure; hold on;
plot(time,gateV(:,1),'-k','LineWidth',2)
plot(time,gateV(:,2),'--r','LineWidth',1.5)
plot(time,gateV(:,3),'-.b','LineWidth',1)
xlabel('Time (\mus)'); xlim([-0.5 3]); box on;
ylabel('Gate Voltage (V)');
legend('500 ns','1 \mus','2 \mus','Location','best','box','off')
% legend('200 ns','300 ns','500 ns','Location','best','box','off')
set(gca,'FontWeight','bold','FontName','Helvetica','FontSize',FontSize)
set(gca,'XColor','k','YColor','k')


figure; hold on;
plot(time,lowVload(:,1),'-k','LineWidth',2)
plot(time,lowVload(:,2),'--r','LineWidth',1.5)
plot(time,lowVload(:,3),'-.b','LineWidth',1)
xlabel('Time (\mus)'); xlim([-0.5 3]); box on;
ylabel('Voltage after load (V)');
legend('500 ns','1 \mus','2 \mus','Location','best','box','off')
% legend('200 ns','300 ns','500 ns','Location','best','box','off')
set(gca,'FontWeight','bold','FontName','Helvetica','FontSize',FontSize)
set(gca,'XColor','k','YColor','k')


figure; hold on;
plot(time,highVload(:,1)-lowVload(:,1),'-k','LineWidth',2)
plot(time,highVload(:,2)-lowVload(:,2),'--r','LineWidth',1.5)
plot(time,highVload(:,3)-lowVload(:,3),'-.b','LineWidth',1)
xlabel('Time (\mus)'); xlim([-0.5 3]); box on;
ylabel('Voltage drop across load (V)');
legend('500 ns','1 \mus','2 \mus','Location','best','box','off')
% legend('200 ns','300 ns','500 ns','Location','best','box','off')
set(gca,'FontWeight','bold','FontName','Helvetica','FontSize',FontSize)
set(gca,'XColor','k','YColor','k')
%%
error('Do not advance')
beforeLoad = getWaveform(myScope, 'acquisition', true);
SendPulse(fagi,fkie,3, 30E-6,3E-6,0.4);

% Plot the waveform.
plot(beforeLoad);
xlabel('Samples');
ylabel('Voltage');



%% Closing the instruments
fprintf(fagi,'OUTPUT OFF'); disp('Agilent output off');%
fprintf(fkie,'OUTPUT OFF'); disp('Keithley output off');%

%%
fclose(fagi);
fclose(fkie);
disconnect(myScope);
close all; clear all;
