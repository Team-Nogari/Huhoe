import requests
from bs4 import BeautifulSoup as bs

page = requests.get("https://www.bithumb.com/")
soup = bs(page.text, "html.parser")

elements = soup.select('div.sort_coin_box > p > a.GA_MAIN_ASSET_COIN_LIST > span')

s = set()

for element in enumerate(elements):
    a = str(element[1]).replace('<span class="sort_coin small_txt" data-sorting=', '')
    b = a.replace('/KRW</span>', '" = ')
    c = b.replace('/BTC</span>', '" = ')
    cutIndex = c.find('>') + 1
    d = '"{}{}";'.format(c[cutIndex:], c[:cutIndex].replace('">', ''))
    s.add(d)

for str in s:
    print(str)