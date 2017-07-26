breed [bifidos bifido] ;; define the Bifidobacteria breed
breed [desulfos desulfo] ;; define the Desulfovibrio breed
breed [closts clost] ;; define the Clostridia breed
breed [bacteroides bacteroid];; define the bacteroides bacteroidus breed
turtles-own [energy excrete isSeed isStuck remAttempts age flowConst doubConst]
patches-own [glucose FO lactose lactate inulin CS glucosePrev FOPrev lactosePrev
lactatePrev inulinPrev CSPrev glucoseReserve FOReserve lactoseReserve lactateReserve
inulinReserve CSReserve avaMetas stuckChance]
globals [trueAbsorption negMeta testState result]


to display-labels
;; Shows levels of energy on the turtles in the viewer
  ask turtles [set label ""]
  ask desulfos [set label round energy ]
  ask bifidos [set label round energy ]
  ask closts [set label round energy ]
end


to setup

  ;; ensure the model starts from scratch
  clear-all

  ;; Initializing the turtles and patches
	;; populates the world with the bacteria population at the initial-numbers set by the user
  set-default-shape bifidos "dot"
  create-bifidos (initNumBifidos * (1 - seedPercent / 100)) [
    ;;create non-seeds
    set color blue
    set size 0.25
    set label-color blue - 2
    set energy 100
    set excrete false
    set isSeed false
    set isStuck true
    set age random 1000
	  set flowConst 1 ;; can use this to edit the breed specfic flow distance
	  set doubConst 1
    setxy random-xcor random-ycor
  ]

    create-bifidos (initNumBifidos * (seedPercent / 100)) [
    ;;create seeds
    set color blue
    set size 0.25
    set label-color blue - 2
    set energy 100
    set excrete false
    set isSeed true
    set isStuck true
    set age random 1000
	  set flowConst 1 ;; can use this to edit the breed specfic flow distance
	  set doubConst 1
    setxy random-xcor random-ycor
  ]

  set-default-shape desulfos "dot"
  create-desulfos (initNumDesulfos * (1 - seedPercent / 100)) [
    ;;create non-seeds
    set color green
    set size 0.25
    set energy 100
    set excrete false
    set isSeed false
    set isStuck true
	  set age random 1000
	  set flowConst 1
	  set doubConst 1
    setxy random-xcor random-ycor
  ]

  create-desulfos (initNumDesulfos * (seedPercent / 100)) [
    ;;create seeds
    set color green
    set size 0.25
    set energy 100
    set excrete false
    set isSeed true
    set isStuck true
	  set age random 1000
	  set flowConst 1
	  set doubConst 1
    setxy random-xcor random-ycor
  ]

  set-default-shape closts "dot"
  create-closts (initNumClosts * (1 - seedPercent / 100)) [
    ;;create non-seeds
    set color red
    set size 0.25
    set energy 100
    set excrete false
    set isSeed false
    set isStuck true
	  set age random 1000
	  set flowConst 1
	  set doubConst 1
    setxy random-xcor random-ycor
  ]

    create-closts (initNumClosts * (seedPercent / 100)) [
    ;;create seeds
    set color red
    set size 0.25
    set energy 100
    set excrete false
    set isSeed true
    set isStuck true
	  set age random 1000
	  set flowConst 1
	  set doubConst 1
    setxy random-xcor random-ycor
  ]

  set-default-shape bacteroides "dot"
  create-bacteroides (initNumBacteroides * (1 - seedPercent / 100)) [
    ;;create non-seeds
    set color grey
    set size 0.25
    set energy 100
    set excrete false
    set isSeed false
    set isStuck true
	  set age random 1000
	  set flowConst 1
	  set doubConst 1
    setxy random-xcor random-ycor
  ]

  create-bacteroides (initNumBacteroides * (seedPercent / 100)) [
    ;;create seeds
    set color grey
    set size 0.25
    set energy 100
    set excrete false
    set isSeed true
    set isStuck true
	  set age random 1000
	  set flowConst 1
	  set doubConst 1
    setxy random-xcor random-ycor
  ]

	;; initializes the patch variables
  ask patches [
    set glucose 0
    set FO 0
    set lactose 0
    set lactate 0
    set inulin 0
    set CS 0
    set glucosePrev 0
    set FOPrev 0
    set lactosePrev 0
    set lactatePrev 0
    set inulinPrev 0
    set CSPrev 0
    set glucoseReserve 0
    set FOReserve 0
    set lactoseReserve 0
    set lactateReserve 0
    set inulinReserve 0
    set CSReserve 0
    set stuckChance 0
  ]

  ;; setup the true absorption rate
  setTrueAbs

  ;; setup the stuckChance
  setStuckChance

  ;; Setup for stop if negative metas
  set negMeta false

  ;; set time to zero
  reset-ticks

  ;; reset the testState
  set testState 0

