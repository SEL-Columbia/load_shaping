import pandas as p
import scipy as sp

class Inverter:
    inverter_curve = {'output_power':[ 20,   45, 300, 750],
                        'efficiency':[0.4, 0.65, 0.8, 0.9]}
    #inverter_curve = {'output_power':[ 20,   45, 300, 750],
    #                    'efficiency':[0.9, 0.9, 0.9, 0.9]}

    # this might be better off returning the power demanded rather
    # than the efficiency, especially since we need to use the
    # no-load condition

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

class Solar:
    latitude = 0
    longitude = 0

    def declination(self, date):
        day_of_year = date.strftime('%j')
        return 23.45 * sp.sin(2 * sp.pi * (day_of_year - 81) / 365.0)

    def hour_angle(self, date):
        pass

    def insolation(self, hour):
        if sp.sin(hour / 24. * sp.pi) > 0:
            return sp.sin(hour / 24. * sp.pi) / 2 * 500
        else:
            return 0

