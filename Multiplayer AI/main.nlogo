extensions [rnd]

patches-own [ttl] ; ttl is to determine when to change patch colour back to black

globals
[
  currentGeneration
  generations
  average-total-length
  highest-total-length
  lineList
  total-Total-Lengths
  highest-individual-score
  no-agent-actions
  no-agent-states
  chromosome-length
  numOfDead
  averageFitness
  highest-avg-fitness
  total-length
  highest-ind-score-per-gen
  bestChromosomes
  totalAverageFitness
  totalFitness
]

breed [dangerNoodles noodle]

dangerNoodles-own
[
  startingX
  startingY
  body-length
  generation
  currentState
  isDead
  fitness
  chromosome
  points
  stepsTaken
]

to setup-dangerNoodles ; sets up the dangerNoodle agent with initial properties
  set color blue
  set shape "arrow"
  set heading (random 4 * 90)
  set body-length 5
  set points 0
  set stepsTaken 0
  set generation currentGeneration

  if disableEvolution = false or generation = 0[
    ifelse generation = 0 [
      setup-chromosomes
    ]
    [
      mutate-chromosomes
    ]
  ]
  set fitness 0
  set isDead 0
  let z 0
  while [any? other turtles-here or pcolor = orange]
  [
    setxy random-pxcor random-pycor
  ]
end

to setup ; initializes the environment, creates food and the dangerNoodles agents.
  ca
  reset-ticks
  set currentGeneration 0
  set highest-avg-fitness 0
  set numOfDead 0
  set total-Total-Lengths 0
  set average-total-length 0
  set chromosome-length (27)
  set bestChromosomes []
  set totalAverageFitness 0
  set totalFitness 0

  ask patches[
    set ttl 0
  ]
  let x 0
  while [x < minAmtOfFood]
  [
    placefood
    set x (x + 1)
  ]

  create-dangerNoodles population [setup-dangerNoodles]
end

to tick-dangerNoodles; executes decision making for each of the dangerNoodle agents
  ask dangerNoodles[
    decisionMaking
  ]
end
to go
  if superSpeed = false[
    wait 0.15 / speed
  ]

  if freqOfFoodSpawnsPerTick > random-float 1 and food-generation-per-tick = true ;place food each tick if allowed
  [
    forcePlaceFood
  ]

  if infGen = false[ ;to stop after a certain amount of generations if wanted.
    if (amtOfGen - 1) < currentGeneration [stop]
  ]
  let endcycle false
  if ticks < cycleTime ;checks tick time
  [
    tick
    tick-dangerNoodles

    ask dangerNoodles[
      if isDead = 0[
        st
        set fitness fitness + 1 ;increase the fitness each tick
        fd 1
        if pcolor = orange [ ;if it dies
          set isDead 1
          set numOfDead numOfDead + 1
        ]
        if pcolor = green[ ;if food is eaten
          set body-length body-length + 1
          set fitness fitness + 1000
          set points points + 1
          placefood
        ]
        set pcolor orange
        set ttl body-length
      ]
      if isDead = 1 [ ; to kill the snake but not remove it entirely so that they could populate the next generation
        ht
        if numOfDead >= population[
          set endcycle true
        ]
    ]]
  ask patches with [ttl > 0]
  [set ttl ttl - 1
    if ttl = 0 [set pcolor black]
  ]
  ]
  if ticks >= cycleTime or endcycle = true [ ;if the cycle ends
        endOfCycle
        reset-ticks
      ]
end

to-report indexing [x y z] ; calculation to get the index. Formula explained in the info section.
  report (x + ((y - 1) * 3) + ((z - 1) * 8) + (z - 2))
end

