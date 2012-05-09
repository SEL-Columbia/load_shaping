import simulation as sim
import pandas as p
import datetime as dt

lead_dict = {'type' : 'lead acid',
             'cost' : 0.14,
             'battery_efficiency_curve' : {'output_power':[0, 1000],
                                           'efficiency':[0.75,   0.75]},
             'DOD' : 0.5,
             'life' : 2
             }

lith_dict = {'type' : 'LFP',
             'cost' : 1,
             'battery_efficiency_curve' : {'output_power':[0, 1000],
                                           'efficiency':[0.95,   0.95]},
             'DOD' : 1.0,
             'life' : 6
             }

pbc_dict = {'type' : 'lead carbon',
             'cost' : 0.14,
             'battery_efficiency_curve' : {'output_power':[0, 1000],
                                           'efficiency':[0.75,   0.75]},
             'DOD' : 0.5,
             'life' : 6
             }

def table_2(plot=False, verbose=False):
    print '%table 2'
    for load in ['day', 'night', 'continuous', 'lighting', 'freezer']:
        for battery in [lead_dict]:
            sim.run_simulation(battery, inverter_type='typical', load_type=load, plot=plot, verbose=verbose)

def table_inverter(plot=False, verbose=False):
    print '% table_inverter'
    print '%', dt.datetime.now()
    import os
    os.system('git rev-parse HEAD')

    for load in ['day', 'night', 'continuous', 'lighting', 'freezer']:
        for battery in [lead_dict]:
            sim.run_simulation(battery, inverter_type='flat', load_type=load, plot=plot, verbose=verbose)

def table_5(plot=False, verbose=False):
    print '% table 5'
    print '%', dt.datetime.now()
    import os
    os.system('git rev-parse HEAD')
    output = []
    both_index = []
    load_index = []
    battery_index = []
    for load in ['day', 'night', 'continuous', 'lighting', 'freezer']:
        for battery in [lead_dict, lith_dict, pbc_dict]:
            d = sim.run_simulation(battery, inverter_type='typical', load_type=load, plot=plot, verbose=verbose)
            d['battery_type'] = battery['type']
            d['load_type'] = load
            output.append(d)

            both_index.append(load + ' ' + battery['type'])
            load_index.append(load)
            battery_index.append(battery['type'])
        print
    df = p.DataFrame(output)
    return df

if __name__ == '__main__':
    #table_2(plot=False, verbose=False)
    table_inverter()
    #df = table_5()