% Mitchell Lee
% Shared Solar 
% Call on pvBatOptf for four different weather profiles
% Script Began on July 9, 2012


dates = MaliNTSData2005_2(:,1:4);
weather = [MaliNTSData2005_2(:,5),LuxorNTSData2005(:,5),KisanganiNTSData2005(:,5),NouakchottNTSData2005(:,5)];
[r,c] = size(weather);
demVec = fridgeDemandYearSyn;
LEGPVec = 0.01:0.01:0.20;
bestMultiLoc = zeros(length(LEGPVec),6,c);

for ixx = 1:c
    bestMultiLoc(:,:,ixx) = pvBatOptf(dates,weather(:,ixx),demVec,LEGPVec);
end
    
