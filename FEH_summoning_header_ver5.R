#The purpose of this header is to reduce the time needed to program custom
#summon simulations for the game Fire Emblem heroes, using the R programming
#language

#By default, the header includes data set for summoning on regular mythic/legendary
#(ML) banners. If the simulation is being run for a different type of banner, 
#it's recommended that you overwrite these values in the script for that simulation
#instead of changing them here.

source("FEH_roster_header.R")

#hero_array = c("Lif", "L!Lilina", "B!Marth", "L!F!Byleth", "B!Eirika", 
#	"Seiros", "Freyja", "Gatekeeper", "L!M!Byleth", "Ash", "Yuri", "B!Marianne")
	#The array of hero_names is not used in these sample scripts, but
	#can help the programmer keep in mind the index number used for these
	#heroes in other vectors/matricies

###START OF VARIABLES THAT NEED TO BE OVERWRITTEN FOR NON-ML BANNERS###

hero_colors = c(1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4)
	#The hero_colors array assigns the colors of the legendary/mythic focus
	#heroes with 1=red, 2=blue, 3=green, and 4 = colorless. Lif is in the
	#first position, and his color is red, L!Lilina in the second and so on

num_focuses = length(hero_colors) #how many focus heroes are on the banner

fours_focus_hero = c(0)	#index numbers of heroes that also appear as four-star
	#focuses. If "B!Marth" were a four-star focus hero, we would put 3 as 
	#one of the values. 

ini_5s_focus_rate = 0.08 #The initial rate of 5-star focus heroes on ML banners
ini_5s_non_focus_rate = 0 #The initial rate of non-focus 5-star heroes
ini_4s_focus_rate = 0 #The initial rate of 4-star focus heroes
ini_4s_spc_rate = .03 #The initial rate of 4-star special heroes
ini_4s_rate = .55 #The initial rate of 4-star heroes
ini_3s_rate = .34 #The initial rate of 3-star heroes

# We calculate the proportion of each type of 5-star, so we know how to split the pity
ini_5s_rate = ini_5s_focus_rate + ini_5s_non_focus_rate
fives_focus_prop = ini_5s_focus_rate/ini_5s_rate
fives_non_focus_prop = ini_5s_non_focus_rate/ini_5s_rate


# Next we figure out how much of the non-5-star rate each group represents of the 
# non-5-stars
ini_non_5s_rate = ini_4s_focus_rate + ini_4s_spc_rate + ini_4s_rate + ini_3s_rate
fours_focus_prop = ini_4s_focus_rate/ini_non_5s_rate
fours_spc_prop = ini_4s_spc_rate/ini_non_5s_rate
fours_prop = ini_4s_rate/ini_non_5s_rate
threes_prop = ini_3s_rate/ini_non_5s_rate

###END OF VARIABLES THAT NEED TO BE OVERWRITTEN FOR NON-ML BANNERS###


orb_cost = c(5, 4, 4, 4, 3) #The first summon in a circle costs 5 orbs, the second 
	#4 orbs and so on

reg_fives = reg_five_stars()

red_5s = reg_fives[1] #number of red non-focus 5-stars available to summon
blue_5s = reg_fives[2] #number of blue non-focus 5-stars available to summon
green_5s = reg_fives[3] #number of green non-focus 5-stars available to summon
cless_5s = reg_fives[4] #number of colorless non-focus 5-stars available to summon
total_5s = sum(reg_fives) #total number of non-focus 5-stars available

fives_colors = rep(c(1, 2, 3, 4), reg_fives)


four_ss = four_star_specials()

red_4s_spc = four_ss[1] #number of red special 4-stars available to summon
blue_4s_spc = four_ss[2] #number of blue special 4-stars available to summon
green_4s_spc = four_ss[3] #number of green special 4-stars available to summon
cless_4s_spc = four_ss[4] #number of colorless special 4-stars available to summon
total_4s_spc = sum(four_ss) #total number of 4-star special units available to summon

fours_spc_colors = rep(c(1, 2, 3, 4), four_ss)


dem = demotes()

red_4s = dem[1] #number of red 4-stars available
blue_4s = dem[2] #number of blue 4-stars available
green_4s = dem[3] #number of green 4-stars available
cless_4s = dem[4] #number of colorless 4-stars available
total_4s = sum(dem) #total number of 4-star heroes available to summon

fours_colors = rep(c(1, 2, 3, 4), dem)

threes_colors = fours_colors



#The function generate_circle accepts the pity rate and focus charges as its arguments. It 
#internally uses variables defined previously in the code such as ini_5s_rate.

#It returns a matrix representing the stones in a summoning circle. The first row of the matrix
#contains numbers representing stone color, and the second row contains numbers representing the
#stone contents. The third row represents the hero index of 5-star focus and 4-star focus heroes

error0 = FALSE

