sort ind
gen  ind_dja87 = .

*Drop non-civilian workers
drop if ind1990 >= 940

*Farms
*replace ind_dja87 = 1 if indnaics == "111" | indnaics == "112" 
 replace ind_dja87 = 1 if ind1990 >= 010 & ind1990 <= 030

*Forestry and Related Activities
*replace ind_dja87 = 2 if indnaics == "113M" | indnaics == "1133" | indnaics == "115" | indnaics == "114"
 replace ind_dja87 = 2 if ind1990 >= 031  & ind1990 <= 032
 
*Oil and Gas Extraction
*replace ind_dja87 = 3 if indnaics  == "211"
 replace ind_dja87 = 3 if ind1990 == 042

*Coal Mining
*replace ind_dja87 = 4 if indnaics == "2121"
 replace ind_dja87 = 4 if ind1990 == 041
 
*Non-Energy Mining
*replace ind_dja87 = 5 if indnaics == "2122" | indnaics == "2123"
 replace ind_dja87 = 5 if ind1990 == 040 | ind1990 == 050
 
*Support activities for mining
*replace ind_dja87 = 6 if indnaics == "213"

*Electric Power Generation, Transmition, Distribution
*replace ind_dja87 = 7 if indnaics == "2211P"
 replace ind_dja87 = 7 if ind1990 == 450 | ind1990 == 452 | ind1990 == 472

*Natural Gas Distribution
*replace ind_dja87 = 8 if indnaics == "2212P"
 replace ind_dja87 = 8 if ind1990 == 451 

*Water and Sewage
*replace ind_dja87 = 9 if indnaics == "2213M" | indnaics == "22132" 
 replace ind_dja87 = 9 if ind1990 == 470 | ind1990 == 471
 
*Construction
*replace ind_dja87 = 10 if indnaics == "23"
 replace ind_dja87 = 10 if ind1990 == 060 
 
*Wood products 
*replace ind_dja87 = 11 if indnaics ==
 replace ind_dja87 = 11 if ind1990 >= 230 &  ind1990 <= 241
 
*Nonmetallic mineral products
*replace ind_dja87 = 12 if indnaics == "32711" | indnaics == "32712" | indnaics == "3272" | indnaics == "327M" | indnaics == "3279"
 replace ind_dja87 = 12 if ind1990 >= 250 &  ind1990 <= 262
 
*Primary metals; iron and steel
*replace ind_dja87 = 13 if indnaics == "331M"
 replace ind_dja87 = 13 if ind1990 == 270 | ind1990 == 271
 
*Primary metals; non-ferrous metals 
*replace ind_dja87 = 14 if indnaics == "3313" | indnaics == "3314" | indnaics == "3315"
 replace ind_dja87 = 14 if ind1990 == 272 |  ind1990 == 280
 
*Fabricated metal products
*replace ind_dja87 = 15 if indnaics == "3321" | indnaics == "3322" | indnaics == "332M" | indnaics == "3327" | indnaics == "3328" | indnaics == "33299M" | indnaics == "332MZM"   
*Not clear what to do with 33MS; Was part of 331 and 332 in the former version of NAICS
 replace ind_dja87 = 15 if ind1990 >= 281 &  ind1990 <= 301

*Machinery
*replace ind_dja87 = 16 if indnaics == "33311" | indnaics == "3331M" | indnaics == "3333" | indnaics == "3335" | indnaics == "3336" | indnaics == "333M" | indnaics == "333S"   
 replace ind_dja87 = 16 if ind1990 == 310 | ind1990 == 311 | ind1990 == 312 | ind1990 == 320 | ind1990 == 321 | ind1990 == 331 | ind1990 == 332
 
*Computer and peripheral equip mfg
*replace ind_dja87 = 17 if indnaics == "3341"
 replace ind_dja87 = 17 if ind1990 == 322 

*Communications equipment mfg
*replace ind_dja87 = 18 if indnaics == "334M1"
*There is a problem here, as 334M1 includes both 3342 and 3343; 3343 should be assigned to a different industry (20 in dja98)
 replace ind_dja87 = 18 if ind1990 == 341
 
*Semiconductor and other Electronic component mfg
*replace ind_dja87 = 19 if indnaics == "334M2"
*There is a problem here, as 334M2 includes both 3344 and 3346; 3346 should be assigned to a different industry (20 in dja98)
 *eplace ind_dja87 = 19 if ind1990 == " "
 
