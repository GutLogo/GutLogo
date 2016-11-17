extensions [profiler]
;///////////////////////////VARIABLES///////////////////////////////////////
breed [bifidos bifido] ;define the Bifidobacteria breed
breed [desulfos desulfo] ;define the Desulfovibrio breed
breed [closts clost] ;define the Clostridia breed
breed [vulgats vulgat]; define the Bacteriodes Vulgatus breed
turtles-own [energy excrete isSeed isStuck remAttempts age flowConst doubConst]
patches-own [antioxidants oxidants glucose FO lactose lactate inulin CS varA varB glucosePrev FOPrev lactosePrev
lactatePrev inulinPrev CSPrev glucoseReserve FOReserve lactoseReserve lactateReserve inulinReserve CSReserve avaCarbs]
globals [trueAbsorption negCarb]
;///////////////////////////VARIABLES///////////////////////////////////////

;///////////////////////////DISPLAY-LABLELS///////////////////////////////////////
; Shows levels of energy on the turtles in the viewer
to display-labels
  ask turtles [set label ""]
  ask desulfos [set label round energy ]
  ask bifidos [set label round energy ]
  ask closts [set label round energy ]
end
;///////////////////////////DISPLAY-LABLELS///////////////////////////////////////

;///////////////////////////SETUP///////////////////////////////////////
to setup

  ;ensure the model starts from scratch
  clear-all

  ; Initializing the turtles and patches
  set-default-shape bifidos "bacteria"
  create-bifidos initial-number-bifidos [
    set color blue
    set size 1
    set label-color blue - 2
    set energy 100
    set excrete false
    set isSeed true
    set isStuck true
    set age random 1000
	  set flowConst 1 ;edit this
	  set doubConst 1
    setxy random-xcor random-ycor

  ]
  set-default-shape desulfos "bacteria"
  create-desulfos initial-number-desulfos [
    set color green
    set size 1
    set energy 100
    set excrete false
    set isSeed true
    set isStuck true
	  set age random 1000
	  set flowConst 1 ;edit this
	  set doubConst 1
    setxy random-xcor random-ycor
  ]

  set-default-shape closts "bacteria"
  create-closts initial-number-closts [
    set color red
    set size 1
    set energy 100
    set excrete false
    set isSeed true
    set isStuck true
	  set age random 1000
	  set flowConst 1 ;edit this
	  set doubConst 1
    setxy random-xcor random-ycor
  ]

  set-default-shape vulgats "bacteria"
  create-vulgats initial-number-vulgats [
    set color grey
    set size 1
    set energy 100
    set excrete false
    set isSeed true
    set isStuck true
	  set age random 1000
	  set flowConst 1 ;edit this
	  set doubConst 1
    setxy random-xcor random-ycor
  ]

  ask patches [
    set glucose 10
    set FO 10
    set lactose 10
    set lactate 10
    set inulin 10
    set CS 10
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
  ]

  ; 0.723823204 is the weighted average immune response coefficient calculated for
  ; Healthy bacteria gut percentages. This allows the absorption to change due to
  ; bacteria populations, simulating immune response.
  set trueAbsorption absorption * (0.723823204 / ((0.8 * ((count desulfos) / (count turtles))) +
  (1 * ((count closts) / (count turtles)))+(1.2 * ((count vulgats) / (count turtles))) +
  (0.7 * ((count bifidos) / (count turtles)))))

  ; Setup for stop if negative carbs
  set negCarb false

  ;set time to zero
  reset-ticks
end

;///////////////////////////SETUP///////////////////////////////////////

