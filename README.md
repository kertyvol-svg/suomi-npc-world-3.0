# Suomi NPC World 3.0

Tämä repositorio on FiveM-QBCore-pohjainen kehitysalusta, jossa rakennetaan NPC-voimainen roolipeliympäristö suomalaisella tunnelmalla.

Tavoite on luoda toimiva ja skaalautuva perusta, jossa pelaaja toimii esimerkiksi poliisina ja koko kaupunki toimii NPC-voimaisesti.

## Projektin kehitysvaiheet

1. NPC Core
   - NPC luonti
   - state machine
   - spawnaus
   - perus registri

2. NPC Identity System
   - henkilötiedot
   - palkka, työ, koti, omistukset
   - muistijälki
   - suhdeverkko

3. NPC Daily Life Engine
   - työ -> koti -> kauppa -> vapaa-aika
   - reititys ja aikataulut
   - perus NPC-world simulointi

4. NPC Crime Engine
   - rikosgenerointi
   - witnessit
   - 112-puhelu
   - dispatch-tehtävät

5. Police MDT / Dispatch
   - kansalais-/ajoneuvorekisteri
   - BOLO / warrant
   - evidence
   - case system

## Kehitystilanne

Tällä hetkellä repositorioon on lisätty:

- NPC Core perusta
- shared config
- server-side NPC registration
- SQL schema pohja

Uusi kehitystaso rakentaa seuraavaksi:

- NPC Identity System
- NPC Daily Life Engine
- NPC state transitions

## Kansiorakenne

```text
resources/
  [core]/
    npc_core/
    npc_identity/
    npc_daily_life/
sql/
  npc_core.sql
README.md
```
