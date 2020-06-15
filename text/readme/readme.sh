#!/bin/bash

function generate_readme_file() {
  output=$1
  if [ $(echo -n "$output" | wc -m) -gt 3 ]; then
    echo "$output" | grep -i ".md" 1>/dev/null
    if [ $? != 0 ]; then
      output=$output".md"
    fi
  else
    output=$output".md"
  fi
  [ -f "$output" ] && while true; do
    read -p "The file \"$1\" already exists, Do you want to overwrite it? [Y/N] " answer
    case $answer in
      [Yy]*) readme_manual_version "$output" ; break ;;
      [Nn]*) exit ;;
      *) echo "Please answer yes or no." ;;
    esac
  done || readme_manual_version "$output"
}

function readme_manual_version() {
  readme_file="$output"
  echo 'COMPLETE THE INFORMATION'
  printf '\n'
  read -p 'Title : ' title

  [ ! -f "$readme_file" ] && touch "$readme_file"

  cat > "$readme_file" << EOF
# $title
EOF

  [ -s "$readme_file" ] && echo "\"$readme_file\" created successfully." && exit 0 || echo "Error!! occurred during file creation of \"$readme_file\"." 1>&2 && exit 1
}
