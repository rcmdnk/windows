#!/bin/bash
files=()
instdirs=()
exclude=('.' '..' 'README.md' 'install.sh')

backup="bak"
overwrite=1
dryrun=0
newlink=()
exist=()
curdir=`pwd -P`
# help
HELP="Usage: $0 [-nd] [-b <backup file postfix>] [-e <exclude file>]

Arguments:
      -b  Set backup postfix (default: make *.bak file)
          Set \"\" if backups are not necessary
      -e  Set additional exclude file (default: ${exclude[@]})
      -n  Don't overwrite if file is already exist
      -d  Dry run, don't install anything
      -h  Print Help (this message) and exit
"
while getopts b:e:ndh OPT;do
  case $OPT in
    "b" ) backup=$OPTARG ;;
    "e" ) exclude=(${exclude[@]} "$OPTARG") ;;
    "n" ) overwrite=0 ;;
    "d" ) dryrun=1 ;;
    "h" ) echo "$HELP" 1>&2; exit ;;
    * ) echo "$HELP" 1>&2; exit ;;
  esac
done

if [[ "$OSTYPE" =~ "cygwin" ]];then
  # ln wrapper{{{
  function ln {
    opt="/H"
    if [ "$1" = "-s" ];then
      opt=""
      shift
    fi
    target="$1"
    if [ -d "$target" ];then
      opt="/D $opt"
    fi
    if [ $# -eq 2 ];then
      link="$2"
    elif [ $# -eq 1 ];then
      link=`basename "$target"`
    else
      echo "usage: ln [-s] <target> [<link>]"
      echo "       -s for symbolic link, otherwise make hard link"
      return
    fi
    t_winpath=$(cygpath -w -a "$target")
    t_link=$(cygpath -w -a "$link")
    echo "cmd /c mklink $opt $t_link $t_winpath"
    cmd /c mklink $opt "$t_link" "$t_winpath"
  }
# }}}
fi

if [ $dryrun -ne 1 ];then
  mkdir -p $instdir
else
  echo "*** This is dry run, not install anything ***"
fi
i=0
while [ $i -lt ${#files[@]} ];do
  f=${files[$i]}
  d=${instdirs[$i]}
  i=$(($i+1))
  for e in ${exclude[@]};do
    flag=0
    if [ "$f" = "$e" ];then
      flag=1
      break
    fi
  done
  if [ $flag = 1 ];then
    continue
  fi
  echo install $f to \"$d\"
  install=1
  if [ $dryrun -eq 1 ];then
    install=0
  fi
  if [ "`ls "$d/$f" 2>/dev/null`" != "" ];then
    exist=(${exist[@]} "$f")
    if [ $dryrun -eq 1 ];then
      echo -n ""
    elif [ $overwrite -eq 0 ];then
      install=0
    elif [ "$backup" != "" ];then
      mv "$d/$f" "$d/${f}.$backup"
    else
      rm "$d/$f"
    fi
  else
    newlink=(${newlink[@]} "$f")
  fi
  if [ $install -eq 1 ];then
    ln -s "$curdir/$f" "$d/$f"
  fi
done
f=$(basename "`pwd`")                 
d="/cygdrive/c/Program Files/yamy"
echo install current directly $f to "$d"
install=1
if [ $dryrun -eq 1 ];then
  install=0
fi
if [ "`ls "$d/$f" 2>/dev/null`" != "" ];then
  exist=(${exist[@]} "$f")
  if [ $dryrun -eq 1 ];then
    echo -n ""
  elif [ $overwrite -eq 0 ];then
    install=0
  elif [ "$backup" != "" ];then
    mv "$d/$f" "$d/${f}.$backup"
  else
    rm "$d/$f"
  fi
else
  newlink=(${newlink[@]} "$f")
fi
if [ $install -eq 1 ];then
  ln -s "`pwd`" "$d/$f"
fi
echo ""
if [ $dryrun -eq 1 ];then
  echo "Following files don't exist:"
else
  echo "Following files were newly installed:"
fi
echo "  ${newlink[@]}"
echo
echo -n "Following files existed"
if [ $dryrun -eq 1 ];then
  echo "Following files exist:"
elif [ $overwrite -eq 0 ];then
  echo "Following files exist, remained as is:"
elif [ "$backup" != "" ];then
  echo "Following files existed, backups (*.$backup) were made:"
else
  echo "Following files existed, replaced old one:"
fi
echo "  ${exist[@]}"
echo
