# Basic Description and Contact
These R scripts are intended to simulate summoning in the mobile game Fire Emblem Heroes (FEH). These scripts are provided freely but come with absolutely no warranty. However, I will do my best to fix any bugs or issues as they come to my attention.

If you find any issues or have any questions, please message u/tthompson5 through reddit.com. Alternatively, you can email me at reddit.tthompson5@gmail.com, but the response will be much slower.

These scripts are in NO way associated with https://www.fullyconcentrated.net/fehstatsim/ Any questions regarding that site should be directed to u/minno on reddit. If you are looking to do a fast and simple summoning simulation that compares orbs versus odds, I do recommend minno's site.

# Description of Summoning in FEH
FEH is a strategy game where a player (or "summoner") deploys units (or "heroes") to fight for them on a fantasy battlefield. It is a free-to-play (or "free-to-start" as the publisher Nintendo likes to say) mobile game available on iOS and Android devices.

Most of the game's units can be obtained through an in-game gacha system (similar to a lootbox) where players gamble an in-game currency (called "orbs") to try to obtain specific units. These orbs are awarded through gameplay and can also be purchased for real-world currency in micro (or not-so-micro) transactions, which is a common monetization strategy for free-to-play games.

When a player wants to gamble for heroes through the gacha system (also known as "summoning" or "pulling" heroes), they go to a special summoning screen. The first step in summoning is choosing a banner to summon on. Each banner features focus heroes, and summoners typically choose a banner to try to obtain one or more of those particular focus heroes. Some heroes can only be obtained through the gacha when a summoner is summoning on a banner that features them as a focus hero. Other heroes are merely much more likely to be obtained when they are featured as a focus hero on the corresponding banner.

Once a player selects a banner, they hit a large green button to begin summoning. The player may hit this button once for free per banner. Sometimes a summoner will have one or more summoning tickets available to hit the button for "free" again.  After that, they will have to spend 5 orbs to hit the button.

Once the button has been hit, the player will be presented with a circle of 5 colored stones. These stones will be 1 of 4 colors: red, blue, green, or colorless. These colors correspond to the four colors of heroes in the game. Colors are determined by a hero's weapon color. For instance, sword units in FEH are red and lance units are blue. Once the summoner choses one of the stones, they are given a hero of the corresponding color. In this way, the colors of the stones hint at the hero the summoner will be given.

Once the summoner has chosen 1 of the 5 colored stones, they have the option to either exit the current summoning circle or continue choosing from the remaining stones - for additional orbs - until all 5 stones have been chosen. The second, third, and fourth stones in a circle cost 4 orbs each, and the fifth stone costs 3 orbs. Thus, the cost to pull an entire circle is 20 orbs - or 15 if the first summon was free. Once the summoner has exited the circle, they can choose to generate another circle for 5 orbs (or a ticket - if available).

Many times, summoners only choose stones that are the same color as their desired focus (or target) hero to take advantage of conditional probability and increase their odds of obtaining their target hero. This is called "sniping." This strategy is often preferred over pulling "full circles," even though there is a discount for pulling more than one stone in a circle. 

## Details on Summoning
In the early days of FEH, summoning was more straight-forward than it is now. Over time, the summoning mechanics in FEH have become increasingly complex as its developer (Intelligent Systems or IS) has attempted to make summoning more appealing and extremely bad outcomes from the gacha more rare. This is likely because it is well-known that players will sometimes quit gacha games after experiencing extremely bad luck. (Although summoning in FEH has become more "generous," FEH is still a gacha game and extremely bad outcomes can still occur.) However, the complexity of summoning in FEH does make it interesting to model.

There are seven categories of heroes that may appear from summoning on a banner: 5-star focus heroes (availble on all banners), 5-star non-focus heroes (available on most banners), 4-star focus heroes (some banners), 4-star special heroes (all banners), 4-star SH special heroes (a few banners), 4-star heroes (all banners), and 3-star heroes (all banners). (Note that 4-star SH special heroes are currently not implemented in the scripts, and I do not currently have plans to do so.) Three and 4-star (non-special) heroes are generally considered less desirable than the other categories of heroes and are sometimes referred to as "demotes." Currently the heroes available at 3-star rarity are identical to the heroes available at 4-star rarity. Each of the seven categories has an appearance rate associated with it. For instance, focus heroes usually have an inital appearance rate between 3% and 8%, depending on the particular banner.

