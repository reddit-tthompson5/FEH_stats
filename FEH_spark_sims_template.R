rm(list = ls()) #clear the objects stored in memory
source("FEH_summoning_header_ver6.R") #include the summoning header which includes
	#the very important "generate_circle" function

#hero_array = c("Y!Hector", "Y!Eliwood", "Y!Rebecca", "Mark")

n = 1000 #number of sessions to sim, in other words the number of trials
	#set to n=1000 for the github repository so if someone runs it with the
	#default values, it doesn't take too long to run

target_color = c(4) #snipe on cless = 4 if possible
off_color = c(3) #pull green = 3, if no cless, if possible
first_free = TRUE #include a free summon
num_tickets = 0 #given no free tickets for banner
num_to_summon = 40 #40 summons are needed to spark
target_hero = 3 #index number of target hero. Only used to calc stats at end
	#In this case, Y!Rebecca is indicated as the target

hero_colors = c(3, 1, 4, 2)
	#Y!Hector is green (3), Y!Eliwood is red (1), Y!Rebecca is cless (4), 
	#Mark is blue (2)
fours_focus_hero = c(3)	#Index numbers of heroes that also appear as four-star
	#focuses. In this case, "Y!Rebecca" is a 4-star focus unit as well.
	#If set to 0 (zero), indicates no 4-star focus heroes. 
	#If no 4-star focus heroes, set ini_4s_focus_rate = 0 as well
num_focuses = length(hero_colors) #how many focus heroes are on the banner

ini_5s_focus_rate = 0.03 #The initial rate of 5-star focus heroes
ini_5s_non_focus_rate = 0.03 #The initial rate of non-focus 5-star heroes
ini_4s_focus_rate = 0.03 #The initial rate of 4-star focus heroes
ini_4s_spc_rate = 0.03 #The initial rate of 4-star special heroes
ini_4s_rate = 0.52 #The initial rate of 4-star heroes
ini_3s_rate = 0.36 #The initial rate of 3-star heroes

max_ver = max(roster$version) #indicates we want to include all heroes up to and 
	#including this version in the regular 5-star (pitybreakers) pool
spc_cutoff = 4.08 #indicates which version (including this version) to use for
	#the 4-star special (not pitybreakers) pool

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


# Create the color pools for regular 5-stars (pitybreakers), 4-star specials, and
# demotes (3/4-star heroes)
fives_colors = rep(c(1, 2, 3, 4), reg_five_stars(max_ver, spc_cutoff))
fours_spc_colors = rep(c(1, 2, 3, 4), four_star_specials(spc_cutoff))
demote_colors = rep(c(1, 2, 3, 4), demotes(max_ver))



#creating variables to bookkeep interesting data
fives_focus_acq_n = matrix(0, n, (num_focuses)) 
	#how many of each focus were pulled each trial
fours_focus_acq_n = matrix(0, n, (num_focuses)) 
	#how many 4-star focus heroes pulled
fours_spc_acq_n = matrix(0, n, 4) 
	#how many special heroes of each color were pulled each trial
fives_non_f_acq_n = matrix(0, n, 4) 
	#how many non-foucs five-stars of each color were pulled each trial
orbs_spent_n = 0*c(1:n) 
	#how many orbs were spent each trial
circles_gen_n = 0*c(1:n) 
	#how many circles are generated to get to spark each trial
circles_wo_target_color_n = 0*c(1:n) 
	#how many circles were generated each trial without the target color
max_pity_n = 0*c(1:n) 
	#what is the max pity reached during each trial
max_focus_charge_n = 0*c(1:n) 
	#what was the max number of focus charges seen each trial
charge_used_n = 0*c(1:n) 
	#how many times a focus charge was used
summoned_n = 0*c(1:n) 
	#how many heroes summoned during a trial (used for error checking)


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

	while(summoned < num_to_summon)
		#we keep summoning until we reach the num_to_summon
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
		
		new_circle = generate_circle(pity, focus_charge) 
			#generate summoning circle
		circles_gen = circles_gen + 1

		stone_colors = new_circle[1, ]
		stone_rarity = new_circle[2, ]
		stone_contents = new_circle[3, ]
	
		pulling = which(stone_colors %in% target_color) #try to pull stones 
										#w/target color(s)

		if(length(pulling) == 0) #if no stones w/target color(s)
		{
			circles_wo_target_color = circles_wo_target_color + 1
			pulling = which(stone_colors %in% off_color)[1] 
				#try to pull secondary
			
			if(is.na(pulling)) #if no stones w/secondary color(s)
			{	
				pulling = 1 #pull first stone
			}
		}
		if((length(pulling) + summoned) > num_to_summon) #don't pull more than 
											#num_to_summon
		{
			num_left = num_to_summon - summoned
			pulling = pulling[1:num_left]
		}
		summoned = summoned + length(pulling)
	
		pulled = 0
		for(i in pulling) #for loop going through each stone we're pulling
					#in the circle
		{
			stone_col = stone_colors[i]
			stone_rar = stone_rarity[i]
			stone_con = stone_contents[i]
		
			pulled = pulled + 1
			orbs_spent = orbs_spent + orb_cost[pulled]
		
			if(stone_rar == 0) #If we pull a regular 3 or 4-star hero
			{
				no_fives = no_fives + 1

			} else if(stone_rar == 1) #If we pull a 5-star focus hero
			{
				no_fives = 0
				if(charged == TRUE)
				{
					charge_used = charge_used + 1
					focus_charge = 0
					charged = FALSE
				}
				fives_focus_acq[stone_con] = fives_focus_acq[stone_con] + 1

			} else if(stone_rar == 2) #If we pull a 5-star non-focus hero
			{
				no_fives = max(0, (no_fives-20))
				if(focus_charge < 3)
				{
					focus_charge = focus_charge + 1
				}
				fives_non_f_acq[stone_col] = fives_non_f_acq[stone_col] + 1

			} else if(stone_rar == 3) #If we pull a 4-star focus hero
			{
				no_fives = no_fives + 1
				fours_focus_acq[stone_con] = fours_focus_acq[stone_con] + 1

			} else if(stone_rar == 4) #If we pull a 4-star special hero
			{
				no_fives = no_fives + 1
				fours_spc_acq[stone_col] = fours_spc_acq[stone_col] + 1
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


fives_acq = rowSums(fives_focus_acq_n) + rowSums(fives_non_f_acq_n)

mean_orbs = mean(orbs_spent_n)
mean_5s = mean(fives_acq)
mean_focus = mean(rowSums(fives_focus_acq_n) + rowSums(fours_focus_acq_n))
mean_target = mean(fives_focus_acq_n[, target_hero] + 
	fours_focus_acq_n[, target_hero])
odds_target = length(which(fives_focus_acq_n[, target_hero] > 0 |
	fours_focus_acq_n[, target_hero] > 0))/n
odds_focus_5s = length(which(rowSums(fives_focus_acq_n) > 0))/n
odds_5s = length(which(fives_acq > 0))/n

results = matrix(0, 1, 7)
results = data.frame(results)
colnames(results) = c("avg orbs", "avg 5s", "avg focuses", "avg target", 
	"odds target", "odds f 5s", "odds 5s")
results[1, ] = round(c(mean_orbs, mean_5s, mean_focus, mean_target, 
	100*odds_target, 100*odds_focus_5s, 100*odds_5s), 2)

print(results)