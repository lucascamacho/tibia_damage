# compare the scaling of damage for each vocation in tibia.
# the scaling is pretty similar for each vocation, what changes is mostly the area attack for each vocation
#
# knight: 1 basic attack + area attack (exori gran: 9 sqm) 
# sorcerer : 1 basic attack + rune (GFB: 37 sqm)
# druid: 1 basic attack + rune (AVA: 37 sqm)
# paladin: 1 basic attack + rune (Diamond arrow: 21; AVA: 37 sqm)
# monk: 1 basic attack + rune (AVA: 37 sqm)
#
# in each turn, the quantity of targets should vary given a certain truncated normal probability distribution
#
if(!require(truncnorm)){install.packages("truncnorm"); library(truncnorm)}
if(!require(ggplot2)){install.packages("ggplot2"); library(ggplot2)}
if(!require(tidyr)){install.packages("tidyr"); library(tidyr)}
if(!require(dplyr)){install.packages("dplyr"); library(dplyr)}

# define how much SQM a vocation hits in a turn.
Hit_Number = function(sqm, hit_number){
  a = 1
  b = sqm
  mu = round(sqm / 2)
  sigma = 5
  
  hit = round(rtruncnorm(hit_number, a = a, b = b, mean = mu, sd = sigma))
  return(hit)
}

level = seq(1, 3000, 1)
damages = data.frame()
for(i in 1:length(level)){
  # Damage Base + Base * SQM hit from sampling
  # Leveling changes in time
  # Base damage
  if(i <= 149){
    base_k = ceiling(i / 5)
    base_s = ceiling(i / 5)
    base_d = ceiling(i / 5)
    base_p = ceiling(i / 5)
    base_m = ceiling(i / 5)
  }
  
  if(i >= 150 && i <= 500){
    base_k = ceiling(i / 5)
    base_s = ceiling(i / 5)
    base_d = ceiling(i / 5)
    base_p = ceiling(i / 5)# * Hit_Number(21, 1)
    base_m = ceiling(i / 5)
  }
  
  if(i >= 501 && i <= 1100){
    base_k = ceiling(i / 6)
    base_s = ceiling(i / 6)
    base_d = ceiling(i / 6)
    base_p = ceiling(i / 6)# * Hit_Number(21, 1)
    base_m = ceiling(i / 6)
  }
  
  if(i >= 1101 && i <= 1800){
    base_k = ceiling(i / 7)
    base_s = ceiling(i / 7)
    base_d = ceiling(i / 7)
    base_p = ceiling(i / 7)# * Hit_Number(21, 1)
    base_m = ceiling(i / 7)
  }
  
  if(i >= 1801 && i <= 2600){
    base_k = ceiling(i / 8)
    base_s = ceiling(i / 8)
    base_d = ceiling(i / 8)
    base_p = ceiling(i / 8)# * Hit_Number(21, 1)
    base_m = ceiling(i / 8)
  }
  
  if(i >= 2601 && i <= 3500){
    base_k = ceiling(i / 9)
    base_s = ceiling(i / 9)
    base_d = ceiling(i / 9)
    base_p = ceiling(i / 9)# * Hit_Number(21, 1)
    base_m = ceiling(i / 9)
  }
  
  if(i >= 3501 && i <= 4300){
    base_k = ceiling(i / 10)
    base_s = ceiling(i / 10)
    base_d = ceiling(i / 10)
    base_p = ceiling(i / 10)# * Hit_Number(21, 1)
    base_m = ceiling(i / 10)
  }
  
  if(i >= 4301 && i <= 5200){
    base_k = ceiling(i / 11)
    base_s = ceiling(i / 11)
    base_d = ceiling(i / 11)
    base_p = ceiling(i / 11)# * Hit_Number(21, 1)
    base_m = ceiling(i / 11)
  }
  
  if(i >= 5201 && i <= 6200){
    base_k = ceiling(i / 12)
    base_s = ceiling(i / 12)
    base_d = ceiling(i / 12)
    base_p = ceiling(i / 12)# * Hit_Number(21, 1)
    base_m = ceiling(i / 12)
  }
  
  # Damage in area
  area_k = base_k * Hit_Number(9, 1) # exori gran
  area_s = (base_s * Hit_Number(37, 1)) + (base_s * Hit_Number(11, 1)) # GFB + exori vis hur
  area_d = (base_d * Hit_Number(37, 1)) + (base_d * Hit_Number(11, 1)) # AVA + exori terra hur
  area_p = base_p * Hit_Number(37, 1) # AVA or GFB
  area_m = base_m * Hit_Number(37, 1) # AVA or GFB
  
  # Total damage
  total_k = base_k + area_k
  total_s = base_s + area_s
  total_d = base_d + area_d
  total_p = base_p + area_p
  total_m = base_m + area_m
  
  #
  turn = c(total_k, total_s, total_d, total_p, total_m)
  damages = rbind(damages, turn)
}
colnames(damages) = c("Knight", "Sorcerer", "Druid", "Paladin", "Monk")

# basic stats
summary(damages)

par(mfrow = c(2,3))
#pdf("~/Dropbox/tibia_damage/Histograms_Damages.png")
hist(damages$Knight)
hist(damages$Sorcerer)
hist(damages$Druid)
hist(damages$Paladin)
hist(damages$Monk)
dev.off()

# 
damages_new = damages %>% mutate(Level = row_number())

# Transform wide to long
damages_long = damages_new %>%
  pivot_longer(cols = c(Knight, Sorcerer, Druid, Paladin, Monk),
               names_to = "Vocs",
               values_to = "Dano")

# Plot
p = ggplot(damages_long, aes(x = Level, y = Dano, color = Vocs)) +
    geom_line(alpha = 0.3) +
    geom_smooth(method = "gam", se = FALSE, linewidth = 1) +
    theme_minimal() +
    labs(title = "Damage by Level for each vocation",
         x = "Level",
         y = "Damage") +
    theme_bw()

# save plot
ggsave(p, filename = "~/Dropbox/tibia_damage/NoArrow_Damage_Voc.png")

