import datetime
import sqlite3

# DB接続
old_conn = sqlite3.connect("old_db.sqlite3")
new_conn = sqlite3.connect("new_db.sqlite3")
old_conn.row_factory = sqlite3.Row
old_cur = old_conn.cursor()
new_conn.row_factory = sqlite3.Row
new_cur = new_conn.cursor()

# genres
for data in old_cur.execute("select * from genres order by id asc"):
  time = datetime.datetime.now()
  SQL = "insert into genres (name, created_at, updated_at) values (?,?,?)"
  value = (data["name"], time, time)
  new_conn.execute(SQL, value)
  new_conn.commit()

# authors
for data in old_cur.execute("select * from authors order by id asc"):
  time = datetime.datetime.now()
  SQL = "insert into authors (name, created_at, updated_at) values (?,?,?)"
  value = (data["name"], time, time)
  new_conn.execute(SQL, value)
  new_conn.commit()

# events
for data in old_cur.execute("select * from events order by id asc"):
  time = datetime.datetime.now()
  SQL = "insert into events (name, created_at, updated_at) values (?,?,?)"
  value = (data["name"], time, time)
  new_conn.execute(SQL, value)
  new_conn.commit()

# circles
for data in old_cur.execute("select * from circles order by id asc"):
  time = datetime.datetime.now()
  SQL = "insert into circles (name, created_at, updated_at) values (?,?,?)"
  value = (data["name"], time, time)
  new_conn.execute(SQL, value)
  new_conn.commit()

# books
for data in old_cur.execute("select * from books order by id asc"):
  time = datetime.datetime.now()
  SQL = "insert into books (title, cover, published_at, detail, is_adult, mod_user, event_id, circle_id, created_at, updated_at) values (?,?,?,?,?,?,?,?,?,?)"
  value = (data["title"], data["cover"], data["date"], data["detail"], data["is_adult"], data["mod_user"], data["event_id"], data["circle_id"], time, time)
  new_conn.execute(SQL, value)
  new_conn.commit()

# book_genres
for data in old_cur.execute("select * from books order by id asc"):
  time = datetime.datetime.now()
  SQL = "insert into book_genres (book_id, genre_id, is_main, created_at, updated_at) values (?,?,?,?,?)"
  value = (data["id"], data["genre_id"], "t", time, time)
  new_conn.execute(SQL, value)
  new_conn.commit()

# book_authors
for data in old_cur.execute("select * from books order by id asc"):
  time = datetime.datetime.now()
  SQL = "insert into book_authors (book_id, author_id, is_main, created_at, updated_at) values (?,?,?,?,?)"
  value = (data["id"], data["author_id"], "t", time, time)
  new_conn.execute(SQL, value)
  new_conn.commit()

# user_books(owners)
for data in old_cur.execute("select * from owners order by id asc"):
  time = datetime.datetime.now()
  SQL = "insert into user_books (user_id, book_id, is_read, memo, created_at, updated_at) values (?,?,?,?,?,?)"
  value = (data["user_id"], data["book_id"], data["is_read"], data["memo"], time, time)
  new_conn.execute(SQL, value)
  new_conn.commit()

old_cur.close()
new_cur.close()
new_conn.commit()

old_conn.close()
new_conn.close()