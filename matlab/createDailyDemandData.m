% Mitchell Lee
% Shared Solar 
% May 23,2012
% Convert an hourly demand data set into a daily data set. The propagate 
% the data into a year long vector

lightDemandDaily = ones(365,1)*-999;
for ix = 1:365
    lightDemandDaily(ix) = sum(lightDemandYear((ix*24-23):ix*24));
end