*Other electronic equipment
*replace ind_dja87 = 20 if indnaics == "3345"
 replace ind_dja87 = 20 if ind1990 == 340 | ind1990 == 371 | ind1990 == 372 | ind1990 == 380 | ind1990 == 381
 
*Electrical equipment
*replace ind_dja87 = 21 if indnaics == "3352" | indnaics == "335M"
*Here I should exclude industry 33592 (insulated wire). I do not have such a level
*of disagreggation to do so
 replace ind_dja87 = 21 if ind1990 == 342 | ind1990 == 350

*Motor vehicles and parts
*replace ind_dja87 = 22 if indnaics == "336M" | indnaics == "3366" 
 replace ind_dja87 = 22 if ind1990 == 351 
 
*Aircraft and spacecraft
*replace ind_dja87 = 23 if indnaics == "33641M1"
 replace ind_dja87 = 23 if ind1990 == 352
 
*Other transportation equipment
*replace ind_dja87 = 24 if indnaics == "3365" | indnaics == "3369"
 replace ind_dja87 = 24 if ind1990 == 360 | ind1990 == 361 | ind1990 == 362 | ind1990 == 370
 
*Furniture and related products
*replace ind_dja87 = 25 if indnaics == "337"
 replace ind_dja87 = 25 if ind1990 == 242
 
*Miscellaneous manufacturing
*replace ind_dja87 = 26 if indnaics == "3399M" | indnaics == "3399ZM" | indnaics == "3391"
 replace ind_dja87 = 26 if ind1990 == 390 | ind1990 == 391 | ind1990 == 392

*Food and beverage 
*replace ind_dja87 = 27 if indnaics == "311M1" | indnaics == "3113" | indnaics == "3114" | indnaics == "3115" | indnaics == "3116" | indnaics == "311811" | indnaics == "3118Z" | indnaics == "311MZ" | indnaics == "311S"
 replace ind_dja87 = 27 if ind1990 >= 100 & ind1990 <= 122
 
*Tobacco products
*replace ind_dja87 = 28 if indnaics == "3122"
 replace ind_dja87 = 28 if ind1990 == 130
 
*Textile mills and textile product mills 
*replace ind_dja87 = 29 if ind >= 147 & ind <= 159  
*It's easier to do it using ind when we have multiple consecutive industries
 replace ind_dja87 = 29 if ind1990 >= 132 & ind1990 <= 150 
 
*Apparel
*replace ind_dja87 = 30 if indnaics == "3152" | indnaics == "3159"
 replace ind_dja87 = 30 if ind1990 >= 151 & ind1990 <= 152
 
*Leather and allied products 
*replace ind_dja87 = 31 if indnaics == "3162" | indnaics == "316M"
 replace ind_dja87 = 31 if ind1990 >= 220 & ind1990 <= 222
 
*Paper and paper products 
*replace ind_dja87 = 32 if indnaics == "3221" | indnaics == "32221" | indnaics == "3222M"
 replace ind_dja87 = 32 if ind1990 >= 160 & ind1990 <= 162
 
*Printing and related support activities
*replace ind_dja87 = 33 if indnaics == "323"
 replace ind_dja87 = 33 if ind1990 == 171 
 
*Petroleum and coal products
*replace ind_dja87 = 34 if indnaics == "32411" | indnaics == "3241M"
 replace ind_dja87 = 34 if ind1990 == 200 | ind1990 == 201
 
*Chemicals; excl pharma 
*replace ind_dja87 = 35 if indnaics == "3252" | indnaics == "3253" | indnaics == "3255" | indnaics == "3256" | indnaics == "325M"
 replace ind_dja87 = 35 if ind1990 == 180 | ind1990 == 182 | ind1990 == 190 | ind1990 == 191 | ind1990 == 192 
 
*Pharmaceuticals
*replace ind_dja87 = 36 if indnaics == "3254"
 replace ind_dja87 = 36 if ind1990 == 181 
 
*Plastics and rubber products
*replace ind_dja87 = 37 if indnaics == "3261" | indnaics == "32621" | indnaics == "3262M"
 replace ind_dja87 = 37 if ind1990 == 210 | ind1990 == 211 | ind1990 == 212 
 
*Wholesale trade
*replace ind_dja87 = 38 if ind >= 407 & ind <= 459
 replace ind_dja87 = 38 if ind1990 >= 500 & ind1990 <= 571
  