For each stone in a summoning circle, FEH selects the category of the hero first. Then, a hero of that category is selected. Each hero within a particular category has an equal chance of selection. Once the hero is selected, FEH presents the hero's color as the stone's color to the summoner with no additional hints at the hero's identity. Contrary to a common misperception, the identities and rarities of all the heroes represented in the summoning circle are determined before the circle is presented to the summoner. FEH does NOT randomly pick a hero of the right color when the summoner selects that color. For this reason, the colors of the summoning stones are not randomly uniform and depend instead on the distribution of colors among the possible heroes.

Additionally, FEH attempts to incentivize summoners to continue summoning on a particular banner through a "pity" system. FEH keeps a count of how many heroes a summoner has pulled that are not 5-star heroes. For every 5 such heroes (rounded down to the nearest 5), FEH increases the odds of a 5-star (focus or non-focus) hero by 0.5% (half a percent) and distributes this pity proportionally to the initial appearance rates in the focus and non-focus 5-star categories. For instance, if the initial appearance rate of 5-star focus heroes is 3% and non-focus heroes is also 3%, a 0.5% "pity" would be distributed evenly and the appearance rates of each category would become 3.25%. If the initial rate of 5-star focus heroes is 5% and non-focus 5-stars is 3%, a 0.5% pity would result in an appearance rate of 5-star focus heroes of 5.31% and of 5-star non-focus heroes of 3.19%. Appearance rates are only referenced when the circle is generated. This is because this is when all 5 heroes in the 5 summoning stones are selected. This means that the appearance rates within a particular summoning circle are fixed and do not dynamically change within that circle.

When a summoner pulls a 5-star focus hero, the pity is reset to zero, and the count of non-5-star heroes starts over. When a summoner pulls a 5-star non-focus hero, the count of non-5-star heroes is subtracted by 20 (to a minimum value of zero), so the pity amount is decreased by up to 2%. This is why non-focus 5-star units are sometimes called "pitybreakers" by players.

Additionally, there's a special pity rule. If the non-5-star count reaches 120, the summoning rates for 5-star heroes will be increased to 100% with the exact percentage for focus 5-stars and non-focus 5-stars determined by their initial appearance rate proportions (unless the player has activated focus charges, more on that in the next paragraph). For instance, if the initial rate of focus 5-stars was 5% and of non-focus 5-stars was 3%, the rates would be 62.5% for focus 5-stars and 37.5% for non-focus 5-stars. For this reason, if a player ever reaches a non-5-star count of 120, they should immediately exit the summoning circle so they can take full advantage of the 100% rate on the next circle. However, this special rule comes into play so rarely that it's only ever been documented to have happened once to the knowledge of this coder (and is not currently coded into the summoning sims due to this extreme unlikeliness.)

Recently (at the time of writing this README), FEH introduced a new summoning mechanic called "focus charges." Only available on some banners, a focus charge is given whenever a non-focus 5-star unit is pulled up to a maximum of 3 focus charges. When 3 focus charges have been acquired, a "focus charge" state will become active, starting on the next circle generated. While active, any 5-star unit summoned will be a 5-star focus unit. This means that if the banner has a non-focus 5-star rate and focus charge is active, that rate is added to the 5-star focus rate and the non-focus rate is set to 0%. If a 5-star focus unit is summoned while focus charge is active, the focus charge state will be deactivated on the next summoning circle, and the number of focus charges will be reset to zero. 

Some banners in FEH also offer a free 5-star summon after 40 summons. This has been nicknamed a "spark" by the community (maybe because IS has not given it a succinct name). Some banners in FEH only have the spark feature for players who subscribe to Feh Pass while many don't feature a spark at all. When a player reaches spark on a banner, the regular summoning rules are suspended for the next summoning circle. Instead of being given a randomly generated circle, the player will be presented with a circle that features each of the focus units on the banner in stones that do NOT hide their identities, and the player will be able to choose one to summon. Once the player has exited the special spark circle, the regular rules for summoning resume, and the player gets to keep any pity and any focus charges they had previously acquired. Additionally, entering this special circle costs no orbs, which is why IS calls it "free." Most players laugh at that description as you have to spend the orbs on the 40 summons to reach spark, which is a significant amount of orbs. 

