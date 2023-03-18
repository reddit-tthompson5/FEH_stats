roster = read.csv("FEH_Full_Roster.csv")

special_ver_cutoff = 4.08 #version cutoff for 4-star special heroes

#finding the indexes of the different color types of 4-star special heroes

red_4s_s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Red" & roster$version <= special_ver_cutoff)

blue_4s_s = which(((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Blue" & roster$version <= special_ver_cutoff) |
		roster$name == "Ephraim" & roster$type == "Duo")

green_4s_s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Green" & roster$version <= special_ver_cutoff)

cless_4s_s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Cless" & roster$version <= special_ver_cutoff)

#finding the indexes of the different regular 5-star heroes that are NOT
#4-star special heroes

reg_red_5s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Red" & roster$version > special_ver_cutoff)

reg_blue_5s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Blue" & roster$version > special_ver_cutoff)

reg_green_5s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Green" & roster$version > special_ver_cutoff)

reg_cless_5s = which((roster$type == "Five-star Regular" |
		roster$type == "Brave" | roster$type == "Ascendant") & 
		roster$color == "Cless" & roster$version > special_ver_cutoff)

#finding the indexes of the 3/4-star heroes

red_demote = which (roster$type == "Demote Regular" &
	roster$color == "Red")

blue_demote = which (roster$type == "Demote Regular" &
	roster$color == "Blue")

green_demote = which (roster$type == "Demote Regular" &
	roster$color == "Green")

cless_demote = which (roster$type == "Demote Regular" &
	roster$color == "Cless")

reg_five_stars = function()
{
	red = length(reg_red_5s)
	blue = length(reg_blue_5s)
	green = length(reg_green_5s)
	cless = length(reg_cless_5s)
	return(c(red, blue, green, cless))
}

four_star_specials = function()
{
	red = length(red_4s_s)
	blue = length(blue_4s_s)
	green = length(green_4s_s)
	cless = length(cless_4s_s)
	return(c(red, blue, green, cless))
}

demotes = function()
{
	red = length(red_demote)
	blue = length(blue_demote)
	green = length(green_demote)
	cless = length(cless_demote)
	return(c(red, blue, green, cless))
}