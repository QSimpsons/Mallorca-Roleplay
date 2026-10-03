-- Locaties overgenomen uit ocean_garage.
-- coords = marker om een voertuig uit te halen.
-- store = marker om te parkeren.
-- spawns = plekken waar het voertuig verschijnt.
Config = Config or {}

Config.Garages = {
	{
		id = 'car-haven',
		label = 'Haven',
		type = 'car',
		coords = vector3(201.5898, -3067.1487, 5.7756),
		store = vector3(204.6271, -3076.2620, 5.7743),
		spawns = {
			vector4(204.6271, -3076.2620, 5.7743, 85.7869),
		}
	},
	{
		id = 'car-grapseed2',
		label = 'Grapseed2',
		type = 'car',
		coords = vector3(2546.8877, 4667.9507, 34.0768),
		store = vector3(2553.4629, 4676.4961, 33.9256),
		spawns = {
			vector4(2553.4629, 4676.4961, 33.9256, 287.3750),
		}
	},
	{
		id = 'car-lllll',
		label = 'LLLLL',
		type = 'car',
		coords = vector3(93.2009, 3594.3501, 39.6938),
		store = vector3(82.4333, 3599.1970, 39.7234),
		spawns = {
			vector4(82.4333, 3599.1970, 39.7234, 174.8154),
		}
	},
	{
		id = 'car-la-cosa-nostra',
		label = 'La Cosa Nostra',
		type = 'car',
		coords = vector3(-1336.2286, -1054.5354, -5.8600),
		store = vector3(-1344.1246, -1053.3534, -5.8600),
		blip = false,
		spawns = {
			vector4(-1313.5002, -1054.9645, -6.5511, 30.3168),
			vector4(-1318.3998, -1057.4694, -6.5510, 30.3168),
			vector4(-1322.8306, -1060.0364, -6.5506, 30.3168),
			vector4(-1328.8605, -1063.4219, -6.5506, 30.3168),
			vector4(-1333.9541, -1066.3076, -6.5506, 30.3168),
			vector4(-1338.3766, -1068.7810, -6.5506, 30.3168),
			vector4(-1342.5062, -1071.0029, -6.5506, 30.3168),
			vector4(-1347.2812, -1073.6567, -6.5506, 30.3168),
		}
	},
	{
		id = 'car-da-family',
		label = 'DA Family',
		type = 'car',
		coords = vector3(-1267.8643, 804.4902, 193.3800),
		store = vector3(-1253.3510, 815.1102, 193.3800),
		blip = false,
		spawns = {
			vector4(-1267.6766, 810.4789, 193.3801, 247.6274),
			vector4(-1266.0945, 813.2844, 193.3801, 63.0241),
		}
	},
	{
		id = 'car-garage-98',
		label = 'Garage 98',
		type = 'car',
		coords = vector3(-700.0212, -2512.1655, 13.9471),
		store = vector3(-705.0195, -2519.2495, 13.9473),
		blip = false,
		spawns = {
			vector4(-710.0432, -2515.1240, 13.5359, 147.9635),
		}
	},
	{
		id = 'car-kmar-bureau',
		label = 'Kmar Bureau',
		type = 'car',
		coords = vector3(2557.5344, 2579.0637, 37.9451),
		store = vector3(2549.2986, 2577.4597, 37.2542),
		blip = false,
		spawns = {
			vector4(2540.4773, 2584.2227, 37.4028, 83.5275),
			vector4(2538.5454, 2587.6870, 37.4026, 83.4920),
			vector4(2538.1304, 2590.8613, 37.4020, 83.4286),
			vector4(2536.5371, 2594.1323, 37.2538, 89.3306),
			vector4(2535.5151, 2597.5540, 37.2540, 85.6587),
			vector4(2534.4246, 2601.0085, 37.2542, 85.1905),
		}
	},
	{
		id = 'car-garage-fortuna',
		label = 'Garage Fortuna',
		type = 'car',
		coords = vector3(-427.1397, 1198.7178, 325.7582),
		store = vector3(-411.3582, 1198.1206, 325.6597),
		blip = false,
		spawns = {
			vector4(-421.1641, 1203.3700, 325.2304, 226.8660),
			vector4(-420.1371, 1207.6122, 325.2300, 230.4117),
			vector4(-418.5739, 1211.4532, 325.2303, 230.5207),
		}
	},
	{
		id = 'car-garage-oak',
		label = 'Garage Oak',
		type = 'car',
		coords = vector3(-1554.0485, 14.7866, 58.8617),
		store = vector3(-1557.0769, 21.6212, 58.6596),
		blip = false,
		spawns = {
			vector4(-1551.6835, 24.5399, 58.0837, 351.6166),
		}
	},
	{
		id = 'car-garage-abcwegermee',
		label = 'Garage abcwegermee',
		type = 'car',
		coords = vector3(467.1657, -1977.6100, 24.6734),
		store = vector3(478.8704, -1977.9746, 24.6568),
		blip = false,
		spawns = {
			vector4(497.2593, -1973.6276, 24.9217, 123.1568),
		}
	},
	{
		id = 'car-garage-tijuana',
		label = 'Garage Tijuana',
		type = 'car',
		coords = vector3(-1892.3525, 2039.3722, 140.8784),
		store = vector3(-1899.7849, 2035.8077, 140.7398),
		blip = false,
		spawns = {
			vector4(-1895.8813, 2034.3311, 140.7413, 160.1208),
			vector4(-1891.7522, 2033.5966, 140.3249, 159.6328),
			vector4(-1887.4529, 2032.8037, 140.3183, 160.3153),
			vector4(-1882.6306, 2030.5726, 140.0985, 165.5195),
		}
	},
	{
		id = 'car-garage-arena',
		label = 'Garage Arena',
		type = 'car',
		coords = vector3(-73.0995, -2004.2644, 18.2753),
		store = vector3(-80.3148, -1999.3336, 18.0014),
		spawns = {
			vector4(-78.7011, -1987.6239, 17.6055, 170.3789),
			vector4(-75.1473, -1988.5824, 17.6056, 171.0154),
		}
	},
	{
		id = 'car-politie-bureau',
		label = 'Politie Bureau',
		type = 'car',
		coords = vector3(441.4670, -982.5603, 25.7089),
		store = vector3(441.4598, -988.3273, 25.7029),
		blip = false,
		spawns = {
			vector4(426.2995, -984.9420, 25.2978, 270.8760),
			vector4(426.5698, -988.4188, 25.2984, 270.3167),
			vector4(426.5681, -991.5787, 25.2979, 270.3167),
		}
	},
	{
		id = 'car-garage-hb',
		label = 'Garage HB',
		type = 'car',
		coords = vector3(-368.6172, -329.7699, 24.7559),
		store = vector3(-376.3072, -327.0607, 24.7558),
		blip = false,
		spawns = {
			vector4(-375.0765, -321.1437, 24.7552, 80.6712),
			vector4(-374.4138, -316.6786, 24.7559, 83.5092),
			vector4(-373.6524, -311.7509, 24.7319, 80.7016),
			vector4(-372.9522, -307.4572, 24.7502, 80.6981),
			vector4(-372.1472, -303.0232, 24.7453, 79.7090),
		}
	},
	{
		id = 'car-garage-pechhulp',
		label = 'Garage Pechhulp',
		type = 'car',
		coords = vector3(-73.9741, -1834.3890, 26.9454),
		store = vector3(-66.1089, -1837.3427, 26.8203),
		blip = false,
		spawns = {
			vector4(-62.8182, -1840.5680, 26.2724, 319.9781),
			vector4(-60.1735, -1842.9105, 26.1731, 319.2789),
		}
	},
	{
		id = 'car-dsi-uitvalbasis',
		label = 'DSI Uitvalbasis',
		type = 'car',
		coords = vector3(-273.1635, -913.9465, 17.9218),
		store = vector3(-260.8256, -918.7222, 17.9218),
		blip = false,
		spawns = {
			vector4(-259.8347, -915.2695, 17.9218, 94.2864),
		}
	},
	{
		id = 'car-garage-pandora',
		label = 'Garage Pandora',
		type = 'car',
		coords = vector3(-827.1588, 177.7423, 71.1325),
		store = vector3(-827.1588, 177.7423, 71.1325),
		blip = false,
		spawns = {
			vector4(-827.1588, 177.7423, 71.1325, 151.8527),
		}
	},
	{
		id = 'car-garage-geen-idee',
		label = 'Garage Geen Idee',
		type = 'car',
		coords = vector3(-756.3483, -239.9612, 37.2510),
		store = vector3(-761.1275, -231.2389, 37.2839),
		spawns = {
			vector4(-763.3487, -243.0397, 37.2421, 196.9950),
		}
	},
	{
		id = 'car-garage-sandy',
		label = 'Garage Sandy',
		type = 'car',
		coords = vector3(1747.9742, 3295.5876, 41.1241),
		store = vector3(1737.1890, 3289.0210, 41.1433),
		spawns = {
			vector4(1754.9062, 3290.2449, 40.7079, 268.6182),
			vector4(1754.5122, 3287.1021, 40.7075, 263.6620),
		}
	},
	{
		id = 'car-garage-pier',
		label = 'Garage Pier',
		type = 'car',
		coords = vector3(-1543.7968, -963.5634, 13.0174),
		store = vector3(-1548.0959, -973.8604, 13.0043),
		spawns = {
			vector4(-1551.5106, -991.5746, 12.6071, 24.3500),
			vector4(-1549.1835, -988.4528, 12.6065, 24.2338),
		}
	},
	{
		id = 'car-garage-gaviria',
		label = 'Garage Gaviria',
		type = 'car',
		coords = vector3(-1935.3948, 562.2785, 115.3917),
		store = vector3(-1940.1134, 561.5894, 115.2423),
		blip = false,
		spawns = {
			vector4(-1940.1134, 561.5894, 115.2423, 81.1201),
		}
	},
	{
		id = 'car-garage-oakfamilia',
		label = 'Garage Oakfamilia',
		type = 'car',
		coords = vector3(-3200.7798, 831.6097, 8.9349),
		store = vector3(-3208.1218, 831.6962, 8.9308),
		blip = false,
		spawns = {
			vector4(-3208.1218, 831.6962, 8.9308, 117.8332),
		}
	},
	{
		id = 'car-garage-roztheacartel',
		label = 'Garage Roztheacartel',
		type = 'car',
		coords = vector3(-1448.5552, -356.9034, 44.2422),
		store = vector3(-1465.0532, -343.9513, 20.4609),
		blip = false,
		spawns = {
			vector4(-1441.1024, -366.8294, 43.5998, 34.6041),
			vector4(-1437.2557, -365.5551, 43.6380, 34.0861),
			vector4(-1443.6755, -370.4325, 43.5010, 46.1310),
		}
	},
	{
		id = 'car-terceiro',
		label = 'Terceiro',
		type = 'car',
		coords = vector3(-2788.2141, 1431.0808, 100.9283),
		store = vector3(-2786.2671, 1433.8860, 100.9283),
		blip = false,
		spawns = {
			vector4(-2778.4207, 1427.6066, 100.9284, 317.3495),
		}
	},
	{
		id = 'car-gaviria',
		label = 'Gaviria',
		type = 'car',
		coords = vector3(-1934.4666, 537.9634, 110.7339),
		store = vector3(-1927.5042, 534.9194, 110.7341),
		blip = false,
		spawns = {
			vector4(-1934.4919, 538.9632, 110.7341, 161.0617),
		}
	},
	{
		id = 'car-athena',
		label = 'Athena',
		type = 'car',
		coords = vector3(-876.9203, 53.9804, 48.7531),
		store = vector3(-880.4438, 30.5428, 48.7591),
		blip = false,
		spawns = {
			vector4(-871.5283, 47.9191, 48.7673, 157.1047),
		}
	},
	{
		id = 'car-chumash-plaza',
		label = 'Chumash Plaza',
		type = 'car',
		coords = vector3(-3147.5271, 1063.5127, 20.5808),
		store = vector3(-3162.2993, 1069.4305, 20.6797),
		spawns = {
			vector4(-3140.9312, 1079.0254, 20.6365, 84.3115),
			vector4(-3137.3906, 1090.7534, 20.6373, 84.5009),
			vector4(-3153.2144, 1091.8994, 20.7070, 287.3065),
		}
	},
	{
		id = 'car-downtown-vinewood',
		label = 'Downtown Vinewood',
		type = 'car',
		coords = vector3(363.6394, 286.5844, 103.4062),
		store = vector3(374.8504, 289.7036, 103.2356),
		spawns = {
			vector4(374.6914, 282.9803, 103.1818, 342.3198),
			vector4(378.5236, 281.1696, 103.1107, 342.0529),
			vector4(386.7065, 289.8867, 103.0445, 162.0684),
			vector4(371.6543, 276.0481, 103.1413, 162.7343),
		}
	},
	{
		id = 'car-gulag-gang',
		label = 'Gulag Gang',
		type = 'car',
		coords = vector3(-1101.8881, 356.2211, 68.4876),
		store = vector3(-1096.1708, 358.1043, 67.5016),
		blip = false,
		spawns = {
			vector4(-1097.7072, 357.6286, 68.0815, 358.1525),
			vector4(-1093.4634, 357.5331, 68.1055, 359.0058),
		}
	},
	{
		id = 'car-kor-family',
		label = 'Kor Family',
		type = 'car',
		coords = vector3(-3137.3328, 1555.5481, 37.2797),
		store = vector3(-3143.2217, 1558.5952, 37.2797),
		blip = false,
		spawns = {
			vector4(-3154.6523, 1550.1243, 37.2805, 266.9151),
		}
	},
	{
		id = 'car-tequila-bar-garage',
		label = 'Tequila bar Garage',
		type = 'car',
		coords = vector3(-562.1979, 319.1414, 84.4056),
		store = vector3(-575.9156, 315.9131, 84.6221),
		spawns = {
			vector4(-572.9136, 324.2142, 84.5396, 355.6822),
			vector4(-576.5947, 324.2142, 84.6706, 355.6822),
			vector4(-579.9665, 324.2142, 84.7870, 355.6822),
			vector4(-583.5693, 324.2142, 84.9134, 355.6822),
		}
	},
	{
		id = 'car-haven-garage',
		label = 'Haven Garage',
		type = 'car',
		coords = vector3(-347.7068, -2772.4473, 5.2002),
		store = vector3(-337.8532, -2769.7563, 4.9607),
		spawns = {
			vector4(-336.9621, -2775.7302, 4.5894, 89.6051),
		}
	},
	{
		id = 'car-begraafplaats',
		label = 'Begraafplaats',
		type = 'car',
		coords = vector3(-1655.2815, -195.0814, 55.4125),
		store = vector3(-1647.4709, -209.9251, 54.6898),
		spawns = {
			vector4(-1658.0552, -201.6841, 54.9327, 250.0545),
			vector4(-1660.3157, -208.2283, 54.8249, 249.7179),
			vector4(-1640.2582, -202.6948, 54.7336, 156.3190),
			vector4(-1637.0087, -203.9373, 54.7199, 159.9798),
			vector4(-1660.0574, -204.7012, 54.9158, 251.2969),
			vector4(-1659.6365, -208.7542, 54.7989, 250.6599),
			vector4(-1661.2968, -211.6726, 54.7620, 249.3159),
			vector4(-1662.8281, -214.7726, 54.6949, 256.4296),
			vector4(-1664.8030, -220.4368, 54.5840, 252.0479),
			vector4(-1646.7522, -217.2381, 54.6654, 69.1595),
			vector4(-1647.4093, -220.5418, 54.6486, 67.6513),
			vector4(-1639.9075, -219.4203, 54.5884, 251.9194),
			vector4(-1641.0062, -222.9383, 54.5509, 251.4814),
			vector4(-1674.9720, -247.1024, 54.1580, 250.1719),
			vector4(-1674.4469, -243.6051, 54.2156, 248.1018),
			vector4(-1672.8894, -239.9928, 54.2859, 248.7997),
			vector4(-1671.4836, -236.8582, 54.3410, 248.4482),
			vector4(-1670.1710, -233.7055, 54.3864, 246.2599),
			vector4(-1669.0850, -230.2889, 54.4390, 251.6179),
			vector4(-1668.2189, -226.5732, 54.4954, 250.8041),
			vector4(-1662.4727, -250.7600, 54.4965, 340.4158),
			vector4(-1658.8542, -252.2887, 54.4995, 337.4629),
			vector4(-1655.8685, -253.4741, 54.4140, 338.4302),
		}
	},
	{
		id = 'car-young-gunners',
		label = 'Young Gunners',
		type = 'car',
		coords = vector3(-1527.2202, 889.3781, 181.8416),
		store = vector3(-1538.5967, 881.6662, 181.5057),
		blip = false,
		spawns = {
			vector4(-1531.1056, 890.2296, 181.8866, 5.1519),
			vector4(-1534.8490, 889.9141, 181.8069, 40.7248),
			vector4(-1538.7815, 889.4070, 181.6893, 25.1971),
			vector4(-1542.0918, 888.0227, 181.5052, 26.7248),
			vector4(-1545.4260, 886.1891, 181.3441, 26.4636),
			vector4(-1548.5208, 883.7747, 181.2965, 21.9110),
			vector4(-1551.2168, 880.4195, 181.3223, 22.0000),
		}
	},
	{
		id = 'car-minigames',
		label = 'Minigames',
		type = 'car',
		coords = vector3(237.1657, -752.1865, 34.6313),
		store = vector3(243.1560, -744.1041, 34.6151),
		blip = false,
		spawns = {
			vector4(243.6808, -742.5338, 34.2101, 159.3634),
			vector4(246.9056, -743.6586, 34.2185, 159.8079),
			vector4(250.3185, -744.5073, 34.2243, 158.6905),
			vector4(253.4620, -746.1085, 34.2261, 159.6746),
		}
	},
	{
		id = 'car-savage-skulls',
		label = 'Savage Skulls',
		type = 'car',
		coords = vector3(302.5232, -2739.5171, 6.0166),
		store = vector3(302.0831, -2750.3264, 6.1490),
		blip = false,
		spawns = {
			vector4(309.0904, -2761.1357, 5.5835, 137.7937),
			vector4(308.6494, -2757.0571, 5.5729, 134.3141),
		}
	},
	{
		id = 'car-narkoz',
		label = 'Narkoz',
		type = 'car',
		coords = vector3(-1990.2253, -211.9282, 35.0240),
		store = vector3(-1979.8979, -208.4507, 34.9937),
		blip = false,
		spawns = {
			vector4(-1979.2697, -209.4137, 34.5596, 312.2587),
			vector4(-1973.8798, -207.1422, 34.8983, 270.7280),
		}
	},
	{
		id = 'car-reef',
		label = 'Reef',
		type = 'car',
		coords = vector3(-3275.4255, 522.5677, 12.2654),
		store = vector3(-3277.4802, 527.3721, 12.2654),
		blip = false,
		spawns = {
			vector4(-3282.3047, 524.6979, 12.2654, 115.0539),
		}
	},
	{
		id = 'car-no-mercy',
		label = 'No Mercy',
		type = 'car',
		coords = vector3(1375.3890, 4729.6475, 135.9393),
		store = vector3(1371.0856, 4729.4604, 135.9394),
		blip = false,
		spawns = {
			vector4(1372.7012, 4738.0566, 135.9393, 271.9198),
			vector4(1382.7781, 4738.5898, 135.9393, 274.0628),
		}
	},
	{
		id = 'car-blokkenpark',
		label = 'Blokkenpark',
		type = 'car',
		coords = vector3(213.9300, -809.2979, 31.0149),
		store = vector3(208.3095, -795.9836, 30.5500),
		spawns = {
			vector4(210.6640, -788.4648, 30.5076, 250.8897),
			vector4(211.7812, -786.0963, 30.4902, 251.0495),
		}
	},
	{
		id = 'car-rode-garage',
		label = 'Rode Garage',
		type = 'car',
		coords = vector3(-332.1514, -779.7233, 33.9645),
		store = vector3(-328.6704, -767.9117, 33.9650),
		spawns = {
			vector4(-341.9704, -767.3699, 32.5578, 91.0023),
			vector4(-341.6941, -763.9532, 32.5574, 90.2498),
		}
	},
	{
		id = 'car-del-perro',
		label = 'Del Perro',
		type = 'car',
		coords = vector3(-1523.1262, -451.7191, 35.5919),
		store = vector3(-1512.5807, -440.1878, 35.4468),
		spawns = {
			vector4(-1509.9956, -435.0706, 34.0323, 83.7294),
			vector4(-1509.8330, -431.5845, 34.0313, 83.9128),
		}
	},
	{
		id = 'car-mayans-mc',
		label = 'Mayans MC',
		type = 'car',
		coords = vector3(-78.1837, 6476.9502, 31.4962),
		store = vector3(-77.3819, 6482.7012, 31.4908),
		blip = false,
		spawns = {
			vector4(-82.6760, 6487.4829, 31.4909, 228.6588),
			vector4(-77.8699, 6490.3496, 31.4909, 263.8907),
		}
	},
	{
		id = 'car-ziekenhuis',
		label = 'Ziekenhuis',
		type = 'car',
		coords = vector3(1210.5757, -1539.1233, 39.4028),
		store = vector3(1180.5753, -1538.0227, 38.4012),
		spawns = {
			vector4(1209.3368, -1549.5231, 38.9905, 50.5182),
			vector4(1207.5289, -1552.4377, 38.9900, 52.8433),
			vector4(1205.3647, -1555.0883, 38.9893, 53.4957),
		}
	},
	{
		id = 'car-eiland',
		label = 'Eiland',
		type = 'car',
		coords = vector3(4518.4766, -4510.9033, 4.5012),
		store = vector3(4511.4736, -4519.5205, 3.7193),
		spawns = {
			vector4(4512.0317, -4511.7974, 3.7452, 39.6670),
		}
	},
	{
		id = 'car-eiland-haven',
		label = 'Eiland Haven',
		type = 'car',
		coords = vector3(4977.3735, -5168.8857, 2.4264),
		store = vector3(4981.3979, -5174.4346, 2.4831),
		spawns = {
			vector4(4988.4692, -5173.9653, 2.5101, 267.1523),
			vector4(4989.0156, -5177.7178, 2.5045, 214.0396),
		}
	},
	{
		id = 'car-eiland-2',
		label = 'Eiland 2',
		type = 'car',
		coords = vector3(5369.8740, -5438.2061, 48.5080),
		store = vector3(5373.8379, -5445.3867, 48.0580),
		blip = false,
		spawns = {
			vector4(5373.8599, -5445.4214, 48.0578, 310.9549),
		}
	},
	{
		id = 'car-saints',
		label = 'Saints',
		type = 'car',
		coords = vector3(-1144.3977, -1569.7443, 4.4296),
		store = vector3(-1148.9316, -1572.7677, 4.4296),
		blip = false,
		spawns = {
			vector4(-1145.4955, -1581.8501, 4.3813, 304.3326),
		}
	},
	{
		id = 'car-la-icona',
		label = 'La Icona',
		type = 'car',
		coords = vector3(145.4738, -1294.5013, 29.3706),
		store = vector3(147.2938, -1300.7526, 28.9288),
		blip = false,
		spawns = {
			vector4(137.2693, -1307.0764, 28.9381, 117.5849),
		}
	},
	{
		id = 'car-armeense',
		label = 'Armeense',
		type = 'car',
		coords = vector3(-882.5577, -55.7723, 38.0500),
		store = vector3(-866.6703, -54.4356, 38.3097),
		blip = false,
		spawns = {
			vector4(-866.6703, -54.4356, 38.3097, 294.6743),
		}
	},
	{
		id = 'car-red-devils-mc',
		label = 'Red Devils MC',
		type = 'car',
		coords = vector3(1939.6907, 4622.7798, 40.7699),
		store = vector3(1937.6785, 4615.2451, 40.6136),
		blip = false,
		spawns = {
			vector4(1937.6785, 4615.2451, 40.6136, 38.6797),
		}
	},
	{
		id = 'car-satudarak',
		label = 'Satudarak',
		type = 'car',
		coords = vector3(-2200.5168, 4272.9927, 48.4394),
		store = vector3(-2206.0789, 4259.2363, 47.6214),
		blip = false,
		spawns = {
			vector4(-2196.9106, 4269.7139, 48.1147, 148.2626),
		}
	},
	{
		id = 'car-zone6',
		label = 'Zone6',
		type = 'car',
		coords = vector3(-1529.9194, 91.1121, 56.6598),
		store = vector3(-1525.4910, 97.7604, 56.6788),
		blip = false,
		spawns = {
			vector4(-1522.3546, 89.1488, 56.4337, 250.9685),
		}
	},
	{
		id = 'car-chinees-restaurant',
		label = 'Chinees Restaurant',
		type = 'car',
		coords = vector3(-216.3152, 315.0790, 96.9455),
		store = vector3(-215.7912, 300.9517, 96.9458),
		blip = false,
		spawns = {
			vector4(-202.2468, 301.6970, 96.9455, 356.5894),
		}
	},
	{
		id = 'car-sandy-huis',
		label = 'Sandy Huis',
		type = 'car',
		coords = vector3(825.7897, 3442.2493, 57.8581),
		store = vector3(814.8832, 3419.7334, 59.2724),
		blip = false,
		spawns = {
			vector4(814.8329, 3418.7585, 59.5057, 152.4426),
		}
	},
	{
		id = 'car-albanese-maffia',
		label = 'Albanese Maffia',
		type = 'car',
		coords = vector3(-98.7018, 833.5001, 235.7234),
		store = vector3(-112.0162, 834.7837, 235.6845),
		blip = false,
		spawns = {
			vector4(-110.0912, 835.3334, 235.6917, 285.6742),
		}
	},
	{
		id = 'car-peaky',
		label = 'Peaky',
		type = 'car',
		coords = vector3(-70.9136, 340.6896, 112.4426),
		store = vector3(-85.4582, 341.3901, 112.4383),
		blip = false,
		spawns = {
			vector4(-54.0181, 346.9736, 112.2899, 154.6609),
		}
	},
	{
		id = 'car-bloods',
		label = 'Bloods',
		type = 'car',
		coords = vector3(82.0803, -1970.9001, 20.8595),
		store = vector3(85.8388, -1971.5424, 20.3731),
		blip = false,
		spawns = {
			vector4(88.8377, -1967.8134, 20.3361, 321.1977),
		}
	},
	{
		id = 'car-dtmc',
		label = 'DTMC',
		type = 'car',
		coords = vector3(118.4051, 322.8893, 112.1387),
		store = vector3(112.0573, 321.6100, 112.1245),
		blip = false,
		spawns = {
			vector4(110.1714, 317.6296, 112.1220, 343.9799),
			vector4(113.7650, 326.2608, 112.1217, 118.9667),
		}
	},
	{
		id = 'car-hells-vultures',
		label = 'Hells Vultures',
		type = 'car',
		coords = vector3(997.1799, -2528.1960, 28.3022),
		store = vector3(996.7377, -2518.1536, 28.3022),
		blip = false,
		spawns = {
			vector4(988.3983, -2509.4780, 28.3022, 3.8210),
		}
	},
	{
		id = 'car-cardealer',
		label = 'Cardealer',
		type = 'car',
		coords = vector3(-59.0469, -1117.3998, 26.4348),
		store = vector3(-55.6519, -1109.6096, 26.4363),
		spawns = {
			vector4(-65.9714, -1106.6321, 26.0269, 76.4781),
		}
	},
	{
		id = 'car-bratva',
		label = 'Bratva',
		type = 'car',
		coords = vector3(-1585.9016, -81.1360, 54.3345),
		store = vector3(-1568.0206, -80.8526, 54.1346),
		blip = false,
		spawns = {
			vector4(-1575.8798, -80.9898, 54.1346, 273.9265),
			vector4(-1575.9955, -85.8805, 54.1346, 268.4294),
		}
	},
	{
		id = 'car-sinadra',
		label = 'sinadra',
		type = 'car',
		coords = vector3(569.8260, -2794.6355, 6.0815),
		store = vector3(565.6531, -2800.2488, 6.0819),
		blip = false,
		spawns = {
			vector4(588.4016, -2811.9753, 6.0577, 330.5018),
		}
	},
	{
		id = 'car-sinadra-2',
		label = 'sinadra 2',
		type = 'car',
		coords = vector3(-1168.6724, -1394.0148, 4.8885),
		store = vector3(-1171.0359, -1390.5673, 4.8832),
		blip = false,
		spawns = {
			vector4(-1179.9796, -1397.0507, 4.6569, 304.3877),
		}
	},
	{
		id = 'car-sins',
		label = 'Sins',
		type = 'car',
		coords = vector3(954.1199, -133.5744, 74.4538),
		store = vector3(967.8045, -141.4317, 74.4007),
		blip = false,
		spawns = {
			vector4(971.1328, -115.2352, 74.3531, 219.8679),
			vector4(964.9326, -119.5914, 73.9442, 223.9382),
			vector4(970.4620, -114.0773, 73.9412, 222.1585),
		}
	},
	{
		id = 'car-peakyblinders',
		label = 'PeakyBlinders',
		type = 'car',
		coords = vector3(3443.1843, 4893.3540, 35.9998),
		store = vector3(3431.5254, 4900.3076, 35.9998),
		blip = false,
		spawns = {
			vector4(3435.5273, 4901.3257, 35.9998, 42.8797),
		}
	},
	{
		id = 'car-lafamiliazeta',
		label = 'lafamiliazeta',
		type = 'car',
		coords = vector3(-2584.4846, 1924.1794, 167.3129),
		store = vector3(-2586.3879, 1931.3010, 167.3106),
		blip = false,
		spawns = {
			vector4(-2577.5122, 1929.5162, 167.4436, 236.4261),
		}
	},
	{
		id = 'car-lafuente-blanca',
		label = 'Lafuente Blanca',
		type = 'car',
		coords = vector3(3926.2546, -16.0353, 10.7380),
		store = vector3(3923.9055, -11.9361, 10.6066),
		blip = false,
		spawns = {
			vector4(3926.2456, -9.0310, 10.6066, 270.7263),
		}
	},
	{
		id = 'car-netras-garage',
		label = 'Netras Garage',
		type = 'car',
		coords = vector3(1413.6163, 1110.2062, 114.8286),
		store = vector3(1414.1703, 1118.9760, 114.8394),
		blip = false,
		spawns = {
			vector4(1406.0336, 1118.8214, 114.8367, 91.6110),
			vector4(1392.3370, 1117.7014, 114.9436, 89.0502),
			vector4(1372.3612, 1161.9585, 113.9915, 140.7512),
		}
	},
	{
		id = 'car-krips-garage',
		label = 'Krips Garage',
		type = 'car',
		coords = vector3(-3022.5149, 87.3363, 11.6823),
		store = vector3(-3016.2683, 88.6246, 11.6100),
		blip = false,
		spawns = {
			vector4(-3023.2839, 93.1914, 11.0377, 320.1324),
			vector4(-3026.0793, 95.5683, 11.0362, 319.1674),
			vector4(-3028.8657, 97.9407, 11.0326, 320.0564),
			vector4(-3031.4973, 100.3856, 11.0397, 318.1796),
			vector4(-3034.3015, 102.6280, 11.0395, 320.1486),
			vector4(-3022.5781, 120.8316, 11.0357, 125.0922),
			vector4(-3024.8435, 123.2671, 11.0361, 127.7528),
			vector4(-3026.6494, 126.6672, 11.0350, 127.8112),
		}
	},
	{
		id = 'car-sinadra-garage',
		label = 'sinadra Garage',
		type = 'car',
		coords = vector3(-131.1213, 1006.7343, 235.7321),
		store = vector3(-124.5177, 1008.6713, 235.7321),
		blip = false,
		spawns = {
			vector4(-120.7474, 991.1309, 235.7539, 104.8713),
		}
	},
	{
		id = 'car-no-surrender',
		label = 'No Surrender',
		type = 'car',
		coords = vector3(1267.4769, -894.3621, 75.3971),
		store = vector3(1278.7896, -885.8594, 75.3853),
		blip = false,
		spawns = {
			vector4(1277.7402, -886.4415, 75.3971, 77.6806),
		}
	},
	{
		id = 'car-outcast',
		label = 'Outcast',
		type = 'car',
		coords = vector3(1226.5983, -427.9500, 67.6609),
		store = vector3(1228.3086, -435.4861, 67.6992),
		blip = false,
		spawns = {
			vector4(1220.9364, -433.0672, 67.4084, 77.2949),
		}
	},
	{
		id = 'car-diamond-casino',
		label = 'Diamond Casino',
		type = 'car',
		coords = vector3(910.6597, 46.5042, 80.8989),
		store = vector3(918.1911, 58.0620, 80.8992),
		spawns = {
			vector4(916.3001, 47.7258, 80.8988, 324.2435),
		}
	},
	{
		id = 'car-outcast-2',
		label = 'Outcast 2',
		type = 'car',
		coords = vector3(1240.4275, -399.0981, 68.9939),
		store = vector3(1237.7074, -409.7394, 68.9991),
		blip = false,
		spawns = {
			vector4(1244.5148, -409.9719, 69.0235, 320.7214),
		}
	},
	{
		id = 'car-nova-weedshop',
		label = 'Nova Weedshop',
		type = 'car',
		coords = vector3(161.4686, -256.4405, 51.4009),
		store = vector3(157.3012, -255.4108, 51.4009),
		blip = false,
		spawns = {
			vector4(157.0142, -261.4312, 51.3737, 240.4647),
		}
	},
	{
		id = 'car-diaz-cartel',
		label = 'Diaz Cartel',
		type = 'car',
		coords = vector3(-1794.7308, 454.7197, 128.3082),
		store = vector3(-1790.8466, 459.6089, 128.3080),
		blip = false,
		spawns = {
			vector4(-1791.0417, 456.6454, 128.3081, 87.4846),
			vector4(-1791.1854, 459.6074, 128.3081, 87.6521),
		}
	},
	{
		id = 'car-maffia-hotel',
		label = 'Maffia Hotel',
		type = 'car',
		coords = vector3(381.4036, -9.1689, 82.9838),
		store = vector3(364.3503, -8.8585, 82.9979),
		blip = false,
		spawns = {
			vector4(363.4938, -20.1951, 82.9928, 35.1752),
			vector4(375.9785, 1.9647, 82.5682, 128.1721),
			vector4(350.4111, -7.4192, 82.5851, 218.3958),
			vector4(348.3538, -21.6175, 82.5860, 306.7260),
		}
	},
	{
		id = 'car-olie-verwerking',
		label = 'Olie Verwerking',
		type = 'car',
		coords = vector3(582.28, -2310.71, 5.9),
		store = vector3(582.99, -2302.63, 5.91),
		spawns = {
			vector4(582.28, -2310.71, 5.9, 83.67),
		}
	},
	{
		id = 'car-basic-fat',
		label = 'Basic Fat',
		type = 'car',
		coords = vector3(324.59, -230.34, 54.22),
		store = vector3(327.56, -205.42, 54.09),
		spawns = {
			vector4(317.88, -203.31, 54.09, 250.02),
		}
	},
	{
		id = 'car-gsf',
		label = 'GSF',
		type = 'car',
		coords = vector3(-608.9216, -1603.9484, 26.7509),
		store = vector3(-618.7581, -1596.9890, 26.7510),
		blip = false,
		spawns = {
			vector4(-610.2476, -1597.6298, 26.7510, 73.6367),
			vector4(-610.8818, -1600.6896, 26.7510, 81.7490),
			vector4(-610.0226, -1594.5612, 26.7511, 77.6806),
		}
	},
	{
		id = 'car-gfs-2',
		label = 'GFS 2',
		type = 'car',
		coords = vector3(-582.3173, -1634.0276, 19.6972),
		store = vector3(-576.7150, -1641.5050, 19.4262),
		blip = false,
		spawns = {
			vector4(-589.0639, -1636.7192, 19.9671, 238.3029),
		}
	},
	{
		id = 'car-legerbasis',
		label = 'Legerbasis',
		type = 'car',
		coords = vector3(-2302.4302, 3286.4600, 32.8270),
		store = vector3(-2313.2166, 3277.9104, 32.8269),
		blip = false,
		spawns = {
			vector4(-2309.9812, 3268.6155, 32.3601, 60.8948),
		}
	},
	{
		id = 'car-vuilnis-job',
		label = 'Vuilnis Job',
		type = 'car',
		coords = vector3(-330.21, -1493.96, 30.67),
		store = vector3(-323.48, -1495.60, 30.66),
		spawns = {
			vector4(-330.21, -1493.96, 30.67, 0.35),
		}
	},
	{
		id = 'car-mijnwerker',
		label = 'Mijnwerker',
		type = 'car',
		coords = vector3(807.49, -2023.43, 29.24),
		store = vector3(808.89, -2017.16, 29.25),
		blip = false,
		spawns = {
			vector4(807.49, -2023.43, 29.24, 86.61),
		}
	},
	{
		id = 'car-unmarked-blokkenpart',
		label = 'Unmarked Blokkenpart',
		type = 'car',
		coords = vector3(465.35, -1111.50, 29.20),
		store = vector3(479.05, -1112.83, 29.20),
		spawns = {
			vector4(465.35, -1111.50, 29.20, 175.06),
		}
	},
	{
		id = 'car-gemeentehuis',
		label = 'Gemeentehuis',
		type = 'car',
		coords = vector3(-558.26, -162.41, 38.16),
		store = vector3(-572.75, -168.08, 37.98),
		spawns = {
			vector4(-558.26, -162.41, 38.16, 285.42),
		}
	},
	{
		id = 'car-lsia',
		label = 'LSIA',
		type = 'car',
		coords = vector3(-958.65, -2945.56, 13.95),
		store = vector3(-969.20, -2939.00, 13.95),
		spawns = {
			vector4(-958.65, -2945.56, 13.95, 134.409),
		}
	},
	{
		id = 'car-gevangenis',
		label = 'Gevangenis',
		type = 'car',
		coords = vector3(1853.4948, 2616.6777, 45.6720),
		store = vector3(1862.3777, 2613.7524, 45.6720),
		spawns = {
			vector4(1854.6970, 2620.4663, 45.6720, 267.2097),
			vector4(1854.7621, 2624.0188, 45.6720, 267.2097),
			vector4(1854.9805, 2627.6096, 45.6720, 267.2097),
		}
	},
	{
		id = 'car-vespucci',
		label = 'Vespucci',
		type = 'car',
		coords = vector3(-1160.80, -741.38, 19.64),
		store = vector3(-1144.1489, -758.8185, 18.8389),
		blip = false,
		spawns = {
			vector4(-1144.8943, -745.3440, 19.6847, 104.2876),
			vector4(-1143.4532, -748.4881, 19.5075, 111.1010),
			vector4(-1140.7736, -751.4715, 19.3646, 109.2230),
			vector4(-1135.6366, -757.4587, 19.0649, 108.2254),
			vector4(-1133.4993, -760.3599, 18.9075, 107.1955),
			vector4(-1131.1523, -763.3819, 18.7425, 105.4951),
			vector4(-1186.1373, -742.6299, 20.1058, 306.0945),
		}
	},
	{
		id = 'car-farmer',
		label = 'Farmer',
		type = 'car',
		coords = vector3(74.34, 6350.02, 31.38),
		store = vector3(60.61, 6343.35, 31.23),
		spawns = {
			vector4(46.80, 6364.92, 30.56, 0.0),
		}
	},
	{
		id = 'car-blokkenpark-2',
		label = 'Blokkenpark',
		type = 'car',
		coords = vector3(127.85, -1055.32, 29.20),
		store = vector3(129.4745, -1069.9064, 29.1923),
		spawns = {
			vector4(105.7222, -1063.0082, 29.1923, 241.8553),
			vector4(107.1142, -1059.4025, 29.1923, 240.1088),
			vector4(108.6024, -1056.3364, 29.1923, 244.1176),
			vector4(110.2438, -1052.9524, 29.5328, 253.0041),
			vector4(111.7969, -1049.6509, 29.2127, 245.7878),
			vector4(170.5081, -1080.7959, 29.1928, 355.5078),
			vector4(162.3162, -1081.6973, 29.1929, 357.8204),
			vector4(154.9379, -1081.8539, 29.1924, 358.4811),
			vector4(150.8804, -1081.8918, 29.1926, 357.4568),
			vector4(147.1563, -1081.7411, 29.1924, 354.0339),
			vector4(143.5926, -1081.8785, 29.1924, 358.1599),
			vector4(139.9244, -1082.0396, 29.1932, 359.8092),
			vector4(135.9452, -1081.9086, 29.1937, 355.4557),
			vector4(132.3576, -1081.8009, 29.1937, 356.6260),
			vector4(128.7376, -1081.6858, 29.2122, 356.6260),
			vector4(124.9895, -1081.7274, 29.1932, 359.7612),
			vector4(121.3601, -1081.8768, 29.1931, 354.8054),
			vector4(117.5884, -1081.9034, 29.2214, 359.4566),
			vector4(111.2381, -1081.0308, 29.1924, 333.8557),
			vector4(107.7407, -1080.1135, 29.1928, 334.9133),
			vector4(104.4411, -1078.5557, 29.1924, 337.6587),
		}
	},
	{
		id = 'car-sakura',
		label = 'Sakura',
		type = 'car',
		coords = vector3(24.0502, 540.2344, 176.0275),
		store = vector3(15.7183, 551.7633, 176.6580),
		blip = false,
		spawns = {
			vector4(14.6597, 546.8580, 175.6631, 58.7506),
			vector4(16.5304, 549.4705, 175.8958, 58.7213),
		}
	},
	{
		id = 'car-cjng',
		label = 'CJNG',
		type = 'car',
		coords = vector3(128.6677, 1224.8507, 214.1098),
		store = vector3(126.3779, 1233.9205, 214.1101),
		blip = false,
		spawns = {
			vector4(126.3779, 1233.9205, 214.1101, 282.1463),
		}
	},
	{
		id = 'car-fuerzas-especiales',
		label = 'fuerzas_especiales',
		type = 'car',
		coords = vector3(180.5516, 2785.4490, 46.1372),
		store = vector3(191.7714, 2786.6985, 45.6333),
		blip = false,
		spawns = {
			vector4(191.7714, 2786.6985, 45.6333, 275.5867),
		}
	},
	{
		id = 'car-wapenloods-pro',
		label = 'Wapenloods Pro',
		type = 'car',
		coords = vector3(880.0477, -2343.8799, 30.3731),
		store = vector3(883.6675, -2351.4136, 30.3314),
		blip = false,
		spawns = {
			vector4(883.6675, -2351.4136, 30.3314, 224.7050),
		}
	},
	{
		id = 'car-blockp',
		label = 'BlockP',
		type = 'car',
		coords = vector3(-153.3825, -1544.6427, 34.7488),
		store = vector3(-157.3574, -1546.0874, 34.9572),
		blip = false,
		spawns = {
			vector4(-141.7387, -1555.1509, 34.0012, 318.6375),
		}
	},
	{
		id = 'car-grapeseed-garage',
		label = 'Grapeseed Garage',
		type = 'car',
		coords = vector3(1702.0774, 3604.0918, 35.4204),
		store = vector3(1702.2065, 3598.4290, 35.4452),
		spawns = {
			vector4(1714.0846, 3597.5391, 34.8792, 206.7548),
			vector4(1711.5625, 3596.2803, 34.9870, 206.2818),
		}
	},
	{
		id = 'car-41k-garage',
		label = '41K Garage',
		type = 'car',
		coords = vector3(1028.6071, -2322.8257, 30.5038),
		store = vector3(1021.7188, -2326.0337, 30.5101),
		blip = false,
		spawns = {
			vector4(1020.8085, -2325.7930, 30.0987, 265.7277),
		}
	},
	{
		id = 'car-plezierhaven-garage',
		label = 'Plezierhaven Garage',
		type = 'car',
		coords = vector3(-696.5773, -1407.6406, 5.0007),
		store = vector3(-691.2448, -1417.3922, 4.9604),
		spawns = {
			vector4(-681.1014, -1411.9722, 4.5889, 86.7056),
			vector4(-680.5476, -1403.8029, 4.5890, 87.0028),
		}
	},
	{
		id = 'car-tuneshop-garage',
		label = 'Tuneshop Garage',
		type = 'car',
		coords = vector3(846.0179, -1330.3622, 26.1654),
		store = vector3(851.0748, -1331.9708, 26.1173),
		blip = false,
		spawns = {
			vector4(844.4641, -1334.6061, 25.6937, 246.5593),
			vector4(844.3898, -1340.5310, 25.6549, 245.7818),
		}
	},
	{
		id = 'car-grapeseed-garage-2',
		label = 'Grapeseed Garage 2',
		type = 'car',
		coords = vector3(1691.3511, 4785.0566, 41.9215),
		store = vector3(1693.0571, 4800.9673, 41.8499),
		spawns = {
			vector4(1691.1259, 4778.3701, 41.3489, 90.5028),
			vector4(1690.9944, 4770.2749, 41.3486, 90.5328),
		}
	},
	{
		id = 'car-route-15-garage',
		label = 'Route 15 Garage',
		type = 'car',
		coords = vector3(2582.3462, 462.5514, 108.6046),
		store = vector3(2578.5518, 448.2425, 108.4557),
		spawns = {
			vector4(2579.7036, 438.9535, 108.0436, 1.7698),
			vector4(2588.2239, 446.9761, 108.0440, 90.7931),
		}
	},
	{
		id = 'car-kledingwinkel-noorden-garage',
		label = 'Kledingwinkel Noorden Garage',
		type = 'car',
		coords = vector3(-1137.7023, 2681.6453, 18.1045),
		store = vector3(-1156.0248, 2663.7639, 18.0939),
		blip = false,
		spawns = {
			vector4(-1159.7327, 2674.3018, 17.6814, 222.1723),
			vector4(-1155.0458, 2678.3774, 17.6820, 223.2741),
		}
	},
	{
		id = 'car-vinewood-bowl-garage',
		label = 'Vinewood Bowl Garage',
		type = 'car',
		coords = vector3(646.7017, 585.5181, 128.9107),
		store = vector3(643.4215, 593.1404, 128.9107),
		spawns = {
			vector4(638.2950, 588.6200, 128.5018, 340.1482),
			vector4(650.9712, 597.1042, 128.4994, 70.8680),
		}
	},
	{
		id = 'car-peaky-garage',
		label = 'Peaky Garage',
		type = 'car',
		coords = vector3(-75.9927, 906.7991, 235.8120),
		store = vector3(-72.4248, 907.3963, 235.6165),
		spawns = {
			vector4(-69.9924, 900.3622, 235.1655, 114.0581),
			vector4(-68.5509, 897.7626, 235.1341, 115.6589),
		}
	},
	{
		id = 'car-motel-garage',
		label = 'Motel Garage',
		type = 'car',
		coords = vector3(1140.9324, 2663.7385, 38.1609),
		store = vector3(1137.3988, 2653.1821, 37.9969),
		spawns = {
			vector4(1124.1799, 2647.9587, 37.5841, 0.1631),
			vector4(1131.7068, 2647.6914, 37.5845, 0.7910),
		}
	},
	{
		id = 'car-kortz-center-garage',
		label = 'Kortz Center Garage',
		type = 'car',
		coords = vector3(-2316.9448, 428.7395, 174.4666),
		store = vector3(-2311.4800, 431.2165, 174.4666),
		spawns = {
			vector4(-2316.6226, 435.0108, 174.0543, 353.1275),
			vector4(-2315.1304, 447.9720, 174.0556, 353.5191),
		}
	},
	{
		id = 'car-power-garage',
		label = 'Power Garage',
		type = 'car',
		coords = vector3(2673.6021, 1678.8134, 24.4882),
		store = vector3(2666.8479, 1678.1232, 24.4882),
		spawns = {
			vector4(2673.7285, 1686.2925, 24.0761, 91.7059),
			vector4(2673.9021, 1689.8070, 24.0764, 90.2243),
		}
	},
	{
		id = 'car-ikea-garage',
		label = 'Ikea Garage',
		type = 'car',
		coords = vector3(2749.2544, 3458.0312, 55.9210),
		store = vector3(2752.5691, 3450.7561, 56.0020),
		spawns = {
			vector4(2759.7656, 3450.9243, 55.4752, 67.2935),
			vector4(2756.3481, 3443.4116, 55.6115, 68.2524),
		}
	},
	{
		id = 'car-visser-garage',
		label = 'Visser Garage',
		type = 'car',
		coords = vector3(-1535.7460, 4986.7842, 62.5579),
		store = vector3(-1526.1757, 4996.8750, 62.4964),
		spawns = {
			vector4(-1519.3704, 5004.5342, 62.6043, 317.7249),
			vector4(-1508.1998, 5016.7197, 62.6942, 317.5056),
		}
	},
	{
		id = 'car-tankstation-legerbasis-garage',
		label = 'Tankstation Legerbasis Garage',
		type = 'car',
		coords = vector3(-2537.0745, 2319.4910, 33.2152),
		store = vector3(-2542.5730, 2326.4670, 33.0599),
		spawns = {
			vector4(-2537.7952, 2347.0852, 32.6480, 213.3381),
			vector4(-2534.1218, 2347.2395, 32.6486, 212.7784),
		}
	},
	{
		id = 'car-cartel69-garage',
		label = 'Cartel69 Garage',
		type = 'car',
		coords = vector3(-2188.6702, -370.6825, 13.1033),
		store = vector3(-2188.5620, -378.0760, 13.2021),
		blip = false,
		spawns = {
			vector4(-2185.3943, -369.8335, 12.7151, 168.5105),
			vector4(-2179.4727, -370.4749, 12.7292, 168.6163),
		}
	},
	{
		id = 'car-paleto-snelweg-garage',
		label = 'Paleto Snelweg Garage',
		type = 'car',
		coords = vector3(430.1266, 6542.9805, 27.7750),
		store = vector3(426.0491, 6546.8564, 27.5646),
		blip = false,
		spawns = {
			vector4(426.0491, 6546.8564, 27.5646, 357.6621),
		}
	},
	{
		id = 'car-kingsman-garage',
		label = 'Kingsman Garage',
		type = 'car',
		coords = vector3(-1379.0876, -7.6226, 53.8616),
		store = vector3(-1385.8785, 3.1799, 53.3523),
		blip = false,
		spawns = {
			vector4(-1375.1564, 3.3448, 53.0875, 178.5616),
			vector4(-1369.7222, 0.1446, 53.0870, 178.7518),
			vector4(-1363.0920, -5.0306, 53.0870, 133.0614),
			vector4(-1359.4690, -9.0400, 53.0686, 130.2816),
			vector4(-1359.0692, -19.6715, 52.9390, 53.5436),
			vector4(-1362.3092, -23.3705, 52.8426, 47.3144),
			vector4(-1371.7478, -25.7020, 52.8298, 355.3426),
			vector4(-1377.0387, -25.4572, 52.9034, 353.9024),
			vector4(-1383.6191, -21.6061, 53.0783, 323.7162),
			vector4(-1387.4918, -17.4152, 53.0382, 323.8553),
			vector4(-1390.3215, -12.5336, 52.8874, 323.1216),
		}
	},
	{
		id = 'car-mirrorpark-garage',
		label = 'Mirrorpark Garage',
		type = 'car',
		coords = vector3(1036.2242, -763.2553, 57.9930),
		store = vector3(1046.6799, -790.9714, 57.9896),
		spawns = {
			vector4(1046.4135, -774.6315, 57.6069, 91.4508),
			vector4(1046.2247, -778.3746, 57.5971, 92.7752),
			vector4(1037.8708, -791.2608, 57.5400, 1.7057),
		}
	},
	{
		id = 'car-pitstop-garage',
		label = 'Pitstop Garage',
		type = 'car',
		coords = vector3(797.6722, -1626.2024, 31.164),
		store = vector3(792.8976, -1612.2516, 31.2202),
		spawns = {
			vector4(807.1065, -1622.4501, 30.7814, 68.5173),
			vector4(786.4111, -1624.9548, 30.6138, 331.9890),
		}
	},
	{
		id = 'car-agency-garage',
		label = 'Agency Garage',
		type = 'car',
		coords = vector3(-846.0184, -742.4952, 23.8326),
		store = vector3(-831.0516, -749.1422, 23.1039),
		blip = false,
		spawns = {
			vector4(-829.9359, -756.9658, 21.9553, 90.3017),
			vector4(-810.6788, -757.2084, 21.9033, 91.6985),
		}
	},
	{
		id = 'car-ramenwasser-garage',
		label = 'Ramenwasser Garage',
		type = 'car',
		coords = vector3(-1297.6147, -1250.5348, 4.402),
		store = vector3(-1303.1061, -1252.3495, 4.3861),
		blip = false,
		spawns = {
			vector4(-1308.0471, -1260.7418, 4.1269, 19.7451),
			vector4(-1315.8567, -1263.4534, 4.1631, 20.1840),
		}
	},
	{
		id = 'car-la-spada-garage',
		label = 'La Spada Garage',
		type = 'car',
		coords = vector3(-1064.2551, -1403.2771, 5.4017),
		store = vector3(-1051.8643, -1398.3284, 5.4254),
		spawns = {
			vector4(-1056.3595, -1415.1488, 5.0135, 74.9246),
			vector4(-1070.0286, -1420.9974, 4.9476, 256.5040),
			vector4(-1050.7012, -1428.0605, 5.0146, 255.4303),
			vector4(-1036.8456, -1420.6200, 5.0165, 75.3869),
		}
	},
	{
		id = 'car-merryweather-garage',
		label = 'Merryweather Garage',
		type = 'car',
		coords = vector3(503.1256, -3049.0879, 6.1693),
		store = vector3(527.8630, -3043.3977, 6.0696),
		spawns = {
			vector4(516.7989, -3054.1914, 5.6577, 1.0264),
			vector4(509.9389, -3054.1726, 5.6586, 359.0628),
			vector4(539.8920, -3053.9656, 5.6576, 359.7472),
			vector4(546.4534, -3053.9358, 5.6579, 0.3472),
		}
	},
	{
		id = 'car-merryweather-garage-2',
		label = 'Merryweather Garage',
		type = 'car',
		coords = vector3(1195.0521, -3249.4873, 7.0952),
		store = vector3(1189.3795, -3251.5798, 6.028),
		blip = false,
		spawns = {
			vector4(1189.9059, -3239.7407, 5.6166, 90.6780),
			vector4(1190.1929, -3246.1960, 5.6172, 91.1260),
		}
	},
	{
		id = 'car-uitvalbasis-garage',
		label = 'Uitvalbasis Garage',
		type = 'car',
		coords = vector3(2558.9561, -377.5719, 93.1066),
		store = vector3(2546.7971, -384.4673, 92.9928),
		blip = false,
		spawns = {
			vector4(2548.4341, -378.1677, 92.5808, 166.2311),
			vector4(2551.8765, -390.4940, 92.5810, 9.1048),
		}
	},
	{
		id = 'car-humane-labs-garage',
		label = 'Humane Labs Garage',
		type = 'car',
		coords = vector3(3495.8250, 3785.3826, 30.0721),
		store = vector3(3486.0740, 3787.6084, 30.1683),
		blip = false,
		spawns = {
			vector4(3493.9377, 3779.3140, 29.5188, 168.6906),
			vector4(3501.4878, 3777.3225, 29.5074, 167.4384),
		}
	},
	{
		id = 'car-tankstation-paleto-garage',
		label = 'Tankstation Paleto Garage',
		type = 'car',
		coords = vector3(1698.4260, 6425.5454, 32.7640),
		store = vector3(1714.1699, 6420.0708, 32.9464),
		blip = false,
		spawns = {
			vector4(1718.5377, 6419.0674, 33.0497, 68.1203),
			vector4(1719.8102, 6409.9707, 33.4900, 150.8761),
		}
	},
	{
		id = 'boat-haven',
		label = 'Haven',
		type = 'boat',
		coords = vector3(-721.2983, -1324.5327, 1.5924),
		store = vector3(-711.8947, -1338.3336, 0.5861),
		spawns = {
			vector4(-711.8947, -1338.3336, 0.5861, 227.7727),
		}
	},
	{
		id = 'boat-geen-idee-69',
		label = 'Geen idee 69',
		type = 'boat',
		coords = vector3(-1613.1121, 5260.0693, 3.9741),
		store = vector3(-1636.0697, 5257.4985, 0.1026),
		spawns = {
			vector4(-1636.0697, 5257.4985, 0.1026, 97.8640),
		}
	},
	{
		id = 'boat-reef-boat',
		label = 'Reef boat',
		type = 'boat',
		coords = vector3(-3388.9583, 595.4188, 3.6740),
		store = vector3(-3387.4277, 600.1723, 0.2617),
		blip = false,
		spawns = {
			vector4(-3387.4277, 600.1723, 0.2617, 29.8523),
		}
	},
	{
		id = 'boat-sandy',
		label = 'Sandy',
		type = 'boat',
		coords = vector3(1733.5568, 3984.6890, 31.9787),
		store = vector3(1746.3986, 3995.7263, 30.8539),
		spawns = {
			vector4(1746.3986, 3995.7263, 29.8539, 10.4295),
		}
	},
	{
		id = 'boat-eiland-543',
		label = 'Eiland 543',
		type = 'boat',
		coords = vector3(3837.3059, -43.6907, 2.2809),
		store = vector3(3836.4814, -47.3485, 1.6163),
		blip = false,
		spawns = {
			vector4(3841.2947, -49.2888, 0.5430, 88.6226),
		}
	},
	{
		id = 'boat-capos-island',
		label = 'capos island',
		type = 'boat',
		coords = vector3(-4144.7852, -948.9023, 3.3745),
		store = vector3(-4140.2881, -951.8809, -0.7993),
		blip = false,
		spawns = {
			vector4(-4140.2881, -951.8809, -0.7993, 312.1514),
		}
	},
	{
		id = 'boat-eiland',
		label = 'Eiland',
		type = 'boat',
		coords = vector3(4929.3579, -5173.9307, 2.4616),
		store = vector3(4931.7803, -5167.8994, 0.2969),
		spawns = {
			vector4(4933.9692, -5161.6841, 0.3351, 64.7269),
			vector4(4935.4619, -5158.5483, 0.2996, 63.3829),
		}
	},
	{
		id = 'boat-eiland-2',
		label = 'Eiland',
		type = 'boat',
		coords = vector3(2001.9365, -2853.8767, 2.4472),
		store = vector3(1996.6530, -2860.0200, -0.0350),
		blip = false,
		spawns = {
			vector4(1996.6530, -2860.0200, -0.0350, 118.4899),
		}
	},
	{
		id = 'boat-yacht-sins-boot',
		label = 'Yacht Sins Boot',
		type = 'boat',
		coords = vector3(-2042.3910, -1489.5540, 2.4474),
		store = vector3(-2048.3547, -1485.4792, 0.3260),
		blip = false,
		spawns = {
			vector4(-2048.3547, -1485.4792, 0.3260, 52.1293),
		}
	},
	{
		id = 'boat-merryweather-boot',
		label = 'Merryweather Boot',
		type = 'boat',
		coords = vector3(527.4500, -3127.8455, 6.0698),
		store = vector3(528.2996, -3161.2202, 1.1336),
		blip = false,
		spawns = {
			vector4(528.2996, -3162.2202, -0.1336, 178.0856),
		}
	},
	{
		id = 'aircraft-cova-heli',
		label = 'Cova Heli',
		type = 'aircraft',
		coords = vector3(-1292.6273, -1036.6882, 29.0454),
		store = vector3(-1299.4318, -1038.1011, 29.0454),
		blip = false,
		spawns = {
			vector4(-1299.4318, -1038.1011, 29.0454, 341.3814),
		}
	},
	{
		id = 'aircraft-ira-heli',
		label = 'IRA Heli',
		type = 'aircraft',
		coords = vector3(141.5969, -1327.9226, 31.1891),
		store = vector3(148.3228, -1329.2430, 31.1891),
		blip = false,
		spawns = {
			vector4(148.3228, -1329.2430, 31.1891, 148.1935),
		}
	},
	{
		id = 'aircraft-kmar-garage',
		label = 'KMAR Garage',
		type = 'aircraft',
		coords = vector3(2491.3628, 2604.1445, 44.7429),
		store = vector3(2486.0940, 2603.2515, 44.7492),
		blip = false,
		spawns = {
			vector4(2486.0940, 2603.2515, 44.7492, 93.4656),
		}
	},
	{
		id = 'aircraft-blockp-garage',
		label = 'BlockP Garage',
		type = 'aircraft',
		coords = vector3(-1917.5861, 2078.6633, 140.3827),
		store = vector3(-1951.1477, 2080.2571, 155.9291),
		blip = false,
		spawns = {
			vector4(-1951.1477, 2080.2571, 155.9291, 84.8384),
		}
	},
	{
		id = 'aircraft-veneto-garage',
		label = 'Veneto Garage',
		type = 'aircraft',
		coords = vector3(-3530.7849, 1510.0404, 11.9079),
		store = vector3(-3528.1755, 1514.1698, 12.0352),
		blip = false,
		spawns = {
			vector4(-3528.1755, 1514.1698, 12.0352, 326.6382),
		}
	},
	{
		id = 'aircraft-jacht-heli-garage',
		label = 'Jacht heli Garage',
		type = 'aircraft',
		coords = vector3(-1970.7843, -233.3733, 95.5603),
		store = vector3(-1975.7838, -230.2974, 95.5603),
		blip = false,
		spawns = {
			vector4(-1975.7838, -230.2974, 95.5603, 92.8632),
		}
	},
	{
		id = 'aircraft-cjnx-heli',
		label = 'CJNX Heli',
		type = 'aircraft',
		coords = vector3(216.4350, 1243.4127, 226.4560),
		store = vector3(217.6364, 1249.5123, 226.4560),
		blip = false,
		spawns = {
			vector4(217.6364, 1249.5123, 226.4560, 344.1080),
		}
	},
	{
		id = 'aircraft-braska-garage',
		label = 'Braska Garage',
		type = 'aircraft',
		coords = vector3(-1523.2709, -103.8213, 56.1169),
		store = vector3(-1517.7306, -102.7915, 56.1169),
		blip = false,
		spawns = {
			vector4(-1517.7306, -102.7915, 56.1169, 284.2266),
		}
	},
	{
		id = 'aircraft-14k-garage',
		label = '14K Garage',
		type = 'aircraft',
		coords = vector3(1016.1072, -2308.3821, 32.3104),
		store = vector3(1010.6282, -2305.3345, 32.3104),
		blip = false,
		spawns = {
			vector4(1010.6282, -2305.3345, 32.3104, 62.9813),
		}
	},
	{
		id = 'aircraft-albanese-garage',
		label = 'Albanese Garage',
		type = 'aircraft',
		coords = vector3(-46.8061, 867.8976, 234.0696),
		store = vector3(-40.0057, 870.1046, 234.0696),
		blip = false,
		spawns = {
			vector4(-40.0057, 870.1046, 234.0696, 276.8097),
		}
	},
	{
		id = 'aircraft-garage-sakura',
		label = 'Garage Sakura',
		type = 'aircraft',
		coords = vector3(23.0387, 513.7013, 172.4626),
		store = vector3(28.0227, 508.4239, 172.4626),
		blip = false,
		spawns = {
			vector4(28.1308, 508.3292, 172.4626, 229.4749),
		}
	},
	{
		id = 'aircraft-narkoz',
		label = 'Narkoz',
		type = 'aircraft',
		coords = vector3(-1161.9634, -1391.5201, 19.5788),
		store = vector3(-1168.4482, -1393.1710, 19.5788),
		blip = false,
		spawns = {
			vector4(-1168.4482, -1393.1710, 19.5788, 102.6806),
		}
	},
	{
		id = 'aircraft-isla-de-la-magia',
		label = 'Isla de la Magia',
		type = 'aircraft',
		coords = vector3(-3212.4800, -1414.8835, 7.6902),
		store = vector3(-3217.9045, -1419.3119, 6.6902),
		blip = false,
		spawns = {
			vector4(-3217.2676, -1418.5720, 7.6902, 119.8007),
		}
	},
	{
		id = 'aircraft-scarface',
		label = 'Scarface',
		type = 'aircraft',
		coords = vector3(692.2125, 3438.8418, 57.8249),
		store = vector3(686.1191, 3436.4204, 57.8249),
		blip = false,
		spawns = {
			vector4(686.1191, 3436.4204, 57.8249, 192.5689),
		}
	},
	{
		id = 'aircraft-rdmc-heli',
		label = 'rdmc heli',
		type = 'aircraft',
		coords = vector3(1937.2025, 4657.5845, 41.7248),
		store = vector3(1933.3094, 4663.6606, 41.7248),
		blip = false,
		spawns = {
			vector4(1933.3094, 4663.6606, 41.7248, 15.1961),
		}
	},
	{
		id = 'aircraft-airport',
		label = 'Airport',
		type = 'aircraft',
		coords = vector3(375.0334, 35.1371, 94.1497),
		store = vector3(380.4163, 35.3977, 94.1497),
		blip = false,
		spawns = {
			vector4(380.4163, 35.3977, 94.1497, 271.9752),
		}
	},
	{
		id = 'aircraft-peaky-heli',
		label = 'Peaky Heli',
		type = 'aircraft',
		coords = vector3(3491.3098, 4920.0610, 35.3680),
		store = vector3(3492.9983, 4916.3413, 35.3599),
		blip = false,
		spawns = {
			vector4(3492.9983, 4916.3413, 35.3599, 218.2617),
		}
	},
	{
		id = 'aircraft-weedshop-heli',
		label = 'weedshop Heli',
		type = 'aircraft',
		coords = vector3(184.5565, -241.7635, 67.6032),
		store = vector3(191.4773, -242.0000, 67.6032),
		blip = false,
		spawns = {
			vector4(191.4773, -242.0000, 67.6032, 251.4403),
		}
	},
	{
		id = 'aircraft-reef-heli',
		label = 'Reef Heli',
		type = 'aircraft',
		coords = vector3(-3420.8394, 535.7736, 10.5777),
		store = vector3(-3429.9587, 542.2723, 12.4519),
		blip = false,
		spawns = {
			vector4(-3429.9587, 542.2723, 12.4519, 232.0739),
		}
	},
	{
		id = 'aircraft-cjnx-heli-2',
		label = 'CJNX heli',
		type = 'aircraft',
		coords = vector3(3821.4243, 32.4455, 15.9398),
		store = vector3(3810.5774, 32.3625, 17.7516),
		blip = false,
		spawns = {
			vector4(3810.5774, 32.3625, 17.7516, 0.0),
		}
	},
	{
		id = 'aircraft-grapeseed-airport',
		label = 'Grapeseed Airport',
		type = 'aircraft',
		coords = vector3(2124.9836, 4790.6426, 41.1159),
		store = vector3(2118.4966, 4801.5171, 41.1823),
		spawns = {
			vector4(2118.4966, 4801.5171, 41.1823, 112.6030),
		}
	},
	{
		id = 'aircraft-eiland-54',
		label = 'Eiland 54',
		type = 'aircraft',
		coords = vector3(-442.3351, 1140.3307, 325.8558),
		store = vector3(-453.4306, 1143.4545, 327.6880),
		blip = false,
		spawns = {
			vector4(-453.4306, 1143.4545, 327.6880, 253.7554),
		}
	},
	{
		id = 'aircraft-sandy-airport',
		label = 'Sandy Airport',
		type = 'aircraft',
		coords = vector3(1713.06, 3255.3, 41.0),
		store = vector3(-1643.80, -3137.26, 13.96),
		spawns = {
			vector4(1688.3539, 3249.9692, 40.8581, 98.1830),
		}
	},
	{
		id = 'aircraft-airport-2',
		label = 'Airport',
		type = 'aircraft',
		coords = vector3(-1651.6151, -3131.1924, 13.9922),
		store = vector3(-1643.80, -3137.26, 13.96),
		spawns = {
			vector4(-1626.4120, -3099.2419, 13.9315, 331.1998),
		}
	},
	{
		id = 'aircraft-krips-heli',
		label = 'Krips Heli',
		type = 'aircraft',
		coords = vector3(-3036.2156, 113.6322, 13.4711),
		store = vector3(-3042.2358, 116.0614, 13.4711),
		blip = false,
		spawns = {
			vector4(-3042.2358, 116.0614, 13.4711, 52.3132),
		}
	},
	{
		id = 'aircraft-zone6',
		label = 'Zone6',
		type = 'aircraft',
		coords = vector3(-1597.0995, 106.3207, 60.7759),
		store = vector3(-1607.8843, 104.3928, 62.7249),
		blip = false,
		spawns = {
			vector4(-1608.8545, 104.2916, 62.7249, 286.5683),
		}
	},
	{
		id = 'aircraft-capos-island-heli',
		label = 'Capos island Heli',
		type = 'aircraft',
		coords = vector3(-4171.4253, -977.7098, 5.8727),
		store = vector3(-4161.7583, -981.5222, 7.3791),
		blip = false,
		spawns = {
			vector4(-4161.7583, -981.5222, 7.3791, 68.6004),
		}
	},
	{
		id = 'aircraft-young-gunners-heli',
		label = 'Young Gunners Heli',
		type = 'aircraft',
		coords = vector3(-1559.3242, 825.2796, 186.6484),
		store = vector3(-1559.3850, 831.3118, 186.6484),
		blip = false,
		spawns = {
			vector4(-1559.3850, 831.3214, 186.6422, 333.7621),
		}
	},
	{
		id = 'aircraft-familieak-heli',
		label = 'Familieak Heli',
		type = 'aircraft',
		coords = vector3(-1576.9775, -1.1870, 61.0558),
		store = vector3(-1569.4174, 3.7841, 59.9993),
		blip = false,
		spawns = {
			vector4(-1569.4174, 3.7841, 59.9993, 259.0003),
		}
	},
	{
		id = 'aircraft-saints-heli',
		label = 'Saints Heli',
		type = 'aircraft',
		coords = vector3(-1147.9705, -1528.7130, 15.5577),
		store = vector3(-1150.2201, -1522.5128, 15.5577),
		blip = false,
		spawns = {
			vector4(-1150.2201, -1522.5128, 15.5577, 33.1043),
		}
	},
	{
		id = 'aircraft-gsf-heli',
		label = 'GSF Heli',
		type = 'aircraft',
		coords = vector3(-629.9698, -1650.3940, 27.7010),
		store = vector3(-631.3541, -1656.8840, 27.7010),
		blip = false,
		spawns = {
			vector4(-631.3541, -1656.8840, 27.7010, 150.5296),
		}
	},
	{
		id = 'aircraft-netras-heli',
		label = 'Netras Heli',
		type = 'aircraft',
		coords = vector3(1439.2413, 1114.4460, 114.1662),
		store = vector3(1461.0116, 1111.5052, 113.9911),
		blip = false,
		spawns = {
			vector4(1461.0116, 1111.5052, 114.9911, 270.3765),
		}
	},
	{
		id = 'aircraft-bloods-heli',
		label = 'Bloods Heli',
		type = 'aircraft',
		coords = vector3(101.3759, -1988.2948, 20.6200),
		store = vector3(99.6000, -1999.7781, 22.7234),
		blip = false,
		spawns = {
			vector4(99.6000, -1999.7781, 22.7234, 345.4607),
		}
	},
	{
		id = 'aircraft-oak-heli',
		label = 'OAK Heli',
		type = 'aircraft',
		coords = vector3(-3262.2476, 817.9698, 8.5890),
		store = vector3(-3268.5640, 816.7012, 8.5890),
		blip = false,
		spawns = {
			vector4(-3268.5640, 816.7012, 8.5890, 340.0587),
		}
	},
	{
		id = 'aircraft-dtmc-heli',
		label = 'DTMC Heli',
		type = 'aircraft',
		coords = vector3(175.7050, 329.0343, 117.3364),
		store = vector3(176.1379, 335.6595, 117.3364),
		blip = false,
		spawns = {
			vector4(176.1379, 335.6595, 117.3364, 69.0339),
		}
	},
	{
		id = 'aircraft-yacht-heli',
		label = 'yacht Heli',
		type = 'aircraft',
		coords = vector3(-339.2505, -3531.7349, 11.9078),
		store = vector3(-336.5380, -3527.3901, 12.0352),
		blip = false,
		spawns = {
			vector4(-336.5380, -3527.3901, 12.0352, 330.5720),
		}
	},
	{
		id = 'aircraft-yacht-sins-heli',
		label = 'yacht Sins Heli',
		type = 'aircraft',
		coords = vector3(-2016.5472, -1509.8794, 11.8721),
		store = vector3(-2020.2996, -1506.8760, 12.0352),
		blip = false,
		spawns = {
			vector4(-2020.2996, -1506.8760, 12.0352, 50.2505),
		}
	},
	{
		id = 'aircraft-yacht-sins-heli-2',
		label = 'yacht Sins Heli 2',
		type = 'aircraft',
		coords = vector3(-1973.9468, -1549.1578, 8.9715),
		store = vector3(-1968.7289, -1547.3696, 10.2582),
		blip = false,
		spawns = {
			vector4(-1968.7289, -1547.3696, 10.2582, 228.0858),
		}
	},
	{
		id = 'aircraft-dias-cartel-heli',
		label = 'Dias Cartel Heli',
		type = 'aircraft',
		coords = vector3(-1778.7806, 409.2689, 113.6526),
		store = vector3(-1797.1522, 395.6333, 112.7884),
		blip = false,
		spawns = {
			vector4(-1797.1522, 395.6333, 112.7884, 263.0256),
		}
	},
	{
		id = 'aircraft-no-surrender-heli',
		label = 'No Surrender Heli',
		type = 'aircraft',
		coords = vector3(1294.4806, -842.5297, 79.6162),
		store = vector3(1284.9169, -842.9295, 78.4600),
		blip = false,
		spawns = {
			vector4(1284.9169, -842.9295, 78.4600, 255.6163),
		}
	},
	{
		id = 'aircraft-sinadra-heli',
		label = 'sinadra Heli',
		type = 'aircraft',
		coords = vector3(-124.7123, 963.5930, 236.2663),
		store = vector3(-116.9768, 962.6277, 236.3372),
		blip = false,
		spawns = {
			vector4(-116.9768, 962.6277, 236.3372, 181.0312),
		}
	},
	{
		id = 'aircraft-terico-heli',
		label = 'Terico Heli',
		type = 'aircraft',
		coords = vector3(-2768.9077, 1472.7126, 103.7910),
		store = vector3(-2768.9077, 1472.7126, 103.7910),
		blip = false,
		spawns = {
			vector4(-2768.9077, 1472.7126, 103.7910, 269.6602),
		}
	},
	{
		id = 'aircraft-armeense-heli',
		label = 'Armeense Heli',
		type = 'aircraft',
		coords = vector3(-885.2966, -38.4577, 39.4407),
		store = vector3(-891.8865, -39.6089, 39.4407),
		blip = false,
		spawns = {
			vector4(-891.8865, -39.6089, 39.4407, 297.6241),
		}
	},
	{
		id = 'aircraft-grapeseed-airport-2',
		label = 'Grapeseed Airport',
		type = 'aircraft',
		coords = vector3(2101.86, 4760.61, 41.12),
		store = vector3(2109.44, 4767.86, 41.16),
		blip = false,
		spawns = {
			vector4(2101.86, 4760.61, 41.12, 180.00),
		}
	},
	{
		id = 'aircraft-dock-heliport',
		label = 'Dock Heliport',
		type = 'aircraft',
		coords = vector3(-681.66, -1433.56, 4.79),
		store = vector3(-744.5399, -1468.5536, 5.0007),
		spawns = {
			vector4(-724.8339, -1444.0179, 4.9944, 63.8569),
		}
	},
	{
		id = 'aircraft-eiland',
		label = 'Eiland',
		type = 'aircraft',
		coords = vector3(4455.0918, -4478.7490, 4.2579),
		store = vector3(4450.1899, -4505.7227, 4.1909),
		spawns = {
			vector4(4425.8457, -4514.4902, 4.1706, 107.8895),
			vector4(4393.1279, -4524.8335, 4.1619, 108.0511),
		}
	},
	{
		id = 'aircraft-geen-idee',
		label = 'Geen Idee',
		type = 'aircraft',
		coords = vector3(-121.5022, 345.6424, 112.8809),
		store = vector3(-111.8845, 355.2756, 111.7273),
		blip = false,
		spawns = {
			vector4(-113.0115, 354.9928, 112.7268, 317.5135),
		}
	},
	{
		id = 'aircraft-yacht-1',
		label = 'Yacht 1',
		type = 'aircraft',
		coords = vector3(-3145.2473, 2777.7019, 12.0352),
		store = vector3(-3145.2473, 2777.7019, 12.0352),
		blip = false,
		spawns = {
			vector4(-3145.2473, 2777.7019, 12.0352, 185.1160),
		}
	},
	{
		id = 'aircraft-yacht-2',
		label = 'Yacht 2',
		type = 'aircraft',
		coords = vector3(-3147.7190, 2843.4375, 10.2582),
		store = vector3(-3147.7190, 2843.4375, 10.2582),
		blip = false,
		spawns = {
			vector4(-3147.7190, 2843.4375, 10.2582, 12.9265),
		}
	},
	{
		id = 'aircraft-aircraft-carrier',
		label = 'Aircraft Carrier',
		type = 'aircraft',
		coords = vector3(3072.4783, -4721.1855, 15.2623),
		store = vector3(3059.0574, -4722.6172, 15.2616),
		spawns = {
			vector4(3059.0574, -4722.6172, 15.2616, 51.4158),
		}
	},
	{
		id = 'aircraft-hells-vultures',
		label = 'Hells Vultures',
		type = 'aircraft',
		coords = vector3(1028.5082, -2502.4780, 30.2739),
		store = vector3(1036.6688, -2496.8274, 30.2484),
		blip = false,
		spawns = {
			vector4(1036.2961, -2496.7397, 30.9296, 85.9462),
		}
	},
	{
		id = 'aircraft-zoraz',
		label = 'Zoraz',
		type = 'aircraft',
		coords = vector3(302.9168, -2772.2268, 6.1239),
		store = vector3(295.6580, -2773.4326, 5.6575),
		blip = false,
		spawns = {
			vector4(295.6580, -2773.4326, 6.6575, 168.3382),
		}
	},
	{
		id = 'aircraft-prive-eiland',
		label = 'Prive Eiland',
		type = 'aircraft',
		coords = vector3(-4763.2759, -58.4458, 7.3402),
		store = vector3(-4769.1040, -54.8058, 7.3402),
		blip = false,
		spawns = {
			vector4(-4769.1040, -54.8058, 7.3402, 322.5606),
		}
	},
	{
		id = 'aircraft-prive-eiland-2',
		label = 'Prive Eiland',
		type = 'aircraft',
		coords = vector3(1237.9318, -406.5241, 68.9698),
		store = vector3(1243.7494, -408.7895, 69.0379),
		blip = false,
		spawns = {
			vector4(1244.7343, -407.6776, 69.7341, 205.0007),
		}
	},
	{
		id = 'aircraft-satudaraks-mc',
		label = 'SatudarakS MC',
		type = 'aircraft',
		coords = vector3(-2202.2305, 4255.4287, 49.1447),
		store = vector3(-2203.3538, 4246.9790, 49.0235),
		blip = false,
		spawns = {
			vector4(-2203.2493, 4245.0410, 49.6796, 4.0137),
		}
	},
	{
		id = 'aircraft-lafamiliazeta-heli',
		label = 'lafamiliazeta Heli',
		type = 'aircraft',
		coords = vector3(-2547.2209, 1870.0094, 166.5521),
		store = vector3(-2556.6479, 1865.0365, 168.1030),
		blip = false,
		spawns = {
			vector4(-2556.5957, 1865.0500, 168.7839, 308.9567),
		}
	},
	{
		id = 'aircraft-sins-heli',
		label = 'Sins Heli',
		type = 'aircraft',
		coords = vector3(966.4465, -106.1891, 82.6727),
		store = vector3(960.2491, -111.8731, 82.6283),
		blip = false,
		spawns = {
			vector4(960.2491, -111.8731, 82.6283, 119.6197),
		}
	},
	{
		id = 'aircraft-yaruka-heli',
		label = 'Yaruka Heli',
		type = 'aircraft',
		coords = vector3(-162.8023, 317.4484, 103.1495),
		store = vector3(-152.0783, 317.1978, 104.9442),
		blip = false,
		spawns = {
			vector4(-152.0783, 317.1978, 104.9442, 89.7870),
		}
	},
	{
		id = 'aircraft-gsf-heli-2',
		label = 'GSF Heli',
		type = 'aircraft',
		coords = vector3(509.1612, -1969.3101, 38.7604),
		store = vector3(516.2313, -1957.2140, 38.7604),
		blip = false,
		spawns = {
			vector4(516.2313, -1957.2140, 38.7604, 302.4956),
		}
	},
	{
		id = 'aircraft-netras-heli-2',
		label = 'Netras Heli',
		type = 'aircraft',
		coords = vector3(1493.5575, 1069.0127, 116.1957),
		store = vector3(1486.3979, 1066.6554, 116.1900),
		blip = false,
		spawns = {
			vector4(1486.3979, 1066.6554, 116.1900, 91.2535),
		}
	},
	{
		id = 'aircraft-diazcartel-heli',
		label = 'diazcartel Heli',
		type = 'aircraft',
		coords = vector3(-1800.6057, 451.2082, 128.5150),
		store = vector3(-1805.4626, 456.4495, 128.2842),
		blip = false,
		spawns = {
			vector4(-1806.3375, 456.7913, 128.9623, 270.3774),
		}
	},
	{
		id = 'aircraft-cartel69-heli',
		label = 'cartel69 Heli',
		type = 'aircraft',
		coords = vector3(-2165.9270, -407.0699, 15.256),
		store = vector3(-2159.7917, -410.3852, 15.2563),
		blip = false,
		spawns = {
			vector4(-2159.8845, -410.3962, 15.9373, 224.5937),
		}
	},
	{
		id = 'aircraft-roztheacartel-heli',
		label = 'Roztheacartel Heli',
		type = 'aircraft',
		coords = vector3(-1447.1396, -370.9222, 43.4891),
		store = vector3(-1449.8824, -359.9711, 43.8026),
		blip = false,
		spawns = {
			vector4(-1449.8824, -359.9711, 43.8026, 317.9319),
		}
	},
	{
		id = 'aircraft-yacht-alba-heli',
		label = 'yacht alba Heli',
		type = 'aircraft',
		coords = vector3(2028.0854, -2835.0037, 11.9078),
		store = vector3(2025.6526, -2839.0293, 12.0352),
		blip = false,
		spawns = {
			vector4(2025.6526, -2839.0293, 12.0352, 121.2730),
		}
	},
	{
		id = 'aircraft-gulf-cartel-heli',
		label = 'Gulf Cartel Heli',
		type = 'aircraft',
		coords = vector3(4895.6909, -5747.4053, 26.3509),
		store = vector3(4890.5249, -5736.6729, 26.3509),
		blip = false,
		spawns = {
			vector4(4890.5249, -5736.6729, 26.3509, 342.7598),
		}
	},
	{
		id = 'aircraft-yacht-heli-2',
		label = 'Yacht Heli',
		type = 'aircraft',
		coords = vector3(-2048.3809, -1032.0354, 11.9087),
		store = vector3(-2044.0347, -1031.4117, 11.9807),
		blip = false,
		spawns = {
			vector4(-2044.0347, -1031.4117, 11.9807, 251.1175),
		}
	},
	{
		id = 'aircraft-merryweather-heli',
		label = 'Merryweather Heli',
		type = 'aircraft',
		coords = vector3(487.4003, -3361.0649, 6.0699),
		store = vector3(478.4610, -3369.8806, 6.0699),
		blip = false,
		spawns = {
			vector4(478.4624, -3369.8799, 6.0699, 179.2870),
		}
	},
	{
		id = 'aircraft-kingsman-heli',
		label = 'Kingsman Heli',
		type = 'aircraft',
		coords = vector3(-1338.8364, 125.7608, 58.1630),
		store = vector3(-1331.7349, 127.1379, 58.1630),
		blip = false,
		spawns = {
			vector4(-1331.7349, 127.1379, 58.1630, 269.5447),
		}
	},
	{
		id = 'aircraft-athena-heli',
		label = 'Athena Heli',
		type = 'aircraft',
		coords = vector3(-920.4070, 55.3060, 49.5912),
		store = vector3(-925.5339, 61.6987, 50.4479),
		blip = false,
		spawns = {
			vector4(-925.5339, 61.6987, 50.4479, 227.459),
		}
	},
}
