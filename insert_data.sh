#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Create tables
$PSQL "DROP TABLE IF EXISTS games, teams CASCADE;"
$PSQL "CREATE TABLE teams(
  team_id SERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(100) UNIQUE NOT NULL
);"
$PSQL "CREATE TABLE games(
  game_id SERIAL PRIMARY KEY NOT NULL,
  year INT NOT NULL,
  round VARCHAR(100) NOT NULL,
  winner_id INT NOT NULL REFERENCES teams(team_id),
  opponent_id INT NOT NULL REFERENCES teams(team_id),
  winner_goals INT NOT NULL,
  opponent_goals INT NOT NULL
);"

# Loop through the CSV file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNERGOAL OPPONENTGOAL
do
  if [[ $YEAR != "year" ]]
  then
    # Check if winner exists
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ "$INSERT_WINNER_RESULT" == "INSERT 0 1" ]]
      then
        echo "Inserted team: $WINNER"
      fi
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # Check if opponent exists
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ "$INSERT_OPPONENT_RESULT" == "INSERT 0 1" ]]
      then
        echo "Inserted team: $OPPONENT"
      fi
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # Insert game record
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
                                VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNERGOAL, $OPPONENTGOAL)")
    if [[ "$INSERT_GAME_RESULT" == "INSERT 0 1" ]]
    then
      echo "Inserted game: $YEAR, $ROUND - $WINNER vs $OPPONENT"
    fi
  fi
done
# Do not change code above this line. Use the PSQL variable above to query your database.
