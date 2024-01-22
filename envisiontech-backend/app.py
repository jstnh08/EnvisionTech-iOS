from flask import Flask, g, request, jsonify
from flask_login import LoginManager, UserMixin
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
import os
from datetime import datetime, timezone, timedelta
from flask_jwt_extended import JWTManager, create_access_token, get_jwt_identity, jwt_required

app = Flask(__name__)
app.secret_key = os.getenv("ENVISION_TECH_SECRET_KEY")
app.config["JWT_SECRET_KEY"] = os.getenv("ENVISION_TECH_JWT_KEY")
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(hours=5)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'

login_manager = LoginManager()
login_manager.init_app(app)

jwt_manager = JWTManager(app)

db = SQLAlchemy(app)
bcrypt = Bcrypt(app)

@login_manager.user_loader
def load_user(user_id):
    return db.session.get(User, int(user_id))


class User(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(20), nullable=False, unique=True)
    password = db.Column(db.String(80), nullable=False)
    email = db.Column(db.String(80), nullable=False, unique=True)
    first_name = db.Column(db.String(20), nullable=False)
    last_name = db.Column(db.String(20), nullable=False)
    grade = db.Column(db.Integer, nullable=False)

    likes = db.relationship('Likes', backref='user', lazy=True)
    comments = db.relationship('Comment', backref='user', lazy=True)

    def to_dict(self):
        return {
            "id": self.id,
            "username": self.username
        }

