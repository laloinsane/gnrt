#!/bin/bash

function poster_variables() {
  tmp="./poster"                                                      # temporary directory
  aw=2                                                                # aspect ratio width
  ah=3                                                                # aspect ratio height
  t="hardlight"                                                       # compose type
}

function poster_crop() {
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

function poster_gradient() {
  lw=$(identify $tmp/logo.png | cut -d " " -f 3 | cut -d "x" -f 1)    # logo width
  lh=$(identify $tmp/logo.png | cut -d " " -f 3 | cut -d "x" -f 2)    # logo height
  gmp=$(bc <<< "$ch / 35.9625")                                       # gradient margin bottom proportion (2877/35.9625=80)
  convert -size $cw'x'$(($lh + $gmp)) gradient:"none"-$c $tmp/gradient.png
}

function poster_compose() {
  gw=$(identify $tmp/gradient.png | cut -d " " -f 3 | cut -d "x" -f 1)     # gradient width
  gh=$(identify $tmp/gradient.png | cut -d " " -f 3 | cut -d "x" -f 2)     # gradient height
  composite -geometry +0+$(($ch - $gh)) $tmp/gradient.png $tmp/crop.jpg -compose $t $tmp/compose.jpg
  lm=$(bc <<<"$(($cw - $lp)) / 2")                                        # left margin logo
  composite -geometry +$lm+$(($ch - $gh)) $tmp/logo.png $tmp/compose.jpg $1
}

function poster_logo() {
  cw=$(identify $tmp/crop.jpg | cut -d " " -f 3 | cut -d "x" -f 1)    # image crop width
  ch=$(identify $tmp/crop.jpg | cut -d " " -f 3 | cut -d "x" -f 2)    # image crop height
  lp=$(bc <<< "$cw / 1.043525571")                                    # logo proportion (1918/1.043525571)
  convert $1 -resize $lp'x' $tmp/logo.png
  poster_gradient
  poster_compose $2
}

function create_poster() {
  poster_variables
  mkdir $tmp
  poster_crop $1
  [ -z "$3" ] && cp $tmp/crop.jpg $2 && rm -rf $tmp && return 0 || poster_logo "$PRODIR/logos/$png" $2 && rm -rf $tmp && return 0
}

function main_poster() {
  [ ! -f "$1" ] && echo "The input file don't exists" 1>&2 && return 1                  # input file

  [ ! -z "$3" ] && png=$(ls $PRODIR/logos | grep -i $3.png) && [ $? != 0 ] && echo "The input logo don't exists" 1>&2 && return 1                  # input logo

  [ ! -z "$4" ] && c=$4 || c="none"                                                     # color of gradient

  [ -f "$2" ] && while true; do                                                         # output file
    read -p "The file $1 already exists, Do you want to overwrite it? [Y/N] " answer
    case $answer in
      [Yy]*) create_poster $1 $2 $3 ; break ;;
      [Nn]*) exit ;;
      *) echo "Please answer yes or no." ;;
    esac
  done || create_poster $1 $2 $3
}
