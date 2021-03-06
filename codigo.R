# código

#fontes postagem de @FCamposoficial em 10 de Maio (tweet.png)
# Ranking das ligas = site -> https://www.globalfootballrankings.com/


jogador <- c("Artur Cabral","Vini Jr.","Evanilson","Gabriel Jesus","Antony","Neymar","Paquetá",
             "Rodrygo","Malcom","Firmino","E. Cebolinha","Raphinha","L.Moura","Claudinho",
             "Richarlison","M.Cunha","Martinelli","Coutinho","Y.ALberto","GabiGol", "Veiga",
             "Dudu", "Hulk")
gols <-c(29,18,21,13,12,12,10,8,9,11,7,10,6,10,9,6,5,6,6,12,10,2,19)
assistencias <-c(7,15,5,11,10,8,7,8,7,4,7,3,7,3,4,4,5,3,3,5,4,2,7)
jogos <- c(46,49,44,39,33,27,43,45,33,31,47,33,42,30,31,34,33,32,13,18,31,21,35)
gols_e_assists <- gols + assistencias
media_gols <- gols/jogos
media_assistencias <- assistencias/jogos
media_gols_e_assist <- gols_e_assists/jogos
# obs artur cabral se transferiu no meio da temporada seu ranking é suiça*0.5 + italia*0.5 = transf1
# obs Coutinho se transferiu no meio da temporada seu ranking é espanha*05 + inglaterra*05 = transf2
# obs Incluí GabiGol, Veiga, Dudu e Hulk somente campeonato brasileiro 2021 (não estavam na lista)
transf1 <- (39.60*0.5) + (63.59*0.5)
Espanha <- 70.03
Portugal <- 52.09
Inglaterra <- 73.16
Holanda <- 51.56
França <- 60.65
Russia <- 45.75
Brasileirao <- 49.30 
transf2 <- (Inglaterra*0.5) + (Espanha*0.5)
ranking <-c(transf1,Espanha,Portugal,Inglaterra,Holanda,França,França,
           Espanha,Russia,Inglaterra,Portugal,Inglaterra,Inglaterra,Russia,Inglaterra,
           Espanha,Inglaterra,transf2,Russia,Brasileirao, Brasileirao, Brasileirao,
           Brasileirao)

df <- data.frame(jogador, gols, gols_e_assists, media_gols, media_assistencias,
                 media_gols_e_assist, ranking)

library(ggplot2)
a <- ggplot(df, aes(gols, assistencias))
a + geom_text(label = jogador) + labs(title = "Gols e assistencia", 
                                      subtitle = "Sem levar em consideração nível da liga",
                                      x = "gols", y= "asssistência)",
                                      caption = "Desconsidera número de jogos") 


df$gols_dificuldade <- media_gols*ranking
df$assists_dificuldade <- media_assistencias*ranking


b <- ggplot(df, aes(gols_dificuldade, assists_dificuldade))
b + geom_text(label = jogador) + labs(title = "MÉDIA de Gols e MÉDIA de Assistências", 
                                    subtitle = "Ponderado pelo nível da liga",
                                    x = "Média de Gols", y= "Média de Asssistências",
                                    caption = "PRO RANKING VER ARQUIVO CÓDIGO") 

df$score <- media_gols_e_assist*ranking


bar <- ggplot(df, aes(jogador, score)) 
bar + geom_bar(stat = "identity") + 
  labs(title = "SCORE Média Gols e Média Assistência", 
       subtitle = "Ponderado pelo nível da liga",
       x = "Jogador", y= "Score",
       caption = "Saiba mais sobre o significado do SCORE em ´analisando ACHADO 3´. Dudu ficou com média tão baixa que nem aparece") + 
  theme_bw() + theme(text = element_text(size = 12))


boxplot(df$score)
summary(df$score)




# pro achado 4 vamos normalizar tudo ( de 0 a 1)


df$Score_Ponderado <- df$score
df$Score_No_Ponderado <- media_gols_e_assist
x <- df
library(caret)
epa32 <- preProcess(x[,c(11:12)], method = c("range"))
norm2 <- predict(epa32,x[,c(11:12)])
summary(norm2)

norm2$Score_Ponderado -> df$Score_Ponderado
norm2$Score_No_Ponderado -> df$Score_No_Ponderado




df$dif <- df$Score_No_Ponderado - df$Score_Ponderado

library(tidyverse)
library(knitr)
library(kableExtra)
b5 <- df %>% 
  dplyr::select(jogador, Score_Ponderado, Score_No_Ponderado, dif) %>% 
  arrange(desc(Score_Ponderado))
b5 %>%
  kbl(caption = "Valores negativos indicam que sem a ponderação, o jogadore seria prejudicado, valores positivos indicam o oposto") %>%
  kable_classic(full_width = F, html_font = "Garamond")


# ANALISES ADICIONAIS EXTRAS

install.packages("ggpubr")
library(ggpubr)
cor(df$Score_Ponderado, df$Score_No_Ponderado) # a correlação de 0.87 indica boa coincidência
sp <- ggscatter(df, x = "Score_No_Ponderado", y = "Score_Ponderado",
                add = "reg.line",  # Add regressin line
                add.params = list(color = "blue", fill = "lightgray"), # Customize reg. line
                conf.int = TRUE # Add confidence interval
)
# Add correlation coefficient
sp + stat_cor(method = "pearson", label.x = 0, label.y = 1)
#> `geom_smooth()` using formula 'y ~ x'
sp + stat_cor(p.accuracy = 0.001, r.accuracy = 0.01)
c <- sp + stat_cor(p.accuracy = 0.001, r.accuracy = 0.01)
c + geom_text(label = jogador)



# o que explica melhor os gols entre esses jogadores, a assistencias ou o nível da liga

model_gol <- lm(media_gols ~ media_assistencias + ranking, data=df)
summary(model_gol)
library(coefplot)
coefplot(model_gol, intercept=FALSE, interactive=TRUE)





