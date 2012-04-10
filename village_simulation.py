import pandas as p

class Inverter:
    inverter_curve = {'output_power':[ 20,   45, 300, 750],
                        'efficiency':[0.4, 0.65, 0.8, 0.9]}
    #inverter_curve = {'output_power':[ 20,   45, 300, 750],
    #                    'efficiency':[0.9, 0.9, 0.9, 0.9]}

    def efficiency(self, load):
        import scipy.interpolate as spi
        efficiency = spi.interp1d(self.inverter_curve['output_power'],
                                  self.inverter_curve['efficiency'])
        return efficiency(load)

class Battery:
    efficiency_curve = {'output_power':[0, 1000],
                       'efficiency':[1,    1]}

    def efficiency(self, load):
        import scipy.interpolate as spi
        efficiency = spi.interp1d(self.efficiency_curve['output_power'],
                                  self.efficiency_curve['efficiency'])
        return efficiency(load)

load = [50, 50, 50, 50, 50, 50,
        50, 50, 50, 50, 50, 50,
        50, 50, 50, 50, 50, 50,
        300, 300, 300, 300, 300, 300]

def get_load_from_csv():
    df = p.read_csv('week_of_data.csv', index_col=0)
    return df['power'].dropna().values

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

inverter = Inverter()
battery = Battery()
import numpy as np
battery_energy = np.zeros(len(load))

for i in range(2, len(load)):
    # determine customer load for hour
    load_customer = load[i]

    # determine inverter load
    load_inverter = load_customer / inverter.efficiency(load_customer)

    # determine insolation
    # determine solar panel output power
    solar_power = 100

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
    print battery_energy[i]
