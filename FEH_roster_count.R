roster = read.csv("FEH_Full_Roster.csv")

#roster_count returns a count of all heroes in the regular 5-star category,
#4-star special category, and demote category as a dataframe. It takes two 
#optional arguments. The first ver_cutoff means to include all heroes up to 
#and including this version number in the count. It's the latest version 
#represented by default. The spc_cutoff is the version number that separates 
#regular 5-star heroes from special heroes. The spc_cutoff is the version 
#number that includes the latest 4-star specials.

roster_count = function(ver_cutoff = max(roster$version), spc_cutoff = 5.02)
{
	hero_counts = matrix(0, 3, 4)
	
	#finding the indexes of the different regular 5-star heroes that are NOT
	#4-star special heroes

	reg_red_5s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Red" & roster$version > spc_cutoff &
		roster$version <= ver_cutoff)

	reg_blue_5s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Blue" & roster$version > spc_cutoff &
		roster$version <= ver_cutoff)

	reg_green_5s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Green" & roster$version > spc_cutoff &
		roster$version <= ver_cutoff)

	reg_cless_5s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Cless" & roster$version > spc_cutoff &
		roster$version <= ver_cutoff)


	#finding the indexes of the different color types of 4-star special heroes

	red_4s_s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Red" & roster$version <= spc_cutoff)

	blue_4s_s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant" |
		(roster$name == "Ephraim" & roster$title == "Dynastic Duo")) & 
		roster$color == "Blue" & roster$version <= spc_cutoff)

	green_4s_s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Green" & roster$version <= spc_cutoff)

	cless_4s_s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Cless" & roster$version <= spc_cutoff)

	#finding the indexes of the 3/4-star heroes

	red_demote = which (roster$type == "Demote Regular" &
		roster$color == "Red" &	roster$version <= ver_cutoff)

	blue_demote = which (roster$type == "Demote Regular" &
		roster$color == "Blue" & roster$version <= ver_cutoff)

	green_demote = which (roster$type == "Demote Regular" &
		roster$color == "Green" & roster$version <= ver_cutoff)

	cless_demote = which (roster$type == "Demote Regular" &
		roster$color == "Cless" & roster$version <= ver_cutoff)
	
	hero_counts[1, ] = c(length(reg_red_5s), length(reg_blue_5s), 
		length(reg_green_5s), length(reg_cless_5s))
	hero_counts[2, ] = c(length(red_4s_s), length(blue_4s_s), 
		length(green_4s_s), length(cless_4s_s))
	hero_counts[3, ] = c(length(red_demote), length(blue_demote), 
		length(green_demote), length(cless_demote))

	hero_counts = data.frame(hero_counts)
	colnames(hero_counts) = c("red", "blue", "green", "cless")
	rownames(hero_counts) = c("reg_5s", "4s_spc", "demotes")
	return(hero_counts)
}

type_count = function(type = "Grail", col = "Red", 
	end_ver = max(roster$version), start_ver = min(roster$version))
{
	return(length(which(roster$type == type & roster$color == col &
		roster$version <= end_ver & roster$version >= start_ver)))

}
