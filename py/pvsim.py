import scipy as sp
import scipy.interpolate as spi



class Inverter:
    inverter_curve = {'output_power':[ 20,   45, 300, 750],
                        'efficiency':[0.4, 0.65, 0.8, 0.9]}
    #inverter_curve = {'output_power':[ 20,   45, 300, 750],
    #                    'efficiency':[0.9, 0.9, 0.9, 0.9]}

    # this might be better off returning the power demanded rather
    # than the efficiency, especially since we need to use the
    # no-load condition

    def efficiency(self, load):
        efficiency = spi.interp1d(self.inverter_curve['output_power'],
                                  self.inverter_curve['efficiency'])
        return efficiency(load)

class Battery:
    efficiency_curve = {'output_power':[0, 1000],
                       'efficiency':[1,    1]}

    def efficiency(self, load):
        efficiency = spi.interp1d(self.efficiency_curve['output_power'],
                                  self.efficiency_curve['efficiency'])
        return efficiency(load)

class Solar:
    lat = sp.radians(40)
    lon = sp.radians(0)

    def declination(self, date):
        # '%j' gives day of year
        day_of_year = int(date.strftime('%j'))
        return sp.radians(23.45 * sp.sin(2 * sp.pi * (day_of_year - 81) / 365.0))

    def hour_angle(self, date):
        # '%H' gives hour of day
        return sp.radians(15 * (int(date.strftime('%H')) - 12))

    def elevation(self, date):
        dec = self.declination(date)
        ha = self.hour_angle(date)
        return sp.arcsin(sp.cos(self.lat) * sp.cos(dec) * sp.cos(ha)
                         + sp.sin(self.lat) * sp.sin(dec))

    def azimuth(self, date):
        dec = self.declination(date)
        ha = self.hour_angle(date)
        # todo: deal with over 90 degree condition
        az = sp.arcsin(sp.cos(dec) * sp.sin(ha) / sp.cos(self.elevation(date)))
        if (sp.cos(ha) >= (sp.tan(dec) / sp.tan(self.lat))):
            return az
        else:
            return (sp.pi - az)

    def insolation(self, hour):
        if sp.sin(hour / 24. * sp.pi) > 0:
            return sp.sin(hour / 24. * sp.pi) / 2 * 500
        else:
            return 0