*Retail trade; other
*replace ind_dja87 = 40 if ind  > 469 & ind <= 579
 replace ind_dja87 = 40 if ind1990 >= 580 & ind1990 <= 691 
 replace ind_dja87 = .  if ind1990 == 612
 replace ind_dja87 = .  if ind1990 == 641
 
 *Retail trade; motor vehicles
*replace ind_dja87 = 39 if ind >= 467 & ind <= 469
 replace ind_dja87 = 39 if ind1990 == 612

 *Air transportation
*replace ind_dja87 = 41 if indnaics == "481"
 replace ind_dja87 = 41 if ind1990 == 421
 
*Rail transportation
*replace ind_dja87 = 42 if indnaics == "482"
 replace ind_dja87 = 42 if ind1990 == 400

*Water transportation
*replace ind_dja87 = 43 if indnaics == "483"
 replace ind_dja87 = 43 if ind1990 == 420
 
*Truck transportation
*replace ind_dja87 = 44 if indnaics == "484" 
 replace ind_dja87 = 44 if ind1990 == 410
 
*Transit and ground passenger transportation
*replace ind_dja87 = 45 if indnaics == "485M" | indnaics == "4853"
 replace ind_dja87 = 45 if ind1990 == 401 | ind1990 == 402
 
*Pipeline transportation
*replace ind_dja87 = 46 if indnaics == "486" 
 replace ind_dja87 = 46 if ind1990 == 422
 
*Other transportation and support activities
*replace ind_dja87 = 47 if indnaics == "487" | indnaics == "488"  | indnaics == "491" | indnaics == "492"
 replace ind_dja87 = 47 if ind1990 == 432
 
*Warehousing and storage
*replace ind_dja87 = 48 if indnaics == "493"
 replace ind_dja87 = 48 if ind1990 == 411 
 
*Newspaper; periodical; book publishers
*replace ind_dja87 = 49 if indnaics == "51111"
 replace ind_dja87 = 49 if ind1990 == 171 | ind1990 == 172
 
*Software publishing
*replace ind_dja87 = 50 if indnaics == "5112"
*replace ind_dja87 = 49 if ind1990 == 172 
 
*Motion picture and sound recording industries
*replace ind_dja87 = 51 if indnaics == "5121"
 replace ind_dja87 = 51 if ind1990 == 800

*Broadcasting
*replace ind_dja87 = 52 if ind == 667
 replace ind_dja87 = 52 if ind1990 == 440 

*Telecommunications
*replace ind_dja87 = 53 if indnaics == "51331" | indnaics == "5133Z"
 replace ind_dja87 = 53 if ind1990 == 441 | ind1990 == 442 
 
*Information and data processing services
*replace ind_dja87 = 54 if ind == 669 | ind == 677 | ind == 678 | ind == 679
 replace ind_dja87 = 54 if ind1990 == 732
 
*Federal reserve banks; credit intermediation
*replace ind_dja87 = 55 if ind == 687 | ind == 688 | ind == 689
 replace ind_dja87 = 55 if ind1990 == 700 | ind1990 == 701 | ind1990 == 702 
 
*Securities; commodity contracts; investments
*replace ind_dja87 = 56 if indnaics == "52M2"
 replace ind_dja87 = 56 if ind1990 == 710 

*Insurance carriers and related activities
*replace ind_dja87 = 57 if indnaics == "524"
 replace ind_dja87 = 56 if ind1990 == 711 

*Funds and trusts
*replace ind_dja87 = 58 if indnaics == "52M2" 
*Here we have the problem that 52M2 includes naics industries 523 and 525. Thus, we cannot differentiate between 
*ind_dja = 58 and ind_dja = 56 (523) and  ind_dja = 58 (525)

* This is not a big deal, because when we aggregate them in ind_eu31, industries 55,56,57, and 58 belong to 
* ind_eu31 = 24  

*Real estate (rental)
*replace ind_dja87 = 59 if indnaics == "531"
 replace ind_dja87 = 59 if ind1990 == 712  

*Real estate (owner occupied)
*replace ind_dja87 = 60 if indnaics == "ooh"
* There is no such industry in IMPUMS

*Rental and leasing services; lessors of intangibles
*replace ind_dja87 = 61 if indnaics == "5321" | indnaics == "53223" | indnaics == "532M" | indnaics == "53M"
 replace ind_dja87 = 61 if ind1990 == 42 
 
