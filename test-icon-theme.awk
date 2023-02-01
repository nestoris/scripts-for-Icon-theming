#!/usr/bin/gawk -f
@load "gd"
@load "readdir"
@load "filefuncs"
#@include "arraytree"

BEGIN{
 dark="\033[2m"
 bold="\033[1m"
 normal="\033[0m"
 red="\033[31;1m"
 green="\033[32m"
 themedir="/home/joker/Документы/GitHub/Win98SE/SE98"
 chk_dir="actions/22"
 dir_size=22
 main2(themedir,chk_dir,dir_size,dir_chk_siz_a)
}

function checksizes(themedir,chk_dir,dir_size,dir_chk_siz_a,	i,j,img,imgW,imgH,data,flags){ # проверка размеров на несоответствие. аргументы: путь к теме, относительный путь папки, размер папки, желаемый массив с ошибочными файлами
	pathlist["1"]=themedir "/" chk_dir
	gsub(/\/+/,"/",pathlist["1"])
	flags = or(FTS_LOGICAL, FTS_COMFOLLOW)
	fts(pathlist, flags, data)
	for(i in data){
		for(j in data[i]){
			if(j~/\.png$/){
			 img=gdImageCreateFromFile(data[i][j]["path"],"GDFILE_PNG")
			 err=ERRNO
			 ERRNO=""
			 imgW=gdImageSX(img)
			 imgH=gdImageSY(img)
			 if(imgW!=dir_size||imgH!=dir_size){dir_chk_siz_a[j]=imgW"x"imgH}
			 ERRNO=""
			 gdImageDestroy(img)
			}
		}
	}
}

function main1(){
 for(thf=1;thf<=ARGC;thf++){
  chkszsthm(ARGV[thf])
 }
 exit;
}

function getres(fil	,ret){ # отправить разрешение значка в формате "X Y" в вывод функции
 img=gdImageCreateFromFile(fil,"GDFILE_PNG")
 err=ERRNO
 ERRNO=""
 ret=gdImageSX(img) " " gdImageSY(img)
 ERRNO=""
 gdImageDestroy(img)
 return ret
}

function _getres(	fil){ # отправить разрешение значка в формате "X Y" в стандартный вывод
 cmd="identify -format '%w' " fil
 while((cmd|getline)>0){return $0}
}

function readsizes1(rdir	,fs){
 fs=FS
 FS="/"
 while((getline < rdir)>0){ # читаем папку с помощью readdir
  szs=getres(rdir $2) ": "($3=="l"?"\033[2m":"\033[1m") $2 "\033[0m"
  if(szs!~/^-/){
   print szs
  }
 }
 FS=fs
}

function checksizes(root,fldr	,size,sza){
 fstmp=FS
 FS="/"
 rdir=root fldr "/"
 while((getline < rdir)>0){
  ext=$2;gsub(/(.*)\./,"",ext)
  if(ext=="png"){
   szs=getres(rdir $2)
   split(szs,sza," ")
   if(sza[2]!=size || sza[1]!=size){
    print bold root green fldr normal bold "/" ($2?$2:"") normal " : " (sza[1]<0?"- "red"Unreadable!"normal: (sza[1]!=size?red:"")sza[1] normal "x" (sza[2]!=size?red:"")sza[2]) normal
   }
  }
 }
 FS=fstmp
}

function getdirs(	theme){
 fstmp=FS
 rstmp=RS
 ofstmp=OFS
 FS="\n|\r"; RS="[\n.*][[]"; OFS=":"
 if(theme){
  while((getline < theme)>0){
   sub(/.$/,"",$1)
   #printf "%s ", $1
   for(i=2;i<=NF;i++){
    if(tolower($i)~/^size/){sub(/.*=/,"",$i);esize=$i}
    if(tolower($i)~/type=/){sub(/.*=/,"",$i);etype=$i}
   }
   if(tolower(etype)!~"scalable"){sizes[$1]=esize}
  }
 }
 FS=fstmp
 RS=rstmp
 OFS=ofstmp
}

function chkszsthm(thm	,i,thmpath){
 stat(thm,statdata)
 thmpath=statdata["name"]
 getdirs(thmpath)
 gsub(/[^\/\/]*$/,"",thmpath)
 for(i in sizes){
  checksizes(thmpath, i, sizes[i])
 }
}

