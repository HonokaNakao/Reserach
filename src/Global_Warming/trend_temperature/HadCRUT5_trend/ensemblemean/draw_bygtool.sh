#! /bin/bash

ln -s /usr/local/dcl/lib/dcldbase/colormap_67.x11 colormap.x11      #特定のカラーマップをcolormap.x11としてシンボリックリンクする
gtcont sig95_90_trend_1960_2014_1_mon cont=1,5 trend_1960_2014_1_mon tone=-1,-0.6,-0.4,-0.2,-0.1,0.0,0.1,0.2,0.4,0.6,1.0 pat=10999,22999,28999,48999,53999,58999,65999,70999,89999,99999 map=1 -print ps:test1.ps
gtcont sig95_90_trend_1960_2014_1_mon tone=85,90,95,100 pat=11999,12999,13999 trend_1960_2014_1_mon tone=-1,-0.6,-0.4,-0.2,-0.1,0.0,0.1,0.2,0.4,0.6,1.0 pat=10999,22999,28999,48999,53999,58999,65999,70999,89999,99999 map=1 -print ps:test2.ps
rm colormap.x11
