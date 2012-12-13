import numpy as np
import pandas as p
import pvsim as pvs
import datetime as dt
import scipy.optimize as spo

# configuration

inverter_type = 'typical'
#inverter_type = 'flat'

load_type = 'day'
load_type = 'night'
load_type = 'continuous'
#load_type = 'village'


def lighting_load():
    df = p.read_csv('ml05-1day.csv', index_col=0, parse_dates=True)
    #return df['power'].dropna().values
    #df = df['power'].dropna()
    return p.Series(df['power'].values, index=df.index).dropna()

def freezer_load():
    df = p.read_csv('ml06-1day.csv', index_col=0, parse_dates=True)
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
def solve_wrapper(A, output_curve, battery_efficiency_curve, load, panel_efficiency):
    # create objects for simulation
    inverter = pvs.Inverter(output_curve)
    battery = pvs.Battery(battery_efficiency_curve)
    solar = pvs.Solar(lat=14)
    panel = pvs.Panel(solar, area=A, efficiency=panel_efficiency, el_tilt=0, az_tilt=0)

    df = run_time_step(inverter,
                      battery,
                      solar,
                      panel,
                      load)

    return df.ix[len(df)-1]['battery_energy']

# create date range to get insolation
date_start = dt.datetime(2012, 3, 23)
date_end = dt.datetime(2012, 3, 24)
rng = p.DateRange(date_start, date_end, offset=p.DateOffset(hours=1))

# create load profile and series object
# 9, 6, 10
# 18, 6, 1
def night_load():
    load_values = [0.0] * 18
    load_values.extend([300.0] * 6)
    load_values.extend([0.0] * 1)
    load = p.Series(load_values, index=rng)
    return load

def day_load():
    load_values = [0.0] * 9
    load_values.extend([300.0] * 6)
    load_values.extend([0.0] * 10)
    load = p.Series(load_values, index=rng)
    return load

def cont_load():
    load_values = [1800.0/25.] * 25
    load = p.Series(load_values, index=rng)
    return load

'''
takes a load in the form of a pandas series and normalizes it such that
the average daily energy in the load is equal to normalized_daily_load
'''
def normalize_load(load, normalized_daily_load):
    load_days = (load.index[-1] - load.index[0]).total_seconds() / 24 / 60 / 60
    load_daily_average = load.sum() / load_days
    return load / load_daily_average * normalized_daily_load

def pretty_print(tag, value, col_width=30):
    print tag.ljust(col_width),
    print '%.2f' % value

def run_simulation(battery_dict,
                   inverter_type='typical',
                   load_type='day',
                   plot=False,
                   verbose=True):

    panel_efficiency = 0.135

    # battery curve
    battery_efficiency_curve = battery_dict['battery_efficiency_curve']

    # inverter curves
    flat_output_curve = {'output_power':[0, 750],
                         'input_power' :[0, 750/.94]}
    typical_output_curve = {'output_power':[ 0, 375, 750],
                            'input_power':[0+13, 375/.75, 750/.94]}

    if inverter_type == 'flat':
        output_curve = flat_output_curve
    if inverter_type == 'typical':
        output_curve = typical_output_curve

    if load_type == 'day':
        load = day_load()
    if load_type == 'night':
        load = night_load()
    if load_type == 'continuous':
        load = cont_load()
    #if load_type == 'village':
        #load = get_load_from_csv()
    if load_type == 'lighting':
        load = lighting_load()
    if load_type == 'freezer':
        load = freezer_load()

    load = normalize_load(load, 3000)
    #print load

    # get solution using solve wrapper
    solution = spo.fsolve(solve_wrapper, 4, args=(output_curve, battery_efficiency_curve,
                                                  load, panel_efficiency))
    generation_size = solution[0]

    # pass this solution to run_time_step (redundantly)
    # to get detailed simulation output
    inverter = pvs.Inverter(output_curve)
    battery = pvs.Battery(battery_efficiency_curve)
    solar = pvs.Solar(lat=14)
    panel = pvs.Panel(solar, area=generation_size, efficiency=0.135, el_tilt=0, az_tilt=0)

    df = run_time_step(inverter,
                      battery,
                      solar,
                      panel,
                      load)

    panel_cost_per_kW = 1000
    panel_peak_kW = generation_size * 0.135
    battery_size_kWh = (df['battery_energy'].max() - df['battery_energy'].min())/1000.
    battery_cost = calc_battery_cost(battery_size_kWh*1000, battery_dict['DOD'], battery_dict['cost'])
    battery_npv = npv(0.07, create_battery_cashflow(battery_cost, battery_dict['life']))
    panel_cost = panel_peak_kW * panel_cost_per_kW

    # print out row of latex table
    print (inverter_type + ' ' + load_type + ' ' + battery_dict['type']).ljust(30),
    print '&',
    #print '%.2f' % generation_size,
    print '%.2f' % panel_peak_kW,
    print '&',
    print '%.2f' % battery_size_kWh,
    print '&',
    print '%.0f' % battery_npv,
    print '&',
    print '%.0f' % panel_cost,
    print '\\\\'

    # output results to stdout
    if verbose:
        #print 'inverter type', inverter_type
        #print 'load type', load_type
        print 'battery cost', battery_cost
        print 'battery npv', battery_npv
        #pretty_print('battery excursion (Wh)', battery_size)
        #pretty_print('customer load (Wh)', df['load_customer'].sum())
        #pretty_print('end battery charge (Wh)', df.ix[len(df)-1]['battery_energy'])
        #pretty_print('solar size (m^2)', generation_size)

    # output plot of timesteps
    if plot:
        import matplotlib.pyplot as plt
        f, ax = plt.subplots(1, 1)
        #ax.plot(df['load_customer'],  label='AC Load (W)')
        ax.plot(df['load_inverter'],  label='Inverter DC Load (W)')
        ax.plot(df['solar_power'],    label='Solar Generation (W)')
        ax.plot(df['battery_energy'], label='Battery Energy (Wh)')
        ax.set_xlabel('Hour of Day')
        ax.grid(True)
        ax.legend(loc='best')
        plt.show()
    return {'panel_peak_kW' : panel_peak_kW,
            'battery_size_kWh' : battery_size_kWh,
            'battery_npv' : battery_npv,
            'panel_cost' : panel_cost,
            'battery_cost' : battery_cost,
            'inverter_type': inverter_type,
            'battery_type': battery_dict['type'],
            'load_type': load_type}

def calc_battery_cost(battery_size, DOD, cost):
    return battery_size / DOD * cost

def create_battery_cashflow(cost, life, lifetime=20):
    tl = [cost] + [0] * (life - 1)
    l = tl * (lifetime/len(tl) + 1)
    return l[:21]

def npv(rate, cashflows):
    total = 0.0
    for i, cashflow in enumerate(cashflows):
        total += cashflow / (1 + rate)**i
    return total
