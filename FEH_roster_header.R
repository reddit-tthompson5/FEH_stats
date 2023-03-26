#rm(list=ls())
roster = read.csv("FEH_Full_Roster.csv")

#reg_five_stars is a fuction that counts all of the regular 5-star 
#(pitybreaker) heroes by color and returns them. "ver_cutoff" is the max
#version of heroes to include. "spc_ver_cutoff" indicates the highest ver
#number of 4-star special heroes, that aren't to be included in the count.
reg_five_stars = function(ver_cutoff=max(roster$version), spc_ver_cutoff=4.08)
{
	reg_red_5s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Red" & roster$version <= ver_cutoff & 
		roster$version > spc_ver_cutoff)
		#find indicies of regular red 5-star heroes
	
	reg_blue_5s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Blue" & roster$version <= ver_cutoff & 
		roster$version > spc_ver_cutoff)
		#find indicies of regular blue 5-star heroes

	reg_green_5s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Green" & roster$version <= ver_cutoff & 
		roster$version > spc_ver_cutoff)
		#find indicies of regular green 5-star heroes

	reg_cless_5s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Cless" & roster$version <= ver_cutoff &
		roster$version > spc_ver_cutoff)
		#find indicies of regular cless 5-star heroes

	red = length(reg_red_5s) #calc number of red 5-stars
	blue = length(reg_blue_5s) #calc number of blue 5-stars
	green = length(reg_green_5s) #calc number of green 5-stars
	cless = length(reg_cless_5s) #calc number of cless 5-stars
	return(c(red, blue, green, cless)) #return values
}

#similar to "reg_five_stars" function but counts 4-star special heroes instead
four_star_specials = function(spc_ver_cutoff=4.08)
{
	red_4s_s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Red" & roster$version <= spc_ver_cutoff)
	
	blue_4s_s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant" |
		(roster$name == "Ephraim" & roster$name == "Dynastic Duo")) & 
		roster$color == "Blue" & roster$version <= spc_ver_cutoff)

	green_4s_s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Green" & roster$version <= spc_ver_cutoff)

	cless_4s_s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Cless" & roster$version <= spc_ver_cutoff)

	red = length(red_4s_s)
	blue = length(blue_4s_s)
	green = length(green_4s_s)
	cless = length(cless_4s_s)
	return(c(red, blue, green, cless))
}

#similar to "reg_five_stars" function but counts demote (3/4-star) heroes
demotes = function(ver_cutoff=max(roster$version))
{
	red_demote = which (roster$type == "Demote Regular" &
		roster$color == "Red" & roster$version <= ver_cutoff)

	blue_demote = which (roster$type == "Demote Regular" &
		roster$color == "Blue" & roster$version <= ver_cutoff)

	green_demote = which (roster$type == "Demote Regular" &
		roster$color == "Green" & roster$version <= ver_cutoff)

	cless_demote = which (roster$type == "Demote Regular" &
		roster$color == "Cless" & roster$version <= ver_cutoff)
	
	red = length(red_demote)
	blue = length(blue_demote)
	green = length(green_demote)
	cless = length(cless_demote)
	return(c(red, blue, green, cless))
}
