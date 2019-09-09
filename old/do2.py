#!/usr/bin/env python
# -*- coding: utf-8 -*-

## pip install psycopg2
## pip install geocoder
## pip install wikimapia_api
## pip install bs4

import psycopg2
import geocoder
import sys
import time
import re
import requests
from bs4 import BeautifulSoup

# wikimapia_key = '796F4B3D-B9D0FEF3-3AF9D2A9-1FC42D24-B3E3F1E6-8F994C3B-0791C6B9-9859F2D8'
# wikimapia_key = '796F4B3D-1590621E-3B4E9E4F-2BC105D4-E1088C2E-37E00C22-920E08F7-46DE6F34'
# wikimapia_key = '796F4B3D-8DD932C0-0AFEA1DD-02B331A0-04B61417-C4EB4C2A-20A61184-F27A23CA'
# wikimapia_key = '796F4B3D-3FE0DF02-70F67D61-B926D0E2-215932A0-1DE1609C-BE51644A-6CCF0DF2'
wikimapia_key = '796F4B3D-DCA0F3D-688D3877-8FE44288-F1B12674-8BD217DF-B2A9E47A-C53BB1F9'

### DO IT
with open('/home/amuriy/Downloads/00___TODO___00/osm_np_kondr100km/22.csv', 'r') as f:
    with open ('/home/amuriy/Downloads/00___TODO___00/osm_np_kondr100km/Kal_obl_results.txt','w') as fout:
        lines = f.read().splitlines()

        region = 'Калужская область'

        for line in lines:
            rline = ('%s' + ', %s') % (line, region)

            print rline
            
            time.sleep(2)
            g = geocoder.yandex(rline.rstrip(), maxRows=20, lang = 'ru-RU')
            for res in g:
                if (res.country is not None) and (res.country.encode('utf8') == 'Россия') and ('река' or 'улица' not in res.address.encode('utf8')):
                    if line in res.address.encode('utf8'): 
                        address = res.address.encode('utf8')
                        print('Адрес ---> %s' % address)
                        
                        lon = res.latlng[0].encode('utf8')
                        lat = res.latlng[1].encode('utf8')
                        print('Координаты ---> %s, %s') % (lon, lat)
                        
                        time.sleep(3)
                        url_search = 'http://api.wikimapia.org/?function=search&key=' + wikimapia_key + '&q=' + line + '&lon=' + lon + '&lat=' + lat + '&disable=location,polygon&language=ru'

                        print url_search
                        
                        response = requests.get(url_search)
                        soup = BeautifulSoup(response.text, "html.parser")
                        for place in soup.findAll('place'):
                            s = str(place)
                            start = '<name>'
                            end = '</name>'
                            fname = re.search('%s(.*)%s' % (start, end), s).group(1)
                            if fname == line:
                                start = 'id="'
                                end = '">'
                                fid = re.search('%s(.*)%s' % (start, end), s).group(1)

                                print fid
                                
                                time.sleep(3)
                                url_info = 'http://api.wikimapia.org/?function=place.getbyid&key=' + wikimapia_key + '&id=' + fid + '&data_blocks=main'

                                print url_info
                                
                                response = requests.get(url_info)
                                soup = BeautifulSoup(response.text, "html.parser")
                                result = str(soup.findAll('description')[0])
                                if result is not None:
                                    pop_list = [int(s) for s in result.split() if s.isdigit()]
                                    if len(pop_list) > 1:
                                        if pop_list[1] == 2010:
                                            pop = pop_list[0]
                                        else:
                                            pop = pop_list[1]
                                    elif len(pop_list) == 1:
                                        pop = pop_list[0]

                                    print pop
                                
                            # outline = ('%s, %s, %s, %s\n') % (line, lat, lon, pop)
                            # print outline
                            # fout.write(outline)
                        
                            # print ''

                            # sys.exit(1)








# select name, population, st_astext(st_centroid(st_transform(way, 4326))) from planet_osm_polygon where place in ('city','town','village','hamlet','isolated_dwelling') order by name ;
