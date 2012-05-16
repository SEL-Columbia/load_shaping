function [ I_BC ] = solDatGeo (lat,long,locTimeMerad,tilt,colAzimuth,dateRange)
%solDatGeo Using Geometry estimates available solar radiation for
%stationary plane
%Mitchell Lee 
% 5/16/2012
% Shared Solar 
% Create Idealized Solar data
%---------------------
% All nomenclature for solar geometric data notation and equations ar 
% as consistent as possible with Renewable and Efficicient Electric 
% Power Systems by Gilbert M. Masters

%% Convert Time to Usable form
dates = datevec(dateRange);
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
solarTimes = standardTimes +4*(locTimeMerad-long)*180/pi/60+E/60;% hours
% confirm accuracy of solar time over larger dataset 

%% Geometric Properties
delta = asin(-sind(23.45).*cosd(360.*(dayNumbers+10)./365));
H = 15*pi/180*(12-solarTimes);
beta = asin(cos(long)*cos(delta).*cos(H)+sin(long)*sin(delta));
phi_s = asin(cos(delta).*sin(H)./cos(beta)); 
theta = acos(cos(beta).*cos(phi_s-colAzimuth).*sin(tilt)+sin(beta).*cos(tilt));
H_SR = acos(-tan(long)*tan(delta));

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
I_BC = I_B.*cos(theta); %Hourly Radiation on Collector per m^2

end
