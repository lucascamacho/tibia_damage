# compare the scaling of damage for each vocation in tibia.
# the scaling is pretty similar for each vocation, what changes is mostly the area attack for each vocation
#
# knight: 1 basic attack + area attack (exori gran: 9 sqm)
# sorcerer : 1 basic attack + rune (GFB: 37 sqm) + spell (exori vis hur: 11 sqm)
# druid: 1 basic attack + rune (AVA: 37 sqm) + spell (exori terra hur: 11 sqm)
# paladin: 1 basic attack + rune (AVA: 37 sqm)
#          from level 150 the basic attack can be a Diamond Arrow (21 sqm)
# monk: 1 basic attack + rune (AVA: 37 sqm)
#
# in each turn, the quantity of targets should vary given a certain truncated normal probability distribution
#
if(!require(truncnorm)){install.packages("truncnorm"); library(truncnorm)}
if(!require(ggplot2)){install.packages("ggplot2"); library(ggplot2)}
if(!require(tidyr)){install.packages("tidyr"); library(tidyr)}
if(!require(dplyr)){install.packages("dplyr"); library(dplyr)}

set.seed(42)

# TRUE: paladins use Diamond Arrows from level 150 (Damage_Voc.png / Histograms_Damage.png)
# FALSE: paladins use a single-target basic attack (NoArrow_*.png)
use_diamond_arrow = TRUE

# TRUE: overwrite the figures in the folder (NoArrow_ prefix when use_diamond_arrow = FALSE)
save_figures = FALSE
prefix = ifelse(use_diamond_arrow, "", "NoArrow_")

# define how much SQM a vocation hits in a turn.
# returns one sampled number of targets per level
Hit_Number = function(sqm, hit_number){
  a = 1
  b = sqm
  mu = round(sqm / 2)
  sigma = 5

  hit = round(rtruncnorm(hit_number, a = a, b = b, mean = mu, sd = sigma))
  return(hit)
}

# Base damage by level.
# Each bracket adds +1 of Base damage every 'step' levels, on top of what was
# gained in the previous brackets (so damage never drops when changing bracket).
# level 1-500: +1 each 5 levels; 501-1100: +1 each 6 levels; and so on.
breaks = c(0, 500, 1100, 1800, 2600, 3500, 4300, 5200, 6200)
step = 5:12

Base_Damage = function(level){
  sapply(level, function(lvl){
    lower = breaks[-length(breaks)]
    upper = breaks[-1]
    levels_in_bracket = pmax(0, pmin(lvl, upper) - lower)
    max(1, floor(sum(levels_in_bracket / step)))
  })
}

level = seq(1, 3000, 1)
n = length(level)
base = Base_Damage(level)

# Damage in area: Base * number of targets hit (sampled once per level)
area_k = base * Hit_Number(9, n) # exori gran
area_s = (base * Hit_Number(37, n)) + (base * Hit_Number(11, n)) # GFB + exori vis hur
area_d = (base * Hit_Number(37, n)) + (base * Hit_Number(11, n)) # AVA + exori terra hur
area_p = base * Hit_Number(37, n) # AVA or GFB
area_m = base * Hit_Number(37, n) # AVA or GFB

# Basic attack. The Diamond Arrow replaces the paladin basic attack (it is not an
# extra attack): it hits the targets in its 21 sqm instead of a single target.
basic_p = base
if(use_diamond_arrow){
  arrow = level >= 150
  basic_p[arrow] = base[arrow] * Hit_Number(21, sum(arrow))
}

# Total damage: attacks in the same turn are added, never multiplied
damages = data.frame(Knight = base + area_k,
                     Sorcerer = base + area_s,
                     Druid = base + area_d,
                     Paladin = basic_p + area_p,
                     Monk = base + area_m)

# basic stats
summary(damages)

if(save_figures){
  png(paste0("~/Dropbox/tibia_damage/", prefix, "Histograms_Damage.png"), width = 660, height = 460)
}
par(mfrow = c(2,3))
for(voc in colnames(damages)){
  hist(damages[[voc]], main = voc, xlab = "Damage")
}
if(save_figures){
  dev.off()
}

#
damages_new = damages %>% mutate(Level = level)

# Transform wide to long
damages_long = damages_new %>%
  pivot_longer(cols = c(Knight, Sorcerer, Druid, Paladin, Monk),
               names_to = "Vocs",
               values_to = "Dano")

# Plot
p = ggplot(damages_long, aes(x = Level, y = Dano, color = Vocs)) +
    geom_line(alpha = 0.3) +
    geom_smooth(method = "gam", se = FALSE, linewidth = 1) +
    labs(title = "Damage by Level for each vocation",
         x = "Level",
         y = "Damage") +
    theme_bw()
p
# save plot
if(save_figures){
  ggsave(p, filename = paste0("~/Dropbox/tibia_damage/", prefix, "Damage_Voc.png"),
         width = 7, height = 4.8, dpi = 300)
}
