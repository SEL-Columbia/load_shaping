import simulation as sim

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
             'cost' : 1,
             'battery_efficiency_curve' : {'output_power':[0, 1000],
                                           'efficiency':[0.75,   0.75]},
             'DOD' : 1.0,
             'life' : 6
             }

plot = False
verbose = False
for load in ['day', 'night', 'continuous', 'village']:
    for battery in [lead_dict, lith_dict, pbc_dict]:
        sim.run_simulation(battery, inverter_type='typical', load_type=load, plot=plot, verbose=verbose)
    print