;///////////////////////////GO///////////////////////////////////////
; This function determines the behavior at each time tick
to go

  ; 0.723823204 is the weighted average immune response coefficient calculated for
  ; Healthy bacteria gut percentages. This allows the absorption to change due to
  ; bacteria populations, simulating immune response.
  set trueAbsorption absorption * (0.723823204 / ((0.8 * ((count desulfos) / (count turtles))) +
  (1 * ((count closts) / (count turtles)))+(1.2 * ((count vulgats) / (count turtles))) +
  (0.7 * ((count bifidos) / (count turtles)))))

  ; Uncomment the following line to display energy on the turtles
  ; display-labels

  if not any? turtles [ stop ] ; stop if all turtles are dead

  ; Modify the energy levels of each turtles and carbohydrate
  ; level of each patch
  ask patches [
    patchEat
    store-carbohydrates
  ]
  ask patches[
    make-carbohydrates
  ]
  bacteria-tick-behavior

  if ticks mod tickInflow = 0[
    inConc
  ]

  ; Increment time
  tick
  ; Stop if any population hits 0 or there are too many turtles
  if count turtles > 1000000 [stop]
  if count turtles = 0 [stop]
  ; Stop if negative number of carbs calculated
  if negCarb [stop]
end
;///////////////////////////GO///////////////////////////////////////


;///////////////////////////DEATH-BACTERIA///////////////////////////////////////
; Bifidobacteria die if below the energy threshold or if excreted
to death-bifidos
  if energy < 5[
    ;ifelse isSeed
    ;[set energy 100]
    die
  ]
  if excrete [die]
end

; Clostrida die if below the energy threshold or if excreted
to death-closts
  if energy < 5 [
    ;ifelse isSeed
    ;[set energy 100]
    die
  ]
  if excrete [die]
end

; Desulfovibrio die if below the energy threshold or if excreted
to death-desulfos
  if energy < 5 [
    ;ifelse isSeed
    ;[set energy 100]
    die
  ]
  if excrete [die]
end

; Vulgatus die if below energy threshold or if excreted
to death-vulgats
  if energy < 5 [
    ;ifelse isSeed
    ;[set energy 100]
    die
  ]
  if excrete [die]
end
;///////////////////////////DEATH-BACTERIA///////////////////////////////////////

