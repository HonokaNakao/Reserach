#! /bin/bash

# HadCRUT5 ensemble meanとMIROC6 run1-50のtrendの差を描画するプログラム
# (1) # HadCRUT5 ensemble meanとMIROC6 run1-50のtrendの差を計算するプログラム (cal_diftrend.sh)
# (2) diftrendをDCLで描画 (draw_diftrend_sig_mon_NP.sh、draw_diftrend_sig_r1_50_mon_NP.sh)
# (3) montageする (montage.sh)

#---------------------------------------------------------------------------------------------------------------------------------------------- 
# (1) HadCRUT5 ensemble meanとMIROC6 run1-50のtrendの差を計算 (cal_diftrend.sh)
#for mon in $( seq 1 12 ) ; do                 # 月毎
#for mon in 030405 060708 091011 120102 ; do  # 季節毎
#       for run in $( seq 1 50 ) ; do
#               ./cal_diftrend.sh $mon $run
#       done
#done

# (1)' HadCRUT5 trend1-200のensemble meanとMIROC6 run1-50のensemble meanの差を計算 (cal_diftrendav.sh)
#for mon in $( seq 1 12 ) ; do                 # 月毎
for mon in 030405 060708 091011 120102 ; do  # 季節毎
        ./cal_diftrendav.sh $mon
done

# (2) diftrendをDCLで描画 (draw_diftrend_sig_mon_NP.sh、draw_diftrend_sig_r1_50_mon_NP.sh)
# MIROC ensemble mean trend - HadCRUT5 ensemble mean trend
#for mon in $( seq 1 12 ) ; do                   # 月毎
#for mon in 030405 060708 091011 120102 ; do     # 季節毎
#        ./draw_diftrend_sig_mon_NP.sh $mon      # N20_90 (北緯20度以北)
#        ./draw_diftrend_sig_mon_N30_90.sh $mon  # N30_90 (北緯30度以北)
#done

# MIROC run1-50 trend - HadCRUT5 ensemble mean trend
#for runnum in $( seq 1 50 ) ; do  
#	for mon in $( seq 1 12 ) ; do
#        for mon in 030405 060708 091011 120102 ; do                   # 季節毎
#		./draw_diftrend_sig_r1_50_mon_NP.sh $runnum $mon       # N20_90(北緯20度以北)
#		./draw_diftrend_sig_r1_50_mon_N30_90.sh $runnum $mon   # N30_90(北緯30度以北)
#	done
#done

# (3) montageする (montage.sh)
#for mon in $( seq 1 12 ) ; do
#for mon in 030405 060708 091011 120102 ; do  # 季節毎
#        ./montage.sh $mon
#done
