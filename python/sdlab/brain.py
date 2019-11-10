# -*- coding: utf-8 -*-
import settings
import redis
import json

HUBOT_BRAIN_KEY = 'hubot:storage'


def load_brain(redis_url=settings.REDISCLOUD_URL):
    r = redis.Redis.from_url(redis_url)
    return json.loads(r.get('hubot:storage').decode('utf-8'))


def restore_brain(brain_data: dict, redis_url=settings.REDISCLOUD_URL):
    r = redis.Redis.from_url(redis_url)
    r.set(HUBOT_BRAIN_KEY, json.dumps(brain_data, ensure_ascii=False))


def clear_brain_trash(redis_url=settings.REDISCLOUD_URL):
    brain = load_brain(redis_url=redis_url)

    unused_users = [
        # list unused users here.
    ]

    for user in unused_users:
        del brain['users'][user]
    restore_brain(brain, redis_url=redis_url)
