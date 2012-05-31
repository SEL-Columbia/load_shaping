% Mitchell Lee
% Shared Solar 
% Create a pretend multi year data set of hourly insolation
pretendDates = MaliNTSData2005(:,1:4);
pretendDates(:,5:6) = 0; 
pretendDates(:,1) = 2000;
[r,c] = size(MaliNTSData2005);
dateMat = zeros(r,10);
radMat = zeros(r,10);
for ix = 1:10
    %creating date Matrix
    dateMat(:,ix) = datenum(pretendDates);
    pretendDates(:,1) = pretendDates(:,1)+1;
    %creating pretend radiation data matrix
    modify = find(MaliNTSData2005(:,ix)>=0);
    radMat(modify,ix) = MaliNTSData2005(modify,ix)+50*2*(rand(length(modify),1)-.5);
    radMat(radMat < 0) = 0; 
end