*Legal services
*replace ind_dja87 = 62 if indnaics == "5415" 
 replace ind_dja87 = 62 if ind1990 == 841 
 
*Computer systems design and related services
*replace ind_dja87 = 63 if indnaics == "5412" | indnaics == "5413" | indnaics == "5414" | indnaics == "5416" | indnaics == "5418" | indnaics == "5419Z" 
*replace ind_dja87 = 63 if ind1990 == "732" 
 
*Misc. professional, scientific
*replace ind_dja87 = 64 if indnaics == "55" | indnaics == "551" | indnaics == "5417"
 replace ind_dja87 = 64 if ind1990 >= 882 & ind1990 <= 891 | ind1990 == 893  
 
*Management of companies and enterprises
*replace ind_dja87 = 65 if indnaics == "5613" | indnaics == "5614"  | indnaics == "5615"  | indnaics == "5616" | indnaics == "5617Z" | indnaics == "56173"  | indnaics == "561M" 
 replace ind_dja87 = 65 if ind1990 == 892 
 
*Administrative & support services
*replace ind_dja87 = 66 if indnaics == "5613"
 *replace ind_dja87 = 66 if ind1990 == 893 
 
*Waste management
*replace ind_dja87 = 67 if indnaics == "562"

*Educational services
*replace ind_dja87 = 68 if ind >= 786 & ind <= 789
 replace ind_dja87 = 68 if ind1990 >= 842 & ind1990 <= 860
 
*Ambulatory health care services
*replace ind_dja87 = 69  if ind >= 797 & ind <= 817
 replace ind_dja87 = 69 if ind1990 >= 812 & ind1990 <= 830
 
*Hospitals, nursing and resid care
*replace ind_dja87 = 70 if indnaics == "622" | indnaics == "623"
 replace ind_dja87 = 70 if ind1990 >= 831 & ind1990 <= 840
 
*Social assistance
*replace ind_dja87 = 71 if indnaics == "6241" | indnaics == "6242" | indnaics == "6243" | indnaics == "6244"
 replace ind_dja87 = 71 if ind1990 >= 861 & ind1990 <= 871
 
*Performating arts; spectator sports; museums
*replace ind_dja87 = 72 if indnaics == "711" | indnaics == "712"
 replace ind_dja87 = 72 if ind1990 == 872 
 
*Amusements and gambling
*replace ind_dja87 = 73 if indnaics == "71395" | indnaics == "713Z"
 replace ind_dja87 = 73 if ind1990 == 802 | ind1990 == 801 | ind1990 == 810
 
*Accommodations
*replace ind_dja87 = 74 if indnaics == "7211" | indnaics == "721M"
 replace ind_dja87 = 74 if ind1990 == 762 | ind1990 == 770 
 
*Food services and drinking places
*replace ind_dja87 = 75 if indnaics == "722Z" | indnaics == "7224"
 replace ind_dja87 = 75 if ind1990 == 641 
 
*Automobile repair
*replace ind_dja87 = 
 replace ind_dja87 = 76 if ind1990 == 751  
 
*Other services (repair; personal svc; organizations)
*replace ind_dja87 = 77 if ind >= 877 & ind <= 919
 replace ind_dja87 = 77 if ind1990 >= 771 & ind1990 <= 791 | ind1990 >= 721 & ind1990 <= 731 | ind1990 >= 740 & ind1990 <= 750 | ind1990 >= 752 & ind1990 <= 760 | ind1990 >= 873 & ind1990 <= 881

*Private households
*replace ind_dja87 = 78 if indnaics == "814"
 replace ind_dja87 = 78 if ind1990 ==  761
 
*Federal gen govt excl health
*replace ind_dja87 = 79 if indnaics == "9211MP" | indnaics == "92113" | indnaics == "92119" | indnaics == "92MP" | indnaics == "923" | indnaics == "92M1" | indnaics == "92M2" | ind == 959 
 replace ind_dja87 = 79 if ind1990 >=  900 & ind1990 <= 932
 replace ind_dja87 = 79 if ind1990 ==  956 
 
*Fed gov health
*replace ind_dja87 = 80

*Federal gov enterprises (ex electric)
replace ind_dja87 = 81 if ind1990 ==  412 
 
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* Now I match dja87 to eu31 using the bridge provided by Mun Ho