end


to go
;; This function determines the behavior at each time tick

  ;; stop if error or unexpected output
  stopCheck

  ;; Modify the energy level of each turtle and metabolite level of each patch
  ask patches [
    patchEat
    storeMetabolites
  ]
  ;; make meta must be in seperate ask, sequential tasks
  ask patches[
    makeMetabolites
  ]

  ;; agents do their other procedures for this tick
  bactTickBehavior

  ;; set the new stuckChance for the patches
  setStuckChance

  ;; change the trueAbsorption
  setTrueAbs

  ;; make agents into seeds
  createSeeds

  ;; Probiotics or bacteria in
  bactIn

  ;; Increment time
  tick

end


to stopCheck
;; code for stopping the simulation on unexpected output

  ;; Stop if negative number of metas calculated
  if negMeta [stop]

  ;; Stop if flowDist > 1
  if flowDist > 1 [
    print "ERROR! flowDist > 1, portions of simulation will not work properly. Terminating Program."
    stop
  ]

  ;; Stop if any population hits 0 or there are too many turtles
  if (count turtles > 1000000) [ stop ]
  if not any? turtles [ stop ] ;; stop if all turtles are dead
end


to setStuckChance
;; controls stuckChance, function of patch population, linear function into asymptote
  ask patches[
    let population count(turtles-here)
    ;; 1 - exponential-like function
    set stuckChance (maxStuckChance - ((maxStuckChance) * population / (midStuckConc + population)))
    if stuckChance < lowStuckBound [set stuckChance 0];; lower bound
  ]
end


to createSeeds
;; controls whether an agent becomes a seed or not
;; first checks if the agent is stuck or not
  ask patches[
    ask turtles-here[
      if (isStuck and (random 100 < seedChance))[
        set isSeed true
      ]
    ]
  ]
end


to setTrueAbs
  ;; controls the true absorption rate

  ;; 0.723823204 is the weighted average immune response coefficient calculated for
  ;; Healthy bacteria gut percentages. This allows the absorption to change due to
  ;; bacteria populations, simulating immune response.

  set trueAbsorption absorption * (0.723823204 / ((0.8 * ((count desulfos) / (count turtles))) +
  (1 * ((count closts) / (count turtles)))+(1.2 * ((count bacteroides) / (count turtles))) +
  (0.7 * ((count bifidos) / (count turtles)))))
end


to bactIn
  ;; controls when probiotics enter system
  if ticks mod tickInflow = 0[
    inConc
  ]
end


;; Each of these functions are currently equivalent, different function so we can expand on it if needed
to deathBifidos
;; Bifidobacteria die if below the energy threshold or if excreted
  if energy <= 0[
    die
  ]
  if excrete [die]
end


to deathClosts
;; Clostrida die if below the energy threshold or if excreted
  if energy <= 0 [
    die
  ]
  if excrete [die]
end


to deathDesulfos
;; Desulfovibrio die if below the energy threshold or if excreted
  if energy <= 0 [
    die
  ]
  if excrete [die]
end


to deathbacteroides
;; bacteroides die if below energy threshold or if excreted
  if energy <= 0 [
    die
  ]
  if excrete [die]
end


