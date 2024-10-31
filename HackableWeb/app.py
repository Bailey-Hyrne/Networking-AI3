from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

# Define valid users
valid_users = {
    "KingCeo": "SigmaWolf123",
    "Ted Smith": "Hacked123"
}

@app.route('/')
def home():
    return render_template('login.html')

@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']
    if username in valid_users and valid_users[username] == password:
        return f"Welcome, {username}!"
    else:
        return "Invalid credentials, please try again."

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)

