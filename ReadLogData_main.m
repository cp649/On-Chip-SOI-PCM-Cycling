clc; close all;
%%
fileDir = 'E:\CF GSST\1P_CF_THK_1\312.2\';
fileLog = 'sam1P_CF_THK_1_dev312.2.txt';
tic; TextData = readtable(fullfile(fileDir,fileLog));
 data  =table2cell(TextData); data = cell2num(data); toc;
%% Make the figures; str2double takes a long time; Don't redo it.
figure; hold on
plot(data(:,2),data(:,67),'*r','MarkerSize',3)
plot(data(:,2),data(:,68),'^g','MarkerSize',3)
plot(data(:,2),data(:,69),'ob','MarkerSize',3)
[yval]=ylim;
ylim([0  yval(2)]);
xlabel('Cycle #'); ylabel('\Delta DMA')
set(gca,'FontSize',15,'FontWeight','bold','XColor','k','YColor','k'); box on; grid on;

figure; hold on
plot(data(:,2),data(:,56)/1920/1080,'sk','MarkerSize',3)
xlabel('Cycle #'); ylabel('Switching area fraction')
set(gca,'FontSize',15,'FontWeight','bold','XColor','k','YColor','k'); box on; 
grid on

figure; hold on
plot(data(:,2),data(:,22),'hm','MarkerSize',3)
xlabel('Cycle #'); ylabel('Resistance (\Omega)')
set(gca,'FontSize',15,'FontWeight','bold','XColor','k','YColor','k'); box on; 
grid on

figure; hold on
histogram(data(:,22),'FaceColor','m','EdgeColor','k','BinWidth',1)
xlabel('Resistance (\Omega)'); ylabel('Cycles')
set(gca,'FontSize',15,'FontWeight','bold','XColor','k','YColor','k'); box on; 
grid on

figure; hold on
plot(data(:,2),data(:,59),'*','Color',[1,0.5,0.5],'MarkerSize',3)
plot(data(:,2),data(:,60),'^','Color',[0.5,1,0.5],'MarkerSize',3)
plot(data(:,2),data(:,61),'o','Color',[0.5,0.5,1],'MarkerSize',3)
plot(data(:,2),data(:,63),'*','Color',[0.5,0,0],'MarkerSize',3)
plot(data(:,2),data(:,64),'^','Color',[0,0.5,0],'MarkerSize',3)
plot(data(:,2),data(:,65),'o','Color',[0,0,0.5],'MarkerSize',3)

xlabel('Cycle #'); ylabel('DMA')
set(gca,'FontSize',15,'FontWeight','bold','XColor','k','YColor','k'); box on; 
grid on
legend('a-R','a-G','a-B','c-R','c-G','c-B','box','off','location','best','NumColumns',2)

%%
figure; hold on
plot(data(:,2),data(:,25),'*','Color',[1,0.5,0.5],'MarkerSize',3)
plot(data(:,2),data(:,26),'^','Color',[0.5,1,0.5],'MarkerSize',3)
plot(data(:,2),data(:,27),'o','Color',[0.5,0.5,1],'MarkerSize',3)
plot(data(:,2),data(:,30),'*','Color',[0.5,0,0],'MarkerSize',3)
plot(data(:,2),data(:,31),'^','Color',[0,0.5,0],'MarkerSize',3)
plot(data(:,2),data(:,32),'o','Color',[0,0,0.5],'MarkerSize',3)

xlabel('Cycle #'); ylabel('Mean Image Value')
set(gca,'FontSize',15,'FontWeight','bold','XColor','k','YColor','k'); box on; 
grid on
legend('a-R','a-G','a-B','c-R','c-G','c-B','box','off','location','best','NumColumns',2)
%%
figure; hold on

plot(data(:,2),data(:,35),'*','Color',[0.5,0,0],'MarkerSize',3)
plot(data(:,2),data(:,36),'^','Color',[0,0.5,0],'MarkerSize',3)
plot(data(:,2),data(:,37),'o','Color',[0,0,0.5],'MarkerSize',3)

xlabel('Cycle #'); ylabel('Mean Image Value')
set(gca,'FontSize',15,'FontWeight','bold','XColor','k','YColor','k'); box on; 
grid on
legend('a-R','a-G','a-B','c-R','c-G','c-B','box','off','location','best','NumColumns',2)
