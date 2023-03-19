rm(list = ls()) #clear the objects stored in memory
source("FEH_summoning_header_ver5.R") #include the summoning header which includes
	#the very important "generate_circle" function

#The purpose of this script is to estimate the conditional probabilities associated 
#with the free summon in fire emblem heroes.
#That is this script attempts to answer "How likely is it I pull a 5-star if I free-
#summon on [color]?" on the 2023 AHR banner

#hero_array = c("R!Ophelia", "N!Camilla", "L!Veronica", "Fomortiis")

n = 1000000 #number of sessions to sim, in other words the number of trials

# num_to_summon = 1 #(not used) We are going to pull 1 time on the banner

hero_colors = c(1, 1, 1, 4)
	#R!Ophelia is red (1), N!Camilla is red, L!Veronica is red, 
	#Fomortiis is colorless(4)

num_focuses = length(hero_colors) #how many focus heroes are on the banner

fours_focus_hero = c(0)	#index numbers of heroes that also appear as four-star
	#focuses. 

ini_5s_focus_rate = 0.03 #The initial rate of 5-star focus heroes
ini_5s_non_focus_rate = 0.03 #The initial rate of non-focus 5-star heroes
ini_4s_focus_rate = 0 #The initial rate of 4-star focus heroes
ini_4s_spc_rate = 0.03 #The initial rate of 4-star special heroes
ini_4s_rate = 0.55 #The initial rate of 4-star heroes
ini_3s_rate = 0.36 #The initial rate of 3-star heroes

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



#creating variables to bookkeep interesting data
fives_focus_acq_nm = matrix(0, n, 4)
fours_focus_acq_nm = matrix(0, n, 4) 
fours_spc_acq_nm = matrix(0, n, 4)
fives_non_f_acq_nm = matrix(0, n, 4) 
circles_wo_target_color_nm = matrix(0, n, 4)
summoned_nm = matrix(0, n, 4)

for(i in 1:4) #for each of red=1, blue=2, green=3, and cless=4
{
	fives_focus_acq_m = 0*c(1:n)
	fours_focus_acq_m = 0*c(1:n)
	fours_spc_acq_m = 0*c(1:n)
	fives_non_f_acq_m = 0*c(1:n)
	circles_wo_target_color_m = 0*c(1:n)
	summoned_m = 0*c(1:n)

	for(j in 1:n) #j represents a particular trial or summoning session
	{
		#initializing values
		fives_focus_acq = 0
		fours_focus_acq = 0
		fours_spc_acq = 0
		fives_non_f_acq = 0
		circles_wo_target_color = 0
		summoned = 0

		pulled = FALSE
		while(pulled == FALSE)
		{
			new_circle = generate_circle(0, 0)
			stone_colors = new_circle[1, ]
			stone_rarity = new_circle[2, ]
			stone_contents = new_circle[3, ]
	
			stone_to_pull = which(stone_colors == i)[1]
			if(is.na(stone_to_pull))
			{
				circles_wo_target_color = circles_wo_target_color + 1
			}
			else
			{
				pulled = TRUE
				summoned = summoned + 1
				
				stone_rar = stone_rarity[stone_to_pull]
				stone_con = stone_contents[stone_to_pull]

				if(stone_rar == 1)
				{
					fives_focus_acq = fives_focus_acq + 1
				}
				else if(stone_rar == 2)
				{
					fives_non_f_acq = fives_non_f_acq + 1
				}
				else if(stone_rar == 3)
				{
					fours_focus_acq = fours_focus_acq + 1
				}
				else if(stone_rar == 4)
				{
					fours_spc_acq = fours_spc_acq + 1
				}
			}

		}

		fives_focus_acq_m[j] = fives_focus_acq 
		fours_focus_acq_m[j] = fours_focus_acq
		fours_spc_acq_m[j] = fours_spc_acq
		fives_non_f_acq_m[j] = fives_non_f_acq
		circles_wo_target_color_m[j] = circles_wo_target_color
		summoned_m[j] = summoned

	}
	fives_focus_acq_nm[, i] = fives_focus_acq_m
	fours_focus_acq_nm[, i] = fours_focus_acq_m
	fours_spc_acq_nm[, i] = fours_spc_acq_m
	fives_non_f_acq_nm[, i] = fives_non_f_acq_m
	circles_wo_target_color_nm[, i] = circles_wo_target_color_m
	summoned_nm[, i] = summoned_m
}

round(100*colSums(fives_focus_acq_nm)/n, 2)
round(100*colSums(fives_non_f_acq_nm)/n, 2)
round(100*colSums(fours_focus_acq_nm)/n, 2)
round(100*colSums(fours_spc_acq_nm)/n, 2)
colSums(circles_wo_target_color_nm)
colSums(summoned_nm)

red_appearance = round(n/(n + sum(circles_wo_target_color_nm[, 1])), 4)
blue_appearance = round(n/(n + sum(circles_wo_target_color_nm[, 2])), 4)
green_appearance = round(n/(n + sum(circles_wo_target_color_nm[, 3])), 4)
cless_appearance = round(n/(n + sum(circles_wo_target_color_nm[, 4])), 4)