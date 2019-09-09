#!/usr/bin/env python
# -*- coding: utf-8 -*-

## pip install psycopg2
## pip install geocoder
## pip install wikimapia_api
## pip install bs4
## pip install wikipedia
## pip install sparqlwrapper
## pip install wptools


import psycopg2
import geocoder
import sys
import time
import re
import requests
# from bs4 import BeautifulSoup
import wikipedia
from SPARQLWrapper import SPARQLWrapper, JSON
# from dadata import DaDataClient

## functions
def get_qnumber(wikiarticle, wikisite):
    resp = requests.get('https://www.wikidata.org/w/api.php', {
        'action': 'wbgetentities',
        'titles': wikiarticle,
        'sites': wikisite,
        'props': '',
        'format': 'json'
    }).json()
    return list(resp['entities'])[0]


def place_wikidata_info(name, lon, lat):
    uname = unicode(name, "utf-8")
    wikipedia.set_lang("ru")
    search = wikipedia.geosearch(lon,lat)
    sparql = SPARQLWrapper("https://query.wikidata.org/sparql", agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36')
    if uname in [x for x in search]:
        qnumber = get_qnumber(wikiarticle="%s" % name, wikisite="ruwiki")
        query = """
        SELECT DISTINCT ?item ?itemLabel ?population ?okato_id ?oktmo_id ?locality WHERE {
        FILTER(?item IN(wd:%s))
        OPTIONAL { ?item wdt:P1082 ?population. }
        OPTIONAL { ?item wdt:P721 ?okato_id. }
        OPTIONAL { ?item wdt:P764 ?oktmo_id. }
        OPTIONAL { ?item wdt:P131 ?locality. }
        SERVICE wikibase:label { bd:serviceParam wikibase:language "ru". }
        }
        """
        query2 = query % qnumber
        sparql.setQuery(query2)
        sparql.setReturnFormat(JSON)
        results = sparql.query().convert()
        locality = results[u'results'][u'bindings'][0][u'locality'][u'value']
        item = results[u'results'][u'bindings'][0][u'item'][u'value']
        okato_id = results[u'results'][u'bindings'][0][u'okato_id'][u'value']
        oktmo_id = results[u'results'][u'bindings'][0][u'oktmo_id'][u'value']
        population = results[u'results'][u'bindings'][0][u'population'][u'value']
        d = dict()
        d['locality'] = '%s' % locality
        d['item'] = '%s' % item
        d['okato_id'] = '%s' % okato_id
        d['oktmo_id'] = '%s' % oktmo_id
        d['population'] = '%s' % population
        return d
    
    
# res = place_wikidata_info('Балабаново',55.182545653891,36.6617494478658)
# print res


def places_list_db(host, db, user, pwd):
    try:
        conn = psycopg2.connect(host = host, database = db, user = user, password = pwd)
    except psycopg2.OperationalError as e:
        print('Unable to connect!\n{0}').format(e)
        sys.exit(1)
    else:
        cursor = conn.cursor()
        # cursor.execute("select name, st_astext(st_centroid(st_transform(way, 4326))) from planet_osm_polygon where place in ('city','town','village','hamlet','isolated_dwelling') order by name limit 10;")
        cursor.execute("select name, st_astext(st_centroid(st_transform(way, 4326))) from planet_osm_polygon where place in ('city','town') order by name limit 5;")
        res = cursor.fetchall()
        cursor.close()
        conn.close()
        return res


def place_geocoder_info(lon, lat):
    time.sleep(2)
    g = geocoder.yandex([lon,lat], kind = 'locality', method='reverse', lang = 'ru-RU')
    addr = g.address.encode('utf8')
    ## добавить проверку на полноту адреса; если нет района или муниц. образования, запускаем обратный геокодинг Nominatim
    if region in addr:
        return g.address.encode('utf8')


def place_dadata_info(address):
    # client = DaDataClient(key = '%s' % key, secret = '%s' % secret)
    client.address = '%s' % address
    client.address.request()
    okato = client.result.okato.encode('utf8')
    oktmo = client.result.oktmo.encode('utf8')
    print('Код ОКАТО ---> %s' % okato)
    print('Код ОКТМО ---> %s' % oktmo)
    ## TODO: print FIAS codes !!! #
    

def place_wikimapia_info(lon, lat):
    # API.config.key = '%s' % wikimapia_key
    # API.config.language = 'ru'    
    time.sleep(5)
    place = API.places.nearest(lat, lon, category = 949, data_blocks='location')    
    if place[0] is None:
        time.sleep(5)
        place = API.places.nearest(lat, lon, category = 88, data_blocks='location')    
        if place and place[0] is not None:
            purl = [p['url'] for p in place][0]
            url = ''.join(purl).encode('utf8')
            print('URL на Викимапии ---> %s' % url)
            response = requests.get(url)
            if (response is not None) and (response.status_code == 200):
                soup = BeautifulSoup(response.text, "html.parser")                
                for i in soup.find_all('meta'):
                    res = re.search('Население(.*)перепись', str(i).replace('\n',' '))
                    if res:
                        wminfo = res.group(0)                  
                    if res is None:
                        res = re.search('население(.*)перепись', str(i).replace('\n',' '))
                        wminfo = res.group(0)
                    print wminfo
                    if wminfo is not None:
                        print('Описание на Викимапии ---> %s' % wminfo)
                        pop_list = [int(s) for s in wminfo.split() if s.isdigit()]
                        if len(pop_list) > 1:
                            if pop_list[1] == 2010:
                                pop = pop_list[0]
                            else:
                                pop = pop_list[1]
                        elif len(pop_list) == 1:
                            pop = pop_list[0]                            
                        print('Население ---> %s' % pop)    
    
    



places = places_list_db('localhost', 'osm_ru_klu', 'user', '')

for line in places:
    name = line[0]
    latlon = line[1].replace('POINT(','').replace(')','')
    lat = latlon.split(' ')[0]
    lon = latlon.split(' ')[1]
    lonlat = '%s,%s' % (lon, lat)
    
    print name
    print lonlat
    place_geocoder_info(lon,lat)
    
    



# region = 'Калужская' 

#     for line in res:
#         name = line[0]
#         latlon = line[1].replace('POINT(','').replace(')','')
#         lat = latlon.split(' ')[0]
#         lon = latlon.split(' ')[1]
#         lonlat = '%s,%s' % (lon, lat)
        
#         time.sleep(2)
#         g = geocoder.yandex([lon,lat], kind = 'locality', method='reverse', lang = 'ru-RU')
#         addr = g.address.encode('utf8')
#         if region in addr:
#             print name
#             print lonlat
#             print g.address.encode('utf8')
            
#             time.sleep(5)
#             place = API.places.nearest(lat, lon, category = 949, data_blocks='location')

#             if place[0] is None:
#                 time.sleep(5)
#                 place = API.places.nearest(lat, lon, category = 88, data_blocks='location')

#             if place and place[0] is not None:
#                 purl = [p['url'] for p in place][0]
#                 url = ''.join(purl).encode('utf8')
#                 print('URL на Викимапии ---> %s' % url)
                
#                 response = requests.get(url)
#                 if (response is not None) and (response.status_code == 200):
#                     soup = BeautifulSoup(response.text, "html.parser")

#                     for i in soup.find_all('meta'):
#                         res = re.search('Население(.*)перепись', str(i).replace('\n',' '))
#                         if res:
#                             wminfo = res.group(0)                        
#                         if res is None:
#                             res = re.search('население(.*)перепись', str(i).replace('\n',' '))
#                             wminfo = res.group(0)

#                         print wminfo
                        
                        
                    #     if wminfo is not None:
                    #         print('Описание на Викимапии ---> %s' % wminfo)
                    #         pop_list = [int(s) for s in wminfo.split() if s.isdigit()]
                    #         if len(pop_list) > 1:
                    #             if pop_list[1] == 2010:
                    #                 pop = pop_list[0]
                    #             else:
                    #                 pop = pop_list[1]
                    #         elif len(pop_list) == 1:
                    #             pop = pop_list[0]
                                    
                    #         print('Население ---> %s' % pop)
                    # print ''                    


                    


                    # s = str(soup.findAll('meta')[1]).replace("'",'"').replace('\n',' ')
                    # if 'население' or 'Население' or 'перепись' in s:
                    #     start = '<meta content="'
                    #     end = '"description"/>'
                    #     try:
                    #         wminfo = re.search('%s(.*)%s' % (start, end), s).group(1)
                    #     except AttributeError:
                    #         wminfo = re.search('%s(.*)%s' % (start, end), s)
                        
                    #     if wminfo is not None:
                    #         print('Описание на Викимапии ---> %s' % wminfo)
                    #         pop_list = [int(s) for s in wminfo.split() if s.isdigit()]
                    #         if len(pop_list) > 1:
                    #             if pop_list[1] == 2010:
                    #                 pop = pop_list[0]
                    #             else:
                    #                 pop = pop_list[1]
                    #         elif len(pop_list) == 1:
                    #             pop = pop_list[0]
                                
                    #         print('Население ---> %s' % pop)
                    #     print ''
                        
                    # else:
                        
                    #     for i in soup.find_all('meta'):
                    #         res = re.search('Население(.*)перепись', str(i))
                    #         if res is None:
                    #             res = re.search('население(.*)перепись', str(i))
                    #         if res:
                    #             wminfo = res.group(0)

                    #         if wminfo is not None:
                    #             print('Описание на Викимапии ---> %s' % wminfo)
                    #             pop_list = [int(s) for s in wminfo.split() if s.isdigit()]
                    #             if len(pop_list) > 1:
                    #                 if pop_list[1] == 2010:
                    #                     pop = pop_list[0]
                    #                 else:
                    #                     pop = pop_list[1]
                    #             elif len(pop_list) == 1:
                    #                 pop = pop_list[0]
                                    
                    #             print('Население ---> %s' % pop)
                    #     print ''

                        
                        


                


    

# def get_wikimapia_info











# ### DO IT
# with open('/home/amuriy/Downloads/00___TODO___00/osm_np_kondr100km/22.csv', 'r') as f:
#     with open ('/home/amuriy/Downloads/00___TODO___00/osm_np_kondr100km/Kal_obl_results.txt','w') as fout:
#         lines = f.read().splitlines()

#         region = 'Калужская область'

#         for line in lines:
#             rline = ('%s' + ', %s') % (line, region)

#             print rline
            
#             time.sleep(2)
#             g = geocoder.yandex(rline.rstrip(), maxRows=20, lang = 'ru-RU')
#             for res in g:
#                 if (res.country is not None) and (res.country.encode('utf8') == 'Россия') and ('река' or 'улица' not in res.address.encode('utf8')):
#                     if line in res.address.encode('utf8'): 
#                         address = res.address.encode('utf8')
#                         print('Адрес ---> %s' % address)
                        
#                         lon = res.latlng[0].encode('utf8')
#                         lat = res.latlng[1].encode('utf8')
#                         print('Координаты ---> %s, %s') % (lon, lat)
                        
#                         time.sleep(3)
#                         url_search = 'http://api.wikimapia.org/?function=search&key=' + wikimapia_key + '&q=' + line + '&lon=' + lon + '&lat=' + lat + '&disable=location,polygon&language=ru'

#                         print url_search
                        
#                         response = requests.get(url_search)
#                         soup = BeautifulSoup(response.text, "html.parser")
#                         for place in soup.findAll('place'):
#                             s = str(place)
#                             start = '<name>'
#                             end = '</name>'
#                             fname = re.search('%s(.*)%s' % (start, end), s).group(1)
#                             if fname == line:
#                                 start = 'id="'
#                                 end = '">'
#                                 fid = re.search('%s(.*)%s' % (start, end), s).group(1)

#                                 print fid
                                
#                                 time.sleep(3)
#                                 url_info = 'http://api.wikimapia.org/?function=place.getbyid&key=' + wikimapia_key + '&id=' + fid + '&data_blocks=main'

#                                 print url_info
                                
#                                 response = requests.get(url_info)
#                                 soup = BeautifulSoup(response.text, "html.parser")
#                                 result = str(soup.findAll('description')[0])
#                                 if result is not None:
#                                     pop_list = [int(s) for s in result.split() if s.isdigit()]
#                                     if len(pop_list) > 1:
#                                         if pop_list[1] == 2010:
#                                             pop = pop_list[0]
#                                         else:
#                                             pop = pop_list[1]
#                                     elif len(pop_list) == 1:
#                                         pop = pop_list[0]

#                                     print pop
                                
#                             # outline = ('%s, %s, %s, %s\n') % (line, lat, lon, pop)
#                             # print outline
#                             # fout.write(outline)
                        
#                             # print ''

#                             # sys.exit(1)













