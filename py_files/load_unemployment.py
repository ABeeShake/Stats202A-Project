def load_unemployment(file):
    
    import pandas as pd
    
    data = pd.read_csv(file)
    
    results = pd.DataFrame()
    
    results['BorrowerFIPS'] = data['Region Code']
    
    for i in range(2019,2022):
         
       results[f'{i}_q1'] = data[[f'{i}-{j:02d}-01' for j in range(1,4)]].mean(axis = 1)
       
       results[f'{i}_q2'] = data[[f'{i}-{j:02d}-01' for j in range(4,7)]].mean(axis = 1)
       
       results[f'{i}_q3'] = data[[f'{i}-{j:02d}-01' for j in range(7,10)]].mean(axis = 1)
       
       results[f'{i}_q4'] = data[[f'{i}-{j:02d}-01' for j in range(10,13)]].mean(axis = 1)
       
       results[f'{i}_q234_avg'] = results[[f'{i}_q{j}' for j in range(2,5)]].mean(axis = 1)
       
       results[f'{i}_q234-q1'] = results[f'{i}_q234_avg'] - results[f'{i}_q1']
    
    return results
    
def main():
    
    import argparse
    
    parser = argparse.ArgumentParser()
    
    parser.add_argument("-f", "--file_name",help="file to load",required=True)
    parser.add_argument('-o','--output_name',help='output file name',required=True)
    
    args = parser.parse_args()
    
    unr = load_unemployment(args.file_name)
    
    unr.to_csv(f'{args.output_name}.csv', index=False)
    
if __name__ == "__main__":
    
    main()