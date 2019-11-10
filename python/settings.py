import os
from os.path import join, dirname
from dotenv import load_dotenv

load_dotenv(verbose=True)

dotenv_path = join(dirname(__file__), '..', '.env')
load_dotenv(dotenv_path)

PWD = os.environ.get("PASSWORD")
REDISCLOUD_URL = os.environ.get("REDISCLOUD_URL")
