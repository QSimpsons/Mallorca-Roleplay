Config = {}

-- Eenmalig bij de allereerste keer dat een speler ingame komt.
-- Bestaande spelers (al een rij in `users` op het moment dat dit aan gaat) krijgen niks.
Config.StarterVipCoins = 10000

Config.StoreData = {
    categories = {
        -- crates = {
        --     title = "Mysterie Crates",
        --     description = "Open mysterie pakketten voor willekeurige beloningen!",
        --     icon = "https://png.pngtree.com/png-vector/20231102/ourmid/pngtree-wooden-crate-wood-png-image_10416605.png",
        --     products = {
        --            {
        --             id = "matrix_crate",
        --             name = "Matrix Mystery Crate",
        --             description = "Een premium crate met betere beloningen",
        --             price = 50,
        --             images = {
        --                 "https://i.postimg.cc/5tmSfn9Q/zilveremysterybox.webp"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "WEAPON_M4A5V2", name = "WEAPON M4A5V2", amount = 1, probability = 25, type = "weapon" },
        --                 { id = "ammo_medium", name = "9mm Ammo", amount = 1000, probability = 35, type = "ammo" },
        --                 { id = "WEAPON_FOOLV2", name = "WEAPON FOOLV2", amount = 1, probability = 25, type = "weapon" },
        --                 { id = "RTGM8", name = "MXK 8 Speed", amount = 1, probability = 15, type = "car" }
        --             }
        --         },
        --         {
        --             id = "OG_crate",
        --             name = "OG Mystery Crate",
        --             description = "Een premium crate met betere beloningen",
        --             price = 60,
        --             images = {
        --                 "https://i.postimg.cc/5tmSfn9Q/zilveremysterybox.webp"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "rhinea19x", name = "Vindicator", amount = 1, probability = 35, type = "car" },
        --                 { id = "rwagvenm", name = "Torrenza", amount = 1, probability = 25, type = "car" },
        --                 { id = "rs666mini", name = "Mini Beast 6", amount = 1, probability = 15, type = "car" },
        --                 { id = "rmodlego2", name = " Astrion", amount = 1, probability = 25, type = "car" }
        --             }
        --         },
        --         {
        --             id = "Collecter_crate",
        --             name = "Collecter Mystery Crate",
        --             description = "Een premium crate met betere beloningen",
        --             price = 30,
        --             images = {
        --                 "https://i.postimg.cc/5tmSfn9Q/zilveremysterybox.webp"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "scr765LT", name = "Bravado Striker", amount = 1, probability = 15, type = "car" },
        --                 { id = "ammo_medium", name = "9mm Ammo", amount = 100, probability = 35, type = "ammo" },
        --                 { id = "WEAPON_FOOLV2", name = "WEAPON FOOLV2", amount = 1, probability = 25, type = "weapon" },
        --                 { id = "WEAPON FAMAS YELLOW L", name = "WEAPON FAMAS YELLOW L", amount = 1, probability = 25, type = "weapon" }
        --             }
        --         },
        --         {
        --             id = "Absolute_crate",
        --             name = "Collecter Mystery Crate",
        --             description = "Een premium crate met betere beloningen",
        --             price = 45,
        --             images = {
        --                 "https://i.postimg.cc/kXRGQd9w/95e75755-d885-40bb-af63-d9fb1d38d2a1.png"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "WEAPON_M4A5V2", name = "WEAPON M4A5V2", amount = 1, probability = 25, type = "weapon" },
        --                 { id = "WEAPON_GRU2", name = "WEAPON GRU2", amount = 1, probability = 25, type = "weapon" },
        --                 { id = "WEAPON_BULLPUP_SMG", name = "WEAPON BULLPUP SMG", amount = 1, probability = 25, type = "weapon" },
        --                 { id = "WEAPON_FAMAS_YELLOW", name = "WEAPON FAMAS YELLOW L", amount = 1, probability = 25, type = "weapon" }
        --             }
        --         },
        --         {
        --             id = "Suikerfeest_crate",
        --             name = "Suikerfeest Mystery Crate",
        --             description = "Een premium crate met betere beloningen",
        --             price = 35,
        --             images = {
        --                 "https://i.postimg.cc/5tmSfn9Q/zilveremysterybox.webp"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "WEAPON_GYSV2", name = "WEAPON GYSV2 L", amount = 1, probability = 35, type = "weapon" },
        --                 { id = "ammo_medium", name = "WEAPON GRU2", amount = 100, probability = 25, type = "ammo" },
        --                 { id = "DBg634x4byv", name = "10 Persoons Super", amount = 1, probability = 25, type = "car" },
        --                 { id = "rolls6x6", name = "[SUPER BEAST] 6X6", amount = 1, probability = 15, type = "car" }
        --             }
        --         },
        --         {
        --             id = "bronze_crate",
        --             name = "Bronze Mystery Crate",
        --             description = "Een basis crate met verschillende beloningen",
        --             price = 10,
        --             images = {
        --                 "https://i.postimg.cc/43G1CrGX/bronzemysterybox.webp"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "WEAPON_HFSMGV2", name = "WEAPON HFSMGV2", amount = 1, probability = 40, type = "weapon" },
        --                 { id = "WEAPON_GRU2", name = "WEAPON GRU2", amount = 1, probability = 30, type = "weapon" },
        --                 { id = "weapon_ump45", name = "UMP-45", amount = 1, probability = 20, type = "weapon" },
        --                 { id = "WEAPON_M4_TACTICAL_RED", name = "WEAPON M4 TACTICAL RED", amount = 1, probability = 10, type = "weapon" }
        --             }
        --         },
        --         {
        --             id = "silver_crate",
        --             name = "Silver Mystery Crate",
        --             description = "Een premium crate met betere beloningen",
        --             price = 15,
        --             images = {
        --                 "https://i.postimg.cc/5tmSfn9Q/zilveremysterybox.webp"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "cyphx", name = "Ravager", amount = 1, probability = 15, type = "car" },
        --                 { id = "rhinea19x", name = "Vindicator", amount = 1, probability = 45, type = "car" },
        --                 { id = "WEAPON_M4_TACTICAL_RED_R", name = "WEAPON M4 TACTICAL RED R", amount = 1, probability = 25, type = "weapon" },
        --                 { id = "WEAPON_ULLPUP_MG", name = "WEAPON BULLPUP SMG", amount = 1, probability = 15, type = "weapon" }
        --             }
        --         },
        --         {
        --             id = "golden_crate",
        --             name = "Golden Mystery Crate",
        --             description = "Een premium crate met betere beloningen",
        --             price = 30,
        --             images = {
        --                 "https://i.postimg.cc/5tmSfn9Q/zilveremysterybox.webp"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "rs666mini", name = "Mini Beast 6", amount = 1, probability = 35, type = "car" },
        --                 { id = "dubmono", name = "Dominex", amount = 1, probability = 15, type = "car" },
        --                 { id = "torosven", name = "Aetheron", amount = 1, probability = 25, type = "car" },
        --                 { id = "WEAPON_AWP_ASIIMOV", name = "AWP ASIIMOV L", amount = 1, probability = 25, type = "weapon" }
        --             }
        --         },
        --         {
        --             id = "diamond_crate",
        --             name = "Diamond Mystery Crate",
        --             description = "Een premium crate met betere beloningen",
        --             price = 40,
        --             images = {
        --                 "https://i.postimg.cc/5tmSfn9Q/zilveremysterybox.webp"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "dubmono", name = "Dominex", amount = 1, probability = 35, type = "car" },
        --                 { id = "kcjub", name = "Overdrive", amount = 1, probability = 25, type = "car" },
        --                 { id = "torosven", name = "Aetheron", amount = 1, probability = 25, type = "car" },
        --                 { id = "hycwagen", name = "Spectra", amount = 1, probability = 15, type = "car" }
        --             }
        --         },
        --         {
        --             id = "platinum_crate",
        --             name = "Platinum Mystery Cratplatinum",
        --             description = "Een premium crate met betere beloningen",
        --             price = 45,
        --             images = {
        --                 "https://i.postimg.cc/5tmSfn9Q/zilveremysterybox.webp"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "rhinea19x", name = "Vindicator", amount = 1, probability = 35, type = "car" },
        --                 { id = "dubmono", name = "Dominex", amount = 1, probability = 25, type = "car" },
        --                 { id = "weapon_rifle", name = "AK-47", amount = 1, probability = 25, type = "car" },
        --                 { id = "rs666mini", name = "Mini Beast 6", amount = 1, probability = 15, type = "car" }
        --             }
        --         },
        --         {
        --             id = "beast_crate",
        --             name = "Beast Mystery Crate",
        --             description = "Een premium crate met betere beloningen",
        --             price = 60,
        --             images = {
        --                 "https://i.postimg.cc/5tmSfn9Q/zilveremysterybox.webp"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "sou_23s63T", name = "Rocket X", amount = 1, probability = 15, type = "car" },
        --                 { id = "25c8suv", name = "Envora Flash", amount = 1, probability = 25, type = "car" },
        --                 { id = "q8prior6", name = "Zentrix 6X6", amount = 1, probability = 25, type = "car" },
        --                 { id = "scr765LT", name = "Bravado Striker", amount = 1, probability = 35, type = "car" }
        --             }
        --         },
        --         {
        --             id = "legendary_crate",
        --             name = "Legendary Mystery Crate",
        --             description = "Een premium crate met betere beloningen",
        --             price = 35,
        --             images = {
        --                 "https://i.postimg.cc/5tmSfn9Q/zilveremysterybox.webp"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "WEAPON_AWP_ASIIMOV", name = "AWP ASIIMOV L", amount = 1, probability = 35, type = "weapon" },
        --                 { id = "RTGM8", name = "MXK 8 Speed", amount = 1, probability = 25, type = "car" },
        --                 { id = "mrwheelchair", name = "Mexc Bodykit XXL", amount = 1, probability = 25, type = "car" },
        --                 { id = "sou_23s63T", name = "Rocket X", amount = 1, probability = 15, type = "car" }
        --             }
        --         },
        --         {
        --             id = "Colonel_crate",
        --             name = "Beast Mystery Crate",
        --             description = "Een premium crate met betere beloningen",
        --             price = 55,
        --             images = {
        --                 "https://i.postimg.cc/5tmSfn9Q/zilveremysterybox.webp"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "sou_23s63t", name = "Rocket X", amount = 1, probability = 15, type = "car" },
        --                 { id = "ammo_medium", name = "9mm Ammo", amount = 100, probability = 35, type = "ammo" },
        --                 { id = "WEAPON_AKPUV2", name = "WEAPON AKPUV2", amount = 1, probability = 25, type = "weapon" },
        --                 { id = "hycbuff", name = "Ignis", amount = 1, probability = 25, type = "car" }
        --             }
        --         },
        --         {
        --             id = "King_crate",
        --             name = "King Mystery Crate",
        --             description = "Een premium crate met betere beloningen",
        --             price = 60,
        --             images = {
        --                 "https://i.postimg.cc/5tmSfn9Q/zilveremysterybox.webp"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "torosven", name = "Aetheron", amount = 1, probability = 25, type = "car" },
        --                 { id = "cometven", name = "Veyronix", amount = 1, probability = 25, type = "car" },
        --                 { id = "hycwagen", name = "Spectra", amount = 1, probability = 25, type = "car" },
        --                 { id = "strcoupe", name = "MirageX", amount = 1, probability = 25, type = "car" }
        --             }
        --         },
        --         {
        --             id = "Outplayed_crate",
        --             name = "Outplayed Mystery Crate",
        --             description = "Een premium crate met betere beloningen",
        --             price = 35,
        --             images = {
        --                 "https://i.postimg.cc/zGc10yj8/16380177-270c-4e99-8406-babcccf960f6.png"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "WEAPON_HFSMGV2", name = "WEAPON HFSMGV2 L", amount = 1, probability = 25, type = "weapon" },
        --                 { id = "WEAPON_SCEVO", name = "WEAPON SCEVO L", amount = 1, probability = 25, type = "weapon" },
        --                 { id = "WEAPON_GRU2", name = "WEAPON GRU2", amount = 1, probability = 25, type = "weapon" },
        --                 { id = "WEAPON_AKPUV2", name = "WEAPON AKPUV2", amount = 1, probability = 25, type = "weapon" }
        --             }
        --         },
        --         {
        --             id = "Offer_crate",
        --             name = "Offer Mystery Crate",
        --             description = "Een premium crate met betere beloningen",
        --             price = 40,
        --             images = {
        --                 "https://i.postimg.cc/ZqpDpnsD/54628722-3e03-42e4-a45e-4f7b9039b25c.png"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "WEAPON_GALILARV2", name = "WEAPON GALILARV2", amount = 1, probability = 25, type = "weapon" },
        --                 { id = "ammo_medium", name = "9mm Ammo", amount = 100, probability = 35, type = "ammo" },
        --                 { id = "WEAPON_FOOLV2", name = "WEAPON FOOLV2", amount = 1, probability = 25, type = "weapon" },
        --                 { id = "nov", name = "Vintari H1X", amount = 1, probability = 15, type = "car" }
        --             }
        --         },
        --         {
        --             id = "20K_crate",
        --             name = "20K Mystery Crate",
        --             description = "Een premium crate met betere beloningen",
        --             price = 50,
        --             images = {
        --                 "https://i.postimg.cc/5tmSfn9Q/zilveremysterybox.webp"
        --             },
        --             type = "crate",
        --             rewards = {
        --                 { id = "WEAPON_M4_TACTICAL_RED", name = "WEAPON M4 TACTICAL RED R", amount = 1, probability = 25, type = "weapon" },
        --                 { id = "ammo_medium", name = "9mm Ammo", amount = 100, probability = 35, type = "ammo" },
        --                 { id = "cyphx", name = "Ravager", amount = 1, probability = 25, type = "car" },
        --                 { id = "scrgtrv2", name = "XS Dubbel Speed", amount = 1, probability = 15, type = "car" }
        --             }
        --         },
        --     }
        -- },
        killmessages = {
            title = 'Kill Messages',
            description = 'Zorg ervoor dat iemand een mededeling in zijn scherm krijgt wanneer je iemand vermoord!',
            icon = "https://i.postimg.cc/qBN6D622/388cf485-08f8-4035-8617-0e005580fec1-removalai-preview.png",
            products = {     
                {
                    id = 'vip',
                    name = 'Kill messages - VIP',
                    description = 'Iemand vermoord in de stad? Jouw custom tekst komt in iedereen zijn beeld die je vermoord. /killmessage om het te activeren!',
                    amount = 1,
                    price = 200,
                    images = {
                        'https://i.postimg.cc/tJZgq45C/vip.png'
                    },
                    type = "killmessage"
                },
                {
                     id = 'patron',
                    name = 'Kill messages - Patron',
                    description = 'Iemand vermoord in de stad? Jouw custom tekst komt in iedereen zijn beeld die je vermoord. /killmessage om het te activeren!',
                    amount = 1,
                    price = 250,
                    images = {
                        'https://i.postimg.cc/L6PsGh5c/patron.png'
                    },
                    type = "killmessage"
                },
                {
                    id = 'master',
                    name = 'Kill messages - Master',
                    description = 'Iemand vermoord in de stad? Jouw custom tekst komt in iedereen zijn beeld die je vermoord. /killmessage om het te activeren!',
                    amount = 1,
                    price = 300,
                    images = {
                        'https://i.postimg.cc/qRmtBYHK/master.png'
                    },
                    type = "killmessage"
                },
                {
                    id = 'thelegend',
                    name = 'Kill messages - The Legend',
                    description = 'Iemand vermoord in de stad? Jouw custom tekst komt in iedereen zijn beeld die je vermoord. /killmessage om het te activeren!',
                    amount = 1,
                    price = 350,
                    images = {
                        'https://i.postimg.cc/tT7qk48t/thelegend.png'
                    },
                    type = "killmessage"
                },
            }
        },
        vip = {
            title = "VIP",
            description = "Word VIP en ontvang een speciale melding wanneer je joint! Iedereen ziet dat jij bent gejoined met een exclusieve VIP-announce waarin je naam verschijnt. Laat zien dat jij een echte VIP bent!",
            products = {
                {
                    id = 'vip',
                    name = "VIP",
                    description = "Je krijgt een melding in-game voor iedereen te zien waar je naam bij staat!",
                    amount = 1,
                    price = 150,
                    images = {
                        'https://i.postimg.cc/ZnG2W3hG/1111111-removebg-preview.png'
                    },
                    type = "vip"
                },
                {
                    id = 'patron',
                    name = "Patron",
                    description = "Je krijgt een melding in-game voor iedereen te zien waar je naam bij staat!",
                    amount = 1,
                    price = 200,
                    images = {      
                        'https://i.postimg.cc/J4dvDfRZ/51467f13-7334-49e2-abad-454e16f37084-removebg-preview.png'
                    },
                    type = "vip"
                },
                {
                    id = 'master',
                    name = "Master",
                    description = "Je krijgt een melding in-game voor iedereen te zien waar je naam bij staat!",
                    amount = 1,
                    price = 300,
                    images = {
                        'https://i.postimg.cc/mgHXchXb/b045e0d0-cffb-4606-a460-e7d92196660d-removebg-preview.png'
                    },
                    type = "vip"
                },
                {
                    id = 'thelegend',
                    name = "The Legend",
                    description = "Je krijgt een melding in-game voor iedereen te zien waar je naam bij staat!",
                    amount = 1,
                    price = 400,
                    images = {
                        'https://i.postimg.cc/bJcjGK9N/d8d078d3-d7a2-4293-8f5c-f401b7d2cc06-removebg-preview.png'
                    },
                    type = "vip"
                }
            }
        },
        taken = {
            title = "Taken wegkopen",
            description = 'Hiermee koop je alle taken weg, je taakstraf wordt meteen verwijdert bij het aanschaffen!',
            icon = "https://i.postimg.cc/bNK04pWJ/image-removebg-preview.png",
            products = { 
                {
                    id = 'taken_wegkopen',
                    name = "Taken wegkopen",
                    description = 'Hiermee koop je alle taken weg, je taakstraf wordt meteen verwijdert bij het aanschaffen!',
                    amount = 1,
                    price = 200,
                    images = {
                        "https://dunb17ur4ymx4.cloudfront.net/packages/images/44a3be5bdd6443892c074daba7243f7d41079793.webp",

                    },
                    type = "takenwegkopen"
                }
            }
        },
