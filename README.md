## Tibia Vocations Damage Modelling

For a long time I see players complaining about the (un)balancing of vocations and 
the enormous advantage that Paladins has, manly due to the use of Diamond Arrows after level 150. 
Basically, the main argument is that Paladins can hit in a certain area 2 times in a same turn. 
This ends in Paladins doing massive amount of damage compared to other vocations which can only hit in area only a single time in each turn. 
Well, I just got curious to see how this “grows” with the characters leveling and the real impact of Diamond Arrows when leveling. 
I construct a simple computer program which I like to share here and get some critics/recommendations about the modelling. 
The code will be available in Github so you can download and play with the model as I did.

### The Model

I am modelling how much damage does a single character of each of the five classes can do in a single turn. 
I am doing this as the characters levels grows. The damage modeled here is composed of 2 parts: Basic attacks and Area attacks. 

#### Basic Attacks

The Basic attack changes as the character get higher levels, as follows:
- From level 1 to level 500, each 5 levels adds 1 of the Base damage, 
- From level 150 to 500 each 6 levels add 1 of the Base damage,
- From level 501 to 1100 each 7 levels add 1 to the Base damage… and so on.

All the characters begins the same, with 1 of Base damage attack.

![alt text](https://github.com/lucascamacho/tibia_damage/blob/main/basic_attack.png)

#### Area Attacks

The Area attack depends on how many monsters do you get in your area attack. 
Sometimes when you throw a GFB or a diamond arrow, you get 10 monsters, 
sometimes you get 1 monster or sometimes you are lucky and all the square meters (sqm’s) of your GFBs or arrow hit a monster. 
Nice. Area attacks depends on luck. For that, the Area damage is the Base Damage multiplied by the quantity of monsters that 
you hit when you trow a rune, send an diamond arrow, cast *exori gran*, etc, etc.
The quantity of how much monsters the characters hit in an single Area attack is sampled from a truncated normal distribution 
where the minimum value that hit is 1 and the maximum is the size, in sqm’s, that the Area attack hit.

![alt text](https://github.com/lucascamacho/tibia_damage/blob/main/area_attack.png)

Let’s get a practical example. We have our knight named Knight, very creative. Knight can attack one base attack and one *exori gran* 
in a single turn. So in the level 1 turn, Knight could hit one Basic attack which the damage depends on the Knight’s level plus the Area attack 
which is an *exori gran* which has 9 sqm’s. The quantity of monsters that Knight will hit in the *exori gran* is a sampled number from 1 to 9 
sqm’s from a truncated normal distribution. Suppose that Knight is a lucky guy and in this level 1 turn, he hits 7 monsters with his *exori gran*. 
So the final damage of our Knight in the level 1 will be Base attack + Area attack => 1 + (1 * 7) =  9. 
That’s the basic intuition of our model. 

I let the model run for 6000 timesteps which represents the damage of our characters in the level 1 to level 6000.

### Assumptions

Of course there a lot of simplifications of our model, but is a starting point so we can unravel how character damage changes over time 
in scenarios of different attacks and levels. Some simplifications are made:
- The Basic attacks always hits
- Regardless the level, all the characters can use all the runes and spells from their own vocation 
- Paladins can only use Diamond Arrows from level 150
- The damage of an Area attack is just the sum of Basic attacks in several sqm’s
- The characters do not waste any turn healing or doing other stuff, just attacking
- There are no items or spells that increase damage, only increase the sqm’s which the Basic attack hits

## Results

Paladins has a lot of damage after level 150 due to the Diamond Arrow use.

![alt text](https://github.com/lucascamacho/tibia_damage/blob/main/Histograms_Damage.pdf)

But also Paladins has a lot of variation due to the possibility
of both attacks hit only a single monster in a single turn.

![alt text](https://github.com/lucascamacho/tibia_damage/blob/main/Damage_Voc.pdf)