to makeMetabolites
;; Runs through all the metabolites and makes them, and moves them.

  if ((inulin < 0) or (CS < 0) or (FO < 0) or (lactose < 0) or (lactate < 0) or (glucose < 0)) [
    print "ERROR! Patch reported negative metabolite. Problem with simulation leading to inaccurate results. Terminating Program."
    set negMeta true
    stop
  ]

  set inulin ((inulin) + inulinReserve)
  set FO ((FO) + FOReserve)
  set lactose ((lactose) + lactoseReserve)
  set lactate ((lactate) + lactateReserve)
  set glucose ((glucose) + glucoseReserve)
  set CS ((CS) + CSReserve)

  let remainFactor 0
  if (flowDist < 1)[set remainFactor (1 - flowDist)]
  set inulin (inulin * remainFactor)
  set FO (FO * remainFactor)
  set lactose (lactose * remainFactor)
  set lactate (lactate * remainFactor)
  set glucose (glucose * remainFactor)
  set CS (CS * remainFactor)

  ;;each left-most patch gets the inFlow number of metas
  ifelse (pxcor = min-pxcor)[
    set inulin ((inulin) + (inFlowInulin))
    set FO ((FO) + (inFlowFO))
    set lactose ((lactose) + (inFlowLactose))
    set lactate ((lactate) + (inFlowLactate))
    set glucose ((glucose) + (inFlowGlucose))
    set CS ((CS) + (inFlowCS))
  ]
  [
    let added ((get-inulin (- (ceiling flowDist)) 0) * (1 - remainFactor))
    ifelse (inulin + added) < 1000[
      set inulin (inulin + (added))
    ]
		[
			set inulin (1000)
		]

    set added ((get-FO (- (ceiling flowDist)) 0) * (1 - remainFactor))
    ifelse (FO + added) < 1000[
      set FO (FO + (added))
    ]
		[
			set FO (1000)
		]

    set added ((get-lactose (- (ceiling flowDist)) 0) * (1 - remainFactor))
    ifelse (lactose + added) < 1000[
      set lactose (lactose + (added))
    ]
		[
			set lactose (1000)
		]

    set added ((get-lactate (- (ceiling flowDist)) 0) * (1 - remainFactor))
    ifelse (lactate + added) < 1000[
      set lactate (lactate + (added))
    ]
		[
			set lactate (1000)
		]

    set added ((get-glucose (- (ceiling flowDist)) 0) * (1 - remainFactor))
    ifelse (glucose + added) < 1000[
      set glucose (glucose + (added))
    ]
		[
			set glucose (1000)
		]

    set added ((get-CS (- (ceiling flowDist)) 0) * (1 - remainFactor))
    ifelse (CS + added) < 1000[
      set CS (CS + (added))
    ]
		[
			set CS (1000)
		]
  ]

  if ((inulin < 0.001)) [
    set inulin 0
  ]

	if ((CS < 0.001)) [
		set CS 0
	]

	if ((FO < 0.001)) [
		set FO 0
	]

	if ((lactose < 0.001)) [
		set lactose 0
	]

	if ((lactate < 0.001)) [
		set lactate 0
	]

	if ((glucose < 0.001)) [
		set glucose 0
	]

	ifelse (((max-pxcor - min-pxcor) < 1))[
		set inulinReserve (0)
  	set FOReserve (0)
  	set lactoseReserve (0)
  	set lactateReserve (0)
  	set glucoseReserve (0)
  	set CSReserve (0)
	][
  	set inulinReserve ((inulin) * reserveFraction * ((max-pxcor - pxcor)/(max-pxcor - min-pxcor)))
  	set FOReserve ((FO) * reserveFraction * ((max-pxcor - pxcor)/(max-pxcor - min-pxcor)))
  	set lactoseReserve ((lactose) * reserveFraction * ((max-pxcor - pxcor)/(max-pxcor - min-pxcor)))
  	set lactateReserve ((lactate) * reserveFraction * ((max-pxcor - pxcor)/(max-pxcor - min-pxcor)))
  	set glucoseReserve ((glucose) * reserveFraction * ((max-pxcor - pxcor)/(max-pxcor - min-pxcor)))
  	set CSReserve ((CS) * reserveFraction * ((max-pxcor - pxcor)/(max-pxcor - min-pxcor)))
	]

  	set inulin ((inulin - inulinReserve) * (1 - trueAbsorption))
  	set FO ((FO - FOReserve) * (1 - trueAbsorption))
  	set lactose ((lactose - lactoseReserve) * (1 - trueAbsorption))
  	set lactate ((lactate - lactateReserve) * (1 - trueAbsorption))
  	set glucose ((glucose - glucoseReserve) * (1 - trueAbsorption))
  	set CS ((CS - CSReserve) * (1 - trueAbsorption))
end


to storeMetabolites
;; Sets previous metaohydrate variables to current levels to allow for correct
;; transfer on ticks
  set inulinPrev ((inulin + inulinReserve))
  set FOPrev ((FO + FOReserve))
  set lactosePrev ((lactose + lactoseReserve))
  set lactatePrev ((lactate + lactateReserve))
  set glucosePrev ((glucose + glucoseReserve))
  set CSPrev ((CS + CSReserve))
end


to bactTickBehavior
;; reproduce the chosen turtle
  ask bifidos [
    flowMove ;; movement of the bacteria by flow
  ;;randMove ;; movement of the bacteria by a combination of motility and other random forces
    checkStuck ;; check if the bacteria becomes stuck or unstuck
    deathBifidos ;; check that the energy of the bacteria is enough, otherwise bacteria dies
    if (age mod bifidoDoub = 0 and age != 0)[ ;;this line controls on what tick mod reproduce
      reproduceBact ;; run the reproduce code for bacteria
    ]
  	set age (age + 1) ;; increase the age of the bacteria with each tick
  ]

  ask desulfos [;;controls the behavior for the desulfos bacteria
    flowMove
  ;;randMove
    checkStuck
    deathDesulfos
    if (age mod desulfoDoub = 0 and age != 0)[
      reproduceBact
    ]
  	set age (age + 1)
  ]

  ask closts [;;controls the behavior for the closts
    flowMove
  ;;randMove
    checkStuck
    deathClosts
    if (age mod clostDoub = 0 and age != 0)[
      reproduceBact
    ]
  	set age (age + 1)
  ]

  ask bacteroides [;;controls the behavior for the bacteroides
    flowMove
  ;;randMove
    checkStuck
    deathbacteroides
    if (age mod bacteroidDoub = 0 and age != 0)[
      reproduceBact
    ]
  	set age (age + 1)
  ]

end


to reproduceBact
;; reproduce the chosen turtle
  if energy > 50 and count turtles-here < 1000[ ;;turtles-here check to model space limit
    let tmp (energy / 2 )
    set energy (tmp) ;; parent's energy is halved
    hatch 1 [
      rt random-float 360
      set energy tmp ;; child gets half of parent's energy
      set isSeed false
      set isStuck false
	    set age 0
    ]
  ]
end


to randMove
;; DISABLED
;; Defines random movement of turtles
;; rotates the orientation of the bacteria randomly within 180 degrees front-facing then moves forward the bacteria's randDist
;; if it would hit go through the simulation boundaries, sets excrete to true
  if (isStuck = false)[
    rt (random 360)

    ifelse (can-move? randDist)
      [fd randDist]
      [set excrete true]
  ]

end


to flowMove
;; moves the bacteria by the flow distance * the bacteria's flow constant
;; if xcor would pass the max-pxcor with movement, sets excrete to true
  if (isStuck = false and isSeed = false)[
    ifelse (xcor + flowDist * flowConst >= (max-pxcor + 0.5))
      [set excrete true]
      [set xcor (xcor + flowDist * flowConst)]
  ]

end


to checkStuck
;; checks if the bacteria should be stuck or unstucked based on the chances
  ifelse(not isStuck and (random-float 100 < stuckChance))[
    set isStuck true
  ]
  [;;else
    if(isStuck and (random-float 100 < unstuckChance))[
      set isStuck false
    ]
  ]
end


to inConc
;; controls the amount of each type of bacteria flowing in to the simulation
;; similar to the code in go, but bacteria are now placed at only in the first column

  create-bifidos inConcBifidos [
    set color blue
    set size 1
    set label-color blue - 2
    set energy 100
    set excrete false
    set isSeed false
    set isStuck false
    set age random 1000
	  set flowConst 1
	  set doubConst 1
    setxy min-pxcor - 0.5 random-ycor

  ]

  create-desulfos inConcDesulfos [
    set color green
    set size 1
    set energy 100
    set excrete false
    set isSeed false
    set age random 1000
	  set flowConst 1
	  set doubConst 1
    setxy min-pxcor - 0.5 random-ycor

  ]

  create-closts inConcClosts [
    set color red
    set size 1
    set energy 100
    set excrete false
    set isSeed false
    set isStuck false
    set age random 1000
	  set flowConst 1
	  set doubConst 1
    setxy min-pxcor - 0.5 random-ycor

  ]
  create-bacteroides inConcBacteroides [
    set color grey
    set size 1
    set energy 100
    set excrete false
    set isSeed false
    set isStuck false
    set age random 1000
	  set flowConst 1
	  set doubConst 1
    setxy min-pxcor - 0.5 random-ycor

  ]
end


to bactEat [metaNum]
;; run this through a turtle with a metaNum parameter to have them try to eat the carb

  if (metaNum = 10)[;;CS
    ifelse (breed = desulfos)[;; check correct breed
      set energy (energy + 50);; increase the energy of the bacteria
      ask patch-here [
          set CS (CS - 1);; reduce the meta count
        if (CS < 1)[;; remove the meta from avaMetas if there is no more of it
          set avaMetas remove 10 avaMetas
        ]
      ]
    ]
    [;;else
      ;;do nothing
    ]
  ]

  if (metaNum = 11)[;;FO
    ifelse (breed = closts or breed = bacteroides)[
      set energy (energy + 25)
      ask patch-here [
        set FO (FO - 1)
        if (FO < 1)[
          set avaMetas remove 11 avaMetas
        ]
      ]
    ]
    [;;else
      if(breed = bifidos)[
        set energy (energy + 50)
        ask patch-here [
          set FO (FO - 1)
          if (FO < 1)[
            set avaMetas remove 11 avaMetas
          ]
        ]
        ask patch-here [
          set lactate (lactate + bifido-lactate-production)
        ]
      ]
    ];;end else
  ]

  if (metaNum = 12)[;;GLUCOSE
    ifelse (breed = closts or breed = bacteroides)[
      set energy (energy + 50)
      ask patch-here [
        set glucose (glucose - 1)
        if (glucose < 1)[
          set avaMetas remove 12 avaMetas
        ]
      ]
    ]
    [;;else
      if (breed = bifidos) [
        set energy (energy + 25)
        ask patch-here [
        	set glucose (glucose - 1)
          if (glucose < 1)[
            set avaMetas remove 12 avaMetas
          ]
        ]
        ask patch-here [
          set lactate (lactate + bifido-lactate-production)
        ]
      ]
    ];;end else
  ]

  if (metaNum = 13)[;;INULIN
    ifelse (breed = closts or breed = bacteroides)[
      set energy (energy + 25)
      ask patch-here [
        set inulin (inulin - 1)
        if (inulin < 1)[
          set avaMetas remove 13 avaMetas
        ]
      ]
    ]
    [;;else
      if (breed = bifidos) [
      set energy (energy + 25)
        ask patch-here [
          	set inulin (inulin - 1)
          if (inulin < 1)[
            set avaMetas remove 13 avaMetas
          ]
        ]
        ask patch-here [
          set lactate (lactate + bifido-lactate-production)
        ]
      ]
    ];;end else
  ]

  if (metaNum = 14)[;;LACTATE
    ifelse (breed = (desulfos))[
      set energy (energy + 50)
      ask patch-here [
        set lactate (lactate - 1)
        if (lactate < 1)[
          set avaMetas remove 14 avaMetas
        ]
      ]
    ]
    [;;else
      ;;do nothing
    ]
  ]

  ifelse (metaNum = 15)[;;LACTOSE
    ifelse (breed = closts or breed = bacteroides)[
      ifelse (breed = closts)[
        set energy (energy + 25)
      ]
      [;;else
        set energy (energy + 50)
      ];;end else
      ask patch-here [
        set lactose (lactose - 1)
        if (lactose < 1)[
          set avaMetas remove 15 avaMetas
        ]
      ]
    ]
    [;;else
      if (breed = bifidos) [
        set energy (energy + 50)
        ask patch-here [
          	set lactose (lactose - 1)
          if (lactose < 1)[
            set avaMetas remove 15 avaMetas
          ]
        ]
        ask patch-here [
          set lactate (lactate + bifido-lactate-production)
        ]
      ]
    ];;end else
  ]
  [;;else
    ;;do nothing
  ]
end

to patchEat
;; run this on a ask patches to have them start the turtle eating process
  ask turtles-here [
    set remAttempts 2 ;; reset the number of attempts
    set energy (energy - (100 / 1440)) ;; decrease the energy of the bacteria, currently survive 24 hours no eat
  ]
  let allMetas (list CS FO glucose inulin lactate lactose);; list containing numbers of all the metas
  set avaMetas []

  ;; initialize the two lists
  let hungryBact (turtles-here with [(energy < 80) and (remAttempts > 0)])
  let i 0
  while [i < (length(allMetas))][
    if (item i allMetas >= 1) [
      set avaMetas lput (i + 10) avaMetas
    ]
    set i (i + 1)
  ]
  let iter 0 ;; used to limit the number of times the next while loop will occur, aribitrary
  ;; do the eating till no metas or not hungry
  while [(length(avaMetas) > 0) and any? hungryBact and iter < 100] [
    ;; code here to randomly select a turtle from hungryBact and then ask it to run bactEat with a random meta from ava. list
    ask one-of hungryBact [
      bactEat(one-of avaMetas)
      set remAttempts remAttempts - 1
    ]
    ;;re-bound agent set
    set hungryBact (turtles-here with [(energy < 80) and (remAttempts > 0)])

    set iter (iter + 1)
  ]
end

to-report getAllBactPatchLin
;; Returns a list of the number of bacteria on each patch
;; Only works properly with a world with height of 1
  let data map getNumBactLin (range min-pxcor (max-pxcor + 1))
  report (data)
end

to-report getNumBactLin [xVal]
;; Returns the number of bacteria on the patch at given x-coord
;; Only works properly with a world with height of 1
  report [count(turtles-here)] of patch xVal 0
end

to-report getNumSeeds
;; Returns the number of bacteria with isSeed set to true
  report count turtles with [isSeed = true]
end

to-report getStuckChance [xVal]
;; Needed to run JUnit tests
  report [stuckChance] of patch xVal 0
end

to-report gettrueAbs
;; Needed to run JUnit tests
  report trueAbsorption
end

to-report getResult
;; Needed to run JUnit tests
  report result
end

;; CarbReporters

to-report get-glucose [target-patch-x-coord target-patch-y-coord]
;; Returns glucose value at passed coordinate
    report [glucosePrev] of patch-at target-patch-x-coord target-patch-y-coord
end


to-report get-lactose [target-patch-x-coord target-patch-y-coord]
;; Returns lactose value at passed coordinate
    report [lactosePrev] of patch-at target-patch-x-coord target-patch-y-coord
end


to-report get-inulin [target-patch-x-coord target-patch-y-coord]
;; Returns inulin value at passed coordinate
    report [inulinPrev] of patch-at target-patch-x-coord target-patch-y-coord
end


to-report get-lactate [target-patch-x-coord target-patch-y-coord]
;; Returns lactate value at passed coordinate
    report [lactatePrev] of patch-at target-patch-x-coord target-patch-y-coord
end


to-report get-FO [target-patch-x-coord target-patch-y-coord]
;; Returns FO value at passed coordinate
    report [FOPrev] of patch-at target-patch-x-coord target-patch-y-coord
end


to-report get-CS [target-patch-x-coord target-patch-y-coord]
;; Returns CS value at passed coordinate
    report [CSPrev] of patch-at target-patch-x-coord target-patch-y-coord
end


;; Experiments, used in the cluster runs to control the simulation

;; note that these controllers won't actually work on ticks not multiple of 100 because of how BehaviorSpace is set up
to flowRateTest
;; changes the flowrate by testConst after at S-S then reduces it after a week of time
  if (ticks >= 10080 and testState = 0)[
    set flowDist (flowDist * testConst)
    set testState 1
  ]
  if (ticks >= 20160 and testState = 1)[
    set flowDist (flowDist / testConst)
    set testState 2
  ]
end

to glucTest
;; changes the CS inConc for carb experiment
  if (ticks >= 10080 and testState = 0)[
    set inFlowGlucose (inFlowGlucose * testConst)
    set testState 1
  ]
  if (ticks >= 20160 and testState = 1)[
    set inFlowGlucose (inFlowGlucose / testConst)
    set testState 2
  ]
end

