#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#echo $($PSQL "TRUNCATE TABLE games, teams")

function get_team_id {
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$1'")
  if [[ -z $TEAM_ID ]]
  then
    echo "Insert new team $1"
    INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$1')")
    if [[ $INSERT_TEAM_RESULT = "INSERT 0 1" ]]
    then
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$1'")
    else
      echo "ERROR: Insert team $1 failed"
    fi
  fi
}

cat games.csv | while IFS=, read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    get_team_id "$WINNER"
    WINNER_ID=$TEAM_ID
    echo "ID of $WINNER is $WINNER_ID"

    get_team_id "$OPPONENT"
    OPPONENT_ID=$TEAM_ID
    echo "ID of $OPPONENT is $OPPONENT_ID"

    if [[ $WINNER_ID && $OPPONENT_ID ]]
    then
      GAME_INSERT_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      if [[ $GAME_INSERT_RESULT == 'INSERT 0 1' ]]
      then
        echo "Game on $ROUND $YEAR between $WINNER and $OPPONENT inserted"
      else
        echo "ERROR: Insert game on $ROUND $YEAR between $WINNER and $OPPONENT failed"
      fi
    fi
  fi

  echo -e "\n"
done
