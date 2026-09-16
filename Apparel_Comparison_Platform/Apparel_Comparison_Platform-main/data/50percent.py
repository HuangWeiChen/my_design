import requests
from bs4 import BeautifulSoup
import json
import pandas as pd
import os
import time
import re

data_list = []

def det(cloth_name):
    if "牛仔褲" in cloth_name:
        return "牛仔褲"
    if "運動褲" in cloth_name:
        return "運動褲"
    if "西裝褲" in cloth_name:
        return "西裝褲"
    if "休閒褲" in cloth_name:
        return "休閒褲"
    if "短褲" in cloth_name:
        return "短褲"
    if "褲" in cloth_name:
        return "褲子"
    if "polo" in cloth_name:
        return "polo系列"
    if "T恤" in cloth_name:
        return "T恤"
    if "帽T" in cloth_name:
        return "帽T"
    if "針織衫" in cloth_name:
        return "針織衫"
    if "襯衫" in cloth_name:
        return "襯衫"
    if "大衣" in cloth_name:
        return "大衣"
    if "外套" in cloth_name:
        return "外套"
    if "背心" in cloth_name:
        return "背心"
    if "洋裝" in cloth_name:
        return "洋裝"
    if "裙" in cloth_name:
        return "裙子"
    if "衣" in cloth_name:
        return "上衣"
    if "襪" in cloth_name:
        return "襪子"
    return "其他"

def fetch_data(url):
    header = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'}
    response = requests.get(url, headers = header)#headers是關鍵字
    soup = BeautifulSoup(response.text, "html.parser")
    names = soup.find_all("div", class_="products_list fbNo1")
    for name in names:
        data = {}
        data["brand"] = "50percent"
        data["gender"] = s
        cloth_name = name.find("div", class_="size_option_wrapper")
        cloth_name = cloth_name.text
        cloth_name = re.sub(r"NT\.\d+", "", cloth_name)
        data["clothname"] = cloth_name
        data["category"] = det(cloth_name)
        price = name.find("div", class_="size_option_wrapper")
        price = price.span.text
        data["price"] = price
        img_src = (name.a.img)
        img_src = img_src.get("src") 
        data["img_src"] = img_src
        buy_href = name.a.get("href")
        data["buy_href"] = "https://www.50-shop.com/Shop/"+buy_href
        data_list.append(data)
   

url = "https://www.50-shop.com/Shop/itemList.aspx?m=5&p=401&smfp=0"
s = "男"
fetch_data(url)
url = "https://www.50-shop.com/Shop/itemList.aspx?m=6&p=707&smfp=0"
s = "女"
fetch_data(url)

with open("50percent.json", "w", encoding = "utf-8") as file:
    json.dump(data_list, file, ensure_ascii=False, indent=4)