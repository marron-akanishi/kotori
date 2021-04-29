wget http://kakasi.namazu.org/stable/kakasi-2.3.6.tar.gz
tar -xvf kakasi-2.3.6.tar.gz
cd kakasi-2.3.6
./configure
make
make install
cd ..
rm -fr kakasi*
echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig