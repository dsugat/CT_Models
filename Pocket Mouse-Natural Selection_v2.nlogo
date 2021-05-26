globals [
  frequency-of-dominant-A
  frequency-of-recessive-a
  light-fur-color
  dark-fur-color
]
breed [mice mouse]
breed [predators predator]
mice-own [
  genotype
  partner
  sex
  age
]

;;set-up pupulation of males and females
to setup
  ca
  set light-fur-color 39
  set dark-fur-color 31
  ask patches [set pcolor 35]

  create-mice initial-homozygous-dominant-males [
    set sex "male"
    set genotype "AA"
  ]
  create-mice initial-heterozygous-males [
    set sex "male"
    set genotype "Aa"
  ]
  create-mice initial-homozygous-recessive-males [
    set sex "male"
    set genotype "aa"
  ]
  create-mice initial-homozygous-dominant-females [
    set sex "female"
    set genotype "AA"
   ]
   create-mice initial-heterozygous-females [
    set sex "female"
    set genotype "Aa"
   ]
   create-mice initial-homozygous-recessive-females [
    set sex "female"
    set genotype "aa"
   ]
  ask mice [
    setxy random-xcor random-ycor
    set partner nobody
    set size 2
    set shape "mouse"
    set-fur-color
    set age 0
  ]
  ask mice with [sex = "male"] [
    set size 2.5
  ]
  calculate-allele-frequencies
  if predation? [create-predator-population]
  reset-ticks
end

to create-predator-population
  create-predators chance-of-predation * 100 [
    setxy random-xcor random-ycor
    set shape "bird"
    set color red
    set size 5
  ]
end

to go
  if not any? mice [stop]
  ask mice [
    move
    age-and-die
    die-if-predated
  ]
  ask mice[
    reproduce
  ]
  calculate-allele-frequencies
  ifelse predation? [
    maintain-predator-population
    ask predators [
      move
    ]
  ][
    ask predators [die]
  ]
  tick
end

to move
    rt random 360
    lt random 360
    fd 5
end

to die-if-predated

  ;; a difference between a mouse color and color of its neighboring patches decreases camouflage increases

  let camouflage  ( 1 / ( abs ( mean [pcolor] of neighbors  - [color] of self ) ) )

  ifelse predation? and ( random-float 1 < ( chance-of-predation - camouflage ) ) [  ;; chance of predation reduces if a mouse is camouflaged
    die
  ]
  [
    search-a-partner
  ]

end

to search-a-partner   ;; a male procedure
  if sex = "male" [
    let females mice with [sex = "female"]
    if ( count females in-radius 5 >= 1 )and (count females in-radius 10 < 10 )   [
      set partner one-of females in-radius 5

      ifelse [partner] of partner != nobody [
        set partner nobody
        stop                        ;; just in case two males find the same partner
      ]
      [
        ask partner [set partner myself]
      ]
    ]
  ]
  if sex = "female" [
    let males mice with [sex = "male"]
    if ( count males in-radius 5 >= 1 )and (count males in-radius 10 < 10 )   [
      set partner one-of males in-radius 5


      ifelse [partner] of partner != nobody [
        set partner nobody
        stop                        ;; just in case two females find the same partner
      ]
      [
        ask partner [set partner myself]
      ]
    ]
  ]

end

to reproduce
  let my-gametes []
  let partner-gametes []
  if partner != nobody [
    if genotype = "AA" [ set my-gametes ["A" "A"]]
    if genotype = "Aa" or genotype = "aA" [ set my-gametes ["A" "a"]]
    if genotype = "aa" [ set my-gametes ["a" "a"]]
    if [genotype] of partner = "AA" [ set partner-gametes ["A" "A"]]
    if ([genotype] of partner = "Aa" or [genotype] of partner = "aA") [ set partner-gametes ["A" "a"]]
    if [genotype] of partner = "aa" [set partner-gametes ["a" "a"]]
    let my-child1-genotype word (one-of my-gametes) (one-of partner-gametes)
    let my-child2-genotype word (one-of my-gametes) (one-of partner-gametes)
    let partner-child1-genotype word (one-of my-gametes) (one-of partner-gametes)
    let partner-child2-genotype word (one-of my-gametes) (one-of partner-gametes)

    hatch 1 [
      set genotype my-child1-genotype
      set-fur-color
      fd 1
    ]
    hatch 1 [
      set genotype my-child2-genotype
      set-fur-color
      fd 1
    ]
    ask partner [
      hatch 1 [
        set genotype partner-child1-genotype
        set-fur-color
        fd 1
      ]
      hatch 1 [
        set genotype partner-child2-genotype
        set-fur-color
        fd 1
      ]
      die
    ]
    die
  ]
