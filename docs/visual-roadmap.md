# Visual roadmap for Suomi NPC World 3.0

Tämä tiedosto näyttää, miltä jokainen kehitysvaihe tulee näyttämään palvelimella ja mitkä osat ovat toiminnallisia.

Huomautus: Tämä on visualisoitu "wireframe" / ASCII-layout, jotta näkymä on selkeä ennen varsinaista UI:n rakentamista. Jos haluat, voin myöhemmin muuttaa nämä mockupit oikeiksi HTML/CSS/NUI-luonnoksiksi.

---

## Vaihe 1 — NPC Core

Tavoite:
- palvelin tietää, että kaupungissa on NPC:itä
- jokaisella NPC:llä on perus identiteetti
- NPC näkyy mapissa ja on hallittavissa

Mockup:

```text
[ NPC CORE SYSTEM ]
---------------------------------------------------
NPC Count: 42
Active Zones: Downtown, Sandy Shores, Vespucci
Population Status: Active
Simulation: 60 fps stable

NPC LIST
---------------------------------------------------
1. npc_001 | Matti Virtanen | mechanic | downtown
2. npc_002 | Janne Korhonen | civilian | downtown
3. npc_003 | Ari Nieminen | police | downtown
4. npc_004 | Laura Salmi | cashier | vespucci
5. npc_005 | Timo Laine | taxi | sandy

[ Spawn NPC ]   [ Update State ]   [ Remove NPC ]
```

Server-side toiminta:
- NPC luodaan identiteetillä
- NPC saadaan spawnattua maailmaan
- state: idle / walking / patrol / work
- voidaan päivittää suoraan admin-panelista

---

## Vaihe 2 — NPC Identity System

Tavoite:
- NPC:llä on nimi, ikä, työ, koti, auto, rikoshistoria
- police MDT voi hakea henkilön tiedot

Mockup:

```text
===============================================
             MATTI VIRTANEN
===============================================
Age: 37
Gender: Male
Job: Mechanic
Residence: Palomino Ave 18
Vehicle: ABC-123 / BMW 320
License: Valid
Criminal Record: 1 minor traffic offense

Recent Activity:
- Worked at garage downtown
- Visited market at 14:20
- Left home at 15:10

[ View Records ]   [ Add Criminal Note ]   [ Police Link ]
===============================================
```

Server-side toiminta:
- NPC data tallennetaan muistiin / tietokantaan
- voidaa hakea henkilön perusteella
- police MDT pystyy yhdistämään henkilöön ajoneuvon / tapaukset

---

## Vaihe 3 — NPC Daily Life Engine

Tavoite:
- NPC:t liikkuvat arkielämässä
- työ -> koti -> kauppa -> vapaa-aika
- kaupungin elämä näyttää elävältä

Mockup:

```text
             CITY DAILY LIFE
---------------------------------------------------
08:00  Work starts          [ Mechanic open ]
10:30  Travel to market     [ Walking / Driving ]
12:00  Lunch / break        [ Idle ]
14:00  Shopping            [ Civilians active ]
17:30  Return home         [ Home route ]
20:00  Leisure time        [ Café / park ]
23:00  Sleep cycle         [ Home state ]

NPC Activity Grid
---------------------------------------------------
Matti      WORK -> MARKET -> HOME
Janne      WALKING -> SHOPPING -> HOME
Ari        PATROL -> POLICE STATION -> PATROL
Laura      CASHIER -> HOME -> SHOPPING
---------------------------------------------------
```

Server-side toiminta:
- NPC:llä on aikataulu
- state vaihtuu automaattisesti:
  idle / walking / shopping / work / patrol / home
- kaupungin elämä rakennetaan ajan mukaan

---

## Vaihe 4 — NPC Crime Engine

Tavoite:
- NPC tekee rikoksia / toimii väärin
- joku näkee tapahtuman
- rikos kirjautuu järjestelmään

Mockup:

```text
[ CRIME EVENT ]
---------------------------------------------------
Crime Type: Armed Robbery
Location: Vespucci Blvd 24
Time: 21:43
Suspect: Matti Virtanen
Witnesses: 2
Status: Active investigation

DETAILS
---------------------------------------------------
- Suspect seen near vehicle
- Unknown male fled after confrontation
- Witness reported weapon visible
- Vehicle plate: ABC-123

[ Dispatch Call ]   [ Add Evidence ]   [ Link Witness ]
```

