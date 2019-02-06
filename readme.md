# kotori
同人誌管理アプリケーション  

## 概要
所有している同人誌を管理するためのWebアプリケーション  
複数購入を防止するために作成されました。  

## 動作環境
未決定  

## 以下開発メモ
### ログイン方法
Twitter APIを使わない。  
今有力なのはGoogle OAuth 2.0  

### DB設計
#### Users
id -> 一意なID(Google OAuthから引っ張る？)  
latest_at -> 最後にログインした日時  
deleted_at -> 退会した日時  
name -> 表示名  

#### Books
id -> 一意なID(連番か何か)  
title -> 書籍タイトル  
event -> 発売されたイベント  
date -> 発行日  
author -> 作者    
circle -> サークル名  
cover -> 表紙画像(ファイルパス)  

#### Owners
user -> Users.id  
book -> Books.id  
memo -> 個別のメモ  

### ページ
#### /list
所有している本の一覧  

#### /mypage
自分の情報の変更  

#### /add
書籍追加画面  
GETで追加画面、POSTで追加  

### API
ここのリンクはページを設けずに通信用に使用  
#### /delete
書籍情報の削除

### 余力があれば以下で実装

#### Events
id -> 一意なID  
title -> イベント名  
date -> イベント開催日  

#### Authors
id -> 一意なID  
name -> 名前  
circleid -> Circles.id  
twitter -> TwitterID  
pixiv -> pixivID  
web -> ウェブサイト  

#### Circles
id -> 一意なID  
name -> サークル名  
twitter -> twitterID  
web -> ウェブサイト  

#### /circle
サークル情報の確認  

#### /author
作者情報の確認  

#### /circle_add
サークル情報の追加  

#### /author_add
作者情報の追加  

#### /event_add
イベント情報の追加  