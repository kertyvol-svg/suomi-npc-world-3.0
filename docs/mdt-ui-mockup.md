# MDT UI visual mockup

Tämä tiedosto esittää, miltä poliisin MDT-näkymä voisi näyttää pelissä.

## Käyttöliittymän idea

- vasemmalla sivupalkki: valikko
- keskiössä: henkilön tiedot ja hakutulokset
- oikealla: ajoneuvo, rikoshistoria, BOLO, warrant-listat
- yläosassa: haku ja palvelimen tila

## Layout

```text
┌──────────────────────────────────────────────────────────────────────────┐
│ POLICE MDT                           [SEARCH BAR]     SYSTEM ONLINE │
├───────────────┬───────────────────────────────────────────────┬──────────┤
│ Dashboard      │ Person Record / Search Results              │ Vehicle  │
│ Person Search  │                                           │ History  │
│ Vehicles       │  [Avatar] Matti Virtanen                    │ Warrant  │
│ Warrants       │  Age: 37 | Job: Mechanic                   │ BOLO     │
│ BOLO           │  Residence: Palomino Ave 18                 │ Cases    │
│ Cases          │  Vehicle: ABC-123 / BMW 320                │          │
│ Evidence       │  License: Valid                             │          │
│ Dispatch       │  Last seen: Vespucci Blvd                   │          │
│                │  Criminal history: 2 entries                │          │
│                │  [View cases] [Add report] [Quick arrest]  │          │
├───────────────┴───────────────────────────────────────────────┴──────────┤
│ Active calls: 12 | Warrants: 4 | BOLO: 7 | Cases: 31                     │
└──────────────────────────────────────────────────────────────────────────┘
```

## Pelinäkymän typologia

- Ensisijainen näkymä: henkilö / ajoneuvo / tapaus
- Poliisilla tulee olla korkean prioriteetin virka-ikkunat
- NUI näyttää pienemmän, moottorin tyylisen paneelin ilman "heavy" UI-osaamista
- Fallback: tekstipohjainen UI jos NUI ei ole vielä käytössä

## Suunniteltu käyttö

1. Hae henkilö
2. Näytä rekisteritiedot
3. Näytä ajoneuvot
4. Näytä rikoshistoria
5. Näytä BOLO / Warrant
6. Linkitä tapaus ja todistusaineisto

## Oikea toteutus

- HTML/CSS NUI
- QBCore eventit:
  - `police_mdt:server:searchPerson`
  - `police_mdt:server:searchVehicle`
  - `police_mdt:server:getPersonRecord`
- NUI-sovitin lähettää `SetNuiFocus(true, true)` poliisin ikkunalle
- Tiedot palautetaan JSON:na ja renderöidään UI:hin

Tämä mockup toimii pohjana sille, kun halutaan oikea UX:n toteutus FiveM/NUI:lla.