gen ind_eu31 = .

*Farms	1	1
replace ind_eu31 = 1 if ind_dja87 == 1

*Forestry and related activities	1	2
replace ind_eu31 = 1 if ind_dja87 == 2

*Oil and gas extraction	2	30
replace ind_eu31 = 2 if ind_dja87 == 3

*Coal mining	2	4
replace ind_eu31 = 2 if ind_dja87 == 4

*Non-energy mining	2	5
replace ind_eu31 = 2 if ind_dja87 == 5

*Support activities for mining	2	6
replace ind_eu31 = 2 if ind_dja87 == 6

*Electric power: generation; transmission; distribution 	16	7
replace ind_eu31 = 16 if ind_dja87 == 7

*Natural gas distribution 	16	8
replace ind_eu31 = 16 if ind_dja87 == 8

*Water and sewage	16	9
replace ind_eu31 = 16 if ind_dja87 == 9

*Construction	17	10
replace ind_eu31 = 17 if ind_dja87 == 10

*Wood products	5	11
replace ind_eu31 = 5 if ind_dja87 == 11

*Nonmetallic mineral products	10	12
replace ind_eu31 = 10 if ind_dja87 == 12

*Primary metals; iron and steel	11	13
replace ind_eu31 = 11 if ind_dja87 == 13

*Primary metals; non-ferrous metals	11	14
replace ind_eu31 = 11 if ind_dja87 == 14

*Fabricated metal products	11	15
replace ind_eu31 = 11 if ind_dja87 == 15

*Machinery	12	16
replace ind_eu31 = 12 if ind_dja87 == 16

*Computer and peripheral equip mfg	13	17
replace ind_eu31 = 13 if ind_dja87 == 17

*Communications equipment mfg	13	18
replace ind_eu31 = 13 if ind_dja87 == 18

*Semiconductor and other Electronic component mfg	13	19
replace ind_eu31 = 13 if ind_dja87 == 19

*Other electronic equipment	13	20
replace ind_eu31 = 13 if ind_dja87 == 20

*Electrical equipment	13	21
replace ind_eu31 = 13 if ind_dja87 == 21

*Motor vehicles and parts	14	22
replace ind_eu31 = 14 if ind_dja87 == 22

*Aircraft and spacecraft	14	23
replace ind_eu31 = 14 if ind_dja87 == 23

*Other transportation equipment	14	24
replace ind_eu31 = 14 if ind_dja87 == 24

*Furniture and related products	5	25
replace ind_eu31 = 5 if ind_dja87 == 25

*Miscellaneous manufacturing	15	26
replace ind_eu31 = 15 if ind_dja87 == 26

*Food and beverage 	3	27
replace ind_eu31 = 3 if ind_dja87 == 27

*Tobacco products	3	28
replace ind_eu31 = 3 if ind_dja87 == 28

*Textile mills and textile product mills	4	29
replace ind_eu31 = 4 if ind_dja87 == 29

*Apparel	4	30
replace ind_eu31 = 4 if ind_dja87 == 30

*Leather and allied products	4	31
replace ind_eu31 = 4 if ind_dja87 == 31

*Paper and paper products	6	32
replace ind_eu31 = 6 if ind_dja87 == 32

*Printing and related support activities	6	33
replace ind_eu31 = 6 if ind_dja87 == 33

*Petroleum and coal products	7	34
replace ind_eu31 = 7 if ind_dja87 == 34

*Chemicals; excl pharma	8	35
replace ind_eu31 = 8 if ind_dja87 == 35

*Pharmaceuticals	8	36
replace ind_eu31 = 8 if ind_dja87 == 36

*Plastics and rubber products	9	37
replace ind_eu31 = 9 if ind_dja87 == 37

*Wholesale trade	19	38
replace ind_eu31 = 19 if ind_dja87 == 38

*Retail trade; motor vehicles	18	39
replace ind_eu31 = 18 if ind_dja87 == 39

*Retail trade; other	20	40
replace ind_eu31 = 20 if ind_dja87 == 40

*Air transportation	22	41
replace ind_eu31 = 22 if ind_dja87 == 41

*Rail transportation	22	42
replace ind_eu31 = 22 if ind_dja87 == 42

*Water transportation	22	43
replace ind_eu31 = 22 if ind_dja87 == 43

*Truck transportation	22	44
replace ind_eu31 = 22 if ind_dja87 == 44

