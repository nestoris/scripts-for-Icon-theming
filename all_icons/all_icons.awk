#!/usr/bin/gawk -f
@load "readfile"
@load "readdir"
#@include "arraytree"
#@include "ini"

function readinif(file,iniarr,prefix,	rs){	#read ini file and convert it to a 2D gawk array.
	rs=RS
	RS="\n|\r"
	while((getline<file)>0){
		if($0!~"^#|^;|^$"){
			gsub(" *[;#].*$","")
			if($0~/^\[.*\]$/){sect=$0;gsub(/^\[|\].*$/,"",sect);sect=prefix "/" sect;iniarr[sect]["#"];delete iniarr[sect]["#"]}else{gsub(/ *= */,"=");split($0,va,"=");iniarr[sect][va[1]]=va[2]}
		}
	}
	RS=rs
}

function doini(arr,sys,	i,	j,	out,	rs){ # Create ini file: arr -- input array, sys -- newline symbol for system (w -- Windows, m -- Mac, any other -- Unix/Linux)
rs=(sys=="w"?"\r\n":sys=="m"?"\r":"\n")
	if(isarray(arr)){
		for(i in arr){
			if(isarray(arr[i])){
				out=out (out?"\n\n":"") "["i"]"
				for(j in arr[i]){
					out=out "\n"j"="arr[i][j]
				}
			}
		}
	}
return out
}

