__includes [ "utilities.nls" ] ; all the boring but important stuff not related to content
extensions [ csv ]

; individual breeds for the three worker types + problem youth and the citizens. Garbage is also an agent?? (could also be a patch-agent)
breed [garbagecollectors garbagecollector]
breed [communityworkers communityworker]
breed [policeofficers policeofficer]
breed [problemyouth problemyoungster]
breed [citizens citizen]

; Sites as agents
breed [comcentre a-comcentre]
breed [initiatives initiative]
breed [schools school]
breed [religious a-religious]
breed [jobs job]
breed [supermarkets supermarket]
breed [policestations policestation]
breed [garbage a-garbage]
breed [burglaries burglary]

globals [
  ; variables for the map
  topleftx
  toplefty
  bottomrightx
  bottomrighty
  schoollist
  communitycenterlist
  policestationlist
  religioncenterlist
  ; variables for the model
  ;; time management and event times
  timenow ; hh:mm, reset after 23:50 -> 00:00
  minutenow ; minute counter, reset at 60
  hournow ; hour counter, reset at 24
  daynow ; day of the week, reset after 7 days
  weeknow ; week of the year, reset after 52 weeks
  yearnow ; end at year 4
  workday ; day 1 to 5 of the week
  schoolday ; == workday, day 1 to 5 of the week
  starttime ; starttime of working-/schoolday at 0800 = 48 ticks
  endtime ; endtime of working-/schoolday at 1800 = 108 ticks
  ;;;; time tick = 10min
  ;;;; day-cylce = 144 ticks
  ;; PLS global counter
  pls_global ; max 100
  pls_pos_small
  pls_pos_medium
  pls_pos_high
  pls_neg_small
  pls_neg_medium
  pls_neg_high
  initiative_pressure

  ;; event factors
  garbageprobability
  garbagefactor
  garbage_cap
  burglaryprobability
  burglaryfactor

  ;; state finances
  treasury ; 100-#police*10-#communityworker*5-#garbagecollector*4-#initiatives*2 , limit 0

  ; variables for agents
  ;; location community centre
  community_x ; added in utilities file that save the coordinates for community workers
  community_y ; added in utilities file that save the coordinates for community workers
  polstation_x ; added in utilities file that save the coordinates for police officers
  polstation_y ; added in utilities file that save the coordinates for police officers

  ;; garbagecollectors and garbage
  alternative_target_list
  g_col ; standard garbage color
  gres_col ; garbage color when targeted by garbagecollector (reserved)


]

patches-own [
  plocation ; the string holding the name of this location, default is 0
  pcategory ; string holding the category of the location, default is 0
  pcolorPatch; string with the color to each type of path in the csv file #Added by group
  ppls-value ; integer of pls bonus upon visit by agent, default is 0
  problemyouth_2 ; value that indicate the problem youth
  garbage-counter ; count the number of garbage agent in a radius
]

garbagecollectors-own [
  homelocation ; the home patch
  targetlocation ; assigns target location from schedule
  children ; number of children ; 37% have children
  hasreligion ; boolean if is religious or not ; proability of 50%
  schedule_start ; the agent's schedule list at the begining of the day
  schedule_end ; the agent's schedule list at the end of the day
  target ; variable that operates on the list of schedule
  target_garbage ; nearest garbage patch to collect
  target_school ; variable that determines the nearest school
  target_religious ; variable that determines the nearest religious building
  target_supermarket ; variable that determines the nearest supermarket from home
  schedule-counter ; variable for iterate on dayly schedule
]

communityworkers-own [
  homelocation ; the home patch
  targetlocation ; assigns target location from schedule
  children ; number of children ; 37% have children
  school-name ; school name
  hasreligion ; boolean if is religious or not ; proability of 50%
  religioncenter-name ; religion center name
  initiativework ; algorithm to work on the nearest initiative
  schedule_start ; the agent's schedule list at the begining of the day
  schedule_end ; the agent's schedule list at the end of the day
  target ; variable that operates on the list of schedule
  target_school ; variable that determines the nearest school
  target_religious ; variable that determines the nearest religious building
  schedule-counter ; variable for iterate on dayly schedule
]

