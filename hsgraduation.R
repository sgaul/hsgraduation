hsgrad <- read.csv("hsgraduationrates-district.csv")

#Filter to just regional districts
hsgrad <- subset(hsgrad, hsgrad$District.Name %in% levels(districts$district))
hsgrad$District.Name <- factor(hsgrad$District.Name)

#Clean up categories
hsgrad$Category <- gsub(pattern = "^Indian$", replacement = "American Indian", hsgrad$Category)
hsgrad$Category <- gsub(pattern = "Asian American", replacement = "Asian", hsgrad$Category)
hsgrad$Category <- gsub(pattern = "Asian ", replacement = "Asian", hsgrad$Category)
hsgrad$Category <- gsub(pattern = "Non- Special", replacement = "Non-Special", hsgrad$Category)

#Merge with enrollment data to allow aggregation
#Doing this with entire enrollment for the school, need better data by year
hsenroll <- read.csv("Race_and_Gender_by_district_2011_for_N_5_suppressed.csv")
hsenroll <- melt(hsenroll, id.vars = c("Inst","dist","District.Name"))
hsenroll$variable <- gsub(pattern = "All.Students", replacement = "All Students", hsenroll$variable)

gradenroll <- merge(hsgrad, hsenroll, by.x = c("District.Name","Category"), by.y = c("District.Name","variable"))

#Show types of non-completing students

#Show trends for region
gradregion <- ddply(gradenroll, .(Category, School.Year), summarise, 
                    wm = weighted.mean(X4.Year.Graduation.Rate, value, na.rm = TRUE))

#Get overall rates for the region
ddply(gradenroll, .(Category), summarise, wm = weighted.mean(X4.Year.Graduation.Rate, value, na.rm = TRUE))


#Show trends for alliance / not alliance
#Then add variable for towns served by Alliance Districts
gradenroll$District.Type <- ifelse(gradenroll$District.Name %in% c("Bloomfield School District",
                                                                   "East Hartford School District","East Windsor School District","Hartford School District","Manchester School District","Vernon School District","Windsor School District","Windsor Locks School District"), 
                                   "Alliance District","Not Alliance District")

gradalliance <- ddply(gradenroll, .(District.Type, School.Year), summarise, 
                    wm = weighted.mean(X4.Year.Graduation.Rate, value, na.rm = TRUE))


#Show by demographic and town
#By Race
#Re-use arrow graphs
qplot(data = subset(hsgrad, Category %in% c("White","Black","Hispanic","Asian")), 
      y = Category, x = X4.Year.Graduation.Rate) + 
  theme_minimal() + 
  facet_wrap(~ District.Name, ncol = 6)

qplot(data = subset(hsgrad, Category %in% c("Male","Female")), 
      y = Category, x = X4.Year.Graduation.Rate) + 
  theme_minimal() + 
  facet_wrap(~ District.Name, ncol = 6)

#Show by school
#One big graph