from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import json
import requests
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
def netfetch_data(url, s):
    header = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'}
    response = requests.get(url, headers = header)#headers是關鍵字
    soup = BeautifulSoup(response.text, "html.parser")
    names = soup.find_all("div", class_="main_con js-product-block")
    for name in names:
        data = {}
        data["brand"] = "net"
        data["gender"] = s
        cloth_name = name.find("div", class_="main_name")
        cloth_name = cloth_name.a.text
        data["clothname"] = cloth_name
        data["category"] = det(cloth_name)
        if name.find("span", class_="price_orginal"):
            price = name.find("span", class_="price_orginal")
            price = price.text
            data["price"] = price
        else:
            price = name.find("span", class_="price_special")
            price = price.text
            data["price"] = price
        img_src = name.find("div", class_="main_img").find("img", class_="js-product-img")
        img_src = img_src.get("src") 
        data["img_src"] = img_src
        buy_href = name.find("div", class_="main_img").a.get("href")
        data["buy_href"] = buy_href
        data_list.append(data)
    next_page = soup.find("div", class_="yahoo").find("a", class_="number_line_a page_next")
    if next_page:
        next_url = next_page.get("href")
        print("正在爬取:{}".format(next_url))
        netfetch_data(next_url, s)
def net(): 
    url = "https://www.net-fashion.net/category/2106"
    s = "男"
    netfetch_data(url, s)
    url = "https://www.net-fashion.net/category/2105"
    s = "女"
    netfetch_data(url, s)
def ham():
    options = Options()
    options.add_argument("--disable-gpu")
    options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36")
    options.add_argument("--disable-blink-features=AutomationControlled")
    driver = webdriver.Chrome(options=options)

    urls = [
        "https://www2.hm.com/zh_asia3/men/shop-by-product/view-all.html?sort=stock&image-size=small&image=model&offset=0&page-size=3454",
        "https://www2.hm.com/zh_asia3/ladies/shop-by-product/view-all.html?sort=stock&image-size=small&image=model&offset=0&page-size=10000"
    ]

    for url in urls:
        gender = "男" if "men" in url else "女"
        try:
            driver.get(url)
            WebDriverWait(driver, 30).until(
                EC.presence_of_all_elements_located((By.CLASS_NAME, "product-item"))
            )
            soup = BeautifulSoup(driver.page_source, "html.parser")
            names = soup.select("ul.products-listing li.product-item")
            for name in names:
                data = {}
                try:
                    cloth_name = name.find("h3", class_="item-heading").text.strip()
                    price = name.find("span", class_="price regular").text.strip()
                    img_src = name.find("div", class_="image-container").find("img").get("data-altimage")
                    buy_href = name.find("a", class_="item-link").get("href")
                    data["brand"] = "H&M"
                    data["gender"] = gender
                    data["clothname"] = cloth_name
                    data["category"] = det(cloth_name)
                    data["price"] = price
                    data["img_src"] = img_src
                    data["buy_href"] = "https://www2.hm.com" + buy_href
                    data_list.append(data)
                except AttributeError:
                    continue
        except Exception as e:
            print(f"錯誤: {e}")

    driver.quit()
def percentfetch_data(url, s):
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
def percent():
    url = "https://www.50-shop.com/Shop/itemList.aspx?m=5&p=401&smfp=0"
    s = "男"
    percentfetch_data(url, s)
    url = "https://www.50-shop.com/Shop/itemList.aspx?m=6&p=707&smfp=0"
    s = "女"
    percentfetch_data(url, s)
def lativfetch_data(url, s):
    header = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'}
    response = requests.get(url, headers = header)#headers是關鍵字
    soup = BeautifulSoup(response.text, "html.parser")
    names = soup.find_all("li", class_="row_before")
    for name in names:
        data = {}
        data["brand"] = "lativ"
        data["gender"] = s
        cloth_name = name.find("div", class_="productname")
        cloth_name = cloth_name.text
        data["clothname"] = cloth_name
        data["category"] = det(cloth_name)
        price = name.span
        price = price.text
        price = re.search(r"NT\$\d+", price).group()
        data["price"] = price
        img_src = name.find("a", class_="imgd").img.get("data-outfitpic")
        img_src = str(img_src).split(',')[0]
        data["img_src"] = "https://s1.lativ.com.tw"+str(img_src)
        buy_href = name.find("a", class_="imgd").get("href")
        data["buy_href"] = "https://www.lativ.com.tw/"+buy_href
        if data["img_src"] != "https://s1.lativ.com.twNone" :
            data_list.append(data)
def lativ():
    url = [["https://www.lativ.com.tw/MEN", "男"],["https://www.lativ.com.tw/WOMEN", "女"]]
    for i in url:
        s = i[1]
        header = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'}
        response = requests.get(i[0], headers = header)#headers是關鍵字
        soup = BeautifulSoup(response.text, "html.parser")
        categories = soup.find_all("ul", class_="sale_category")
        for category in categories:
            print(categories)
            li_hrefs = category.find_all("li")
            for li_href in li_hrefs:
                i[0] = li_href.a.get("href")
                print(i[0])
                lativfetch_data("https://www.lativ.com.tw"+i[0], s)

net()
ham()
percent()
lativ()

with open("ALL.json", "w", encoding="utf-8") as file:
    json.dump(data_list, file, ensure_ascii=False, indent=4)