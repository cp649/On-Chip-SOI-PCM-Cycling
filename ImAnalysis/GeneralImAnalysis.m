%%
clear; clc; close all;
% filePath = 'E:\CF GSST\1P_CF_THK_1\315.2\';
% filePath = 'E:\CF GSST\1S_CF_REF_1\308.2\';
filePath = 'C:\Users\popes\Dropbox (MIT)\CF GSST\1S_CF_150_1\43.16\';
fileNames = GetSortedMatFileNames(filePath);
LastCycle = GetLastCycle(fileNames);
%% Set up variables to store data in
cycles = zeros(LastCycle,1);
MeanImStat = zeros(3,LastCycle,3,3); % 2 states (am and cr)+difference
% total cycles and 3 color channels, 3 values (mean, std and kurt)
HSVStats = zeros(3,LastCycle,3);
HSVPxlStats = zeros(2,LastCycle);
DMAStats = zeros(3,LastCycle,3);
DMAPxlStats = zeros(LastCycle,4);

cc = 1;
hsv_low = 0.15; hsv_high = 0.4;
R_Thr= 8; G_Thr = 10; B_Thr = 10;
%%
tic
for ii = 1: numel(fileNames)-1
    % Find the cycle number
    cyc = GetCycleNumber(fileNames(ii).name);
    state = GetState(fileNames(ii).name);
    % If the file is for amr, then load and if the next one is for crs,
    % load too. 
    if (cyc>-1) && strcmp(state,'amr') 
        
        cycles(cc)=cyc;
        load(fullfile(fileNames(ii).folder,fileNames(ii).name)); iam = image; %load image
        stateNext = GetState(fileNames(ii+1).name);
        if strcmp(stateNext,'crs')
            load(fullfile(fileNames(ii+1).folder,fileNames(ii+1).name)); icr = image;
            % Get the normal mean, std and kurt values
            MeanImStat(1,cc,:,:) = MeanIm(iam)';
            MeanImStat(2,cc,:,:) = MeanIm(icr)';
            % Get HSV filter processing
            [HSVPxlStats(:,cc),HSVStats(1,cc,:),...
               HSVStats(2,cc,:) ] = HSVFilter(iam,icr,hsv_low,hsv_high);
            % Get DMA filter 
            [DMAPxlStats(cc,:), DMAStats(1,cc,:),...
                DMAStats(2,cc,:),DMAStats(3,cc,:)] = DMAImFilter(iam, icr,R_Thr,G_Thr,B_Thr);
            cc = cc+1;
            
        end

    end
end
toc
MeanImStat(3,:,:,:) =MeanImStat(2,:,:,:)-MeanImStat(1,:,:,:);
HSVStats(3,:,:) =HSVStats(2,:,:) -HSVStats(1,:,:) ; 
%% Making figures

fig = figure;fig.Position = [100,100,1800,600];
nexttile; imshow(iam); nexttile; imshow(icr); nexttile;imshow((icr-iam)*5)
diim = icr-iam;
fig = figure;fig.Position = [100,100,1800,600];
nexttile; imshow(diim(:,:,1)*5); nexttile; imshow(diim(:,:,2)*5); nexttile; imshow(diim(:,:,3)*5); 
%%
x = (1:size(diim,2))/9;y = (1:size(diim,1))/9;
fig = figure;fig.Position = [100,100,1800,600];
cminval =[R_Thr,G_Thr,B_Thr];
for index =1:3
nexttile; surf(x,y,diim(:,:,index),'LineStyle','none'); view([0 0 -1]); xlim([min(x),max(x)])
ylim([min(y),max(y)]);axis image; colorbar; caxis([0 55]);
zlim([cminval(index),55])
xlabel('x (\mum)');ylabel('y (\mum)')
end
%%
x = (1:size(diim,2))/9;y = (1:size(diim,1))/9;
fig = figure;fig.Position = [2200,400,600,600];
maskHSV = HSVImFilter(image, 0.15,0.3);
surf(x,y,double(maskHSV),'LineStyle','none');xlim([min(x),max(x)])
ylim([min(y),max(y)]);axis image;view([0 0 -1]);xlabel('x (\mum)');ylabel('y (\mum)')

