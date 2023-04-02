rm(list = ls()) #clear the objects stored in memory
source("FEH_summoning_header_ver6.R") #include the summoning header which includes
	#the very important "generate_circle" function

#hero_array = c("Hero 1", "Hero 2", "Hero 3", "Hero 4")

n = 1000 #number of sessions to sim, in other words the number of trials
	#set to n=1000 for the github repository so if someone runs it with the
	#default values, it doesn't take too long to run


desired_copies = c(10, 10, 10, 0) #how many copies of each we want (10 of 
	#"Hero 1", "Hero 2", and "Hero 3", and zero of "Hero 4"
num_to_complete = 2 #Any hero with zero desired copies is "completed" by 
	#default, so in this case, the summoner wants to summon 10 copies of
	#one of "Hero 1", "Hero 2", OR "Hero 3" and then stop.
	#If num_to_complete > number of  focus heroes, script will only stop due to max_orbs
off_color = c(3) #secondary color to pull if desired_hero's color does not appear. 
	#Note: This color can match one of the heroes we're already summoning for, which
	#indicates we'll continue to pull their color as a secondary after completing them.
max_orbs = 10000 #used as a failsafe in this case. Can also be used to represent how 
	#many orbs the summoner actually has and to stop the sim there


hero_colors = c(4, 3, 2, 1)
	#"Hero 1" is cless(4), "Hero 2" is green(3), "Hero 3" is blue(2), "Hero 4" is red(1)
fours_focus_hero = c(3)	#index numbers of heroes that also appear as four-star
	#focuses, in this case "Hero 3". If set to 0 (zero), indicates  no 4-star focus heroes. 
	#If no 4-star focus heroes, make sure to set ini_4s_focus_rate = 0.
num_focuses = length(hero_colors)


first_free = FALSE #don't include a free summon
num_tickets = 0 #given no free tickets for banner
focus_charges_active = TRUE #does the banner use focus charges


ini_5s_focus_rate = 0.03 #The initial rate of 5-star focus heroes
ini_5s_non_focus_rate = 0.03 #The initial rate of non-focus 5-star heroes
ini_4s_focus_rate = 0.03 #The initial rate of 4-star focus heroes
ini_4s_spc_rate = 0.03 #The initial rate of 4-star special heroes
ini_4s_rate = 0.52 #The initial rate of 4-star heroes
ini_3s_rate = 0.36 #The initial rate of 3-star heroes

ver_cutoff = max(roster$version)
spc_cutoff = 4.08


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
fives_colors = rep(c(1, 2, 3, 4), reg_five_stars(ver_cutoff, spc_cutoff))
fours_spc_colors = rep(c(1, 2, 3, 4), four_star_specials(spc_cutoff))
demote_colors = rep(c(1, 2, 3, 4), demotes(ver_cutoff))


heroes_pulling = which(desired_copies > 0) #which heroes to pull
ini_colors_pulling = which(c(1, 2, 3, 4) %in% hero_colors[heroes_pulling])
	#which colors to pull initially


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


