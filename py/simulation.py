import numpy as np
import pandas as p
import pvsim as pvs
import datetime as dt
import scipy.optimize as spo

def get_load_from_csv():
    df = p.read_csv('week_of_data.csv', index_col=0)
    return df['power'].dropna().values



def run_time_step(inverter,
                  battery,
                  solar,
                  load):
    '''
    # create objects for simulation
    inverter = pvs.Inverter()
    battery = pvs.Battery()
    solar = pvs.Solar(A=786, lat=40)
    '''
    battery_energy = [0]
    lca = []
    lia = []
    spa = []

    # need to wrap this in a solver to get the right production size
    for date in load.index:
        # determine customer load for hour
        load_customer = load[date]

        # determine inverter load
        #load_inverter = load_customer / inverter.efficiency(load_customer)
        load_inverter = inverter.input_power(load_customer)

        lca.append(load[date])
        lia.append(load_inverter)
        spa.append(solar.insolation(date))

        # determine insolation
        solar_power = solar.insolation(date)

        # compare inverter load to solar generation
        # determine how much energy comes from pv and battery
        if solar_power > load_inverter:
            charge = solar_power - load_inverter
            discharge = 0
        else:
            charge = 0
            discharge = load_inverter - solar_power

        # calculate next energy storage state based on energy from battery
        battery_energy.append(battery_energy[-1]
                              + charge
                              - discharge / battery.efficiency(discharge))

    # assemble everything into a dataframe
    d = {'load_customer' : lca,
         'solar_power' : spa,
         'load_inverter' : lia,
         'battery_energy' : battery_energy[:-1]}

    df = p.DataFrame(d)

    return df

def solve_wrapper(A):
    # create objects for simulation
    inverter = pvs.Inverter()
    battery = pvs.Battery()
    solar = pvs.Solar(A=A, lat=40)

    df = run_time_step(inverter,
                      battery,
                      solar,
                      load)

    return df.ix[len(df)-1]['battery_energy']

# create date range to get insolation
date_start = dt.datetime(2012, 2, 1)
date_end = dt.datetime(2012, 2, 2)
rng = p.DateRange(date_start, date_end, offset=p.DateOffset(hours=1))

# create load profile and series object
# 9, 6, 10
# 18, 6, 1
def night_load():
    load_values = [0] * 18
    load_values.extend([300] * 6)
    load_values.extend([0] * 1)
    load = p.Series(load_values, index=rng)
    return load

def day_load():
    load_values = [0] * 9
    load_values.extend([300] * 6)
    load_values.extend([0] * 10)
    load = p.Series(load_values, index=rng)
    return load

def cont_load():
    load_values = [1800/25.] * 25
    load = p.Series(load_values, index=rng)
    return load


load = night_load()
load = day_load()
load = cont_load()

solution = spo.fsolve(solve_wrapper, 800)

generation_size = solution[0]

inverter = pvs.Inverter()
battery = pvs.Battery()
solar = pvs.Solar(A=generation_size, lat=40)

df = run_time_step(inverter,
                  battery,
                  solar,
                  load)

print 'battery excursion', df['battery_energy'].max() - df['battery_energy'].min()
print 'customer load', df['load_customer'].sum()
print 'end battery charge', df.ix[len(df)-1]['battery_energy']
print 'solar size', solar.A

plot = True
plot = False
if plot:
    import matplotlib.pyplot as plt
    f, ax = plt.subplots(1, 1)
    ax.plot(d['load_customer'])
    ax.plot(d['load_inverter'])
    ax.plot(d['solar_power'])
    ax.plot(d['battery_energy'])
    ax.grid(True)
    plt.show()
