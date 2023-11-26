import os

from flask import Flask, g, request, jsonify
from flask_login import LoginManager, UserMixin
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
import os

app = Flask(__name__)
app.secret_key = os.getenv("ENVISION_TECH_SECRET_KEY")
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'

login_manager = LoginManager()
login_manager.init_app(app)

db = SQLAlchemy(app)
bcrypt = Bcrypt(app)

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))


class User(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(20), nullable=False, unique=True)
    password = db.Column(db.String(80), nullable=False)

@app.route('/')
def index():
    return 'Welcome to the Flask-Login Example!'

@ app.route('/register', methods=['POST'])
def register():
    json_data = request.get_json()
    print(json_data)
    print(request.form)

    username = request.form.get('username')
    password = request.form.get('password')
    print(username, password)

    # hashed_password = bcrypt.generate_password_hash(password)
    return jsonify({"message": "Received and processed data successfully"})
    # new_user = User(username=, password=hashed_password)
    # db.session.add(new_user)
    # db.session.commit()

app.run(debug=True)