import pandas as p
import pvsim as pvs

load = [50, 50, 50, 50, 50, 50,
        50, 50, 50, 50, 50, 50,
        50, 50, 50, 50, 50, 50,
        300, 300, 300, 300, 300, 300]

def get_load_from_csv():
    df = p.read_csv('week_of_data.csv', index_col=0)
    return df['power'].dropna().values



inverter = pvs.Inverter()
battery = pvs.Battery()
solar = pvs.Solar()

import numpy as np
battery_energy = np.zeros(len(load))
battery_energy[0] = 100

lca = []
lia = []
spa = []

for i in range(1, len(load)):
    # determine customer load for hour
    load_customer = load[i]

    # determine inverter load
    load_inverter = load_customer / inverter.efficiency(load_customer)

    # determine insolation
    # determine solar panel output power
    solar_power = 100
    solar_power = solar.insolation(i)

    # compare inverter load to solar generation
    # determine how much energy comes from pv and battery
    if solar_power > load_inverter:
        charge = solar_power - load_inverter
        discharge = 0
    else:
        charge = 0
        discharge = load_inverter - solar_power

    # calculate next energy storage state based on energy from battery
    battery_energy[i] = battery_energy[i-1] + charge - discharge / battery.efficiency(discharge)

    print load_customer,
    print load_inverter,
    print solar_power,
    print battery_energy[i]

    lca.append(load_customer)
    lia.append(load_inverter)
    spa.append(solar_power)

d = {'load_customer' : lca,
     'load_inverter' : lia,
     'solar_power' : spa,
     'battery_energy' : battery_energy[1:len(load)]}

df = p.DataFrame(d)

import matplotlib.pyplot as plt
f, ax = plt.subplots(1, 1)
ax.plot(lca)
ax.plot(lia)
ax.plot(spa)
ax.plot(battery_energy[1:len(load)])
plt.show()


'''
daily_load = 0
daily_battery_load = 0

load = get_load_from_csv()

for i in range(len(load)):
    daily_load += load[i]
    daily_battery_load += load[i] / inverter_efficiency(load[i])

print 'daily_load =', daily_load
print 'daily_battery_load =', daily_battery_load

print 'effective_efficiency =', daily_load / daily_battery_load
'''

