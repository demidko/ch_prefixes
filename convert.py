# coding=utf8
import sys, csv
from urllib.parse import urlparse, parse_qs

def convert(input):
    parts = input.split(" ")
    url = parts[9]
    ring = unquote(parts[19])
    user_id = unquote(parts[18])
    date_time = parts[0]

    # Приводим дату к формату YYYY-MM-DD HH:mm:ss
    date_time = date_time[0:10] + " " + date_time[11:19]

    if ring == "-":
        ring = None

    url_parts = urlparse(url)
    query = parse_qs(url_parts.query)
    if 'action' not in query:
        return None
    action = query['action'][0]

    user_id = int(user_id, 16) if len(user_id) > 0 else 0

    value = 1.0
    if 'keyName' in query and query['keyName'][0].isdigit():
        value = float(query['keyName'][0])
    
    return [date_time, user_id, ring, action, value, tuple_from_dict(query)]

def tuple_from_dict(dict):
    '''
    Формирует строковое представление tuple для Clickhouse из словаря:
    На входе: {'one': '1', 'two': '2'}
    На выходе (строка): [('one', '1'),('two','2')]
    '''

    del dict['_']
    del dict['action']

    tuples = ["('{}','{}')".format(name, values[0]) for name, values in dict.items()]
    return "[" + ",".join(tuples) + "]"

def unquote(input):
    if len(input) >= 2 and input[0] == '"' and input[-1] == '"':
        return input[1:-1]
    else:
        return input

if __name__ == "__main__":
    convert()