from datetime import datetime
import time


def dt(var_date): 
    poss=var_date.find('+')-1
        
    var_date=var_date[:poss]
    
    conv_dt = datetime.strptime(var_date, '%Y-%m-%dT%H:%M:%S.%f')
    date_str = conv_dt.strftime('%d.%m.%Y %H:%M')
    return date_str