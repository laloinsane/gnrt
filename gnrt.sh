#!/bin/bash

FILE=$0
PRODIR=`dirname $FILE`
# text
source "$PRODIR/text/nfo/movie.sh"
source "$PRODIR/text/desktop/desktop.sh"
source "$PRODIR/text/readme/readme.sh"
# image
source "$PRODIR/image/media-center/media_center.sh"

function usage() {
  echo "USAGE: gnrt --movie-nfo [-o \"outfile\"]
            --movie-nfo -h
            --desktop [-o \"outfile\"]
            --desktop -h
            --readme [-o \"outfile\"]
            --readme -h
            --poster [-i \"infile\"] [-l logoname <-t>] [-c color <-t>] [-o \"outfile\"]
            --poster -h
            --fanart [-i \"infile\"] [-l logoname <-t>] [-c color <-t>] [-o \"outfile\"]
            --fanart -h
            [-h | --help]"
}

[ -z "$1" ] && usage 1>&2 && exit 1

while [ -n "$1" ]; do case "$1" in
  # text - movie nfo
  --movie-nfo) [[ -z "$2" || $(echo -n "$2" | wc -c) != 2 || "$2" != -* ]] && echo "Missing arguments in \"--movie-nfo\"" 1>&2 && exit 1 || while [[ -n "$2" && $(echo -n "$2" | wc -c) == 2 ]]; do case "$2" in
     -h) cat "$PRODIR/text/nfo/help" ; exit 0 ;;
     -o) [[ -z "$3" || "$3" == -* ]] && echo "Missing arguments in \"$2\"" 1>&2 && exit 1 || generate_movie_nfo "$3" ; shift ;;
     -*|*) echo "Option \"$2\" not recognized in \"--movie-nfo\"" 1>&2 && exit 1 ;;
  esac ;  shift ; done ;;
  # text - desktop
  --desktop) [[ -z "$2" || $(echo -n "$2" | wc -c) != 2 || "$2" != -* ]] && echo "Missing arguments in \"--desktop\"" 1>&2 && exit 1 || while [[ -n "$2" && $(echo -n "$2" | wc -c) == 2 ]]; do case "$2" in
     -h) cat "$PRODIR/text/desktop/help" ; exit 0 ;;
     -o) [[ -z "$3" || "$3" == -* ]] && echo "Missing arguments in \"$2\"" 1>&2 && exit 1 || generate_desktop_file "$3" ; shift ;;
     -*|*) echo "Option \"$2\" not recognized in \"--desktop\"" 1>&2 && exit 1 ;;
  esac ;  shift ; done ;;
  # text - readme
  --readme) [[ -z "$2" || $(echo -n "$2" | wc -c) != 2 || "$2" != -* ]] && echo "Missing arguments in \"--readme\"" 1>&2 && exit 1 || while [[ -n "$2" && $(echo -n "$2" | wc -c) == 2 ]]; do case "$2" in
     -h) cat "$PRODIR/text/readme/help" ; exit 0 ;;
     -o) [[ -z "$3" || "$3" == -* ]] && echo "Missing arguments in \"$2\"" 1>&2 && exit 1 || generate_readme_file "$3" ; shift ;;
     -*|*) echo "Option \"$2\" not recognized in \"--readme\"" 1>&2 && exit 1 ;;
  esac ;  shift ; done ;;
  # image - media-center - poster
  --poster) [[ -z "$2" || $(echo -n "$2" | wc -c) != 2 || "$2" != -* ]] && echo "Missing arguments in \"$1\"" 1>&2 && exit 1 || media_center_poster_init && while [[ -n "$2" && ($(echo -n "$2" | wc -c) == 2) && "$2" == -* ]]; do case "$2" in
     -h) media_center_out && cat "$PRODIR/image/media-center/help-poster" ; exit 0 ;;
     -i) [[ -z "$3" || "$3" == -* ]] && media_center_out && echo "Missing arguments in \"$2\"" 1>&2 && exit 1 || media_center_crop "$3" ; shift ;;
     -l)
      if [[ -z "$3" || "$3" == -* ]]; then
        media_center_out && echo "Missing arguments in \"$2\"" 1>&2 && exit 1
      else
        l=$3
        lt=1
        ct=1
        if [[ ! -z "$4" && "$4" == "-t" ]]; then
          lt=0.65
          shift
        fi
        if [[ ! -z "$4" && "$4" == "-c" && ! -z "$5" && "$5" != -* && ! -z "$6" && "$6" == "-t" ]]; then
          ct=0.65
          media_center_logo "$l" "$lt" "$5" "$ct"
          shift ; shift ; shift ; shift
        elif [[ ! -z "$4" && "$4" == "-c" && ! -z "$5" && "$5" != -* && ! -z "$6" && "$6" != "-t" ]]; then
          media_center_logo "$l" "$lt" "$5" "$ct"
          shift ; shift ; shift
        else
          media_center_logo "$l" "$lt" "none" "$ct"
          shift
        fi
      fi ;;
     -o) [[ -z "$3" || "$3" == -* ]] && media_center_out && echo "Missing arguments in \"$2\"" 1>&2 && exit 1 || generate_media_center "$3" ; shift ;;
     -*|*) media_center_out && echo "Option \"$2\" not recognized in \"--poster\"" 1>&2 && exit 1 ;;
  esac ;  shift ; done && media_center_out ;;
  # image - media-center - fanart
  --fanart) [[ -z "$2" || $(echo -n "$2" | wc -c) != 2 || "$2" != -* ]] && echo "Missing arguments in \"$1\"" 1>&2 && exit 1 || media_center_fanart_init && while [[ -n "$2" && ($(echo -n "$2" | wc -c) == 2) && "$2" == -* ]]; do case "$2" in
     -h) media_center_out && cat "$PRODIR/image/media-center/help-fanart" ; exit 0 ;;
     -i) [[ -z "$3" || "$3" == -* ]] && media_center_out && echo "Missing arguments in \"$2\"" 1>&2 && exit 1 || media_center_crop "$3" ; shift ;;
     -l)
      if [[ -z "$3" || "$3" == -* ]]; then
        media_center_out && echo "Missing arguments in \"$2\"" 1>&2 && exit 1
      else
        l=$3
        lt=1
        ct=1
        if [[ ! -z "$4" && "$4" == "-t" ]]; then
          lt=0.65
          shift
        fi
        if [[ ! -z "$4" && "$4" == "-c" && ! -z "$5" && "$5" != -* && ! -z "$6" && "$6" == "-t" ]]; then
          ct=0.65
          media_center_logo "$l" "$lt" "$5" "$ct"
          shift ; shift ; shift ; shift
        elif [[ ! -z "$4" && "$4" == "-c" && ! -z "$5" && "$5" != -* && ! -z "$6" && "$6" != "-t" ]]; then
          media_center_logo "$l" "$lt" "$5" "$ct"
          shift ; shift ; shift
        else
          media_center_logo "$l" "$lt" "none" "$ct"
          shift
        fi
      fi ;;
     -o) [[ -z "$3" || "$3" == -* ]] && media_center_out && echo "Missing arguments in \"$2\"" 1>&2 && exit 1 || generate_media_center "$3" ; shift ;;
     -*|*) media_center_out && echo "Option \"$2\" not recognized in \"--fanart\"" 1>&2 && exit 1 ;;
  esac ;  shift ; done && media_center_out ;;
  -h|--help) usage && exit 0 ;;
  -*|*) echo "Option \"$1\" not recognized" 1>&2 && exit 1 ;;
esac ; shift ; done