class Comment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    parent_id = db.Column(db.Integer, db.ForeignKey('comment.id'), nullable=True)
    text = db.Column(db.String(200), nullable=False)
    post_date = db.Column(db.DateTime, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

    likes = db.relationship('Likes', backref='comment', lazy=True)
    replies = db.relationship('Comment', backref='comment', remote_side=id, lazy=True)

    def to_dict(self, user_id):
        return {
            "id": self.id,
            "text": self.text,
            "post_date": self.post_date.replace(tzinfo=timezone.utc).isoformat(),
            "count_likes": Likes.query.filter(Likes.comment_id == self.id).count(),
            "user_liked": bool(Likes.query.filter_by(user_id=user_id, comment_id=self.id).first()),
            "count_replies": Comment.query.filter(Comment.parent_id == self.id).count(),
            "parent_id": self.parent_id,
            "user": self.user.to_dict()
        }

class Likes(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    comment_id = db.Column(db.Integer, db.ForeignKey('comment.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)


class Video(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    comment_id = db.Column(db.Integer, db.ForeignKey('comment.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

with app.app_context():
    # db.drop_all()
    db.create_all()

@app.route('/')
def index():
    return 'Workin'

@ app.route('/register', methods=['POST'])
def register():
    data = request.get_json()

    print(data)

    if User.query.filter_by(username=data['username']).first():
        return jsonify({"error": "This username already exists."}), 409

    if User.query.filter_by(email=data['email']).first():
        return jsonify({"error": "This email already exists."}), 409

    hashed_password = bcrypt.generate_password_hash(data['password'])
    new_user = User(
        username=data['username'],
        password=hashed_password,
        email=data['email'],
        first_name=data['firstName'],
        last_name=data['lastName'],
        grade=data['grade']
    )
    db.session.add(new_user)
    db.session.commit()

    access_token = create_access_token(identity=new_user.id)
    return jsonify({"access_token": access_token, "id": new_user.id})

def get_int_arg(request, key, default):
    arg = request.args.get(key)

    if arg and arg.isdigit():
        return int(arg)
    return default

@app.route('/comment', methods=['GET', 'POST'])
@jwt_required()
def comment():
    user_id = get_jwt_identity()

    if request.method == "POST":
        data = request.get_json()

        if len(data['text']) >= 200:
            return jsonify({"error": "Text too long"}), 400

        new_comment = Comment(
            parent_id=data.get("parentId"),
            text=data['text'],
            post_date=datetime.fromisoformat(data['postDate']),
            user_id=user_id
        )
        db.session.add(new_comment)
        db.session.commit()

        return [new_comment.to_dict(user_id)]

    else:
        offset = get_int_arg(request, "offset", 0)
        snapshot = get_int_arg(request, "snapshot", float("inf"))

        latest_comments = (
            Comment.query
            .filter(Comment.id <= snapshot).filter(Comment.parent_id.is_(None))
            .order_by(Comment.post_date.desc())
            .limit(10)
            .offset(offset)
            .all()
        )

        return jsonify([x.to_dict(user_id) for x in latest_comments])

@ app.route('/replies/<int:comment_id>', methods=['GET'])
@jwt_required()
def replies(comment_id):
    user_id = get_jwt_identity()

    latest_replies = (
        Comment.query
        .filter(Comment.parent_id == comment_id)
        .order_by(Comment.post_date.asc())
        .all()
    )

    return jsonify([x.to_dict(user_id) for x in latest_replies])


@ app.route('/like/<int:comment_id>', methods=['POST'])
@jwt_required()
def like(comment_id):
    user_id = get_jwt_identity()
    existing_like = Likes.query.filter_by(user_id=user_id, comment_id=comment_id).first()

    if existing_like:
        db.session.delete(existing_like)
    else:
        new_like = Likes(
            user_id=user_id,
            comment_id=comment_id
        )
        db.session.add(new_like)

    db.session.commit()

    return jsonify({"message": "OK"})


@ app.route('/units', methods=['GET'])
def units():
    return jsonify(
        [
            {"name": "Software Fundamentals", "icon": "puzzlepiece.fill"},
            {"name": "Productivity and Design", "icon": "paintbrush.pointed.fill"},
            {"name": "Web Tools", "icon": "bubble.right.fill"},
            {"name": "Organization and Security", "icon": "shield.lefthalf.fill"},
            {"name": "Mobile Solutions", "icon": "iphone.homebutton"}
        ]
    )

@ app.route('/courses', methods=['GET'])
def courses():
    print("mr glass")
    return jsonify(
        [
            {"name": "Web Safety", "icon": "shield.righthalf.filled"},
            {"name": "Coding", "icon": "externaldrive.fill"},
            {"name": "Game Dev", "icon": "gamecontroller.fill"},
            {"name": "Software", "icon": "network"},
            {"name": "Computers", "icon": "desktopcomputer"},
        ]
    )

@ app.route('/blog', methods=['GET'])
def blog():
    author = ""
    for person in people_data:
        if person['name'].lower() == "Justin Hudacsko".replace('-', ' ').lower():
            author = person
            break

    return jsonify(
        {
            "title": "Why Should You Choose EnvisionTech?",
            "description": "In the pilot issue of the EnvisionTech Blog, you'll learn why you should choose us over other education focused non-profits.",
            "author": author,
            "sections": [
                {
                    "header": "More Than Just an App",
                    "paragraphs": [
                        "At Envision Tech, we believe that education is the cornerstone of personal and societal growth. Our platform is designed to break down the barriers to education by providing free, world-class learning resources at your fingertips.",
                        "Whether you're a student seeking to supplement your studies, a lifelong learner curious about new topics, or a professional looking to upskill, our app is tailored to meet your learning needs."
                    ]
                },
                {
                    "header": "A World of Knowledge",
                    "paragraphs": [
                        "Our diverse range of courses covers everything from basic mathematics to advanced science, coding, humanities, and more. Each course is crafted by expert educators and is available in bite-sized lessons.",
                        "Interactive quizzes and hands-on projects ensure that your learning experience is engaging and effective. Enjoy and access anytime, anywhere."
                    ]
                },
                {
                    "header": "Personalized Learning Paths",
                    "paragraphs": [
                        "What sets Envision Tech apart is our commitment to personalized education. Our adaptive learning technology curates a learning path just for you.",
                        "Focusing on your strengths and addressing your weaknesses; this means that each learner has a unique experience tailored to their individual learning style and pace."
                    ]
                },
                {
                    "header": "Community and Support",
                    "paragraphs": [
                        "Learning is more fun and effective when you're part of a community. On Envision Tech, you can connect with fellow learners & participate in discussion forums.",
                        "Get help from experienced tutors, so you can share your learning goals and achievements, ask questions, or help others on their learning journey."
                    ]
                },
                {
                    "header": "Your Learning, Your Impact",
                    "paragraphs": [
                        "Every lesson you complete on our app contributes to a greater cause. As a non-profit, we reinvest our resources to continually improve the platform and expand our reach to underserved communities.",
                        "By choosing to learn with us, you're not just enhancing your knowledge; you're part of a movement to make education equitable for all."
                    ]
                }
            ]
        }
    )

people_data = [
    {
        "name": "Raymond Li",
        "position": "Vice President and Co-Founder",
        "description": "Say hello to Raymond Li, our co-founder and basketball aficionado! When he’s not on the court, he’s diving into the world of chemistry and soaking up knowledge like a sponge. Raymond’s love for the game and his passion for learning form the heart of our app, bringing together sportsmanship and scientific curiosity in one dynamic co-founder.",
        "likes": [
            {"name": "Getting Beat", "icon": "ruler"},
            {"name": "Basketball", "icon": "basketball.fill"},
            {"name": "SAT Prep", "icon": "books.vertical.fill"}
        ],
        "info": [
            {"icon": "phone", "text": "(425) 389-7325"},
            {"icon": "envelope", "text": "raymondli1221@gmail.com"}
        ]
    },
    {
        "name": "Justin Zhang",
        "position": "President and Co-Founder",
        "description": "Meet Justin Zhang, our co-founder and tennis champ! When he's not acing it on the court, he's deep into the world of CS, exploring and loving every bit of it. Justin's passion for tennis and his knack for all things tech are the driving forces behind our app. With Justin on our team, we've got a co-founder who smashes it in tennis and codes like a pro!",
        "likes": [
            {"name": "Tennis", "icon": "tennis.racket"},
            {"name": "Coding", "icon": "laptopcomputer"},
            {"name": "Gaming", "icon": "gamecontroller.fill"}
        ],
        "info": [
            {"icon": "phone", "text": "(425) 623-5781"},
            {"icon": "envelope", "text": "justincz0302@gmail.com"}
        ]
    },
    {
        "name": "Justin Hudacsko",
        "position": "Vice President and Co-Founder",
        "description": "Say hello to Justin Hudascsko, our co-founder and passionate about both football and programming! When he's not on the field scoring goals, he's diving into the world of coding, crafting innovative solutions and exploring new tech territories. With Justin leading the charge, we've got a co-founder who's bringing a blend of sportsmanship and technical prowess to our team!",
        "likes": [
            {"name": "Football", "icon": "football.fill"},
            {"name": "Coding", "icon": "laptopcomputer"},
            {"name": "Gaming", "icon": "gamecontroller.fill"}
        ],
        "info": [
            {"icon": "phone", "text": "(425) 628-4018"},
            {"icon": "envelope", "text": "justin.hudacsko@gmail.com"}
        ]
    },
    {
        "name": "Marcus Lee",
        "position": "Treasurer and Co-Founder",
        "description": "Say hi to Marcus Lee, our co-founder and soccer referee extraordinaire! When he's not blowing the whistle on the field, he's gaming hard on Fortnite, soaking in all the action. Marcus's love for soccer and his knack for gaming are the fuel behind our app. With Marcus in the mix, we've got a co-founder who's merging his love for sports and gaming in one awesome package!",
        "likes": [
            {"name": "Soccer", "icon": "soccerball"},
            {"name": "Sauce", "icon": "cup.and.saucer.fill"},
            {"name": "Tutoring", "icon": "book"}
        ],
        "info": [
            {"icon": "phone", "text": "(425) 456-7890"},
            {"icon": "envelope", "text": "marcus.lee12@gmail.com"}
        ]
    },
    {
        "name": "Steve Ling",
        "position": "Gay Nigga Finna Get Cut",
        "description": "Meet Steve Ling, our co-founder with an absolute knack for navigating the college application process! He's all about crafting the perfect application, diving deep into the intricacies of the admissions world. With Steve on our team, we've got a co-founder who's bringing expertise and a genuine desire to help others succeed in their academic journeys!",
        "likes": [
            {"name": "Doing Nothing", "icon": "0.circle.fill"},
            {"name": "College Apps", "icon": "building.fill"},
            {"name": "Getting Cut", "icon": "scissors"}
        ],
        "info": [
            {"icon": "phone", "text": "(425) G4Y-N166A"},
            {"icon": "envelope", "text": "gaynigga@hotmail.com"}
        ]
    }
]
@app.route('/about', methods=['GET'])
@app.route('/about/<string:name>', methods=['GET'])
def about(name=None):
    if name:
        for person in people_data:
            if person['name'].lower() == name.replace('-', ' ').lower():
                return jsonify(person)
        return jsonify({"error": "Could not find user."}), 404
    else:
        return jsonify(people_data)

@ app.route('/practice', methods=['GET'])
def practice():
    return jsonify(
        [
            {
                "question": "What is the brain of the computer called?",
                "explanation": "The brain of the computer is like our brain. It helps the computer think and make decisions. This part is called the CPU.",
                "incorrect": ["Hard drive", "Monitor", "Keyboard"],
                "correct": "CPU"
            },
            {
                "question": "What do we call the pictures or symbols on the screen that you click to open programs?",
                "explanation": "These small pictures on the screen represent different programs or files, and you can start them by clicking on them.",
                "incorrect": ["Keys", "Files", "Text"],
                "correct": "Icons"
            },
            {
                "question": "Which device helps you move the cursor on the screen?",
                "explanation": "This device is used to point, click, and scroll on your computer screen, making it easier to select things.",
                "incorrect": ["Keyboard", "Printer", "Monitor"],
                "correct": "Mouse"
            },
            {
                "question": "What is it called when you restart your computer?",
                "explanation": "Restarting the computer means turning it off and then back on again, which can sometimes fix problems.",
                "incorrect": ["Logging off", "Shutdown", "Charging"],
                "correct": "Reboot"
            }
        ]
    )

app.run(host="0.0.0.0", debug=True)