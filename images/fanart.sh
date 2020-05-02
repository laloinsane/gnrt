#!/bin/bash

function fanart_variables() {
  tmp="./fanart"                                                      # temporary directory
  aw=16                                                               # aspect ratio width
  ah=9                                                                # aspect ratio height
  t="hardlight"                                                       # compose type
}

function fanart_crop() {
  iw=$(identify ./$1 | cut -d " " -f 3 | cut -d "x" -f 1)             # input image width
  ih=$(identify ./$1 | cut -d " " -f 3 | cut -d "x" -f 2)             # input image height
  mcd=$(bc <<< "$iw / $aw")                                           # calculo de height por width (maximo comun divisor)
  h=$(($ah * $mcd))                                                   # image cropped height
  if [ $h -gt $ih ]; then
    mcd=$(bc <<< "$ih / $ah")                                         # calculo de width por height (maximo comun divisor)
    w=$(($aw * $mcd))                                                 # image cropped width
    ic=$(bc <<< "$(($iw - $w)) / 2")                                  # original image center
    convert $1 -crop $w'x'$ih+$ic+0 $tmp/crop.jpg
  else
    ic=$(bc <<< "$(($ih - $h)) / 2")                                  # original image center
    convert $1 -crop $iw'x'$h+0+$ic $tmp/crop.jpg
  fi
}

function fanart_rectangle() {
  lw=$(identify $tmp/logo.png | cut -d " " -f 3 | cut -d "x" -f 1)    # logo width
  lh=$(identify $tmp/logo.png | cut -d " " -f 3 | cut -d "x" -f 2)    # logo height
  rmp=$(bc <<< "$lw / 56")                                            # rectangle margin proportion (560/56=10)
  convert -size $(($lw + $rmp * 2))'x'$(($lh + $rmp * 2)) xc:$c $tmp/rectangle.png
}

function fanart_compose() {
  composite -geometry +$(($(($lp * 4)) + $lmp - $rmp))+$(($ch - $lh - $lmp - $rmp)) $tmp/rectangle.png $tmp/crop.jpg $tmp/compose.jpg
  composite -geometry +$(($(($lp * 4)) + $lmp))+$(($ch - $lh - $lmp)) $tmp/logo.png $tmp/compose.jpg $1
}

function fanart_logo() {
  cw=$(identify $tmp/crop.jpg | cut -d " " -f 3 | cut -d "x" -f 1)    # image crop width
  ch=$(identify $tmp/crop.jpg | cut -d " " -f 3 | cut -d "x" -f 2)    # image crop height
  lp=$(bc <<< "$cw / 5")                                              # logo proportion (1/5)
  lmp=$(bc <<< "$cw / 150")                                           # logo margin proportion (3000/150=20)
  convert $1 -resize $(($lp - $(($lmp * 2)) ))'x' $tmp/logo.png
  fanart_rectangle
  fanart_compose $2
}

function create_fanart() {
    fanart_variables
    mkdir $tmp
    fanart_crop $1
    [ -z "$3" ] && cp $tmp/crop.jpg $2 && rm -rf $tmp && return 0 || fanart_logo "$PRODIR/logos/$png" $2 && rm -rf $tmp && return 0
}

function main_fanart() {
  [ ! -f "$1" ] && echo "The input file don't exists" 1>&2 && return 1                  # input file

  [ ! -z "$3" ] && png=$(ls $PRODIR/logos | grep -i $3.png) && [ $? != 0 ] && echo "The input logo don't exists" 1>&2 && return 1                  # input logo

  [ ! -z "$4" ] && c=$4 || c="none"                                                     # color of gradient

  [ -f "$2" ] && while true; do                                                         # output file
    read -p "The file $1 already exists, Do you want to overwrite it? [Y/N] " answer
    case $answer in
      [Yy]*) create_fanart $1 $2 $3 ; break ;;
      [Nn]*) exit ;;
      *) echo "Please answer yes or no." ;;
    esac
  done || create_fanart $1 $2 $3
}
