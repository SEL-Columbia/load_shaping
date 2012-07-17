function [ aveDays] = makeAveDay(demVec)
%makeAveDay
% Mitchell Lee
% Shared Solar
% Create an average hourly demand profile for a single day
% Began on July 5, 2012

aveDays = zeros(24,1);

for ix = 1:24
    aveDays(ix) = mean(demVec(ix:24:144+ix));
end

end

