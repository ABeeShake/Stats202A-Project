def scrape_coords(url):
    
    from bs4 import BeautifulSoup
    import requests
    import pandas as pd
    
    page = requests.get(url).text
    soup = BeautifulSoup(page, 'html.parser')
    
    table = soup.find_all('table')[0]
    
    coords = pd.read_html(str(table))[0]
    
    results = coords.loc[:,['FIPS','Latitude','Longitude']]
    
    results['FIPS'] = '0'+results['FIPS'].astype(str)
    
    results['Longitude'] = results['Longitude'].str[:-1]
    results['Latitude'] = results['Latitude'].str[:-1]
    
    return results
    
def main():
    
    import argparse
    
    parser = argparse.ArgumentParser()
    
    parser.add_argument("-p", "--page_name",help="wiki page to scrape",required=True)
    parser.add_argument('-o','--output_name',help='output file name',required=True)
    
    args = parser.parse_args()
    
    results = scrape_coords(args.page_name)
    
    results.to_csv(f'{args.output_name}.csv',index=False)
    
if __name__ == "__main__":
    
    main()