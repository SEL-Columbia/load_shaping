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

for ixx = 1:1%c
    bestMultiLoc(:,:,ixx) = pvBatOptf(dates,weather(:,ixx),lats(ixx),demVec,LEGPVec);
end
    
