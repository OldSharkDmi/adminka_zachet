from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def index():
    return "Welcome to the API Service"

@app.route('/health')
def health_check():
    return jsonify(status="healthy")

# First model
@app.route('/model1', methods=['GET'])
def get_model1():
    return jsonify(model1="This is model 1")

# Second model
@app.route('/model2', methods=['GET'])
def get_model2():
    return jsonify(model2="This is model 2")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