function abspath(filepath,relto,	out){ # filepath=relative path, relto=absolute path to file or folder (slash at the end of folder is nessusery!); abspath("../../relative/file.ext","/path/to/file.ext") OR abspath("../../relative/file.ext","/path/to/folder/")
	gsub(/[^/]*$/,"",relto)
	out=relto filepath
	gsub(/\/+/,"/",out)
	#print out
	while(out~/\/\.\//){gsub(/\/\.\//,"/",out)}
	#print out
	while(out~/\/\.\.\//&&out!~/^\/*\..\//){
		gsub(/\/[^/.]*\/\.\./,"",out)
		gsub(/^\/\.\.\//,"../",out)
	}
	return out
}


function getthemes(	paths,	arr,	pth,	cmd,	p,	n,	nmz,	fs){
fs=FS
FS="/"

split(paths,pth,"|") # multiple paths must be separated by "|" symbol
for(p in pth){
themeroot=""
while((getline<pth[p])>0){if($2!~/^\.+$/){
nmz[$2]=$3
if(tolower($2)=="index.theme"&&$3=="f"){themeroot=pth[p]}

#print $2,$3

}}
if(themeroot){thnum++;readinif(themeroot "/index.theme",arr,themeroot)}else{for(n in nmz){if(nmz[n]~"d"){getthemes(pth[p]"/"n,arr)}}}
}
#while((getline<path)>0){}

#cmd="find -H \""path"\" -type f,l -iname \"index.theme\" -printf \"%h|%f\\n\""
#while((cmd|getline)>0){print}
FS=fs
}

function writeIconArray(	iph,	ipath){
#cmd[1]="find \"/usr/share/icons/\" -type f -regextype awk -regex \".*\\.(svg|png|xpm)\" -printf \"%h|%f\\n\""
#cmd[2]="find \"/home/joker/.icons/\" -type f -regextype awk -regex \".*\\.(svg|png|xpm)\" -printf \"%h|%f\\n\""
#cmd[3]="find \"/home/joker/.local/share/icons/\" -type f -regextype awk -regex \".*\\.(svg|png|xpm)\" -printf \"%h|%f\\n\""
#cmd[4]="find \"/usr/share/pixmaps/\" -type f -regextype awk -regex \".*\\.(svg|png|xpm)\" -printf \"%h|%f\\n\""
#cmd[5]="find \"/home/joker/GitHub/Win98SE/Icons/SE98/\" -type f -regextype awk -regex \".*\\.(svg|png|xpm)\" -printf \"%h|%f\\n\""
#cmd[6]="find \"/home/joker/Downloads/icons/TEST_ICONS\" -type f -regextype awk -regex \".*\\.(svg|png|xpm)\" -printf \"%h|%f\\n\""


if(1==3){ # ignoring block
ipath[2]="/usr/share/icons"
ipath[5]="/home/joker/.icons"
ipath[4]="/home/joker/.local/share/icons"
ipath[3]="/usr/share/pixmaps"
ipath[1]="/home/joker/GitHub/Win98SE/SE98"
ipath[6]="/home/joker/Downloads/icons/TEST_ICONS"
}

while((getline<"iconpaths")>0){iph++;$0~"^#"?"":ipath[iph]=$0}

for(df in ipath){
print "Looking for icons in \""ipath[df]"\"...                          "
#while((cmd[df]|getline)>0){
cmd[df]="find -H \""ipath[df]"\" -type f,l -regextype awk -regex \".*\\.(png|xpm|svg|theme)\" -printf \"%h|%f|%l\\n\""
#nr=0
while((cmd[df]|getline)>0){
if($2!~/index\.theme$/){
#print gensub(/\.[^.]*$/,"",1,$2) "=" $1 "/" $2
 #nr++
 noext=gensub(/\.[^.]*$/,"",1,$2) #name of icon w/o extension
 isarray(themearray)&&themearray[$1]["Context"]?icon_contexts[noext][themearray[$1]["Context"]]++:""
 if(isarray(icons[noext])){
  printf "\r"length(icons) " total unique names found."
  isarray(themearray)&&themearray[$1]["Context"]?icons[noext]["#"][themearray[$1]["Context"]]++:""
  isarray(themearray)&&themearray[$1]["context"]?icons[noext]["#"][themearray[$1]["context"]]++:""
  icons[noext][length(icons[noext])+1]=$1 "/" $2
 }else{
  #if(noext=="stock_people"){print $1, $2}
  delete icons[noext]
  icons[noext]["1"]=$1 "/" $2
 }
 if($3){ #creating arrays for symlinked files. iconparents["symlink_name"]["original_target"]
#  linksa[$1 "/" $2]=abspath($3,$1 "/")
  linksa[$1 "/" $2]=$3
  gsub(/.*\/|\.[^.]*$/,"",$3)
  if(length($3)>4){iconparents[noext][$3]=$3}
  iconchildren[$3][noext]=noext
  symlinked_icons[ipath[df]][gensub(/\.[^.]*$/,"",1,$2)]
 }else{
  #originals_count[ipath[df]][gensub(/\.[^.]*$/,"",1,$2)]
  original_icons[curr_thm][noext]
  icons_neverlinked[noext]
 }
}else{
curr_thm=$1
}
}
#printf "\n"
printf "\r"
close(cmd[df])
for(tmp_i in symlinked_icons[ipath[df]]){
#for(curr_thm in original_icons){
#delete original_icons[curr_thm][tmp_i]
#}
delete icons_neverlinked[tmp_i]
}
}
}

function sortrating(iniin,rating){
readinif(iniin,arr)
for(i in arr["Count"]){
zeros=""
for(k=6;k>length(arr["Count"][i]);k--){
zeros=zeros "0"
}
j++;arr1[j]=zeros arr["Count"][i]"_"i
}
asort(arr1)
#arraytree(arr1,"arr1")
for(k=length(arr1);k>0;k--){
split(arr1[k],a,"_")
count=themepath=arr1[k]
gsub(/^[^_]*_/,"",themepath)
gsub(/_.*$/,"",count)
print themepath " ("count*1")" > rating
}
}

function papki(	array,	i,	j,	cntx){ #create folder with html-files and main index.html page with counts
 ## измеряем максимальое количество вариантов значка
 maxicvars=0
 for(i in array){
 maxicvars=length(array[i])>maxicvars?length(array[i]):maxicvars
 }

 ## создаём index.html
 print "<html>\n<body>\n<head>\n<style>\nspan {font-size:75%;color:black;}\nspan.ch {background-color:#00CCFF;}\nspan.pa {background-color:#FFCC00;}\n</style>\n</head>\n" > of
 asorti(array,array_s)
 for(i in array_s){

  ## Создаём отдельную табличку-файл
  icf=path "/icons/" array_s[i] ".html"

  if(imgsize*1>=16){
  css="\
.tooltip img {width:"imgsize"px; height:"imgsize"px;}\n\
.tooltip span {display:none;padding:10;}\n\
.tooltip span img {width:auto; height:auto;}\n\
.tooltip:hover span {position:absolute; left:"imgsize+48"px; display:block; --max-width:512px; --max-height:512px; border:1px solid #AA9966; z-index:1000;}"
  }

#  print "<html>\n<head>\n<title>"array_s[i]"</title>\n<style>\n"css"\n</style></head>\n<body>\n<table border=\"1\">" > icf
icf_data="<html>\n<head>\n<title>"array_s[i]"</title>\n<style>\n"css"\n</style></head>\n<body>\n<table border=\"1\">"
  zhar=int(length(array[array_s[i]])/maxicvars*256)-1
  print "Saving (" int(i/length(array_s)*100) "%) "array_s[i] ".html"
  for(a in array[array_s[i]]){
   if(a!~"#"){
#   print "<tr>\n\t<td><div class=\"tooltip\">\n\t\t<img src=\"" array[array_s[i]][a] "\">\n\t\t<span><img src=\"" array[array_s[i]][a] "\"></span></div>\n\t</td>\n\t<td>" gensub(/.*(Chicago95|SE98|Memphis98).*/,"<b>&</b>",1,array[array_s[i]][a]) "</td>" (linksa[array[array_s[i]][a]]?"\n<td> =&gt; </td>\n<td><a href=\""gensub(/.*\//,"",1,gensub(/\.[^.]*$/,"",1,linksa[array[array_s[i]][a]]))".html\">"linksa[array[array_s[i]][a]]"</a></td>\n<td><a href=\""abspath(linksa[array[array_s[i]][a]],array[array_s[i]][a])"\">"abspath(linksa[array[array_s[i]][a]],array[array_s[i]][a])"</a></td>":"\n<td>\n</td>\n<td>\n</td>\n<td>\n</td>") "\n</tr>" > icf
icf_data=icf_data "\n<tr>\n\t<td><div class=\"tooltip\">\n\t\t<img src=\"" array[array_s[i]][a] "\">\n\t\t<span><img src=\"" array[array_s[i]][a] "\"></span></div>\n\t</td>\n\t<td>" gensub(/.*(Chicago95|SE98|Memphis98).*/,"<b>&</b>",1,array[array_s[i]][a]) "</td>" (linksa[array[array_s[i]][a]]?"\n<td> =&gt; </td>\n<td><a href=\""gensub(/.*\//,"",1,gensub(/\.[^.]*$/,"",1,linksa[array[array_s[i]][a]]))".html\">"linksa[array[array_s[i]][a]]"</a></td>\n<td><a href=\""abspath(linksa[array[array_s[i]][a]],array[array_s[i]][a])"\">"abspath(linksa[array[array_s[i]][a]],array[array_s[i]][a])"</a></td>":"\n<td>\n</td>\n<td>\n</td>\n<td>\n</td>") "\n</tr>"
   }
   #if(!linksa[array[array_s[i]][a]]){delete linksa[array[array_s[i]][a]]}
  }
#  print "</table>\n</body>\n</html>" > icf
icf_data=icf_data "\n</table>\n</body>\n</html>"

print icf_data > icf

  if(isarray(iconparents[array_s[i]])){icopas=mdpas="";for(j in iconparents[array_s[i]]){mdpas=mdpas (mdpas?"` `":"") iconparents[array_s[i]][j];icopas=icopas (icopas?", ":"") "<a href=\"icons/"iconparents[array_s[i]][j]".html\">" iconparents[array_s[i]][j] "</a>"}}else{icopas=""} #если данное имя -- ссылка и имеет в качестве оригинала другие имена
  if(isarray(iconchildren[array_s[i]])){icochis=mdchis="";for(j in iconchildren[array_s[i]]){mdchis=mdchis (mdchis?"` `":"") iconchildren[array_s[i]][j];icochis=icochis (icochis?", ":"") "<a href=\"icons/"iconchildren[array_s[i]][j]".html\">" iconchildren[array_s[i]][j] "</a>"}}else{icochis=""} #если на данное имя ссылаются какие-то другие имена

  print "<a href=\"icons/" array_s[i] ".html\"><b>" array_s[i] "</b> (<font color=\"#"sprintf((zhar<16?"0":"")"%X", zhar)"0000\">" length(array[array_s[i]]) " variants</font>)</a>" (icopas?" [Parents: <span class=\"pa\">"icopas"</span>]":"") (icochis?" [Children: <span class=\"ch\">"icochis"</span>]":"")"<br>" > of

  if(isarray(array[array_s[i]]["#"])){print "* **" array_s[i] "**:" > markdown; for(cntx in array[array_s[i]]["#"]){printf " %s", "*"cntx "*(" array[array_s[i]]["#"][cntx] ")" > markdown}; print " **p**: `" mdpas "` **c**: `" mdchis "`\n" > markdown}

 }

 print "</body></html>" > of
 print "Created " length(array_s) " HTML files in a '"path"'."
}

function find_and_save(){
writeIconArray("/home/joker/Документы/scripts/GAWK/icons.bin")
}



BEGIN{
FS="|"
imgsize=48 #size of images in each html table
parents_out="parents.ini"
childen_out="children.ini"

#print abspath("../../mimetypes/64/message.png","/home/joker/GitHub/Win98SE/SE98/apps/64/")

## create and save icon array OR read it from bin file (Only ASCII paths! No Unicode!)


### For creating list of desired icon names to know about symlinking (many themes get much time)
themes_with_desired_icon_names="themes_with_desired_icon_names"
while((getline<themes_with_desired_icon_names)>0){$0~"^#"?"":desired_icon_names=(desired_icon_names?desired_icon_names"|":"") $0}

getthemes(desired_icon_names,themearray)

 #path=path?path:"/home/joker/Документы/scripts/GAWK/all_icons/all"
 path=path?path:"/tmp/all_icons"
 of=path "/index.html" ### OUTPUT FILE === вывод файла
 markdown=path "/index.md"
 statistic=path "/stat.ini"
 mkdirs="mkdir -p " path "/icons"
 system(mkdirs)
 close(mkdirs)
 rating=path "/orig_rating.txt"


writeIconArray()
#arraytree(original_icons,"original_icons")
#arraytree(icons_neverlinked,"icons_neverlinked")
#arraytree(symlinked_icons,"symlinked_icons")
#arraytree(,"")
count_sec="Count of originals in each theme"

origstr="["count_sec"]"
for(tmp_i in original_icons){origstr=origstr (origstr?"\n":"") tmp_i"="length(original_icons[tmp_i])}
origstr=origstr "\n\n[Never linked originals]"
asorti(icons_neverlinked,icons_neverlinked_s)
for(tmp_i in icons_neverlinked_s){origstr=origstr (origstr?"\n":"") icons_neverlinked_s[tmp_i]}
print origstr > statistic
close(statistic)


#reada("/home/joker/Документы/scripts/GAWK/icons.bin", icons)


#papki(icons,"/home/joker/Документы/GitHub/all_icons")

papki(icons)
printf "Creating rating of how many originals are in theme..."
sortrating(statistic,rating)
print " " rating " Done!"

#getthemes("/home/joker/GitHub/Win98SE/SE98|/usr/share/icons",themearray)
#arraytree(themearray,"themearray")
#arraytree(themearray,"themearray")
#arraytree(linksa,"linksa")
#arraytree(icons,"icons")
}
