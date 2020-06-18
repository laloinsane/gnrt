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
  read -p 'Description : ' description
  while true; do
    read -p "Add Status to README file? [Y/N] " answer
    case $answer in
      [Yy]*) echo 'Status : Insert the status separated by commas (Network,WebBrowser)'
        IFS=',' read -a status
        for index in ${!status[*]}; do
          [ $index == 0 ] && status_tag=$(cat << EOF


## Status

${status[index]}
EOF
) || status_tag=$status_tag$(cat << EOF

${status[index]}
EOF
)
        done ; break ;;
      [Nn]*) break ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
  while true; do
    read -p "Add Pre-requisitos to README file? [Y/N] " answer
    case $answer in
      [Yy]*) echo 'Pre-requisitos : Insert the status separated by commas (Network,WebBrowser)'
        IFS=',' read -a pre_requisitos
        for index in ${!pre_requisitos[*]}; do
          [ $index == 0 ] && pre_requisitos_tag=$(cat << EOF


## Requisitos

- ${pre_requisitos[index]}
EOF
) || pre_requisitos_tag=$pre_requisitos_tag$(cat << EOF
- ${pre_requisitos[index]}
EOF
)
        done ; break ;;
      [Nn]*) break ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
  while true; do
    read -p "Add Instalation to README file? [Y/N] " answer
    case $answer in
      [Yy]*) echo 'Instalation : Insert the status separated by commas (Network,WebBrowser)'
        IFS=',' read -a instalation
        for index in ${!instalation[*]}; do
          [ $index == 0 ] && instalation_tag=$(cat << EOF


## Instalación

- ${instalation[index]}
EOF
) || instalation_tag=$instalation_tag$(cat << EOF
- ${instalation[index]}
EOF
)
        done ; break ;;
      [Nn]*) break ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
  while true; do
    read -p "Add Privacy Policy to README file? [Y/N] " answer
    case $answer in
      [Yy]*) echo 'Privacy Policy : Insert the status separated by commas (Network,WebBrowser)'
        IFS=',' read -a privacy_policy
        for index in ${!privacy_policy[*]}; do
          [ $index == 0 ] && privacy_policy_tag=$(cat << EOF


## Política de Privacidad

${privacy_policy[index]}
EOF
) || privacy_policy_tag=$privacy_policy_tag$(cat << EOF
;${privacy_policy[index]}
EOF
)
        done ; break ;;
      [Nn]*) break ;;
      *) echo "Please answer yes or no." ;;
    esac
  done

  [ ! -f "$readme_file" ] && touch "$readme_file"

  cat > "$readme_file" << EOF
# $title

$description$status_tag$pre_requisitos_tag$instalation_tag$privacy_policy_tag
EOF

  [ -s "$readme_file" ] && echo "\"$readme_file\" created successfully." && exit 0 || echo "Error!! occurred during file creation of \"$readme_file\"." 1>&2 && exit 1
}
