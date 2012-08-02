% Mitchell Lee
% Shared Solar 
% Script Began on 07162012
% Hourly LEGP Histogram Maker

format compact; format long g
close all
addpath('C:\Users\Mitchell\Documents\Shared Solar\load_shaping\matlab\LEGP_Optimization')
addpath('C:\Users\Mitchell\Documents\Shared Solar\load_shaping\matlab\Data') 

%% Fridge Demand 
dates = MaliNTS(:,1:4);
dates = [dates,ones(8760,2)];
weather = MaliNTS(:,5);%,LuxorNTS(:,5),KisanganiNTS(:,5),NouakchottNTS(:,5)];LEGPMonthly
[r,c] = size(weather);
lats = 13.45;%25.68,0.51,18.08];
demVec = fridgeDemandYear;
% Specify the Desired LEGP to Test At
LEGPVec = [0.01,0.05];
bestMultiLoc = zeros(length(LEGPVec),6,c);
sigma = lats;
phi_c = 0;
rho = 0.2;

% Test Compute the Best array for each LEGP
for ixx = 1:1%c
    I_C = resourceCalc (dates,sigma(ixx),phi_c,weather(:,ixx),lats(ixx),rho);
    bestMultiLoc(:,:,ixx) = pvBatOptf(dates,I_C,demVec,LEGPVec);
end
disp('Best With Refigerator Base Load')
bestMultiLoc

batChar1 = zeros(length(I_C),length(LEGPVec));
LEG1 = zeros(length(I_C),length(LEGPVec));
LEGP1 = zeros(length(LEGPVec),1);
% Energy Balance Algorithm for each LEGP, so that the LEP of each
% hour is known


for ix = 1:length(LEGPVec)                              %SuppDemSum (I_C,demand, pvCap, batCap, batMin)
    [batChar1(:,ix), LEG1(:,ix),LEGP1(ix)] = SuppDemSum(I_C,demVec,bestMultiLoc(ix,6),bestMultiLoc(ix,5),bestMultiLoc(ix,5)/2);
end
LEGP1 
%% Separate Out LEGP by Hour
LEGPHourly = zeros(24,length(LEGPVec));
LEGHourly = zeros(24,length(LEGPVec));

for ix = 1:length(LEGPVec)
    for jx = 1:24
        LEGHourly(jx,ix) = sum(LEG1(:,ix).*(dates(:,4)==jx));
        LEGPHourly(jx,ix) = LEGHourly(jx,ix)./sum(demVec.*(dates(:,4)==jx));
    end
end
LEGPHourly1 = LEGPHourly;
aveDay = makeAveDay(demVec(1:168));
subplot(1,2,1)
[ax, h1, h2] = plotyy(1:24,LEGPHourly,1:24,aveDay,@bar,@line);
title1 = title('With Refridgerator Base Load');
set(title1,'FontSize',14);
xlabel('Hour','FontSize',12)
set(get(ax(1),'Ylabel'),'String','Hourly LEGP','FontSize',12)
set(get(ax(2),'Ylabel'),'String','Average Hourly Energy Demand (Whr)','FontSize',12)
colormap hot
set(ax(1),'FontSize',12,'YLim',[0 max(max(LEGPHourly+.05))],'XLim', [0 25])
set(ax(2),'FontSize',12,'XLim', [0 25])
set(h2,'LineWidth',2,'LineStyle','--')
legend('Hourly LEGP for Yearly LEGP = 0.01','Hourly LEGP for Yearly LEGP = 0.05', 'Average Hourly Energy Demand')
h_legend=legend;
set(h_legend,'FontSize',10);

%% Calculate Perccentage of Supply Going Directly to Demand
enDirF = energyDir(I_C/1000*bestMultiLoc(ix,6),fridgeDemandYear);
enDirPercF = sum(enDirF)./(sum(fridgeDemandYear))%-sum(LEG1));
%% Light Demand 
dates = MaliNTS(:,1:4);
dates = [dates,ones(8760,2)];
weather = MaliNTS(:,5);%,LuxorNTS(:,5),KisanganiNTS(:,5),NouakchottNTS(:,5)];LEGPMonthly
[r,c] = size(weather);
lats = 13.45;%25.68,0.51,18.08];
demVec = lightDemandYear+5;
% Specify the Desired LEGP to Test At
LEGPVec = [0.01,0.05];
bestMultiLoc = zeros(length(LEGPVec),6,c);
sigma = lats;
phi_c = 0;
rho = 0.2;

% Test Compute the Best array for each LEGP
for ixx = 1:1%c
    I_C = resourceCalc (dates,sigma(ixx),phi_c,weather(:,ixx),lats(ixx),rho);
    bestMultiLoc(:,:,ixx) = pvBatOptf(dates,I_C,demVec,LEGPVec);
end
   
batChar1 = zeros(length(I_C),length(LEGPVec));
LEG1 = zeros(length(I_C),length(LEGPVec));
LEGP1 = zeros(length(LEGPVec),1);
% Energy Balance Algorithm for each LEGP, so that the LEP of each
% hour is known


for ix = 1:length(LEGPVec)                              %SuppDemSum (I_C,demand, pvCap, batCap, batMin)
    [batChar1(:,ix), LEG1(:,ix),LEGP1(ix)] = SuppDemSum(I_C,demVec,bestMultiLoc(ix,6),bestMultiLoc(ix,5),bestMultiLoc(ix,5)/2);
end

disp('Best Without Refigerator Base Load')
bestMultiLoc
LEGP1

%% Separate Out LEGP by Hour
LEGPHourly = zeros(24,length(LEGPVec));
LEGHourly = zeros(24,length(LEGPVec));

for ix = 1:length(LEGPVec)
    for jx = 1:24
        LEGHourly(jx,ix) = sum(LEG1(:,ix).*(dates(:,4)==jx));
        LEGPHourly(jx,ix) = LEGHourly(jx,ix)./sum(demVec.*(dates(:,4)==jx));
    end
end
LEGPHourly2 = LEGPHourly;
aveDay = makeAveDay(demVec(1:168));
subplot(1,2,2)
[ax, h1, h2] = plotyy(1:24,LEGPHourly,1:24,aveDay,@bar,@line);
title1 = title('Without Refridgerator Base Load');
set(title1,'FontSize',14);
xlabel('Hour','FontSize',12)
set(get(ax(1),'Ylabel'),'String','Hourly LEGP','FontSize',12)
set(get(ax(2),'Ylabel'),'String','Average Hourly Energy Demand (Whr)','FontSize',12)
colormap hot
set(ax(1),'FontSize',12,'YLim',[0 max(max(LEGPHourly+.05))],'XLim', [0 25])
set(ax(2),'FontSize',12,'XLim', [0 25])
set(h2,'LineWidth',2,'LineStyle','--')
legend('Hourly LEGP for Yearly LEGP = 0.01','Hourly LEGP for Yearly LEGP = 0.05', 'Average Hourly Energy Demand')
h_legend=legend;
set(h_legend,'FontSize',10);
%% Calculate Perccentage of Supply Going Directly to Demand
enDirL = energyDir(I_C/1000*bestMultiLoc(ix,6),lightDemandYear);
enDirPercL = sum(enDirL)./(sum(lightDemandYear))%-sum(LEG1));
