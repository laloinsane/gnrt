#!/bin/bash

function fanart_variables() {
  tmp="./media_center"                                                                  # temporary directory
  aw=16                                                                                 # aspect ratio width
  ah=9                                                                                  # aspect ratio height
  t="hardlight"                                                                         # compose type
  proportion1=7
  proportion2=2
}

function poster_variables() {
  tmp="./media_center"                                                                  # temporary directory
  aw=2                                                                                  # aspect ratio width
  ah=3                                                                                  # aspect ratio height
  t="hardlight"                                                                         # compose type
  proportion1=4
  proportion2=3
}

function media_center_fanart_init() {
  fanart_variables
  mkdir $tmp
}

function media_center_poster_init() {
  poster_variables
  mkdir $tmp
}

function media_center_crop() {
  [ ! -f "$1" ] && echo "The input file don't exists" 1>&2 && return 1                  # input file
  cs=$(echo "$1" | tr -cd ' ' | wc -c)
  csn=$(($cs+3))
  iw=$(identify ./"$1" | cut -d " " -f $csn | cut -d "x" -f 1)                          # input image width
  ih=$(identify ./"$1" | cut -d " " -f $csn | cut -d "x" -f 2)                          # input image height
  mcd=$(bc <<< "scale=4; $iw / $aw")                                                    # calculo de height por width (maximo comun divisor)
  h=$(bc <<< "scale=4; $ah * $mcd")                                                     # image cropped height
  henteroround=$(cut -d "." -f1 <<< $h)
  hdecimalround=$(cut -d "." -f2 <<< $h)
  if [ $hdecimalround -gt 5000 ]; then
    hnew=$(($henteroround+1))
  else
    hnew=$henteroround
  fi
  if [ $hnew -eq $ih ]; then
    cp "$1" $tmp/crop.jpg
  else
    if [ $hnew -gt $ih ]; then
      mcd=$(bc <<< "scale=4; $ih / $ah")                                                # calculo de width por height (maximo comun divisor)
      w=$(bc <<< "scale=4; $aw * $mcd")                                                 # image cropped width
      wenteroround=$(cut -d "." -f1 <<< $w)
      wdecimalround=$(cut -d "." -f2 <<< $w)
      if [ $wdecimalround -gt 5000 ]; then
        wnew=$(($wenteroround+1))
      else
        wnew=$wenteroround
      fi
      if [ $wnew -eq $iw ]; then
        cp "$1" $tmp/crop.jpg
      else
        ic=$(bc <<< "$(($iw - $wnew)) / 2")                                                    # original image center
        convert "$1" -crop $wnew'x'$ih+$ic+0 $tmp/crop.jpg
      fi
    else
      ic=$(bc <<< "$(($ih - $hnew)) / 2")                                                    # original image center
      convert "$1" -crop $iw'x'$hnew+0+$ic $tmp/crop.jpg
    fi
  fi
}

function media_center_logo() {
  [ ! -z "$1" ] && png=$(ls $PRODIR/logos | grep -i "$1.png") ; [ $? != 0 ] && echo "The input logo don't exists" 1>&2 && return 1   # input logo
  [ ! -f "$tmp/crop.jpg" ] && echo "The input file don't exists" 1>&2 && return 1       # input file
  cw=$(identify $tmp/crop.jpg | cut -d " " -f 3 | cut -d "x" -f 1)                      # image crop width
  ch=$(identify $tmp/crop.jpg | cut -d " " -f 3 | cut -d "x" -f 2)                      # image crop height
  lp=$(bc <<< "$cw / $proportion1")                                                     # logo proportion (1/4)
  lmp=$(bc <<< "$lp / 20")
  xlmp=$(bc <<< "$lmp / $proportion2")
  convert "$PRODIR/logos/$png" -resize $(($lp - $(($lmp * 2)) - $(($xlmp *2))))'x' $tmp/logo.png
  [[ "$2" != 1 ]] && convert $tmp/logo.png -alpha on -channel a -evaluate multiply $2 +channel $tmp/logo.png
  media_center_rectangle $3 $4
}

function media_center_rectangle() {
  [ ! -f "$tmp/logo.png" ] && echo "The logo file don't exists" 1>&2 && return 1        # logo file
  lw=$(identify $tmp/logo.png | cut -d " " -f 3 | cut -d "x" -f 1)                      # logo width
  lh=$(identify $tmp/logo.png | cut -d " " -f 3 | cut -d "x" -f 2)                      # logo height
  convert -size $(($lw + $xlmp * 2))'x'$(($lh + $xlmp * 2)) xc:$1 $tmp/rectangle.png
  [[ "$2" != 1 ]] && convert $tmp/rectangle.png -alpha on -channel a -evaluate multiply $2 +channel $tmp/rectangle.png
}

function generate_media_center() {
  [ -f "$1" ] && while true; do                                                         # output file
    read -p "The file \"$1\" already exists, Do you want to overwrite it? [Y/N] " answer
    case $answer in
      [Yy]*) get_media_center "$1" ; break ;;
      [Nn]*) media_center_out ; exit ;;
      *) echo "Please answer yes or no." ;;
    esac
  done || get_media_center "$1"
}

function get_media_center() {
  [[ -f "$tmp/crop.jpg" && -f "$tmp/logo.png" && -f "$tmp/rectangle.png" ]] && media_center_compose "$1" && return 0
  [ -f "$tmp/crop.jpg" ] && cp $tmp/crop.jpg "$1" && return 0
}

function media_center_compose() {
  rh=$(identify $tmp/rectangle.png | cut -d " " -f 3 | cut -d "x" -f 2)
  composite -geometry +$(($(($lp * $(($proportion1-1)))) + $lmp))+$(($ch - $rh - $lmp)) $tmp/rectangle.png $tmp/crop.jpg $tmp/compose.jpg
  composite -geometry +$(($(($lp * $(($proportion1-1)))) + $lmp + $xlmp))+$(($ch + $xlmp - $rh - $lmp)) $tmp/logo.png $tmp/compose.jpg "$1"
}

function media_center_out() {
  rm -rf $tmp && return 0
}
