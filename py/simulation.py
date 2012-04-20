import numpy as np
import pandas as p
import pvsim as pvs
import datetime as dt
import scipy.optimize as spo

# configuration

inverter_type = 'typical'
#inverter_type = 'flat'

load_type = 'day'
#load_type = 'night'
#load_type = 'continuous'




# inverter curves
flat_output_curve = {'output_power':[0, 750],
                     'input_power' :[0, 750/.94]}

typical_output_curve = {'output_power':[ 0, 375, 750],
                        'input_power':[0+13, 375/.75, 750/.94]}

if inverter_type == 'flat':
    output_curve = flat_output_curve

if inverter_type == 'typical':
    output_curve = typical_output_curve

def get_load_from_csv():
    df = p.read_csv('week_of_data.csv', index_col=0, parse_dates=True)
    #return df['power'].dropna().values
    #df = df['power'].dropna()
    return p.Series(df['power'].values, index=df.index).dropna()


def run_time_step(inverter,
                  battery,
                  solar,
                  panel,
                  load):

    battery_energy = [0]
    lca = []
    lia = []
    spa = []

    for date in load.index:
        # determine customer and inverter loads and append to arrays
        load_customer = load[date]
        load_inverter = inverter.input_power(load_customer)
        lca.append(load[date])
        lia.append(load_inverter)

        # determine power produced by panel and append to array
        solar_power = panel.power(date)
        spa.append(solar_power)

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

'''
todo: change solver for panel size
'''
def solve_wrapper(A):
    # create objects for simulation
    inverter = pvs.Inverter(output_curve)
    battery = pvs.Battery()
    solar = pvs.Solar(lat=14)
    panel = pvs.Panel(solar, area=A, efficiency=0.20, el_tilt=0, az_tilt=0)

    df = run_time_step(inverter,
                      battery,
                      solar,
                      panel,
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

def pretty_print(tag, value, col_width=30):
    print tag.ljust(col_width),
    print '%.2f' % value



if load_type == 'day':
    load = day_load()

if load_type == 'night':
    load = night_load()

if load_type == 'continuous':
    load = cont_load()

#load = get_load_from_csv()



# get solution using solve wrapper
solution = spo.fsolve(solve_wrapper, 2)
generation_size = solution[0]

# pass this solution to run_time_step (redundantly)
# to get detailed simulation output
inverter = pvs.Inverter(output_curve)
battery = pvs.Battery()
solar = pvs.Solar(lat=14)
panel = pvs.Panel(solar, area=generation_size, efficiency=0.20, el_tilt=0, az_tilt=0)

df = run_time_step(inverter,
                  battery,
                  solar,
                  panel,
                  load)

# output results to stdout
print 'inverter type', inverter_type
print 'load type', load_type
pretty_print('battery excursion (Wh)', df['battery_energy'].max() - df['battery_energy'].min())
pretty_print('customer load (Wh)', df['load_customer'].sum())
pretty_print('end battery charge (Wh)', df.ix[len(df)-1]['battery_energy'])
pretty_print('solar size (m^2)', generation_size)

# output plot of timesteps
plot = True
plot = False
if plot:
    import matplotlib.pyplot as plt
    f, ax = plt.subplots(1, 1)
    ax.plot(df['load_customer'])
    ax.plot(df['load_inverter'])
    ax.plot(df['solar_power'])
    ax.plot(df['battery_energy'])
    ax.grid(True)
    plt.show()
