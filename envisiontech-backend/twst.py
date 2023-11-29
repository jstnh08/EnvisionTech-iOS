import sqlite3

conn = sqlite3.connect("database.db")

cur = conn.cursor()
cur.execute("SELECT * FROM user")
print(cur.fetchall())