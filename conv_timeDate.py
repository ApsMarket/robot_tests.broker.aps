from datetime import datetime
import time


def dt(var_date): 
    poss=var_date.find('+')-1
        
    var_date=var_date[:poss]
    
    conv_dt = datetime.strptime(var_date, '%Y-%m-%dT%H:%M:%S.%f')
    date_str = conv_dt.strftime('%Y-%m-%d %H:%M')
    return date_str



def convert_float_to_string(number):
    return format(number, '.2f')

def convert_float_to_string_f(number, frmat):
    return format(number, frmat)