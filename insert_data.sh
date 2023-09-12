#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE games, teams")

#insert teams into teams table
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do 
  #doing winner teams into teams table first
  if [[ $WINNER != "winner" ]]
  then
    #check if team already exists
    TEAM_NAME=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")

    #if that team doesnt exist yet
    if [[ -z $TEAM_NAME ]]
    then 
      #insert the team
      INSERTED_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      #message if it's done successfully
      if [[ $INSERTED_TEAM == "INSERT 0 1" ]]
      then
        echo Inserted into teams from winner, $WINNER
      fi
    #if that team already exists
    fi
  fi
  #doing opponent teams into teams table
  if [[ $OPPONENT != "opponent" ]]
  then
    #check if it was already implemented
    TEAM_NAME=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")

    #if that team doesnt exist yet
    if [[ -z $TEAM_NAME ]]
    then
      #insert the team
      INSERTED_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      #message if it's done successfully
      if [[ $INSERTED_TEAM == "INSERT 0 1" ]]
      then
        echo Insered into teams from losers, $OPPONENT
      fi
    fi
  fi
done

#insert games into games table 
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  #doing the games table now
  #making sure we're not adding the first line
  if [[ $YEAR != "year" ]]
  then
    #we need to get winner_id and opponent_id from teams
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    #now we can insert the info 
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")
    #let's get a confirmation message for that
    if [[ $INSERT_GAME == "INSERT 0 1" ]]
    then
      echo Inserted into games, $YEAR $ROUND $WINNER_ID $OPPONENT_ID $WINNER_GOALS $OPPONENT_GOALS
    fi
  fi
done

