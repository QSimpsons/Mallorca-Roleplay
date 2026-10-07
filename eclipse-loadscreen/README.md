# Eclipse Roleplay loadingscreen

Custom loadingscreen met een eigen mp4, thema-muziek en de echte laadvoortgang van FiveM.

## Installeren

1. Zet de map `eclipse-loadscreen` in `resources`.
2. Zet dit in `server.cfg`:

```
ensure eclipse-loadscreen
setr sv_showBusySpinnerOnLoadingScreen false
```

3. Houd één resource met een `loadscreen` actief. Een tweede loadingscreen overschrijft deze.
4. Pas Discord, het staffteam, regels, sneltoetsen en tips aan in `config.js`.

## Staffteam

Het paneel links bovenaan leest `staff` in `config.js`. Elke regel heeft een `role` en een `name`. Een lege naam wordt overgeslagen. Zet `staff.enabled` op `false` om het hele paneel te verbergen.

```js
staff: {
    enabled: true,
    title: "Staffteam",
    members: [
        { role: "Eigenaar", name: "Jouw naam" },
        { role: "Admin", name: "Jouw naam" },
    ],
},
```

De naam op het scherm komt uit `deferrals.handover` tijdens het verbinden. Staat er geen naam, dan blijft die regel weg.

## Clip

`clip.url` in `config.js` is de YouTube-video die als achtergrond speelt. Het geluid komt uit die video. Tijdens het laden blijven de regels, het staffteam en de laadstreep zichtbaar. Pas als het laden klaar is, faden die weg en komt **Eclipse Roleplay** in beeld.

De video blijft op YouTube staan. Lukt afspelen niet, bijvoorbeeld omdat de eigenaar insluiten heeft uitgezet, dan speelt `assets/background.mp4` en het thema-geluid. Zet `clip.enabled` op `false` om meteen die eigen mp4 te gebruiken. De speler heeft internet nodig zolang de YouTube-clip aan staat.

## Geluid

`Spatie` of `M` zet het geluid aan of uit. Het volume staat rechtsonder.

Staat de YouTube-clip uit, dan speelt `assets/theme.ogg`. Vervang dat bestand door een eigen nummer en pas `music.title` in `config.js` aan. Gebruik een track waar je zelf de rechten van hebt.

## Video

`assets/background.mp4` is een naadloze 1920×1080-loop van 12 seconden. Opnieuw renderen vanaf de repository-root:

```
python3 tools/render_eclipse_loadscreen.py
```

Daarvoor zijn Python 3, Pillow, NumPy en ffmpeg nodig.

## Vast op het laadscherm

De resource sluit het scherm zelf zodra de netwerksessie start, met een korte fade. Haal `loadscreen_manual_shutdown` en `client_script` uit `fxmanifest.lua` als het scherm moet sluiten op het standaard moment van FiveM.
