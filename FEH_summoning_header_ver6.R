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
demote_prop = (ini_3s_rate + ini_4s_rate)/ini_non_5s_rate

###END OF VARIABLES THAT NEED TO BE OVERWRITTEN FOR NON-ML BANNERS###



###START OF VARIABLES THAT NEED TO BE OVERWRITTEN FOR NON FULL ROSTER SIMS

max_ver = max(roster$version)
spc_cutoff = 4.08

# Create the color pools for regular 5-stars (pitybreakers), 4-star specials, and
# demotes (3/4-star heroes)
fives_colors = rep(c(1, 2, 3, 4), reg_five_stars(max_ver, spc_cutoff))
fours_spc_colors = rep(c(1, 2, 3, 4), four_star_specials(spc_cutoff))
demote_colors = rep(c(1, 2, 3, 4), demotes(max_ver))

###END OF VARIABLES THAT NEED TO BE OVERWRITTEN FOR NON FULL ROSTER SIMS


orb_cost = c(5, 4, 4, 4, 3) #The first summon in a circle costs 5 orbs, the second 
	#4 orbs and so on


#The function generate_circle accepts the pity rate and focus charges as its arguments. It 
#internally uses variables defined previously in the code such as ini_5s_rate.

#It returns a matrix representing the stones in a summoning circle. The first row of the matrix
#contains numbers representing stone color, and the second row contains numbers representing the
#stone contents. The third row represents the hero index of 5-star focus and 4-star focus heroes


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
	} else if(f_charge == 3)
	{
		fives_focus_rate = fives_rate
			#appearance rate for focus 5-star heroes, adjusted for pity
		fives_non_focus_rate = 0
			#appearance rate for non-focus 5-star heroes, adjusted for pity
	}
	fours_focus_rate = fours_focus_prop*lower_rate
		#appearance rate for the 4-star focus hero, adjusted for pity
	fours_spc_rate = fours_spc_prop*lower_rate
		#appearance rate for 4-star special heroes, adjusted for pity
	demote_rate = demote_prop*lower_rate
		#appearace rate for 3/4-star heroes, adjusted for pity
	probs = c(demote_rate, fives_focus_rate, fives_non_focus_rate, fours_focus_rate,
		fours_spc_rate) 

	# Each stone has three main properties: color, rarity and focus hero contained (if any). 
	# There will be three values associated with hero generation. 
	# Color will be 1-4 with red=1, blue=2, green=3, cless=4. 
	# The second will be a number associated with contents. 1 will be a 5-star focus hero, 
	# 2 will be a 5-star non-focus hero, 3 will be a 4-star focus hero, 4 will be a 4-star 
	# special hero, and 0 will be a regular 3 or 4-star hero (demote).
	# The third value is a number indicating the index number of the hero in the corresponding
	# heroes colors array if they are a focus hero.

	stone_rarity = sample(c(0:4), size=5, replace=TRUE, prob=probs) #generate the rarity of
		#the 5 heroes in a summoning circle

	stone_colors = 0*c(1:5) #vector to hold the stone colors of the five heroes in 
		#the summoning circle
	stone_contents = 0*c(1:5) #vector to hold the index numbers of focus heroes in
		#the summoning circle

	
	demotes = which(stone_rarity == 0) #identify demotes
	l_dem = length(demotes)
	
	#Following if statement is for runtime optimization
	if(l_dem == 5) #if all stones are demotes, generate stone colors, return
	{
		stone_data = matrix(0, 3, 5)
		stone_data[1, ] = sample(demote_colors, size=5, replace=TRUE) 
		return(stone_data)
	}

	stone_colors[demotes] = sample(demote_colors, size=l_dem, replace=TRUE) 
		#generate demote colors
	num_stones_gen = l_dem #keep a running total of how many stones have been generated


	fours_spc = which(stone_rarity == 4) #identify 4-star specials
	l_4spc = length(fours_spc)
	if(l_4spc) #if there are 4-star specials
	{
		stone_colors[fours_spc] = sample(fours_spc_colors, size=l_4spc, replace=TRUE)
			#generate 4-star special colors
		num_stones_gen = num_stones_gen + l_4spc
			#update how many stones have been generated
		if(num_stones_gen == 5) #return data if all stones have been generated
		{
			stone_data = matrix(0, 3, 5)
			stone_data[1, ] = stone_colors
			stone_data[2, ] = stone_rarity
			return(stone_data)
		}
	}


	non_focus_fives = which(stone_rarity == 2) #identify non-focus 5-stars
	l_nf5 = length(non_focus_fives)
	if(l_nf5) #if there are non-focus 5-stars
	{
		stone_colors[non_focus_fives] = sample(fives_colors, size=l_nf5, replace=TRUE)
			#generate non-focus 5-star colors
		num_stones_gen = num_stones_gen + l_nf5
			#update how many stones have been generated
		if(num_stones_gen == 5) #return data if all stones have been generated
		{
			stone_data = matrix(0, 3, 5)
			stone_data[1, ] = stone_colors
			stone_data[2, ] = stone_rarity
			return(stone_data)
		}
	}
	

	
	focus_fives = which(stone_rarity == 1) #identify focus 5-stars
	l_f5 = length(focus_fives)
	if(l_f5) #if there are focus 5-stars
	{
		stone_contents[focus_fives] = sample.int(num_focuses, size=l_f5, replace = TRUE)
			#generate which focus 5-stars are pulled (by hero index number)
		stone_colors[focus_fives] = hero_colors[stone_contents[focus_fives]]
			#update the stone colors according to which focus 5-stars were selected
		num_stones_gen = num_stones_gen + l_f5
			#update how many stones have been generated
		if(num_stones_gen == 5) #return data if all have been generated
		{
			stone_data = matrix(0, 3, 5)
			stone_data[1, ] = stone_colors
			stone_data[2, ] = stone_rarity
			stone_data[3, ] = stone_contents
			return(stone_data)
		}
	}


	focus_fours = which(stone_rarity == 3) #identify focus 4-star heroes
	l_f4 = length(focus_fours)

	#if/else statement generates which focus 4-star hero was pulled, 
	#based off hero index
	if(length(fours_focus_hero) == 1) #if there is only one 4-star focus hero
	{
		stone_contents[focus_fours] = fours_focus_hero #select that one
	} else #otherwise
	{
		stone_contents[focus_fours] = sample(fours_focus_hero, size=l_f4, replace = TRUE)
			#sample from the available 4-star focus heroes
	}
	stone_colors[focus_fours] = hero_colors[stone_contents[focus_fours]]
		#update stone colors appropriately


	#return stone data
	stone_data = matrix(0, 3, 5)
	stone_data[1, ] = stone_colors
	stone_data[2, ] = stone_rarity
	stone_data[3, ] = stone_contents
	return(stone_data)
	
}

#new_circle = generate_circle(0, 0) #creating a new circle for testing purposes