end

to set-fur-color ; mice procedure
  ifelse genotype = "AA" or genotype = "Aa" or genotype = "aA" [
    set color dark-fur-color
  ][
    set color light-fur-color
  ]
end



to add-a-mutant
  create-mice 1 [
    setxy random-xcor random-ycor
    set partner nobody
    set shape "mouse"
    set sex one-of ["male" "female"]
    ifelse sex = "male" [set size 2.5] [set size 2]
    set genotype "Aa"
    set-fur-color
  ]
end

to calculate-allele-frequencies
  if count mice > 0 [
  set frequency-of-dominant-A ( (2 * count mice with [genotype = "AA"]) + count mice with [genotype = "Aa"] + count mice with [genotype = "aA"] ) / (2 * count mice)
  set frequency-of-recessive-a ( (2 * count mice with [genotype = "aa"]) + count mice with [genotype = "Aa"] + count mice with [genotype = "aA"] ) / (2 * count mice)
  ]

end

to age-and-die
  set age age + 1
  if age > 10 [
    if random-float 1 > 0.95  [die]
  ]
end

to maintain-predator-population
  ifelse count predators > chance-of-predation * 100 [
    ask one-of predators [die]
  ]
  [
    create-predators 1 [
      setxy random-xcor random-ycor
      set shape "bird"
      set color red
      set size 5
    ]
  ]
end

to set-light-background
  ask patches [set pcolor 36]
  ask n-of (round ( count patches / 3)) patches [ set pcolor 40 ]
  repeat 50 [diffuse pcolor 0.1]
end

to set-dark-background
  ask patches [set pcolor 34]
  ask n-of (round ( count patches / 3)) patches [ set pcolor 30 ]
  repeat 50 [diffuse pcolor 0.1]
end

to set-mixed-background
  ask patches [set pcolor 35]
  ask n-of (round ( count patches / 1.5)) patches [ if pxcor > 0  [ set pcolor 30 ]]
  ask n-of (round ( count patches / 1.5)) patches [ if pxcor < 0  [ set pcolor 40 ]]
  repeat 50 [diffuse pcolor 0.1]
end
@#$#@#$#@
GRAPHICS-WINDOW
503
52
1011
560
-1
-1
7.82
1
10
1
1
1
0
0
1
1
-32
32
-32
32
1
1
1
ticks
30

BUTTON
9
10
64
80
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

BUTTON
72
46
148
79
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

SLIDER
5
221
304
254
initial-homozygous-dominant-females
initial-homozygous-dominant-females
0
200
50
1
1
NIL
HORIZONTAL

SLIDER
5
145
304
178
initial-heterozygous-males
initial-heterozygous-males
0
200
50
1
1
NIL
HORIZONTAL

SLIDER
4
260
304
293
initial-heterozygous-females
initial-heterozygous-females
0
200
50
1
1
NIL
HORIZONTAL

SLIDER
5
183
304
216
initial-homozygous-recessive-males
initial-homozygous-recessive-males
0
200
50
1
1
NIL
HORIZONTAL

SLIDER
3
298
303
331
initial-homozygous-recessive-females
initial-homozygous-recessive-females
0
200
50
1
1
NIL
HORIZONTAL

