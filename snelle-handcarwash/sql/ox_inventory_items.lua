-- Plak deze items in ox_inventory/data/items.lua
-- Kopieer daarna de PNG's uit snelle-handcarwash/html/images/ naar
-- ox_inventory/web/images/  (of gebruik eigen iconen met dezelfde bestandsnaam).

['empty_bucket'] = {
    label = 'Lege emmer',
    weight = 500,
    stack = true,
    close = true,
    description = 'Vul deze emmer bij een waterpunt, kraan of in open water.',
    client = { image = 'empty_bucket.png' }
},

['water_bucket'] = {
    label = 'Emmer water',
    weight = 3500,
    stack = false,
    close = true,
    description = 'Emmer met water. Nodig om een voertuig met de hand te wassen.',
    client = { image = 'water_bucket.png' }
},

['car_sponge'] = {
    label = 'Autospong',
    weight = 200,
    stack = true,
    close = true,
    description = 'Spons om de carrosserie te schrobben. Gaat niet kapot bij gebruik.',
    client = { image = 'car_sponge.png' }
},

['car_soap'] = {
    label = 'Autoshampoo',
    weight = 400,
    stack = true,
    close = true,
    description = 'Shampoo voor een handwas. Wordt per wasbeurt verbruikt.',
    client = { image = 'car_soap.png' }
},

['microfiber_cloth'] = {
    label = 'Microvezeldoek',
    weight = 150,
    stack = true,
    close = true,
    description = 'Doek om het voertuig streeploos af te drogen.',
    client = { image = 'microfiber_cloth.png' }
},

['car_wax'] = {
    label = 'Autowax',
    weight = 350,
    stack = true,
    close = true,
    description = 'Waxlaag die het voertuig langer schoon houdt.',
    client = { image = 'car_wax.png' }
},

['tire_cleaner'] = {
    label = 'Velgenreiniger',
    weight = 400,
    stack = true,
    close = true,
    description = 'Reiniger voor banden en velgen.',
    client = { image = 'tire_cleaner.png' }
},

['hand_carwash_kit'] = {
    label = 'Handwas set',
    weight = 4500,
    stack = false,
    close = true,
    description = 'Complete set: wassen, drogen en waxen in één keer.',
    client = { image = 'hand_carwash_kit.png' }
},
