% Mitchell Lee
% Shared Solar 
% Create an energy balance plot for the first week of data series
% Plot includes battery storage level, insolation, and demand levels
% Began Creating function on July 25, 2012

addpath('C:\Users\Mitchell\Documents\Shared Solar\load_shaping\matlab\LEGP_Optimization')

%% Input Parameters
dates = MaliNTS(:,1:4);
dates = [dates,ones(8760,2)];
weather = MaliNTS(:,5);
[r,c] = size(weather);
lats = 13.45;
demVec = fridgeDemandYear;
LEGPVec = 0.01:0.01:0.20;

%% Optimize
sigma = lats;
phi_c = 0;
rho = 0.2;
I_C = resourceCalc (dates,sigma,phi_c,weather,lats,rho);
bestSingleLoc = pvBatOptf(dates,I_C,demVec,LEGPVec);

%% Find the System Composition at the Desired Reliability
DesRel = 0.05;
[val, idx] = min(bestSingleLoc(:,1)-DesRel);
% function format
%[batChar, LEG, LEGP] = SuppDemSum (I_C,demand, pvCap, batCap, batMin)
[batChar, LEG, LEGP] = SuppDemSum (I_C,demVec, bestSingleLoc(idx,6), bestSingleLoc(idx,5), bestSingleLoc(idx,5)/2);


[ax, h1, h2] = plotyy(datenum(dates((1+24):(168+24),:)),[I_C((1+24):(168+24))/1000*bestSingleLoc(idx,6),demVec((1+24):(168+24))],datenum(dates((1+24):(168+24),:)),batChar((1+24):(168+24)));
set(get(ax(1),'Ylabel'),'String','Supply and Demand of Electricity (W)','FontSize',14)
set(get(ax(2),'Ylabel'),'String','Battery Bank Storage (W-hr)','FontSize',14)
colormap hot
datetick(ax(1),'x','mm/dd')
datetick(ax(2),'x','mm/dd')
set(h1(1),'LineWidth',2,'LineStyle','-','Color','k')
set(h1(2),'LineWidth',2,'LineStyle',':','Color','k')
set(h2,'LineWidth',2,'LineStyle','--','Color','r')
xlabel('Day','FontSize',14)
legend('E_P_V (PV Generation)','E_d_e_m (Electricity Demand)','E_B (Battery Charge State)')


