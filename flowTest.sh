#PBS -N gutSim -S /bin/sh
#PBS -l nodes=1:ppn=40

# -Xmx1024m                     use up to 1GB RAM (edit to increase)
# -Dfile.encoding=UTF-8         ensure Unicode characters in model files are compatible cross-platform
# -classpath app/NetLogo.jar    specify main jar
# org.nlogo.headless.Main       specify we want headless, not GUI
# "$@"                          pass along any command line arguments

java -Xmx4096m -Dfile.encoding=UTF-8 \
-classpath ~/netlogo-6.0/app/netlogo-6.0.0.jar org.nlogo.headless.Main "$@" \
--model ~/gut-nlogo-model/NLCode.nlogo \
--experiment flowTest \
--table ~/results/flowTest.csv \
--threads 40
