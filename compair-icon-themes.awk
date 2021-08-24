#!/usr/bin/gawk -f
@load "readdir"
@load "filefuncs"
@include "arraytree.awk"

#######################################################################################


function getfolderlist(	abs,	folder,	filearray,	filedata,	linkval){ # filearray[/path/to/theme/][context/48][icon]=/path/to/theme/|context/48|icon.ext|link-target.ext|l
 abs=(abs~/\/$/?abs:abs"/")
# gsub(/\/$/,"",folder)
 folder=(folder~/\/$/?folder:folder"/")
 #print abs folder;exit
 fstmp=FS
 FS="/"
 infil=abs folder
 while((getline < infil)>0){
#print $0
  if($2!~/^\.+$|^$/){
   noext=gensub(/.[^.]+$/,"",1,$2)
   print abs folder $2
   if($3~"l"){
    stat((abs folder $2),filedata)
    linkval=filedata["linkval"] "|l"
   }else{
    linkval=$2
   }
   filearray[abs][gensub(/\/$/,"",1,folder)][noext]=abs "|" folder "|" $2 "|" linkval
  }
 }
 FS=fstmp
}

function parsefast(	theme,	cmd){ # parse icon theme file !FIRST OF ALL with each theme!
 fstmp=FS
 rstmp=RS
 ofstmp=OFS
 orstmp=ORS
 FS="\n|\r"; RS="[\n.*][[]"; OFS=":"; ORS="\n"
 if(theme){cmd="realpath -qsz "theme
  ("realpath -qsz "theme|getline abs)
  close(cmd)
  gsub(/[^/]*$/,"",abs)
  fn=gensub(/^.*\//,"",1,theme)
  while((getline < theme)>0){
   sub("[[]","",$1)
   sub(/.$/,"",$1)
   if($0!~"^#"&&$0){
    for(i=2;i<=NF;i++){
     sub(/[ ]*#.*$/,"",$i) # removing comments
     split($i,varval,"=")
     if($i||!$i){
      if($1~"Icon Theme"){
       if(tolower(varval[1])~"name"){name=varval[2];name_a[name]=name;thname_a[abs]=name}
       if(tolower(varval[1])~"comment"){comment=varval[2];comment_a[comment]=comment}
       if(tolower(varval[1])~"example"){example=varval[2];example_a[example]=example}
       if(tolower(varval[1])~"directories"){directories=varval[2];directories_a[directories]=directories}
       if(tolower(varval[1])~"inherits"){inherits=varval[2];inherits_a[inherits]=inherits}
      }else{
       if(tolower(varval[1])~"threshold"){threshold=varval[2];threshold_a[threshold]=threshold}
       if(tolower(varval[1])~"context"){context=varval[2];context_a[context]=context;context_fld[abs][$1]=context}
       if(tolower(varval[1])~"size"){size=varval[2];size_a[size]=size;size_fld[abs][$1]=size}
       if(tolower(varval[1])~"type"){type=varval[2];type_a[type]=type;type_fld[abs][$1]=type}
       if(tolower(varval[1])~"scale"){scale=varval[2];scale_a[scale]=scale}
       folder_a[abs][$1]=type # array of theme folders for couting of icon names folder_a["/theme/path/"]["context/48"]="Fixed"
       scalablesize[context][size]=size
       #print "size_type_a["type"]["(tolower(type)~"fixed"?size:256)"]="(tolower(type)~"fixed"?size:256)
       size_type_a[type][(tolower(type)~"fixed"?size:256)]=(tolower(type)~"fixed"?size:256)
      }
     }
     iniparse[name][$1][tolower(varval[1])]=varval[2] # тема/папка/параметр=значение в сыром виде
    }
   }
  }
 }
 FS=fstmp
 RS=rstmp
 OFS=ofstmp
 ORS=orstmp
}

function allfolderslist(	th_arr,	cnt_arr,	i,	j,	k, abs,	filedata){ # th_arr[1]=/path/to/index.theme => icon_a["/path/to/"]["Context"]["Type"]["Size"]["icon.ext"]="/path/to/|directory|fl"
 for(k in cnt_arr){
  for(i in th_arr){
   abs=gensub(/index.theme$/,"",1,th_arr[i])
   parsefast(th_arr[i])
   for(j in folder_a[abs]){
    if(context_fld[abs][j]==cnt_arr[k]){
      # print abs j, folder_a[abs][j], context_fld[abs][j], type_fld[abs][j], size_fld[abs][j]
      fstmp=FS
      FS="/"
      while((getline < (abs j))>0){if($3!~"d"){
       if($3=="l"){
        stat((abs j "/" $2),filedata)
        linkval=filedata["linkval"]
       }else{
        linkval=$2
       }
       noext=gensub(/.[^.]+$/,"",1,$2)
       icon_a[abs][context_fld[abs][j]][type_fld[abs][j]][size_fld[abs][j]][noext]=abs"|"j"|"$2"|"linkval"|"$3"|"size_fld[abs][j]
       iname_a[noext]=noext
      }
     }
     FS=fstmp
    }
   }
  }
 }
}

function draw(	th_arr,	cnt_arr,	c,	j,	th,	ty,	s,	outline,	outa){
asort(iname_a)


for(c in cnt_arr){
print "<h1>"cnt_arr[c]"</h1>"
for(i in iname_a){
#for(i=1;i<5;i++){
print "<table border=2><tr><td colspan=25>"iname_a[i]"</td></tr>"

print "<tr><td>theme\\type</td>"
for(ty in type_a){print "<td colspan="length(size_type_a[ty])">"ty"</td>"}
print "</tr>"
for(th in th_arr){
gsub(/index\.theme$/,"",th_arr[th])
print "<tr><td>"thname_a[th_arr[th]]"</td>"
for(ty in type_a){
#print prev_size[th_arr[th]]

for(s in size_type_a[ty]){
if(icon_a[th_arr[th]][cnt_arr[c]][ty][s][iname_a[i]]){
outline=icon_a[th_arr[th]][cnt_arr[c]][ty][s][iname_a[i]]
split(outline,outa,"|")
prev_dir[th_arr[th]]=outa[2]
prev_size[th_arr[th]]=outa[6]
iconfile=outa[1] outa[2] "/" outa[3]
iconsize=outa[6]*1
filetype=outa[5]
}else{
outline=th_arr[th]"|"tolower(cnt_arr[c])"/"s"|"iname_a[i]"."(tolower(ty)=="scalable"?"svg":"png")"||n"
split(outline,outa,"|")
fls=prev_dir[outa[1]]
gsub(prev_size[th_arr[th]],(tolower(ty)=="scalable"?"scalable/"s:s),fls)
gsub("scalable",(tolower(ty)=="scalable"?"scalable/"s:s),fls)
iconfile=outa[1] (tolower(ty)=="scalable"?"scalable":fls) "/" outa[3]
iconsize=s*1
filetype=outa[5]

}

drawsize=iconsize<64?iconsize:64


print "<td style=\"background-color:"(outa[5]=="f"?"":(outa[5]=="l"?"#aaaaaa":"grey"))"\"><img src=\""iconfile"\" width=\""drawsize"\" height=\""drawsize"\" alt=\""(tolower(ty)=="scalable"?"scalable":iconsize)"\">""</td>"

#scaladrom=tolower(ty)=="scalable"?1:""

}
#scaladrom=""
}
}
}
print "</tr></table>"
}

}


#######################################################################################

BEGIN{

delete ARGV[0]
asort(ARGV,filearr)

# filearr[3]="/home/joker/Документы/GitHub/Win98SE/Icons/SE98/index.theme"
# filearr[2]="/home/joker/Документы/GitHub/Chicago95/Icons/Chicago95/index.theme"
# filearr[1]="/home/joker/Документы/icons/share-icons/mate/index.theme"
contarr[1]="Devices"

allfolderslist(ARGV,contarr)
draw(ARGV,contarr)

#arraytree(filearr,"filearr")
#draw(filearr,contarr)

#parsefast("/home/joker/Документы/GitHub/Win98SE/Icons/SE98/index.theme")
#icontree()
#while((getline < "/home/joker/Документы/GitHub/Win98SE/Icons/SE98/places/32")>0){print}
#getfolderlist("/home/joker/Документы/GitHub/Win98SE/Icons/SE98/","devices/22",data) # (basefolder, folder with iconfiles, output array)
#stat("/home/joker/Документы/GitHub/Win98SE/Icons/SE98/devices/22/scanner-symbolic.png",data)
#arraytree(data,"data")

# printContext(filearr,contarr)

# iconsincontext значки в контексте
# namesarray имена всех значков без расширений
# namesarraysorted то же, но сортированное и нумерованное
# cts_arr получение относительной папки по свойствам
# parsefast второй аргумент - дерево всей темы
# icon[context][sif_noext][FNUM][type][size]=icon_table[2];

#print readlink("/home/joker/Документы/GitHub/Win98SE/Icons/SE98/places/16/gnome-fs-blockdev.png")

#printcontext()
#arraytree(iconRealPathByParams,"irpbp")
#arraytree(arr,"arr")

#arraytree(iconRealPathByParams[export_context][i],"iconsincontext")
}
