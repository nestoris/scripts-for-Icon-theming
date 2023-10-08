#!/usr/bin/gawk -f

## Requirements:
## gawk <= 5.2.1 (5.2.2 has an error with reading files while the "readdir" module is loaded)
## gawk-gd

## Arch/Manjaro:
# pacman -S gawk
# yay -S gawk-gd

## Other dists:
# https://sourceforge.net/projects/gawkextlib/files/

@load "filefuncs"
@load "gd"
@load "readfile"
@load "readdir"
#@include "arraytree"

function find(	path,	names, names_ar,
				IMG_X,	IMG_Y,	statdata,	fullpath){
	split(names,names_ar)
	for(n in names_ar){
		names_n[names_ar[n]]=names_ar[n]
	}

	fs=FS
	FS="/"
	
	while((getline < path)>0){

		#print path " " $2 " " $3

		fname=gensub(/\.[^.]*$/,"",1,$2)
		fullpath=path"/"$2
		if($3=="d" && $2!~/^\.+$/){
			printf "\r" count_n " " path"/"$2  "                                                                   "
			find(path"/"$2,names)

		}else{
	count_n++
		if($3~/(f|l)/ && fname in names_n){

			if($3~/l/){
			#stat(fullpath,statdata);fullpath=path"/"statdata["linkval"]
			cmdfp="realpath --relative-to=\""pwd"\" \""fullpath"\""
			cmdfp|getline fullpath
			close(cmdfp)
			}

			IMG_DST=gdImageCreateFromFile(path"/"$2)
			IMG_X=gdImageSX(IMG_DST)
			IMG_Y=gdImageSY(IMG_DST)
			if(IMG_DST && IMG_X==IMG_Y){
			#print fullpath "	" length(fullpath)

				#
				#print icons[fname][IMG_X]=gensub(/^\//,"",1,gensub(pwd,"",1,path))"/"$2
				icons[fname][IMG_X]=gensub(/^\.\//,"",1,fullpath)
				#print ""
				#if(gensub(/^\.\//,"",1,fullpath) != gensub(/^\//,"",1,gensub(pwd,"",1,path))"/"$2){print gensub(/^\.\//,"",1,fullpath "\n"  gensub(/^\//,"",1,gensub(pwd,"",1,path))"/"$2 "\n")}
				#print "icons["fname"]["IMG_X"]="icons[fname][IMG_X]
				#print "icons["name"]["IMG_X"]=" gensub(/^\//,"",1,gensub(pwd,"",1,path))"/"$2
				#print gensub(/^\//,"",1,gensub(pwd,"",1,path))"/"$2,IMG_X " x " IMG_Y,rel
				gdImageDestroy(IMG_DST)
			}
		}
		}

	}
	FS=fs
}


function tbl(	names,	sizes,	names_a,sizes_a){

split(names,names_a)
split(sizes,sizes_a)

for(n in names_a){
#print names_a[n]
if(names_a[n]){names_n[names_a[n]]=names_a[n]}

find(pwd,names)

#find(pwd,names_n[names_a[n]])
for(s in sizes_a){
sizes_n[sizes_a[s]]=sizes_a[s]
#print "icons["n"]["sizes_a[s]"]"
#printf names_a[n] " " sizes_a[s] " "
}
#print ""
}

if(length(names_n)>1 && names in names_n){delete names_n[names]}

print "*Built by [MDTable.awk](https://github.com/nestoris/scripts-for-Icon-theming/blob/main/mdtable.awk)*\n" > outfile
if(!ARGV[5]){printf "| " > outfile}
for(s in sizes_a){
printf "|**"sizes_a[s]"x"sizes_a[s]"**" > outfile
}
print "|" > outfile
if(!ARGV[5]){printf "|-" > outfile}
for(s in sizes_a){
printf "|-" > outfile
}
print "|" > outfile

##печатаем строки
for(n in names_a){
if(names_a[n]~/^$/){delete names_a[n]}
#printf "|**"toupper(substr(names_a[n],1,1)) substr(names_a[n],2)"**"
if(!ARGV[5]){printf "|**"names_a[n]"**" > outfile}
for(s in sizes_a){
#print "<<<"n">>>"
#print sizes_a[s]
#print icons[names_a[n]][sizes_a[s]]
printf "|%s", "![]("icons[names_a[n]][sizes_a[s]]")" > outfile

}
print "|" > outfile

}

fs=FS
FS="/"


FS=fs

}

function r_descript(file,	out){ # read names and descriptions of icons

fs=FS
FS=" "
while((getline<file)>0){
#print $1
#arr[$1]=$2
out=out (out?" ":"") $1
}
FS=fs
return out
}

function checkargs(arg1,arg2,arg3	,status,	statdata){
status=stat(arg1,statdata)
if(statdata["type"]!="directory"){hq_a[1]=1}

status=stat(arg2,statdata)
if(statdata["type"]=="directory"){hq_a[2]=2}

status=stat(arg3,statdata)
if(statdata["type"]=="directory"){hq_a[3]=3}

helpquit(hq_a)
}

function helpquit(hq_a,	m,	msg){

for(m in hq_a){
if(m==1){print "First argument must be a directory"}
if(m==2){print "Second argument cannot be a directory"}
if(m==3){print "Second argument cannot be a directory"}

#msg=msg msg?"\n":"" (m==1?"First argument must be a directory":m==2?"Second argument cannot be a folder":m==3?"Second argument cannot be a folder":"")

}

if(length(hq_a)>0){
("ps -p " PROCINFO["pid"] " -o comm=") | getline CMDNAME
print "Syntax:\n\t" CMDNAME " <PATH> <NAME_LIST_FILE> <SIZE_LIST_FILE> [OUTPUT_FILE]"
exit -1
}
}

BEGIN{
checkargs(ARGV[1],ARGV[2],ARGV[3])
print ARGV[1]
#if(isarray(hq_a)){print "aaa"}else{print "ddd"}
if(!ARGV[1]){
#delete ARGV
helpquit()
}
pwd=ARGV[1]?ARGV[1]:ENVIRON["PWD"]
#pwd="/home/joker/Документы/GitHub/Win98SE/SE98"
#pwd="/home/joker/Документы/GitHub/Win98SE"
names_f=ARGV[2]?ARGV[2]:"names"
sizes_f=ARGV[3]?ARGV[3]:"sizes"
outfile=ARGV[4]?ARGV[4]:"/dev/stdout"

#nmz=readfile(names_f)
nmz=r_descript(names_f)

gsub("\n"," ",nmz)
gsub(/[ ]+/," ",nmz)
szz=readfile(sizes_f)
gsub("\n"," ",szz)

#print nmz
tbl(nmz,szz)
print ""

#tbl("computer folder catfish","48 32")
#arraytree(icons,"icons")

#find(".","computer.png",pwd)
#find(pwd,"computer")
}