#time = proc.time()
for(j in 1:n) #j represents a particular trial or summoning session
{	
	#initializing values (will be recorded in "_n" versions)
	orbs_spent = 0 #zero orbs spent
	circles_gen = 0 #zero circles generated
	circles_wo_target_color = 0 #zero circles without the target color
	summoned = 0 #zero heroes summoned
	max_pity = 0 #highest pity is zero
	max_focus_charge = 0 #highest focus charges is zero
	charge_used = 0 #focus charge has been trigged zero times
	
	#(internal loop variables only)
	no_fives = 0 #zero heroes since last five-star (used to calc pity rate)
	focus_charge = 0 #no focus charges
	colors_pulling = ini_colors_pulling


	keep_summoning = TRUE
	#we keep summoning in this session until we reach the desired copies 
	#or we don't have enough orbs
	while(keep_summoning)
	{ 
		pity = floor(no_fives/5)*.005 #calc pity
		if(pity > max_pity)
		{
			max_pity = pity
		}

		charged = FALSE #if we have 3 focus charges, the next 5-star will be a focus
		if(focus_charge == 3)
		{
			charged = TRUE
		}
		
		new_circle = generate_circle(pity, focus_charge) #generate summoning circle
		circles_gen = circles_gen + 1

		stone_colors = new_circle[1, ]
		pulling = which(stone_colors %in% colors_pulling) 
			#try to pull stones that match colors_pulling

		if(length(pulling) == 0) #if no stones w/target color(s)
		{
			circles_wo_target_color = circles_wo_target_color + 1
			pulling = which(stone_colors %in% off_color)[1] #try to pull secondary
			
			if(is.na(pulling)) #if no stones w/secondary color(s)
			{	
				pulling = 1 #pull first stone
			}
		}

		stone_i = 0 #counter for stone to pull
		num_to_pull = length(pulling) #total stones to pull
		stone_rarity = new_circle[2, pulling] #rarity of stones to pull
		stones_left = TRUE #are there stones left to pull?
		while(stones_left) #while loop going through pulling particular circle
		{
			stone_i = stone_i + 1 
			orbs_spent = orbs_spent + orb_cost[stone_i] 
			if(orbs_spent > max_orbs) #stop session if out of orbs
			{
				orbs_spent = orbs_spent - orb_cost[stone_i]
				keep_summoning = FALSE
				break
			}
			summoned = summoned + 1

			stone_rar = stone_rarity[stone_i]
			if(stone_rar == 0) #if we pull a regular 3/4-star hero
			{
				no_fives = no_fives + 1
			}
			else if(stone_rar == 4) #if we pull a 4-star special hero
			{
				no_fives = no_fives + 1
		
				this_stone = pulling[stone_i] #this_stone = which stone number out of 
					#original 5 in circle
				stone_col = stone_colors[this_stone]
				fours_spc_acq_n[j, stone_col] = fours_spc_acq_n[j, stone_col] + 1
					#update 4-star special counter (by color)
			}
			else if(stone_rar == 2) #if we pull a non-focus 5-star hero
			{
				no_fives = max(0, (no_fives-20))
				if(focus_charge < 3 & focus_charges_active)
				{
					focus_charge = focus_charge + 1
				}
				
				this_stone = pulling[stone_i] #this_stone = which stone number out of 
					#original 5 in circle
				stone_col = stone_colors[this_stone]
				fives_non_f_acq_n[j, stone_col] = fives_non_f_acq_n[j, stone_col] + 1
					#update non-focus 5-star counter (by color)
			}
			else if(stone_rar == 1 | stone_rar == 3) #if we pull a focus hero
			{
				this_stone = pulling[stone_i] #this_stone = which stone number out of 
					#original 5 in circle
				stone_con = new_circle[3, this_stone] #index number of which
					#focus hero we pulled
				if(stone_rar == 1) #if we pull a 5-star focus
				{
					no_fives = 0
					if(charged == TRUE)
					{
						charge_used = charge_used + 1
						focus_charge = 0
						charged = FALSE
					}

					fives_focus_acq_n[j, stone_con] = fives_focus_acq_n[j, stone_con] + 1
						#update focus 5-star counter (by hero index)
				} 
				else #if we pull a 4-star focus hero
				{
					no_fives = no_fives + 1

					fours_focus_acq_n[j, stone_con] = fours_focus_acq_n[j, stone_con] + 1
						#update focus 4-star counter (by hero index)	
				}
				
				num_focus_acq = fours_focus_acq_n[j, ] + fives_focus_acq_n[j, ]
					#calc total focus heroes (by index)
				if(length(which(num_focus_acq >= desired_copies)) == num_to_complete)
					#if we've reached the number of desired heroes
				{
					keep_summoning = FALSE
					break
				}
				if(num_focus_acq[stone_con] == desired_copies[stone_con])
					#if we've reached the desired copies of a specific hero
					#update which colors pulling
				{
					heroes_pulling = which(desired_copies > num_focus_acq)
					colors_pulling = which(c(1, 2, 3, 4) %in% hero_colors[heroes_pulling])
					
					if(stone_i < num_to_pull)
						#if there are still stones to pull
						#update which stones IN THIS CIRCLE to pull
						#(This is reason for a while loop iterating through circle, 
						#not a for loop.)
					{
						new_pulling = which(stone_colors %in% colors_pulling)
						pulling = union(pulling[1:stone_i], new_pulling)
						num_to_pull = length(pulling)
						stone_rarity = new_circle[2, pulling]
					}
				}
			}

			if(stone_i == num_to_pull)
			{
				stones_left = FALSE	
			}

		}

		if(focus_charge > max_focus_charge)
		{
			max_focus_charge = focus_charge
		}
	
	}#End of while loop/end of circle

	if(first_free) #update orbs_spent if there's a free summon
	{
		orbs_spent = orbs_spent - 5
	}

	if(num_tickets > 0) #update orbs spent if there are tickets
	{
		circles_for_tickets = circles_gen
		if(first_free)
		{
			circles_for_tickets = circles_for_tickets - 1
		}
		tickets_used = min(num_tickets, circles_for_tickets)
		orbs_spent = orbs_spent - 5*tickets_used
	}

	#record interesting data
	orbs_spent_n[j] = orbs_spent 
	circles_gen_n[j] = circles_gen
	circles_wo_target_color_n[j] = circles_wo_target_color
	max_pity_n[j] = max_pity 
	max_focus_charge_n[j] = max_focus_charge
	charge_used_n[j] = charge_used
	summoned_n[j] = summoned


}# end of trial/for loop
#proc.time() - time

fives_acq = rowSums(fives_focus_acq_n) + rowSums(fives_non_f_acq_n)
focus_acq_n = fives_focus_acq_n + fours_focus_acq_n

mean_orbs = mean(orbs_spent_n)
mean_5s = mean(fives_acq)
mean_focus = mean(rowSums(fives_focus_acq_n))

results = matrix(0, 1, 3)
results = data.frame(results)
colnames(results) = c("avg orbs", "avg 5s", "avg f 5s")
results[1, ] = round(c(mean_orbs, mean_5s, mean_focus), 2)
odds = round(quantile(orbs_spent_n, probs = c(.25, .5, .75, .9, .99))) #orbs versus odds  
cat("\n")
print(results)
cat("\n")
print(odds)