citizens-own [
  pls_individual ; every agent's individual PLS value, default is 50/100
  homelocation ; the home patch
  targetlocation ; assigns target location from schedule
  children ; number of children ; 37% have children
  school-name ; school name
  hasreligion ; boolean if is religious or not ; proability of 50%
  religioncenter-name ; religion center name
  hasjob ; boolean if has a job ; proability of 60%
  joblocation ; job location
  hasinitiative ; boolean if takes part in initiatives ; proability of 12%
  initiative-name ; name of initiative he participates in
  schedule_start ; the agent's schedule list at the begining of the day
  schedule_end ; the agent's schedule list at the end of the day
  target ; variable that operates on the list of schedule
  target_job; variable that determines the nearest jobs-edge in the map from home
  target_supermarket ; variable that determines the nearest supermarket from home
  target_school ; variable that determines the nearest school  from home
  target_religious ; variable that determines the nearest religious building from home
  target_initiative ; variable that determines the nearest initiative from home
  schedule-counter ; variable for iterate on dayly schedule
  burglary_recent ; indicator if burglary recently occurred to citizen
  burglary_date ; indicates when burglary occurred to citizen
  urge_to_start_initiative ; indicates urge to start an initiative
]

garbage-own [
  garbagelocation
]

policeofficers-own [
  homelocation ; the home patch
  targetlocation ; assigns target location from schedule
  children ; number of children ; 37% have children
  school-name ; school name
  hasreligion ; boolean if is religious or not ; proability of 50%
  religioncenter-name ; religion center name
  polstationwork ; algorithm to work on the nearest initiative
  schedule_start ; the agent's schedule list at the begining of the day
  schedule_end ; the agent's schedule list at the end of the day
  target ; variable that operates on the list of schedule
  target_school ; variable that determines the nearest school
  target_religious ; variable that determines the nearest religious building
  schedule-counter
]

comcentre-own[
  comcentrelocation
]

jobs-own[
  jobslocation
]

policestations-own[
  policestationslocation
]

initiatives-own[
  initiativeslocation
  viability
]

schools-own[
  schoolslocation
  problemyouth_1 ;; For problem youth
]

supermarkets-own[
  supermarketlocation
  problemyouth_1 ;; For problem youth
]

religious-own[
  religiouslocation
]

burglaries-own[
  burglarylocation
  burglary_date
]

problemyouth-own[
  problemyouthlocation
]

to move-to-world-edge ;; moves until reaches edge of world ==> alternative for citizen going to job
  loop [
    if not can-move? 1 [stop]
    fd 1
    ]
end

