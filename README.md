# ABM_citizenPLS_in_Bouwlust

This is part of the course SEN1211 at TUDelft.

## Context

The case is situated in the City of The Hague. This city is one of the most fragmented and diverse cities
in The Netherlands. This means that people from many different backgrounds are living together and in
some neighbourhoods this could complicate the management of liveability and safety problems.
Examples of problems in the neighbourhood, affecting liveability and sense of safety are hang youth,
drug abuse, lonely elderly, litter and lack of community/social space. We use Bouwlust1 , the area
bounded by the Meppelweg, Dedemvaartsweg, Erasmusweg and Lozrelaan, as a case study
neighbourhood.

## notes

### 1. Done

- initial setup of map and locations
- communityworkers (agent)
- citizens (agent)
- garbagecollectors (agent)
- random garbage (agent)

### 2. in Progress

- policeofficers (agent) -> V.
- problemyouth (agent) -> F.
- burglaries (agent) -> F.
- PLS logic and the change of model behaviour from it -> I.
  - open:
    - pls-effect of locations = QR codes
    - pls-effect of other agents - if any --> discuss
    - pls-effect fine-tunine
  - done:
    - citizen count garbage, p-youth as neg. pls-effect
    - citizen register passing other citizen-agents (police, g-collectors, comm-workers, citizens) and get pos. pls-effect
    - includes difference in effect of passing policeofficer after burglary-event

### 3. still to do

- spending mechanism/budget tracking
- initiative viability mechanism --> initiatives die if not visited frequently
- check if logic can be simplified, i.e. combine similar if-statements
- write report
