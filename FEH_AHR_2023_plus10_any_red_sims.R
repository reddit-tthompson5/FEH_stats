rm(list = ls()) #clear the objects stored in memory
source("FEH_summoning_header_ver5.R") #include the summoning header which includes
	#the very important "generate_circle" function

#hero_array = c("R!Ophelia", "N!Camilla", "L!Veronica", "Fomortiis")

n = 1000 #number of sessions to sim, in other words the number of trials
	#set to n=1000 for the github repository so if someone runs it with the
	#default values, it doesn't take too long to run

target_color = c(1) #snipe on red = 1 if possible
off_color = c(4) #pull cless, if no red, if possible
first_free = FALSE #don't include a free summon
num_tickets = 0 #given no free tickets for banner
max_orbs = 10000 #used as a failsafe in this case. Can also be used to represent how 
	#many orbs the summoner actually has and to stop the sim there

desired_copies = c(10, 10, 10, 0) #need 10 copies to complete the +10 (1 copy sparked)
num_to_complete = 2 #will stop the sim if two of the heroes meets the desired copies 
	#It's 2 because one of the heroes (Fomortiis) is zero, and so is already
	#'completed' by default

hero_colors = c(1, 1, 1, 4)
	#R!Ophelia is red (1), N!Camilla is red, L!Veronica is red, 
	#Fomortiis is colorless(4)

num_focuses = length(hero_colors) #how many focus heroes are on the banner
target_heroes = which(hero_colors %in% target_color) #what are our target heroes since
	#we're pulling on a particular color(s)

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
fives_focus_acq_n = matrix(0, n, (num_focuses)) #how many of each focus were pulled each trial
fours_focus_acq_n = matrix(0, n, (num_focuses)) #how many 4-star focus heroes pulled
fours_spc_acq_n = matrix(0, n, 4) #how many special heroes of each color were pulled each trial
fives_non_f_acq_n = matrix(0, n, 4) #how many non-foucs five-stars of each color were pulled 
	#each trial
orbs_spent_n = 0*c(1:n) #how many orbs were spent each trial
circles_gen_n = 0*c(1:n) #how many circles are generated to get to spark each trial
circles_wo_target_color_n = 0*c(1:n) #how many circles were generated each trial without
	#the target color (red for this AHR)
max_pity_n = 0*c(1:n) #what is the max pity reached during each trial
max_focus_charge_n = 0*c(1:n) #what was the max number of focus charges seen each trial
charge_used_n = 0*c(1:n) #how often did we use a focus charge
summoned_n = 0*c(1:n) #how many heroes did we summon during a trial (primarily used for error
	#checking)



