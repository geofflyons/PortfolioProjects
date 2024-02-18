#Load the dataset
library(readxl)
df <- read_excel("C:/Users/Admin/Documents/JCU_Data_Science/MA5800_Foundations for Data Science/MA5800 Capstone/ma5800capstonedatasalvos.xlsx")

head(df,6); str(df); colnames(df); dim(df) # Explore the df. There are 107 249 rows and 63 columns

sum(duplicated(df)) #Check duplicated columns. There are no duplicates.

colnames(df) <- gsub("\\s|\\.|,|/", "", colnames(df)) #Clean cols of whitespace and special characters

#The Visit_ID and Number of Dependents variables are the wrong datatype and need to be corrected
df$VisitID <- as.character(df$VisitID)
df$NumberofDependants <- as.numeric(df$NumberofDependants)

#Several variables are not needed for this analysis and have to be dropped from the df
library(dplyr)
df <- select(df, -SAMISCode7, -FundingRegionName, -CentreCode, -PrivacyNotice, 
             -LastVisitedSalvosConnect, -VisitSessionWorker, -FutureConsentTSA,-State_new, -Territory, 
             -Age_new, -Gender_NEW, -Indigenous_New, -COB_NEW, -Residency_NEW, -Income_NEW, 
             -Disability_NEW, -Language_NEW, -Household_NEW, -Issue_NEW, -Livingsituation_NEW, 
             -Referral_NEW, -ContributingEvent_NEW,-AssistanceReferralorUnmetDemand, -Category, 
             -Type, -Subtype, -Status, -QUANTITY, -COST, -ContributingEvent, -ReferralSource, 
             -UnderlyingIssue, -VisitID, -MainLanguage, -VisitSessionDate, -ResidencyStatus, 
             -CountryofBirth, -ClientPostcode, -CentreName)
names(df)

#Change the variable name of the variable "SAMISCode1" to "SAMISCode"
colnames(df)[colnames(df) == "SAMISCode1"] <- "SAMISCode"

#Now check for missingness. Results show a great deal of missing values across the dataset. Some columns are completely blank.
sum(is.na(df))
colSums(is.na(df))

#Columns that are completely blank or have very high missingness are dropped from the dataset. 
df <- select(df, -Funded, -SessionStatus, -Bankruptcy, -TotalPeopleSupported, -VisitSessionType, 
             -VisitSessionTime, -SessionMode, -HouseholdComposition, -NumberofDependants, -CallID, 
             -DSSResearchConsent, -SecondarySource, -DSSReportingConsent)
colnames(df)

#The IncomeSource, MainIssue, and LivingSituation variables have trailing numbers in the responses. # (e.g. Don't know 99). I need to trim these numbers from them before I can run analyses.
df$IncomeSource <- sub("\\s*\\d+$", "", df$IncomeSource)
df$MainIssue <- sub("\\s*\\d+$", "", df$MainIssue)
df$LivingSituation <- sub("\\s*\\d+$", "", df$LivingSituation)

# Display the response levels of the "Disability" variable
response_levels <- unique(df$Disability)
print(response_levels) #There are many response levels that overlap. It is very messing.
#Use the ifelse() function to aggregate responses 
df$Disability <- ifelse(df$Disability %in% c("None", "Nothing", "None Identified", 
                                             "No disorder"), "None", df$Disability)
df$Disability <- ifelse(df$Disability %in% c("Psychiatric Disorder, Physical / Diverse", 
                                             "Psychiatric Disorder, Intellectual Learning" , 
                                             "Psychiatric Disorder, Sensory / Speech, Physical / Diverse", 
                                             "Psychiatric Disorder, Intellectual Learning, Sensory / Speech, Physical /Diverse", "Psychiatric Disorder, Sensory / Speech","Psychiatric, Physical/diverse", "Psychiatric","Psychiatric, Sensory/Speech","Psychiatric, Sensory/Speech, Physical/diverse",
                                             "Psychiatric, None Identified"), "Psychiatric Disorder", df$Disability)
df$Disability <- ifelse(df$Disability %in% c("Intellectual Learning, Physical / Diverse", "Intellectual Learning", 
                                             "Psychiatric Disorder, Intellectual Learning, Sensory / Speech", 
                                             "Psychiatric Disorder, Intellectual Learning, Physical / Diverse", "Intellectual Learning, Sensory / Speech",
                                             "Intellectual Learning, Sensory / Speech, Physical / Diverse",
                                             "Intellectual Learning, Psychiatric","Intellectual Learning, Physical/diverse",
                                             "Intellectual Learning, Psychiatric, Physical/diverse","Intellectual Learning, Sensory/Speech",
                                             "Intellectual Learning, Psychiatric, Sensory/Speech, Physical/diverse",
                                             "Intellectual Learning, Psychiatric, Sensory/Speech","Intellectual Learning, Sensory/Speech, Physical/diverse", 
                                             "Not stated/inadequately described, Intellectual Learning"), "Intellectual Disability", df$Disability)
