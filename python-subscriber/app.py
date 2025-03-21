import flask
from flask import request, jsonify
from flask_cors import CORS
from dapr.clients import DaprClient
import json

stateStore = "statestore"

app = flask.Flask(__name__)
CORS(app)

@app.route('/dapr/subscribe', methods=['GET'])
def subscribe():
    subscriptions = [{'pubsubname': 'pubsub', 'topic': 'A', 'route': 'A'},
        {'pubsubname': 'pubsub', 'topic': 'C', 'route': 'C'}]
    return jsonify(subscriptions)

@app.route('/A', methods=['POST'])
def a_subscriber():
    print('Received message on topic "{}":  "{}"'.format(request.json['topic'], request.json['data']['message']), flush=True)
    with DaprClient() as d:
        d.save_state(store_name=stateStore, key=request.json['topic'], value=request.json['data']['message'])
        print('Saving message "{}" into "{}"'.format(request.json['data']['message'], stateStore), flush=True)
    
    return json.dumps({'success':True}), 200, {'ContentType':'application/json'} 

@app.route('/C', methods=['POST'])
def c_subscriber():
    print('Received message on topic "{}": "{}"'.format(request.json['topic'], request.json['data']['message']), flush=True)

    with DaprClient() as d:
        d.save_state(store_name=stateStore, key=request.json['topic'], value=request.json['data']['message'])
        print('Saving message "{}" into "{}"'.format(request.json['data']['message'], stateStore), flush=True)
        
    return json.dumps({'success':True}), 200, {'ContentType':'application/json'} 

app.run(port=5001)
