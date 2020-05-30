#!/bin/bash

function generate_desktop_file() {
  [ -f "$1" ] && while true; do
    read -p "The file \"$1\" already exists, Do you want to overwrite it? [Y/N] " answer
    case $answer in
      [Yy]*) desktop_manual_version "$1" ; break ;;
      [Nn]*) exit ;;
      *) echo "Please answer yes or no." ;;
    esac
  done || desktop_manual_version "$1"
}

function desktop_manual_version() {
  desktop_file="$1"
  echo 'COMPLETE THE INFORMATION'
  printf '\n'
  read -p 'Version : ' version
  read -p 'Name : ' name
  read -p 'GenericName : ' genericname
  read -p 'Exec : ' exec
  read -p 'Icon : ' icon
  read -p 'Type : ' type
  echo 'Categories : Insert the categories separated by commas (Network,WebBrowser)'
  IFS=',' read -a categories
  for index in ${!categories[*]}; do
    [ $index == 0 ] && categorie_tag=$(cat << EOF
${categories[index]}
EOF
) || categorie_tag=$categorie_tag$(cat << EOF
;${categories[index]}
EOF
)
  done

  [ ! -f "$desktop_file" ] && touch "$desktop_file"

  cat > "$desktop_file" << EOF
[Desktop Entry]
Version=$version
Name=$name
GenericName=$genericname

Exec=$exec
Terminal=false
Icon=$icon
Type=$type
Categories=$categorie_tag
X-Ayatana-Desktop-Shortcuts=NewWindow

[NewWindow Shortcut Group]
Name=New Window
Exec=$exec -n
TargetEnvironment=Unity
EOF

  [ -s "$desktop_file" ] && echo "\"$desktop_file\" created successfully." && exit 0 || echo "Error!! occurred during file creation of \"$desktop_file\"." 1>&2 && exit 1
}