to setup
  clear-all
  setupMap
  loadData
  set starttime 7
  set endtime 18
  set g_col orange ; standard garbage color
  set gres_col brown ; garbage color when targeted by garbagecollector (reserved)
  ;;;; CREATES locations as agents

  ;; Jobs on Edges
  let coords [[0 0] [0 784] [814 784] [814 0]]
  foreach coords [
    c  ->
    create-jobs 1 [
      setxy first c last c
      set shape "house"
      set color magenta
      set size 12
      set jobslocation patch-here
    ]
  ]



  ;; Community centre
  ;show patches with [pcategory = "community centre"]
  ;set-default-shape innitiatives "house"
  ;ask n-of 1 (patches with [pcategory = "community centre"])[sprout-innitiatives 1 [set color red]]
  ;;; Create community centre with coordinates read in the utilities.nls file
  create-comcentre 1 [
    setxy community_x community_y
    set shape "house"
    set color green
    set size 12
    set comcentrelocation patch-here
  ]
  ;; Neighbourhood innitiatives
  ;;; Create innitiatives with coordinates read in the utilities.nls file (Only for setup)
  ask n-of 5 (patches with [pcategory = "neighbourhood initiative"])[
    sprout-initiatives 1 [
      set color blue
      set shape "house"
      set size 12
      set initiativeslocation patch-here
      set label who
      set label-color black
  ]]
  ;; Schools
  ;;; Create schools with coordinates read in the utilities.nls file (Only for setup)
  ask n-of 13 (patches with [pcategory = "school"])[
    sprout-schools 1 [
      set color red
      set shape "house"
      set size 12
      set schoolslocation patch-here
      set label who
      set label-color black
      set problemyouth_1 1
  ]]

  ;; Assign patches with problem youth in supermarkets and schools
  ask schools[
    ask patch-here[
      set pcolor brown
      set problemyouth_2 1
    ]
  ]

  ;; Religious Buildings
  ;;; Create schools with coordinates read in the utilities.nls file (Only for setup)
  ask n-of 6 (patches with [pcategory = "religious"])[
    sprout-religious 1 [
      set color magenta
      set shape "triangle"
      set size 15
      set religiouslocation patch-here
      set label who
      set label-color black
  ]]

  ;; Supermarket
  ;;; Create supermarkets with coordinates read in the utilities.nls file (Only for setup)
  ask n-of 4 (patches with [pcategory = "supermarket"])[
    sprout-supermarkets 1 [
      set color yellow
      set shape "house"
      set size 15
      set supermarketlocation patch-here
      set problemyouth_1 1
      set label who
      set label-color black
  ]]

  ;; Assign patches with problem youth in supermarkets and schools
  ask supermarkets[
    ask patch-here[
      set pcolor brown
      set problemyouth_2 1
    ]
  ]

  ;;Policestation
  ;;;Create police stations at coordinates read in the utilities.nls file
  ask n-of 1 (patches with [pcategory = "police station"])[
    sprout-policestations 1 [
      set color black
      set shape "house"
      set size 12
      set policestationslocation patch-here
      set label who
      set label-color black
  ]]

  ;; GARBAGE
  create-garbage 4 [
    setxy random-xcor random-ycor
    set shape "square"
    set size 12
    set color orange
    set garbagelocation patch-here
  ]

  ;; GARBAGECOLLECTORS
  create-garbagecollectors 4 [
    setxy random-xcor random-ycor
    set shape "person"
    set size 12
    set color orange
    set homelocation patch-here ; records the home location of agent
    if random 100 < 38 ; 37% have children
      [ set children 1 + random-poisson 0.5
        set target_school min-one-of schools [distance myself] ] ; choose nearest school !
    if random 2 > 0 ; 50% have religion ; assuming that the randomizer equally often chooses 0 and 1
      [set hasreligion 1
      set target_religious min-one-of religious [distance myself]
    ]
    set target_supermarket min-one-of supermarkets [distance myself]
  ]

  ;; POLICEOFFICERS

  create-policeofficers Lever_PoliceOfficers[
    ;setxy random-xcor random-ycor
    setxy polstation_x polstation_y
    ;setxy 0 0
    set shape "person"
    set size 15
    set color black
    set homelocation patch-here ; records the home location of agent

    ifelse random 100 < 99 ; 37% have children
      [ set children random-poisson 1.2
       ]
      [ set children 0 ]
    set hasreligion random 2 ; 50% have religion ; assuming that the randomizer equally often chooses 0 and 1
  ]

  ;; COMMUNITYWORKERS
  create-communityworkers Lever_CommunityWorkers [
    setxy community_x community_y
    ;setxy 0 0
    set shape "person"
    set size 20
    set color blue
    set homelocation patch-here ; records the home location of agent

    if random 100 < 38 ; 37% have children
      [ set children 1 + random-poisson 0.5 ]
    set hasreligion random 2 ; 50% have religion ; assuming that the randomizer equally often chooses 0 and 1
  ]
    ;; create individual schedule for agent based on children, religion, job, initiatives

  ;; CITIZENS
  create-citizens Lever_Citizens [
    setxy random-xcor random-ycor
    set shape "person"
    set size 12
    set color grey
    set homelocation patch-here
    set pls_individual 50 ; max 100

    if random 100 < 38 ; 37% have children
      [ set children 1 + random-poisson 0.5 ]
    if random 100 < 61 ; 60% have job
      [ set hasjob 1]
    if random 100 < 13 ; 12% have initiative
      [ set hasinitiative 1 ]
    set hasreligion random 2 ; 50% have religion ; assuming that the randomizer equally often chooses 0 and 1
    ]
  ask citizens with [hasjob = 1][
    set target_job min-one-of jobs [distance myself]
    set color green
    ]

  ;ask citizens with [hasjob = 1 and children > 0][
  ;  set size 15
    ;watch-me
  ;]

  set alternative_target_list (list schools religious supermarkets comcentre citizens communityworkers garbagecollectors) ; policeofficers problemyouth initiatives policestations <-- uncomment once implemented !

    ;; TIMESETUP
  set minutenow 0 ; minute counter, reset at 60
  set hournow 0 ; hour counter, reset at 24
  set daynow 1 ; day of the week, reset after 7 days
  set weeknow 1 ; week of the year, reset after 52 weeks
  set yearnow 1 ; end at year 4
  set workday 1
  set schoolday 1
 ; set timenow [ yearnow weeknow daynow hournow minutenow ] ; hh:mm, reset after 23:50 -> 00:00

    ;; PLS_SETUP
  set pls_global (sum [pls_individual] of citizens) / count citizens
  set pls_pos_small random 2
  set pls_pos_medium (5 - random 3)
  set pls_pos_high (8 - random 3)
  set pls_neg_small random -3
  set pls_neg_medium (-5 + random 2)
  set pls_neg_high 10

  set garbageprobability 1  ; set the standard probability of garbage appearing
  set garbage_cap 20 ; caps the max amount of garbage created per instant. per defined formula, max possible amount is 11.
                    ; probably a cap around 5 is recommended
  set burglaryprobability 1 ; set the standard probability of burglary occuring

  reset-ticks

