from bs4 import BeautifulSoup
import requests
import pandas as pd
import requests
import os.path
import openpyxl
from openpyxl import load_workbook
from openpyxl.utils.dataframe import dataframe_to_rows

list_names = ['Наименование на рус. языке', 'БИН участника', 'ФИО', 'ИИН', ]
class Company:
    def __init__(self, title, bin, name, iin, address):
        self.title = title
        self.bin = bin
        self.name = name
        self.iin = iin
        self.address = address
url = 'https://www.goszakup.gov.kz/ru/registry/rqc'


def extract_links_from_table(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    table = soup.find('table', class_='table-bordered')
    links = []
    if table:
        for row in table.find_all('tr'):
            link = row.find('a', href=True)
            if link and link['href']:
                links.append(link['href'])
    return links

def clean_data(data,list):
    new_data = {}
    for key, value in data.items():
        if key in list:
            new_data[key] = value[0]
    return new_data 

def extract_info(url,list):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    tables = soup.find_all('table', class_='table-striped')
    if tables:
        data = {}
        for table in tables:
            for row in table.find_all('tr'):
                th = row.find('th')
                td = row.find('td')
                if th and td:
                    key = th.get_text(strip=True)
                    value = td.get_text(strip=True)
                    data[key] =[value]
        new_data = clean_data(data, list)

        return new_data
    else:
        return None


    
def export_to_excel(data, filename='output.xlsx'):
    if os.path.isfile(filename):
        # If the file already exists, load it
        df_existing = pd.read_excel(filename)
        # Append new data to the existing DataFrame
        df = pd.concat([df_existing, pd.DataFrame(data)], ignore_index=True)
    else:
        # If the file doesn't exist, create a new DataFrame
        df = pd.DataFrame(data)

    # Save the DataFrame to Excel
    df.to_excel(filename, index=False)

list_links = extract_links_from_table(url)

df_list = []

for links in list_links:
    data = extract_info(links,list_names)
    df = pd.DataFrame([data])
    df_list.append(df)
df_all=pd.concat(df_list, ignore_index=True)
df_wo_dup = df_all.drop_duplicates()
export_to_excel(df_wo_dup,filename='output.xlsx')
