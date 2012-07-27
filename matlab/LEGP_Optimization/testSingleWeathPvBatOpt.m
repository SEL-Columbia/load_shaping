% Mitchell Lee
% Shared Solar 
% Call on pvBatOptf for ones weather profile
% Script Began on July 9, 2012

dates = MaliNTS(:,1:4);
dates = [dates,ones(8760,2)];
weather = MaliNTS(:,5);
[r,c] = size(weather);
lats = 13.45;
demVec = fridgeDemandYear;
LEGPVec = 0.01:0.01:0.20;

sigma = lats;
phi_c = 0;
rho = 0.2;
I_C = resourceCalc (dates,sigma,phi_c,weather,lats,rho);
bestSingleLoc = pvBatOptf(dates,I_C,demVec,LEGPVec);

%% Plot for ONE Cost vs LEGP Curve
plot(bestSingleLoc(:,1),bestSingleLoc(:,2),'LineWidth',2)

xlabel('LEGP','FontSize',14)
ylabel('Cost Per kWhr (USD)','FontSize',14)
%legend('Mali')
set(gca,'FontSize',12)
axis tight
hold on

%% Repeat Process for different demand curve
dates = MaliNTS(:,1:4);
dates = [dates,ones(8760,2)];
weather = MaliNTS(:,5);
[r,c] = size(weather);
lats = 13.45;
demVec = lightDemandYear;
LEGPVec = 0.01:0.01:0.20;

sigma = lats;
phi_c = 0;
rho = 0.2;
I_C = resourceCalc (dates,sigma,phi_c,weather,lats,rho);
bestSingleLoc = pvBatOptf(dates,I_C,demVec,LEGPVec);

%% Plot for ONE Cost vs LEGP Curve
plot(bestSingleLoc(:,1),bestSingleLoc(:,2),'--','LineWidth',2)

xlabel('LEGP','FontSize',14)
ylabel('Cost Per kWhr (USD)','FontSize',14)
legend('With Refridgerator Base Load','Without Refridgerator Base Load')
set(gca,'FontSize',12)
axis tight
hold off
