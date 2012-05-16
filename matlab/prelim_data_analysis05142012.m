% Mitchell Lee
% 4/12/2012
% Shared Solar
% Create Idealized Solar data
%---------------------
% All nomenclature for solar geometric data notation and equations are
% as consistent as possible with Renewable and Efficicient Electric
% Power Systems by Gilbert M. Masters

clc
format short
format compact
%rawData = importdatafile('week_of_data.csv');
rawData2 = rawData;
rawData2(:,2) = rawData(:,2)-50;
%% Location and PV cell arrangment
L = 13.368056*pi/180; %latitude degrees
Long = 5.273333*pi/180; %longitude(West Positve)
time_meradian = 0; %local time meradian
sigma = L; %collector angle tilt
phi_c = 0;

%% Convert Time to Usable form
dates = datevec(rawData(:,1));
[rows,cols] = size(dates);
monthStarts = [1,2,3,4,5,6,7,8,9,10,11,12
    1,32,60,91,121,152,182,213,244,274,305,335]';
dayNumbers = zeros(rows,1);
for ix = 1:rows
    for ixx = 1:12
        if monthStarts(ixx) == dates(ix,2)
            dayNumbers(ix) = monthStarts(ixx,2)+dates(ix,3);
        end
    end
end
%% Calculate Solar time
standardTimes = dates(:,4)+dates(:,5)*60+dates(:,6)*60*60;%hours
B = 360*(dayNumbers-81)/364*pi/180;
E = 9.87*sin(2*B)-7.53*cos(B)-1.5*sin(B);
solarTimes = standardTimes +4*(time_meradian-Long)*180/pi/60+E/60;% hours
% confirm accuracy of solar time over larger dataset

%% Geometric Properties
delta = asin(-sind(23.45).*cosd(360.*(dayNumbers+10)./365));
H = 15*pi/180*(12-solarTimes);
beta = asin(cos(L)*cos(delta).*cos(H)+sin(L)*sin(delta));
phi_s = asin(cos(delta).*sin(H)./cos(beta));
theta = acos(cos(beta).*cos(phi_s-phi_c).*sin(sigma)+sin(beta).*cos(sigma));
H_SR = acos(-tan(L)*tan(delta));

%% Insolation
% Until reliabled data is available assume that:
% -Direct beam insolation is 1000 W/m^2 during all dailight hours
% -There is no ground reflected or diffuse radition
% -That the insolation at the beginning of the hour is representative of
%  the entire hour.

I_B = zeros(rows,1);
for ix = 1:rows
    if abs(H(ix)) <= abs(H_SR(ix))
        I_B(ix) = 1400;% 1.4 kW
    end
end
I_BC = I_B.*cos(theta); %Hourly Radiation on Collector
%% Demand
totalDemand = sum(rawData2(:,2)); % Watt hours per week
totalSolarResource = sum(I_BC); % Resource on Collector Wh per m^2 per week

% PV Area is equal to actual system
%PV_area = totalDemand/totalSolarResource; % m^2

%% System Simulation
% Plot System Ablity to meet demand vs Battery storage capacity

solGen = I_BC;
demand = rawData2(:,2);
batteryFlow = solGen -demand;
batteryCharge = zeros(rows,1);

% Now assume battery initial charge states is 50% of this range
demandMet = 0;
n = 2000;
MaxCapacity = 2;%Whr
WhShort = zeros(n,1); % Amount of energy that could not be met for each
% battery capacity simulation

LOLP = zeros(n,1);% Loss of Load Probability = number of battery capacity
% measurements with zero capacity divided by the total number of
% measurements taken. Each element is
% for one simulation with a fixed maximum battery capacity)
shortSupplyTimes = zeros(1,rows);
check = 0;
for ixx = 1:n;
    batteryCharge = zeros(rows,1);
    batteryCharge(1) = MaxCapacity(ixx); %Initial Charge State is equal to maximum capacity
    for ix = 2:rows
        batteryCharge(ix) = batteryCharge(ix-1)+batteryFlow(ix-1);
        if batteryCharge(ix) > MaxCapacity(ixx)
            batteryCharge(ix) = MaxCapacity(ixx);
        elseif batteryCharge(ix) < 0
            batteryCharge(ix) = 0;
            WhShort(ixx,1) = WhShort(ixx,1)- batteryFlow(ix-1);
        end
    end
    outTime = find(batteryCharge==0);
    shortSupplyTimes(outTime) = shortSupplyTimes(outTime)+1;
    LOLP(ixx) = sum(batteryCharge == 0)/length(batteryCharge);
    MaxCapacity(ixx+1) = MaxCapacity(ixx)+2;
    if WhShort(ixx)==0 && check ==0
        check = 1;
        figure
        plot(rawData2(:,1),solGen,'g',rawData2(:,1),demand,'b',rawData2(:,1),batteryCharge,'m')
        datetick('x','mm-dd')
        axis auto
        ylabel('Energy (Wh)')
        xlabel('Time')
        title('Time Series for Minimum Battery Capacity Preventing Shutoff (ML06)')
        legend('PV Generation (W)','Energy Demand (W)','Battery Stored Energy (Wh)')
    end
end

chopOff = min(find(LOLP == 0));
LOLP = LOLP(1:chopOff);
MaxCapacity = MaxCapacity(1:chopOff);
WhShort = WhShort(1:chopOff);

figure
plot(MaxCapacity,LOLP)
axis tight
xlabel('Battery Storage Capacity (Wh)')
ylabel('LOLP')
title('Missed Demand vs Maximum Battery Capacity')



% A histogram of energy shortfall times by hour of week

%figure
plot(shortSupplyTimes,'xr')
%hold on 
%datetick('x','mm/dd')
xlabel('Hour of Week')
ylabel('Loss of Load Count')
title('Histogram of Energy Shortfall for All Battery Capacities')
%A histogram of energy shortfall times by hour of day
hours = 0:23;
hourHist = zeros(24,1);
for ix = 0:23
    z = find(dates(:,4)==ix);
    hourHist(ix+1) = sum(shortSupplyTimes(z));
end
figure
plot(hours,hourHist,'xr')
hold on
xlabel('Hour of Day')
ylabel('Loss of Load Count')
title('Histogram of Energy Shortfall for All Battery Capacities')
axis tight
% NOTE: Once the model includes battery efficency losses it will be necessary
% to differentiate between demand that is meet directly via PV energy
% without going to the battery first
