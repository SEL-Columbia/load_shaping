function [I_C] = resourceCalc (dates,sigma,phi_c,I_B,L,Long,LTM,rho)
    
    % Given a set of dates stamps with the corresponding beam insolation
    % on the earths surface and ground reflectance, calculates
    % the insolationon the collector at all times.
    %
    % I_C = net insolation on collector
    % sigma = collector tilt
    % L = Location Latitude
    % Long = Location Long
    % LTM 
    % phi_c = collector azimuth
    % rho = ground reflectance
    %
    % All solar notation is consistant with the notation in Renewable and Efficienct Power Systems
    % by Gilbert M. Masters 1st Edition, chapter 7. All additional variables and notation are defined. 
    %
    % Author: Mitchell Lee

    
    time = datenum(dates); 
    
    sigma = (sigma)*pi/180; %collector angle sigma from ground
 
    n = ceil((1:length(time))/24)';
    delta = 23.45*pi/180*sin(2*pi/365*(n-81));
    B = 2*pi/364*(n-81);
    E = (9.87.*sin(2.*B)-7.53.*cos(B)-1.5.*sin(B))/60;
    time_solar = dates(:,4)+4/60*(LTM-Long)+E;
    H = 2*pi/24*(12-time_solar);
    H_sunrise_col = acos(-tan(L).*tan(delta));
    sunrise_col = H_sunrise_col*24/(2*pi);
    beta = asin(cos(L).*cos(delta).*cos(H)+sin(L).*sin(delta));
    phi_s = asin(cos(delta).*sin(H)./cos(beta));
    theta = acos(cos(beta).*cos(phi_s-phi_c).*sin(sigma)+sin(beta).*cos(sigma));
    
    C = 0.095+0.04*sin(360/365*(n-100));
    % Stationary Collector
    I_C = I_B.*(cos(beta).*cos(phi_s-phi_c).*sin(sigma)+sin(beta).*cos(sigma)+C.*(1+cos(sigma))./2+rho.*(sin(beta)+C).*(1-cos(sigma))./2);
    I_C(I_C<0) = 0;
end
