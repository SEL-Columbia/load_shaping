# load up libraries
import LEGP as legp
import pandas as p
import numpy as np
import scipy.io as spio
import datetime as dt
import matplotlib.pyplot as plt

# load in mat weather data
mat = spio.loadmat('resourceSolTim1.mat')
data = mat['MaliNTS']

# create dates from weather data using 'list comprehension'
dates = [dt.datetime(w[0], w[1], w[2], w[3]-1) for w in data]

# extract resource data from weather data
resource = [w[4] for w in data]

# load up demand data
mat2 = spio.loadmat('synthDem.mat')
demVec = mat2['lightDemandYearSyn']
LEGPVec = [0.05]
lats = 13.45
weathVec = data[:,4]

#best = legp.pvBatOptf(dates, weathVec,lats,demVec, LEGPVec)

'''
batcap, desired = legp.batCapCal(dates, 13.45, resource, demVec, 2000, 0.05, 100,
100)
print 'battery', batcap
print 'LEGP', desired
'''

import scipy.io
mat = scipy.io.loadmat('IcTest.mat')
IcTest = mat['IcTest']
IcTest = IcTest[:,0]

'''
# call function
(batchar, LEG, LEGP) = legp.SuppDemSum(dates, 13.45, IcTest, demVec, 2000, 10000, 5000)

# create nice plottable object
'''
'''
batchar = p.Series(index=dates, data=batchar)
batchar.plot()
plt.show()
'''


sigma = lats
phi_c = 0
rho = 0.2
I_C = np.zeros(len(weathVec)) 
for i, date in enumerate(dates):
    I_C[i] = legp.resourceCalc(date, sigma, phi_c, weathVec[i], lats,rho)

