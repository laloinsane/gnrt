#!/bin/bash

FILE=$0
PRODIR=`dirname $FILE`
# utils
source "$PRODIR/utils/usage.sh"
# text
source "$PRODIR/text/nfo/movie.sh"
# image
source "$PRODIR/image/media-center/poster.sh"
source "$PRODIR/image/media-center/fanart.sh"

[ -z "$1" ] && usage 1>&2 && exit 1

while [ -n "$1" ]; do case "$1" in
  --l|--list) echo "list " ;;
  # text
  --movie-nfo) [[ -z "$2" || $(echo -n "$2" | wc -c) != 2 || "$2" != -* ]] && echo "Missing arguments in \"--movie-nfo\"" 1>&2 && exit 1 || while [[ -n "$2" && $(echo -n "$2" | wc -c) == 2 ]]; do case "$2" in
     -o|--output) [[ -z "$3" || "$3" == -* ]] && echo "Missing arguments in \"$2\"" 1>&2 && exit 1 || generate_movie_nfo "$3" ; shift ;;
     -*|*) echo "Option \"$2\" not recognized in \"--movie-nfo\"" 1>&2 && exit 1 ;;
  esac ;  shift ; done ;;
  # image
  --poster) [[ -z "$2" || $(echo -n "$2" | wc -c) != 2 || "$2" != -* ]] && echo "Missing arguments in \"$1\"" 1>&2 && exit 1 || poster_init && while [[ -n "$2" && ($(echo -n "$2" | wc -c) == 2) && "$2" == -* ]]; do case "$2" in
     -i) [[ -z "$3" || "$3" == -* ]] && poster_out && echo "Missing arguments in \"$2\"" 1>&2 && exit 1 || poster_crop "$3" ; shift ;;
     -l) [[ -z "$3" || "$3" == -* ]] && poster_out && echo "Missing arguments in \"$2\"" 1>&2 && exit 1 || [[ ! -z "$4" && "$4" == "-c" && ! -z "$5" && "$5" != -* ]] && poster_logo "$3" "$5" && shift && shift || poster_logo "$3" "none" && shift ;;
     -o) [[ -z "$3" || "$3" == -* ]] && poster_out && echo "Missing arguments in \"$2\"" 1>&2 && exit 1 || generate_poster "$3" ; shift ;;
     -*|*) poster_out && echo "Option \"$2\" not recognized in \"--poster\"" 1>&2 && exit 1 ;;
  esac ;  shift ; done && poster_out ;;
  --fanart) [[ -z "$2" || $(echo -n "$2" | wc -c) != 2 || "$2" != -* ]] && echo "Missing arguments in \"$1\"" 1>&2 && exit 1 || fanart_init && while [[ -n "$2" && ($(echo -n "$2" | wc -c) == 2) && "$2" == -* ]]; do case "$2" in
     -i) [[ -z "$3" || "$3" == -* ]] && fanart_out && echo "Missing arguments in \"$2\"" 1>&2 && exit 1 || fanart_crop "$3" ; shift ;;
     -l) [[ -z "$3" || "$3" == -* ]] && fanart_out && echo "Missing arguments in \"$2\"" 1>&2 && exit 1 || [[ ! -z "$4" && "$4" == "-c" && ! -z "$5" && "$5" != -* ]] && fanart_logo "$3" "$5" && shift && shift || fanart_logo "$3" "none" && shift ;;
     -o) [[ -z "$3" || "$3" == -* ]] && fanart_out && echo "Missing arguments in \"$2\"" 1>&2 && exit 1 || generate_fanart "$3" ; shift ;;
     -*|*) fanart_out && echo "Option \"$2\" not recognized in \"--fanart\"" 1>&2 && exit 1 ;;
  esac ;  shift ; done && fanart_out ;;
  # utils
  --help) usage && exit 0 ;;
  -*|*) echo "Option \"$1\" not recognized" 1>&2 && exit 1 ;;
esac ; shift ; done