Server-side toiminta:
- rikosgenerointi tapahtuu NPC:n state logiikan kautta
- witnessit voivat huomata tapahtuman
- dispatch saa eventin ja luo tehtävän
- evidence voidaan liittää tapausnumeroon

---

## Vaihe 5 — Dispatch + 112 System

Tavoite:
- poliisi näkee aktiiviset tehtävät
- NPC soittaa 112:een
- dispatch vastaanottaa ilmoituksen

Mockup:

```text
                  [ POLICE DISPATCH ]
---------------------------------------------------
ACTIVE CALLS
---------------------------------------------------
[RED] PRIORITY 1  A R M E D   R O B B E R Y
     Location: Vespucci Blvd 24
     Time: 21:43
     Caller: NPC witness
     Suspect: Male, black jacket
     Vehicle: BMW 320 / ABC-123
     [ Accept ] [ Navigate ]

ACTIVE UNITS
---------------------------------------------------
301 - Patrol
305 - Traffic stop
312 - En route
318 - Available

MAP OVERVIEW
---------------------------------------------------
   POLICE 301  ---------  CRIME LOCATION
       |                     |
   POLICE 312  ---------  WITNESS POINT
---------------------------------------------------
```

Server-side toiminta:
- NPC witness lähettää eventin
- dispatch luo tehtävätaulun
- police unit saa taskin
- voidaan liittää navigatoriin / blipiin / markeriin

---

## Vaihe 6 — Police MDT

Tavoite:
- poliisi avaa henkilön / ajoneuvon / tapauksen tiedot
- näkee rikoshistorian, BOLO:n, warrantit ja todistusaineiston

Mockup:

```text
========================================
             POLICE MDT
========================================
[ Search Person ]   [ Search Vehicle ]   [ Active Warrants ]
---------------------------------------------------
PERSON RECORD
Name: Matti Virtanen
Age: 37
DOB: 14.05.1989
Address: Palomino Ave 18
Employment: Mechanic
License: Active
Criminal History:
- Traffic violation
- Public disturbance
- No active warrant

Associated Vehicles:
- ABC-123 BMW 320
- XYZ-882 Volvo V70

[ View Cases ]   [ Add Report ]   [ Quick Arrest ]
========================================
```

Server-side toiminta:
- henkilöhaun tulos yhdistää NPC:n profiilin
- ajoneuvot näkyvät
- rikoshistoria ja warrant-luettelo tulee MDT:hen
- voidaan avata aktiviset case-tiedot

---

## Vaihe 7 — Evidence & Case System

Tavoite:
- rikoslinkit ja todisteet yhdistetään tapausnumeroon
- poliisi voi seurata bensaa / järjestelmän linkkejä

Mockup:

```text
CASE #2026-00981
-----------------------------------------------
Title: Armed robbery at Vespucci Blvd 24
Status: Investigation in progress
Suspect: Matti Virtanen
Primary Witness: NPC witness #18
Vehicle: ABC-123 / BMW 320
Evidence Items:
1. CCTV footage
2. Tire mark evidence
3. Weapon trace
4. Witness statement

[ Link to Person ]   [ Link to Vehicle ]   [ Add Evidence ]
-----------------------------------------------
```

Server-side toiminta:
- tapausnumero, henkilöt, ajoneuvot ja todisteet linkittyvät toisiinsa
- police MDT ja dispatch nähvät samat tiedot
- evidence voidaan liittää NPC:n muistiin ja toiminta-loggeriin

---

## Yhteenveto

Jokainen vaihe vastaa yhtä kognitiivista kerrosta:

1. NPC Core = olemassaolo
2. Identity = profiili
3. Daily Life = arkielämä
4. Crime = tapahtuma
5. Dispatch = reagointi
6. MDT = poliisityökalu
7. Evidence = tutkinta

Tämä on oikea kehitysjärjestys.

Jos haluat, voin seuraavaksi tehdä:
- varsinaisen HTML/CSS/NUI-mockupin jokaisesta vaiheesta
- lisätä tiettyjä qb-core tiedostoja projektin mukaan
- aloittaa seuraavan konkreettisen moduulin: NPC Crime Engine

Tämä on toimiva ja skaalautuva suunnitelma, joka pitää projektin hallittavana.
