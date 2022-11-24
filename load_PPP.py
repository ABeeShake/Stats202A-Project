def add_county(data):
    
    import pandas as pd
    
    counties = pd.read_csv("./ZIP-COUNTY-FIPS_2017-06.csv", dtype='object')
    
    data['BorrowerZip'] = data['BorrowerZip'].str[:5]
    
    data = data.merge(counties, left_on = ['BorrowerState','BorrowerZip'], right_on = ['STATE','ZIP'])
    
    data.drop(['ZIP','COUNTYNAME','STATE',
               'CLASSFP','Gender','Veteran',
               'NonProfit','Race','Ethnicity'],axis=1,inplace=True)
    
    data.rename(columns={'STCOUNTYFP': 'BorrowerFIPS'},inplace=True)
    
    return data

def add_coords(data):
    
    import pandas as pd

    coords = pd.read_csv('./county_to_coords.csv',dtype='object')
    
    data = data.merge(coords,left_on=['BorrowerFIPS'], right_on=['FIPS'])
    
    data.drop('FIPS',axis=1,inplace=True)
    
    return data


def load_PPP(file_path):

    import pandas as pd
    import numpy as np
        
    data = pd.read_csv(file_path)
    
    data = data.loc[~(data['BorrowerCity'].isin(['','N/A',np.nan])) & ~(data['BorrowerState'].isin(['','N/A',np.nan])),]
    
    data = add_county(data)
    
    data = add_coords(data)
    
    return data

def main():
    
    import argparse
    
    parser = argparse.ArgumentParser()
    
    parser.add_argument("-f", "--file_name",help="file to load",required=True)
    parser.add_argument('-o','--output_name',help='output file name',required=True)
    
    args = parser.parse_args()
    
    PPP_loans = load_PPP(args.file_name)
    
    PPP_loans.to_csv(f'{args.output_name}.csv', index=False)


if __name__ == "__main__":
    
    main()