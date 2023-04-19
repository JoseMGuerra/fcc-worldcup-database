#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate the teams and games tables to clear any existing data
echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # remove the csv headers
  if [[ $YEAR != "year" ]]; then
    # get the winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER' LIMIT 1")
    # if not found
    if [[ -z $WINNER_ID ]]; then
      # insert winner
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') ON CONFLICT(name) DO NOTHING")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]; then
        echo "Inserted winner into teams, $WINNER"
      fi
      # get new winner_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # get the opponent_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT' LIMIT 1")
    # if not found
    if [[ -z $OPPONENT_ID ]]; then
      # insert opponent
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') ON CONFLICT(name) DO NOTHING")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]; then
      echo "Inserted opponenent into teams, $OPPONENT"
      fi
      # get new opponent_id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
    # insert into games
    INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
    VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS,$OPPONENT_GOALS)")
    if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]; then
      echo "Inserted into games, year:$YEAR, round:'$ROUND', winner id:$WINNER_ID, opponent id:$OPPONENT_ID, winner goals:$WINNER_GOALS, opponent goals:$OPPONENT_GOALS"
    fi
  fi
done