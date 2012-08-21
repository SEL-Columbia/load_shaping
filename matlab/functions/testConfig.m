%% Test Particular Micro-Grid Configuration Performance
% By: Mitchell Lee
% Script Began on August 20, 2012

%% Calculate Solar Production

format compact; format long g
close all
addpath('C:\Users\Mitchell\Documents\Shared Solar\load_shaping\matlab\LEGP_Optimization')
addpath('C:\Users\Mitchell\Documents\Shared Solar\load_shaping\matlab\Data') 

dates = MaliNTS(:,1:4);
dates = [dates,ones(8760,2)];
weather = MaliNTS(:,5);
[r,c] = size(weather);
lats = 13.45;
demVec = fridgeDemandYear;
% Specify the Desired LEGP to Test At
sigma = lats;
phi_c = 0;
rho = 0.2;
I_C = resourceCalc (dates,sigma,phi_c,weather,lats,rho);

%% Analyze Performance

% SuppDemSum (I_C,demand, pvCap, batCap, batMin)
[batChar1, LEG1,LEGP1] = SuppDemSum(I_C,demVec,1400,17280,17280/2);

batCost = 0.0804;
pvCost = 0.1762;

kWh_supp = sum(demVec)*(1-LEGP1)/1000;        
cost_kW = (17280*batCost+1400*pvCost)/kWh_supp
LEGP1