;///////////////////////////MAKE-CAROBOHYDRATES///////////////////////////////////////
; Runs through all the carbohydrates and makes them, and moves them.
to make-carbohydrates

  if ((inulin < 0) or (CS < 0) or (FO < 0) or (lactose < 0) or (lactate < 0) or (glucose < 0)) [
    print "ERROR! Patch reported negative carbohydrate. Problem with simulation leading to inaccurate results. Terminating Program."
    set negCarb true
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

  ifelse (pxcor < (min-pxcor + ceiling (flowDist)))[
    set inulin ((inulin) + (inFlowInulin))
    set FO ((FO) + (inFlowFO))
    set lactose ((lactose) + (inFlowLactose))
    set lactate ((lactate) + (inFlowLactate))
    set glucose ((glucose) + (inFlowGlucose))
    set CS ((CS) + (inFlowCS))
  ]
  [
    let added ((get-inulin (- (ceiling flowDist)) 0) * (1 - remainFactor))
    set inulin (inulin + (added))

    set added ((get-FO (- (ceiling flowDist)) 0) * (1 - remainFactor))
    set FO (FO + (added))

    set added ((get-lactose (- (ceiling flowDist)) 0) * (1 - remainFactor))
    set lactose (lactose + (added))

    set added ((get-lactate (- (ceiling flowDist)) 0) * (1 - remainFactor))
    if (lactate + added) < 200[
      set lactate (lactate + (added))
    ]

    set added ((get-glucose (- (ceiling flowDist)) 0) * (1 - remainFactor))
    set glucose (glucose + (added))

    set added ((get-CS (- (ceiling flowDist)) 0) * (1 - remainFactor))
    if (CS + added) < 200[
      set CS (CS + (added))
    ]
  ]
  set inulinReserve ((inulin) * reserveFraction * ((max-pxcor - pxcor)/(max-pxcor - min-pxcor)))
  set FOReserve ((FO) * reserveFraction * ((max-pxcor - pxcor)/(max-pxcor - min-pxcor)))
  set lactoseReserve ((lactose) * reserveFraction * ((max-pxcor - pxcor)/(max-pxcor - min-pxcor)))
  set lactateReserve ((lactate) * reserveFraction * ((max-pxcor - pxcor)/(max-pxcor - min-pxcor)))
  set glucoseReserve ((glucose) * reserveFraction * ((max-pxcor - pxcor)/(max-pxcor - min-pxcor)))
  set CSReserve ((CS) * reserveFraction * ((max-pxcor - pxcor)/(max-pxcor - min-pxcor)))

  set inulin ((inulin - inulinReserve) * (1 - trueAbsorption))
  set FO ((FO - FOReserve) * (1 - trueAbsorption))
  set lactose ((lactose - lactoseReserve) * (1 - trueAbsorption))
  set lactate ((lactate - lactateReserve) * (1 - trueAbsorption))
  set glucose ((glucose - glucoseReserve) * (1 - trueAbsorption))
  set CS ((CS - CSReserve) * (1 - trueAbsorption))
end
;///////////////////////////MAKE-CAROBOHYDRATES///////////////////////////////////////

;///////////////////////////STORE-CARBOHYDRATES///////////////////////////////////////
; Sets previous carbohydrate variables to current levels to allow for correct
; transfer on ticks
to store-carbohydrates
  set inulinPrev ((inulin))
  set FOPrev ((FO))
  set lactosePrev ((lactose))
  set lactatePrev ((lactate))
  set glucosePrev ((glucose))
  set CSPrev ((CS))
end
;///////////////////////////STORE-CARBOHYDRATES///////////////////////////////////////

;///////////////////////////BACTERIA-TICK-BEHAVIOR///////////////////////////////////////
; Determines the turtle behavior for this tick

to bacteria-tick-behavior
  ask bifidos [
    flowMove
    bacteriaMove
	  checkStuck
    death-bifidos
    if (age mod bifidoDoub / doubConst = 0 and age != 0)[ ;this line controls on what tick mod reproduce
      reproduceBact
    ]
  	set age (age + 1)
  ]

  ask desulfos [;controls the behavior for the desulfos bacteria
    flowMove
    bacteriaMove
	  checkStuck
    death-desulfos
    if (age mod desulfoDoub / doubConst = 0 and age != 0)[
      reproduceBact
    ]
  	set age (age + 1)
  ]

  ask closts [;controls the behavior for the closts
    flowMove
    bacteriaMove
	  checkStuck
    death-closts
    if (age mod clostDoub / doubConst = 0 and age != 0)[
      reproduceBact
    ]
  	set age (age + 1)
  ]

  ask vulgats [;controls the behavior for the vulgats
    flowMove
    bacteriaMove
	  checkStuck
    death-vulgats
    if (age mod vulgatDoub / doubConst = 0 and age != 0)[
      reproduceBact
    ]
  	set age (age + 1)
  ]

end
;///////////////////////////BACTERIA-TICK-BEHAVIOR///////////////////////////////////////

;///////////////////////////reproduceBact///////////////////////////////////////:
;reproduce the chosen turtle
to reproduceBact
  if energy > 50 [
    let tmp (energy / 2 )
    set energy (tmp)
    hatch 1 [
      rt random-float 360
      set energy tmp
      set isStuck false
	    set age 0
    ]
  ]
end
;///////////////////////////reproduceBact///////////////////////////////////////

;///////////////////////////bacteriaMove///////////////////////////////////////
; Defines random movement of turtles
to bacteriaMove
; rotates the orientation of the bacteria randomly within 180 degrees front-facing then moves forward the bacteria's motilDist
;may disable with motility assumption
; if it would hit go through the simulation boundaries, sets excrete to true
  if (isStuck = false)[
    rt (random 360)

    ifelse (can-move? motilDist)
      [fd motilDist]
      [set excrete true]
  ]

end
;///////////////////////////bacteriaMove///////////////////////////////////////

;///////////////////////////flowMove///////////////////////////////////////
to flowMove
;if xcor would pass the max-pxcor with movement, sets excrete to true
  if (isStuck = false)[
    ifelse (xcor + flowDist * flowConst >= (max-pxcor + 0.5))
      [set excrete true]
      [set xcor (xcor + flowDist * flowConst)]
  ]

end
;///////////////////////////flowMove///////////////////////////////////////

;///////////////////////////checkStuck///////////////////////////////////////
to checkStuck
  if(not isSeed)[
    if(not isStuck and (random 100 < stuckChance))[
	    set isStuck true
    ]
    ifelse(isStuck and (random 100 < unstuckChance))[
	    set isStuck false
    ][;else
			if(random 100 < seedChance)[
			  set isSeed true
			]
		]
  ]
end
;///////////////////////////checkStuck///////////////////////////////////////

;///////////////////////////inConc///////////////////////////////////////
to inConc
;controls the amount of each type of bacteria flowing in to the simulation

  create-bifidos inConcBifidos [
    set color blue
    set size 1
    set label-color blue - 2
    set energy 100
    set excrete false
    set isSeed false
    set isStuck false
	  set age 0
	  set flowConst 1 ;edit this
	  set doubConst 1
    setxy min-pxcor - 0.5 random-ycor

  ]

  create-desulfos inConcDesulfos [
    set color green
    set size 1
    set energy 100
    set excrete false
    set isSeed false
    set isStuck false
	  set age 0
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
	  set age 0
	  set flowConst 1
	  set doubConst 1
    setxy min-pxcor - 0.5 random-ycor

  ]
  create-vulgats inConcVulgats [
    set color grey
    set size 1
    set energy 100
    set excrete false
    set isSeed false
    set isStuck false
	  set age 0
	  set flowConst 1
	  set doubConst 1
    setxy min-pxcor - 0.5 random-ycor

  ]
end
;///////////////////////////inConc///////////////////////////////////////


;///////////////////////////bactEat///////////////////////////////////////
to bactEat [carbNum]
;run this through a turtle with a carbNum parameter to have them try to eat the carb
;include the odd bifido lactate production
  if (carbNum = 10)[;CS
    ifelse (breed = desulfos)[
      set energy (energy + 50)
      ask patch-here [
        set CS (CS - 1)
		if (CS < 1)[
			set avaCarbs remove 10 avaCarbs
		]
      ]
    ]
    [;else
      ;do nothing
    ]
  ]

  if (carbNum = 11)[;FO
    ifelse (breed = closts or breed = vulgats)[
      set energy (energy + 25)
      ask patch-here [
        set FO (FO - 1)
		if (FO < 1)[
			set avaCarbs remove 11 avaCarbs
		]
      ]
    ]
    [;else
      if(breed = bifidos)[
        set energy (energy + 50)
        ask patch-here [
          set FO (FO - 1)
			if (FO < 1)[
				set avaCarbs remove 11 avaCarbs
			]
        ]
        if (random-float 100 < bifido-lactate-production) [
          ask patch-here [
            set lactate (lactate + 1)
          ]
        ]
      ]
    ];end else
  ]

  if (carbNum = 12)[;GLUCOSE
    ifelse (breed = closts or breed = vulgats)[
      set energy (energy + 50)
      ask patch-here [
        set glucose (glucose - 1)
		if (glucose < 1)[
			set avaCarbs remove 12 avaCarbs
		]
      ]
    ]
    [;else
      if (breed = bifidos) [
        set energy (energy + 25)
        ask patch-here [
        	set glucose (glucose - 1)
			if (glucose < 1)[
				set avaCarbs remove 12 avaCarbs
			]
        ]
        if (random-float 100 < bifido-lactate-production) [
          ask patch-here [
            set lactate (lactate + 1)
          ]
        ]
      ]
    ];end else
  ]

  if (carbNum = 13)[;INULIN
    ifelse (breed = closts or breed = vulgats)[
      set energy (energy + 25)
      ask patch-here [
        set inulin (inulin - 1)
		if (inulin < 1)[
			set avaCarbs remove 13 avaCarbs
		]
      ]
    ]
    [;else
      if (breed = bifidos) [
      set energy (energy + 25)
        ask patch-here [
          	set inulin (inulin - 1)
			if (inulin < 1)[
				set avaCarbs remove 13 avaCarbs
			]
        ]
        if (random-float 100 < bifido-lactate-production) [
          ask patch-here [
            set lactate (lactate + 1)
          ]
        ]
      ]
    ];end else
  ]

  if (carbNum = 14)[;LACTATE
    ifelse (breed = (desulfos))[
      set energy (energy + 50)
      ask patch-here [
        set lactate (lactate - 1)
		if (lactate < 1)[
			set avaCarbs remove 14 avaCarbs
		]
      ]
    ]
    [;else
      ;do nothing
    ]
  ]

  ifelse (carbNum = 15)[;LACTOSE
    ifelse (breed = closts or breed = vulgats)[
      ifelse (breed = closts)[
        set energy (energy + 25)
      ]
      [;else
        set energy (energy + 50)
      ];end else
      ask patch-here [
        set lactose (lactose - 1)
		if (lactose < 1)[
			set avaCarbs remove 15 avaCarbs
		]
      ]
    ]
    [;else
      if (breed = bifidos) [
        set energy (energy + 50)
        ask patch-here [
          	set lactose (lactose - 1)
			if (lactose < 1)[
				set avaCarbs remove 15 avaCarbs
			]
        ]
        if (random-float 100 < bifido-lactate-production) [
          ask patch-here [
            set lactate (lactate + 1)
          ]
        ]
      ]
    ];end else
  ]
  [;else
    ;do nothing
  ]
end
;///////////////////////////bactEat///////////////////////////////////////

;///////////////////////////patchEat///////////////////////////////////////
to patchEat
;run this on a ask patches to have them start the turtle eating process
  ask turtles-here [
    set remAttempts 5 ;reset the number of attempts
    set energy (energy - (100 / 1440)) ;decrease the energy of the bacteria, currently survive 24 hours no eat
  ]
  let allCarbs (list CS FO glucose inulin lactate lactose)
  set avaCarbs []

  ;initialize the two lists
  let hungryBact (turtles-here with [(energy < 80) and (remAttempts > 0)])
  let i 1
  while [i < (length(allCarbs))][
    if (item i allCarbs >= 1) [
      set avaCarbs lput (i + 10) avaCarbs
    ]
    set i (i + 1)
  ]
  let tries 0 ;not used in current code
  ; do the eating till no carbs or not hungry
  while [(length(avaCarbs) > 0) and any? hungryBact] [
    ;code here to randomly select a turtle from hungryBact and then ask it to run bactEat with a random carb from ava. list
    let carbNum one-of avaCarbs
    ask one-of hungryBact [
      bactEat(carbNum)
      set remAttempts remAttempts - 1
    ]
	set hungryBact (turtles-here with [(energy < 80) and (remAttempts > 0)])
	;increase the tries counters
    set tries (tries + 1)
  ]

end
;///////////////////////////patchEat///////////////////////////////////////

;///////////////////////////GET-GLUCOSE///////////////////////////////////////
; Returns glucose value at passed coordinate
to-report get-glucose [target-patch-x-coord target-patch-y-coord]
    report [glucosePrev] of patch-at target-patch-x-coord target-patch-y-coord
end
;///////////////////////////GET-GLUCOSE///////////////////////////////////////

;///////////////////////////GET-LACTOSE///////////////////////////////////////
; Returns lactose value at passed coordinate
to-report get-lactose [target-patch-x-coord target-patch-y-coord]
    report [lactosePrev] of patch-at target-patch-x-coord target-patch-y-coord
end
;///////////////////////////GET-LACTOSE///////////////////////////////////////

;///////////////////////////GET-INULIN///////////////////////////////////////
; Returns inulin value at passed coordinate
to-report get-inulin [target-patch-x-coord target-patch-y-coord]
    report [inulinPrev] of patch-at target-patch-x-coord target-patch-y-coord
end
;///////////////////////////GET-INULIN///////////////////////////////////////

;///////////////////////////GET-LACTATE///////////////////////////////////////
; Returns lactate value at passed coordinate
to-report get-lactate [target-patch-x-coord target-patch-y-coord]
    report [lactatePrev] of patch-at target-patch-x-coord target-patch-y-coord
end
;///////////////////////////GET-LACTATE///////////////////////////////////////

;///////////////////////////GET-FO///////////////////////////////////////
; Returns FO value at passed coordinate
to-report get-FO [target-patch-x-coord target-patch-y-coord]
    report [FOPrev] of patch-at target-patch-x-coord target-patch-y-coord
end
;///////////////////////////GET-FO///////////////////////////////////////

;///////////////////////////GET-CS///////////////////////////////////////
; Returns CS value at passed coordinate
to-report get-CS [target-patch-x-coord target-patch-y-coord]
    report [CSPrev] of patch-at target-patch-x-coord target-patch-y-coord
end
;///////////////////////////GET-CS///////////////////////////////////////

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@#$#@#$#@
GRAPHICS-WINDOW
425
21
1292
167
-1
-1
12.8
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
66
0
8
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
1028
177
1431
493
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
"Vulgats" 1.0 0 -7500403 true "" "plot count vulgats"

MONITOR
321
586
395
631
Cloststridia
count closts
17
1
11

MONITOR
405
586
493
631
Bifidobacteria
count bifidos
17
1
11

MONITOR
501
585
586
630
Desulfovibrio
count desulfos
17
1
11

MONITOR
320
633
451
678
Percentage Clostridia
100 * count closts / count turtles
2
1
11

MONITOR
458
634
613
679
Percentage Bifidobacteria
100 * count bifidos / count turtles
2
1
11

MONITOR
622
634
773
679
Percentage Desulfovibrio
100 * count desulfos / count turtles
2
1
11

MONITOR
222
586
311
631
Total Bacteria
count turtles
3
1
11

MONITOR
926
583
983
628
Glucose
sum [glucose] of patches
0
1
11

MONITOR
861
583
918
628
FO
sum [FO] of patches
2
1
11

MONITOR
734
585
791
630
Lactate
sum [lactate] of patches
2
1
11

MONITOR
991
583
1048
628
CS
sum [CS] of patches
2
1
11

MONITOR
669
584
726
629
Inulin
sum [inulin] of patches
2
1
11

MONITOR
800
584
857
629
Lactose
sum [Lactose] of patches
2
1
11

MONITOR
596
585
656
630
Vulgatus
count vulgats
17
1
11

MONITOR
781
635
908
680
Percentage Vulgatus
100 * count vulgats / count turtles
2
1
11

BUTTON
26
54
97
87
Profiler
setup                  ;; set up the model\nprofiler:start         ;; start profiling\nrepeat 30 [ go ]       ;; run something you want to measure\nprofiler:stop          ;; stop profiling\nprint profiler:report  ;; view the results\nprofiler:reset         ;; clear the data
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
1194
504
1300
537
plots-on?
plots-on?
0
1
-1000

INPUTBOX
724
309
850
369
inConcVulgats
0
1
0
Number

INPUTBOX
724
369
850
429
inConcBifidos
0
1
0
Number

INPUTBOX
849
309
981
369
inConcClosts
0
1
0
Number

INPUTBOX
849
368
981
428
inConcDesulfos
0
1
0
Number

INPUTBOX
1150
589
1277
649
motilDist
0.1
1
0
Number

INPUTBOX
850
428
982
488
flowDist
0.5
1
0
Number

INPUTBOX
1150
649
1277
709
lessMotilConst
0.75
1
0
Number

INPUTBOX
767
250
922
310
tickInflow
480
1
0
Number

INPUTBOX
724
428
851
488
stuckChance
50
1
0
Number

INPUTBOX
233
273
388
333
initial-number-vulgats
200
1
0
Number

INPUTBOX
233
333
388
393
initial-number-bifidos
10000
1
0
Number

INPUTBOX
233
393
388
453
initial-number-closts
300
1
0
Number

INPUTBOX
233
453
388
513
initial-number-desulfos
20
1
0
Number

TEXTBOX
802
227
894
245
Flow Variables
14
0.0
1

TEXTBOX
506
184
649
202
Carbohydrate Variables
14
0.0
1

TEXTBOX
1184
550
1288
601
randFlow Variables\n
14
0.0
1

TEXTBOX
266
251
351
269
Initial Bacteria
14
0.0
1

TEXTBOX
52
292
193
310
Bacteria Reproduction
14
0.0
1

MONITOR
926
636
1028
681
True Absorption
trueAbsorption
6
1
11

INPUTBOX
723
487
855
547
unstuckChance
50
1
0
Number

INPUTBOX
41
319
196
379
bifidoDoub
338
1
0
Number

INPUTBOX
40
378
196
438
desulfoDoub
908
1
0
Number

INPUTBOX
41
496
196
556
clostDoub
67
1
0
Number

INPUTBOX
41
436
196
496
vulgatDoub
171
1
0
Number

INPUTBOX
401
217
556
277
inFlowInulin
100
1
0
Number

INPUTBOX
556
438
711
498
absorption
0.01
1
0
Number

INPUTBOX
555
336
710
396
inFlowFO
100
1
0
Number

INPUTBOX
401
336
556
396
inFlowLactose
100
1
0
Number

INPUTBOX
554
276
709
336
inFlowLactate
100
1
0
Number

INPUTBOX
556
216
710
276
inFlowGlucose
100
1
0
Number

INPUTBOX
401
277
556
337
inFlowCS
100
1
0
Number

INPUTBOX
401
438
556
498
bifido-lactate-production
1
1
0
Number

INPUTBOX
855
487
983
547
seedChance
5
1
0
Number

INPUTBOX
478
502
633
562
reserveFraction
0.9
1
0
Number

@#$#@#$#@
## Model Summary
This model represents the relationships between _Bifidobaceria_, _Desulfovibrio_, and _Clostridia_. These bacteria are important in the appearance of Autism Spectrum Disorders (ASDs). High levels of _Desulfovibrio_ and _Clostridia_ and low levels of _Bifidobacteria_ have been found in the gut of children with ASDs. Therefore, a gut microbiome dominated by _Bifidobacteria_ is likely to be that of a healthy child, whereas a gut microbiome dominated by _Desulfovibrio_ and/or _Clostridia_ is likely to be that of an autistic child.

## Change Log

##### 10/25/15
Introduced autoregulation of Bifidobacteria
Things to do:
Look into max coordinate death under death-breed, maybe change min-x interaction too
Look into Volgatus food consumption numbers, varify numbers.
Look into precise lactate production by bifodobacteria
Look into autoregulation
Look into spores of Clostridia

##### 8/30/15
Bronson Modified Erik's code. Changes made follows:
Reproduction rate now depends on the energy  by the microbe
Set Flow to rate to 0
Introduce probiotic treatment button to model
Changed bacteria carbohydrate consumption cycle. Process now depeneds on
stochastic interactions between microbes and carbohydrates. There is a back up
left-over program written just in case any microbe is not fed and there is
still food available.
Bacteria now loose health every turn do to normal cell damage. Reproduction no
longer effects cell health because research suggests that when cells devide,
most of the damage stays with one cell so the health of the cell effectively
stays the same.

To Do:
Look inro max coordinate death under death-breed, maybe change min-x interaction too
Look into Volgatus food consumption numbers, varify numbers.
Look into precise lactate production by bifodobacteria

##### 11/12
- Simulation ends once bifidobacteria or desulfovibrio become extinct. Clostridia were excluded since they can be introduced to the system through infection.

- Added oxidative stress slider, which gives an additional way clostridia and bifidobacteria turtles can die.

- Added antibiotic turtle, which decreases the amount of bifidobacteria, but not clostridia or desulfovibrio. Haven't actually used it yet.

- Added infection chance, but it's actually the chance of not being infected. Not sure how to fix.

##### 11/15
- Started fitting bacteria counts to normal vs IBS cats.
The table below is easier to read in edit mode.


                                       | Healthy (n = 34)    | Inﬂammatory bowel disease (n = 11)
     Bacterial Group                   | %    | count        | %   | count
     Total bacteria                    | 100  | 10.28 ± 0.14 | 100 | 10.04 ± 0.22
     Biﬁdobacterium spp.               | 91.2 | 9.34  ± 1.20 | 64  | 7.56  ± 0.93
     Clostridium histolyticum subgp.   | 97.1 | 7.92  ± 0.68 | 100 | 8.12  ± 0.58
     Lactobacillus/Enterococcus subgp. | 97.1 | 8.68  ± 0.74 | 100 | 8.59  ± 0.32
     Bacteroides spp.                  | 100  | 9.07  ± 0.56 | 100 | 8.31  ± 0.48
     Desulfovibrio spp.                | 97.1 | 7.26  ± 1.29 | 100 | 7.84  ± 0.61

Units for count are log10(cells)/g fecal matter

- Removes infection slider and commented out infection code, to make parameter check easier (see below).

- Without using oxidative stress or clostridia infection, and using the parameters above

To simulate a healthy individual: B = 9, C = 8, D = 7, Br = 13, Cr = 10, Dr = 10
Bifidobacteria was the dominant species in 8 of 10 simulations (for 1 set of 10 runs).

To simulate an autistic individual: B = 7, C = 8, D = 7, Br = 13, Cr = 10, Dr = 10
Bifidobacteria was the dominant species in 5 of 10 simulations (for 1 set of 10 runs).

##### 11/17
- Catches removed
- Reproduction rates now affected by nearby turtles of other bacteria types
- Model now stops upon reaching a maximum number of turtles

##### 11/23
- Bifidos produce anti-oxidants, which inhibit desulfo growth
- Desulfos produce oxidants, which inhibit bifido growth

##### 11/24
- Anti-oxidants and oxidants diffuse between patches
- Right now, with all reproduction rates at 10%, 10/8/7 is healthy and 7/8/7 is autistic
-- Clostridia population is always much lower than the others
- Tried adding cell death to the model
- Carbohydrates added as a patch variable
- Added a breast-fed toggle with lowers the clostridia growth rate when on

##### 11/25
- Modified clost growth rate based on Kondepudi paper, "Prebiotic-non-digestible...activityagent _Clostridium difficile_"

##### 12/6
- Cleaning up code to submit as final project for CHEG667

##### 1/29
- There was a problem with the multipliers, they compounded on each other from bacteria to bacteria. I resolved this problem
- it was found through research that bifidobacteria not only produces antioxidants, but repoduces an intermiadate that is used by the bodies metabolism to produce even more antioxidants. Therefore I changed the bifidobacteria to decrease the oxidation level by one but increase antioxidation by 2
- the degree to which desulfovibrio was inhibited was not enough to control the population. Also the inhibition should be someone proportional to the ratio of oxidants to antioxidants. I made this change as well. The formula I used in this adjustment was someone arbitrary and is definately open to reconsideration.
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
NetLogo 5.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
