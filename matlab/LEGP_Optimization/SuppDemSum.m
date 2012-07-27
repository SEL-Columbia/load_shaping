function [batChar, LEG, LEGP] = SuppDemSum (I_C,demand, pvCap, batCap, batMin)

% Using energy method calculates battery charge state over a given
% time frame. The inputs are a date matrix (dates), the annual
% insolation data (recource),pv Capacity (pvcap) the maximum battery charge state
% (batcap), and the minimum battery charge state (batMin).
% dates(1,:) = [2005, 1, 1, 1]  %[year, month,day,hour]
% Author: Mitchell Lee

% Subfunction inputs

supply = I_C/1000*pvCap; %W
batChar = zeros(length(demand),1);

for ix = 1:(length(demand)-1);
    batChar(ix+1) = batChar(ix)+supply(ix)-demand(ix);
    if batChar(ix+1) > batCap
        batChar(ix+1) = batCap;
    end
    if batChar(ix+1) < batMin
        batChar(ix+1) = batMin;
    end
end

%Compute LEGP (Lack of Energy to Generated)
LEG = zeros(length(demand),1);
for ix = 1:(length(demand)-1);
    LEG(ix+1) = demand(ix+1)-(supply(ix+1)+batChar(ix)-batMin);
    if (LEG(ix+1) <0) || (ix<=24)
        LEG(ix+1) = 0;
    end
end
LEGP = sum(LEG)/sum(demand);
%LOLP = length(find(LEG>0))/length(LEG);
% hold on
% plot(batChar)
end