to decisionMaking
  let originalDir heading
  let originalX xcor
  let originalY ycor
  let frontDir 0 ; z
  let rightDir 0 ; y
  let leftDir 0 ; x

  let x 1
  let stillGoing true
  while [x <= 4 and stillGoing = true] ;check whats in front of it stops if it found something.
  [
   fd 1
   set frontDir whatsOnTheTile
   if frontDir > 1 [set stillGoing false]
   set x (x + 1)
  ]

  set stillGoing true ; resets the values for the next check
  setxy originalX originalY
  set heading originalDir
  rt 90
  set x 1

  while [x <= 4] ; checks what is to its right.
  [
   fd 1
   set rightDir whatsOnTheTile
   if rightDir > 1 [set stillGoing false]
   set x (x + 1)
  ]
  set stillGoing true
  setxy originalX originalY
  set heading originalDir
  lt 90
  set x 1

  while [x <= 4] ;checks whats to its left
  [
   fd 1
   set leftDir whatsOnTheTile
   if leftDir > 1 [set stillGoing false]
   set x (x + 1)
  ]
  set stillGoing true
  setxy originalX originalY
  set heading originalDir

  action leftDir rightDir frontDir ;does the action with the new information
end

to action[x y z] ; performs the action
  let decision item (indexing x y z) chromosome ; checks for the chromosome
  ifelse decision = 0 [east] ;performs an action based on the chromosome decision
  [ ifelse decision = 1 [south]
  [ ifelse decision = 2 [west]
  [ ifelse decision = 3 [north]
  [
  ]]]]
end

to-report whatsOnTheTile ;checks whats on the tile to do the scanning
  ifelse pcolor = green [report 3]
  [ifelse pcolor = orange [report 2]
  [ifelse pcolor = black [report 1]
  [
  ]]]
  report 1
end

to setup-chromosomes ;sets up chromosomes
  let statesBlank n-values chromosome-length [random 4]

  set chromosome statesBlank

end

to endOfCycle ;does calculations after the end of each cycle to get the statistics and sets up the next cycle
  set total-length 0
  set highest-ind-score-per-gen 0
  ask dangerNoodles
  [
    set total-length (total-length + points)
    if points > highest-individual-score [
      set highest-individual-score points
    ]
    if points > highest-ind-score-per-gen[
      set highest-ind-score-per-gen points
    ]
  ]
  set total-length (total-length + (population * 5))
  if total-length > highest-total-length[set highest-total-length total-length]
  set total-Total-Lengths (total-Total-Lengths + total-length)
  set average-total-length (total-Total-Lengths / (currentGeneration + 1))



  set numOfDead 0
  cp

  let x 1
  while [x < minAmtOfFood]
  [
    placefood
    set x (x + 1)
  ]

  let sumFitness 0
  ask dangerNoodles[set sumFitness (sumFitness + fitness)]
  set averageFitness (sumFitness / population)
  if averageFitness > highest-avg-fitness [
    set highest-avg-fitness averageFitness
    set bestChromosomes []
    ask dangerNoodles[
      set bestChromosomes lput chromosome bestChromosomes
    ]
  ]
  set totalFitness (totalFitness + averageFitness)
  set totalAverageFitness (totalFitness / (currentGeneration + 1))

  hatchNextGeneration

end


to hatchNextGeneration ;hatch the new population
  let tempSet (dangerNoodles with [generation = currentGeneration])
  set currentGeneration (currentGeneration + 1)

  ifelse disableEvolution = false [ ;if enabled skip the evolution part


  ask tempSet
  [
    if points > highest-individual-score [set highest-individual-score points]
    if averageFitness = 0 [set fitness 1]
  ]

  if averageFitness = 0 [ set averageFitness 1]

  while[ count dangerNoodles < (population * 2)]
  [
    let parent1 rnd:weighted-one-of dangerNoodles [fitness] ;roulette picking
    let parent2 rnd:weighted-one-of dangerNoodles [fitness]

    let newSetC (crossover parent1 parent2) ; crossover


    ask parent1 ;setting new chromosomes for and hatching the children
    [
      set chromosome item 0 newSetC
      hatch-dangerNoodles 1 [setup-dangerNoodles]
    ]


    ask parent2
    [
      set chromosome item 1 newSetC
      hatch-dangerNoodles 1 [setup-dangerNoodles]
    ]
  ]
  ]
  [ ask tempset [hatch-dangerNoodles 1 [setup-dangerNoodles]]] ; if disable evoultion is true just pass the same chromosomes to the next generation
  ask tempSet [die]; kill the temp set
  placefood

