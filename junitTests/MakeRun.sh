<<<<<<< HEAD
#java -Djava.awt.headless=true -cp app/netlogo-6.0.0.jar:junit/junit.jar:junit/hamcrest.jar:. \
#org.junit.runner.JUnitCore ExampTest

java -Djava.awt.headless=true -cp app/netlogo-6.0.0.jar:junit/junit.jar:junit/hamcrest.jar:. \
org.junit.runner.JUnitCore stopCheckTests

java -Djava.awt.headless=true -cp app/netlogo-6.0.0.jar:junit/junit.jar:junit/hamcrest.jar:. \
org.junit.runner.JUnitCore onePatchTests

java -Djava.awt.headless=true -cp app/netlogo-6.0.0.jar:junit/junit.jar:junit/hamcrest.jar:. \
org.junit.runner.JUnitCore twoPatchTests
