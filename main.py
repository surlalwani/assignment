from flask import Flask, jsonify
import random

app = Flask(__name__)


STRING_OPTIONS = [
    "Investments",
    "Smallcase",
    "Stocks",
    "buy-the-dip",
    "TickerTape"
]

@app.route('/api/v1', methods=['GET'])
def get_random_string():
    """Endpoint that returns a random string from the predefined list"""
    random_string = random.choice(STRING_OPTIONS)
    return jsonify({
        "random_string": random_string
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8081)