#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

echo $($PSQL "TRUNCATE TABLE games, teams;")

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    #get ids
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

    #if winning team is not registered in db
    if [[ -z $WINNER_ID ]]
    then
      #insert winning team
      WINNER_INSERION=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")

      if [[ $WINNER_INSERTION == "INSERT 0 1" ]]
      then
        echo Inserted team $WINNER
      fi
    fi

    if [[ -z $OPPONENT_ID ]]
    then
      OPPONENT_INSERTION=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT');")
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

      if [[ $OPPONENT_INSERTION == "INSERT 0 1" ]]
      then
        echo Inserted team $OPPONENT
      fi
    fi

    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")

    if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]
    then
      echo Inserted game $YEAR $ROUND $WINNER $OPPONENT
    else
      echo Did not insert game $YEAR $ROUND $WINNER $OPPONENT
    fi
  fi
done