df$Disability <- ifelse(df$Disability %in% c("Physical / Diverse", "Sensory / Speech", "Sensory / Speech, Physical / Diverse", "Sensory/Speech",
                                             "Physical/diverse","Sensory/Speech, Physical/diverse"), "Sensory/Physically Diverse", df$Disability)
df$Disability <- ifelse(df$Disability %in% c("Not stated / inadequately described", "Not stated/inadequately described",
                                             "Not stated/inadequately described, None Identified",NA), "Unknown", df$Disability)

str(df) # The data is now clean and I'm left with 107249 rows and 11 columns

######PART 2: EXPLORING AGE OUTLIERS#############
# Create histogram and boxplot using ggplot2
library(ggplot2)
ggplot(df, aes(x = Age)) +
  geom_histogram(binwidth = 1, color = "black", fill = "blue") +
  labs(x = "Age", y = "Frequency", title = "Histogram of Age")

ggplot(df, aes(x = "", y = Age)) +
  geom_boxplot(fill = "blue", color = "black") +
  labs(x = "", y = "Age", title = "Boxplot of Age")

summary(df$Age) #I can see a summary of the data.
sd(df$Age) #calculating the standard deviation

#The upper quartile is 51 years but the boxplot suggests many observations above this.
#Calculating the frequency count of ages above 51
old_people <- subset(df, Age > 100) # Create a subset of ages greater than 100
age_freq_old_people <- table(old_people$Age) # Calculate the frequency of ages greater than 100
print(age_freq_old_people)

#Create a table that shows old peoples SAMIS code, Age, suburb, indigenous status
over100 <- df[df$Age > 100, ] # Select rows with Age greater than 100

# Create a table showing SAMISCODE,SUBURB,STATE,INDIGENOUS,INCOME
over100table <- data.frame(
  SAMISCode = over100$SAMISCode,
  Suburb = over100$ClientSuburb,
  State = over100$ClientState,
  Indigenous = over100$IndigenousStatus,
  IncomeSource = over100$IncomeSource
)

# Rename the column names
colnames(over100table) <- c("SAMISCode", "Suburb", "State", "Indigenous", "Income Source")
View(over100table) #See the table in a new tab. Nice one.

#Create another table for disability, main issue, living situation
over100table2 <- data.frame(
  SAMISCode = over100$SAMISCode,
  Disability = over100$Disability,
  Problem = over100$MainIssue,
  Home = over100$LivingSituation
)

colnames(over100table2) <- c("SAMISCode", "Disability", "Problem", "Home") # Rename the column names
View(over100table2) # View the result. Nailed it.


####DISSIMILARITY#####
#Firstly I'll create a new variable of Age by groups. Then I can just limit the new df by people over 80.
age_groups <- cut(df$Age, breaks = c(0, 17, 29, 44, 64, 80, Inf), labels = c("0 to 17", "18 to 29", "30 to 44", "45 to 64", "65 to 80", "80 plus"), right = FALSE)
df$AgeGroup <- age_groups # Add the age groups as a new column in the dataset
colnames(df)

# Subset the dataset into two groups. The selected clients and remaining clients (other_clients)
old_clients <- subset(df, SAMISCode %in% c("KURBEVM", "SAMJEXM", "ZULDUNM", "GUMMEBM", "TIRLAFM"))
other_clients <- subset(df, !(SAMISCode %in% c("KURBEVM", "SAMJEXM", "ZULDUNM", "GUMMEBM", "TIRLAFM")))

# Combine the selected clients and other clients into a new dataset using rbind(). This will be used for dissimilarity analysis
dissimilarity_data <- rbind(old_clients, other_clients)

#Select only those in the df that are in the 80 plus group
old_people_dissimilarity_data <- subset(dissimilarity_data, AgeGroup == "80 plus")

# Visualize the dissimilarity matrix
mds_coordinates <- cmdscale(dissimilarity_matrix)
dot_colors <- ifelse(old_people_dissimilarity_data$SAMISCode %in% selected_clients$SAMISCode, "red", "black")
plot(mds_coordinates, type = "n", main = "Euclidean Dissimilarity of 80 plus via Income and Gender")
text(mds_coordinates[, 1], mds_coordinates[, 2], labels = old_people_dissimilarity_data$SAMISCode, col = ifelse(old_people_dissimilarity_data$SAMISCode %in% selected_clients$SAMISCode, "red", "black"))
plot(mds_coordinates, type = "n", main = "Euclidean Dissimilarity of 80 plus via Income and Gender",xlab="", ylab="")
points(mds_coordinates[, 1], mds_coordinates[, 2], col = dot_colors, pch = 16)

