from flask import Flask, request, jsonify

import os



app = Flask(__name__)



log_file_path = "/app/logs/app.log"

greeting = os.getenv("GREETING", "Welcome to the custom app")



os.makedirs(os.path.dirname(log_file_path), exist_ok=True)



@app.route('/')

def home():

    return greeting



@app.route('/status')

def status():

    return jsonify({"status": "ok"})



@app.route('/log', methods=['POST'])

def write_log():

    data = request.get_json()

    message = data.get("message", "empty log")

    

    with open(log_file_path, "a") as f:

        f.write(message + "\n")

    

    print(f"LOG: {message}", flush=True)

    return jsonify({"status": "saved"}), 201



@app.route('/logs')

def read_logs():

    try:

        with open(log_file_path, "r") as f:

            return f.read()

    except FileNotFoundError:

        return "No logs yet."



if __name__ == '__main__':

    port = int(os.getenv("PORT", 8080))

    app.run(host='0.0.0.0', port=port)