MONITOR
334
136
395
181
AA males
count mice with [genotype = \"AA\" and sex = \"male\"]
17
1
11

MONITOR
333
189
396
234
Aa males
count mice with [genotype = \"Aa\" and sex = \"male\"] + count mice with [genotype = \"aA\" and sex = \"male\"]
17
1
11

MONITOR
333
248
399
293
aa males
count mice with [genotype = \"aa\" and sex = \"male\"]
17
1
11

PLOT
2
337
380
573
Phenotype frequencies
generations
frequency
0
10
0
1
true
true
"" ""
PENS
"Homozygous dominant" 1 0 -8630108 true "" "if count mice > 0 [ plot ( count mice with [genotype = \"AA\"] / count mice )]"
"Heterozygous" 1 0 -3425830 true "" "if count mice > 0 [plot ( ( count mice with [genotype = \"Aa\"] + count mice with [genotype = \"aA\"]) / count mice )] "
"Homozygous recessive" 1 0 -7500403 true "" "if count mice > 0 [plot ( count mice with [genotype = \"aa\"] / count mice )]"

MONITOR
412
248
486
293
aa females
count mice with [genotype = \"aa\" and sex = \"female\"]
17
1
11

MONITOR
412
189
486
234
Aa females
count mice with [genotype = \"Aa\" and sex = \"female\"] + count mice with [genotype = \"aA\" and sex = \"female\"]
17
1
11

MONITOR
412
136
486
181
AA females
count mice with [genotype = \"AA\" and sex = \"female\"]
17
1
11

BUTTON
491
10
617
43
NIL
set-light-background
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
620
11
746
44
NIL
set-dark-background
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
750
11
886
44
NIL
set-mixed-background
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
911
10
1025
43
Add a mutant
add-a-mutant
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
283
16
478
49
chance-of-predation
chance-of-predation
0.05
0.5
0.35
0.01
1
NIL
HORIZONTAL

SWITCH
166
16
274
49
predation?
predation?
0
1
-1000

SLIDER
5
106
304
139
initial-homozygous-dominant-males
initial-homozygous-dominant-males
0
200
50
1
1
NIL
HORIZONTAL

MONITOR
385
380
499
425
light-colored-mice
count mice with [genotype = \"aa\"]
17
1
11

MONITOR
385
430
499
475
dark-colored-mice
count mice with [genotype = \"AA\"] + \ncount mice with [genotype = \"aA\"] +\ncount mice with [genotype = \"Aa\"]
17
1
11

MONITOR
385
480
500
525
total mice
count mice
17
1
11

TEXTBOX
76
80
226
105
Initial settings
20
0
1

TEXTBOX
383
94
465
119
Data
20
0
1

BUTTON
72
10
148
43
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1
@#$#@#$#@
## WHAT IS IT
This is a model of pocket mouse evolution based on a lesson plan designed by Howard Hughes Medical Institute (https://www.hhmi.org/biointeractive/making-fittest-natural-selection-and-adaptation)
and an AP biology lab (original source unknown).
(http://www2.centralcatholichs.com/APbiologysite/AP%20evolution/HWC%20pop%20genetics%20AP%20lab%208.PDF )


## HOW IT WORKS
The model consists of a a rock pokect mouse population.
The fur color of mouse is determined by genes at a particular loci for which there are two alleles - A and a. 
A is a dominant allele, whereas a is recessive allele. 
p is a frequency of the dominant allele (A) and q is a frequency of the recessive allele (a).

Each clock tick is a generation in this model. 
At each generation, 
a mouce moves, 
it is possibly predated (if "predation?" is ON) based on the chance of predation and how well it can camouflage with the surroundings,
if it survives predation, it finds a partner and reproduces.

Reproduction is modelled based on Mendelian inheritance as the following:
Each mating pair produces four childern. Each child recevies one of the alleles from the mother and one of the alleles from the father.

Both the parents die after reproduction. For simplicity, there are no overlapping generations.

The button - "Add a mutant", adds a heterozygous mutant at a random location.

## HOW TO USE IT
Set initial population by choosing the following sliders:
iniital-homozygous-dominant-males (AA males)
iniital-heterozygous-males (Aa/aA males)
iniital-homozygous-recessive-males (aa males)
iniital-homozygous-dominant-females (AA females)
iniital-heterozygous-females (Aa/aA females)
iniital-homozygous-recessive-females (aa females)

You can set the background colors - dark, light or mixed.

You can choose to set "predation?" ON or OFF; and set the chance-of-predation.

"chance-of-predation" determines the probabilty of a mouse dying because of predation in each tick. The predation probabilty reduces depending on how well a mouse camouflages, based on its fur coat color and the color of surroundings. 

## THINGS TO NOTICE
Set the initial population and see how it evolves over time.  
You can change the background colors and observe the effects on the changes in the genetic composition of the population over time. 


## THINGS TO TRY
Start with a completely homozygous recessive population and see how introduction of a mutant changes population composition over time.


## EXTENDING THE MODEL
You could modify the model by making the generations overlap.
Think about how you could study other life history traits such as number of offsprings, or longevity. 


## RELATED MODELS



## CREDITS AND REFERENCES
https://www.pnas.org/content/100/9/5268
https://www.hhmi.org/biointeractive/making-fittest-natural-selection-and-adaptation



## COPYRIGHT AND LICENSE
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

bird
true
0
Polygon -7500403 true true 151 170 136 170 123 229 143 244 156 244 179 229 166 170
Polygon -16777216 true false 152 154 137 154 125 213 140 229 159 229 179 214 167 154
Polygon -7500403 true true 151 140 136 140 126 202 139 214 159 214 176 200 166 140
Polygon -7500403 true true 152 86 227 72 286 97 272 101 294 117 276 118 287 131 270 131 278 141 264 138 267 145 228 150 153 147
Polygon -7500403 true true 160 74 159 61 149 54 130 53 139 62 133 81 127 113 129 149 134 177 150 206 168 179 172 147 169 111
Polygon -16777216 true false 129 53 135 58 139 54
Polygon -7500403 true true 148 86 73 72 14 97 28 101 6 117 24 118 13 131 30 131 22 141 36 138 33 145 72 150 147 147

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
Circle -7500403 true true 135 135 30

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

female
true
0
Circle -7500403 false true 108 108 85
Line -7500403 true 150 195 150 240
Circle -7500403 true true 103 103 92
Line -7500403 true 135 210 165 210

female fish
false
4
Polygon -13345367 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -13345367 true false 150 195 134 235 110 218 91 210 61 204 75 165
Polygon -1184463 true true 75 60 83 92 71 118 86 129 165 105 135 75
Polygon -13345367 true false 30 136 150 105 225 105 280 119 292 146 292 160 287 170 255 180 195 195 135 195 30 166
Circle -16777216 true false 215 121 30

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

male
true
0
Circle -7500403 false true 108 108 85
Line -7500403 true 180 120 225 75
Line -7500403 true 195 75 225 75
Line -7500403 true 225 75 225 105
Circle -7500403 true true 103 103 92

male fish
false
4
Polygon -14835848 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -14835848 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1184463 true true 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -14835848 true false 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

mouse
false
0
Polygon -7500403 true true 38 162 24 165 19 174 22 192 47 213 90 225 135 230 161 240 178 262 150 246 117 238 73 232 36 220 11 196 7 171 15 153 37 146 46 145
Polygon -7500403 true true 289 142 271 165 237 164 217 185 235 192 254 192 259 199 245 200 248 203 226 199 200 194 155 195 122 185 84 187 91 195 82 192 83 201 72 190 67 199 62 185 46 183 36 165 40 134 57 115 74 106 60 109 90 97 112 94 92 93 130 86 154 88 134 81 183 90 197 94 183 86 212 95 211 88 224 83 235 88 248 97 246 90 257 107 255 97 270 120
Polygon -16777216 true false 234 100 220 96 210 100 214 111 228 116 239 115
Circle -16777216 true false 246 117 20
Line -7500403 true 270 153 282 174
Line -7500403 true 272 153 255 173
Line -7500403 true 269 156 268 177

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
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0
-0.2 0 0 1
0 1 1 0
0.2 0 0 1
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@

@#$#@#$#@
