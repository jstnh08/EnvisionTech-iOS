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
    email = db.Column(db.String(80), nullable=False, unique=True)
    first_name = db.Column(db.String(20), nullable=False)
    last_name = db.Column(db.String(20), nullable=False)
    grade = db.Column(db.Integer, nullable=False)

with app.app_context():
    db.create_all()

@app.route('/')
def index():
    return 'Workin'

@ app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    print(data)

    if User.query.filter_by(username=data['username']).first():
        return jsonify({"message": "This username already exists."}), 409

    if User.query.filter_by(email=data['email']).first():
        return jsonify({"message": "This email already exists."}), 409

    hashed_password = bcrypt.generate_password_hash(data['password'])
    new_user = User(
        username=data['username'],
        password=hashed_password,
        email=data['email'],
        first_name=data['firstName'],
        last_name=data['lastName'],
        grade=data['grade']
    )
    print(new_user )
    db.session.add(new_user)
    db.session.commit()

    return jsonify({"message": "Received and processed data successfully"})

@ app.route('/units', methods=['GET'])
def units():
    return jsonify(
        [
            {
                "name": "Software Fundamentals",
                "icon": "puzzlepiece.fill",
                "activated": False
            },
            {
                "name": "Productivity and Design",
                "icon": "paintbrush.pointed.fill",
                "activated": False
            },
            {
                "name": "Web Tools",
                "icon": "bubble.right.fill",
                "activated": False
            },
            {
                "name": "Organization and Security",
                "icon": "shield.lefthalf.fill",
                "activated": False
            },
            {
                "name": "Mobile Solutions",
                "icon": "iphone.homebutton",
                "activated": False
            }
        ]
    )

app.run(debug=True)