end

to mutate-chromosomes
  set chromosome mutate-chromosome
end

to-report mutate-chromosome
  let j 0
  let stateBlock chromosome
    while [j < (chromosome-length)] ; goes through everything inside the chromosome
    [
      if mutationChance > random-float 1 ;if the chance hits then mutate that index of the chromosome
      [
        set stateBlock replace-item j stateBlock randomState
      ]
    set j ( j + 1 )
    ]
  report stateBlock
end

to-report crossOver [parent1 parent2] ;one point crossover for the parents (Mainly taken from the practical 11)
  let slicePoint random(round(chromosome-length / 2))
  let finalList []
  ask parent1
  [
    let slice sublist chromosome 0 slicePoint
    let slice1 sublist chromosome slicePoint (chromosome-length)

    ask parent2
    [
      let slice2 sublist chromosome 0 slicePoint
      let slice3 sublist chromosome slicePoint (chromosome-length)
      set finalList lput (join-lists slice2 slice1) finalList
      set finalList lput (join-lists slice2 slice3) finalList
    ]


  ]
  report finalList
end

to-report join-lists[list1 list2] ; helper function to join two lists together
  let jMax length list2
  let j 0
    while [j < jMax]
    [
      set list1 lput (item j list2) list1
      set j ( j + 1 )
    ]
  report list1
end


to-report randomState
  report (random 4)
end

;;;; direction setting ;;;;
to north
  set heading 0
end
to east
  set heading 90
end
to south
  set heading 180
end
to west
  set heading 270
end

to placefood ;; place food but not forcefully if the amount of food is above the minimum
  let amtOfBlack 0
  let amtOfGreen 0
  ask patches with [pcolor = black] [set amtOfBlack (amtOfBlack + 1)]
  ask patches with [pcolor = green] [set amtOfGreen (amtOfGreen + 1)]
  if amtOfBlack > 0 and amtOfGreen < minAmtOfFood [
    ask one-of patches with [pcolor = black] [set pcolor green]
  ]
end

to forcePlaceFood ; force place food even if the amount is above the minimum
  let amtOfBlack 0
  ask patches with [pcolor = black] [set amtOfBlack (amtOfBlack + 1)]
  if amtOfBlack > 0 [
    ask one-of patches with [pcolor = black] [set pcolor green]
  ]
end


to saveData ;;save data to a file
  if file-exists? "save-best.txt"
  [
    file-delete "save-best.txt"
  ]

  file-open "save-best.txt"

  file-print "population:"
  file-print population
  file-print "minAmtOfFood:"
  file-print minAmtOfFood
  file-print "freqOfFoodSpawnsPerTick:"
  file-print freqOfFoodSpawnsPerTick
  file-print "mutationChance:"
  file-print mutationChance
  file-print "cycleTime:"
  file-print cycleTime
  file-print "food-generation-per-tick:"
  file-print food-generation-per-tick
  file-print "chromosome:"
  foreach bestChromosomes [x -> (file-print x) ]

  file-close
  print ("saved")
end


