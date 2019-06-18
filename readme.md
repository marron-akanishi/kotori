# kotori
同人誌管理アプリケーション  

## 概要
所有している同人誌を管理するためのWebアプリケーション  
複数購入を防止するために作成されました。  

## 開発仕様
Windows10 + WSL  
Umi(CSS)  
その他Gemfileに書いてあるもの

## Unicornの操作
起動  
```
bundler exec unicorn -c unicorn.rb -E development -D
```  

停止  
```
kill -QUIT `cat tmp/pids/unicorn.pid`
```

## 以下開発メモ
### ログイン方法
Googleアカウントを利用   

### DB設計
#### Users
```sql
create table users (
  id text primary key,
  mail text,
  latest_at datetime,
  daleted_at datetime,
  name text
);
```
id -> 一意なID(Google OAuthから引っ張る)  
mail -> Googleのメールアドレス  
latest_at -> 最後にログインした日時  
deleted_at -> 退会した日時  
name -> 表示名  

#### Books
```sql
create table books (
  id integer primary key,
  title text,
  cover text,
  date date,
  detail text,
  is_adult boolean,
  mod_user text,
  genre_id integer,
  event_id integer,
  author_id integer,
  circle_id integer,
  foreign key(genre_id) references genres(id),
  foreign key(event_id) references events(id),
  foreign key(author_id) references authors(id),
  foreign key(circle_id) references circles(id)
);
```
id -> 一意なID  
title -> 書籍タイトル  
cover -> 表紙画像(UUIDによるファイル名)  
date -> 発行日  
deteil -> 詳細・メモ  
is_adult -> 18禁  
mod_user -> 最終変更ユーザー  
genre_id -> Genres.id  
event_id -> Events.id  
author_id -> Authors.id  
circle_id -> Circles.id

#### Genres
```sql
create table genres (
  id integer primary key,
  name text
);
```
id -> 一意なID  
name -> ジャンル名  

#### Events
```sql
create table events (
  id integer primary key,
  name text,
  date date
);
```
id -> 一意なID  
name -> イベント名  
date -> 開催日  

#### Authors
```sql
create table authors (
  id integer primary key,
  name text,
  detail text,
  twitter text,
  pixiv text,
  web text,
  circle_id integer,
  foreign key(circle_id) references circles(id)
);
```
id -> 一意なID  
name -> 著者名  
detail -> 詳細・メモ  
twitter -> TwitterID  
pixiv -> pixivID  
web -> ウェブページURL  
circle_id -> Circles.id  

#### Circles
```sql
create table circles (
  id integer primary key,
  name text,
  detail text,
  web text
);
```
id -> 一意なID  
name -> サークル名  
detail -> 詳細・メモ  
web -> ウェブページURL  

#### Owners
```sql
create table owners (
  user_id text,
  book_id integer,
  is_read boolean,
  memo text,
  foreign key(user_id) references users(id),
  foreign key(book_id) references books(id)
);
```
user_id -> Users.id  
book_id -> Books.id  
is_read -> 未読管理  
memo -> 個別のメモ  