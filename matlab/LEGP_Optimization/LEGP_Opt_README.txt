README for Mitchell's Energy Consumption Model's

pvBatOpt.m - is the main optimization algorithm is calls on
SuppDemSum.m  and batCapCal.m

SuppDemSum.m - given PV capacity and Battery capacity this 
outputs the LEGP of the system. This is used by pvBatOpt.m
to compute the minimum pv panel size that is necessary to meet
a specified LEGP, when there is a nearly infinite battery bank

batCapCal.m - computes the necessary Battery bank for a given 
PV array and desired LEGP. This is called upon by pvBatopt.m 
to actually produce the battery vs. PV curve

resourceCalc.m - computes takes the insolation data and converts
that into the net insolation w/m^2 on the collector.