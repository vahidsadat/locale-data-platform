from kafka import KafkaProducer
import logging
import json


def on_send_success(record_metadata):
    print(record_metadata.topic)
    print(record_metadata.partition)
    print(record_metadata.offset)

def on_send_err(excp):
    logging.error('error', exc_info=excp)

producer = KafkaProducer(
    bootstrap_servers='localhost:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8'))


producer.send('orders', {'field': 'value'}).add_callback(on_send_success).add_errback(on_send_err)

producer.flush()