generate_circle = function(pity, f_charge)
{
	fives_rate = ini_5s_rate + pity
	lower_rate = 1 - fives_rate 
	if(f_charge < 3)
	{
		fives_focus_rate = fives_focus_prop*fives_rate
			#appearance rate for focus 5-star heroes, adjusted for pity
		fives_non_focus_rate = fives_non_focus_prop*fives_rate
			#appearance rate for non-focus 5-star heroes, adjusted for pity
	}
	else if(f_charge == 3)
	{
		fives_focus_rate = fives_rate
			#appearance rate for focus 5-star heroes, adjusted for pity
		fives_non_focus_rate = 0
			#appearance rate for non-focus 5-star heroes, adjusted for pity
	}
	else
	{
		error0 = TRUE
	}
	fours_focus_rate = fours_focus_prop*lower_rate
		#appearance rate for the 4-star focus hero, adjusted for pity
	fours_spc_rate = fours_spc_prop*lower_rate
		#appearance rate for 4-star special heroes, adjusted for pity
	fours_rate = fours_prop*lower_rate
		#appearace rate for 4-star heroes, adjusted for pity
	threes_rate = threes_prop*lower_rate
		#appearace rate for 3-star heroes, adjusted for pity

	fives_focus_cutoff = fives_focus_rate
	fives_non_focus_cutoff = fives_focus_cutoff + fives_non_focus_rate
	fours_focus_cutoff = fives_non_focus_cutoff + fours_focus_rate 
	fours_spc_cutoff = fours_focus_cutoff + fours_spc_rate
	fours_cutoff = fours_spc_cutoff + fours_rate
	threes_cutoff = fours_cutoff + threes_rate # should be 1


	# Each stone has three main properties: color, rarity and focus hero contained (if any). 
	# There will be three values associated with hero generation. 
	# Color will be 1-4 with red = 1, blue=2, green =3, cless=4. 
	# The second will be a number associated with contents. 1 will be a 5-star focus hero, 
	# 2 will be a 5-star non-focus hero, 3 will be a 4-star focus hero, 4 will be a 4-star 
	# special hero, and 0 will be a regular 3 or 4-star hero.
	# The third value is a number indicating the index number of the hero in the corresponding
	# heroes colors array

	stone_colors = 0*c(1:5) #vector to hold the stone colors of the five heroes in 
		#a summoning circle
	stone_rarity = 0*c(1:5) #vector to hold the rarity of the 5 stones 
		#a summoning circle
	stone_contents = 0*c(1:5) #vector to hold the index numbers of focus heroes

	heroes_gen = runif(5) #randomly generate the rarity of the heroes according to the cutoffs
	#heroes_gen = c(.01, .04, .07, .10, .15) #This vector is for testing purposes. Please leave
		#commented unless you're testing the circle generation function

	#Following block of code interprets the rarity based off pity and the heroes_gen vector
	threes = which(heroes_gen > fours_cutoff)
	fours = which(heroes_gen > fours_spc_cutoff & heroes_gen <= fours_cutoff)
	fours_spc = which(heroes_gen > fours_focus_cutoff & heroes_gen <= fours_spc_cutoff)
	fours_focus = which(heroes_gen > fives_non_focus_cutoff & heroes_gen <= fours_focus_cutoff)
	fives_non_focus = which(heroes_gen > fives_focus_cutoff 
		& heroes_gen <= fives_non_focus_cutoff)
	fives_focus = which(heroes_gen <= fives_focus_cutoff)

	#Assign the stone rarity according to the heroes_gen vector (5-star, 4-star, etc)
	stone_rarity[fives_focus] = 1
	stone_rarity[fives_non_focus] = 2
	stone_rarity[fours_focus] = 3
	stone_rarity[fours_spc] = 4
	# The rarity for 3/4 star heroes doesn't need to be assigned as the values in the 
	# stone_rarity vector are initialize to zero


	#Assign stone contents for 5-star and 4-star focus heroes
	stone_contents[fives_focus] = sample.int(num_focuses, length(fives_focus), replace = TRUE)
	if(length(fours_focus_hero) > 1)
	{
		stone_contents[fours_focus] = sample(fours_focus_hero, length(fours_focus), replace = TRUE)
	} else
	{
		stone_contents[fours_focus] = fours_focus_hero
	}


	#Assign the stone colors based off hero rarity
	stone_colors[fives_focus] = hero_colors[stone_contents[fives_focus]]
	stone_colors[fives_non_focus] = sample(fives_colors, size=length(fives_non_focus),
		replace=TRUE)
	stone_colors[fours_focus] = hero_colors[stone_contents[fours_focus]]
	stone_colors[fours_spc] = sample(fours_spc_colors, size=length(fours_spc), replace=TRUE)
	stone_colors[fours] = sample(fours_colors, size=length(fours), replace=TRUE)
	stone_colors[threes] = sample(threes_colors, size=length(threes), replace=TRUE)
	
	stone_data = matrix(0, 3, 5)
	stone_data[1, ] = stone_colors
	stone_data[2, ] = stone_rarity
	stone_data[3, ] = stone_contents
	return(stone_data)
}

new_circle = generate_circle(0, 0) #creating a new circle for testing purposes