end

to go

;;;;;;;;;;;;;;;;;;;;;;
;;;;;; PLS-RELATED EVENTS

set pls_global (sum [pls_individual] of citizens) / count citizens ; re-evaluates global PLS rating every

set garbagefactor ((1 - pls_global / 100) * garbageprobability) ; evaluate garbagefactor in dependence of global pls-value. high pls -> low factor
 ; burglaryfactor ((1 - pls_global / 100) * burglaryprobability) ; evaluate burglaryfactor in dependence of global pls-value. high pls -> low factor
;;;;;; END PLS
;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Create Garbage
if minutenow > ( 30 - minute_step) and minutenow < (30 + minute_step) [
  spawn-random-garbage
]

;;;;;; End GARBAGE
;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; CITIZENS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; They start at starttime and end at endtime
;;;; They go 5/7 days to work to the nearest edge in the map
  if hournow = 0 and minutenow = 0[
    ask citizens with [ hasjob = 1][
      set schedule_start []
      set schedule_end []
      set schedule_start fput target_job schedule_start
      set schedule_end fput homelocation schedule_end; schedule home
      if PBernoulli (3 / 7) [
        set target_supermarket min-one-of supermarkets [distance myself]
        set schedule_end fput target_supermarket schedule_end ; add supermarket building to schedule, first position
      ]

      if PBernoulli (1 / 7) [
        set target_initiative min-one-of initiatives [distance myself]
        set schedule_end fput target_initiative schedule_end ; add supermarket building to schedule, first position
      ]
      set target []
      ;show schedule_start
    ]
    ask citizens with [hasjob = 1 and hasreligion > 0][
      if PBernoulli (1 / 7) [
        set target_religious min-one-of religious [distance myself]
        set schedule_start fput target_religious schedule_start ; add religious building to schedule, first position
      ]
    ]
    ask citizens with [hasjob = 1 and children > 0][
      if PBernoulli (5 / 7) [
        set target_school min-one-of schools [distance myself]
        set schedule_start fput target_school schedule_start ; add school to schedule, first position
        set schedule_end fput target_school schedule_end ; add school to schedule, first position
      ]
    ]
  ]

  ask citizens with[ hasjob = 1] [
     if hournow = 0 [
      set schedule-counter 0
      set target []
    ]
     if hournow >= starttime [

      if hournow = starttime and minutenow = 0[
        if target = [] [
          set target item schedule-counter schedule_start
        ]
        face target
        ;show target
      ]
      if hournow < endtime[
        move-turtles
        if distance target = 0 and (last schedule_start) != target[
          set schedule-counter schedule-counter + 1
          set target item schedule-counter schedule_start
          face target
          ;show target
        ]
      ]
      if hournow = endtime and minutenow = 0 [
        set schedule-counter 0
        set target item schedule-counter schedule_end
        face target
        ;show target
      ]
      if hournow > endtime[
        move-turtles
        if distance target = 0 and target != homelocation [
          set schedule-counter schedule-counter + 1
          set target item schedule-counter schedule_end
          face target
          ;show target
        ]
      ]
    ]
    ;; --> add:
    ;; --> pls_individual update by encounters and burglaries
    ;; --> related: "ask garbagecollector 37 [ ask patches in-radius 10 [set pcolor red]]"
    ;; --> depending on PLS, citizens start an initiative at citizen location
  ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ;;;  COMMUNITY WORKERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if hournow = 0 and minutenow = 0[
    ask communityworkers [
      set schedule_start []
      set schedule_end []
      set schedule_start fput (one-of initiatives) schedule_start
      set schedule_end fput homelocation schedule_end; schedule home
      set target []
    ]
    ask communityworkers with [hasreligion > 0][
      if PBernoulli (1 / 7) [
        set target_religious min-one-of religious [distance myself]
        set schedule_start fput target_religious schedule_start ; add religious building to schedule, first position
      ]
    ]
    ask communityworkers with [children > 0][
      if PBernoulli (5 / 7) [
        set target_school min-one-of schools [distance myself]
        set schedule_start fput target_school schedule_start ; add school to schedule, first position
        set schedule_end fput target_school schedule_end ; add school to schedule, first position
      ]

    ]
   ask communityworkers [
    show schedule_start
    show schedule_end
   ]
  ]


  ask communityworkers [
     if hournow = 0 [
      set schedule-counter 0
      set target []
    ]
     if hournow >= starttime [
      if hournow = starttime and minutenow = 0[
        if target = [] [
          set target item schedule-counter schedule_start
        ]
        face target
        ;show target
      ]
      if hournow < endtime[
        move-turtles
        if distance target = 0 and (last schedule_start) != target[
          set schedule-counter schedule-counter + 1
          set target item schedule-counter schedule_start
          face target
          ;show target
        ]
      ]
      if hournow = endtime and minutenow = 0 [
        set schedule-counter 0
        set target item schedule-counter schedule_end
        face target
        ;show target
      ]
      if hournow > endtime[
        move-turtles
        if distance target = 0 and target != homelocation [
          set schedule-counter schedule-counter + 1
          set target item schedule-counter schedule_end
          face target
          ;show target
        ]
      ]
    ]
  ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ;;;  GARBAGECOLLECTORS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ask garbagecollectors [
;;; on WORKDAYS
  if workday = 1 and hournow + minutenow = 0[
    set schedule_start []
    set schedule_end []
      if hasreligion > 0 and PBernoulli ( 1 / 7 ) [
      set schedule_start fput target_religious schedule_start
    ]
    if children > 0 [
      set schedule_start lput target_school schedule_start
      set schedule_end fput target_school schedule_end
    ]
    set schedule_end lput homelocation schedule_end; schedule home
    if schedule_start = [] [
      ifelse [color = g_col] of min-one-of garbage [distance myself] [
        set target_garbage min-one-of garbage [distance myself]
        ask target_garbage [set color gres_col]
        set schedule_start lput target_garbage schedule_start
      ][set target_garbage one-of garbage with [color = g_col]
        ifelse target_garbage != nobody [
          ask target_garbage [set color gres_col]
          set schedule_start lput target_garbage schedule_start]
          [set target one-of one-of alternative_target_list  ; if last target reached but != garbage-breed and timenow <endtime: choose random target
            set schedule_start lput target schedule_start]    ; add to schedule
        ]
    ]
  ]
;;; on WEEKENDS
  if workday = 0 and hournow + minutenow = 0 [
    set schedule_start []
    set schedule_end []
      if hasreligion > 0 and PBernoulli ( 1 / 7 ) [
      set schedule_start fput target_religious schedule_start
    ]
    set schedule_start lput target_supermarket schedule_start ; add supermarket building to schedule, last position
    set schedule_end lput homelocation schedule_end ; to return home at end of day
  ]
]
ask garbagecollectors [
     if hournow = 0 [
      set schedule-counter 0
      set target []
    ]
     if hournow >= starttime [
      if hournow = starttime and minutenow = 0[
        if target = [] [set target item schedule-counter schedule_start]
        face target]
      if hournow < endtime[    ;; add --> while on "last" of "schedule_start", continue going to garbage
        move-turtles
        if distance target = 0 and (last schedule_start) != target[
          set schedule-counter schedule-counter + 1
          set target item schedule-counter schedule_start
          face target]
        if distance target = 0 and (last schedule_start) = target[
          ifelse [breed] of target = garbage [                 ; if last entry is garbage, eat garbage and remove from list
            set schedule_start remove target schedule_start
            set schedule-counter schedule-counter - 1          ; remove counter 1
            ask target [die]                                   ; kill target garbage
            ifelse min-one-of garbage [distance myself] = nobody [
              set target one-of one-of alternative_target_list
              set schedule_start lput target schedule_start][
              ifelse [color = g_col] of min-one-of garbage [distance myself] [ ; need new target on schedule
                set target_garbage min-one-of garbage [distance myself]        ; if closest garbage is free/orange, target this
                ask target_garbage [set color gres_col]                        ; reservev garbage by setting color brown
                set target target_garbage
                set schedule_start lput target_garbage schedule_start          ; add target to schedule
              ][set target_garbage one-of garbage with [color = g_col]         ; if closest garbage already taken, choose random with col=orange
                ifelse target_garbage = nobody [                               ; if chosen turns out dead
                  set target one-of one-of alternative_target_list             ; if new target is nobody and timenow <endtime: choose random target
                  set schedule_start lput target schedule_start]               ; add new target to schedule
                  [ask target_garbage [set color gres_col]                     ; else: chosen available, reserve/set col=brown
                  set schedule_start lput target_garbage schedule_start        ; add to schedule
                  set target target_garbage]] ] ]                              ; set target
           [set target one-of one-of alternative_target_list  ; if last target reached but != garbage-breed and timenow <endtime: choose random target
            set schedule_start lput target schedule_start]    ; add to schedule
            face target
            ]
          ]
      ]
      if hournow = endtime and minutenow = 0 [
        set schedule-counter 0
        set target item schedule-counter schedule_end
        ask garbage [set color g_col]
        face target]
      if hournow > endtime[
        move-turtles
        if distance target = 0 and target != homelocation [
          set schedule-counter schedule-counter + 1
          set target item schedule-counter schedule_end
          face target]
      ]
  ]
;;;;;; END GARBAGECOLLECTORS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Police Stations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; if hournow = 0 and minutenow = 0 [
;   ask policeofficers [
;     set schedule_start []
;     set schedule_end []
;     set schedule_start fput (one-of policestations) schedule_start
;     set schedule_end fput homelocation schedule_end; schedule home
;     set target []
;     ]
;   ask policeofficers with [hasreligion > 0][
;     if PBernoulli (1 / 7) [
;       set target_religious min-one-of religious [distance myself]
;       set schedule_start fput target_religious schedule_start ; add religious building to schedule, first position
;       ]
;     ]
;   ask policeofficers with [children > 0][
;     if PBernoulli (5 / 7) [
;       set target_school min-one-of schools [distance myself]
;       set schedule_start fput target_school schedule_start ; add school to schedule, first position
;       set schedule_end fput target_school schedule_end ; add school to schedule, first position
;       ]
;     ]
;   ]
;
;
; ask policeofficers [
;   if hournow = 0 [
;     set schedule-counter 0
;     set target []
;     ]
;   if hournow >= starttime [
;
;     if hournow = starttime and minutenow = 0[
;       if target = [] [
;         set target item schedule-counter schedule_start
;         ]
;       face target
;       ]
;     if hournow < endtime[
;       move-turtles
;       if distance target = 0 and (last schedule_start) != target[
;         set schedule-counter schedule-counter + 1
;         set target item schedule-counter schedule_start
;         face target
;         ]
;       ]
;     if hournow = endtime and minutenow = 0 [
;       set schedule-counter 0
;       set target item schedule-counter schedule_end
;       face target
;       ]
;     if hournow > endtime[
;       move-turtles
;       if distance target = 0 and target != homelocation [
;         set schedule-counter schedule-counter + 1
;         set target item schedule-counter schedule_end
;         face target
;         ]
;       ]
;     ]
;   ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ;;;  PROBLEM YOUTH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; PROBLEM YOUTH --- > is created at starttime; destroyed at endtime
  let probProblemyouth 0.5
if hournow = starttime [
    ask patches with [problemyouth_2 = 1][
      if pBernoulli (probProblemyouth)[set problemyouth_2  2]
    ]
  ask patches with [problemyouth_2 = 2][
    sprout-problemyouth 1 [
      set color yellow
      set shape "face sad"
      set size 30
      set problemyouthlocation patch-here
    ]
  ]
]

if hournow = endtime [
    ask problemyouth[
      ask patch-here[set problemyouth_2 1]
      die
    ]
  ]

if hournow > starttime and hournow < endtime and (hournow mod 3 = 0) and minutenow = 0 [ ; every three hours the problem youth generates litter
  spawn-probyouth-garbage ;; only creates garbage with problemyouth = 2
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ;;;  INTERACTION PROBLEM YOUTH AND POLICE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ask patches with [problemyouth_2 = 1][
   set garbage-counter count garbage in-radius 3
  ]

; ask policeofficers [
;      if hournow = 0 [
;      set schedule-counter 0
;      set target []
;    ]
;    if hournow >= starttime and hournow < endtime[
;      ;if yearnow = 1 and daynow = 1 and hournow = starttime and minutenow = 0[
;        if target = [] [
;          set target one-of patches with[problemyouth_2 = 2]
;          face target
;        ]
;      ;]
;      move-turtles;---> if they can do some rounds in circles just add the other function (FABIO)
;
;      ;;; Interaction police and problem youth
;      if distance target = 0 [
;        if any? problemyouth-here [
;          ask problemyouth-here [set shape "face happy"] ;;; Interaction with police eliminate problem youth
;          set target []
;          show [who] of problemyouth-here
;        ]
;      ask n-of 1 (patches with [problemyouth_2 = 1])[
;      sprout-problemyouth 1 [
;        set color yellow
;        set shape "face sad"
;        set size 30
;        set problemyouthlocation patch-here
;        ask patch-here [set problemyouth_2  2]
;        ]
;      ]
;      ]
;   ]
;     if hournow >= endtime [
;      set target homelocation
;      face target
;      move-turtles
;    ]
;]


timestep

end


to timestep
  ; advance time
  ifelse minutenow > (60 - minute_step) [ ; minute counter, steps of 10, from 50 --> set 00
    set hournow hournow + 1
    set minutenow 0]
    [ set minutenow minutenow + minute_step]
  if hournow = 24 [
    set daynow daynow + 1
    set hournow 0]
  if daynow = 8 [
    set weeknow weeknow + 1
    set daynow 1]
  if weeknow = 53 [
    set yearnow yearnow + 1
    set weeknow 1]
  if yearnow = 4 [
    stop]
  ifelse daynow < 6 [ ; day 1 to 5 of the week ==schoolday
    set workday 1
    set schoolday 1]
    [set workday 0
    set schoolday 0]
  tick ; next time step
end

to spawn-random-garbage
  let new_garbage_amount round (abs (random-normal 1 (1 / garbageprobability))  ; the garbageprobability-factor determines the standard deviation (SD)
                                ; of garbage creation. if pls is high (ex.90) -> factor is low (0.1), thus the SD is low SD: 1.
                                ; with a random-normal distribution with mean=1, this results in garbage production of 0 and 2 at high pls
                                ; and between 0 and 11 at low pls.
  if new_garbage_amount > garbage_cap [
    set new_garbage_amount garbage_cap
  ]
  create-garbage new_garbage_amount [
    setxy random-xcor random-ycor
    set shape "square"
    set color orange
    set size 12
    set garbagelocation patch-here
  ]
end

to spawn-probyouth-garbage
  ask patches with [problemyouth_2 = 2][
    sprout-garbage 1[
    set shape "square"
    set color orange
    set size 12
    set garbagelocation patch-here
    ]
  ]
end

to move-turtles
       ifelse distance target < distance_target
      [ move-to target ]
      [ face target
      fd citizen_speed ]
end

to move-turtles-radius
  ifelse  (distance target) < (5 * distance_target)
  [ ;; walking on circles to location
  ; ; reused for the code  Circular Path Example -
  ; Public Domain:
  ; To the extent possible under law, Uri Wilensky has waived all
  ; copyright and related or neighboring rights to this model.

  let r 5 * distance_target
  fd (pi * r / 180) * citizen_speed / 10
  rt (citizen_speed / 10)
  ]
  [ ;; moving straight to objective location
    face target
    fd citizen_speed
  ]
end

to random-walk
  set heading random 360 ; alternative: try to set random coordinates as target
  fd citizen_speed
end

to-report PBernoulli [ p ]
  report random-float 1 < p
end
@#$#@#$#@
GRAPHICS-WINDOW
218
10
1041
804
-1
-1
1.0
1
10
1
1
1
0
0
0
1
0
814
0
784
0
0
1
ticks
30.0

BUTTON
2
103
75
136
NIL
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
151
103
214
136
NIL
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

SWITCH
4
208
125
241
verbose?
verbose?
0
1
-1000

SWITCH
4
243
114
276
debug?
debug?
0
1
-1000

OUTPUT
1053
12
1664
188
12

MONITOR
63
56
132
101
NIL
hournow
17
1
11

SLIDER
4
278
176
311
citizen_speed
citizen_speed
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
4
313
176
346
minute_step
minute_step
0
59
5.0
0.5
1
NIL
HORIZONTAL

MONITOR
133
56
214
101
NIL
minutenow
17
1
11

SLIDER
4
348
176
381
distance_target
distance_target
0
100
20.0
1
1
NIL
HORIZONTAL

INPUTBOX
3
481
143
541
Lever_CommunityWorkers
5.0
1
0
Number

INPUTBOX
3
543
152
603
Lever_Citizens
10.0
1
0
Number

MONITOR
2
56
62
101
NIL
daynow
17
1
11

MONITOR
2
10
67
55
NIL
yearnow
17
1
11

MONITOR
68
10
137
55
NIL
weeknow
17
1
11

MONITOR
2
139
79
184
NIL
pls_global
17
1
11

INPUTBOX
3
419
143
479
Lever_PoliceOfficers
2.0
1
0
Number

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 6.1.1
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
