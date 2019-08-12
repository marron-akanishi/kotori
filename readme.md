# kotori
同人誌管理アプリケーション  

## 概要
所有している同人誌を管理するためのWebアプリケーション  
複数購入を防止するために作成されました。  

## 開発仕様
Windows10 + WSL  
Umi(CSS)  
その他Gemfileに書いてあるもの

## kakasiのインストール
ふりがな用にkakasiを利用  
Ubuntuでのインストールが面倒なのでメモ  
```
wget http://kakasi.namazu.org/stable/kakasi-2.3.6.tar.gz
tar -xvf kakasi-2.3.6.tar.gz
cd kakasi-2.3.6
./configure
make
sudo make install
rm -fr kakasi*
sudo nano /etc/ld.so.conf
# /lib/local/libを追記
sudo ldconfig
```

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
tables.vsdx参照