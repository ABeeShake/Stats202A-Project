def load_PPP(file_path):
    import pandas as pd
    
    data = pd.read_csv(file_path)
    
    data = data.loc[~(data['BorrowerCity'].isin(['','N/A'])) & ~(data['BorrowerState'].isin(['','N/A'])),]
    
    return data

def geocode_addresses(data):
    
    addresses = data["BorrowerCity"]
    
    return data


if __name__ == "__main__":
    
    import pandas as pd
    import geopandas as gpd
    import geopy as gy
    
    file_path = './public_150k_plus_220930.csv'
    
    data = load_PPP(file_path)
    
    data = geocode_addresses(data)
    
    print(data.head())