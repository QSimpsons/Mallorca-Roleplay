-- Plak deze blokken IN de items-tabel van ox_inventory/data/items.lua.
-- Niet het hele bestand vervangen.
--
-- Daarna de PNG's uit install/images/ kopiëren naar ox_inventory/web/images/
-- Dezelfde bestandsnaam, bijvoorbeeld popbang_stage1.png.
--
-- Geen SQL. ox_inventory leest de items uit dit lua-bestand.

['popbang_stage1'] = {
    label = 'Pop & Bangs Stage 1',
    weight = 1800,
    stack = true,
    close = true,
    consume = 0,
    description = 'Milde uitlaatpops als je het gas loslaat.',
    client = {
        image = 'popbang_stage1.png',
        export = 'snelle-popandbangs.useInstallItem'
    }
},

['popbang_stage2'] = {
    label = 'Pop & Bangs Stage 2',
    weight = 2000,
    stack = true,
    close = true,
    consume = 0,
    description = 'Vaker pops en korte vlammetjes.',
    client = {
        image = 'popbang_stage2.png',
        export = 'snelle-popandbangs.useInstallItem'
    }
},

['popbang_stage3'] = {
    label = 'Pop & Bangs Stage 3',
    weight = 2200,
    stack = true,
    close = true,
    consume = 0,
    description = 'Duidelijke bangs en uitlaatvlammen.',
    client = {
        image = 'popbang_stage3.png',
        export = 'snelle-popandbangs.useInstallItem'
    }
},

['popbang_stage4'] = {
    label = 'Pop & Bangs Stage 4',
    weight = 2400,
    stack = true,
    close = true,
    consume = 0,
    description = 'Antilag: ook pops terwijl je gas geeft.',
    client = {
        image = 'popbang_stage4.png',
        export = 'snelle-popandbangs.useInstallItem'
    }
},

['popbang_stage5'] = {
    label = 'Pop & Bangs Stage 5',
    weight = 2700,
    stack = true,
    close = true,
    consume = 0,
    description = 'Harde bangs en grote blauwe vlammen.',
    client = {
        image = 'popbang_stage5.png',
        export = 'snelle-popandbangs.useInstallItem'
    }
},

['popbang_stage6'] = {
    label = 'Pop & Bangs Stage 6',
    weight = 3000,
    stack = true,
    close = true,
    consume = 0,
    description = 'Maximale pops, bangs en grote uitlaatvlammen.',
    client = {
        image = 'popbang_stage6.png',
        export = 'snelle-popandbangs.useInstallItem'
    }
},

['popbang_remover'] = {
    label = 'Pop & Bangs verwijderkit',
    weight = 800,
    stack = true,
    close = true,
    consume = 0,
    description = 'Haalt pop & bangs van een voertuig af.',
    client = {
        image = 'popbang_remover.png',
        export = 'snelle-popandbangs.useRemoveItem'
    }
},
