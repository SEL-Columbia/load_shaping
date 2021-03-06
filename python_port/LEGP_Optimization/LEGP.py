from numpy import pi, sin, cos, tan, arccos, arcsin
import scipy as sp
import numpy as np
import matplotlib.pyplot as plt

# dates is an array 8760 x 6 columns 

# unvectorized

# this function takes the normal to sun, direct beam insolation from a
# solar database and converts it to insolation on a fixed panel
# accounting for both direct, ground reflected, and diffuse 

def resourceCalc(date, sigma, phi_c, I_B, lats,rho):
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
    L = lats
    L = sp.radians(L)
    phi_c = sp.radians(phi_c)

    #n = ceil((1:length(time))/24)';
    # give day of year
    n = int(date.strftime('%j'))


    delta = 23.45 * pi / 180. * sin(2 * pi / 365. * (n - 81))
    time_solar = int(date.strftime('%H'))+1
    H = 2 * pi / 24 * (12 - time_solar)
    
    beta = arcsin(cos(L) * cos(delta) * cos(H) + sin(L) * sin(delta))
    phi_s = arcsin(cos(delta) * sin(H) / cos(beta))
    
    # C ambient light correction
    C = 0.095 + 0.04 * sin(360 / 365. * (n - 100))
    # Stationary Collector

    I_C = I_B * (cos(beta) * cos(phi_s - phi_c) * sin(sigma)
                 + sin(beta) * cos(sigma)
                 + C * (1+cos(sigma)) / 2. + rho * (sin(beta)+C) * (1-cos(sigma))/2.)
    if I_C < 0:
        I_C = 0

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


def SuppDemSum(dates, lats, I_C, demand, pvCap, batCap, batMin):

    # Using energy method calculates battery charge state over a given
    # time frame. The inputs are a date matrix (dates), the annual
    # insolation data (recource),pv Capacity (pvcap) the maximum battery charge state
    # (batcap), and the minimum battery charge state (batMin).
    # dates(1,:) = [2005, 1, 1, 1]  #[year, month,day,hour]
    # Author: Mitchell Lee
    #[r,c] = size(dates)
    #dates = [dates,ones(r,2)]
    #time = datenum(dates)
    supply = I_C/1000. * pvCap
    print np.max(supply)
    batChar = np.zeros(len(demand))

   
    batChar = np.zeros(len(demand))
    batChar[0] = batMin
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
            LEG[ix+1] = 0.

    LEGP = LEG.sum() / demand.sum()
    #LOLP = length(find(LEG>0))/length(LEG)
    # hold on
    # plot(batChar)
    return batChar, LEG, LEGP


#function [batCap, LEGP_ach] = batCapCal(dates,lats, resource,demand, pvCap, LEGP, batStep, batMin)

def batCapCal(dates, lats, I_C, demand, pvCap, LEGP, batStep, batMin):
    '''
    given pvCap and LEGP, returns the battery capacity that delivers
    that LEGP
    '''

    # scaling pv area to maximum of resource
    supply = I_C/1000. * pvCap
    print np.max(supply)
    batChar = np.zeros(len(demand))
    LEGPTemp = 1
    batCap = 0
    x = 0

    while LEGPTemp >= LEGP:
        # Conduct energy balance for all hours of year
        for ix in range(1, len(demand)-1):
            batChar[ix+1] = batChar[ix]+supply[ix]-demand[ix]
            if batChar[ix+1] > batCap:
                batChar[ix+1] = batCap
            if batChar[ix+1] < batMin:
                batChar[ix+1] = batMin

        # Increase battery capacity for next iteration
        batCap = batCap + batStep
        
        
        # Compute the LEG for all hours of year 
        LEG = np.zeros(len(demand))
        for ix in range(1,len(demand)-1):   
            LEG[ix+1] = demand[ix+1] - (supply[ix+1] + batChar[ix] - batMin)
            if LEG[ix+1] < 0:
                LEG[ix+1] = 0
                
        # Calculate LEGP for current iteration
        LEGPTemp = LEG.sum() / demand.sum()
        #print LEGPTemp, batCap
        # Stop the while loop if program is not converging                              
        if batCap >= 100000.:
            LEGP_ach = -999.
            x = 1
            break
                                      
    # Correct for over counting batCap
    batCap = batCap - batStep
    # Store the LEGP of the final iteration                                  
    LEGP_ach = LEGPTemp                                  
                                      
    return batCap, LEGP_ach

    # Main Optimization Algorithm
    # Find mimimum cost battery/PV soluation for a Specified LEGP
