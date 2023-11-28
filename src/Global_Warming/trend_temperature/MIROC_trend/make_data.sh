#! /bin/bash
## HadCRUT5に揃えたMIROC6データを作成するプログラム

# (1) 偏差データを作成 (make_anomaly.sh)
# (2) 格子補間 [HadCRUT5と同じ水平解像度に変更] (gtintrp.sh)
# (3) 欠損値をHadCRUT5と揃える (gtmask.sh)

#----------------------------------------------------------------------------------------------------------------------------------------------
# (1) 偏差データを作成 (make_anomaly.sh)
#./make_anomaly.sh

# (2) 格子補間 [HadCRUT5と同じ水平解像度に変更] (gtintrp.sh)
#for runnum in $( seq 1 50 ) ; do
#        for mon in $( seq 1 12 ) ; do
#                ./gtintrp.sh $runnum $mon
#        done
#done

# (3) 欠損値をHadCRUT5と揃える (gtmask.sh)
for runnum in $( seq 1 50 ) ; do
        for mon in $( seq 1 12 ) ; do
                ./gtmask.sh $runnum $mon
        done
done
