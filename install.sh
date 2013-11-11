#!/bin/bash
files=("AutoHotkey.ahk" "submodules/vim_ahk/vim.ahk")
instdirs=("/cygdrive/c/Users/$USER/Documents/" "/cygdrive/c/Users/$USER/Documents/")

backup="bak"
overwrite=1
dryrun=0
newlink=()
exist=()
curdir=`pwd -P`
# help
HELP="Usage: $0 [-nd] [-b <backup file postfix>] [-e <exclude file>]

Make links of windows related files/directories

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

echo "**********************************************"
echo "Update submodules"
echo "**********************************************"
echo
if which git >&/dev/null;then
  git submodule update --init
else
  echo "git is not installed, please install git or get following submodules directly:"
  grep url .gitmodules
fi
echo

if [ $dryrun -eq 1 ];then
  echo "*********************************************"
  echo "*** This is dry run, not install anything ***"
  echo "*********************************************"
  echo
fi
i=0
while [ $i -lt ${#files[@]} ];do
  f=${files[$i]}
  f_name=$(basename ${files[$i]})
  d=${instdirs[$i]}
  i=$((i+1))
  echo install $f to \"$d\"
  install=1
  if [ $dryrun -eq 1 ];then
    install=0
  fi
  if [ "`ls "$d/$f_name" 2>/dev/null`" != "" ];then
    exist=(${exist[@]} "$f_name")
    if [ $dryrun -eq 1 ];then
      echo -n ""
    elif [ $overwrite -eq 0 ];then
      install=0
    elif [ "$backup" != "" ];then
      mv "$d/$f_name" "$d/${f_name}.$backup"
    else
      rm "$d/$f_name"
    fi
  else
    newlink=(${newlink[@]} "$f_name")
  fi
  if [ $install -eq 1 ];then
    echo ln -s "$curdir/$f" "$d/$f_name"
    ln -s "$curdir/$f" "$d/$f_name"
  fi
done
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
if [ $dryrun -eq 1 ];then
  echo "*********************************************"
  echo "*** This is dry run, nothing was installed***"
  echo "*********************************************"
  echo
fi
