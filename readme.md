# kotori
同人誌管理アプリケーション  

## 概要
所有している同人誌を管理するためのWebアプリケーション  
複数購入を防止するために作成されました。  

## 開発仕様
Windows10 + WSL  
Umi(CSS)  
その他Gemfileに書いてあるもの

## 以下開発メモ
### ログイン方法
Twitter APIを使わない。  
今有力なのはGoogle OAuth 2.0  

### DB設計
#### Users
```sql
create table users (
  id text primary key,
  latest_at datetime,
  daleted_at datetime,
  name text
);
```
id -> 一意なID(Google OAuthから引っ張る)  
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
  event_id integer,
  author_id integer,
  circle_id integer,
  foreign key(event_id) references events(id),
  foreign key(author_id) references authors(id),
  foreign key(circle_id) references circles(id)
);
```
id -> 一意なID  
title -> 書籍タイトル  
cover -> 表紙画像(ファイルパス)  
date -> 発行日  
event_id -> Events.id  
author_id -> Authors.id  
circle_id -> Circles.id

#### Events
```sql
create table events (
  id integer primary key,
  name text
);
```
id -> 一意なID  
name -> イベント名  

#### Authors
```sql
create table authors (
  id integer primary key,
  name text
);
```
id -> 一意なID  
name -> 作者名  

#### Circles
```sql
create table circles (
  id integer primary key,
  name text
);
```
id -> 一意なID  
name -> サークル名  

#### Owners
```sql
create table owners (
  user_id text,
  book_id integer,
  memo text,
  foreign key(user_id) references users(id),
  foreign key(book_id) references books(id)
);
```
user_id -> Users.id  
book_id -> Books.id  
memo -> 個別のメモ  

### ページ
#### /
トップ画面  
ログイン状態のSessionがある場合は/listにリダイレクト  

#### /login
ログイン画面  
GETで画面、POSTでログイン実行  

#### /list
所有している本の一覧  
表紙・タイトルを一覧で表示  

#### /mypage
自分の情報の変更  
GETで詳細画面、POSTで変更  

#### /search
書籍の検索  
GETで検索  
検索画面から自分の持っていない書籍を所持に変更出来るようにする。  

#### /add
書籍追加画面  
GETで追加画面、POSTで追加  
タイトル・作者・サークル名にはサジェスト機能を付ける。  
タイトルがサジェストで見つかった場合はその書籍情報を利用する。  
未定義の作者・サークルの場合は各DBに自動追加する。  

#### /detail
書籍詳細画面  

#### /modify
書籍情報編集画面  
GETで変更画面、POSTで変更  

### API
ここのリンクはページを設けずに通信用に使用  
#### /delete
書籍情報の削除  

#### /logout
ログアウト  

#### /quit
退会  