autos = {
    title = "Speciale Voertuigen",
    description = "Ontdek een exclusieve collectie auto's in onze shop, zorgvuldig geselecteerd voor de ultieme rijbeleving. Van razendsnelle supercars tot robuuste SUVs – luxe en prestaties waren nog nooit zo bereikbaar!",
    icon = "https://png.pngtree.com/png-vector/20221022/ourmid/pngtree-porsche-911-carrera-s-ilustrasi-vector-kartun-png-image_6382619.png",
    products = {
        {
            id = "club8r",
            name = "Vindicator",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 900,
            images = {
                "https://i.postimg.cc/Tw6mvY6C/clubfoto.png",
                "https://i.postimg.cc/dtxyt9FR/clubfoto2.png",
                "https://i.postimg.cc/7hL5q5Wk/clubfoto3.png",
                "https://i.postimg.cc/3wCNpXsq/clubfoto4.png"
            },
            type = "car"
        },
        {
            id = "reblax",
            name = "Reblax",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1200,
            images = {
                "https://i.postimg.cc/Bb1G5s83/reblax1.png",
                "https://i.postimg.cc/XNTrRYkx/reblax2.png",
                "https://i.postimg.cc/fRvkSjnF/reblax3.png"
            },
            type = "car"
        },
        {
            id = "carrion",
            name = "Carrion",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1300,
            images = {
                "https://i.postimg.cc/RVBM16RN/carri1.png",
                "https://i.postimg.cc/YCXMwXwC/carr2.png",
                "https://i.postimg.cc/SKJqQWyv/carr3.png",
                "https://i.postimg.cc/zvSY27k4/carr4.png"
            },
            type = "car"
        },
        {
            id = "omsr7",
            name = "Torrenza",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1500,
            images = {
                "https://i.postimg.cc/jjJ9kvxp/tan.png",
                "https://i.postimg.cc/mkV6F5jk/tan2.png",
                "https://i.postimg.cc/rFFHLqyf/tan3.png",
                "https://i.postimg.cc/Vk2ZMMq9/tan4.png"
            },
            type = "car"
        },
        {
            id = "sent5wide",
            name = "Overdrive",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1100,
            images = {
                "https://i.postimg.cc/KjsDbSQH/wide1.png",
                "https://i.postimg.cc/K8Tr6WTk/wide2.png",
                "https://i.postimg.cc/KzGPgvH1/wide3.png",
                "https://i.postimg.cc/fykYBqZY/wide4.png"
            },
            type = "car"
        },
        {
            id = "torosven",
            name = "Crescenta",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1000,
            images = {
                "https://i.postimg.cc/Hkt4WySH/stop1.png",
                "https://i.postimg.cc/NGr69VNJ/stop2.png"
            },
            type = "car"
        },
        {
            id = "flashhrs",
            name = "Dominex",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 2000,
            images = {
                "https://i.postimg.cc/dV0DdZs3/mega1.png",
                "https://i.postimg.cc/rm5pcSJ9/mega2.png",
                "https://i.postimg.cc/dQm0xjD2/mega3.png",
                "https://i.postimg.cc/HkjsjGz4/mega4.png"
            },
            type = "car"
        },
        {
            id = "flashhrshyc",
            name = "Crescenta",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1700,
            images = {
                "https://i.postimg.cc/289rscYq/tril1.png",
                "https://i.postimg.cc/DwWnnrfc/tril2.png",
                "https://i.postimg.cc/LsLSZm14/tril3.png",
                "https://i.postimg.cc/j5TbHBHp/tril4.png"
            },
            type = "car"
        },
    }
},
        wapens = {
            title = "Wapens",
            description = "Geen zin in eindeloos grinden? Ontdek onze webshop voor handige wapens en bewapen jezelf met stijl.",
            icon = "https://i.postimg.cc/Dy8HMcDk/WEAPON-GRU2.webp",
            products = {
                {
                    id = "WEAPON_HFSMGV2",
                    name = "WEAPON HFSMGV2 L",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/nzxt8Qm1/WEAPON-HFSMGV2-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_HFSMGV2", amount = 1, type = "weapon", name = "HFSMGV2"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_SCEVO",
                    name = "WEAPON SCEVO L",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/P58GPMz2/WEAPON-UMP-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_SCEVO", amount = 1, type = "weapon", name = "SCEVO L"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_AWP_ASIIMOV",
                    name = "AWP ASIIMOV L",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 200,
                    images = {
                        "https://i.postimg.cc/qRwS9D4w/AWP-ASIIMOV-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_AWP_ASIIMOV", amount = 1, type = "weapon", name = "ASIIMOV L"},
                        {id = "ammo-sniper", amount = 50, type = "item", name = "Sniper Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_GRU2",
                    name = "WEAPON GRU2",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/Dy8HMcDk/WEAPON-GRU2.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_GRU2", amount = 1, type = "weapon", name = "GRU2"},
                        {id = "ammo-rifle", amount = 20, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_AKPUV2",
                    name = "WEAPON AKPUV2",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/VktTYkzQ/WEAPON-AKPUV2-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_AKPUV2", amount = 1, type = "weapon", name = "AKPUV2"},
                        {id = "ammo-rifle", amount = 20, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_FOOLV2",
                    name = "WEAPON FOOLV2",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 150,
                    images = {
                        "https://i.postimg.cc/gjwxgHtF/WEAPON-FOOLV2.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_FOOLV2", amount = 1, type = "weapon", name = "FOOLV2"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_M4_TACTICAL_RED",
                    name = "WEAPON M4 TACTICAL RED R",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 150,
                    images = {
                        "https://i.postimg.cc/sx16bVnC/WEAPON-M4-TACTICAL-RED-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_M4_TACTICAL_RED", amount = 1, type = "weapon", name = "M4 TACTICAL RED R"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_M4A5V2",
                    name = "WEAPON M4A5V2",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/Dy9jY31K/WEAPON-M4A5V2-L-1.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_M4A5V2", amount = 1, type = "weapon", name = "M4A5V2"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_BULLPUP_SMG",
                    name = "WEAPON BULLPUP SMG",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/VNRK6STx/WEAPON-BULLPUP-SMG-L-1.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_BULLPUP_SMG", amount = 1, type = "weapon", name = "BULLPUP SMG"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_FAMAS_YELLOW",
                    name = "WEAPON FAMAS YELLOW L",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/63bzrk9s/WEAPON-FAMAS-YELLOW-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_FAMAS_YELLOW", amount = 1, type = "weapon", name = "FAMAS YELLOW L"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_GYSV2",
                    name = "WEAPON GYSV2 L",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/7Y2Xztdf/WEAPON-GYSV2-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_GYSV2", amount = 1, type = "weapon", name = "GYSV2 L"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_GALILARV2",
                    name = "WEAPON GALILARV2",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/FHbZWd90/WEAPON-GALILARV2-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_GALILARV2", amount = 1, type = "weapon", name = "GALILARV2"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_L85_CHRISTMAS",
                    name = "WEAPON CHRISTMAS",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/dt0r13ks/WEAPON-L85-CHRISTMAS-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_L85_CHRISTMAS", amount = 1, type = "weapon", name = "L85 CHRISTMAS"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_NVRIFLE_PURPLE",
                    name = "WEAPON NVRIFLE PURPLE",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 150,
                    images = {
                        "https://i.postimg.cc/vmym42qS/WEAPON-NVRIFLE-PURPLE-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_NVRIFLE_PURPLE", amount = 1, type = "weapon", name = "NVRIFLE PURPLE"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_M4A5V2",
                    name = "WEAPON_M4A5V2 L",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/4dD4T898/WEAPON-M4A5V2-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_M4A5V2", amount = 1, type = "weapon", name = "M4A5V2"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_SCEVO",
                    name = "SCEVO",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/gJPBF806/WEAPON-SCEVO-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_SCEVO", amount = 1, type = "weapon", name = "SCEVO"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_PISTOL50",
                    name = "DESERT_EAGLE_L",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 150,
                    images = {
                        "https://i.postimg.cc/KzFQsb95/DESERT-EAGLE-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_PISTOL50", amount = 1, type = "weapon", name = "EAGLE"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_BERYL_762",
                    name = "BERYL_762",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/Kcprtty4/WEAPON-BERYL-762-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_BERYL_762", amount = 1, type = "weapon", name = "BERYL_762"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_AK47_NIGHTWISH",
                    name = "AK47_NIGHTWISH",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 150,
                    images = {
                        "https://i.postimg.cc/hGCbMm7r/WEAPON-AK47-NIGHTWISH-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_AK47_NIGHTWISH", amount = 1, type = "weapon", name = "NIGHTWISH"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_BAS_P_RED",
                    name = "BAS_P_RED",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 150,
                    images = {
                        "https://i.postimg.cc/QCT2KYQK/WEAPON-BAS-P-RED-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_BAS_P_RED", amount = 1, type = "weapon", name = "BAS_P_RED"},
                        {id = "ammo-9", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_BULLPUP_SMG",
                    name = "BULLPUP_SMG",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/y8VG78bJ/WEAPON-BULLPUP-SMG-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_BULLPUP_SMG", amount = 1, type = "weapon", name = "BULLPUP_SMG"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_FAMAS",
                    name = "FAMAS",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/Y0H38XcG/WEAPON-FAMAS-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_FAMAS", amount = 1, type = "weapon", name = "FAMAS"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_HK516V2",
                    name = "HK516V2",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/x1wbKXVC/WEAPON-HK516V2-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_HK516V2", amount = 1, type = "weapon", name = "HK516V2"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_HOWAT20",
                    name = "HOWAT20",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/FsfRDhZG/WEAPON-HOWAT20-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_HOWAT20", amount = 1, type = "weapon", name = "HOWAT20"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_LMTM4R",
                    name = "LMTM4R",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/ydbKZS2w/WEAPON-LMTM4R-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_LMTM4R", amount = 1, type = "weapon", name = "LMTM4R"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_M4_A_W",
                    name = "M4_A_W",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/VLy6G3HV/WEAPON-M4-A-W-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_M4_A_W", amount = 1, type = "weapon", name = "M4_A_W"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_M4_HALLOWEEN",
                    name = "M4_HALLOWEEN",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 150,
                    images = {
                        "https://i.postimg.cc/8PVpBL7S/WEAPON-M4-HALLOWEEN-L-1.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_M4_HALLOWEEN", amount = 1, type = "weapon", name = "M4_HALLOWEEN"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_M47V2",
                    name = "M47V2",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 150,
                    images = {
                        "https://i.postimg.cc/rsNv90HD/WEAPON-M47V2-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_M47V2", amount = 1, type = "weapon", name = "M47V2"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_M82V2",
                    name = "M82V2",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 150,
                    images = {
                        "https://i.postimg.cc/W3RCLwLV/WEAPON-M82V2-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_M82V2", amount = 1, type = "weapon", name = "M82V2"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_MP5",
                    name = "MP5",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/nLKYr491/WEAPON-MP5-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_MP5", amount = 1, type = "weapon", name = "MP5"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_NVRIFLE",
                    name = "NVRIFLE",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/vmvfbGC4/WEAPON-NVRIFLE-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_NVRIFLE", amount = 1, type = "weapon", name = "NVRIFLE"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_P20_ASIIMOV",
                    name = "P20_ASIIMOV",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 150,
                    images = {
                        "https://i.postimg.cc/dV2TjqQs/WEAPON-P20-ASIIMOV-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_P20_ASIIMOV", amount = 1, type = "weapon", name = "P20_ASIIMOV"},
                        {id = "ammo-45", amount = 50, type = "item", name = "SMG Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_SCAR-L",
                    name = "SCAR-L",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 150,
                    images = {
                        "https://i.postimg.cc/Xv2K9VLT/WEAPON-SCAR-L-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_SCAR-L", amount = 1, type = "weapon", name = "SCAR-L"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_VECTOR",
                    name = "VECTOR",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/KcTL8rX8/WEAPON-VECTOR-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_SCAR-L", amount = 1, type = "weapon", name = "VECTOR"},
                        {id = "ammo-45", amount = 50, type = "item", name = "SMG Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_XM7_6_8",
                    name = "XM7_6_8",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 150,
                    images = {
                        "https://i.postimg.cc/jjW2kttt/WEAPON-XM7-6-8-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_XM7_6_8", amount = 1, type = "weapon", name = "XM7_6_8"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_M270D",
                    name = "M270D",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 300,
                    images = {
                        "https://i.postimg.cc/6qWHtHHs/WEAPON-M270D-L.webp"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_M270D", amount = 1, type = "weapon", name = "M270D"},
                        {id = "ammo-45", amount = 50, type = "item", name = "SMG Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                },
                {
                    id = "WEAPON_FOOLV2",
                    name = "WEAPON FOOLV2",
                    description = "Unieke Wapen",
                    amount = 1,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/mD2s4QLG/00101011.png"
                    },
                    type = "pack",
                    items = {
                        {id = "WEAPON_FOOLV2", amount = 1, type = "weapon", name = "FOOLV2"},
                        {id = "ammo-rifle", amount = 50, type = "item", name = "Rifle Ammo"},
                        {id = "ammo-rifle", amount = 0, type = "item", name = "Deze wapen mag niet afgepakt worden"},
                    }
                }
            }
        },
        geld = {
            title = "Geld",
            description = "Koop in-game geld met je coins.",
            icon = "https://gallery.yopriceville.com/downloadfullsize/send/6534",
            products = {
                {
                    id = "money",
                    name = "Money Bag 50 Mil",
                    description = "Tas met geld",
                    amount = 50000000,
                    price = 600,
                    images = {
                        "https://i.postimg.cc/C1sg76Hw/d7bbe592-2951-4239-82ac-6cfcc582652d.png"
                    },
                    type = "item"
                },
                {
                    id = "money",
                    name = "Money Bag 30 Mil",
                    description = "Tas met geld",
                    amount = 30000000,
                    price = 300,
                    images = {
                        "https://i.postimg.cc/Cx5fHrdj/46d4e5bf-6d19-487b-88b9-2b3fac0e2d43.png"
                    },
                    type = "item"
                },
                {
                    id = "money",
                    name = "Contant geld",
                    description = "Tas met geld",
                    amount = 20000000,
                    price = 200,
                    images = {
                        "https://i.postimg.cc/qvmSJ64y/4b32eb52-144c-4640-9108-0706ef1beb78.png"
                    },
                    type = "item"
                },
                {
                    id = "money",
                    name = "Contant geld",
                    description = "Tas met geld",
                    amount = 5000000,
                    price = 800,
                    images = {
                        "https://i.postimg.cc/02hKLcJ7/b4884447-c7a5-4ecb-a600-dcb694b4620f.png"
                    },
                    type = "item"
                },
                {
                    id = "money",
                    name = "Contant geld",
                    description = "Tas met geld",
                    amount = 2500000,
                    price = 500,
                    images = {
                        "https://i.postimg.cc/4NjwBvfb/99674a9a-d703-4e2b-9918-22046afa7891.png"
                    },
                    type = "item"
                },
                {
                    id = "money",
                    name = "Contant geld",
                    description = "Tas met geld",
                    amount = 1000000,
                    price = 300,
                    images = {
                        "https://i.postimg.cc/gJwDP4KR/cac4d9a9-1b82-4186-9711-5f59875d941d.png"
                    },
                    type = "item"
                },

                {
                    id = "money",
                    name = "Contant geld",
                    description = "Tas met geld",
                    amount = 500000,
                    price = 200,
                    images = {
                        "https://i.postimg.cc/V6BN5P4P/63141e02-df21-47e2-8f82-85711ee1dfed.png"
                    },
                    type = "item"
                },

                {
                    id = "money",
                    name = "Contant geld",
                    description = "Tas met geld",
                    amount = 200000,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/FsfQBQSw/a0fa1c26-ba50-45ec-b283-d94315b13026.png"
                    },
                    type = "item"
                },
            }
        },
        ammo = {
            title = "Ammo",
            description = "Ammo packs.",
            icon = "https://i.postimg.cc/mkrvzjnV/28618b67-70cd-49c2-8676-ace74f4486a7.png",
            products = {
                {
                    id = "ammo-9",
                    name = "9mm Ammo",
                    description = "Genoeg ammo om stad ophol te zetten",
                    amount = 1000,
                    price = 50,
                    images = {
                        "https://i.postimg.cc/7Zf9ddvJ/ammo-9.png"
                    },
                    type = "item",
                    {id = "ammo-rifle", amount = 1000, type = "item", name = "1000x Rifle Ammo"},
                },
                {
                    id = "ammo-45",
                    name = "45 APC Ammo",
                    description = "Genoeg ammo om stad ophol te zetten",
                    amount = 1000,
                    price = 50,
                    images = {
                        "https://i.postimg.cc/X7hdGvhV/ammo-45.png"
                    },
                    type = "item",
                    {id = "ammo-45", amount = 1000, type = "item", name = "1000x APC Ammo"},
                },
                {
                    id = "ammo-shotgun",
                    name = "Shotgun Ammo",
                    description = "Genoeg ammo om stad ophol te zetten",
                    amount = 1000,
                    price = 50,
                    images = {
                        "https://i.postimg.cc/9FvwXnRM/ammo-shotgun.png"
                    },
                    type = "item",
                    {id = "ammo-shotgun", amount = 1000, type = "item", name = "1000x Shotgun Ammo"},
                },
                {
                    id = "ammo-rifle",
                    name = "Rifle Ammo",
                    description = "Genoeg ammo om stad ophol te zetten",
                    amount = 1000,
                    price = 50,
                    images = {
                        "https://i.postimg.cc/sX61k6Cz/ammo-rifle.png"
                    },
                    type = "item",
                    {id = "ammo-rifle", amount = 1000, type = "item", name = "1000x Rifle Ammo"},
                },
                {
                    id = "mixed-ammo",
                    name = "Mixed Ammo",
                    description = "Genoeg ammo om stad ophol te zetten",
                    amount = 1,
                    price = 150,
                    images = {
                        "https://i.postimg.cc/7Zf9ddvJ/ammo-9.png",
                        "https://i.postimg.cc/X7hdGvhV/ammo-45.png",
                        "https://i.postimg.cc/9FvwXnRM/ammo-shotgun.png",
                        "https://i.postimg.cc/sX61k6Cz/ammo-rifle.png"
                    },
                    type = "pack",
                    items = {
                        {id = "ammo-9", amount = 1000, type = "item", name = "1000x 9mm Ammo"},
                        {id = "ammo-45", amount = 1000, type = "item", name = "1000x 45 APC Ammo"},
                        {id = "ammo-shotgun", amount = 1000, type = "item", name = "1000x Shotgun Ammo"},
                        {id = "ammo-rifle", amount = 1000, type = "item", name = "1000x Rifle Ammo"},
                    }
                }
            }
        },
LimiedEdition = {
    title = "Limited Edition",
    description = "Hieronder vind je alle limited edition voertuigen die je kan kopen.",
    icon = "https://i.postimg.cc/mrFtvN2s/Blue-star-icon-stylized.png",
    products = {
        {
            id = "kerosenesr6",
            name = "895 KM/U Sport Auto NIEUW",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 2200,
            images = {
                "https://i.postimg.cc/vmKZxrYq/f45ad976cef5fcd4a8b05611e73a0dc9acce29a2.png",
                "https://i.postimg.cc/0QJ2Yzrr/6024745c5db581ed58e8923a3a28cf9a829acb5d.png",
                "https://i.postimg.cc/NF6snZ1T/5e209555762b4abd22eb510ab086b60a2f1a858f.png",
                "https://i.postimg.cc/8kMzsfqv/0322409e35d5150b9b68c024d42626abbf1b299a.png",
                "https://i.postimg.cc/QxDx7x3k/ce5506834b95a12aaaa5b511a3a3a257eaae992f.png",
            },
            type = "car"                  
        },
        {
            id = "DRcF150x",
            name = "800 KM/U Crimineel Auto",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1800,
            images = {
                "https://i.postimg.cc/FRcyF4zM/image.png",
                "https://i.postimg.cc/kg4W68Bn/image33.png",
                "https://i.postimg.cc/0QpSR0Hp/imag45.png",
                "https://i.postimg.cc/xTsz2Cg5/image482.png",
            },
            type = "car"                  
        },
        {
            id = "scr765LT",
            name = "Bravado Striker",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1700,
            images = {
                "https://i.postimg.cc/d1m2Jn8T/Mallorca-bravado-striker.png"
            },
            type = "car"                  
        },
        {
            id = "rolls6x6",
            name = "[SUPER BEAST] 6X6",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1600,
            images = {
                "https://i.postimg.cc/44QPG45r/rolls6x6-Mallorca.png"
            },
            type = "car"             
        },
        {
            id = "sou_23s63T",
            name = "Rocket X",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 2400,
            images = {
                "https://i.postimg.cc/520nnc8L/rocketx-Mallorca.png"
            },
            type = "car"                
        },
        {
            id = "q8prior6",
            name = "Zentrix 6X6",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 2000,
            images = {
                "https://i.postimg.cc/0jsVfbCr/q8prior6-Mallorca.png"
            },
            type = "car"                  
        },
        {
            id = "scrgtrv2",
            name = "XS Dubbel Speed",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1500,
            images = {
                "https://i.postimg.cc/m2S5mNqJ/XS-Dubbel-Speed-Mallorca.png"
            },
            type = "car"                  
        },
        {
            id = "25c8suv",
            name = "Envora Flash",
            description = "Deze auto is kogelvrij, kan vliegen en is super snel, waardoor hij veilig is en binnen een paar seconden overal kan zijn.",
            amount = 1,
            price = 3000,
            images = {
                "https://i.postimg.cc/fRB1RjvQ/envora-flash-Mallorca.png"
            },
            type = "car"                  
        },
        {
            id = "mrwheelchair",
            name = "Mexc Bodykit XXL",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1400,
            images = {
                "https://i.postimg.cc/3rGMFG3y/mrwheelchair-Mallorca.png"
            },
            type = "car"                  
        },
        {
            id = "scrq7",
            name = "Titanis Xtreme (NIEUW) SUPER SNEL",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1900,
            images = {
                "https://i.postimg.cc/hGGWL3G4/titan-extreme-Mallorca.png"
            },
            type = "car"                  
        },
        {
            id = "nov",
            name = "Vintari H1X",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1500,
            images = {
                "https://i.postimg.cc/859SPBD3/Vintari-hix-Mallorca.png"
            },
            type = "car"                  
        },
        {
            id = "rsq3mnsry",
            name = "S3 UNDERCOVER",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1300,
            images = {
                "https://i.postimg.cc/0ys9wfSX/07cf1a64-4277-4368-b180-3daf1d5f9ead.png"
            },
            type = "car"                  
        },
        {
            id = "RTGM8",
            name = "MXK 8 Speed",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1700,
            images = {
                "https://i.postimg.cc/prh60wNV/MXK-8-Speed-Mallorca.png"
            },
            type = "car"                  
        },
        {
            id = "DMx5m",
            name = "MX8 X5",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1200,
            images = {
                "https://i.postimg.cc/zf763wwj/MX8-X5-Mallorca.png"
            },
            type = "car"                  
        },
        {
            id = "mk8r",
            name = "MX8 R +",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1500,
            images = {
                "https://i.postimg.cc/WbqBSkjq/lll.png"
            },
            type = "car"                  
        },
        {
            id = "rs666mini",
            name = "MXK 8 Speed",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1100,
            images = {
                "https://i.postimg.cc/B6QWC7ZR/MXK-8-Speed-MINI-Mallorca.png"
            },
            type = "car"                  
        },
        {
            id = "rs666mini",
            name = "Mini Beast 6",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1100,
            images = {
                "https://i.postimg.cc/wTtpPrXP/Mini-Beast-6-Mallorca.png"
            },
            type = "car"                  
        },
        {
            id = "gstramv1",
            name = "Beast Trucker",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1100,
            images = {
                "https://i.postimg.cc/FKbmpJyF/beasttrucker-Mallorca.png"
            },
            type = "car"                  
        },
        {
            id = "rmodlego2",
            name = "Astrion",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1200,
            images = {
                "https://i.postimg.cc/Dymvh0hw/Astrion-Mallorca.png"
            },
            type = "car"                  
        },
        {
            id = "5ifty6x6T",
            name = "Performa 6X6 [BEAST]",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1100,
            images = {
                "https://i.postimg.cc/d1BssTDJ/Performa-6X6-BEAST-Mallorca.png"
            },
            type = "car"                  
        },
        {
            id = "DBg634x4byv",
            name = "10 Persoons Super",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1500,
            images = {
                "https://i.postimg.cc/RVb0Jfdv/10-Persoons-Super-Mallorca.png"
            },
            type = "car"                  
        },
        {
            id = "huracanpriorbeast",
            name = "Furiano (Speciale Versie)",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1300,
            images = {
                "https://i.postimg.cc/90LQpqj6/4444.png"
            },
            type = "car"                  
        },
        {
            id = "jdap6x6g",
            name = "Mavora",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1200,
            images = {
                "https://i.postimg.cc/QdwVw5Kv/Mavora-Mallorca.png"
            },
            type = "car"                  
        },
        {
            id = "centuria",
            name = "Zentara XXL",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1100,
            images = {
                "https://i.postimg.cc/sxmvNN5M/Zentara-Super-Speed-Mallorca.png"
            },
            type = "car"                  
        },
        {
            id = "ftb_ouxiv8",
            name = "[SUPER SNEL] ELEKTRISCHE MOTOR/FIETS - Nog niet beschikbaar",
            description = "Al onze voertuigen zijn speciaal geoptimaliseerd door onze developers en rijden enorm fijn en snel!",
            amount = 1,
            price = 1200,
            images = {
                "https://i.postimg.cc/L8bZSwwk/324234234234-removebg-preview.png"
            },
            type = "car"                  
        },
    }
},
        wapenloodsen = {
            title = "Gangs",
            description = "Opzoek naar een gang binnen Mallorca? Profiteer van de mooie prijzen en begin je eigen officiele gang!",
            icon = "https://i.postimg.cc/g0Q7zQ6t/3784182.png",
            products = {
                {
                    id = "1",
                    name = "Officiële Gang [MEGA]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 2450,
                    images = {
                        "https://i.postimg.cc/FRPm2bL7/Schermafbeelding-2025-10-23-182931.png",
                        "https://i.postimg.cc/YCckKChw/Schermafbeelding-2025-10-23-183304.png",
                        "https://i.postimg.cc/25rDy9dk/Schermafbeelding-2025-10-23-183236.png",
                        "https://i.postimg.cc/WpCcg16L/Schermafbeelding-2025-10-23-183357.png",
                        "https://i.postimg.cc/cHCPtpvs/Schermafbeelding-2025-10-23-183216.png",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang [MANSION]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 1500,
                    images = {
                        "https://i.postimg.cc/Wzqmw3Xk/Schermafbeelding-2025-10-12-204700.png",
                        "https://i.postimg.cc/pLZf9jdz/Schermafbeelding-2025-10-12-204912.png",
                        "https://i.postimg.cc/NMymPPkb/Schermafbeelding-2025-10-12-204825.png",
                        "https://i.postimg.cc/8zDdP4Nx/Schermafbeelding-2025-10-12-204856.png",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang [XXL MANSION]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 650,
                    images = {
                        "https://i.postimg.cc/pd5dNN3L/Schermafbeelding-2025-10-12-205253.png",
                        "https://i.postimg.cc/BVEXbHBx4/Schermafbeelding-2025-10-12-205406.png",
                        "https://i.postimg.cc/DZVwnjK9/Schermafbeelding-2025-10-12-205337.png",
                        "https://i.postimg.cc/kGqMt2GK/Schermafbeelding-2025-10-12-205357.png",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang 21 [CUSTOM NAAM]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 700,
                    images = {
                        "https://i.postimg.cc/L5X77S0D/Schermafbeelding-2025-10-12-205516.png",
                        "https://i.postimg.cc/G3Xnj7S6/Schermafbeelding-2025-10-12-205551.png",
                        "https://i.postimg.cc/q7VP79z0/Schermafbeelding-2025-10-12-205528.png",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang 25 [CUSTOM NAAM]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 550,
                    images = {
                        "https://i.postimg.cc/Y2GWLVLL/98f7681e412f775556348c305a4136114ae3afab.webp",
                        "https://i.postimg.cc/tJYSk5sj/Schermafbeelding-2025-10-12-205705.png",
                        "https://i.postimg.cc/5yYgL2Rr/Schermafbeelding-2025-10-12-205726.png",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang 14 [CUSTOM NAAM]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 600,
                    images = {
                        "https://i.postimg.cc/0Q33LFRr/Schermafbeelding-2025-10-12-205851.png",
                        "https://i.postimg.cc/htBFDkJh/Schermafbeelding-2025-10-12-210034.png",
                        "https://i.postimg.cc/5N8GRsPd/Schermafbeelding-2025-10-12-205906.png",
                        "https://i.postimg.cc/0NXHwFNM/Schermafbeelding-2025-10-12-205928.png",
                        "https://i.postimg.cc/FFLnYPXk/Schermafbeelding-2025-10-12-210001.png",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang 19 [CUSTOM NAAM]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 450,
                    images = {
                        "https://i.postimg.cc/fW9VR91J/fbdd919ecdbac3b0684613f26b60c41fb79b3413.webp",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang 24 [CUSTOM NAAM]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 750,
                    images = {
                        "https://i.postimg.cc/nrbcD3Nz/5a37627c19d38a93ced00495bf6fb4ad8e5e8820.webp",
                        "https://i.postimg.cc/nzQTQLgc/Schermafbeelding-2025-10-12-210205.png",
                        "https://i.postimg.cc/zGXjF76M/Schermafbeelding-2025-10-12-210223.png",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang [XXL]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 850,
                    images = {
                        "https://i.postimg.cc/ZqXJGfbX/a2e214d5b8c2189b5a08dc61a5686c7a46351cb6.webp",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang [LUXE HOTEL]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 1250,
                    images = {
                        "https://i.postimg.cc/JnJcz2Hk/Schermafbeelding-2025-10-12-210311.png",
                        "https://i.postimg.cc/J4K30J0Z/Schermafbeelding-2025-10-12-210352.png",
                        "https://i.postimg.cc/SsWChYHG/Schermafbeelding-2025-10-12-210453.png",
                        "https://i.postimg.cc/c4DY0SkK/Schermafbeelding-2025-10-12-210333.png",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang [BEACH MANSION]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 900,
                    images = {
                        "https://i.postimg.cc/1RBVrSS4/Schermafbeelding-2025-10-12-210519.png",
                        "https://i.postimg.cc/TwRYKypj/Schermafbeelding-2025-10-12-210628.png",
                        "https://i.postimg.cc/SsqjcTtS/Schermafbeelding-2025-10-12-210600.png",
                        "https://i.postimg.cc/X7hJs7zS/Schermafbeelding-2025-10-12-210613.png",
                        "https://i.postimg.cc/Zqzqhsmj/Schermafbeelding-2025-10-12-210538.png",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang 11 [CUSTOM NAAM]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 550,
                    images = {
                        "https://i.postimg.cc/pX9V5MXK/Schermafbeelding-2025-10-12-211019.png",
                        "https://i.postimg.cc/50NbxZRm/Schermafbeelding-2025-10-12-211118.png",
                        "https://i.postimg.cc/x8XQmLYz/Schermafbeelding-2025-10-12-211054.png",
                        "https://i.postimg.cc/ncQZcK3t/Schermafbeelding-2025-10-12-211032.png",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang 20 [CUSTOM NAAM]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 600,
                    images = {
                        "https://i.postimg.cc/D04V0FdW/Schermafbeelding-2025-10-12-211205.png",
                        "https://i.postimg.cc/66Fq0pSx/Schermafbeelding-2025-10-12-211258.png",
                        "https://i.postimg.cc/RZB0kb4w/Schermafbeelding-2025-10-12-211353.png",
                        "https://i.postimg.cc/G2H3FWxd/Schermafbeelding-2025-10-12-211222.png",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang [XL BEACH MANSION]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 400,
                    images = {
                        "https://i.postimg.cc/15xRFYgT/Schermafbeelding-2025-10-12-211727.png",
                        "https://i.postimg.cc/kgvex16vh/Schermafbeelding-2025-10-12-211738.png",
                        "https://i.postimg.cc/QMMjD2Pf/Schermafbeelding-2025-10-12-211850.png",
                        "https://i.postimg.cc/wvCzh7Bh/Schermafbeelding-2025-10-12-211755.png",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang [ZWEMBAD XXL]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 900,
                    images = {
                        "https://i.postimg.cc/XJgDfJz5/7243d9007df7432845fd9417092d92fb106891a8.webp",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang [LINKER SNELWEG]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 450,
                    images = {
                        "https://i.postimg.cc/fbnH1m4X/91992cc0b5df0cd4fbeaa9037f06cf890d408ddb.webp",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang 6 [CUSTOM NAAM]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 700,
                    images = {
                        "https://i.postimg.cc/XvkghPkX/c0476849d1404029937cf6c9fa46f1374df5e133.webp",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang 22 [CUSTOM NAAM]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 450,
                    images = {
                        "https://i.postimg.cc/pLNYdv0b/6f5a20f0ff8a5af430cf564ac0fc873dbefadc71.webp",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang 18 [CUSTOM NAAM]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 400,
                    images = {
                        "https://i.postimg.cc/wTdHMyZx/Schermafbeelding-2025-10-12-212017.png",
                        "https://i.postimg.cc/1z412pnW/Schermafbeelding-2025-10-12-212031.png",
                        "https://i.postimg.cc/cCRpwh2r/Schermafbeelding-2025-10-12-212048.png",
                        "https://i.postimg.cc/L86cgzTJ/Schermafbeelding-2025-10-12-212105.png",
                    },
                    type = "wapenloods"
                },
                {
                    id = "1",
                    name = "Officiële Gang 15 [CUSTOM NAAM]",
                    description = "👉 Bestel nu en start vandaag nog je gang!",
                    amount = 1,
                    price = 600,
                    images = {
                        "https://i.postimg.cc/85NPP2t7/image.png",
                    },
                    type = "wapenloods"
                },
            }
        },
        --[[drugsloodslevels = {
            title = "Drugsloods",
            description = "Updrade Jouw drugs loods.",
            icon = "https://cdn-icons-png.freepik.com/512/3774/3774880.png",
            products = {
                {
                    id = "1",
                    name = "Loods Upgrade naar Level 1",
                    description = "Loods naar keuze die jij beheerd upgraden naar level 1. Gekocht? Open een donatie-ticket",
                    amount = 0,
                    price = 150,
                    images = {
                        "https://gowarehouse.io/wp-content/uploads/2021/05/pharmaceutical-storage-2.1.png"
                    },
                    type = "drugsloodslevel"
                },
                {
                    id = "2",
                    name = "Loods Upgrade naar Level 2",
                    description = "Loods naar keuze die jij beheerd upgraden naar level 2. Gekocht? Open een donatie-ticket",
                    amount = 0,
                    price = 250,
                    images = {
                        "https://gowarehouse.io/wp-content/uploads/2021/05/pharmaceutical-storage-2.1.png"
                    },
                    type = "drugsloodslevel"
                },
                {
                    id = "3",
                    name = "Loods Upgrade naar Level 3",
                    description = "Loods naar keuze die jij beheerd upgraden naar level 3. Gekocht? Open een donatie-ticket",
                    amount = 0,
                    price = 400,
                    images = {
                        "https://gowarehouse.io/wp-content/uploads/2021/05/pharmaceutical-storage-2.1.png"
                    },
                    type = "drugsloodslevel"
                }
            }
        }, ]]--
        --[[tunership = {
            title = "Pops & Bangs",
            description = "Opzoek naar pops & bangs onder jouw auto? Dit is de juiste categorie.",
            icon = "https://i.postimg.cc/RFdRYy4W/tunerchip1.png",
            products = {
                {
                    id = "tunerchip1",
                    name = "Level 1 Pops & Bangs",
                    description = "Level 1 Pops & Bangs onder jouw auto! Uitzetten? Command /pops",
                    amount = 0,
                    price = 50,
                    images = {
                        "https://i.postimg.cc/RFdRYy4W/tunerchip1.png"
                    },
                    type = "item",
                    {id = "tunerchip1", amount = 1, type = "item", name = "1x Level 1Pops & Bangs"},
                },
                {
                    id = "tunerchip2",
                    name = "Level 2 Pops & Bangs",
                    description = "Level 2 Pops & Bangs onder jouw auto! Uitzetten? Command /pops",
                    amount = 0,
                    price = 100,
                    images = {
                        "https://i.postimg.cc/sxBhJNXC/tunerchip2.png"
                    },
                    type = "item",
                    {id = "tunerchip2", amount = 1, type = "item", name = "1x Level 2 Pops & Bangs"},
                },
                {
                    id = "tunerchip3",
                    name = "Level 3 Pops & Bangs",
                    description = "Level 3 Pops & Bangs onder jouw auto! Uitzetten? Command /pops",
                    amount = 0,
                    price = 150,
                    images = {
                        "https://i.postimg.cc/xj7Hdnxg/tunerchip3.png"
                    },
                    type = "item",
                    {id = "tunerchip3", amount = 1, type = "item", name = "1x Level 3 Pops & Bangs"},
                }
            }
        }, ]]--
        packs = {
        title = "Pakketten",
        description = "Hieronder vind je alle complete pakketten die je kan kopen met een donatiepakket.",
        icon = "https://i.postimg.cc/SskxXbmF/541415.png",
        products = {
            -- {
            --     id = "startt_pack",
            --     name = "HERFST PACKAGE",
            --     description = "35 STUKS BESCHIKBAAR OP = OP!!",
            --     price = 700,
            --     images = {
            --         "https://i.postimg.cc/xdFf1SdN/7b90e3c7-111e-4b92-bf70-3a90cf47fb65.png",
            --         "https://i.postimg.cc/d3jgD8Bc/9d9f62cb4ca2255304a727ab28ec40386be0466b.png",
            --         "https://i.postimg.cc/nV4ydJtw/9cc2995a381ac67045cad57b7bb9caf2b61eec22.png",
            --         "https://i.postimg.cc/L6vrp358/ba91b6095d8b8dff5b12263ff5c4996b7a9252e4.png",
            --         "https://i.postimg.cc/Tw8s9k7j/9dbc9dda6981e98ffa1ecf6c0bde45c4c41ed823.png",
            --         "https://i.postimg.cc/brpBXZjm/c7c528b068b832e1b37531e3acbcbbf5e962148d-1.png",
            --         "https://i.postimg.cc/SK9TJ6Sc/6958c3d9024188a10bc1d0efa80e39deb7f7e588-1.png",
            --         "https://i.postimg.cc/26F0xCBb/7beb45baee2012ae6014e2d676eb802d452e065f-1.png",
            --         "https://i.postimg.cc/J0pK9Kx8/c28181b3cc09be23728fc4bfb346f93291f618bb-1.png",
            --         "https://i.postimg.cc/zXfxnZDK/9d0014aff49a50893e7baf27a84f4c58d1947f0f-1.png",
            --     },
            --     type = "pack",
            --     items = {
            --         {id = "outlaw4d", amount = 1, type = "car", name = "Helix NIEUWE AUTO!!"},
            --         {id = "clubrhyc", amount = 1, type = "car", name = "Orixa Volt"},
            --         {id = "reblax", amount = 1, type = "car", name = "Rysa"},
            --         {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
            --         {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
            --         {id = "money", amount = 10000000, type = "item", name = "Contant geld"}
            --     },
            -- },
            -- {
            --     id = "starter_pack",
            --     name = "MIDNIGHT HORROR",
            --     description = "45 STUKS BESCHIKBAAR OP = OP!!",
            --     price = 650,
            --     images = {
            --         "https://i.postimg.cc/FRXGsrnw/dc18bdf5-eae4-4891-ae95-169ea06c4479.png",
            --         "https://i.postimg.cc/MZbFm7DQ/78684c2bda39cd851892877930a82d4fe5d99f9f.webp",
            --         "https://i.postimg.cc/yYXKqHvT/q8prior6.png",
            --         "https://i.postimg.cc/zXBcXYk9/sou-23s63-T.webp",
            --         "https://i.postimg.cc/YCmX0h2r/dubmono.png",
            --         "https://i.postimg.cc/g2rCDzYs/kcjub.png",
            --         "https://i.postimg.cc/s24hNg0b/5f9be8b346b4345ad1a5cb98cbcf25f507e249cd.webp",
            --     },
            --     type = "pack",
            --     items = {
            --         {id = "q8prior6", amount = 1, type = "car", name = "Zentrix 6X6"},
            --         {id = "rolls6x6", amount = 1, type = "car", name = "[SUPER BEAST] 6X6"},
            --         {id = "sou_23s63T", amount = 1, type = "car", name = "ROCKET X (SNELSTE AUTO)"},
            --         {id = "dubmono", amount = 1, type = "car", name = "Dominex EXTREME"},
            --         {id = "kcjub", amount = 1, type = "car", name = "Overdrive ABSOLUTE"},
            --         {id = "25c8suv", amount = 1, type = "car", name = "Envora Flash"},
            --         {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
            --         {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
            --         {id = "money", amount = 10000000, type = "item", name = "Contant geld"}
            --     },
            -- },

            -- ↓ Tweede pakket
            {
                id = "vip_pack",
                name = "Outplayed Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 950,
                images = {
                    "https://i.postimg.cc/c4ZK4Hq5/16380177-270c-4e99-8406-babcccf960f6.png",
                },
                type = "pack",
                items = {
                    {id = "mrwheelchair", amount = 1, type = "car", name = "Mexc Bodykit XXL"},
                    {id = "rsq8m", amount = 1, type = "car", name = "S3 UNDERCOVER"},
                    {id = "sou_23s63T", amount = 1, type = "car", name = "Rocket X"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },
            

            -- ↓ Derde pakket
            {
                id = "beast_pack",
                name = "Beast Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 900,
                images = {
                    "https://i.postimg.cc/Pf9Ysy59/b4bf86b5-2994-438c-9d7c-4c7dfb0e2670.png",
                },
                type = "pack",
                items = {
                    {id = "6X6", amount = 1, type = "car", name = "Mexc Bodykit XXL"},
                    {id = "ikx3devel22", amount = 1, type = "car", name = "Driver"},
                    {id = "pv_jeep", amount = 1, type = "car", name = "Mini Beast"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "collecter_pack",
                name = "Collecter Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 850,
                images = {
                    "https://i.postimg.cc/NjPGvGk0/2afb9945-4a28-4466-b035-d8c6e51ef391.png",
                },
                type = "pack",
                items = {
                    {id = "DBhycgle", amount = 1, type = "car", name = "XL Rocket"},
                    {id = "rmodlegoporsche", amount = 1, type = "car", name = "Exclusive Ton"},
                    {id = "mvisiongt", amount = 1, type = "car", name = "Vision Clean"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "absolute_pack",
                name = "Absolute Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 800,
                images = {
                    "https://i.postimg.cc/7hNZT3vV/95e75755-d885-40bb-af63-d9fb1d38d2a1.png",
                },
                type = "pack",
                items = {
                    {id = "rolls6x6", amount = 1, type = "car", name = "[SUPER BEAST] 6X6"},
                    {id = "pv_sianr", amount = 1, type = "car", name = "Mini Beast"},
                    {id = "bentaygast", amount = 1, type = "car", name = "Zentara XXL"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "suikerfeest_pack",
                name = "Suikerfeest Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 800,
                images = {
                    "https://i.postimg.cc/PxNp0vss/e4987d22-6b99-4c7a-9720-7e919f1b2226.png",
                },
                type = "pack",
                items = {
                    {id = "RTGM8", amount = 1, type = "car", name = "MXK 8 Speed"},
                    {id = "DBg634x4byv", amount = 1, type = "car", name = "10 Persoons Auto"},
                    {id = "tmax", amount = 1, type = "car", name = "Motor"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "legendary_pack",
                name = "Legendary Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 750,
                images = {
                    "https://i.postimg.cc/VsdVmzj6/eb495db8-b3df-4444-a080-9de3761ec3fe.png",
                },
                type = "pack",
                items = {
                    {id = "centuria", amount = 1, type = "car", name = "[SUPER BEAST] 6X6"},
                    {id = "jdap6x6g", amount = 1, type = "car", name = "Zentara XXL"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "silver_pack",
                name = "Silver 3 Year Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 800,
                images = {
                    "https://i.postimg.cc/RhR9svZL/ff72845f-3aaa-4ca8-a0d8-fa51e4c6298a.png",
                },
                type = "pack",
                items = {
                    {id = "DBgt63beast", amount = 1, type = "car", name = "Rocket X"},
                    {id = "audiq7", amount = 1, type = "car", name = "Xalor"},
                    {id = "mk8r", amount = 1, type = "car", name = "MX8 R +"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "colonel_pack",
                name = "Colonel Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 700,
                images = {
                    "https://i.postimg.cc/RFdb2hwD/bb664507-537e-4185-8069-40ae8752ee0d.png",
                },
                type = "pack",
                items = {
                    {id = "gstramv1", amount = 1, type = "car", name = "Xalor"},
                    {id = "RRazirrisa", amount = 1, type = "car", name = "Super Auto"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "silver1year_pack",
                name = "Silver 1 Year Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 680,
                images = {
                    "https://i.postimg.cc/3xPMZkZW/daeced85-e781-48ee-976a-775e2a3ac3ee.png",
                },
                type = "pack",
                items = {
                    {id = "abhawk", amount = 1, type = "car", name = "Extreme Auto"},
                    {id = "DMx5m", amount = 1, type = "car", name = "MX8 X5"},
                    {id = "bentaygast", amount = 1, type = "car", name = "Zentara XXL"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "admirar_pack",
                name = "Admirar Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 680,
                images = {
                    "https://i.postimg.cc/gjQ0CgyD/38fb4f84-0c2e-4c91-aada-5d402e9f907e.png",
                },
                type = "pack",
                items = {
                    {id = "rmodlego2", amount = 1, type = "car", name = "Astrion"},
                    {id = "rrazirrisa", amount = 1, type = "car", name = "Rrazirrisa"},
                    {id = "biome", amount = 1, type = "car", name = "Super Voertuig"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "bronze_pack",
                name = "Bronze Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 650,
                images = {
                    "https://i.postimg.cc/VLpZx30H/d39c40da-27ef-48f4-8d1f-a81936374723.png",
                },
                type = "pack",
                items = {
                    {id = "5ifty6x6T", amount = 1, type = "car", name = "Performa 6X6 [BEAST]"},
                    {id = "rs666mini", amount = 1, type = "car", name = "Mini Beast"},
                    {id = "tmax", amount = 1, type = "car", name = "Super Motor"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "prime_pack",
                name = "Prime Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 650,
                images = {
                    "https://i.postimg.cc/6QrGdxrr/2f262763-7333-4959-ba77-bf3f89edfc93.png",
                },
                type = "pack",
                items = {
                    {id = "RTGM8", amount = 1, type = "car", name = "MXK 8 Speed"},
                    {id = "huracanpriorbeast", amount = 1, type = "car", name = "Furiano (Speciale Versie)"},
                    {id = "mrwheelchair", amount = 1, type = "car", name = "Mexc Bodykit XXL"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "og_pack",
                name = "OG Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 600,
                images = {
                    "https://i.postimg.cc/T1zR7pGg/442aba12-dd05-40dd-b8ee-b5a63b4f9ba2.png",
                },
                type = "pack",
                items = {
                    {id = "DBg634x4byv", amount = 1, type = "car", name = "10 Persoons Super"},
                    {id = "rmodlegosenna", amount = 1, type = "car", name = "Astrion"},
                    {id = "scrq7", amount = 1, type = "car", name = "Titanis Xtreme (NIEUW) SUPER SNEL"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "king_pack",
                name = "King Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 600,
                images = {
                    "https://i.postimg.cc/76Pb0GYw/4ef00aac-0879-49d4-9d40-754090868347.png",
                },
                type = "pack",
                items = {
                    {id = "rmodlego1", amount = 1, type = "car", name = "Vintari H1X"},
                    {id = "pv_sianr", amount = 1, type = "car", name = "Mini Beast"},
                    {id = "rmodlego3", amount = 1, type = "car", name = "Schattige Super Auto"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "diamond_pack",
                name = "Diamond Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 550,
                images = {
                    "https://i.postimg.cc/jSVHNcVJ/af0e4ab4-b278-4b4a-b27c-a9c4c8187c30.png",
                },
                type = "pack",
                items = {
                    {id = "gstramv1", amount = 1, type = "car", name = "Beast Trucker"},
                    {id = "DBpbbmwm3", amount = 1, type = "car", name = "Blue Monster Auto"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "luitenand_pack",
                name = "Luitenand Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 500,
                images = {
                    "https://i.postimg.cc/Ls9ZB0xd/e031c9d8-78d5-4717-8d52-70dd90e45f4b.png",
                },
                type = "pack",
                items = {
                    {id = "Rolls6x6", amount = 1, type = "car", name = "[SUPER BEAST] 6X6"},
                    {id = "pv_jeep", amount = 1, type = "car", name = "Mini Beast"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "captain_pack",
                name = "Captain Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 450,
                images = {
                    "https://i.postimg.cc/RV6XLXp6/a72205d4-8c37-4cba-a70c-1fa180d9d066.png",
                },
                type = "pack",
                items = {
                    {id = "pv_sianr", amount = 1, type = "car", name = "Mini Beast"},
                    {id = "mk8r", amount = 1, type = "car", name = "MX8 R +"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "20k_pack",
                name = "20K Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 400,
                images = {
                    "https://i.postimg.cc/d3L1NbyW/6b2782e9-24a5-4295-871d-3bd85387129b.png",
                },
                type = "pack",
                items = {
                    {id = "DMx5m", amount = 1, type = "car", name = "[SUPER BEAST] 6X6"},
                    {id = "audiq7", amount = 1, type = "car", name = "Mini Beast"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 1000000, type = "item", name = "Contant geld"}
                },
            },

            {
                id = "offer_pack",
                name = "Offer Package",
                description = "Complete pakket met allerlei speciale producten!",
                price = 100,
                images = {
                    "https://i.postimg.cc/ZqpDpnsD/54628722-3e03-42e4-a45e-4f7b9039b25c.png",
                },
                type = "pack",
                items = {
                    {id = "pv_sianr", amount = 1, type = "car", name = "Mini Beast"},
                    {id = "rs666mini", amount = 1, type = "car", name = "Super Beast Mini"},
                    {id = "weapon_ak47", amount = 1, type = "weapon", name = "AK-47"},
                    {id = "ammo-rifle", amount = 200, type = "item", name = "Rifle Ammo"},
                    {id = "money", amount = 100000, type = "item", name = "Contant geld"}
                },
            },
        },
        crates = {
            title = "Crates",
            description = "Open crates voor willekeurige beloningen!",
            icon = "https://openaparty.com/open-a-party-shop/images/SonicLootBox%20copy.png",
            products = {
                {
                    id = "basic_crate",
                    name = "Basic Crate",
                    description = "Een basis crate met verschillende beloningen",
                    price = 200,
                    images = {
                        "https://openaparty.com/open-a-party-shop/images/SonicLootBox%20copy.png"
                    },
                    type = "crate",
                    rewards = {
                        { id = "money", name = "Contant geld", amount = 500000, probability = 40, type = "money" },
                        { id = "ammo-9", name = "9mm Ammo", amount = 50, probability = 30, type = "ammo" },
                        { id = "weapon_ump45", name = "UMP-45", amount = 1, probability = 20, type = "weapon" },
                        { id = "adder", name = "Adder", amount = 1, probability = 10, type = "car" }
                    }
                },
                {
                    id = "premium_crate",
                    name = "Premium Crate",
                    description = "Een premium crate met betere beloningen",
                    price = 1000,
                    images = {
                        "https://openaparty.com/open-a-party-shop/images/SonicLootBox%20copy.png"
                    },
                    type = "crate",
                    rewards = {
                        { id = "money_medium", name = "Contant geld", amount = 250000, probability = 35, type = "money" },
                        { id = "ammo_medium", name = "9mm Ammo", amount = 100, probability = 25, type = "ammo" },
                        { id = "weapon_rifle", name = "AK-47", amount = 1, probability = 25, type = "weapon" },
                        { id = "car_premium", name = "Premium Car", amount = 1, probability = 15, type = "car" }
                    }
                },
                {
                    id = "legendary_crate",
                    name = "Legendary Crate",
                    description = "Een legendarische crate met de beste beloningen",
                    price = 2000,
                    images = {
                        "https://openaparty.com/open-a-party-shop/images/SonicLootBox%20copy.png"
                    },
                    type = "crate",
                    rewards = {
                        { id = "money_large", name = "Contant geld", amount = 1000000, probability = 30, type = "money" },
                        { id = "helicopter", name = "Super Volito", amount = 1, probability = 20, type = "helicopter" },
                        { id = "car_legendary", name = "Porsche GT3RS", amount = 1, probability = 25, type = "car" },
                        { id = "drugsloods", name = "Coke Loods", amount = 1, probability = 15, type = "drugsloods" },
                        { id = "wapenloods", name = "Wapenloods 7 dagen", amount = 1, probability = 10, type = "wapenloods" }
                    }
                }
            },
            }
        },
    }
}

-- Config.DiscountCodes = {
--     ["WELCOME10"] = {
--         percentage = 10,
--         description = "10% korting voor nieuwe spelers"
--     },
--     ["SAVE20"] = {
--         percentage = 20,
--         description = "20% korting op je bestelling"
--     },
--     ["MEGA50"] = {
--         percentage = 50,
--         description = "50% MEGA korting!"
--     }
-- }

---@param player [PLAYER ID]
---@param title [Title of the notify]
---@param description [Description of the notify]
---@param icon [Notify Icon]
function Notify(player, title, description, icon)
   TriggerClientEvent('ox_lib:notify', player, {
        title = title,
        description = description,
        icon = icon,
        duration = 5000,
   })
end

---@param player [PLAYER ID]
---@param type [Product Type]
---@param productname [Product ID] 
---@param amount [Product Amount]
function GiveProduct(player, type, productname, amount)
    print(player, productname, amount)
    if type == "weapon" or type == "item" then 
        exports.ox_inventory:AddItem(player, productname, amount) 
        return true

    elseif type == "car" then 
        giveVehicle(player, productname, 'car')
        return true

    elseif type == "vip" then
        local ok, err = pcall(function()
            exports['mallorca_vipmsg']:addVipPlayer(player, productname)
        end)
        if not ok then
            print(('[Mallorca-tebexwrapper] FOUT: kon VIP niet toekennen aan speler %s (product: %s). Is mallorca_vipmsg gestart? Error: %s'):format(tostring(player), tostring(productname), tostring(err)))
            return false
        end
        return true

    elseif type == "takenwegkopen" then
        local ok, err = pcall(function()
            exports['fx-taakstraf']:RemoveTaakstraf(player, "Tebex - Taken wegkopen")
        end)
        if not ok then
            print(('[Mallorca-tebexwrapper] FOUT: kon taakstraf niet verwijderen bij speler %s. Is fx-taakstraf gestart? Error: %s'):format(tostring(player), tostring(err)))
            return false
        end
        return true

    elseif type == "air" then 
        giveVehicle(player, productname, 'air')
        return true

    elseif type == "boat" then 
        giveVehicle(player, productname, 'boat')
        return true

    elseif type == "drugsloods" then 
        local xPlayer = ESX.GetPlayerFromId(player)
        local coords = xPlayer.getCoords(true)
        local radius = 20.0
        if exports["matrix_drugsloods"]:isLoodsNearby(coords, radius) then 
            TriggerClientEvent('ox_lib:notify', player, {
                title = 'Er is al een loods in de buurt, probeer het ergens anders',
                type = 'error'
            })
            return false 
        end

        exports["matrix_drugsloods"]:createLoods(xPlayer.identifier, 0, 'Met Coins Gekocht', productname, coords)
        return true

    elseif type == "drugsloodslevel" then 
        local xPlayer = ESX.GetPlayerFromId(player)

        local loods = exports["matrix_drugsloods"]:chooseFromOwnedLoodsen(xPlayer.identifier)

        if not loods then 
            TriggerClientEvent('ox_lib:notify', player, {
                title = 'Je hebt geen loods op jouw naam!',
                type = 'error'
            })
            return false
        end

        exports["matrix_drugsloods"]:upgradeLoods(loods, productname)
        return true

    elseif type == "wapenloods" then 
        local xPlayer = ESX.GetPlayerFromId(player)

        exports["matrix_wapenloods"]:makeLoods(player, productname)
        return true


    elseif type == "wapenloodslevel" then 
        local xPlayer = ESX.GetPlayerFromId(player)

        local loods = exports["matrix_wapenloods"]:chooseFromOwnedWapenLoodsen(xPlayer.identifier)

        if not loods then 
            TriggerClientEvent('ox_lib:notify', player, {
                title = 'Je hebt geen loods op jouw naam!',
                type = 'error'
            })
            return false
        end

        exports["matrix_wapenloods"]:upgradeWapenLoods(loods, productname)
        return true

    elseif type == "killmessage" then
        return exports['killmessages']:GrantTier(player, productname)

    end

    return false
end