#!/bin/bash

function generate_movie_nfo() {
  output=$1
  if [ $(echo -n "$output" | wc -m) -gt 4 ]; then
    echo "$output" | grep -i ".nfo" 1>/dev/null
    if [ $? != 0 ]; then
      output=$output".nfo"
    fi
  else
    output=$output".nfo"
  fi
  [ -f "$output" ] && while true; do
    read -p "The file \"$1\" already exists, Do you want to overwrite it? [Y/N] " answer
    case $answer in
      [Yy]*) movie_nfo_manual_version "$output" ; break ;;
      [Nn]*) exit ;;
      *) echo "Please answer yes or no." ;;
    esac
  done || movie_nfo_manual_version "$output"
}

function movie_nfo_manual_version() {
  movie_file="$output"
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
  echo 'Countries : Insert the countries separated by commas (USA,Canada,UK)'
  IFS=',' read -a countries
  for index in ${!countries[*]}; do
    [ $index == 0 ] && countries_tag=$(cat << EOF

  <country>${countries[index]}</country>
EOF
) || countries_tag=$countries_tag$(cat << EOF

  <country>${countries[index]}</country>
EOF
)
  done
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
  <tagline></tagline>$genre_tag$countries_tag
  <director>$director</director>
  <premiered>$release</premiered>
  <year>$year</year>
  <studio>$studio</studio>$actor_tag
</movie>
EOF

  [ -s "$movie_file" ] && echo "\"$movie_file\" created successfully." && exit 0 || echo "Error!! occurred during file creation of \"$movie_file\"." 1>&2 && exit 1
}
