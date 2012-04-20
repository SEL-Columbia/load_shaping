import scipy as sp
import scipy.interpolate as spi
from scipy import sin, cos, tan, arcsin, arccos, pi, exp


'''
todo: be able to pass output curve to class on __init__
'''
class Inverter:
    efficiency_curve = {'output_power':[ 20,   45, 300, 750],
                          'efficiency':[0.4, 0.65, 0.8, 0.9]}
    output_curve = {'output_power':[0, 750],
                    'input_power' :[0, 750/.9]}

    #output_curve = {'output_power':[ 0, 20, 45, 300, 750],
    #                 'input_power':[10, 50, 70, 375, 833]}
    #inverter_curve = {'output_power':[ 20,   45, 300, 750],
    #                    'efficiency':[0.9, 0.9, 0.9, 0.9]}

    def efficiency(self, load):
        efficiency = spi.interp1d(self.efficiency_curve['output_power'],
                                  self.efficiency_curve['efficiency'])
        return efficiency(load)

    def input_power(self, load):
        input_power = spi.interp1d(self.output_curve['output_power'],
                                   self.output_curve['input_power'])
        return input_power(load)


class Battery:
    efficiency_curve = {'output_power':[0, 1000],
                       'efficiency':[0.75,   0.75]}

    def efficiency(self, load):
        efficiency = spi.interp1d(self.efficiency_curve['output_power'],
                                  self.efficiency_curve['efficiency'])
        return efficiency(load)


'''
calculates insolation and other solar properties
'''
class Solar:
    lat = sp.radians(0)
    lon = sp.radians(0)
    el_tilt = sp.radians(0)
    az_tilt = sp.radians(0)
    solar_constant = 1.377

    def __init__(self, lat=0):
        self.lat = sp.radians(lat)

    def day_of_year(self, date):
        # '%j' gives day of year
        return int(date.strftime('%j'))

    def declination(self, date):
        day_of_year = self.day_of_year(date)
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
        az = sp.arcsin(sp.cos(dec) * sp.sin(ha) / sp.cos(self.elevation(date)))
        if (sp.cos(ha) >= (sp.tan(dec) / sp.tan(self.lat))):
            return az
        else:
            return (sp.pi - az)

    def extraterrestrial_insolation(self, date):
        day_of_year = self.day_of_year(date)
        return self.solar_constant * (1 + 0.034 * cos(2 * pi * day_of_year / 365))

    def apparent_extraterrestrial_flux(self, date):
        day_of_year = self.day_of_year(date)
        return 1160 + 75 * sin(2 * pi * (day_of_year - 275) / 365)

    def optical_depth(self, date):
        day_of_year = self.day_of_year(date)
        return 0.174 + 0.035 * sin(2 * pi * (day_of_year - 100) / 365)

    def air_mass_ratio(self, date):
        return 1 / sin(self.elevation(date))

    def direct_beam_radiation(self, date):
        return self.apparent_extraterrestrial_flux(date) * exp(- self.optical_depth(date)
                                                               * self.air_mass_ratio(date))


'''
'''
class Panel:

    def __init__(self, solar, area=1, efficiency = 0.20, el_tilt=0, az_tilt=0):
        self.area = area
        self.efficiency = efficiency
        self.el_tilt = sp.radians(el_tilt)
        self.az_tilt = sp.radians(az_tilt)
        self.solar = solar

    def incidence_angle(self, date):
        dec = self.solar.declination(date)
        el = self.solar.elevation(date)
        az = self.solar.azimuth(date)
        return arccos(cos(el) * cos(az - self.az_tilt) * sin(self.el_tilt)
                      + sin(el) * cos(self.el_tilt))

    def radiation_normal_panel(self, date):
        ins = self.solar.direct_beam_radiation(date) * cos(self.incidence_angle(date))
        if ins > 0:
            return ins
        else:
            return 0

    def power(self, date):
        return self.area * self.efficiency * self.radiation_normal_panel(date)