Most banners with the spark feature only allow a player to spark once. The handful of banners that allow a player to spark more than once, only let the player choose each focus hero once. That is any focus hero chosen by the player in a previous spark will not be among the available choices in subsequent sparks. In spite of its limited nature, sparking is the most generous summoning feature introduced by IS as it provides a guarantee and a choice, which gives some control back to players in a system mostly dictated by luck.

# Using These Scripts
There are currently three main scripts to use in this repo to simulate summoning. They are "FEH_spark_sims_template.R", "FEH_single_target_unit_sims_template.R", and "FEH_multi_target_units_sims_template.R". These scripts are independent of one another, but each require "FEH_summoning_header_ver6.R", "FEH_roster_header.R", and "FEH_Full_Roster.csv" to execute. All of these scripts simulate summoning on a single banner in FEH a particular number of times to compile mass summoning statistics on the simulated banner given the implemented conditions.

"FEH_spark_sims_template.R" is set up to run mass summoning simulations pulling 40 times on a banner to achieve spark. It assumes the summoner will summon exactly 40 times and book-keeps potentially interesting data related to the summoning sessions such as the number of orbs spent and the number of 5-star heroes (focus and non-focus) pulled.

"FEH_single_target_unit_sims_template.R" is set up to run mass summoning simulations where the summoner wants to pull a number of copies of a specific target focus unit. It allows for the optional use of the spark feature. It runs marginally faster than running an equivalent simulation in "FEH_multi_target_units_sims_template.R".

"FEH_multi_target_units_sims_template.R" is set up to run mass summoning simulations where the summoner wants to pull a number of copies of several target focus heroes. A different number of copies of each can be selected. It is NOT set up to incorporate a spark.

Some of the scripts in this repo are archival such as all the AHR scripts and "FEH_summoning_header_ver5.R", which is to be used with the AHR scripts due to potential backwards-compatibility issues with ver6. Also, this repo is relatively new compared to how long I have been working on coding FEH summoning scripts. "FEH_summoning_header_ver4.R" (et cetera) exists on my personal computer but is out of date with FEH's numerous summoning changes, and I see no reason to archive them on github at this point.

The file "FEH_Full_Roster_Detailed.csv" is a newer file in the repo. It contains a lot of information about every playable unit in Fire Emblem Heroes. It is not used in any of the summoning scripts (currently) but is included for interested parties who want to use it for statistical (or non-statistical) purposes. When this file is loaded as a data frame into R, it allows for easy lookup of units who possess certain skills or for analysis of trends (such as comparing the percentage of grail units with a prf weapon versus gacha units in a given set of FEH versions).

In addition to using the scripts as-is with minimal modification, it is my hope that these scripts may serve as a starting point for R coders who wish to run unique summoning simulations that are beyond the scope of these and other pre-made simulators. For instance, they might serve as a starting point for someone who wanted to simulate a summoner who would stop summoning if they got their target hero in under 30 summons but would go to spark if over 30. 

## More details on using the three main scripts
The three main simulation scripts are meant to be mostly self-explanatory. I recommend loading all three of the main scripts and their dependencies into your working directory in R ("FEH_spark_sims_template.R", "FEH_single_target_unit_sims_template.R", "FEH_multi_target_units_sims_template.R", "FEH_summoning_header_ver6.R", "FEH_roster_header.R", and "FEH_Full_Roster.csv"). Once you have loaded the scripts and their dependencies into your working directory in R, you can run them as-is. They are set up with default values of important implementation variables that you change in the scripts themselves such as the number of simulations to run, banner composition, and initial summoning rates. These important variables are all placed near the top of the three main scripts.

Important: In all of these scripts the color Red is represented by 1, Blue by 2, Green by 3, Colorless (or Cless) by 4. This is similar to representing all stone colors as factors. I am considering changing them from integers to actual factors in a future update for improved readability.

### Listing of main variables to change in the scripts as desired:
n: The number of simulations to run with the set conditions (in stats this would be called the number of trials).

first_free: A logical indicating whether the first summon on the simulated banner costs orbs.

num_tickets: An integer representing the number of tickets available to use on the simulated banner.

focus_charges_active: A logical indicating whether the simulated banner uses focus charges.

hero_colors: A vector containing the numbers 1-4 representing the colors of focus heroes. For instance if a banner had the following focus heroes - Volke (Red), Charlotte (Green), and Annand (Red), then hero_colors = c(1, 3, 1). Additionally, the script implicitly assigns Volke an index of 1, Charlotte an index of 2, and Annand an index of 3.

