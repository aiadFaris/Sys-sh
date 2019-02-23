#!/bin/bash
#!$(which bash)
# for github # my is myaio.sh
# call ./aio.sh [OPTION] [ARG1] [ARG2] [ARG3] 
# tested with cygwin Termux 
case "$1" in
  rma)
    # remove all hidden files those name to be specified e.g ".git"
    if [ $# -ne 3 ]
      then
		    echo "remove all hidden files whose name to be specified e.g '.git'"
		    echo "Usage: aio.sh rma [path] [file's name]"
		    echo "Example: ./aio.sh rma . git"
	  		exit 1
    else
      find "$2" -type f | grep -i "\.$3" | xargs rm # you may replace rm with ls 
    fi
  ;;
   rm0)
    if [ $# -ne 2 ]
      then
		    echo "remove all files remove all files whose size is zero"
		    echo "Usage: aio.sh rm0 [path] "
		    echo "Example: ./aio.sh rm0 ."
	  		exit 1
    else
			# create file size 0 to test it with: truncate -s 0m test2/empty1.txt # 
      find "$2" -size 0 -print0 | xargs -0 rm -- # todo
    fi
  ;;
  cp)
    # OK Aufruf: $ ./aio.sh cp . daily/
		# Aber cp: -r wurde nicht angegeben, daher wird das Verzeichnis '.' ausgelassen
    if [ $# -ne 3 ]
      then
		    echo "copy files created within last 24 hour"
		    echo "Usage: aio.sh cp [path to source][path to DestDir] "
		    echo "Example: ./aio.sh cp . daily/"
		  	exit 1
    else
      # You may adjust it to match the Dirs too
      find $2 -mtime 0 -exec cp {} $3 \;
    fi
  ;;

  ren)
    if [ $# -ne 3 ]
      then
		    echo "add extension to all files in given Directory"
		    echo "Usage: aio.sh ren [path to source][path to extension] "
		    echo "Example: ./aio.sh ren ~txt"
		  	exit 1
    else
	    find "$2" -type f -print0 | xargs -0 -I {} mv {} {}.$3
    fi
	;;
	mv)
	  if [ $# -lt 3 ]
      then
		    echo "add extension to all files in given Directory"
		    echo "Usage: aio.sh ren [path to source][path to extension] "
		    echo "Example: ./aio.sh mv hello daily/"
		    echo "No expansion in Name such foo*"		    
		  	exit 1
    else
      find "$(pwd)" -name "$2" -type d -print0 | xargs -0 -I {} mv {} "$3"/
    fi
	;;

  findall)
	  if [ $# -lt 3 ]
      then
		    echo "find files/Dirs name .* or *.gpg or *.gpgd"
		    echo "Usage: aio.sh findall [path] [first letters][last letters] "
		    echo "Example: ./aio.sh .* *.gpg "
		  	exit 1
    else  
		  # find files/Dirs name .* or *.gpg or *.gpgd
		  find "$(pwd)" -regex "[\$2]?.*[\.$3]?" | sed 's/.\///g'
		fi  
  ;;
  tar)
 	  if [ $# -lt 3 ]
      then
		    echo "taring files with specified extens"
		    echo "Usage: ./aio.sh tar [extension 1][extension 2] "
		    echo "Example: aio.sh tar txt sh "
		  	exit 1
    else   
	    i=1
			for arg in $*
			do
		      find . -name "*.$2" -o -name "*.$3" | tar -cvf "$2-$3-$(date +%d.%b.%Y_%H).tar" -T -
		      i=`expr $i + 1`
			done
		fi
	;;
	untar)
 	  if [ $# -lt 3 ]
      then
		    echo "untar an archiv of given name"
		    echo "Usage: ./aio.sh untar [archive's name] "
		    echo "Example: aio.sh untar foo.tar "
		  	exit 1
    else 
     	
			tar -xvf $1.tar
	fi
			#specify a different directory to extract to using -C parameter
			# tar -C /$1 -xvf $2.tar
		;;
	untargz)
	  tar -zxvf yourfile.tar.gz
	;;
	untarbz2)
	   tar xvjf file.tar.tbz
  ;;
  
  tarall)
    # it just show the result. If it's okay just delete echo. find besser
	  #find . -type d -maxdepth 1 -mindepth 1 -exec tar cvf {}.tar {}  \;
	  find /cygdrive/e/ -type d -maxdepth 1 -mindepth 1 -exec tar czvf /cygdrive/n/{}.tar.gz {}  \;
  ;;

  tar7z)
		# tested on POSIX compliant shell OK termux
        # Aufruf:
        # sh aio.sh tar7z test2 bkb-test2
        # sh aio.sh tar7z delme bkpdelme
        #
		# $ tar cf - daily/ | 7za a -si _VID2/daily.tar.7z
    # check /usr/bin/7z or /usr/bin/p7zip
    if [ $# -ne 3 ]
      then
	    usage
    else
      # echo fuer packen mit Pfad ab $PWD mit demselben Quellname
  		# usage $0 tar7z S2= <path to source> $3=<$3.tar.7z>
  		# Bsp.:  tar cf - ~/test2 | 7za a -si ~/test3/bkp.tar.7z
			tar cf - "$2" | 7za a -si "$3".tar.7z
    fi
	;;

  untar7z)
	# OK Cygwin, Aufruf
	# $ sh aio.sh tar7z bkpdelme.tar.7z delme
    # termux tar: can't change directory to 'bkb-test2': No such file or directory
    if [ $# -ne 3 ]
      then
	    usage
    else
  		# usage $0 untar7z yourfile.tar.7z target_dir
  		# echo "Bsp: 7z x -so test3/bkp.tar.7z | tar xf - -C test2/
        # 7z oder tar versteht "$2".tar.7z  nicht
			7z x -so "$2" | tar xf - -C "$3"
    fi
	;;
  #
	7zarm)
		# more explain does it delete the files after archibving them!
		# Ok sofar * stand untouched. if *\$3.txt nothing will be deleted
		# usage $0 7zarm archive's name
		7z a $2.7z * -sdel
	;;

	un7z)
		# uncompress 7z's achives
	  7za e $2.7z
	;;
	7zrpw)
	# comress each dir from . down separately with given Password.
	# if files in . will be 7z too
	# Usage: sh aio.sh 7zrpw
	# Password will be asked but not prompt
	for i in *
		do 7z a -mhe -pPassword $i.7z $i
	  done
	;;

	7zl)
	  #list found file in archiv
	  # e.g. 7z l f.txt.7z f1.txt -r
	  7z l $2.7z $3 -r
	;;
  encr)
    #  OK termux OK
  	# TESTEN UNTER CYGWIN NICHT MOGLICH
    # echo gpg must be installed && passphrase-file pwpharse4gpg needed
    # script must be called within Dir, whose data 'll be entcrypted
	    for i in test2/*;
			do
				# OK termux OK
        # sh aio.sh encr * 2>/dev/null
        gpg -c --batch --cipher-algo AES256 --compress-algo none \
        --passphrase-file pwpharse4gpg --passphrase-repeat 0 < "$i" > "$i".gpg
				i=`expr $i + 1`
			done
  ;;
  decr)
    # OK termux, aber nur wenn er nach dem passwort fragt. ja fragt.
    # beachte originaldateien werden overwritten
    gpg --passphrase-file pwpharse4gpg --decrypt-files *.gpg
   ;;
	# TODO
  grepinall)
	  # OK termux OK. Aufruf:
      # sh aio.sh grepinall . board
      # ./b.txt
      #./tmp/b.txt
	  # searchs pattern in all files in pwd/path & subdirs
	  find "$2" -type f -exec grep -q $3 {} \; -print
	;;
	
	grepall)
		# diplay all file with the name .foo, foo, _foo, foo.txt
		# ls -la | grep -E -i -w '\.?.*|.*'
		#OR
		find . | grep -E -i -w '\.?.*|.*'		
	;;

  cmpf)
    # OK termux OK. Aufruf:
    # sh aio.sh cmpf b.txt d.txt
    # Compare two files lines by line and display the differences
    diff -a --suppress-common-lines -y "$2" "$3"
    # comm -23 < (sort words.txt | uniq) < (sort countries.txt | uniq)
    # diff -a --suppress-common-lines -y a.txt b.txt > c.txt
    # diff urls.txt* | grep "<" | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
	;;

  rmdups)
    #OK termux OK. Call:
    # sh aio.sh rmdups d.txt
    # the script eliminate duplicate lines
    # regardless where they are in file
    sort  "$2" -u > "Purified-"$2
	;;

  mkmd5)
    i=1
    for arg in $*
    	do
    		# OK. Termux OK. call:
            # sh aio.sh mkmd5
            # zweck: erstellt md5-Liste zu allen files in PWD in md5checklists.chk
            # nur folgende zeile reicht vollig aus
    		find -type f -exec md5sum "{}" + > md5checklists.chk
     		i=`expr $i + 1`
    	done
	;;
  vrfymd5)
  	# OK. Aufruf
    # sh aio.sh vrfymd5 md5checklists.chk
    while read variable
    	do
    		md5sum -c $variable 2>&1 | grep OK
    	done < $2
	;;

	cmptar)
	  # OK Cygwin, Aufruf
	  # $  sh aio.sh cmptar delme delme
	  # NOT OK in termux with tar version 1.29. nothing wrong in Code.
      # tar don't recognized its own options --diff, --compare.
      # problem is well known
      # compare tar archive without specify the directory got tared.
	  # the 2nd part list the source files for tar
	  # tar --diff -vf tmp.tar  && ls -l tmp/* | awk '{print $9}'
	  tar --diff -vf $2.tar  && ls -l $3/*
	  ;;

	unix2dos)
	  # unix' file $1 will be converted in dos format
	  unix2dos $2
	  # check with
	  # od –bc $1
	  ;;

	dos2unix)
	  # dos' file $1 will be in unix format
	  dos2unix $2
	  # check with
	  # od –bc $1
	  ;;
	uuencode)
	  # Kommandos umwandelt Text- in Binärdateien um und wieder zurück umwandeln.
	  # Beim Datenaustausch via Internet behaelt Umlaute
	  # bzw. alle ASCII-Zeichen über 127) u. w. richtig dargestellt
	  uuencode archiv.tgz archiv.tgz
  ;;

	rnmext)
	  # in PWD: rename recuresivily file's extention just in .
	  # Usage: $0 rnmext [old Extention] [new Extention]
	  # e.g. $0 rnmext ext.txt txt
	  # e.g. :  $ sh aio.sh rnmext ext.tx txt
	  for f in *.$2
	  	do
	  		mv -- "$f" "${f%.$2}.$3"
	  	done

	;;
	  wmf)
      # OK. Call: sh aio.sh wmf
  	  # write into multiple Files- fit Pattern as needed
  	  for i in *.txt
  	    do
  	      echo "the quick brown fox spring over lazy dog" >> $i
  	    done
  	  ;;

	  diffDir)
	    # compare Dir1 Dir2
      # Usage: $0 diffDir dir1 dir2
			diff -r $2 $3
	 ;;
	  cmpf)
	    # compare the content of file1 file2 & display only differet lines
      # Usage: $0 cmpf file1 file2
			diff --changed-group-format='%<' --unchanged-group-format='' $2 $3
	 ;;
	 addln)
     # OK termux
	   #add given lines nummbered into multiple files
	   for i in test*.txt # kann *.ext
	     do
  	     if [ -s test$i.txt ]; # file don't exist or his seize is 0
           then
          	 echo "file donot exist or his seize is 0"
          	 exit 1
   	       else
       	    sed -i '1i#!/bin/bash' $i
       	    sed -i '2i# $0' $i
  	  	 fi
	     done
       ;;
	 mklns)
	   # script create symlinks for all files/dirs of sourceDir into DestDir
	   # echo "Usage: $0 sourceDir DestDir"
	   # with relative or absolut paths:
	   # sh $0 bsp/ bsp2/ OR
	   #/cygdrive/c/cygwin/home/Admin/data/bsp1/ [path]/data/bsp2/
	   ### by Cygwin necessarily to type in shell manually :
	   export CYGWIN="winsymlinks:native"
	   for file in $2/*;
	   	 do
         ln -s -v "$(basename "$file")" "$2/$(basename "$file")"
       done
	 ;;
	 mkcrc32)
     # unter Cygwin geht nur durch trick, in termux kann crc32 nicht installiert.
     # call :sh aio.sh mkcrc32
	 # mk.md5-crc32.sh
	 # erstellt md5sum und CRC32 in je separate List von allen Dateien im pwd
	 temp_file=$(mktemp)
	 # echo "$(date +%d.%m.%Y-%H-%M)" > hashlist.txt
	 find -type f -exec md5sum "{}" + | tee md5sumlist-$(date +%d.%m.%Y).txt # &&\
	 # find -type f -exec crc32 {} + | tee crc32list.txt
     # geht nicht da >>./<< vor den Namen stehen
	 cut -c37- < md5sumlist.txt > temp_file
	 while read variable
     do
       echo $variable >> crc32list.txt && crc32 $variable >> crc32list.txt
     done < temp_file
   ;;

   cmpfl7zp)
     # compare check of file already got 7zipped and its 7z
     # tested OK
     # $0 cmpfl7zp archiv.7z file
     fl=$(crc32.exe $2 | cut -b 3-11)
     zp=$(7z l -slt $2.7z | grep -E 'CRC|blahblah' | cut -b 7-14)
     if [ "$fl" = "$zp" ];
     	 then echo "equal"
     else
      echo "not equal"
     fi
   ;;
   zipgrep)
     # search "pattern" all files except file books
     zipgrep "$1" media.zip -x books
   ;;
   shredd)
	   #
	   dd if=/dev/urandom of=file.txt bs=1 \
	   > count=`wc -c file.txt | awk '{  print  $1  }'`; rm file.txt
   ;;
   mega)
		 # better options to call separate sh
		 # cygwin path
		 /bin/sh /cygdrive/d/IT/WrkSpacs/sh/blessed/mega.sh
		 # termux path
		 #
		 # linux path:
		 #
		 # 2 option to call separate sh with exec. may be not the best
		 # exec ~/myData/sh/working/called.sh Aiad
   ;;
   trmx)
	   apt update && apt upgrade &&\
	   termux-setup-storage &&  dpkg --get-selections | cut -f1 > trmx-instlld-pkgd-$(date +%d.%m.%Y).txt
	   # check | use:
	   #echo 'something' | termux-clipboard-set
	   #termux-clipboard-get
	   # exort installed Package
	   # generate installed package list
	   # $1 = trmx-instlld-pkgd-$(date +%d.%m.%Y).txt
	   dpkg --get-selections | cut -f1 > $1.txt
	   # install from file
	   $ xargs -0 apt install -y < <(tr \\n \\0 < $1.txt)
   ;;
   trmxssh)
	   # MobaXterm starten port 2222
	   cd ~/.ssh
	   sshpass -p 'Copper2' ssh Admin@192.168.1.2 -p 2222
   ;;
   # ###### rsync
   pc2trmx)
	   # aus PC zu termux senden. PC => Termux
	   # MobaXterm starten port 2222
	   # ~/ ist my HOME unter MobaXterm
	   rsync -av -e 'ssh -p 2222' Admin@192.168.1.2:~/synk/admn-pc.txt  rsynced/
	   #passphrase C.....2
	;;
   trmx2pc)
	   # aus termux zu PC senden. PC <= Termux
	   # MobaXterm starten port 2222
	   # ~/ ist my HOME unter MobaXterm
	   rsync -av -e 'ssh -p 2222' rsynced/ Admin@192.168.1.2:~/synk/
	   # passphrase C.....2
	;;
	rsyncssh)
		# successful tested with MobaXterm as ssh-server
	   rsync -aubPvlzr --exclude=excl*  --backup-dir=_bkp_ -e 'ssh -p 2222'\
	   --log-file="/drives/d/IT//log/rsync.log.$(date +%d.%m.%Y_%H-%m)"\
	    /drives/d/IT/rsynsrc/ /drives/d/IT/rsyndest/ --delete
  ;;
	rsynclcl)
		# successful tested with MobaXterm local without ssh-server 
		# n ((dry-run) must be removed to perform the action. be sure before you delete Data!
    rsync -aubPvlzrn --exclude=excl*  --backup-dir=_bkp_ --log-file="/drives/c/Users/Admin/Desktop/rsync/log/rsync.$(date +%d.%m).log" "/drives/c/Users/Admin/Desktop/rsync/rsyncsrc/" "/drives/c/Users/Admin/Desktop/rsync/rsyncdest/" --delete
	    
  ;;
	 gitssh)
	   # Don't bother with window, aint goging to develop sh underneath
	   # Actually you need a SSH-service and git would perfectly work over SSH.
	   # 
     #Host internal repositories like Gitlab or Stash. This will be similar to services like BitBucket or GitHub
     #If you want to have a simple service with SSH authentication:
     # Actually you need a SSH-service and git would perfectly work over SSH.
     #A very bare bones way is
     # server: Create a bare repo: 
			 mkdir -p RepoName && git init RepoName --bare
		 # server: Start the git daemon: 
			git daemon --base-path=$PWD/RepoName
		 # client:
        # Add your remote: git remote add origin git://server.url.or.ip/RepoName
        # or just clone it: git clone git://server.url.or.ip/RepoName
	 ;;
	 
   pdfgrep)
     # e.g:
     # find /cygdrive/d/IT/linux -type f  -iname "*.pdf" -print0 | xargs -0 pdfgrep -i "Inhaltsverzeichnis"
     # find /cygdrive/$1 -type f  -iname "*.pdf" -print0 | xargs -0 pdfgrep -i "$2"
   ;;
   bashrc)
   	 echo "alias gh="'history | grep' >> .bashrc
   	 source .bashrc
   	 # alias ls='$1/bin/ls -F --color=tty --show-control-chars'
   	 ;;
   	 
  ack-grep)
    # in cygwin
    curl https://beyondgrep.com/ack-2.24-single-file > /usr/bin/ack && chmod 0755 /usr/bin/ack
    ;;
	zgrep)
		# tested
		#find "$(pwd)" -name "scan.log.tar.gz" -exec zgrep -ai --color=always 'Failed' {} \; 
		find "$(pwd)" -name "$2".gz -exec zgrep -ai --color=always "$3" {} \; 
	;;
	zdiff)
		#zdiff -ai home.log.tar.gz scan.log
		zdiff -ai home.log.tar.gz scan.log
	;;
   # TODO
   # ssh-tar
   # rsync
   # git
   # termux: D:\IT\WrkSpacs\sh\blessed\termux.sh
	 # asciinema
	 # windows vbs
	 	# C:\Users\Admin\Desktop\rsync
	 	# How to schedule a Batch File to run automatically
	 	# one all in one batch
	#- add cmd excute on .bashrc to aio
	# - add cmd excute on source.lists to aio

   *) usage;;
esac