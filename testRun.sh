#PBS -N gutSim -S /bin/sh
#PBS -l nodes=1:ppn=16
java -Xmx1024m -Dfile.encoding=UTF-8 -cp ../netlogo-6.0/app/NetLogo.jar \
org.nlogo.headless.Main \
--model NLCode.nlogo \
--experiment testCluster \
--spreadsheet -
