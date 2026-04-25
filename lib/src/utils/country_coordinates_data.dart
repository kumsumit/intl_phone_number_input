class CountryCoordinates {
  final double latitude;
  final double longitude;

  const CountryCoordinates({required this.latitude, required this.longitude});
}

const countryCoordinates = <String, CountryCoordinates>{
  'AD': CountryCoordinates(latitude: 42.54071670051963, longitude: 1.5732033),
  'AF': CountryCoordinates(latitude: 33.76800649959523, longitude: 66.2385139),
  'AL': CountryCoordinates(latitude: 41.00002800039216, longitude: 19.9999619),
  'AM': CountryCoordinates(latitude: 40.76962720036561, longitude: 44.6736646),
  'AO': CountryCoordinates(latitude: -11.87757680009983, longitude: 17.5691241),
  'AR': CountryCoordinates(
    latitude: -34.99649629988816,
    longitude: -64.9672817,
  ),
  'AT': CountryCoordinates(
    latitude: 47.200000000119395,
    longitude: 13.199999999999998,
  ),
  'AU': CountryCoordinates(latitude: -24.77610859981175, longitude: 134.755),
  'AZ': CountryCoordinates(
    latitude: 40.100774300280115,
    longitude: 47.24248585,
  ),
  'BA': CountryCoordinates(latitude: 44.305347600519575, longitude: 17.5961467),
  'BD': CountryCoordinates(latitude: 24.476878300299845, longitude: 90.2932426),
  'BE': CountryCoordinates(latitude: 50.64028089931601, longitude: 4.6667145),
  'BF': CountryCoordinates(
    latitude: 12.075308299587288,
    longitude: -1.6880313999999998,
  ),
  'BG': CountryCoordinates(latitude: 42.60739750052276, longitude: 25.4856617),
  'BI': CountryCoordinates(
    latitude: -3.3634356997313652,
    longitude: 29.887057499999997,
  ),
  'BJ': CountryCoordinates(
    latitude: 9.52934719941766,
    longitude: 2.2584407999999994,
  ),
  'BN': CountryCoordinates(latitude: 4.413715499552055, longitude: 114.5653908),
  'BO': CountryCoordinates(
    latitude: -17.05686960047022,
    longitude: -64.99122859999999,
  ),
  'BR': CountryCoordinates(latitude: -10.333333299946492, longitude: -53.2),
  'BS': CountryCoordinates(
    latitude: 24.773654600276785,
    longitude: -78.00005469999999,
  ),
  'BT': CountryCoordinates(latitude: 27.549510999996667, longitude: 90.5119273),
  'BW': CountryCoordinates(
    latitude: -23.168178200043872,
    longitude: 24.5928742,
  ),
  'BY': CountryCoordinates(latitude: 53.425060499112625, longitude: 27.6971358),
  'BZ': CountryCoordinates(latitude: 16.82597930011683, longitude: -88.7600927),
  'CA': CountryCoordinates(
    latitude: 61.066692201747934,
    longitude: -107.991707,
  ),
  'CD': CountryCoordinates(
    latitude: -2.9814343997517234,
    longitude: 23.822263600000003,
  ),
  'CF': CountryCoordinates(latitude: 7.032359799404397, longitude: 19.9981227),
  'CH': CountryCoordinates(latitude: 46.79856240020171, longitude: 8.2319736),
  'CI': CountryCoordinates(latitude: 7.989737099390447, longitude: -5.5679458),
  'CK': CountryCoordinates(
    latitude: -16.049278100439054,
    longitude: -160.355485,
  ),
  'CL': CountryCoordinates(
    latitude: -31.761336499388936,
    longitude: -71.3187697,
  ),
  'CM': CountryCoordinates(latitude: 4.612552199536013, longitude: 13.1535811),
  'CN': CountryCoordinates(latitude: 35.00007399965166, longitude: 104.999927),
  'CO': CountryCoordinates(latitude: 2.889443399693678, longitude: -73.783892),
  'CR': CountryCoordinates(
    latitude: 10.273563299452295,
    longitude: -84.0739102,
  ),
  'CU': CountryCoordinates(latitude: 23.01313380038352, longitude: -80.8328748),
  'CV': CountryCoordinates(
    latitude: 16.000055200024498,
    longitude: -24.008394699999997,
  ),
  'CY': CountryCoordinates(latitude: 35.10341654965907, longitude: 33.3851832),
  'CZ': CountryCoordinates(
    latitude: 49.81670029949451,
    longitude: 15.474954399999998,
  ),
  'DE': CountryCoordinates(latitude: 51.08341959923527, longitude: 10.4234469),
  'DJ': CountryCoordinates(latitude: 11.8145965995638, longitude: 42.8453061),
  'DK': CountryCoordinates(
    latitude: 55.67024899965357,
    longitude: 10.333328299999998,
  ),
  'DO': CountryCoordinates(
    latitude: 19.097403100321152,
    longitude: -70.30280260000002,
  ),
  'DZ': CountryCoordinates(latitude: 28.000027199946235, longitude: 2.9999825),
  'EC': CountryCoordinates(
    latitude: -1.3397667998718783,
    longitude: -79.3666965,
  ),
  'EE': CountryCoordinates(latitude: 58.75237780115055, longitude: 25.3319078),
  'EG': CountryCoordinates(
    latitude: 26.254049300138135,
    longitude: 29.267546900000003,
  ),
  'ER': CountryCoordinates(latitude: 15.950031900018738, longitude: 37.9999668),
  'ES': CountryCoordinates(
    latitude: 39.326068500172966,
    longitude: -4.837979099999999,
  ),
  'ET': CountryCoordinates(latitude: 10.211670199448909, longitude: 38.6521203),
  'FI': CountryCoordinates(
    latitude: 63.24677770079637,
    longitude: 25.920916399999996,
  ),
  'FJ': CountryCoordinates(
    latitude: -18.12396960047183,
    longitude: 179.01227369999998,
  ),
  'FM': CountryCoordinates(latitude: 5.560056499469512, longitude: 150.1982846),
  'FO': CountryCoordinates(latitude: 62.044872401539735, longitude: -7.0322972),
  'FR': CountryCoordinates(latitude: 46.60335400023912, longitude: 1.8883335),
  'GA': CountryCoordinates(
    latitude: -0.8999694999115962,
    longitude: 11.6899699,
  ),
  'GB': CountryCoordinates(latitude: 54.70235449933597, longitude: -3.2765753),
  'GE': CountryCoordinates(
    latitude: 42.39287590050311,
    longitude: 43.11888776666666,
  ),
  'GG': CountryCoordinates(
    latitude: 49.45662329958024,
    longitude: -2.5822347999999997,
  ),
  'GH': CountryCoordinates(latitude: 8.030028399390375, longitude: -1.0800271),
  'GL': CountryCoordinates(latitude: 77.619234902968, longitude: -42.8125967),
  'GM': CountryCoordinates(
    latitude: 13.470061999730191,
    longitude: -15.4900464,
  ),
  'GN': CountryCoordinates(
    latitude: 10.722622599479545,
    longitude: -10.7083587,
  ),
  'GQ': CountryCoordinates(latitude: 1.6131719998282976, longitude: 10.5170357),
  'GR': CountryCoordinates(latitude: 38.99536830012524, longitude: 21.9877132),
  'GT': CountryCoordinates(latitude: 15.63560879998218, longitude: -89.8988087),
  'GW': CountryCoordinates(
    latitude: 12.10003499958958,
    longitude: -14.900021399999996,
  ),
  'HN': CountryCoordinates(
    latitude: 15.257243199937683,
    longitude: -86.0755145,
  ),
  'HR': CountryCoordinates(
    latitude: 45.56434420040462,
    longitude: 17.011895399999997,
  ),
  'HT': CountryCoordinates(
    latitude: 19.13999520032402,
    longitude: -72.35709719999998,
  ),
  'HU': CountryCoordinates(
    latitude: 47.18175850012328,
    longitude: 19.506093699999997,
  ),
  'ID': CountryCoordinates(
    latitude: -5.499290249788538,
    longitude: 121.86393045,
  ),
  'IE': CountryCoordinates(
    latitude: 52.8651959990849,
    longitude: -7.979459900000001,
  ),
  'IL': CountryCoordinates(latitude: 31.53131129962957, longitude: 34.8667654),
  'IM': CountryCoordinates(latitude: 54.19368049921973, longitude: -4.5591148),
  'IN': CountryCoordinates(latitude: 22.351114800402986, longitude: 78.6677428),
  'IQ': CountryCoordinates(latitude: 33.09557929958744, longitude: 44.1749775),
  'IR': CountryCoordinates(
    latitude: 32.647531399591166,
    longitude: 54.564351599999995,
  ),
  'IS': CountryCoordinates(
    latitude: 64.98418209894021,
    longitude: -18.105901299999996,
  ),
  'IT': CountryCoordinates(
    latitude: 42.638426100524136,
    longitude: 12.674296999999996,
  ),
  'JE': CountryCoordinates(
    latitude: 49.22145609963767,
    longitude: -2.1358385999999996,
  ),
  'JM': CountryCoordinates(
    latitude: 18.18505070025032,
    longitude: -77.39476929999998,
  ),
  'JO': CountryCoordinates(latitude: 31.16670489965039, longitude: 36.941628),
  'JP': CountryCoordinates(latitude: 36.57484409979729, longitude: 139.2394179),
  'KE': CountryCoordinates(latitude: 1.4419682998467824, longitude: 38.4313975),
  'KG': CountryCoordinates(latitude: 41.50893240044474, longitude: 74.724091),
  'KH': CountryCoordinates(latitude: 13.506639399734253, longitude: 104.869423),
  'KI': CountryCoordinates(
    latitude: -3.400163099729576,
    longitude: -170.30240499999996,
  ),
  'KM': CountryCoordinates(
    latitude: -12.204517600132862,
    longitude: 44.2832964,
  ),
  'KP': CountryCoordinates(
    latitude: 40.37366110031666,
    longitude: 127.08704169999996,
  ),
  'KR': CountryCoordinates(
    latitude: 36.63839199980464,
    longitude: 127.69611879999997,
  ),
  'KZ': CountryCoordinates(
    latitude: 47.22860860011326,
    longitude: 65.20931969999998,
  ),
  'LA': CountryCoordinates(latitude: 20.017110900373176, longitude: 103.378253),
  'LB': CountryCoordinates(latitude: 33.87506289959798, longitude: 35.843409),
  'LI': CountryCoordinates(latitude: 47.14163070013177, longitude: 9.5531527),
  'LK': CountryCoordinates(latitude: 7.555494199393871, longitude: 80.7137847),
  'LR': CountryCoordinates(
    latitude: 5.749972099458349,
    longitude: -9.365852399999998,
  ),
  'LS': CountryCoordinates(
    latitude: -29.603926699324624,
    longitude: 28.3350193,
  ),
  'LT': CountryCoordinates(latitude: 55.35000029953515, longitude: 23.7499997),
  'LU': CountryCoordinates(
    latitude: 49.8158682994947,
    longitude: 6.129675100000001,
  ),
  'LV': CountryCoordinates(
    latitude: 56.84064940017825,
    longitude: 24.753764499999996,
  ),
  'LY': CountryCoordinates(latitude: 26.823447200077258, longitude: 18.1236723),
  'MA': CountryCoordinates(
    latitude: 31.17282049965,
    longitude: -7.336248200000001,
  ),
  'MC': CountryCoordinates(latitude: 43.73234920053946, longitude: 7.4276832),
  'MD': CountryCoordinates(latitude: 47.28796080010045, longitude: 28.5670941),
  'ME': CountryCoordinates(latitude: 42.98688530053623, longitude: 19.5180992),
  'MG': CountryCoordinates(
    latitude: -18.924960400450463,
    longitude: 46.4416422,
  ),
  'MH': CountryCoordinates(latitude: 6.951874199406627, longitude: 170.9985095),
  'MK': CountryCoordinates(latitude: 41.61712140045473, longitude: 21.7168387),
  'ML': CountryCoordinates(latitude: 16.370035900066604, longitude: -2.2900239),
  'MM': CountryCoordinates(latitude: 17.17504950015371, longitude: 95.9999652),
  'MN': CountryCoordinates(
    latitude: 46.82503880019649,
    longitude: 103.84997359999998,
  ),
  'MR': CountryCoordinates(latitude: 20.25403820038309, longitude: -9.2399263),
  'MT': CountryCoordinates(
    latitude: 35.888599299724646,
    longitude: 14.447691099999998,
  ),
  'MU': CountryCoordinates(
    latitude: -20.275945100370553,
    longitude: 57.5703566,
  ),
  'MV': CountryCoordinates(latitude: 4.706435199528674, longitude: 73.3287853),
  'MW': CountryCoordinates(
    latitude: -13.268720400237092,
    longitude: 33.9301963,
  ),
  'MX': CountryCoordinates(
    latitude: 22.500048500399664,
    longitude: -100.000037,
  ),
  'MY': CountryCoordinates(
    latitude: 4.569375399539441,
    longitude: 102.26568229999998,
  ),
  'MZ': CountryCoordinates(
    latitude: -19.30223300043362,
    longitude: 34.91449769999999,
  ),
  'NE': CountryCoordinates(latitude: 17.7356214002094, longitude: 9.3238432),
  'NG': CountryCoordinates(
    latitude: 9.600035899420366,
    longitude: 7.999972099999999,
  ),
  'NI': CountryCoordinates(
    latitude: 12.609015699638856,
    longitude: -85.29369109999999,
  ),
  'NL': CountryCoordinates(
    latitude: 52.5001697990881,
    longitude: 5.7480820999999995,
  ),
  'NO': CountryCoordinates(latitude: 60.5000209017212, longitude: 9.0999715),
  'NP': CountryCoordinates(
    latitude: 28.108392899934167,
    longitude: 84.09171390000002,
  ),
  'NR': CountryCoordinates(
    latitude: -0.5252305999473795,
    longitude: 166.93244259999997,
  ),
  'NU': CountryCoordinates(
    latitude: -19.0536414004452,
    longitude: -169.86134099999998,
  ),
  'NZ': CountryCoordinates(
    latitude: -41.500083101030114,
    longitude: 172.8344077,
  ),
  'PE': CountryCoordinates(
    latitude: -6.869969699706354,
    longitude: -75.0458515,
  ),
  'PG': CountryCoordinates(
    latitude: -5.681606899681096,
    longitude: 144.2489081,
  ),
  'PH': CountryCoordinates(
    latitude: 12.750348599653217,
    longitude: 122.7312101,
  ),
  'PK': CountryCoordinates(
    latitude: 30.330840099711256,
    longitude: 71.24749899999999,
  ),
  'PL': CountryCoordinates(latitude: 52.215932999101426, longitude: 19.134422),
  'PN': CountryCoordinates(
    latitude: -25.065771899769672,
    longitude: -130.1017823,
  ),
  'PT': CountryCoordinates(
    latitude: 40.0332629002718,
    longitude: -7.889626299999999,
  ),
  'PW': CountryCoordinates(latitude: 5.378353699480902, longitude: 132.9102573),
  'PY': CountryCoordinates(
    latitude: -23.316593500023124,
    longitude: -58.1693445,
  ),
  'RO': CountryCoordinates(latitude: 45.9852129003448, longitude: 24.6859225),
  'RS': CountryCoordinates(latitude: 44.15341210052679, longitude: 20.55144),
  'RU': CountryCoordinates(latitude: 64.6863135992973, longitude: 97.7453061),
  'RW': CountryCoordinates(
    latitude: -1.9646630998204373,
    longitude: 30.0644358,
  ),
  'SB': CountryCoordinates(
    latitude: -9.735434399891584,
    longitude: 162.8288542,
  ),
  'SC': CountryCoordinates(
    latitude: -4.657497699687207,
    longitude: 55.454014599999994,
  ),
  'SD': CountryCoordinates(latitude: 14.58444439985823, longitude: 29.4917691),
  'SE': CountryCoordinates(latitude: 59.67497120152591, longitude: 14.5208584),
  'SI': CountryCoordinates(latitude: 45.81331130037045, longitude: 14.4808369),
  'SK': CountryCoordinates(latitude: 48.741152199756534, longitude: 19.4528646),
  'SL': CountryCoordinates(latitude: 8.640034899394465, longitude: -11.8400269),
  'SN': CountryCoordinates(
    latitude: 14.47506069984537,
    longitude: -14.452961199999995,
  ),
  'SO': CountryCoordinates(latitude: 8.367677099391441, longitude: 49.083416),
  'SR': CountryCoordinates(
    latitude: 4.141302499575072,
    longitude: -56.07711869999999,
  ),
  'SS': CountryCoordinates(latitude: 7.869943099390904, longitude: 29.6667897),
  'ST': CountryCoordinates(
    latitude: 0.8875497999065584,
    longitude: 6.964871799999999,
  ),
  'SV': CountryCoordinates(
    latitude: 13.800038199767254,
    longitude: -88.91406829999998,
  ),
  'SY': CountryCoordinates(
    latitude: 34.640186099629624,
    longitude: 39.049410599999995,
  ),
  'SZ': CountryCoordinates(latitude: -26.56248059956548, longitude: 31.3991317),
  'TD': CountryCoordinates(latitude: 15.613413699979589, longitude: 19.0156172),
  'TG': CountryCoordinates(
    latitude: 8.780026499396763,
    longitude: 1.0199764999999998,
  ),
  'TH': CountryCoordinates(latitude: 14.897192099895127, longitude: 100.83273),
  'TJ': CountryCoordinates(latitude: 38.62817330007198, longitude: 70.8156541),
  'TK': CountryCoordinates(
    latitude: -9.167639599843447,
    longitude: -171.819687,
  ),
  'TM': CountryCoordinates(latitude: 39.37638070018016, longitude: 59.3924609),
  'TN': CountryCoordinates(latitude: 33.843940799597135, longitude: 9.400138),
  'TO': CountryCoordinates(
    latitude: -19.916081900397085,
    longitude: -175.2026424,
  ),
  'TR': CountryCoordinates(latitude: 38.959759400120085, longitude: 34.9249653),
  'TV': CountryCoordinates(
    latitude: -7.768958999747341,
    longitude: 178.1167698,
  ),
  'TW': CountryCoordinates(
    latitude: 23.973937400334503,
    longitude: 120.98201789999996,
  ),
  'TZ': CountryCoordinates(latitude: -6.524712299695509, longitude: 35.7878438),
  'UA': CountryCoordinates(
    latitude: 49.48719679957284,
    longitude: 31.271832099999997,
  ),
  'UG': CountryCoordinates(
    latitude: 1.5333553998369125,
    longitude: 32.21665779999999,
  ),
  'US': CountryCoordinates(
    latitude: 39.78373040023763,
    longitude: -100.4458825,
  ),
  'UY': CountryCoordinates(
    latitude: -32.87555479951087,
    longitude: -56.0201525,
  ),
  'UZ': CountryCoordinates(latitude: 41.32373000042664, longitude: 63.9528098),
  'VE': CountryCoordinates(latitude: 8.001870899390418, longitude: -66.1109318),
  'VN': CountryCoordinates(
    latitude: 13.290402699710436,
    longitude: 108.4265113,
  ),
  'VU': CountryCoordinates(
    latitude: -16.52550690045718,
    longitude: 168.10691539999996,
  ),
  'WS': CountryCoordinates(
    latitude: -13.769389500282786,
    longitude: -172.12005079999997,
  ),
  'YE': CountryCoordinates(latitude: 16.347124300064024, longitude: 47.8915271),
  'ZA': CountryCoordinates(latitude: -28.8166235993549, longitude: 24.991639),
  'ZM': CountryCoordinates(
    latitude: -14.518912100344904,
    longitude: 27.558988399999997,
  ),
  'ZW': CountryCoordinates(
    latitude: -18.455496300465366,
    longitude: 29.7468414,
  ),
};