for(j in 1:n) #j represents a particular trial or summoning session
{	
	#initializing values
	fives_focus_acq = 0*c(1:num_focuses) #no five-star focus heroes pulled 
		#(sorted by focus index)
	fours_focus_acq = 0*c(1:num_focuses) #no four-star focus heroes pulled
		#(sorted by focus index)
	fives_non_f_acq = 0*c(1:4)  #zero non-focus five-stars
		#(sorted by color, 1= red, 2=blue, etc.)
	fours_spc_acq = 0*c(1:4) #zero four-star special heroes
		#(sorted by color)

	orbs_spent = 0 #zero orbs spent
	circles_gen = 0 #zero circles generated
	circles_wo_target_color = 0 #zero circles without the target color
	summoned = 0 #zero heroes summoned
	no_fives = 0 #zero heroes since last five-star (used to calc pity rate)
	focus_charge = 0 #no focus charges
	max_pity = 0 #highest pity is zero
	max_focus_charge = 0 #highest focus charges is zero
	charge_used = 0 #focus charge has been trigged zero times

	all_copies_acquired = FALSE
	#we keep summoning until we reach the desired copies or we don't have enough orbs
	while(all_copies_acquired == FALSE & orbs_spent + orb_cost[1] <= max_orbs)
	{ 
		pity = floor(no_fives/5)*.005 #calc pity
		if(pity > max_pity)
		{
			max_pity = pity
		}

		charged = FALSE 
		if(focus_charge == 3)
		{
			charged = TRUE
		}
		
		new_circle = generate_circle(pity, focus_charge) #generate summoning circle
		circles_gen = circles_gen + 1

		stone_colors = new_circle[1, ]
		stone_rarity = new_circle[2, ]
		stone_contents = new_circle[3, ]
	
		pulling = which(stone_colors %in% target_color) #try to pull stones 
										#w/target color(s)

		if(identical(pulling, integer(0))) #if no stones w/target color(s)
		{
			circles_wo_target_color = circles_wo_target_color + 1
			pulling = which(stone_colors %in% off_color)[1] #try to pull secondary
			
			if(is.na(pulling)) #if no stones w/secondary color(s)
			{	
				pulling = 1 #pull first stone
			}
		}
	
		pulled = 0
		for(i in pulling) #for loop going through each stone we're pulling
		{
 			#only pull if we haven't acquired all copies yet and we're below the max_orbs
			if(all_copies_acquired == FALSE & orbs_spent + orb_cost[pulled+1] <= max_orbs)
			{
				stone_col = stone_colors[i]
				stone_rar = stone_rarity[i]
				stone_con = stone_contents[i]
			
				pulled = pulled + 1
				summoned = summoned + 1
				orbs_spent = orbs_spent + orb_cost[pulled]
	
				if(stone_rar == 0) #If we pull a regular 3 or 4-star hero
				{
					no_fives = no_fives + 1
				}
				else if(stone_rar == 1) #If we pull a 5-star focus hero
				{
					no_fives = 0
					if(charged == TRUE)
					{
						charge_used = charge_used + 1
						focus_charge = 0
						charged = FALSE
					}
					fives_focus_acq[stone_con] = fives_focus_acq[stone_con] + 1
				
					#check to see if we've pulled the desired number of copies of any
					#of our target heroes. Neglecting to do this will result in an infinite
					#loop
					if(length(which(fives_focus_acq >= desired_copies)) >= num_to_complete)
					{
						all_copies_acquired = TRUE
					}
				}
				else if(stone_rar == 2) #If we pull a 5-star non-focus hero
				{
					no_fives = max(0, (no_fives-20))
					if(focus_charge < 3)
					{
						focus_charge = focus_charge + 1
					}
					fives_non_f_acq[stone_col] = fives_non_f_acq[stone_col] + 1
				}
				else if(stone_rar == 3) #If we pull a 4-star focus hero
				{
					no_fives = no_fives + 1
					fours_focus_acq[stone_con] = fours_focus_acq[stone_con] + 1
				}		
				else if(stone_rar == 4) #If we pull a 4-star special hero
				{
					no_fives = no_fives + 1
					fours_spc_acq[stone_col] = fours_spc_acq[stone_col] + 1
				}
			}
		}
		if(focus_charge > max_focus_charge)
		{
			max_focus_charge = focus_charge
		}
	}#End of while loop/end of circle

	if(first_free)
	{
		orbs_spent = orbs_spent - 5
	}

	if(num_tickets > 0)
	{
		circles_for_tickets = circles_gen
		if(first_free)
		{
			circles_for_tickets = circles_for_tickets - 1
		}
		tickets_used = min(num_tickets, circles_for_tickets)
		orbs_spent = orbs_spent - 5*tickets_used
	}

	fives_focus_acq_n[j, ] = fives_focus_acq 
	fours_focus_acq_n[j, ] = fours_focus_acq
	fours_spc_acq_n[j, ] = fours_spc_acq
	fives_non_f_acq_n[j, ] = fives_non_f_acq
	orbs_spent_n[j] = orbs_spent 
	circles_gen_n[j] = circles_gen
	circles_wo_target_color_n[j] = circles_wo_target_color
	max_pity_n[j] = max_pity 
	max_focus_charge_n[j] = max_focus_charge
	charge_used_n[j] = charge_used
	summoned_n[j] = summoned

}# end of trial/for loop

mean_orbs = mean(orbs_spent_n)
mean_orbs
med_orbs = median(orbs_spent_n)
med_orbs
quantile(orbs_spent_n)

