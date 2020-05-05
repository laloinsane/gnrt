#!/bin/bash

function fanart_variables() {
  tmp="./fanart"                                                                        # temporary directory
  aw=16                                                                                 # aspect ratio width
  ah=9                                                                                  # aspect ratio height
  t="hardlight"                                                                         # compose type
}

function fanart_init() {
  fanart_variables
  mkdir $tmp
}

function fanart_crop() {
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

function fanart_logo() {
  [ ! -z "$1" ] && png=$(ls $PRODIR/logos | grep -i "$1.png") ; [ $? != 0 ] && echo "The input logo don't exists" 1>&2 && return 1   # input logo
  [ ! -f "$tmp/crop.jpg" ] && echo "The input file don't exists" 1>&2 && return 1       # input file

  cw=$(identify $tmp/crop.jpg | cut -d " " -f 3 | cut -d "x" -f 1)                      # image crop width
  ch=$(identify $tmp/crop.jpg | cut -d " " -f 3 | cut -d "x" -f 2)                      # image crop height
  lp=$(bc <<< "$cw / 6")                                                                # logo proportion (1/5)
  lmp=$(bc <<< "$cw / 150")                                                             # logo margin proportion (3000/150=20)
  convert "$PRODIR/logos/$png" -resize $(($lp - $(($lmp * 2)) ))'x' $tmp/logo.png
  [[ "$2" != 1 ]] && convert $tmp/logo.png -alpha on -channel a -evaluate multiply $2 +channel $tmp/logo.png
  fanart_rectangle $3 $4
}

function fanart_rectangle() {
  [ ! -f "$tmp/logo.png" ] && echo "The logo file don't exists" 1>&2 && return 1        # logo file

  lw=$(identify $tmp/logo.png | cut -d " " -f 3 | cut -d "x" -f 1)                      # logo width
  lh=$(identify $tmp/logo.png | cut -d " " -f 3 | cut -d "x" -f 2)                      # logo height
  rmp=$(bc <<< "$lw / 56")                                                              # rectangle margin proportion (560/56=10)
  convert -size $(($lw + $rmp * 2))'x'$(($lh + $rmp * 2)) xc:$1 $tmp/rectangle.png
  [[ "$2" != 1 ]] && convert $tmp/rectangle.png -alpha on -channel a -evaluate multiply $2 +channel $tmp/rectangle.png
}

function generate_fanart() {
  [ -f "$1" ] && while true; do                                                         # output file
    read -p "The file $1 already exists, Do you want to overwrite it? [Y/N] " answer
    case $answer in
      [Yy]*) get_fanart $1 ; break ;;
      [Nn]*) fanart_out ; exit ;;
      *) echo "Please answer yes or no." ;;
    esac
  done || get_fanart $1
}

function get_fanart() {
  [[ -f "$tmp/crop.jpg" && -f "$tmp/logo.png" && -f "$tmp/rectangle.png" ]] && fanart_compose $1 && return 0
  [ -f "$tmp/crop.jpg" ] && cp $tmp/crop.jpg $1 && return 0
}

function fanart_compose() {
  composite -geometry +$(($(($lp * 5)) + $lmp - $rmp))+$(($ch - $lh - $lmp - $rmp)) $tmp/rectangle.png $tmp/crop.jpg $tmp/compose.jpg
  composite -geometry +$(($(($lp * 5)) + $lmp))+$(($ch - $lh - $lmp)) $tmp/logo.png $tmp/compose.jpg $1
}

function fanart_out() {
  rm -rf $tmp && return 0
}