*Transit and ground passenger transportation	22	45
replace ind_eu31 = 22 if ind_dja87 == 45

*Pipelines	22	46
replace ind_eu31 = 22 if ind_dja87 == 46

*Other transportation and support activities	22	47
replace ind_eu31 = 22 if ind_dja87 == 47

*Warehousing and storage	22	48
replace ind_eu31 = 22 if ind_dja87 == 48

*Newspaper; periodical; book publishers	6	49
replace ind_eu31 = 6 if ind_dja87 == 49

*Software publishing	26	50
replace ind_eu31 = 26 if ind_dja87 == 50

*Motion picture and sound recording industries	30	51
replace ind_eu31 = 30 if ind_dja87 == 51

*Broadcasting	23	52
replace ind_eu31 = 23 if ind_dja87 == 52

*Telecommunications	23	53
replace ind_eu31 = 23 if ind_dja87 == 53

*Information and data processing services	26	54
replace ind_eu31 = 26 if ind_dja87 == 54

*Federal reserve banks; credit intermediation	24	55
replace ind_eu31 = 24 if ind_dja87 == 55

*Securities; commodity contracts; investments	24	56
replace ind_eu31 = 24 if ind_dja87 == 56

*Insurance carriers and related activities	24	57
replace ind_eu31 = 24 if ind_dja87 == 57

*Funds and trusts	24	58
replace ind_eu31 = 24 if ind_dja87 == 58

*Real estate (rental)	25	59
replace ind_eu31 = 25 if ind_dja87 == 59

*Real estate (owner occupied)	25	60
replace ind_eu31 = 25 if ind_dja87 == 60

*Rental and leasing services; lessors of intangibles	26	61
replace ind_eu31 = 26 if ind_dja87 == 61

*Legal services	26	62
replace ind_eu31 = 26 if ind_dja87 == 62

*Computer systems design and related services	26	63
replace ind_eu31 = 26 if ind_dja87 == 63

*Misc. professional, scientific	26	64
replace ind_eu31 = 26 if ind_dja87 == 64

*Management of companies and enterprises	26	65
replace ind_eu31 = 26 if ind_dja87 == 65

*Administrative & support services	26	66
replace ind_eu31 = 26 if ind_dja87 == 66

*Waste management	30	67
replace ind_eu31 = 30 if ind_dja87 == 67

*Educational services	28	68
replace ind_eu31 = 28 if ind_dja87 == 68

*Ambulatory health care services	29	69
replace ind_eu31 = 29 if ind_dja87 == 69

*Hospitals, nursing and resid care	29	70
replace ind_eu31 = 29 if ind_dja87 == 70

*Social assistance	29	71
replace ind_eu31 = 29 if ind_dja87 == 71

*Performating arts; spectator sports; museums	30	72
replace ind_eu31 = 30 if ind_dja87 == 72

*Amusements and gambling	30	73
replace ind_eu31 = 30 if ind_dja87 == 73

*Accommodations	21	74
replace ind_eu31 = 21 if ind_dja87 == 74

*Food services and drinking places	21	75
replace ind_eu31 = 21 if ind_dja87 == 75

*Automobile repair	30	76
replace ind_eu31 = 30 if ind_dja87 == 76

*Other services (repair; personal svc; organizations)	30	77
replace ind_eu31 = 30 if ind_dja87 == 77

*Private households	31	78
replace ind_eu31 = 31 if ind_dja87 == 78

*Federal gen govt excl health	27	79
replace ind_eu31 = 27 if ind_dja87 == 79

*Fed gov health	29	80
replace ind_eu31 = 29 if ind_dja87 == 80

*Federal gov enterprises (ex electric)	23	81
replace ind_eu31 = 23 if ind_dja87 == 81

*Fed gov enterp; electric utilities	16	82
replace ind_eu31 = 16 if ind_dja87 == 82

*S&L gov enterprises (ex electric)	27	83
replace ind_eu31 = 27 if ind_dja87 == 83

*S&L gov enterp; electric utilities	16	84
replace ind_eu31 = 16 if ind_dja87 == 84

*S&L gov health	29	85
replace ind_eu31 = 29 if ind_dja87 == 85

*S&L education	28	86
replace ind_eu31 = 28 if ind_dja87 == 86

*S&L excl health and edu	29	87
replace ind_eu31 = 29 if ind_dja87 == 87
