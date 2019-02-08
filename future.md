### 余力があれば以下で実装

### DB
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

### ページ
#### /circle
サークル情報の確認  

#### /author
作者情報の確認  

### API
#### /circle_add
サークル情報の追加  

#### /author_add
作者情報の追加  

#### /event_add
イベント情報の追加  