%%
[~,dmaMask]= DifferenceFilter(diim,R_Thr,G_Thr,B_Thr);
fig = figure;fig.Position = [2200,400,600,600]; 
surf(x,y,double(dmaMask),'LineStyle','none');xlim([min(x),max(x)])
ylim([min(y),max(y)]);axis image;view([0 0 -1]);xlabel('x (\mum)');ylabel('y (\mum)')

%% Mean value stats
fig = figure;fig.Position = [2200,400,600,600]; hold on;
plot(cycles,MeanImStat(3,:,1,1),'.-r');
plot(cycles,MeanImStat(3,:,2,1),'*-g');
plot(cycles,MeanImStat(3,:,3,1),'^-b');
ylim([0 25]); xlabel('Cycle #'); ylabel('\Delta Mean Values (a.u.)')
set(gca,'xscale','log');
set(gca,'FontSize',15,'FontWeight','bold')
xlim([1 LastCycle]); box on;
xticks([1,10,100,1000,1e4])
%% HSV filter stats
figHSV = figure;figHSV.Position = [2200,400,600,600]; hold on;
plot(cycles,HSVStats(3,:,1),'.-r');
plot(cycles,HSVStats(3,:,2),'*-g');
plot(cycles,HSVStats(3,:,3),'^-b');
ylim([-0.0 0.25]); xlabel('Cycle #'); ylabel('\Delta HSV Values (a.u.)')
set(gca,'xscale','log');box on;
set(gca,'FontSize',15,'FontWeight','bold')
xlim([1 LastCycle])
xticks([1,10,100,1000,1e4])

%% DMA filter stats
figDMA = figure;figDMA.Position = [2200,400,600,600]; hold on;
plot(cycles,DMAStats(3,:,1),'.r');
plot(cycles,DMAStats(3,:,2),'.g');
plot(cycles,DMAStats(3,:,3),'.b');
ylim([-0.0 0.15]); 
xlabel('Cycle #'); ylabel('\Delta DMA Values (a.u.)')
set(gca,'xscale','log'); box on;
set(gca,'FontSize',15,'FontWeight','bold')
xlim([1 LastCycle])
xticks([1,10,100,1000,1e4])

%%
%%
figPxl = figure;figPxl.Position = [2200,400,600,600]; hold on;
plot(cycles,HSVPxlStats(1,:)/numel(diim(:,:,1)),'xm','MarkerSize',3);
plot(cycles,HSVPxlStats(2,:)/numel(diim(:,:,1)),'^','MarkerSize',3,'Color',[0.05,0.2,0.7]);
ylim([0 1]); 
xlabel('Cycle #'); ylabel('HSV PCM fraction (a.u.)')
set(gca,'xscale','log'); box on;
set(gca,'FontSize',15,'FontWeight','bold')
xlim([1 LastCycle])
legend('Amorphous','Crystalline')
xticks([1,10,100,1000,1e4])

%%
figDMAPxl = figure;figDMAPxl.Position = [2200,400,600,600]; hold on;
plot(cycles,DMAPxlStats(:,1)/numel(diim(:,:,1)),'or','MarkerSize',2);
plot(cycles,DMAPxlStats(:,2)/numel(diim(:,:,1)),'vg','MarkerSize',2);
plot(cycles,DMAPxlStats(:,3)/numel(diim(:,:,1)),'+b','MarkerSize',2);
plot(cycles,DMAPxlStats(:,4)/numel(diim(:,:,1)),'h','MarkerSize',3,'Color',[0 0 0]);
ylim([0 1]); 
xlabel('Cycle #'); ylabel('DMA image switching fraction (a.u.)')
set(gca,'xscale','log'); box on;
set(gca,'FontSize',15,'FontWeight','bold')
xlim([1 LastCycle])
legend('R','G','B','Total')
xticks([1,10,100,1000,1e4])
% save(fullfile(filePath,'1P_THK_1_D_315p2Statistics.mat'))