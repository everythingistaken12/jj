
-- if unknown user game day or user has passed new user journey days
return JetpackUser.GetCurrentGameDay() == -1 or 
    JetpackUser.GetCurrentGameDay() >= 7

