-- Optioneel: verkoop de handwas-items ook via esx_shops (24/7, LTD, Robs).
-- De resource heeft al een eigen winkel; dit is extra.
-- Importeer dit NIET als je geen `shops`-tabel hebt.

INSERT INTO `shops` (`store`, `item`, `price`) VALUES
    ('TwentyFourSeven', 'empty_bucket',     50),
    ('TwentyFourSeven', 'car_sponge',       30),
    ('TwentyFourSeven', 'car_soap',         25),
    ('TwentyFourSeven', 'microfiber_cloth', 22),
    ('TwentyFourSeven', 'car_wax',          60),
    ('TwentyFourSeven', 'tire_cleaner',     35),
    ('TwentyFourSeven', 'hand_carwash_kit', 165),
    ('RobsLiquor',      'car_soap',         25),
    ('RobsLiquor',      'microfiber_cloth', 22),
    ('LTDgasoline',     'empty_bucket',     50),
    ('LTDgasoline',     'car_sponge',       30),
    ('LTDgasoline',     'car_soap',         25),
    ('LTDgasoline',     'car_wax',          60),
    ('LTDgasoline',     'hand_carwash_kit', 165);