def pvBatOptf(dates, weathVec,lats,demVec, LEGPVec):
    
    # Subfunction resourceCalc inputs
    I_B = weathVec
    phi_c = 0.
    sigma = lats
    rho = 0.2
    demand = demVec
    
    # Loop here to create vector I_C
    I_C = np.zeros(len(demand))
    for i, date in enumerate(dates):
        I_C[i] = resourceCalc(date,sigma,phi_c,I_B[i],lats,rho)
        
    LEGPDesired = LEGPVec
    best = np.zeros((len(LEGPDesired),6))
    
    # call upon SuppDem Sum
    # loop over vector of LEGP values
    # this constructs the cost vs LEGP plot
                                          
    for jx in range(1,len(LEGPDesired)+1):
        pvStep = 100.     # fineness by which PV size can be changed (Watts)
        batStep = 100.    # finess by which Batter size may be changed (W-hr)
        pvCost = 0.1762  # Annual Payment for pv ($/Watt-yr)
        batCost = 0.0804 # Annual Payment for battery capacity ($/W-hr-yr)

        demand = demVec
        batMin = 0
        batCap = 100*max(demVec)
        batPerDis = .50
        
        #for near infinite battery capacity, decrement PV capacity until
        #desired LEGP is reached
        pvCap = 20000.
        LEGP = 0.
        while LEGP <= LEGPDesired[jx-1]:
            (batChar, LEG, LEGP) = SuppDemSum(dates,lats, I_C, demand, pvCap, batCap, batMin)
            
            if LEGP <= LEGPDesired[jx-1]:
                pvCap = pvCap - pvStep
        pvCap = pvCap + pvStep
        # starting with PV capacity found in previous loop, trace out an
        # isoreliability curve and store in pvBatCurve
        pvBatCurve = np.zeros((100,2))
        #print 'entering scary loop'
        for ix in np.arange(1,101):
            (batCap, LEGP_ach) = batCapCal(dates, lats, I_C, demand, pvCap, LEGPDesired[jx-1], batStep, batMin)
            pvBatCurve[ix-1,:] = np.hstack([batCap, pvCap])
            #print batCap
            print LEGP_ach
            pvCap = pvCap +pvStep
        
        print 'this is the bat curve', pvBatCurve
        
        # Correct for depth of discharge of battery
        pvBatCurve[:,0] = pvBatCurve[:,0] / batPerDis; 
        # determine Yearly Payment Cost from isoreliability curve and find
        # minimum
        
        totCost = pvBatCurve[:,0] * batCost + pvBatCurve[:,1] * pvCost
        minCost = totCost.min()
        minRow = totCost.argmin()
        batMinCost = pvBatCurve[minRow,0] * batCost
        pvMinCost = pvBatCurve[minRow,1] * pvCost
        
        #Cost Per kWh based on Yearly Payment Cost
        kWh_supp = demand.sum()*(1-LEGP_ach)/1000.        
        cost_kW = (pvBatCurve[:,0]*batCost+pvBatCurve[:,1]*pvCost)/kWh_supp
        #print cost_kW
        minCost = cost_kW.min()
        minRow = cost_kW.argmin()
        #print pvBatCurve
        
        # assemble matrix of results
        best[jx-1,:] = np.concatenate(([LEGPDesired[jx-1]],[minCost],[batMinCost],[pvMinCost],pvBatCurve[minRow,:]))
        
    return best

    
