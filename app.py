from flask import Flask,request
from prometheus_client import Counter,generate_latest

app = Flask(__name__)

REQUEST_COUNT = Counter('request_count','Total request count')

@app.route('/')
def home():
  REQUEST_COUNT.inc()
  return "Hello World"

@app.route('/metrics')
def metrics():
  return generate_latest(), 200,{'Contenct-Type':'text/plain; charset=utf-8'}

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=5000)
