from bs4 import BeautifulSoup
from itertools import chain
from urllib.request import urlopen
from urllib.parse import urlencode
import json
import sys

NAIST = 560
TAKANOHARA = 470
TIKU_CENTER = 631
KITAIKOMA = 2610
GAKUENMAE = 132


def get_soup_from_url(url):
    return BeautifulSoup(urlopen(url).read())


def detect_time_table_url(soup):
    base_url = 'http://jikoku.narakotsu.co.jp/form/asp/'
    for frame in soup.frameset.find_all('frame'):
        if frame['name'] != 'main':
            continue
        return base_url + frame['src']


def get_departure_times(tr):
    for td in tr.find_all('td'):
        if td.find('a'):
            continue
        times = chain.from_iterable([s.split(' ') for s in td.stripped_strings])
        for t in times:
            yield int(t)


def parse_nara_kotsu_time_table(soup):
    # soup = BeautifulSoup(html)
    result = {}
    for hour, tr in enumerate(soup.table.find_all('tr')[5:-2], start=5):
        result[hour] = get_departure_times(tr)

    return result


def get_time_table_frame_url(day, from_id, to_id):
    query = [('dia', '0'),
             ('dia_date', '20150622')
             ]

    query.append(('daykind', day))
    query.append(('fromcd', from_id))
    query.append(('tocd', to_id))

    base_url = 'http://jikoku.narakotsu.co.jp/form/asp/ejhr0070.asp?'
    return base_url + urlencode(query)

#for h, ts in parse_nara_kotsu_time_table(open('main_utf8.html')).items():
#    h = h % 24
#    l = list(ts)
#    l.sort()
#    if l:
#        time_table[h].append(l)
#    print(h, l)

# detect_time_table_url(open('test_utf8.html'))


time_tables = {}

stations = [('kita', NAIST, KITAIKOMA),
            ('gaku', NAIST, GAKUENMAE),
            ('tiku', TIKU_CENTER, GAKUENMAE),
            ('taka', NAIST, TAKANOHARA)
            ]
for day in [1, 3]:
    tmp_tables = {}
    for tag, from_id, to_id in stations:
        frame_url = get_time_table_frame_url(day, from_id, to_id)
        time_table_url = detect_time_table_url(get_soup_from_url(frame_url))

        time_table = {}
        for i in range(24):
            time_table[i] = []

        for h, ts in parse_nara_kotsu_time_table(get_soup_from_url(time_table_url)).items():
            h = h % 24
            l = list(ts)
            l.sort()
            if l:
                time_table[h] = l

        tmp_tables[tag] = time_table
    day_str = "weekday" if day == 1 else "holiday"
    time_tables[day_str] = tmp_tables


json.dump(time_tables, sys.stdout, indent=4, sort_keys=True)