# Convert the dissimilarity matrix to a distance matrix
distance_matrix <- as.dist(dissimilarity_matrix)
dissimilarity_coeffs <- 1 - as.matrix(distance_matrix) # Compute dissimilarity coefficients
print(dissimilarity_coeffs)

#Drop people from the dataset who are older than 100
df <- df[df$Age <= 100, ]

###PART 3: EXPLORING AGE & DEMOGRAPHICS####
###FIGURE 3 AGE DISTRIBUTION
#Explore the distribution of AgeGroup
AgeGroupDist <- table(df$AgeGroup)
print(AgeGroupDist)
bar_colors <- c("red", "blue", "green", "orange", "purple")
barplot(AgeGroupDist, main = "Age Distribution", xlab = "", ylab = "Frequency", las = 3, col = bar_colors)

###FIGURE 34 AGE ACROSS STATE
library(ggplot2)
ggplot(df, aes(x = CentreState, fill = AgeGroup)) +
  geom_bar(position = "stack") +
  labs(title = "Distribution of Age Groups Across Centre States", x = "Centre State", y = "Count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

###TABLE 4 GENDER BY AGE####
#Gender by Age
library(dplyr)
library(tidyr)
# Calculate the count and percentage of each gender within each age group
df_gender <- df %>%
  group_by(AgeGroup, Gender) %>%
  summarise(count = n()) %>%
  mutate(percentage = round(count / sum(count) * 100, 2))
# Pivot the table for better display
df_gender_pivot <- pivot_wider(df_gender, names_from = Gender, values_from = count:percentage)
# Sort the table by AgeGroup
df_gender_sorted <- df_gender_pivot %>%
  arrange(AgeGroup)
# Print the resulting table
View(df_gender_sorted)

###FIGURE 5 LIVING SITUATION
library(dplyr)
top_5_living <- df %>%
  count(LivingSituation) %>%
  mutate(Percentage = n / sum(n) * 100) %>%
  top_n(5, n) %>%
  arrange(desc(n))
top_5_living$Percentage <- round(top_5_living$Percentage, 2) # Round 2 decimal places
# Print the resulting table
View(top_5_living)

library(ggplot2)#Create the horizontal barchart
ggplot(top_5_living, aes(x = LivingSituation, y = Percentage, fill = LivingSituation)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = paste0(Percentage, "%")), hjust = -0.2, color = "black", size = 3.5) +
  labs(x = "Living Situation", y = "Percentage", fill = "Living Situation") +
  ggtitle("Top 5 Living Situation") +
  theme_bw() +
  coord_flip() +
  theme(axis.text.y = element_blank())

####TABLE 5: LIVING SITUATION ACROSS AGE GROUP
# Create a table showing the top five LivingSituation for each level of AgeGroup
library(dplyr)
# Create a table showing the top five LivingSituation for each level of AgeGroup
top_5_living_age <- df %>%
  group_by(AgeGroup) %>%
  count(LivingSituation) %>%
  top_n(5, n) %>%
  arrange(AgeGroup, desc(n)) %>%
  mutate(Percentage = round(n / sum(n) * 100, 2))
# Print the resulting table
View(top_5_living_age)

#TABLE 6: DISABILITY ACROSS AGE GROUP
# Group the dataframe by AgeGroup and Disability
grouped_df_disab <- df %>% 
  group_by(AgeGroup, Disability) %>% 
  count() # Count the occurrences
# Calculate the total count for each AgeGroup
total_counts <- grouped_df_disab %>% 
  group_by(AgeGroup) %>%  #groups by AgeGroup
  summarise(total_count = sum(n))
# Join the total counts with the grouped dataframe
joined_df <- grouped_df_disab %>% 
  left_join(total_counts, by = "AgeGroup")
# Calculate the percentage for each combination of AgeGroup and Disability
percentage_df <- joined_df %>% 
  mutate(Percentage = round(n / total_count * 100, 2))#rounds to two dec places
# Sort by count of Disability in descending order
sorted_df <- percentage_df %>% 
  arrange(Disability, desc(n))
# Filter the top 4 Diability for each Age Group
top_4_df_dis <- sorted_df %>% 
  group_by(AgeGroup) %>% 
  top_n(4)
# Print the resulting table
View(top_4_df_dis)

####FIGURE 6 DISABILITY ACROSS AGE
# Create a horizontal bar plot with labels
library(ggplot2)
ggplot(top_4_df_dis, aes(x = reorder(Disability, Percentage), y = Percentage, fill = AgeGroup)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "", y = "Percentage", fill = "Disability") +
  ggtitle("Disabilities for each Age Group") +
  theme_bw() +
  coord_flip()
