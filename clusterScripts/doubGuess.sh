#PBS -N doubGuess -S /bin/sh
#PBS -l nodes=1:ppn=12
~/netlogo-6.0/netlogo-headless.sh \
--model ~/gut-nlogo-model/NLCode.nlogo \
--experiment doubGuess \
--spreadsheet ~/results/doubGuess.csv \
--threads 12
