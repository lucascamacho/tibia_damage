# comparar o scalling de dano para cada vocação no tibia.
# o scalling é o mesmo em todas as vocações, o que muda é a quantidade de alvos por turno
# knight: 1 ataque comum + ataque de área (exori gran: 9 sqm) 
# sorcerer : 1 ataque comum + runa de área (GFB: 37 sqm)
# druid: 1 ataque comum + runa de área (AVA: 37 sqm)
# paladin: 1 ataque comum + runa de area (Diamond arrow: 21; AVA: 37 sqm)
# monk: 1 ataque comum + runa de area (AVA: 37 sqm)
#
# a cada turno, a quantidade de alvos deve variar dado uma certa probabilidade normal
#
library(truncnorm)
library(ggplot2)
library(tidyr)
library(dplyr)

# define quantos sqm um personagem atinge em um turno dado a sorte. Cada voc tem um sqm diferente
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
  # Dano: Base + Base * SQM acertados
  # Dado um certo level, o scalling de dano muda
  # Dano Base
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
    base_p = ceiling(i / 5) * Hit_Number(21, 1)
    base_m = ceiling(i / 5)
  }
  
  if(i >= 501 && i <= 1100){
    base_k = ceiling(i / 6)
    base_s = ceiling(i / 6)
    base_d = ceiling(i / 6)
    base_p = ceiling(i / 6) * Hit_Number(21, 1)
    base_m = ceiling(i / 6)
  }
  
  if(i >= 1101 && i <= 1800){
    base_k = ceiling(i / 7)
    base_s = ceiling(i / 7)
    base_d = ceiling(i / 7)
    base_p = ceiling(i / 7) * Hit_Number(21, 1)
    base_m = ceiling(i / 7)
  }
  
  if(i >= 1801 && i <= 2600){
    base_k = ceiling(i / 8)
    base_s = ceiling(i / 8)
    base_d = ceiling(i / 8)
    base_p = ceiling(i / 8) * Hit_Number(21, 1)
    base_m = ceiling(i / 8)
  }
  
  if(i >= 2601 && i <= 3500){
    base_k = ceiling(i / 9)
    base_s = ceiling(i / 9)
    base_d = ceiling(i / 9)
    base_p = ceiling(i / 9) * Hit_Number(21, 1)
    base_m = ceiling(i / 9)
  }
  
  if(i >= 3501 && i <= 4300){
    base_k = ceiling(i / 10)
    base_s = ceiling(i / 10)
    base_d = ceiling(i / 10)
    base_p = ceiling(i / 10) * Hit_Number(21, 1)
    base_m = ceiling(i / 10)
  }
  
  if(i >= 4301 && i <= 5200){
    base_k = ceiling(i / 11)
    base_s = ceiling(i / 11)
    base_d = ceiling(i / 11)
    base_p = ceiling(i / 11) * Hit_Number(21, 1)
    base_m = ceiling(i / 11)
  }
  
  if(i >= 5201 && i <= 6200){
    base_k = ceiling(i / 12)
    base_s = ceiling(i / 12)
    base_d = ceiling(i / 12)
    base_p = ceiling(i / 12) #* Hit_Number(21, 1)
    base_m = ceiling(i / 12)
  }
  
  # Dano em área
  area_k = base_k * Hit_Number(9, 1) # Exori gran 
  area_s = (base_s * Hit_Number(37, 1)) + (base_s * Hit_Number(11, 1)) # GFB + exori vis hur
  area_d = (base_d * Hit_Number(37, 1)) + (base_d * Hit_Number(11, 1)) # AVA + exori terra hur
  area_p = base_p * Hit_Number(37, 1) # AVA ou GFB
  area_m = base_m * Hit_Number(37, 1) # AVA ou GFB
  
  # Dano total
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

# estats básicas
summary(damages)

par(mfrow = c(2,3))
hist(damages$Knight)
hist(damages$Sorcerer)
hist(damages$Druid)
hist(damages$Paladin)
hist(damages$Monk)
dev.off()

# Supondo que seu data frame damage tem uma coluna de índice implícita (1, 2, 3, ...)
damages_new = damages %>% mutate(Level = row_number())

# Transformar de wide para long
damages_long = damages_new %>%
  pivot_longer(cols = c(Knight, Sorcerer, Druid, Paladin, Monk),
               names_to = "Vocação",
               values_to = "Dano")

# Plotar
p = ggplot(damages_long, aes(x = Level, y = Dano, color = Vocação)) +
    geom_line(alpha = 0.3) +
    geom_smooth(method = "gam", se = FALSE, linewidth = 1) +
    theme_minimal() +
    labs(title = "Damage by Level for each vocation",
         x = "Level",
         y = "Damage") +
    theme_bw()

ggsave(p, filename = "~/Dropbox/tibia_damage/Damage_Voc.pdf")

