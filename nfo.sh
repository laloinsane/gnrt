#!/bin/bash

FILE=$0
PRODIR=`dirname $FILE`
source "$PRODIR/utils/usage.sh"
source "$PRODIR/files/movie.sh"
source "$PRODIR/images/poster.sh"
source "$PRODIR/images/fanart.sh"

[ -z "$1" ] && usage 1>&2 && exit 1

while [ -n "$1" ]; do
  case "$1" in
    -m|--movie-file)
      case "$2" in
        -o|--output) [ -z "$3" ] && echo "Missing destination file name" 1>&2 && exit 1 || main_movie_file "$3" ; break ;;
        -*|*) [ -z "$2" ] && echo "Missing arguments" 1>&2 && exit 1 || echo "Option \"$2\" not recognized" 1>&2 && exit 1 ;;
      esac ; shift
    ;;
    -p|--poster)
      case "$2" in
        -i|--input)
          case "$4" in
            -o|--output) [ -z "$5" ] && echo "Missing destination file name" 1>&2 && exit 1 || main_poster $3 $5 ; break ;;
            -l|--logo)
              case "$6" in
                -o|--output) [ -z "$7" ] && echo "Missing destination file name" 1>&2 && exit 1 || main_poster $3 $7 $5 ; break ;;
                -c|--color)
                  case "$8" in
                    -o|--output) [ -z "$9" ] && echo "Missing destination file name" 1>&2 && exit 1 || main_poster $3 $9 $5 $7 ; break ;;
                    -*|*) [ -z "$8" ] && echo "Missing arguments" 1>&2 && exit 1 || echo "Option $8 not recognized" 1>&2 && exit 1 ;;
                  esac ; shift
                ;;
                -*|*) [ -z "$6" ] && echo "Missing arguments" 1>&2 && exit 1 || echo "Option $6 not recognized" 1>&2 && exit 1 ;;
              esac ; shift
            ;;
            -*|*) [ -z "$4" ] && echo "Missing arguments" 1>&2 && exit 1 || echo "Option $4 not recognized" 1>&2 && exit 1 ;;
          esac ; shift
        ;;
        -*|*) [ -z "$2" ] && echo "Missing arguments" 1>&2 && exit 1 || echo "Option $2 not recognized" 1>&2 && exit 1 ;;
      esac ; shift
    ;;
    -f|--fanart)
      case "$2" in
        -i|--input)
          case "$4" in
            -o|--output) [ -z "$5" ] && echo "Missing destination file name" 1>&2 && exit 1 || main_fanart $3 $5 ; break ;;
            -l|--logo)
              case "$6" in
                -o|--output) [ -z "$7" ] && echo "Missing destination file name" 1>&2 && exit 1 || main_fanart $3 $7 $5 ; break ;;
                -c|--color)
                  case "$8" in
                    -o|--output) [ -z "$9" ] && echo "Missing destination file name" 1>&2 && exit 1 || main_fanart $3 $9 $5 $7 ; break ;;
                    -*|*) [ -z "$8" ] && echo "Missing arguments" 1>&2 && exit 1 || echo "Option $8 not recognized" 1>&2 && exit 1 ;;
                  esac ; shift
                ;;
                -*|*) [ -z "$6" ] && echo "Missing arguments" 1>&2 && exit 1 || echo "Option $6 not recognized" 1>&2 && exit 1 ;;
              esac ; shift
            ;;
            -*|*) [ -z "$4" ] && echo "Missing arguments" 1>&2 && exit 1 || echo "Option $4 not recognized" 1>&2 && exit 1 ;;
          esac ; shift
        ;;
        -*|*) [ -z "$2" ] && echo "Missing arguments" 1>&2 && exit 1 || echo "Option $2 not recognized" 1>&2 && exit 1 ;;
      esac ; shift
    ;;
    -h|--help) usage ; exit 0 ;;
    -*|*) [ -z "$1" ] && echo "Missing arguments" 1>&2 && exit 1 || echo "Option $1 not recognized" 1>&2 ; exit 1 ;;
  esac ; shift
done
