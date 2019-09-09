#!/usr/bin/env python
# -*- coding: utf-8 -*-

## pip install geocoder
## pip install wikimapia_api
## pip install bs4

import geocoder
import sys
import time
import re
from wikimapia_api import API, Config
# import pymapia as PyMapia
import requests
from bs4 import BeautifulSoup
# from dadata import DaDataClient

# wikimapia_key = '796F4B3D-B9D0FEF3-3AF9D2A9-1FC42D24-B3E3F1E6-8F994C3B-0791C6B9-9859F2D8'
# wikimapia_key = '796F4B3D-1590621E-3B4E9E4F-2BC105D4-E1088C2E-37E00C22-920E08F7-46DE6F34'
# wikimapia_key = '796F4B3D-8DD932C0-0AFEA1DD-02B331A0-04B61417-C4EB4C2A-20A61184-F27A23CA'
# wikimapia_key = '796F4B3D-3FE0DF02-70F67D61-B926D0E2-215932A0-1DE1609C-BE51644A-6CCF0DF2'
# wikimapia_key = '796F4B3D-DCA0F3D-688D3877-8FE44288-F1B12674-8BD217DF-B2A9E47A-C53BB1F9'
wikimapia_key = '796F4B3D-CEF5AC83-AE169E44-74EEB5EB-4B7F1F9A-4C0B4A2D-BBCFEC6B-99043F50'

# session = PyMapia.PyMapia(wikimapia_key)

API.config.key = '%s' % wikimapia_key
API.config.language = 'ru'

### dadata module work - search for okato/oktmo/fias codes
# client = DaDataClient(key = '6e165910e5449930235b28cdd82de0031a3d8802', secret = '207dd4080f4ed7ee60c54bcd160b58b812cf4265')

### DO IT
with open('/home/amuriy/Downloads/00___TODO___00/osm_np_kondr100km/22.csv', 'r') as f:
    with open ('/home/amuriy/Downloads/00___TODO___00/osm_np_kondr100km/Kal_obl_results.txt','w') as fout:
        lines = f.read().splitlines()

        region = 'Калужская область'

        for line in lines:
            rline = ('%s' + ', %s') % (line, region)
            time.sleep(2)
            g = geocoder.yandex(rline.rstrip(), maxRows=20, lang = 'ru-RU')
            for res in g:
                if (res.country is not None) and (res.country.encode('utf8') == 'Россия') and ('река' or 'улица' not in res.address.encode('utf8')):
                    if line in res.address.encode('utf8'): 
                        address = res.address.encode('utf8')
                        print('Адрес ---> %s' % address)
                        
                        # ### dadata module work - search for okato/oktmo/fias codes
                        # # client.address = '%s' % address
                        # # client.address.request()
                        # # okato = client.result.okato.encode('utf8')
                        # # oktmo = client.result.oktmo.encode('utf8')
                        # # print('Код ОКАТО ---> %s' % okato)
                        # # print('Код ОКТМО ---> %s' % oktmo)
                        # ### dadata module work - search for okato/oktmo/fias codes
                        
                        lon = res.latlng[0].encode('utf8')
                        lat = res.latlng[1].encode('utf8')
                        print('Координаты ---> %s, %s') % (lon, lat)
                        
                        time.sleep(5)
                        
                        place = API.places.nearest(lat, lon, category = 949, data_blocks='location')
                        if not place:
                            time.sleep(5)
                            place = API.places.nearest(lat, lon, category = 88, data_blocks='location')
                            
                        if place and place[0] is not None:
                            purl = [p['url'] for p in place][0]
                            url = ''.join(purl).encode('utf8')
                            print('URL на Викимапии ---> %s' % url)
                            
                            response = requests.get(url)
                            if response is not None:
                                soup = BeautifulSoup(response.text, "html.parser")
                                s = str(soup.findAll('meta')[1]).replace("'",'"')
                                start = '<meta content="'
                                end = '" name="description"/>'
                                
                                try:
                                    result = re.search('%s(.*)%s' % (start, end), s).group(1)
                                except AttributeError:
                                    result = re.search('%s(.*)%s' % (start, end), s)
                                    
                                if result is not None:
                                    print('Описание на Викимапии ---> %s' % result)
                                    pop_list = [int(s) for s in result.split() if s.isdigit()]
                                    if len(pop_list) > 1:
                                        if pop_list[1] == 2010:
                                            pop = pop_list[0]
                                        else:
                                            pop = pop_list[1]
                                    elif len(pop_list) == 1:
                                        pop = pop_list[0]

                                    print('Население ---> %s' % pop)
                                    
                                outline = ('%s, %s, %s, %s\n') % (line, lat, lon, pop)
                                print outline
                                fout.write(outline)
                        
                                print ''