to bifidosTest
;; changes inConcBifidos for probiotic experiment
  if (ticks >= 10080 and testState = 0)[
    set inConcBifidos (5000 * testConst)
    set testState 1
  ]
  if (ticks >= 20160 and testState = 1)[
    set inConcBifidos (0)
    set testState 2
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
7
60
5015
119
-1
-1
50.0
1
10
1
1
1
0
0
1
1
0
99
0
0
1
1
1
ticks
30.0

BUTTON
28
14
92
47
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
113
14
176
47
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
884
119
1287
435
Populations
Time
Populations
0.0
10.0
0.0
10.0
true
true
"ifelse plots-on? [\nauto-plot-on\n]\n[auto-plot-off]" ""
PENS
"Closts" 1.0 0 -2674135 true "" "plot count closts"
"Bifidos" 1.0 0 -13345367 true "" "plot count bifidos"
"Desulfos" 1.0 0 -10899396 true "" "plot count desulfos"
"Bacteroides" 1.0 0 -7500403 true "" "plot count bacteroides"

MONITOR
87
476
161
521
Cloststridia
count closts
17
1
11

MONITOR
161
476
249
521
Bifidobacteria
count bifidos
17
1
11

MONITOR
249
476
334
521
Desulfovibrio
count desulfos
17
1
11

MONITOR
-1
521
130
566
Percentage Clostridia
100 * count closts / count turtles
2
1
11

MONITOR
130
521
285
566
Percentage Bifidobacteria
100 * count bifidos / count turtles
2
1
11

MONITOR
285
521
436
566
Percentage Desulfovibrio
100 * count desulfos / count turtles
2
1
11

MONITOR
-1
476
88
521
Total Bacteria
count turtles
3
1
11

MONITOR
631
476
688
521
Glucose
sum [glucose] of patches
0
1
11

MONITOR
574
476
631
521
FO
sum [FO] of patches
2
1
11

MONITOR
460
476
517
521
Lactate
sum [lactate] of patches
2
1
11

MONITOR
688
476
745
521
CS
sum [CS] of patches
2
1
11

MONITOR
403
476
460
521
Inulin
sum [inulin] of patches
2
1
11

MONITOR
517
476
574
521
Lactose
sum [Lactose] of patches
2
1
11

MONITOR
334
476
403
521
Bacteroides
count bacteroides
17
1
11

MONITOR
436
521
580
566
Percentage Bacteroides
100 * count bacteroides / count turtles
2
1
11

SWITCH
882
435
988
468
plots-on?
plots-on?
0
1
-1000

INPUTBOX
627
119
753
179
inConcBacteroides
0.0
1
0
Number

INPUTBOX
627
179
753
239
inConcBifidos
0.0
1
0
Number

INPUTBOX
752
119
884
179
inConcClosts
0.0
1
0
Number

INPUTBOX
752
179
884
239
inConcDesulfos
0.0
1
0
Number

INPUTBOX
1387
159
1514
219
randDist
0.0
1
0
Number

INPUTBOX
627
239
754
299
tickInflow
480.0
1
0
Number

INPUTBOX
162
119
317
179
initNumBifidos
23562.0
1
0
Number

INPUTBOX
162
179
317
239
initNumBacteroides
5490.0
1
0
Number

INPUTBOX
162
239
317
299
initNumClosts
921.0
1
0
Number

INPUTBOX
162
299
317
359
initNumDesulfos
70.0
1
0
Number

TEXTBOX
713
418
805
436
Flow Variables
14
0.0
1

TEXTBOX
414
369
557
387
Metabolite Variables
14
0.0
1

TEXTBOX
1423
220
1491
271
randFlow Variables\n(Disabled)
14
0.0
1

TEXTBOX
197
397
282
415
Initial Bacteria
14
0.0
1

TEXTBOX
17
364
158
382
Bacteria Reproduction
14
0.0
1

MONITOR
580
521
682
566
gutPerm
trueAbsorption
6
1
11

INPUTBOX
7
119
162
179
bifidoDoub
330.0
1
0
Number

INPUTBOX
7
179
162
239
desulfoDoub
330.0
1
0
Number

INPUTBOX
7
299
162
359
clostDoub
330.0
1
0
Number

INPUTBOX
7
239
162
299
bacteroidDoub
330.0
1
0
Number

INPUTBOX
317
119
472
179
inFlowInulin
10.0
1
0
Number

INPUTBOX
317
239
472
299
inFlowFO
25.0
1
0
Number

INPUTBOX
472
239
627
299
inFlowLactose
15.0
1
0
Number

INPUTBOX
472
179
627
239
inFlowLactate
0.0
1
0
Number

INPUTBOX
472
119
627
179
inFlowGlucose
30.0
1
0
Number

INPUTBOX
317
179
472
239
inFlowCS
0.1
1
0
Number

INPUTBOX
317
299
472
359
bifido-lactate-production
0.005
1
0
Number

INPUTBOX
1220
435
1287
495
testConst
1.0
1
0
Number

INPUTBOX
627
299
754
359
midStuckConc
10.0
1
0
Number

SLIDER
161
359
318
392
seedPercent
seedPercent
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
472
299
627
332
absorption
absorption
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
754
337
884
370
unstuckChance
unstuckChance
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
754
304
884
337
lowStuckBound
lowStuckBound
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
754
271
884
304
seedChance
seedChance
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
754
239
884
272
flowDist
flowDist
0
1
0.278
0.01
1
NIL
HORIZONTAL

SLIDER
754
370
884
403
maxStuckChance
maxStuckChance
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
472
332
627
365
reserveFraction
reserveFraction
0
100
0.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## Model Summary
This model represents the relationships between _Bifidobaceria_, _Desulfovibrio_, and _Clostridia_. These bacteria are important in the appearance of Autism Spectrum Disorders (ASDs). High levels of _Desulfovibrio_ and _Clostridia_ and low levels of _Bifidobacteria_ have been found in the gut of children with ASDs. Therefore, a gut microbiome dominated by _Bifidobacteria_ is likely to be that of a healthy child, whereas a gut microbiome dominated by _Desulfovibrio_ and/or _Clostridia_ is likely to be that of an autistic child.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bacteria
true
0
Circle -7500403 true true 103 28 95
Circle -7500403 true true 105 45 90
Circle -7500403 true true 105 60 90
Circle -7500403 true true 105 75 90
Circle -7500403 true true 105 90 90
Circle -7500403 true true 105 105 90
Circle -7500403 true true 105 120 90
Circle -7500403 true true 105 135 90
Circle -7500403 true true 105 150 90
Circle -7500403 true true 105 165 90
Circle -7500403 true true 105 180 90

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="checkStable" repetitions="4" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100[
  go
]</go>
    <timeLimit steps="50"/>
    <metric>testConst</metric>
    <metric>flowDist</metric>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="23562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5490"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumClosts">
      <value value="921"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="27"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="flowTest" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100 [
  go
]
flowRateTest</go>
    <timeLimit steps="303"/>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="testConst">
      <value value="0.333"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="23562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5490"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumClosts">
      <value value="921"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="flowDist">
      <value value="0.278"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="glucTest" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100 [
  go
]
glucTest</go>
    <timeLimit steps="303"/>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="testConst">
      <value value="0.5"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="23562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5490"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumClosts">
      <value value="921"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inFlowGlucose">
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bifidosTest" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100 [
  go
]
bifidosTest</go>
    <timeLimit steps="303"/>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="testConst">
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="23562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5490"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumClosts">
      <value value="921"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcBifidos">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="flowTestB" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100 [
  go
]
flowRateTest</go>
    <timeLimit steps="303"/>
    <metric>testConst</metric>
    <metric>flowDist</metric>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="testConst">
      <value value="0.333"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="22793"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5311"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumClosts">
      <value value="1842"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="flowDist">
      <value value="0.278"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="glucTestB" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100 [
  go
]
glucTest</go>
    <timeLimit steps="303"/>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="testConst">
      <value value="0.5"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="22793"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5311"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumClosts">
      <value value="1842"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inFlowGlucose">
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bifidosTestB" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100 [
  go
]
bifidosTest</go>
    <timeLimit steps="303"/>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="testConst">
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="22793"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5311"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumClosts">
      <value value="1842"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inConcBifidos">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="controlHealthy" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100 [
  go
]</go>
    <timeLimit steps="303"/>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="initNumClosts">
      <value value="921"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="23562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5490"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testConst">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="controlAutistic" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 100 [
  go
]</go>
    <timeLimit steps="303"/>
    <metric>count bifidos</metric>
    <metric>count bacteroides</metric>
    <metric>count closts</metric>
    <metric>count desulfos</metric>
    <metric>sum [inulin] of patches</metric>
    <metric>sum [lactate] of patches</metric>
    <metric>sum [lactose] of patches</metric>
    <metric>sum [FO] of patches</metric>
    <metric>sum [glucose] of patches</metric>
    <metric>sum [CS] of patches</metric>
    <metric>trueAbsorption</metric>
    <metric>getNumSeeds</metric>
    <metric>getAllBactPatchLin</metric>
    <enumeratedValueSet variable="initNumBifidos">
      <value value="22793"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumBacteroides">
      <value value="5311"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumClosts">
      <value value="1842"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initNumDesulfos">
      <value value="54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="testConst">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
