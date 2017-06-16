all: runStopCheck runOnePatch runTwoPatch

runStopCheck: stopCheckTests.java
	javac -cp junit/junit.jar:app/netlogo-6.0.0.jar stopCheckTests.java 

runOnePatch: onePatchTests.java
	javac -cp junit/junit.jar:app/netlogo-6.0.0.jar onePatchTests.java 

runTwoPatch: twoPatchTests.java
	javac -cp junit/junit.jar:app/netlogo-6.0.0.jar twoPatchTests.java 

runExample: ExampTest.java
	javac -cp junit/junit.jar:app/netlogo-6.0.0.jar ExampTest.java