fours_focus_hero: a vector containing the indexes (NOT colors) of four-star focus heroes as implied by the hero_colors array. It should be set to c(0) if there are no four-star focus heroes available on the banner.

ini_5s_focus_rate: The initial rate of 5-star focus heroes, usually 0.03, 0.04, 0.05, 0.06 or 0.08.

ini_5s_non_focus_rate: The initial rate of non-focus 5-star heroes, usually 0, 0.02,  or 0.03.

ini_4s_focus_rate: The initial rate of 4-star focus heroes, usually 0 or 0.03.

ini_4s_spc_rate: The initial rate of 4-star special heroes, always 0.03.

ini_4s_rate: The initial rate of 4-star heroes, usually 0.52, 0.54, or 0.55.

ini_3s_rate: The initial rate of 3-star heroes, usually 0.33, 0.34, or 0.36.

Note: The total of all the "ini_" rates should be 1, and the scripts do not currently error check this. (One of many things to improve in future updates.)

**Example 1** (Double Special Heroes - June 2023)

hero_colors = c(1, 1, 2, 2, 3, 3, 4, 4)

fours_focus_hero = c(4) #H!M!Byleth (Blue) is in the 4th position of hero_colors

ini_5s_focus_rate = 0.06

ini_5s_non_focus_rate = 0

ini_4s_focus_rate = 0.03

ini_4s_spc_rate = 0.03

ini_4s_rate = 0.54

ini_3s_rate = 0.34

**Example 2** (Bridal Dreams - June 2023)

hero_colors = c(4, 3, 2, 1)

fours_focus_hero = c(4) #B!Flavia (Red) is in the 4th position of hero_colors

ini_5s_focus_rate = 0.03

ini_5s_non_focus_rate = 0.03

ini_4s_focus_rate = 0.03

ini_4s_spc_rate = 0.03

ini_4s_rate = 0.52

ini_3s_rate = 0.36

**Example 3** (Weekly Revival 25)

hero_colors = c(2, 1, 3)

fours_focus_hero = c(0) #No fours_focus_hero

ini_5s_focus_rate = 0.04

ini_5s_non_focus_rate = 0.02

ini_4s_focus_rate = 0

ini_4s_spc_rate = 0.03

ini_4s_rate = 0.55

ini_3s_rate = 0.36

Variables that can be optionally changed:

max_ver: This is the cutoff version (inclusive) for heroes to include as non-focus heroes. The default value is the max version number in the roster csv file ("FEH_Full_Roster.csv")

spc_cutoff: This is the cutoff version (inclusive) for heroes to include as four-star special heroes. The default is currently set to 4.08, which (as of the writing of this README) is the current cutoff.

There are some implementation variables specific to certain scripts. We will go through them script-by-script.

### "FEH_spark_sims_template.R" variables
target_color: A vector of the numbers 1-4 representing which colors the player wishes to pull whenever they are given. For instance target_color = c(1) indicates the player wishes to summon just on Red stones while target_color = c(1, 2, 4) indicates the player wishes to summon on all Red, Blue, and Colorless stones.

off_color: An optional vector (can be set to off_color = c(0)) that indicates the player's most preferred color(s) if the target_color is not available in a circle. For instance if target_color = c(1) and off_color = c(4), that means the player will pull a Cless stone when there's no Red stone in a circle (if possible).

Note: In any circle without the desired color, only one stone will be pulled. off_color just denotes a preference of which one to pull in such a case.

target_hero: This is the implied index (NOT color) of the focus hero the player most wishes to summon. This is NOT used in the simulation itself, but is used in the mass summoning statistics computed at the end. Although it would be logical that the target_hero is the same color as target_color, it is not required of the simulation.

num_to_summon: This is the number of times to summon in each simulation. The default is 40 since that is the number of times needed to reach spark, and this script is primarily meant to simulate the outcomes while sparking. However, if you wanted to simulate a player who will summon exactly 7 times for whatever reason, you could. 

### "FEH_single_target_unit_sims_template.R" variables
desired_hero: The implied index number (NOT color) of the hero the player wishes to pull.

desired_copies: The number of copies the player wishes to pull of that hero.

off_color: An optional vector (with no preference can be set to c(0)) that sets the next most desireable color(s) for the player to pull when the desired_hero's color does not appear.

Note: In any circle without the desired hero's color, only one stone will be pulled. off_color just denotes a preference of which one to pull in such a case.

