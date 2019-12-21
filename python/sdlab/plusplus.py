import json
from redis import ConnectionPool
from redis.client import Redis
from settings import REDIS_URL, SLACK_API_TOKEN
from slack import WebClient

REDIS_NAMESPACE = 'plusplus'
keys = {
    'score': 'score',
    'reason': 'score:reason',
    'last': 'last',
    'log': 'log'
}

redis_pool = ConnectionPool.from_url(REDIS_URL)

for k, v in keys.items():
    keys[k] = ":".join((REDIS_NAMESPACE, v))


def pretty_dump(data):
    print(json.dumps(data, indent=2, ensure_ascii=False))


def convert_hubot_brain_to_bolt_redis(brain):
    plusplus_data = brain['plusPlus']
    convert_score(plusplus_data)
    # convert_score_log(plusplus_data)
    # convert_reasons(plusplus_data)


def convert_score_log(plusplus_data):
    log = plusplus_data['log']
    pretty_dump(log)
    client = WebClient(token=SLACK_API_TOKEN)
    reply = client.users_list()
    if not reply['ok']:
       return

    name2id = {}
    for member in reply['members']:
        id = member['id']
        name = member['name']
        name2id[id] = name

    for user_name, l in log.items():
        for target, date in l.items():
            print(user_name, target, date)


def convert_score(plusplus_data):
    scores = plusplus_data['scores']
    pretty_dump(scores)
    print(type(scores))

    redis = Redis(connection_pool=redis_pool)
    redis.zadd(keys['score'], scores)


def convert_reasons(plusplus_data):
    reasons = plusplus_data['reasons']
    for k, v in reasons.items():
        if v:
            print(k, v)
