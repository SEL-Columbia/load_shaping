import simulation as sim

plot = True
sim.run_simulation(inverter_type='typical', load_type='day', plot=plot)
sim.run_simulation(inverter_type='typical', load_type='night', plot=plot)
sim.run_simulation(inverter_type='typical', load_type='continuous', plot=plot)
sim.run_simulation(inverter_type='typical', load_type='village', plot=plot)