max_orbs: The maximum number of orbs that can be used in the simulation. It can be used either as a failsafe (if set to a high number like 10000) or to represent the number of orbs the player actually has.

spark: A logical that represents if the banner has a spark available. If set to TRUE, the spark will be used to summon a copy of the desired_hero.

summons_for_spark: Represents the number of summons needed to reach spark. It should usually be set to 40. However, a lower number might represent that a player has already summoned some on the banner and therefore needs fewer summons to reach spark.

### "FEH_multi_target_units_sims_template.R" variables
desired_copies: This is a vector that should be the same length as hero_colors. It represents how many copies of each hero the player wants. 

Example: The player is pulling on Bridal Dreams which features harmonic Tiki (Cless), Bridal Anna (Green), Bridal Say'ri (Blue), and Bridal Flavia (Red). The player wants 1 copy of Tiki and 11 copies of Flavia.

hero_colors = c(4, 3, 2, 1)

desired_copies = c(1, 0, 0, 11) #Tiki is implicitly in the first position of hero_colors, and the player wants one copy, so 1 is in the first position of desired_copies. Likewise, Flavia is implicitly in the fourth position of hero_colors, so 11 in the fourth position of desired_copies represents the player wanting 11 copies of Flavia.

num_to_complete: This is the number of focus heroes that need to be completed for the simulation to stop. ANY HERO WITH ZERO DESIRED COPIES IS COMPLETED BY DEFAULT. In the example, setting num_to_complete = 3 means the simulation will stop when the player has pulled a copy of Tiki or 11 copies of Flavia, and setting num_to_complete = 4 means the simulation will stop when the player has pulled 1 copy of Tiki and 11 copies of Flavia (and at least 0 Anna and Say'ri). Setting num_to_complete = 2 (or 0 or 1) would cause the sim to stop the first time a focus hero is summoned since that is when the sim checks if num_to_complete is satisfied. If num_to_complete > number of focus heroes, script will only stop due to reaching max_orbs.

off_color: Optional vector representing secondary color(s) to pull if desired_heroes' colors do not appear in a circle. (If not being used set off_color = c(0).) Note: This color can match one of the heroes the player wants copies of, which indicates the sim will continue to pull that color as a secondary after reaching the desired_copies. In our example if off_color = c(4), This indicates to pull Cless if Tiki has been completed, Flavia hasn't, and no red orbs have appeared.

Note: In any circle without the desired hero(es)'s color(s), only one stone will be pulled. off_color just denotes a preference of which one to pull in such a case. 

max_orbs: The sim will stop when another summon will put the total orbs spent above max_orbs. This can be used as a failsafe when set to a high number (like 10000) or can be used to represent the actual number of orbs the player has to summon.

# Next Steps
Currently, I am learning more about programming in R. In retrospect, I have made some design decisions in how my scripts work that I regret. At some point in the not-too-distant future, I will be re-working these scripts from the ground up to hopefully be faster, have fewer redundancies, have fewer global variables, and be more resilient to user error. I also hope to encapsulate pulling on a circle (not just circle generation) into its own function to make the scripts more readable.

I would also like to make some example scripts focusing on analysing hero trends in the data I have compiled into "FEH_Full_Roster_Detailed.csv".

Also, at some point, I am going to create branches in my repo and organize it.

# Acknowledgements
I would like to thank the people behind the FEH wikis on Fandom and Gamepress. Also, a big thank you to reddit user u/MrGengar123 and their partner Tsukasa as well as u/_vinventure. Without these people, I could never have made the detailed roster csv file.

[Fandom site](https://feheroes.fandom.com/wiki/Main_Page)

[Gampress site](https://gamepress.gg/feheroes/)

[Donate to u/MrGengar123 and Tsukasa](https://ko-fi.com/mrgengar_kofi)

[u/_vinventure's filterable spreadsheet](https://docs.google.com/spreadsheets/d/19DhZyLiWw4lS_9BvUOP5VrIvx7Yi6JZlWQCO_GWfvw8)

I would also like to thank everyone who has helped me with my R programming over the years including my university teachers, go4ino, and random commenters. 

I am giving special mention to Chapman & Hall’s [Advanced R book](https://adv-r.hadley.nz/index.html) which I am currently reading to improve my R skills. I wrote the scripts in this repo before starting this book, so any weird coding decisions on my part are not reflective of the contents of the book.
