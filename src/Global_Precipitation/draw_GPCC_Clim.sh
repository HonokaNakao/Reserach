#! /bin/bash
#
#
# GPCC の気候値データが格納してあるディレクトリ
DATDIR='/net/ocean/mnt/volume0/GPCC/GPCC_Clim/Data'
#
# データの解像度（格子サイズ）を指定
# 選択肢は025, 05, 10, 25
#   025:0.25度, 05:0.5度, 10:1.0度, 25:2.5度
RES=025 
#
# 元データに大して作業ディレクトリからリンクを張る
ln -s ${DATDIR}/${RES}/normals_1991_2020_v2022_${RES}.nc ./
#
# Fortran プログラムをコンパイル
#   なお、データの解像度に合わせてファイル名や変数を書き換える必要がある
#dclfrt draw_normals.f90 -L/usr/lib -lnetcdf -lnetcdff
dclfrt draw_GPCC_Clim_w_subr.f90 -L/usr/lib -lnetcdf -lnetcdff
#
# 実行
./a.out
#
# ムダなファイル等を削除
rm a.out normals_1991_2020_v2022*.nc
#
#
#
exit
