# Suomi NPC World 3.0

Tämä repositorio on FiveM-QBCore-pohjainen kehitysalusta, jossa rakennetaan NPC-voimainen roolipeliympäristö suomalaisella tunnelmalla.

Tavoite on luoda toimiva ja skaalautuva perusta, jossa pelaaja toimii esimerkiksi poliisina ja koko kaupunki toimii NPC-voimaisesti. Tämän projektin perusta on rakentaa ensin:

- NPC Core
- NPC identity + state system
- NPC daily life + job system
- NPC crime generation
- Police MDT / Dispatch / Implements
- evidencia, warrant ja BOLO-järjestelmät

## Pääperiaatteet

1. Ei tarvitse tehdä kaikkea yhtä kertaa
2. Rakennetaan modulaarisesti
3. Jokainen järjestelmä toimii itsenäisesti
4. Ajan myötä yhdistetään QBCore, MDT, dispatch ja NPC-world

## Kansiorakenne

```text
resources/
  [core]/
    npc_core/
      client/
      server/
      shared/
      fxmanifest.lua
sql/
  npc_core.sql
README.md
```

## Ensimmäinen kehitysvaihe

Tässä checkpointissä rakennetaan:

- NPC Core resource
- Perus-NPC spawn
- NPC-tiedot
- State system
- Perusteet dispatchin yhdistämistä varten

## Seuraavat askeleet

1. NPC daily routine engine
2. NPC identity and memory system
3. Crime generation engine
4. Police MDT integration
5. Dispatch and 112 system
6. Evidence & case management

## Kehityksestä

Projektia rakennetaan vaiheittain, jotta joka osa pysyy hallittavissa ja testattavissa.

---

Tämä on alku. Seuraavaksi lisätään NPC daily routine, identity system ja state machine.
