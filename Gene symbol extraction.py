#Script to extract gene names from UniProtKB using API
#Requires gene names in excel file

import pandas as pd
import requests
import time

#Access API
def fetch_uniprot_symbol(gene_name):
    base_url = "https://rest.uniprot.org/uniprotkb/search"
    params = {
       "query": f'{gene_name} AND organism_id:9913', # Change the organism id as needed (current is bos taurus)
        "fields": "gene_names,protein_name",
        "format": "json",
        "size": 1
    }
    response = requests.get(base_url, params=params)

    if response.status_code == 200:
        data = response.json()
        if data['results']:
            gene_names_field = data['results'][0].get('genes', [])
            if gene_names_field:
                return gene_names_field[0].get('geneName', {}).get('value', None)
    return None

def lookup_gene_symbols(file_path):
    df = pd.read_excel(file_path, sheet_name='genenames_vechur_uniq', header=None) #specify default sheet name if only one sheet

    #error prevention and debug
    # Diagnostic Print Statements 
    print("DataFrame after reading with header=None:")
    print(df.head())
    print(f"Number of columns detected: {df.shape[1]}")

    #Ignore if only one col is in excel file
    # If the dataframe unexpectedly has more than 1 column,
    # explicitly select the first column (index 0)
    if df.shape[1] > 1:
        print("Warning: More than one column detected. Using only the first column.")
        df = df.iloc[:, [0]] # Selects all rows and only the first column

    df.columns = ['Gene']  # Manually assign column name (as in the excel file)

    symbols = []
    for gene in df['Gene']:
        # Ensure gene is not NaN before attempting to fetch symbol
        if pd.notna(gene):
            symbol = fetch_uniprot_symbol(gene)
            print(f"Gene: {gene} -> Symbol: {symbol}")
            symbols.append(symbol)
            time.sleep(1)  # pause to avoid rate limiting
        else:
            print(f"Skipping NaN gene value.")
            symbols.append(None) # Append None for NaN values (if no result on UniProt)

    df['Gene Symbol'] = symbols
    return df

# input
input_file = 'file path'

# Save the result to a new Excel file
output_df.to_excel('file path out', index=False)
