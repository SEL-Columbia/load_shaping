from numpy import pi, sin, cos, tan, arccos, arcsin
import scipy as sp
import numpy as np

# dates is an array 8760 x 6 columns 

# unvectorized

# this function takes the normal to sun, direct beam insolation from a
# solar database and converts it to insolation on a fixed panel
# accounting for both direct, ground reflected, and diffuse 

def resourceCalc(date, sigma, phi_c, I_B, L, Long, LTM, rho):
    '''
    inputs
    ------
    date - datetime object
    sigma - collector angle
    rho - factor for ground reflectance
    '''

    #time = datenum(dates);
    
    #sigma = (sigma)*pi/180  #collector angle sigma from ground
    sigma = sp.radians(sigma)
    L = sp.radians(L)
    phi_c = sp.radians(phi_c)

    #n = ceil((1:length(time))/24)';
    # give day of year
    n = int(date.strftime('%j'))


    delta = 23.45 * pi / 180. * sin(2 * pi / 365. * (n - 81))
    B = 2 * pi / 364. * (n - 81)
    E = (9.87 * sin(2 * B) - 7.53 * cos(B) - 1.5 * sin(B)) / 60.
    time_solar = int(date.strftime('%H')) + 4 / 60 * (LTM-Long) + E
    H = 2 * pi / 24 * (12 - time_solar)
    beta = arcsin(cos(L) * cos(delta) * cos(H) + sin(L) * sin(delta))
    phi_s = arcsin(cos(delta) * sin(H) / cos(beta))
    theta = arccos(cos(beta) * cos(phi_s - phi_c) * sin(sigma) + sin(beta) * cos(sigma))
    
    # C ambient light correction
    C = 0.095 + 0.04 * sin(360 / 365 * (n - 100))
    # Stationary Collector
    I_C = I_B * (cos(beta) * cos(phi_s - phi_c) * sin(sigma)
                 + sin(beta) * cos(sigma)
                 + C * (1+cos(sigma)) / 2 + rho * (sin(beta)+C) * (1-cos(sigma))/2)
    if I_C < 0:
        IC = 0

    return I_C
    



'''  
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

    
end
'''
#function [batChar, LEG, LEGP] = SuppDemSum (dates,resource,demand, pvCap, batCap, batMin)


def SuppDemSum(dates, resource, demand, pvCap, batCap, batMin):

    # Using energy method calculates battery charge state over a given
    # time frame. The inputs are a date matrix (dates), the annual
    # insolation data (recource),pv Capacity (pvcap) the maximum battery charge state
    # (batcap), and the minimum battery charge state (batMin).
    # dates(1,:) = [2005, 1, 1, 1]  #[year, month,day,hour]
    # Author: Mitchell Lee
    #[r,c] = size(dates)
    #dates = [dates,ones(r,2)]
    #time = datenum(dates)
    
    # scaling pv area to maximum of resource
    pvArea = pvCap/max(resource) 

    # Subfunction inputs
    phi_c = 0
    sigma = 13.45
    L = 13.45
    Long = 6.266667
    LTM = 0
    rho = 0.2

    # TODO need loop here to create vector I_C
    I_C = np.zeros(len(demand))
    for i, date in enumerate(dates):
        I_C[i] = resourceCalc(date,sigma,phi_c,resource[i],L,Long,LTM,rho)

    supply = I_C * pvArea 
    batChar = np.zeros(len(demand))

    #for ix = 1:(length(demand)-1)
    for ix in range(1, len(demand)-1):
        batChar[ix+1] = batChar[ix]+supply[ix]-demand[ix]
        if batChar[ix+1] > batCap:
            batChar[ix+1] = batCap
        if batChar[ix+1] < batMin:
            batChar[ix+1] = batMin

    #Compute LEGP (Lack of Energy to Generated)
    LEG = np.zeros(len(demand))
    for ix in range(1, len(demand)-1):
        LEG[ix+1] = demand[ix+1]-(supply[ix+1]+batChar[ix]-batMin)
        if LEG[ix+1] < 0:
            LEG[ix+1] = 0

    LEGP = LEG.sum() / demand.sum()
    #LOLP = length(find(LEG>0))/length(LEG)
    # hold on
    # plot(batChar)
    return batChar, LEG, LEGP