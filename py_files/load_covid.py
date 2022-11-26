def load_covid(file):
    
    import pandas as pd
    
    data = pd.read_csv(file, dtype={"fips":str})
    
    data = data.loc[(data['date'].str.startswith("2020")) & (~data['fips'].isna()),['date','fips','cases','deaths']]
    
    cases = data.groupby('fips').sum().reset_index()
    
    return cases

def main():
    
    import argparse
    
    parser = argparse.ArgumentParser()
    
    parser.add_argument("-f", "--file_name",help="file to load",required=True)
    parser.add_argument('-o','--output_name',help='output file name',required=True)
    
    args = parser.parse_args()
    
    cases = load_covid(args.file_name)
    
    cases.to_csv(f'{args.output_name}.csv', index=False)
    
if __name__ == "__main__":
    
    main()