#!/bin/bash

function generate_movie_nfo() {
  [ -f "$1" ] && while true; do
    read -p "The file \"$1\" already exists, Do you want to overwrite it? [Y/N] " answer
    case $answer in
      [Yy]*) movie_nfo_manual_version "$1" ; break ;;
      [Nn]*) exit ;;
      *) echo "Please answer yes or no." ;;
    esac
  done || movie_nfo_manual_version "$1"
}

function movie_nfo_manual_version() {
  movie_file="$1"
  echo 'COMPLETE THE INFORMATION'
  printf '\n'
  read -p 'Title : ' title
  read -p 'Description : ' description
  echo 'Genres : Insert the genres separated by commas (Action,Adventure,Terror)'
  IFS=',' read -a genres
  for index in ${!genres[*]}; do
    [ $index == 0 ] && genre_tag=$(cat << EOF

  <genre>${genres[index]}</genre>
EOF
) || genre_tag=$genre_tag$(cat << EOF

  <genre>${genres[index]}</genre>
EOF
)
  done
  read -p 'Country : ' country
  read -p 'Director : ' director
  read -p 'Release : ' release
  read -p 'Studio : ' studio
  echo 'Actors : Insert the actors separated by commas (Christian Bale,Rosamund Pike,Wes Studi)'
  IFS=',' read -a actors
  for index in ${!actors[*]}; do
    [ $index == 0 ] && actor_tag=$(cat << EOF

  <actor>
    <name>${actors[index]}</name>
    <role></role>
    <order></order>
    <thumb></thumb>
  </actor>
EOF
) || actor_tag=$actor_tag$(cat << EOF

  <actor>
    <name>${actors[index]}</name>
    <role></role>
    <order></order>
    <thumb></thumb>
  </actor>
EOF
)
  done

  [ ! -z "$description" ] && outline=$(echo $description | cut -d "." -f 1).
  [ ! -z "$release" ] && year=$(echo $release | cut -d "-" -f 1)
  [ ! -f "$movie_file" ] && touch "$movie_file"

  cat > "$movie_file" << EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<movie>
  <title>$title</title>
  <originaltitle>$title</originaltitle>
  <userrating>0</userrating>
  <outline>$outline</outline>
  <plot>$description</plot>
  <tagline></tagline>$genre_tag
  <country>$country</country>
  <director>$director</director>
  <premiered>$release</premiered>
  <year>$year</year>
  <studio>$studio</studio>$actor_tag
</movie>
EOF

  [ -s "$movie_file" ] && echo "\"$movie_file\" created successfully." && exit 0 || echo "Error!! occurred during file creation of \"$movie_file\"." 1>&2 && exit 1
}
