// CountryData.swift
// GeoExplorer
//
// Static database of all world countries.
// Population figures are approximate 2024 estimates.
// Coordinates are for the capital city.

import Foundation

enum CountryData {
    static let all: [Country] = [

        // MARK: - Africa

        Country(name: "Algeria", capital: "Algiers", continent: "Africa", flag: "🇩🇿",
                population: 46_000_000, area: 2_381_741,
                funFact: "The Sahara Desert covers more than 80% of Algeria's land, making it the largest country in Africa.",
                latitude: 36.74, longitude: 3.06),

        Country(name: "Angola", capital: "Luanda", continent: "Africa", flag: "🇦🇴",
                population: 37_000_000, area: 1_246_700,
                funFact: "Angola's Kalandula Falls are among the largest waterfalls in Africa by volume of water.",
                latitude: -8.84, longitude: 13.23),

        Country(name: "Benin", capital: "Porto-Novo", continent: "Africa", flag: "🇧🇯",
                population: 13_000_000, area: 114_763,
                funFact: "Benin is considered the birthplace of the Voodoo religion, which is still practised widely today.",
                latitude: 6.37, longitude: 2.42),

        Country(name: "Botswana", capital: "Gaborone", continent: "Africa", flag: "🇧🇼",
                population: 2_600_000, area: 581_730,
                funFact: "The Okavango Delta — one of the world's largest inland deltas — floods a desert basin in Botswana each year.",
                latitude: -24.65, longitude: 25.91),

        Country(name: "Burkina Faso", capital: "Ouagadougou", continent: "Africa", flag: "🇧🇫",
                population: 23_000_000, area: 274_200,
                funFact: "The name 'Burkina Faso' translates to 'Land of the Incorruptible People' in the Mooré and Dioula languages.",
                latitude: 12.37, longitude: -1.53),

        Country(name: "Burundi", capital: "Gitega", continent: "Africa", flag: "🇧🇮",
                population: 13_000_000, area: 27_834,
                funFact: "The Royal Drummers of Burundi are recognised by UNESCO as an Intangible Cultural Heritage.",
                latitude: -3.43, longitude: 29.93),

        Country(name: "Cameroon", capital: "Yaoundé", continent: "Africa", flag: "🇨🇲",
                population: 28_000_000, area: 475_442,
                funFact: "Cameroon is called 'Africa in miniature' because it contains nearly every major climate and vegetation zone found across the continent.",
                latitude: 3.87, longitude: 11.52),

        Country(name: "Cape Verde", capital: "Praia", continent: "Africa", flag: "🇨🇻",
                population: 600_000, area: 4_033,
                funFact: "Cape Verde was uninhabited when Portuguese explorers arrived in 1456, making it one of the last places on Earth to be settled.",
                latitude: 14.93, longitude: -23.51),

        Country(name: "Central African Republic", capital: "Bangui", continent: "Africa", flag: "🇨🇫",
                population: 5_600_000, area: 622_984,
                funFact: "The Dzanga-Sangha rainforest is one of the last refuges for forest elephants and western lowland gorillas.",
                latitude: 4.36, longitude: 18.56),

        Country(name: "Chad", capital: "N'Djamena", continent: "Africa", flag: "🇹🇩",
                population: 18_000_000, area: 1_284_000,
                funFact: "Lake Chad has shrunk by 90% since the 1960s due to climate change and overuse — once one of Africa's largest lakes.",
                latitude: 12.11, longitude: 15.04),

        Country(name: "Comoros", capital: "Moroni", continent: "Africa", flag: "🇰🇲",
                population: 900_000, area: 2_235,
                funFact: "Comoros is the world's largest producer of ylang-ylang, a flower used in perfumes including Chanel No. 5.",
                latitude: -11.70, longitude: 43.26),

        Country(name: "Democratic Republic of Congo", capital: "Kinshasa", continent: "Africa", flag: "🇨🇩",
                population: 102_000_000, area: 2_344_858,
                funFact: "The Congo River is the world's deepest river, reaching depths of over 220 metres.",
                latitude: -4.32, longitude: 15.32),

        Country(name: "Republic of Congo", capital: "Brazzaville", continent: "Africa", flag: "🇨🇬",
                population: 6_000_000, area: 342_000,
                funFact: "Congo is home to the bonobo — one of our closest living relatives — found nowhere else on Earth.",
                latitude: -4.27, longitude: 15.28),

        Country(name: "Djibouti", capital: "Djibouti", continent: "Africa", flag: "🇩🇯",
                population: 1_000_000, area: 23_200,
                funFact: "Lake Assal sits 155 m below sea level — the lowest point in Africa and third lowest on Earth.",
                latitude: 11.59, longitude: 43.15),

        Country(name: "Egypt", capital: "Cairo", continent: "Africa", flag: "🇪🇬",
                population: 106_000_000, area: 1_002_450,
                funFact: "Egypt is home to the only remaining wonder of the ancient world — the Great Pyramid of Giza, built over 4,500 years ago.",
                latitude: 30.06, longitude: 31.25),

        Country(name: "Equatorial Guinea", capital: "Malabo", continent: "Africa", flag: "🇬🇶",
                population: 1_500_000, area: 28_051,
                funFact: "Equatorial Guinea is the only country in Africa where Spanish is an official language.",
                latitude: 3.75, longitude: 8.78),

        Country(name: "Eritrea", capital: "Asmara", continent: "Africa", flag: "🇪🇷",
                population: 3_500_000, area: 117_600,
                funFact: "Eritrea's capital Asmara is known as 'Africa's Rome' for its collection of modernist Italian colonial architecture.",
                latitude: 15.34, longitude: 38.93),

        Country(name: "Eswatini", capital: "Mbabane", continent: "Africa", flag: "🇸🇿",
                population: 1_200_000, area: 17_364,
                funFact: "Eswatini is one of the world's last absolute monarchies, where the king rules by decree.",
                latitude: -26.32, longitude: 31.14),

        Country(name: "Ethiopia", capital: "Addis Ababa", continent: "Africa", flag: "🇪🇹",
                population: 128_000_000, area: 1_104_300,
                funFact: "Ethiopia has its own calendar with 13 months and is roughly 7–8 years behind the Gregorian calendar.",
                latitude: 9.02, longitude: 38.75),

        Country(name: "Gabon", capital: "Libreville", continent: "Africa", flag: "🇬🇦",
                population: 2_300_000, area: 267_668,
                funFact: "About 88% of Gabon is covered by rainforest, making it one of the most forested countries in the world.",
                latitude: 0.39, longitude: 9.45),

        Country(name: "Gambia", capital: "Banjul", continent: "Africa", flag: "🇬🇲",
                population: 2_700_000, area: 11_295,
                funFact: "The Gambia is the smallest country on mainland Africa, completely surrounded by Senegal except for its Atlantic coastline.",
                latitude: 13.45, longitude: -16.58),

        Country(name: "Ghana", capital: "Accra", continent: "Africa", flag: "🇬🇭",
                population: 33_000_000, area: 238_533,
                funFact: "Ghana was the first sub-Saharan African country to gain independence from European colonial rule, in 1957.",
                latitude: 5.56, longitude: -0.20),

        Country(name: "Guinea", capital: "Conakry", continent: "Africa", flag: "🇬🇳",
                population: 14_000_000, area: 245_857,
                funFact: "Guinea contains about two-thirds of the world's known reserves of bauxite, the main ore used to produce aluminium.",
                latitude: 9.54, longitude: -13.68),

        Country(name: "Guinea-Bissau", capital: "Bissau", continent: "Africa", flag: "🇬🇼",
                population: 2_100_000, area: 36_125,
                funFact: "The Bijagós Archipelago is one of the few places in the world where hippopotamuses live in a saltwater marine environment.",
                latitude: 11.86, longitude: -15.60),

        Country(name: "Ivory Coast", capital: "Yamoussoukro", continent: "Africa", flag: "🇨🇮",
                population: 28_000_000, area: 322_463,
                funFact: "Ivory Coast is the world's largest producer of cocoa beans, supplying about 40% of the global total.",
                latitude: 6.82, longitude: -5.27),

        Country(name: "Kenya", capital: "Nairobi", continent: "Africa", flag: "🇰🇪",
                population: 57_000_000, area: 580_367,
                funFact: "Kenya's Great Rift Valley is one of the world's most important archaeological sites for early human ancestors.",
                latitude: -1.29, longitude: 36.82),

        Country(name: "Lesotho", capital: "Maseru", continent: "Africa", flag: "🇱🇸",
                population: 2_200_000, area: 30_355,
                funFact: "Lesotho is the only country in the world that lies entirely above 1,000 metres in elevation.",
                latitude: -29.32, longitude: 27.48),

        Country(name: "Liberia", capital: "Monrovia", continent: "Africa", flag: "🇱🇷",
                population: 5_400_000, area: 111_369,
                funFact: "Liberia was Africa's first republic, founded in 1847 by formerly enslaved African Americans.",
                latitude: 6.30, longitude: -10.80),

        Country(name: "Libya", capital: "Tripoli", continent: "Africa", flag: "🇱🇾",
                population: 7_400_000, area: 1_759_540,
                funFact: "Libya has the largest proven oil reserves in Africa.",
                latitude: 32.90, longitude: 13.18),

        Country(name: "Madagascar", capital: "Antananarivo", continent: "Africa", flag: "🇲🇬",
                population: 29_000_000, area: 587_041,
                funFact: "About 90% of Madagascar's wildlife is found nowhere else on Earth, including all of its lemur species.",
                latitude: -18.91, longitude: 47.54),

        Country(name: "Malawi", capital: "Lilongwe", continent: "Africa", flag: "🇲🇼",
                population: 20_000_000, area: 118_484,
                funFact: "Lake Malawi contains more species of fish than any other lake in the world.",
                latitude: -13.97, longitude: 33.79),

        Country(name: "Mali", capital: "Bamako", continent: "Africa", flag: "🇲🇱",
                population: 23_000_000, area: 1_240_192,
                funFact: "The ancient city of Timbuktu was once a major centre of Islamic scholarship with 180 Quranic schools.",
                latitude: 12.65, longitude: -8.00),

        Country(name: "Mauritania", capital: "Nouakchott", continent: "Africa", flag: "🇲🇷",
                population: 4_700_000, area: 1_030_700,
                funFact: "Mauritania has one of the world's longest trains — the iron ore train — which can stretch up to 2.5 km long.",
                latitude: 18.08, longitude: -15.97),

        Country(name: "Mauritius", capital: "Port Louis", continent: "Africa", flag: "🇲🇺",
                population: 1_300_000, area: 2_040,
                funFact: "The dodo bird was native to Mauritius and went extinct in the 1600s, less than 100 years after humans arrived.",
                latitude: -20.16, longitude: 57.50),

        Country(name: "Morocco", capital: "Rabat", continent: "Africa", flag: "🇲🇦",
                population: 37_000_000, area: 446_550,
                funFact: "The University of al-Qarawiyyin in Fez, founded in 859 AD, is the world's oldest continuously operating university.",
                latitude: 34.02, longitude: -6.84),

        Country(name: "Mozambique", capital: "Maputo", continent: "Africa", flag: "🇲🇿",
                population: 33_000_000, area: 801_590,
                funFact: "Mozambique's flag is the only national flag in the world to feature a modern weapon — an AK-47 rifle.",
                latitude: -25.97, longitude: 32.59),

        Country(name: "Namibia", capital: "Windhoek", continent: "Africa", flag: "🇳🇦",
                population: 2_800_000, area: 824_292,
                funFact: "The Namib Desert is believed to be the world's oldest desert, estimated to be 55–80 million years old.",
                latitude: -22.56, longitude: 17.08),

        Country(name: "Niger", capital: "Niamey", continent: "Africa", flag: "🇳🇪",
                population: 26_000_000, area: 1_267_000,
                funFact: "The Aïr Mountains in Niger contain rock art and engravings dating back over 6,000 years.",
                latitude: 13.51, longitude: 2.11),

        Country(name: "Nigeria", capital: "Abuja", continent: "Africa", flag: "🇳🇬",
                population: 224_000_000, area: 923_768,
                funFact: "Nigeria has the largest film industry in Africa (Nollywood), producing more movies annually than Hollywood.",
                latitude: 9.07, longitude: 7.40),

        Country(name: "Rwanda", capital: "Kigali", continent: "Africa", flag: "🇷🇼",
                population: 14_000_000, area: 26_338,
                funFact: "Rwanda banned plastic bags in 2008 and holds monthly community clean-up days — making it one of the cleanest countries in Africa.",
                latitude: -1.94, longitude: 30.06),

        Country(name: "São Tomé and Príncipe", capital: "São Tomé", continent: "Africa", flag: "🇸🇹",
                population: 230_000, area: 964,
                funFact: "São Tomé and Príncipe straddles both the equator and the prime meridian — the closest country to Earth's geometric centre.",
                latitude: 0.34, longitude: 6.73),

        Country(name: "Senegal", capital: "Dakar", continent: "Africa", flag: "🇸🇳",
                population: 18_000_000, area: 196_722,
                funFact: "The Pink Lake (Lac Rose) near Dakar appears pink due to algae that thrive in its extremely salty water.",
                latitude: 14.72, longitude: -17.47),

        Country(name: "Seychelles", capital: "Victoria", continent: "Africa", flag: "🇸🇨",
                population: 100_000, area: 455,
                funFact: "Seychelles is home to the world's largest seed — the coco de mer palm nut — which can weigh up to 25 kg.",
                latitude: -4.62, longitude: 55.45),

        Country(name: "Sierra Leone", capital: "Freetown", continent: "Africa", flag: "🇸🇱",
                population: 8_600_000, area: 71_740,
                funFact: "Sierra Leone's name means 'Lion Mountains' in Portuguese, inspired by the thunder-like rumble of its hills.",
                latitude: 8.48, longitude: -13.23),

        Country(name: "Somalia", capital: "Mogadishu", continent: "Africa", flag: "🇸🇴",
                population: 18_000_000, area: 637_657,
                funFact: "Somalia has the longest coastline of any African country, stretching over 3,300 km along the Indian Ocean.",
                latitude: 2.05, longitude: 45.34),

        Country(name: "South Africa", capital: "Pretoria", continent: "Africa", flag: "🇿🇦",
                population: 62_000_000, area: 1_221_037,
                funFact: "South Africa is the only country to have voluntarily dismantled its own nuclear weapons programme.",
                latitude: -25.75, longitude: 28.23),

        Country(name: "South Sudan", capital: "Juba", continent: "Africa", flag: "🇸🇸",
                population: 11_000_000, area: 619_745,
                funFact: "South Sudan is the world's newest internationally recognised country, gaining independence in 2011.",
                latitude: 4.85, longitude: 31.60),

        Country(name: "Sudan", capital: "Khartoum", continent: "Africa", flag: "🇸🇩",
                population: 48_000_000, area: 1_886_068,
                funFact: "Sudan has more ancient pyramids than Egypt — over 200, built by the Nubian kingdoms.",
                latitude: 15.55, longitude: 32.53),

        Country(name: "Tanzania", capital: "Dodoma", continent: "Africa", flag: "🇹🇿",
                population: 67_000_000, area: 945_087,
                funFact: "Mount Kilimanjaro is the tallest free-standing mountain in the world at 5,895 metres.",
                latitude: -6.18, longitude: 35.74),

        Country(name: "Togo", capital: "Lomé", continent: "Africa", flag: "🇹🇬",
                population: 9_000_000, area: 56_785,
                funFact: "Voodoo is a recognised religion in Togo and January 10th is a public holiday — National Voodoo Day.",
                latitude: 6.14, longitude: 1.22),

        Country(name: "Tunisia", capital: "Tunis", continent: "Africa", flag: "🇹🇳",
                population: 12_000_000, area: 163_610,
                funFact: "Tunisia was home to ancient Carthage, one of the greatest powers in the Mediterranean world.",
                latitude: 36.82, longitude: 10.17),

        Country(name: "Uganda", capital: "Kampala", continent: "Africa", flag: "🇺🇬",
                population: 49_000_000, area: 241_038,
                funFact: "Uganda is home to about half of the world's remaining mountain gorilla population.",
                latitude: 0.32, longitude: 32.58),

        Country(name: "Zambia", capital: "Lusaka", continent: "Africa", flag: "🇿🇲",
                population: 20_000_000, area: 752_612,
                funFact: "Victoria Falls — on the Zambia-Zimbabwe border — is the world's largest waterfall by total area.",
                latitude: -15.42, longitude: 28.28),

        Country(name: "Zimbabwe", capital: "Harare", continent: "Africa", flag: "🇿🇼",
                population: 16_000_000, area: 390_757,
                funFact: "Great Zimbabwe — ruins of a medieval city built from stone without mortar — gave the country its name.",
                latitude: -17.83, longitude: 31.05),

        // MARK: - Americas

        Country(name: "Antigua and Barbuda", capital: "Saint John's", continent: "Americas", flag: "🇦🇬",
                population: 100_000, area: 440,
                funFact: "Antigua has 365 beaches — one for every day of the year.",
                latitude: 17.12, longitude: -61.85),

        Country(name: "Argentina", capital: "Buenos Aires", continent: "Americas", flag: "🇦🇷",
                population: 46_000_000, area: 2_780_400,
                funFact: "Argentina's Patagonia region is home to some of the world's southernmost forests and glaciers.",
                latitude: -34.60, longitude: -58.38),

        Country(name: "Bahamas", capital: "Nassau", continent: "Americas", flag: "🇧🇸",
                population: 400_000, area: 13_880,
                funFact: "The Bahamas has the third-largest barrier reef system in the world.",
                latitude: 25.06, longitude: -77.34),

        Country(name: "Barbados", capital: "Bridgetown", continent: "Americas", flag: "🇧🇧",
                population: 300_000, area: 430,
                funFact: "Barbados is believed to be the birthplace of rum, with the first commercial rum distillery dating to the 1600s.",
                latitude: 13.10, longitude: -59.62),

        Country(name: "Belize", capital: "Belmopan", continent: "Americas", flag: "🇧🇿",
                population: 400_000, area: 22_966,
                funFact: "Belize has the second-largest barrier reef in the world and the largest cave system in Central America.",
                latitude: 17.25, longitude: -88.77),

        Country(name: "Bolivia", capital: "Sucre", continent: "Americas", flag: "🇧🇴",
                population: 12_000_000, area: 1_098_581,
                funFact: "Bolivia has two capitals and is home to the world's largest salt flat — the Salar de Uyuni.",
                latitude: -19.04, longitude: -65.26),

        Country(name: "Brazil", capital: "Brasília", continent: "Americas", flag: "🇧🇷",
                population: 215_000_000, area: 8_515_767,
                funFact: "Brazil is the only country in South America where Portuguese is the official language, and it contains about 60% of the Amazon rainforest.",
                latitude: -15.78, longitude: -47.93),

        Country(name: "Canada", capital: "Ottawa", continent: "Americas", flag: "🇨🇦",
                population: 38_000_000, area: 9_984_670,
                funFact: "Canada has more lakes than the rest of the world combined — about 60% of the world's fresh surface water.",
                latitude: 45.42, longitude: -75.70),

        Country(name: "Chile", capital: "Santiago", continent: "Americas", flag: "🇨🇱",
                population: 19_000_000, area: 756_102,
                funFact: "Chile is the world's longest country north to south, stretching over 4,300 km.",
                latitude: -33.46, longitude: -70.65),

        Country(name: "Colombia", capital: "Bogotá", continent: "Americas", flag: "🇨🇴",
                population: 52_000_000, area: 1_141_748,
                funFact: "Colombia is the only country in South America with coastlines on both the Pacific Ocean and the Caribbean Sea.",
                latitude: 4.71, longitude: -74.07),

        Country(name: "Costa Rica", capital: "San José", continent: "Americas", flag: "🇨🇷",
                population: 5_200_000, area: 51_100,
                funFact: "Costa Rica abolished its military in 1948, redirecting funds to education and healthcare.",
                latitude: 9.93, longitude: -84.08),

        Country(name: "Cuba", capital: "Havana", continent: "Americas", flag: "🇨🇺",
                population: 11_000_000, area: 109_884,
                funFact: "Cuba has the highest doctor-to-patient ratio in the world and exports medical services to over 60 countries.",
                latitude: 23.13, longitude: -82.38),

        Country(name: "Dominica", capital: "Roseau", continent: "Americas", flag: "🇩🇲",
                population: 70_000, area: 751,
                funFact: "Dominica is known as the 'Nature Isle of the Caribbean' and is home to the world's second-largest boiling lake.",
                latitude: 15.30, longitude: -61.39),

        Country(name: "Dominican Republic", capital: "Santo Domingo", continent: "Americas", flag: "🇩🇴",
                population: 11_000_000, area: 48_671,
                funFact: "The Dominican Republic is home to Pico Duarte, the highest peak in the entire Caribbean at 3,098 metres.",
                latitude: 18.48, longitude: -69.90),

        Country(name: "Ecuador", capital: "Quito", continent: "Americas", flag: "🇪🇨",
                population: 18_000_000, area: 283_561,
                funFact: "Ecuador was the first country in the world to grant constitutional rights to nature, in its 2008 constitution.",
                latitude: -0.22, longitude: -78.51),

        Country(name: "El Salvador", capital: "San Salvador", continent: "Americas", flag: "🇸🇻",
                population: 6_500_000, area: 21_041,
                funFact: "El Salvador adopted Bitcoin as legal tender in 2021, becoming the first country in the world to do so.",
                latitude: 13.69, longitude: -89.19),

        Country(name: "Grenada", capital: "Saint George's", continent: "Americas", flag: "🇬🇩",
                population: 120_000, area: 344,
                funFact: "Grenada is known as the 'Island of Spice' and is one of the world's largest producers of nutmeg and mace.",
                latitude: 12.05, longitude: -61.75),

        Country(name: "Guatemala", capital: "Guatemala City", continent: "Americas", flag: "🇬🇹",
                population: 18_000_000, area: 108_889,
                funFact: "Lake Atitlán in Guatemala is considered one of the most beautiful lakes in the world.",
                latitude: 14.64, longitude: -90.52),

        Country(name: "Guyana", capital: "Georgetown", continent: "Americas", flag: "🇬🇾",
                population: 800_000, area: 214_969,
                funFact: "Guyana is the only English-speaking country in South America.",
                latitude: 6.80, longitude: -58.16),

        Country(name: "Haiti", capital: "Port-au-Prince", continent: "Americas", flag: "🇭🇹",
                population: 12_000_000, area: 27_750,
                funFact: "Haiti was the first Black republic in the world, declaring independence in 1804 after a successful slave revolution.",
                latitude: 18.54, longitude: -72.34),

        Country(name: "Honduras", capital: "Tegucigalpa", continent: "Americas", flag: "🇭🇳",
                population: 10_000_000, area: 112_492,
                funFact: "Honduras is home to the ancient Maya city of Copán, famous for its intricate stone sculptures and hieroglyphic stairway.",
                latitude: 14.10, longitude: -87.22),

        Country(name: "Jamaica", capital: "Kingston", continent: "Americas", flag: "🇯🇲",
                population: 2_900_000, area: 10_991,
                funFact: "Jamaica gave the world reggae music and is the birthplace of Bob Marley.",
                latitude: 18.00, longitude: -76.79),

        Country(name: "Mexico", capital: "Mexico City", continent: "Americas", flag: "🇲🇽",
                population: 130_000_000, area: 1_964_375,
                funFact: "Mexico City is built on the ruins of the ancient Aztec capital Tenochtitlán and sinks several centimetres every year.",
                latitude: 19.43, longitude: -99.13),

        Country(name: "Nicaragua", capital: "Managua", continent: "Americas", flag: "🇳🇮",
                population: 7_000_000, area: 130_375,
                funFact: "Lake Nicaragua is the only freshwater lake in the world to contain sharks.",
                latitude: 12.14, longitude: -86.28),

        Country(name: "Panama", capital: "Panama City", continent: "Americas", flag: "🇵🇦",
                population: 4_400_000, area: 75_417,
                funFact: "The Panama Canal, opened in 1914, connects the Atlantic and Pacific Oceans and is one of history's greatest engineering feats.",
                latitude: 8.99, longitude: -79.52),

        Country(name: "Paraguay", capital: "Asunción", continent: "Americas", flag: "🇵🇾",
                population: 7_500_000, area: 406_752,
                funFact: "Paraguay is one of the few countries with two official languages both widely spoken — Spanish and Guaraní.",
                latitude: -25.29, longitude: -57.65),

        Country(name: "Peru", capital: "Lima", continent: "Americas", flag: "🇵🇪",
                population: 33_000_000, area: 1_285_216,
                funFact: "The ancient Inca citadel of Machu Picchu was built in the 15th century and was unknown to the outside world until 1911.",
                latitude: -12.05, longitude: -77.05),

        Country(name: "Saint Kitts and Nevis", capital: "Basseterre", continent: "Americas", flag: "🇰🇳",
                population: 50_000, area: 261,
                funFact: "Nevis is believed to be the birthplace of Alexander Hamilton, one of the founding fathers of the United States.",
                latitude: 17.30, longitude: -62.72),

        Country(name: "Saint Lucia", capital: "Castries", continent: "Americas", flag: "🇱🇨",
                population: 180_000, area: 616,
                funFact: "Saint Lucia has produced the most Nobel laureates per capita of any country in the world — two.",
                latitude: 14.00, longitude: -61.00),

        Country(name: "Saint Vincent and the Grenadines", capital: "Kingstown", continent: "Americas", flag: "🇻🇨",
                population: 110_000, area: 389,
                funFact: "The Pirates of the Caribbean films were largely shot in Saint Vincent and the Grenadines.",
                latitude: 13.16, longitude: -61.22),

        Country(name: "Suriname", capital: "Paramaribo", continent: "Americas", flag: "🇸🇷",
                population: 600_000, area: 163_820,
                funFact: "Suriname is the smallest sovereign state in South America and has the highest proportion of forest cover of any country in the world.",
                latitude: 5.87, longitude: -55.17),

        Country(name: "Trinidad and Tobago", capital: "Port of Spain", continent: "Americas", flag: "🇹🇹",
                population: 1_400_000, area: 5_130,
                funFact: "Trinidad and Tobago is the birthplace of the steel pan — the only acoustic instrument invented in the 20th century.",
                latitude: 10.65, longitude: -61.52),

        Country(name: "United States", capital: "Washington, D.C.", continent: "Americas", flag: "🇺🇸",
                population: 335_000_000, area: 9_833_517,
                funFact: "The United States has the world's oldest written national constitution still in use, ratified in 1788.",
                latitude: 38.90, longitude: -77.04),

        Country(name: "Uruguay", capital: "Montevideo", continent: "Americas", flag: "🇺🇾",
                population: 3_500_000, area: 176_215,
                funFact: "Uruguay was the first country in the world to legalise the cultivation, sale, and consumption of cannabis, in 2013.",
                latitude: -34.90, longitude: -56.19),

        Country(name: "Venezuela", capital: "Caracas", continent: "Americas", flag: "🇻🇪",
                population: 30_000_000, area: 912_050,
                funFact: "Venezuela has the world's largest proven oil reserves and is home to Angel Falls — the world's highest uninterrupted waterfall.",
                latitude: 10.48, longitude: -66.88),

        // MARK: - Asia

        Country(name: "Afghanistan", capital: "Kabul", continent: "Asia", flag: "🇦🇫",
                population: 42_000_000, area: 652_230,
                funFact: "Buzkashi — polo played with a goat carcass — originated in Afghanistan and is the national sport.",
                latitude: 34.53, longitude: 69.17),

        Country(name: "Armenia", capital: "Yerevan", continent: "Asia", flag: "🇦🇲",
                population: 3_000_000, area: 29_743,
                funFact: "Armenia is home to one of the world's oldest Christian churches — the Etchmiadzin Cathedral, built in 301 AD.",
                latitude: 40.18, longitude: 44.51),

        Country(name: "Azerbaijan", capital: "Baku", continent: "Asia", flag: "🇦🇿",
                population: 10_000_000, area: 86_600,
                funFact: "Azerbaijan means 'Land of Fire' — natural gas vents have fed eternal flames here for thousands of years.",
                latitude: 40.41, longitude: 49.87),

        Country(name: "Bahrain", capital: "Manama", continent: "Asia", flag: "🇧🇭",
                population: 1_500_000, area: 760,
                funFact: "Bahrain was the first Gulf state to discover oil in 1932, and the first to begin diversifying away from it.",
                latitude: 26.22, longitude: 50.59),

        Country(name: "Bangladesh", capital: "Dhaka", continent: "Asia", flag: "🇧🇩",
                population: 170_000_000, area: 147_570,
                funFact: "Bangladesh is home to the Sundarbans — the world's largest mangrove forest, shared with India.",
                latitude: 23.73, longitude: 90.40),

        Country(name: "Bhutan", capital: "Thimphu", continent: "Asia", flag: "🇧🇹",
                population: 800_000, area: 38_394,
                funFact: "Bhutan is the only country in the world to measure success in Gross National Happiness rather than GDP.",
                latitude: 27.47, longitude: 89.64),

        Country(name: "Brunei", capital: "Bandar Seri Begawan", continent: "Asia", flag: "🇧🇳",
                population: 450_000, area: 5_765,
                funFact: "Brunei is one of the few countries in the world where citizens pay no income tax.",
                latitude: 4.94, longitude: 114.95),

        Country(name: "Cambodia", capital: "Phnom Penh", continent: "Asia", flag: "🇰🇭",
                population: 17_000_000, area: 181_035,
                funFact: "Angkor Wat in Cambodia is the world's largest religious monument, covering about 400 square kilometres.",
                latitude: 11.55, longitude: 104.92),

        Country(name: "China", capital: "Beijing", continent: "Asia", flag: "🇨🇳",
                population: 1_412_000_000, area: 9_596_960,
                funFact: "China's Great Wall stretches over 21,000 km and is one of the greatest construction projects in human history.",
                latitude: 39.91, longitude: 116.39),

        Country(name: "Cyprus", capital: "Nicosia", continent: "Asia", flag: "🇨🇾",
                population: 1_200_000, area: 9_251,
                funFact: "Cyprus is the mythical birthplace of Aphrodite, the Greek goddess of love.",
                latitude: 35.17, longitude: 33.37),

        Country(name: "Georgia", capital: "Tbilisi", continent: "Asia", flag: "🇬🇪",
                population: 4_000_000, area: 69_700,
                funFact: "Georgia has one of the world's oldest winemaking traditions, with evidence of viticulture dating back 8,000 years.",
                latitude: 41.69, longitude: 44.83),

        Country(name: "India", capital: "New Delhi", continent: "Asia", flag: "🇮🇳",
                population: 1_428_000_000, area: 3_287_263,
                funFact: "India has the world's largest number of vegetarians and is the world's largest producer of milk.",
                latitude: 28.61, longitude: 77.21),

        Country(name: "Indonesia", capital: "Jakarta", continent: "Asia", flag: "🇮🇩",
                population: 277_000_000, area: 1_904_569,
                funFact: "Indonesia is an archipelago of over 17,000 islands, making it the world's largest island country.",
                latitude: -6.21, longitude: 106.85),

        Country(name: "Iran", capital: "Tehran", continent: "Asia", flag: "🇮🇷",
                population: 87_000_000, area: 1_648_195,
                funFact: "Iran (Persia) is home to one of the world's oldest continuous civilisations, spanning over 7,000 years.",
                latitude: 35.69, longitude: 51.42),

        Country(name: "Iraq", capital: "Baghdad", continent: "Asia", flag: "🇮🇶",
                population: 43_000_000, area: 438_317,
                funFact: "Iraq was once called Mesopotamia — 'land between two rivers' — and is considered the cradle of civilisation.",
                latitude: 33.34, longitude: 44.40),

        Country(name: "Israel", capital: "Jerusalem", continent: "Asia", flag: "🇮🇱",
                population: 9_700_000, area: 20_770,
                funFact: "Israel is the only country in the world to have revived an ancient language as its official national language — Hebrew.",
                latitude: 31.77, longitude: 35.22),

        Country(name: "Japan", capital: "Tokyo", continent: "Asia", flag: "🇯🇵",
                population: 123_000_000, area: 377_975,
                funFact: "Japan has more vending machines per capita than any other country — about one for every 23 people.",
                latitude: 35.68, longitude: 139.69),

        Country(name: "Jordan", capital: "Amman", continent: "Asia", flag: "🇯🇴",
                population: 10_000_000, area: 89_342,
                funFact: "The ancient city of Petra, carved from rose-red rock, is one of the most recognisable archaeological sites in the world.",
                latitude: 31.95, longitude: 35.93),

        Country(name: "Kazakhstan", capital: "Astana", continent: "Asia", flag: "🇰🇿",
                population: 19_000_000, area: 2_724_900,
                funFact: "Kazakhstan is the world's largest landlocked country — bigger than the entire continent of Western Europe.",
                latitude: 51.18, longitude: 71.45),

        Country(name: "Kuwait", capital: "Kuwait City", continent: "Asia", flag: "🇰🇼",
                population: 4_400_000, area: 17_818,
                funFact: "Kuwait has no rivers — all drinking water comes from desalination of seawater from the Persian Gulf.",
                latitude: 29.37, longitude: 47.98),

        Country(name: "Kyrgyzstan", capital: "Bishkek", continent: "Asia", flag: "🇰🇬",
                population: 6_800_000, area: 199_951,
                funFact: "About 90% of Kyrgyzstan is covered by mountains, and it is home to one of the world's largest walnut forests.",
                latitude: 42.87, longitude: 74.59),

        Country(name: "Laos", capital: "Vientiane", continent: "Asia", flag: "🇱🇦",
                population: 7_400_000, area: 236_800,
                funFact: "Laos is the most heavily bombed country per capita in history, from unexploded ordnance left over from the Vietnam War.",
                latitude: 17.97, longitude: 102.63),

        Country(name: "Lebanon", capital: "Beirut", continent: "Asia", flag: "🇱🇧",
                population: 5_500_000, area: 10_400,
                funFact: "Lebanon has 18 officially recognised religious communities — more than almost any other country in the world.",
                latitude: 33.89, longitude: 35.50),

        Country(name: "Malaysia", capital: "Kuala Lumpur", continent: "Asia", flag: "🇲🇾",
                population: 33_000_000, area: 329_847,
                funFact: "Malaysia is home to the world's oldest tropical rainforest, estimated to be 130 million years old.",
                latitude: 3.14, longitude: 101.69),

        Country(name: "Maldives", capital: "Malé", continent: "Asia", flag: "🇲🇻",
                population: 520_000, area: 298,
                funFact: "The Maldives is the flattest country on Earth, with an average elevation of just 1.5 metres above sea level.",
                latitude: 4.18, longitude: 73.51),

        Country(name: "Mongolia", capital: "Ulaanbaatar", continent: "Asia", flag: "🇲🇳",
                population: 3_400_000, area: 1_564_110,
                funFact: "Mongolia has the lowest population density of any sovereign country in the world.",
                latitude: 47.91, longitude: 106.88),

        Country(name: "Myanmar", capital: "Naypyidaw", continent: "Asia", flag: "🇲🇲",
                population: 54_000_000, area: 676_578,
                funFact: "Myanmar has more Buddhist pagodas than any other country — over 1,000 in Bagan alone.",
                latitude: 19.76, longitude: 96.07),

        Country(name: "Nepal", capital: "Kathmandu", continent: "Asia", flag: "🇳🇵",
                population: 30_000_000, area: 147_181,
                funFact: "Nepal is home to eight of the world's ten tallest mountains, including Mount Everest.",
                latitude: 27.71, longitude: 85.31),

        Country(name: "North Korea", capital: "Pyongyang", continent: "Asia", flag: "🇰🇵",
                population: 26_000_000, area: 120_538,
                funFact: "North Korea operates one of the most isolated economies in the world and has its own time zone — Pyongyang Time.",
                latitude: 39.02, longitude: 125.75),

        Country(name: "Oman", capital: "Muscat", continent: "Asia", flag: "🇴🇲",
                population: 4_500_000, area: 309_500,
                funFact: "Oman's Wahiba Sands desert is home to over 150 species of animals — more than the Sahara, which is 1,000 times larger.",
                latitude: 23.58, longitude: 58.41),

        Country(name: "Pakistan", capital: "Islamabad", continent: "Asia", flag: "🇵🇰",
                population: 231_000_000, area: 881_913,
                funFact: "Pakistan is home to K2 — the second-highest mountain in the world, considered more technically challenging than Everest.",
                latitude: 33.72, longitude: 73.06),

        Country(name: "Palestine", capital: "Ramallah", continent: "Asia", flag: "🇵🇸",
                population: 5_400_000, area: 6_220,
                funFact: "The Dead Sea — bordering Palestine and Jordan — is the lowest point on Earth's surface at about 430 metres below sea level.",
                latitude: 31.90, longitude: 35.21),

        Country(name: "Philippines", capital: "Manila", continent: "Asia", flag: "🇵🇭",
                population: 115_000_000, area: 343_448,
                funFact: "The Philippines is an archipelago of over 7,100 islands.",
                latitude: 14.60, longitude: 120.98),

        Country(name: "Qatar", capital: "Doha", continent: "Asia", flag: "🇶🇦",
                population: 2_900_000, area: 11_586,
                funFact: "Qatar was the first Arab country to host the FIFA World Cup, in 2022.",
                latitude: 25.29, longitude: 51.53),

        Country(name: "Saudi Arabia", capital: "Riyadh", continent: "Asia", flag: "🇸🇦",
                population: 36_000_000, area: 2_149_690,
                funFact: "Saudi Arabia is the world's largest oil exporter and home to the two holiest sites in Islam — Mecca and Medina.",
                latitude: 24.69, longitude: 46.72),

        Country(name: "Singapore", capital: "Singapore", continent: "Asia", flag: "🇸🇬",
                population: 5_900_000, area: 728,
                funFact: "Singapore is one of only three surviving city-states in the world, with no natural resources but one of the highest GDPs per capita.",
                latitude: 1.35, longitude: 103.82),

        Country(name: "South Korea", capital: "Seoul", continent: "Asia", flag: "🇰🇷",
                population: 51_000_000, area: 100_210,
                funFact: "South Korea is the most wired country in the world, consistently ranking first in average internet connection speed.",
                latitude: 37.57, longitude: 126.98),

        Country(name: "Sri Lanka", capital: "Sri Jayawardenepura Kotte", continent: "Asia", flag: "🇱🇰",
                population: 22_000_000, area: 65_610,
                funFact: "Sri Lanka produces some of the world's finest tea — the origin of the 'Ceylon' brand still used globally today.",
                latitude: 6.89, longitude: 79.92),

        Country(name: "Syria", capital: "Damascus", continent: "Asia", flag: "🇸🇾",
                population: 21_000_000, area: 185_180,
                funFact: "Damascus is considered one of the oldest continuously inhabited cities in the world, with a history of over 11,000 years.",
                latitude: 33.51, longitude: 36.29),

        Country(name: "Taiwan", capital: "Taipei", continent: "Asia", flag: "🇹🇼",
                population: 23_000_000, area: 36_193,
                funFact: "Taiwan invented bubble tea (boba) in the 1980s, now enjoyed in over 30 countries worldwide.",
                latitude: 25.04, longitude: 121.56),

        Country(name: "Tajikistan", capital: "Dushanbe", continent: "Asia", flag: "🇹🇯",
                population: 10_000_000, area: 143_100,
                funFact: "Over 90% of Tajikistan is covered by mountains, and it contains the Fedchenko Glacier — the longest non-polar glacier in the world.",
                latitude: 38.56, longitude: 68.77),

        Country(name: "Thailand", capital: "Bangkok", continent: "Asia", flag: "🇹🇭",
                population: 72_000_000, area: 513_120,
                funFact: "Thailand is the world's largest exporter of rice and the only Southeast Asian country never to have been colonised.",
                latitude: 13.75, longitude: 100.52),

        Country(name: "Timor-Leste", capital: "Dili", continent: "Asia", flag: "🇹🇱",
                population: 1_400_000, area: 14_874,
                funFact: "Timor-Leste is one of the world's youngest nations, gaining independence in 2002 after centuries of Portuguese and Indonesian rule.",
                latitude: -8.56, longitude: 125.58),

        Country(name: "Turkey", capital: "Ankara", continent: "Asia", flag: "🇹🇷",
                population: 85_000_000, area: 783_562,
                funFact: "Turkey spans two continents — Europe and Asia — and Istanbul is the only city in the world to straddle two continents.",
                latitude: 39.93, longitude: 32.85),

        Country(name: "Turkmenistan", capital: "Ashgabat", continent: "Asia", flag: "🇹🇲",
                population: 6_100_000, area: 488_100,
                funFact: "The 'Door to Hell' — a natural gas crater in Turkmenistan — has been burning continuously since 1971.",
                latitude: 37.95, longitude: 58.39),

        Country(name: "United Arab Emirates", capital: "Abu Dhabi", continent: "Asia", flag: "🇦🇪",
                population: 9_900_000, area: 83_600,
                funFact: "The UAE's Burj Khalifa in Dubai is the world's tallest building at 828 metres.",
                latitude: 24.45, longitude: 54.37),

        Country(name: "Uzbekistan", capital: "Tashkent", continent: "Asia", flag: "🇺🇿",
                population: 36_000_000, area: 447_400,
                funFact: "Uzbekistan was a crossroads of the ancient Silk Road, and Samarkand is one of the oldest inhabited cities in Central Asia.",
                latitude: 41.30, longitude: 69.27),

        Country(name: "Vietnam", capital: "Hanoi", continent: "Asia", flag: "🇻🇳",
                population: 98_000_000, area: 331_212,
                funFact: "Vietnam is the world's second-largest coffee producer, after Brazil.",
                latitude: 21.03, longitude: 105.85),

        Country(name: "Yemen", capital: "Sana'a", continent: "Asia", flag: "🇾🇪",
                population: 34_000_000, area: 527_968,
                funFact: "Yemen is home to Socotra Island — sometimes called the 'Galápagos of the Indian Ocean' for its uniquely alien-looking wildlife.",
                latitude: 15.35, longitude: 44.21),

        // MARK: - Europe

        Country(name: "Albania", capital: "Tirana", continent: "Europe", flag: "🇦🇱",
                population: 2_800_000, area: 28_748,
                funFact: "Albania built over 750,000 concrete bunkers during the communist era — more per square kilometre than any other country.",
                latitude: 41.33, longitude: 19.83),

        Country(name: "Andorra", capital: "Andorra la Vella", continent: "Europe", flag: "🇦🇩",
                population: 80_000, area: 468,
                funFact: "Andorra has no airport, no army, and no income tax — making it a favourite destination for shoppers and skiers.",
                latitude: 42.51, longitude: 1.52),

        Country(name: "Austria", capital: "Vienna", continent: "Europe", flag: "🇦🇹",
                population: 9_100_000, area: 83_871,
                funFact: "Austria is the birthplace of Mozart, Freud, and Schubert — among the most culturally productive countries per capita.",
                latitude: 48.21, longitude: 16.37),

        Country(name: "Belarus", capital: "Minsk", continent: "Europe", flag: "🇧🇾",
                population: 9_400_000, area: 207_600,
                funFact: "Belarus is home to Białowieża Forest — one of the last primeval forests in Europe and home to the rare European bison.",
                latitude: 53.90, longitude: 27.57),

        Country(name: "Belgium", capital: "Brussels", continent: "Europe", flag: "🇧🇪",
                population: 11_600_000, area: 30_528,
                funFact: "Belgium has over 1,500 varieties of beer and the world's highest concentration of chocolatiers per square kilometre.",
                latitude: 50.85, longitude: 4.35),

        Country(name: "Bosnia and Herzegovina", capital: "Sarajevo", continent: "Europe", flag: "🇧🇦",
                population: 3_300_000, area: 51_197,
                funFact: "Sarajevo hosted the 1984 Winter Olympics and later endured the longest siege of a capital city in modern warfare.",
                latitude: 43.85, longitude: 18.39),

        Country(name: "Bulgaria", capital: "Sofia", continent: "Europe", flag: "🇧🇬",
                population: 6_500_000, area: 110_879,
                funFact: "Bulgaria invented the Cyrillic alphabet in the 9th century, now used by over 250 million people worldwide.",
                latitude: 42.70, longitude: 23.32),

        Country(name: "Croatia", capital: "Zagreb", continent: "Europe", flag: "🇭🇷",
                population: 3_900_000, area: 56_594,
                funFact: "Croatia has over 1,000 islands along its Adriatic coastline, and the necktie (cravat) is said to have been invented there.",
                latitude: 45.81, longitude: 15.98),

        Country(name: "Czech Republic", capital: "Prague", continent: "Europe", flag: "🇨🇿",
                population: 10_900_000, area: 78_866,
                funFact: "The Czech Republic has the highest beer consumption per capita in the world.",
                latitude: 50.09, longitude: 14.42),

        Country(name: "Denmark", capital: "Copenhagen", continent: "Europe", flag: "🇩🇰",
                population: 5_900_000, area: 42_924,
                funFact: "Denmark consistently ranks as one of the world's happiest countries and was the first to legalise same-sex unions in 1989.",
                latitude: 55.68, longitude: 12.57),

        Country(name: "Estonia", capital: "Tallinn", continent: "Europe", flag: "🇪🇪",
                population: 1_300_000, area: 45_228,
                funFact: "Estonia is one of the world's most digitally advanced countries — you can vote, pay taxes, and start a company entirely online.",
                latitude: 59.44, longitude: 24.75),

        Country(name: "Finland", capital: "Helsinki", continent: "Europe", flag: "🇫🇮",
                population: 5_500_000, area: 338_424,
                funFact: "Finland has more saunas than cars — over 3 million saunas for a population of 5.5 million people.",
                latitude: 60.17, longitude: 24.94),

        Country(name: "France", capital: "Paris", continent: "Europe", flag: "🇫🇷",
                population: 68_000_000, area: 551_695,
                funFact: "France is the most visited country in the world, attracting over 90 million tourists per year.",
                latitude: 48.86, longitude: 2.35),

        Country(name: "Germany", capital: "Berlin", continent: "Europe", flag: "🇩🇪",
                population: 84_000_000, area: 357_114,
                funFact: "Germany is home to over 1,300 different types of beer and about 1,500 different varieties of bread.",
                latitude: 52.52, longitude: 13.40),

        Country(name: "Greece", capital: "Athens", continent: "Europe", flag: "🇬🇷",
                population: 10_400_000, area: 131_957,
                funFact: "Greece has more archaeological museums than any other country in the world.",
                latitude: 37.98, longitude: 23.73),

        Country(name: "Hungary", capital: "Budapest", continent: "Europe", flag: "🇭🇺",
                population: 9_700_000, area: 93_028,
                funFact: "Hungary has the largest thermal lake in the world — Lake Hévíz — which stays warm enough to swim in year-round.",
                latitude: 47.50, longitude: 19.04),

        Country(name: "Iceland", capital: "Reykjavík", continent: "Europe", flag: "🇮🇸",
                population: 370_000, area: 103_000,
                funFact: "Iceland has no mosquitoes and is one of the few countries where you can reliably see the Northern Lights.",
                latitude: 64.14, longitude: -21.90),

        Country(name: "Ireland", capital: "Dublin", continent: "Europe", flag: "🇮🇪",
                population: 5_100_000, area: 70_273,
                funFact: "Ireland is the only country in the world whose national symbol is a musical instrument — the harp.",
                latitude: 53.33, longitude: -6.25),

        Country(name: "Italy", capital: "Rome", continent: "Europe", flag: "🇮🇹",
                population: 59_000_000, area: 301_340,
                funFact: "Italy is home to the world's oldest university — the University of Bologna — founded in 1088.",
                latitude: 41.90, longitude: 12.50),

        Country(name: "Kosovo", capital: "Pristina", continent: "Europe", flag: "🇽🇰",
                population: 1_800_000, area: 10_887,
                funFact: "Kosovo declared independence from Serbia in 2008, making it one of the world's youngest recognised countries.",
                latitude: 42.67, longitude: 21.17),

        Country(name: "Latvia", capital: "Riga", continent: "Europe", flag: "🇱🇻",
                population: 1_800_000, area: 64_589,
                funFact: "Latvia is one of the greenest countries in Europe, with about 56% of its territory covered by forests.",
                latitude: 56.95, longitude: 24.11),

        Country(name: "Liechtenstein", capital: "Vaduz", continent: "Europe", flag: "🇱🇮",
                population: 40_000, area: 160,
                funFact: "Liechtenstein is the world's sixth-smallest country and is doubly landlocked — surrounded entirely by landlocked countries.",
                latitude: 47.14, longitude: 9.52),

        Country(name: "Lithuania", capital: "Vilnius", continent: "Europe", flag: "🇱🇹",
                population: 2_800_000, area: 65_300,
                funFact: "Lithuania was the last country in Europe to convert to Christianity, doing so only in 1387.",
                latitude: 54.69, longitude: 25.28),

        Country(name: "Luxembourg", capital: "Luxembourg City", continent: "Europe", flag: "🇱🇺",
                population: 670_000, area: 2_586,
                funFact: "Luxembourg has the highest GDP per capita in the world and hosts many European Union institutions.",
                latitude: 49.61, longitude: 6.13),

        Country(name: "Malta", capital: "Valletta", continent: "Europe", flag: "🇲🇹",
                population: 530_000, area: 316,
                funFact: "Malta is home to the world's oldest freestanding structures — the Ggantija temples, built around 3,600 BC.",
                latitude: 35.90, longitude: 14.51),

        Country(name: "Moldova", capital: "Chișinău", continent: "Europe", flag: "🇲🇩",
                population: 2_600_000, area: 33_846,
                funFact: "Moldova is home to Mileştii Mici, which holds the world's largest wine collection with over 1.5 million bottles.",
                latitude: 47.01, longitude: 28.86),

        Country(name: "Monaco", capital: "Monaco", continent: "Europe", flag: "🇲🇨",
                population: 40_000, area: 2,
                funFact: "Monaco is the world's second-smallest country and the most densely populated sovereign state on Earth.",
                latitude: 43.73, longitude: 7.42),

        Country(name: "Montenegro", capital: "Podgorica", continent: "Europe", flag: "🇲🇪",
                population: 620_000, area: 13_812,
                funFact: "Montenegro's name means 'Black Mountain' in Venetian, referring to the dark appearance of Mount Lovćen.",
                latitude: 42.44, longitude: 19.26),

        Country(name: "Netherlands", capital: "Amsterdam", continent: "Europe", flag: "🇳🇱",
                population: 17_900_000, area: 41_543,
                funFact: "The Netherlands has more bicycles than people — about 23 million bikes for 17 million residents.",
                latitude: 52.37, longitude: 4.90),

        Country(name: "North Macedonia", capital: "Skopje", continent: "Europe", flag: "🇲🇰",
                population: 2_100_000, area: 25_713,
                funFact: "Lake Ohrid is one of Europe's oldest and deepest lakes, estimated to be over 3 million years old.",
                latitude: 42.00, longitude: 21.43),

        Country(name: "Norway", capital: "Oslo", continent: "Europe", flag: "🇳🇴",
                population: 5_500_000, area: 385_207,
                funFact: "Norway introduced the concept of salmon sushi to Japan in the 1980s, revolutionising global sushi culture.",
                latitude: 59.91, longitude: 10.75),

        Country(name: "Poland", capital: "Warsaw", continent: "Europe", flag: "🇵🇱",
                population: 37_600_000, area: 312_696,
                funFact: "Poland is home to the world's largest castle by land area — Malbork Castle, built by the Teutonic Knights in the 13th century.",
                latitude: 52.23, longitude: 21.01),

        Country(name: "Portugal", capital: "Lisbon", continent: "Europe", flag: "🇵🇹",
                population: 10_200_000, area: 92_212,
                funFact: "Portugal is the world's largest producer of cork, supplying about 50% of the global total.",
                latitude: 38.72, longitude: -9.14),

        Country(name: "Romania", capital: "Bucharest", continent: "Europe", flag: "🇷🇴",
                population: 19_000_000, area: 238_397,
                funFact: "Romania is home to the Danube Delta, one of Europe's best-preserved river deltas and a UNESCO World Heritage Site.",
                latitude: 44.43, longitude: 26.10),

        Country(name: "Russia", capital: "Moscow", continent: "Europe", flag: "🇷🇺",
                population: 144_000_000, area: 17_098_242,
                funFact: "Russia is the world's largest country by land area, spanning 11 time zones and two continents.",
                latitude: 55.75, longitude: 37.62),

        Country(name: "San Marino", capital: "San Marino", continent: "Europe", flag: "🇸🇲",
                population: 34_000, area: 61,
                funFact: "San Marino claims to be the world's oldest republic, founded in 301 AD — older than most European nations.",
                latitude: 43.94, longitude: 12.46),

        Country(name: "Serbia", capital: "Belgrade", continent: "Europe", flag: "🇷🇸",
                population: 6_800_000, area: 77_474,
                funFact: "Serbia is the world's largest producer of raspberries, supplying about 30% of the global total.",
                latitude: 44.80, longitude: 20.46),

        Country(name: "Slovakia", capital: "Bratislava", continent: "Europe", flag: "🇸🇰",
                population: 5_500_000, area: 49_035,
                funFact: "Slovakia has the highest density of castles per square kilometre in the world — over 180 castles and ruins.",
                latitude: 48.15, longitude: 17.11),

        Country(name: "Slovenia", capital: "Ljubljana", continent: "Europe", flag: "🇸🇮",
                population: 2_100_000, area: 20_273,
                funFact: "Slovenia was ranked the most sustainable country in the world and is home to the oldest wheel ever discovered, dating to 3,150 BC.",
                latitude: 46.05, longitude: 14.51),

        Country(name: "Spain", capital: "Madrid", continent: "Europe", flag: "🇪🇸",
                population: 47_400_000, area: 505_990,
                funFact: "Spain is home to La Tomatina — an annual festival where participants throw tomatoes at each other purely for fun.",
                latitude: 40.42, longitude: -3.70),

        Country(name: "Sweden", capital: "Stockholm", continent: "Europe", flag: "🇸🇪",
                population: 10_500_000, area: 450_295,
                funFact: "Sweden invented the safety match, the zipper, and the pacemaker — among many other world-changing inventions.",
                latitude: 59.33, longitude: 18.07),

        Country(name: "Switzerland", capital: "Bern", continent: "Europe", flag: "🇨🇭",
                population: 8_700_000, area: 41_285,
                funFact: "Switzerland has over 1,500 lakes and is home to the headquarters of the Red Cross.",
                latitude: 46.95, longitude: 7.45),

        Country(name: "Ukraine", capital: "Kyiv", continent: "Europe", flag: "🇺🇦",
                population: 37_000_000, area: 603_550,
                funFact: "Ukraine has the largest territory of any country entirely within Europe and was long known as the breadbasket of Europe.",
                latitude: 50.45, longitude: 30.52),

        Country(name: "United Kingdom", capital: "London", continent: "Europe", flag: "🇬🇧",
                population: 68_000_000, area: 242_495,
                funFact: "The United Kingdom invented the World Wide Web, the telephone, the television, and the steam engine.",
                latitude: 51.51, longitude: -0.13),

        Country(name: "Vatican City", capital: "Vatican City", continent: "Europe", flag: "🇻🇦",
                population: 800, area: 0.44,
                funFact: "Vatican City is the world's smallest country at just 0.44 km², and is the headquarters of the Roman Catholic Church.",
                latitude: 41.90, longitude: 12.45),

        // MARK: - Oceania

        Country(name: "Australia", capital: "Canberra", continent: "Oceania", flag: "🇦🇺",
                population: 26_000_000, area: 7_741_220,
                funFact: "Australia has more species of venomous snakes than any other country in the world.",
                latitude: -35.28, longitude: 149.13),

        Country(name: "Fiji", capital: "Suva", continent: "Oceania", flag: "🇫🇯",
                population: 930_000, area: 18_274,
                funFact: "Fiji is made up of 333 islands, of which only 110 are inhabited.",
                latitude: -18.14, longitude: 178.44),

        Country(name: "Kiribati", capital: "South Tarawa", continent: "Oceania", flag: "🇰🇮",
                population: 120_000, area: 811,
                funFact: "Kiribati is the only country in the world to span all four hemispheres — north, south, east, and west.",
                latitude: 1.33, longitude: 172.98),

        Country(name: "Marshall Islands", capital: "Majuro", continent: "Oceania", flag: "🇲🇭",
                population: 40_000, area: 181,
                funFact: "The Marshall Islands was the site of 67 US nuclear tests after World War II, and Bikini Atoll is now a UNESCO World Heritage Site.",
                latitude: 7.10, longitude: 171.38),

        Country(name: "Micronesia", capital: "Palikir", continent: "Oceania", flag: "🇫🇲",
                population: 120_000, area: 702,
                funFact: "Micronesia's Yap Island uses giant stone discs called Rai as a traditional form of currency — some weigh up to 4 tonnes.",
                latitude: 6.92, longitude: 158.16),

        Country(name: "Nauru", capital: "Yaren", continent: "Oceania", flag: "🇳🇷",
                population: 11_000, area: 21,
                funFact: "Nauru is the world's smallest island nation and the third-smallest country by area.",
                latitude: -0.55, longitude: 166.92),

        Country(name: "New Zealand", capital: "Wellington", continent: "Oceania", flag: "🇳🇿",
                population: 5_100_000, area: 270_467,
                funFact: "New Zealand was the first country to give women the right to vote, in 1893.",
                latitude: -41.29, longitude: 174.78),

        Country(name: "Palau", capital: "Ngerulmud", continent: "Oceania", flag: "🇵🇼",
                population: 18_000, area: 459,
                funFact: "Palau was the first country in the world to create a shark sanctuary in 2009, banning all commercial shark fishing.",
                latitude: 7.50, longitude: 134.62),

        Country(name: "Papua New Guinea", capital: "Port Moresby", continent: "Oceania", flag: "🇵🇬",
                population: 10_000_000, area: 462_840,
                funFact: "Papua New Guinea is the world's most linguistically diverse country, with over 800 languages spoken.",
                latitude: -9.44, longitude: 147.18),

        Country(name: "Samoa", capital: "Apia", continent: "Oceania", flag: "🇼🇸",
                population: 220_000, area: 2_842,
                funFact: "Samoa switched which side of the road it drives on in 2009, becoming the first country to do so in decades.",
                latitude: -13.83, longitude: -171.77),

        Country(name: "Solomon Islands", capital: "Honiara", continent: "Oceania", flag: "🇸🇧",
                population: 740_000, area: 28_896,
                funFact: "The Battle of Guadalcanal — one of the most significant WWII Pacific battles — was fought in the Solomon Islands.",
                latitude: -9.43, longitude: 160.05),

        Country(name: "Tonga", capital: "Nukuʻalofa", continent: "Oceania", flag: "🇹🇴",
                population: 100_000, area: 747,
                funFact: "Tonga is the only Pacific Island nation that was never formally colonised by a European power.",
                latitude: -21.14, longitude: -175.22),

        Country(name: "Tuvalu", capital: "Funafuti", continent: "Oceania", flag: "🇹🇻",
                population: 11_000, area: 26,
                funFact: "Tuvalu is so low-lying it could become the first country completely submerged by rising sea levels due to climate change.",
                latitude: -8.52, longitude: 179.20),

        Country(name: "Vanuatu", capital: "Port Vila", continent: "Oceania", flag: "🇻🇺",
                population: 330_000, area: 12_189,
                funFact: "Vanuatu has been ranked as the happiest country on Earth by the Happy Planet Index.",
                latitude: -17.74, longitude: 168.32),
    ]
}
