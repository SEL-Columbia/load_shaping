% Mitchell Lee
% Shared Solar 
% Call on pvBatOptf for four different weather profiles
% Script Began on July 9, 2012


dates = MaliNTS(:,1:4);
dates = [dates,ones(8760,2)];
weather = [MaliNTS(:,5),LuxorNTS(:,5),KisanganiNTS(:,5),NouakchottNTS(:,5)];
[r,c] = size(weather);
lats = [13.45,25.68,0.51,18.08];
demVec = fridgeDemandYearSyn;
LEGPVec = 0.01:0.01:0.20;
bestMultiLoc = zeros(length(LEGPVec),6,c);
sigma = lats;
phi_c = 0;
rho = 0.2;


for ixx = 1:1%c
    I_C = resourceCalc (dates,sigma(ixx),phi_c,weather(:,ixx),lats(ixx),rho);
    bestMultiLoc(:,:,ixx) = pvBatOptf(dates,I_C,demVec,LEGPVec);
end
    
hold on 
colors = {'b','r','g','k'};
for ixx = 1:c
    plot(bestMultiLoc(:,1,ixx),bestMultiLoc(:,2,ixx),colors{ixx})
end
hold off