to setData ;;load the data from the file
  ifelse not file-exists? "save-best.txt"
  [
    print "no file named save-best.txt found"
  ]
  [
  let currentVar ""
  file-open "save-best.txt"
  let listOfChromosomes []
  while [ not file-at-end? ]
  [
    let line file-read-line
    if member? "population:" line
      [
        set line file-read-line
        set population read-from-string line
      ]
    if member? "minAmtOfFood:" line
      [
        set line file-read-line
        set minAmtOfFood read-from-string line
      ]
    if member? "freqOfFoodSpawnsPerTick:" line
      [
        set line file-read-line
        set freqOfFoodSpawnsPerTick read-from-string line
      ]
    if member? "mutationChance:" line
      [
        set line file-read-line
        set mutationChance read-from-string line
      ]
    if member? "cycleTime:" line
      [
        set line file-read-line
        set cycleTime read-from-string line
      ]
    if member? "food-generation-per-tick:" line
      [
        set line file-read-line
        set food-generation-per-tick read-from-string line
      ]
    if member? "chromosome:" line
      [
        set line file-read-line
        while [not file-at-end?][
          set listOfChromosomes lput (read-from-string line) listOfChromosomes
          set line file-read-line
        ]
        set listOfChromosomes lput (read-from-string line) listOfChromosomes
      ]
  ]
  file-close
  setup

    if loadChromosomes = true [
      let x 0
      ask dangerNoodles
      [
        set chromosome item x listOfChromosomes
        set x x + 1
      ]

    ]
    print ("loaded")
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
278
26
559
308
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-10
10
-10
10
0
0
1
ticks
30.0

SLIDER
4
59
148
92
speed
speed
1
100
18.0
1
1
NIL
HORIZONTAL

BUTTON
56
378
119
411
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
136
378
199
411
NIL
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

SLIDER
32
134
204
167
cycleTime
cycleTime
1000
10000
3000.0
1000
1
NIL
HORIZONTAL

SLIDER
34
18
206
51
mutationChance
mutationChance
0
1
0.02
0.01
1
NIL
HORIZONTAL

SLIDER
33
97
205
130
population
population
2
50
6.0
1
1
NIL
HORIZONTAL

SLIDER
30
177
202
210
minAmtOfFood
minAmtOfFood
1
25
12.0
1
1
NIL
HORIZONTAL

PLOT
21
473
340
721
Average Fitness
Generations
Fitness
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -11085214 true "" "plotxy currentGeneration totalAverageFitness"

MONITOR
595
43
735
88
higest  average fitness
highest-avg-fitness
0
1
11

MONITOR
596
110
739
155
NIL
highest-individual-score
0
1
11

MONITOR
748
255
950
300
Previous  Generations Average Fitness 
averageFitness
0
1
11

MONITOR
594
186
739
231
Highest Total Length
highest-total-length
17
1
11

MONITOR
788
112
921
157
Average Total Length
average-total-length
0
1
11

MONITOR
788
189
902
234
NIL
currentGeneration
0
1
11

MONITOR
574
256
743
301
last generations total length
total-length
0
1
11

PLOT
342
474
659
720
average and highest total length per generation
Generations
Total Length
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"average" 1.0 0 -13791810 true "" "plotxy currentGeneration average-total-length"
"highest" 1.0 0 -11085214 true "" "plotxy currentGeneration highest-total-length"

SWITCH
156
58
261
91
superSpeed
superSpeed
1
1
-1000

SWITCH
175
322
265
355
infGen
infGen
0
1
-1000

SLIDER
3
322
161
355
amtOfGen
amtOfGen
100
10000
4600.0
100
1
NIL
HORIZONTAL

SWITCH
470
380
629
413
loadChromosomes
loadChromosomes
0
1
-1000

BUTTON
678
372
767
405
Save Data
saveData
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
509
424
597
457
Load Data
setData
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
478
341
622
374
disableEvolution
disableEvolution
0
1
-1000

TEXTBOX
313
323
463
463
To see how the default snakes behave without evolution: make sure disableEvolution is on and load the data without chromosomes.\n\nto see how the evolved saved data behaves without tweaking: disable evolution and load the chromosomes.
11
0.0
1

TEXTBOX
784
340
934
452
Careful not to override the given data by pressing save. I have provided a copy of the data called backup data. incase the data was overwritten make sure to rename it to \"best-save.txt\" to recover it.
11
0.0
1

SLIDER
27
227
204
260
freqOfFoodSpawnsPerTick
freqOfFoodSpawnsPerTick
0.1
1
0.1
0.05
1
NIL
HORIZONTAL

MONITOR
750
45
938
90
Average Fitness across generations
totalAverageFitness
0
1
11

PLOT
662
474
974
720
Fitness
Generations
Fitness
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -13840069 true "" "plotxy currentGeneration averageFitness"

SWITCH
22
274
214
307
food-generation-per-tick
food-generation-per-tick
0
1
-1000

@#$#@#$#@
## Exam  number : Y3881018
## ALL OF THE MASSIVE IMAGES, TABLES OR FIGURES ARE AT THE END OF THE INFO PAGE
## WHAT IS IT?

This model is designed to create a population of snakes that evolve and learn to avoid running into their own bodies or other snakes nearby. At the same time, they try to eat as many apples as possible to make the total length of the snakes combined longer.

## Snake Representation
In this model, the snakes are represented by chromosomes, which are lists of numbers ranging from 0 to 3, each indicating a cardinal direction. Which represents each possible scenario so the length of the chromosome is determined by the total number of possible scenarios in which the snake can find itself. To represent these scenarios, the snake scans its surroundings for two things: food and its own or other snakes body. It checks the four directions relative to its head's position and direction, but as its body will always be behind it, this direction can be omitted, reducing the number of directions to three. Each direction scan can yield one of three possible results: 1 for empty space, 2 for its own body, and 3 for food ahead. By scanning three directions, each with three possible results, the number of possible combinations is 3^3, which equals 27, which we set as the length of the chromosome.

## HOW IT WORKS
Snake Game:

The snake game has been developed utilizing patch manipulations to achieve a representation of the classic game. The snake's body is not comprised of linked agents, but rather, when the snake passes over a patch, it alters the color of the patch to match that of the snake, thereby simulating its body. Additionally, a variable is assigned to each patch to keep track of the number of turns the snake has played, representing the length of the snake's body. This methodology accurately portrays the look and feel of the snake game.

Food Generation:

The food generation system is based on a set minimum amount of food present on the playing field. A slider is used to specify the amount of food present, which is always available. However, if the food generation per tick feature is enabled, there is a chance for additional food to appear based on a slider-defined probability. Food is represented on the playing field similarly to the snake, by changing a random black patch to green, with no time limit. In the event that the entire screen is covered by the snake, food generation is skipped.

Running the game:

Upon selecting the "go" button, the snake undergoes an action that involves scanning the playing field to locate the index in the chromosome that corresponds to each unique situation. Each situation is labeled using three numbers, one for each direction, which adjust the index based on a cultivated formula (x + ((y - 1) * 3) + ((z - 1) * 8) + (z - 2)) which can be seen in action in figure 7.  The unique index for each situation is then used to locate the appropriate position in the chromosome, enabling the snake to execute the corresponding move. Each time the snake eats the apple they get 1000 fitness and every tick they survive they get 1. So the snakes are incentivized to eat the apples. The game concludes either after the specified cycle time has elapsed or when all snakes have died, at which point a new generation runs. 

Evolution and selection:

Following each generation, the individuals that are selected to repopulate the next generation are chosen using roulette selection, as previously demonstrated in question one. The selected parents then undergo one point cross over, with a randomly determined slice point, to produce offspring chromosomes which can be seen in figure 8. This process continues until the entire population of the new generation has been generated.


![one point crossover](file:8.png)

Figure 7: one point crossover source: https://en.wikipedia.org/wiki/Crossover_(genetic_algorithm)

Hatching and mutating:

After the evolution and selection process is complete, the newly hatched children undergo a setup procedure during whichthey go through the mutation stage. Where each number in the chromosome has a chance of mutation, with the number being replaced by a random value between 0 and 3. The probability of mutation can be modified using the sliders.

## HOW TO USE IT
Mutation chance: determines the likelihood of each number in the chromosome evolving, but not the chance of mutation occurring in the individual.

Speed: controls the pace of the game.

Super speed: sets the game to maximum speed for rapid generation progression.

Population: determines the number of snakes present per generation.

CycleTime: sets the number of ticks before the snakes are forcibly removed if they have not died.

MinAmtOfFood: establishes the minimum quantity of food present on the field at any given time.

FreqOfFoodSpawningPerTick: sets the likelihood of food appearing each tick.

Food generation per tick: enables or disables food spawning per tick, but does not override the minimum amount of food.

Amount of generations: specifies the number of generations to run the model for.

InfGen: allows for the model to run indefinitely.

Setup: inputs the provided values into the game.

Go: runs the game.

Disable Evolution: deactivates evolution and mutation, which allows evaluation of a particular group of snakes' performance.

Save data: stores the current data state and the best performing chromosomes discovered.

Load data: loads the saved snake data.

LoadChromosomes: selects whether the best found individuals are loaded or if a random set of chromosomes is necessary.

To test the default snake behavior, the data should be loaded with the LoadChromosomes function off and Disable Evolution off when running the game. Conversely, to test the evolved snake behavior, the data should be loaded with LoadChromosomes function on and Disable Evolution off when running the game.

## THINGS TO NOTICE

It should be noted that there was no data sharing among the snakes during gameplay, as any shared data would likely be irrelevant. For instance, if one snake shares the food it has found after consuming it, other snakes will not be able to locate any food upon arrival. Similarly, sharing the current position of the snake is unnecessary, as each snake should only be aware of its current position and the surroundings in its vicinity. Furthermore, since the snakes already scan for other bodies within their vicinity, there is no need for a snake on one end of the map to know the location of another on the opposite end. Hence, no data sharing was implemented during gameplay.

Most of the work was based on the practical provided in workshop 11.

behaviour observation:
If the evolved snakes are ran one thing to notice is that they keep working and eating together until they get kind of big. then one of them dies by getting scared of its surroundings. Then the other one goes on to eat up to 350 apples before dying.

## EXTENDING THE MODEL

To enhance the performance of the snakes, expanding the number of directions the snake can perceive to eight and increasing the detection range may improve their awareness of their surroundings. However, this would likely result in a significant increase in chromosome length, which could be problematic. To overcome this obstacle, a neural network could be integrated to handle more information without significantly increasing the size of the chromosome. By utilizing a neural network, the snakes could process more data and enhance their performance without incurring an impractical increase in the chromosome's length.

To avoid them getting scared of the surroundings, the distance to walls and bodies could be implemented. Which gives them accurate representation of whats around them. This would avoid them turning on a tail that they think is far away when its right in front of them.

## DATA ANALYSIS AND EVALUATION

To evaluate and compare between the two groups (one with the evolved behaviour and one without) I will be following the flow chart provided in figure 6: As I am dealing with continuous data and intend on checking the differences between the means of the two groups I have to check if the data satisfies the parametric assumptions. Therefore, I conducted a shapiro-wilk test to check if the data is normally distributed. According to the result of the test given (Figure 1): The test was significant with p < .001. Hence, the data was not normally distributed. It would be best to conduct a non-parametric test, in this case a Mann-Whitney-U-Test instead of a t-test. I did not attempt to transform the data to fix the distribution so that it would not seem that I was attempting to p hack the data.

A Mann-Whitney-U-Test was calculated to determine if there were differences in having an evolved chromosome and the default behaviour regarding the total lengths of all the snakes in each generation. The results of the tests can be viewed in figures 2 and 3. The distributions differed between both groups according to the Kolmogorov-Smirnov test that was conducted and can be seen in figure 4 concluded with p < .05. There was a statistically significant difference in the total lengths between both groups, U = 29874.00, Z = -36.569, p < .001. The effect size according to Cohen’s d is considered a large effect as it is higher than 0.8, the value being 0.818 (calculated using the formula (abs value of z / sqrt(n))).

As you can see from figure 5 there are no outliers that can negatively influence the outcome of the analysis.

All the graphs and data calculation were generated by the tool IBM Spss. With the evolved stats run 1000 times and the default behaviour run 1000 times as well.


![shapiro-wilk test](file:2.png)

Figure 1: shapiro-wilk test

![mann-whitney-u-test 1](file:3.png)

Figure 2: mann-whitney-u-test 1

![mann-whitney-u-test 2](file:4.png)

Figure 3: mann-whitney-u-test 2

![kolmogorov-smirnov test](file:5.png)

Figure 4: kolmogorov-smirnov test

![testing negativity](file:6.png)

Figure 5: testing negativity in outliers

![Flowchart of the most commonly used statistical tests](file:1.png)

Figure 6: Flowchart of the most commonly used statistical tests

![Execution of the indexing.](file:9.png)

Figure 8: Execution of the indexing.
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
NetLogo 6.3.0
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
