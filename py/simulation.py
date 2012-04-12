import numpy as np
import pandas as p
import pvsim as pvs
import datetime as dt

def get_load_from_csv():
    df = p.read_csv('week_of_data.csv', index_col=0)
    return df['power'].dropna().values


# create date range to get insolation
date_start = dt.datetime(2012, 2, 1)
date_end = dt.datetime(2012, 2, 2)
rng = p.DateRange(date_start, date_end, offset=p.DateOffset(hours=1))

# create load profile and series object
load_values = [50] * 9
load_values.extend([300] * 6)
load_values.extend([50] * 10)
load = p.Series(load_values, index=rng)

# create objects for simulation
inverter = pvs.Inverter()
battery = pvs.Battery()
solar = pvs.Solar()

battery_energy = [0]
lca = []
lia = []
spa = []

for date in load.index:
    # determine customer load for hour
    load_customer = load[date]

    # determine inverter load
    load_inverter = load_customer / inverter.efficiency(load_customer)

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

print df['battery_energy'].max()
print df['battery_energy'].min()
print df['battery_energy'].max() - df['battery_energy'].min()


import matplotlib.pyplot as plt
f, ax = plt.subplots(1, 1)
ax.plot(d['load_customer'])
ax.plot(d['load_inverter'])
ax.plot(d['solar_power'])
ax.plot(d['battery_energy'])
ax.grid(True)
plt.show()
