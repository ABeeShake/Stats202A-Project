def add_coords(data,sample=1/100):
    
    from geopy.geocoders import Nominatim
    from geopy.extra.rate_limiter import RateLimiter
    
    shuffled = data.sample(frac=sample)
    
    geolocator = Nominatim(user_agent = 'UCLA stats 202 Project',timeout = 10)
    
    geocode = RateLimiter(geolocator.geocode, min_delay_seconds = 1)
    
    locations = shuffled['full_address'].apply(geocode)
    
    shuffled['lat'] = locations[1][0]
    shuffled['long'] = locations[1][1]
    
    shuffled = shuffled[(shuffled.lat.notnull()) & (shuffled.long.notnull())]
    
    return shuffled

def make_map_subset(PPP_file):
    
    import pandas as pd
    
    PPP_loans = pd.read_csv(f'./{PPP_file}.csv')
    
    PPP_loans['full_address'] = (PPP_loans['BorrowerAddress'] + 
                                 ',' + 
                                 PPP_loans['BorrowerCity'] +
                                 ',' + 
                                 PPP_loans['BorrowerState'])
    
    map_subset = add_coords(PPP_loans)
    
    map_subset['lat'] = map_subset['coords'].str[1].str[0]
    map_subset['long'] = map_subset['coords'].str[1].str[1]
    
    map_subset = map_subset[(map_subset.lat.notnull()) & (map_subset.long.notnull())]
    
    return map_subset

def main():
    
    import argparse
    
    parser = argparse.ArgumentParser()
    
    parser.add_argument("-f", "--file_name",help="file to load",required=True)
    parser.add_argument('-o','--output_name',help='output file name',required=True)
    
    args = parser.parse_args()
    
    map_subset = make_map_subset(args.file_name)
    
    map_subset.to_csv(f'{args.output_name}.csv', index=False)
    

if __name__ == "__main__":
    
    main()    