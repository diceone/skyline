#!/bin/bash

# Defaults

GRAPHITE_HOST=${GRAPHITE_HOST:-localhost}
GRAPHITE_PORT=${GRAPHITE_PORT:-2003}

echo "GRAPHITE_HOST: ${GRAPHITE_HOST}"
echo "GRAPHITE_PORT: ${GRAPHITE_PORT}"

# Configuration

cat << EOF > /skyline/src/settings.py
import os
REDIS_SOCKET_PATH='/tmp/redis.sock'
LOG_PATH = '/var/log/skyline'
PID_PATH = '/var/run/skyline'
FULL_NAMESPACE = 'metrics.'
MINI_NAMESPACE = 'mini.'
FULL_DURATION = 86400
MINI_DURATION = 3600
GRAPHITE_HOST = '${GRAPHITE_HOST}:${GRAPHITE_PORT}'
GRAPH_URL = 'http://' + GRAPHITE_HOST + '/render/?width=1400&from=-1hour&target=%s'
OCULUS_HOST = 'http://your_oculus_host.com'
ANOMALY_DUMP = 'webapp/static/dump/anomalies.json'
ANALYZER_PROCESSES = 5
STALE_PERIOD = 500
MIN_TOLERABLE_LENGTH = 1
MAX_TOLERABLE_BOREDOM = 100
CANARY_METRIC = 'statsd.numStats'
ALGORITHMS = [
                'first_hour_average',
                'mean_subtraction_cumulation',
                'stddev_from_moving_average',
                'least_squares',
                'grubbs',
                'histogram_bins',
                'median_absolute_deviation',
                'ks_test',
             ]
ENABLE_SECOND_ORDER = False
BOREDOM_SET_SIZE = 1
CONSENSUS = 7
WORKER_PROCESSES = 2
HORIZON_IP = os.popen("""ip addr | grep "inet " | cut -d' ' -f 6 | cut -d'/' -f 1""").readlines()[1][:-1]
PICKLE_PORT = 2024
UDP_PORT = 2025
CHUNK_SIZE = 10
MAX_QUEUE_SIZE = 500
ROOMBA_PROCESSES = 1
ROOMBA_GRACE_TIME = 600
MAX_RESOLUTION = 1000
SKIP_LIST = ['example.statsd.metric',
             'another.example.metric',
            # if you use statsd, these can result in many near-equal series 
            #'_90',
            #'.lower',
            #'.upper',
            #'.median',
            #'.count_ps',
          ]
WEBAPP_IP = HORIZON_IP
WEBAPP_PORT = 80
EOF

# Startup

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

