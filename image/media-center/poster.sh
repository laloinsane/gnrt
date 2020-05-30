#!/bin/bash

function poster_variables() {
  tmp="./poster"                                                                        # temporary directory
  aw=2                                                                                  # aspect ratio width
  ah=3                                                                                  # aspect ratio height
  t="hardlight"                                                                         # compose type
}

function poster_init() {
  poster_variables
  mkdir $tmp
}

function poster_crop() {
  [ ! -f "$1" ] && echo "The input file don't exists" 1>&2 && return 1                  # input file
  iw=$(identify ./$1 | cut -d " " -f 3 | cut -d "x" -f 1)                               # input image width
  ih=$(identify ./$1 | cut -d " " -f 3 | cut -d "x" -f 2)                               # input image height
  mcd=$(bc <<< "$iw / $aw")                                                             # calculo de height por width (maximo comun divisor)
  h=$(($ah * $mcd))                                                                     # image cropped height
  if [ $h -gt $ih ]; then
    mcd=$(bc <<< "$ih / $ah")                                                           # calculo de width por height (maximo comun divisor)
    w=$(($aw * $mcd))                                                                   # image cropped width
    ic=$(bc <<< "$(($iw - $w)) / 2")                                                    # original image center
    convert $1 -crop $w'x'$ih+$ic+0 $tmp/crop.jpg
  else
    ic=$(bc <<< "$(($ih - $h)) / 2")                                                    # original image center
    convert $1 -crop $iw'x'$h+0+$ic $tmp/crop.jpg
  fi
}

function poster_logo() {
  [ ! -z "$1" ] && png=$(ls $PRODIR/logos | grep -i "$1.png") ; [ $? != 0 ] && echo "The input logo don't exists" 1>&2 && return 1   # input logo
  [ ! -f "$tmp/crop.jpg" ] && echo "The input file don't exists" 1>&2 && return 1       # input file
  cw=$(identify $tmp/crop.jpg | cut -d " " -f 3 | cut -d "x" -f 1)                      # image crop width
  ch=$(identify $tmp/crop.jpg | cut -d " " -f 3 | cut -d "x" -f 2)                      # image crop height
  lp=$(bc <<< "$cw / 4")                                                                # logo proportion (1/4)
  lmp=$(bc <<< "$lp / 20")
  xlmp=$(bc <<< "$lmp / 3")
  convert "$PRODIR/logos/$png" -resize $(($lp - $(($lmp * 2)) - $(($xlmp *2))))'x' $tmp/logo.png
  [[ "$2" != 1 ]] && convert $tmp/logo.png -alpha on -channel a -evaluate multiply $2 +channel $tmp/logo.png
  poster_rectangle $3 $4
}

function poster_rectangle() {
  [ ! -f "$tmp/logo.png" ] && echo "The logo file don't exists" 1>&2 && return 1        # logo file
  lw=$(identify $tmp/logo.png | cut -d " " -f 3 | cut -d "x" -f 1)                      # logo width
  lh=$(identify $tmp/logo.png | cut -d " " -f 3 | cut -d "x" -f 2)                      # logo height
  convert -size $(($lw + $xlmp * 2))'x'$(($lh + $xlmp * 2)) xc:$1 $tmp/rectangle.png
  [[ "$2" != 1 ]] && convert $tmp/rectangle.png -alpha on -channel a -evaluate multiply $2 +channel $tmp/rectangle.png
}

function generate_poster() {
  [ -f "$1" ] && while true; do                                                         # output file
    read -p "The file $1 already exists, Do you want to overwrite it? [Y/N] " answer
    case $answer in
      [Yy]*) get_poster $1 ; break ;;
      [Nn]*) poster_out ; exit ;;
      *) echo "Please answer yes or no." ;;
    esac
  done || get_poster $1
}

function get_poster() {
  [[ -f "$tmp/crop.jpg" && -f "$tmp/logo.png" && -f "$tmp/rectangle.png" ]] && poster_compose $1 && return 0
  [ -f "$tmp/crop.jpg" ] && cp $tmp/crop.jpg $1 && return 0
}

function poster_compose() {
  rh=$(identify $tmp/rectangle.png | cut -d " " -f 3 | cut -d "x" -f 2)
  composite -geometry +$(($(($lp * 3)) + $lmp))+$(($ch - $rh - $lmp)) $tmp/rectangle.png $tmp/crop.jpg $tmp/compose.jpg
  composite -geometry +$(($(($lp * 3)) + $lmp + $xlmp))+$(($ch + $xlmp - $rh - $lmp)) $tmp/logo.png $tmp/compose.jpg $1
}

function poster_out() {
  rm -rf $tmp && return 0
}
