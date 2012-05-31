function [batChar, LOLP, LEGP] = SuppDemSum (dates,resource,demand, pvCap, batCap, batMin);

% Using energy method calculates battery charge state over a given
% time frame. The inputs are a date matrix (dates), the annual
% insolation data (recource),pv Capacity (pvcap) the maximum battery charge state
% (batcap), and the minimum battery charge state (batMin).
% dates(1,:) = [2005, 1, 1, 1]  %[year, month,day,hour]
% Author: Mitchell Lee

time = datenum(dates);
pvArea = pvCap/max(resource); 

% Subfunction inputs
phi_c = 0;
sigma = 13.45;
I_B = resource;
L = 13.45;
Long = 6.266667;
LTM = 0;
rho = 0.2;
[I_C] = resourceCalc (dates,sigma,phi_c,I_B,L,Long,LTM,rho);

%To create daily data;
% I_CDaily = ones(365,1)*-999;
% 
% for ix = 1:365
%     day = I_C((24*ix-23):(ix*24));
%     I_CDaily(ix) = sum(day);
% end
% I_C = I_CDaily;
% % plot(I_C)

supply = I_C*pvArea; %W
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
    if LEG(ix+1) <0
        LEG(ix+1) = 0;
    end
end
LEGP = sum(LEG)/sum(demand);
LOLP = length(find(LEG>0))/length(LEG);

% plot(I_C,'b')
% hold on
% plot(batChar)
end
