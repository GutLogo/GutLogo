#PBS -N gutSim -S /bin/sh
#PBS -l nodes=1:ppn=16
~/netlogo-6.0/netlogo-headless.sh \
--model ~/gut-nlogo-model/NLCode.nlogo \
--experiment testCluster \
--spreadsheet -
--threads 16