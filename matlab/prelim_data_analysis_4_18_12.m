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
m = abs(1./sin(beta));
A = 1160+75.*sin(pi/180*360/365.*(dayNumbers-275)); % "Apparent" Extraterrestrial Flux 
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
        I_B(ix) = 1000;
    end
end



peakHours = 3:6; %number of peak hours per day equivalent of insolation available  
peakPower = 1000; %W/m^2 is maximum insolation
totalSolarResource = round(rows/24)*peakHours*1000;% The amount of Energy Available 
% during the time period (dependent upon the number of peak hours of sunlight
% available per day) this is in Wh/m^2

m(find(I_B ==0)) = inf;
A(find(I_B ==0)) = 0;
k = zeros(1,length(peakHours));

for jxx =1:length(peakHours) 
 k(jxx)  = findk(totalSolarResource(jxx),A,m);
end


I_BC = zeros(length(peakHours),length(I_B));

for jxx =1:length(peakHours) 
I_BC(jxx,:) = I_B.*cos(theta).*A.*exp(-k(jxx)*m); %Hourly Radiation on Collector per m^2
end
solGen = zeros(length(peakHours),length(I_BC));

totalDemand = sum(rawData(:,2)); % Watt hours per week

% Determine the PV area such that for this week, the exact amount of
% electricity to meet demand is generated
PV_area = totalDemand./totalSolarResource; % m^2

for jx = 1:length(peakHours)
    solGen(jx,:) = I_BC(jx,:)*PV_area(jx);
end
figure
plot(solGen')
 figure
 plot(I_BC')
