#! /bin/bash

## MIROC6 ensemblemean & 50例とHadCRUT5 ensemblemean & 200例の空間相関を算出するプログラム
# (1) データのシンボリックリンク (symbolic.sh)
# (2) MIROCデータのファイル名一覧のテキストファイルを作成 (mk_flnm.sh)
# (3) 空間相関の算出 (cal_pattern.sh)
#----------------------------------------------------------------------------------------------------------------------------------------------

# (1) データのシンボリックリンク (symbolic.sh)
for mon in $( seq 1 12 ) ; do                 # 月毎
#for mon in 030405 060708 091011 120102 ; do
	for run in $( seq 1 50 ) ; do
		./symbolic.sh $mon $run
	done
done

# (2) MIROCデータのファイル名一覧のテキストファイルを作成 (mk_flnm.sh)
for mon in $( seq 1 12 ) ; do
#for mon in 030405 060708 091011 120102 ; do
	./mk_flnm.sh $mon > /home/honoka/work/sppattern/data/trend/ifnmMIROC_${mon}.txt
done
           
# (3) 空間相関の算出 (cal_pattern.f90)
for mon in $( seq 1 12 ) ; do                 # 月毎
#for mon in 030405 060708 091011 120102 ; do  # 季節毎
	./cal_pattern.sh $mon                 # 全球
	./cal_pattern_NP.sh $mon              # 北半球 (北緯2.5-87.5度)
	./cal_pattern_N30_90.sh $mon          # 北半球 (北緯32.5-87.5度)
done

# (4) 空間相関の度数分布表の描画 (draw_bar.sh)
for mon in $( seq 1 12 ) ; do                 # 月毎
#for mon in 030405 060708 091011 120102 ; do  # 季節毎
        for area in NP N30_90 ; do
        		./draw_bar.sh $mon $area
	done
done

# (5) 空間相関の度数分布表をmontage (montage.sh)
for area in NP N30_90 ; do
	./montage.sh $area
done
