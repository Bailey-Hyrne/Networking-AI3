from flask import Flask, render_template, request, redirect, url_for, session
import os
import json

app = Flask(__name__)
app.secret_key = 'your_secret_key'

# Path to the user data file
user_data_file = 'users/users.json'

# Function to load users from a JSON file
def load_users():
    if os.path.exists(user_data_file):
        with open(user_data_file, 'r') as f:
            return json.load(f)
    return {}

# Function to save users to a JSON file
def save_users(users):
    with open(user_data_file, 'w') as f:
        json.dump(users, f)

# Home page with login form
@app.route('/')
def home():
    return render_template('login.html')

# Registration page
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        users = load_users()
        if username in users:
            return "Username already exists!"
        users[username] = password
        save_users(users)
        return redirect(url_for('home'))
    return render_template('register.html')

# Login page
@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']
    users = load_users()
    if username in users and users[username] == password:
        session['username'] = username
        return redirect(url_for('secret'))
    return "Invalid credentials!"

# Secret page
@app.route('/secret')
def secret():
    if 'username' in session:
        return f"Hello, {session['username']}! <a href='/logout'>Logout</a>"
    return redirect(url_for('home'))

# Logout
@app.route('/logout')
def logout():
    session.pop('username', None)
    return redirect(url_for('home'))

if __name__ == '__main__':
    app.run(debug=True)
