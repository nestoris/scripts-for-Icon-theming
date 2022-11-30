#!/usr/bin/gawk -f
@load "rwarray"
@load "readfile"
@load "readdir"
# @load "json"
# @include "arraytree"
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

function writeIconArray(arrfile,	iph,	ipath){
#cmd[1]="find \"/usr/share/icons/\" -type f -regextype awk -regex \".*\\.(svg|png|xpm)\" -printf \"%h|%f\\n\""
#cmd[2]="find \"/home/joker/.icons/\" -type f -regextype awk -regex \".*\\.(svg|png|xpm)\" -printf \"%h|%f\\n\""
#cmd[3]="find \"/home/joker/.local/share/icons/\" -type f -regextype awk -regex \".*\\.(svg|png|xpm)\" -printf \"%h|%f\\n\""
#cmd[4]="find \"/usr/share/pixmaps/\" -type f -regextype awk -regex \".*\\.(svg|png|xpm)\" -printf \"%h|%f\\n\""
#cmd[5]="find \"/home/joker/GitHub/Win98SE/Icons/SE98/\" -type f -regextype awk -regex \".*\\.(svg|png|xpm)\" -printf \"%h|%f\\n\""
#cmd[6]="find \"/home/joker/Downloads/icons/TEST_ICONS\" -type f -regextype awk -regex \".*\\.(svg|png|xpm)\" -printf \"%h|%f\\n\""

linksf=parfile=chilfile=arrfile
gsub(/\/[^/.]*\./,"/iconparents.",parfile)
gsub(/\/[^/.]*\./,"/iconchildren.",chilfile)
gsub(/\/[^/.]*\./,"/iconlinks.",linksf)


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
print "Looking for icons in \""ipath[df]"\"..."
#while((cmd[df]|getline)>0){
cmd[df]="find -H \""ipath[df]"\" -type f,l -regextype awk -regex \".*\\.(png|xpm|svg)\" -printf \"%h|%f|%l\\n\""
while((cmd[df]|getline)>0){
#print gensub(/\.[^.]*$/,"",1,$2) "=" $1 "/" $2
 noext=gensub(/\.[^.]*$/,"",1,$2) #name of icon w/o extension
 isarray(themearray)&&themearray[$1]["Context"]?icon_contexts[noext][themearray[$1]["Context"]]++:""
 if(isarray(icons[noext])){
  isarray(themearray)&&themearray[$1]["Context"]?icons[noext]["#"][themearray[$1]["Context"]]++:""
  isarray(themearray)&&themearray[$1]["context"]?icons[noext]["#"][themearray[$1]["context"]]++:""
  icons[noext][length(icons[noext])+1]=$1 "/" $2
 }else{
  #if(noext=="stock_people"){print $1, $2}
  delete icons[noext]
  icons[noext]["1"]=$1 "/" $2
 }
 if($3){
#  linksa[$1 "/" $2]=abspath($3,$1 "/")
  linksa[$1 "/" $2]=$3
  gsub(/.*\/|\.[^.]*$/,"",$3)
  if(length($3)>4){iconparents[noext][$3]=$3}
  iconchildren[$3][noext]=noext
 } #creating arrays for symlinked files. iconparents["symlink_name"]["original_target"]
}
close(cmd[df])
}
writea(arrfile, icons)

if(isarray(iconparents)){writea(parfile, iconparents)}
if(isarray(iconchildren)){writea(chilfile, iconchildren)}
if(isarray(linksa)){writea(linksf, linksa)}
}

function build(	json,	htm){

htm=htm "\n\
<!DOCTYPE html>\n\
<html>\n\
<head><meta charset=\"utf-8\" /><title>HTML5</title></head>\n\
<body>\n\
<label for=\"iconcombo\">Choose your iconcombo from the list:</label>\n\
<input list=\"iconnames\" name=\"iconcombo\" id=\"iconcombo\">\n\
<datalist id=\"iconnames\">\n\
</datalist>\n\
<select name=\"thelist\" id=\"iconcomboclose\" onchange=\"combo(this, 'iconcombo')\">\n\
</select> \n\
<div id=\"output\">\n\
</div><br>\n\
</body>\n"

htm=htm "\n<script lnguage=\"JavaScript\" type=\"text/javascript\">"
htm=htm "\nfunction combo(thelist, iconcombo){theinput = document.getElementById(\"theinput\"); var idx = thelist.selectedIndex; var content = thelist.options[idx].innerHTML;document.all.iconcombo.value = content};"
htm=htm "\nconst icon = " json ";"
htm=htm "\nfor(var i in icon){document.all.iconnames.innerHTML+='<option value=\"'+i+'\">';document.all.iconcomboclose.innerHTML+='<option>'+i+'</option>'};"
htm=htm "\ndocument.all.iconcombo.addEventListener(\"input\", function(event){if(event.inputType == \"insertReplacementText\" || event.inputType == null){icontable=event.target.value+'<br>';icontable+='<table border="1">';for(var i in eval('icon[\"'+event.target.value+'\"]')){icontable+='<tr><td><img src=\"'+eval('icon[\"'+event.target.value+'\"]['+i+']')+'\"></td><td>'+eval('icon[\"'+event.target.value+'\"]['+i+']')+'</td></tr>'};icontable+='</table>';document.all.iconcombo.textContent=event.target.value};document.all.output.innerHTML=icontable});"
htm=htm "\ndocument.all.iconcomboclose.addEventListener(\"input\", function(event){var icontable=event.target.value+'<br>';icontable+='<table border=\"1\">';for(var i in eval('icon[\"'+event.target.value+'\"]')){icontable+='<tr><td><img src=\"'+eval('icon[\"'+event.target.value+'\"]['+i+']')+'\"></td><td>'+eval('icon[\"'+event.target.value+'\"]['+i+']')+'</td></tr>'};icontable+='</table>';document.all.output.innerHTML=icontable});"
htm=htm "\n</script>"
htm=htm "\n</html>"

return htm
}

function papki(	array,	path,	i,	j,	cntx){ #create folder with html-files and main index.html page with counts
 #path=path?path:"/home/joker/Документы/scripts/GAWK/all_icons/all"
 path=path?path:"/tmp/all_icons"
 of=path "/index.html" ### OUTPUT FILE === вывод файла
 markdown=path "/index.md"
 system("mkdir -p " path "/icons")

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
 print "Created " length(array_s) " HTML files in '"path"'."
}

function find_and_save(){
writeIconArray("/home/joker/Документы/scripts/GAWK/icons.bin")
}

function load_saved(){
reada("/home/joker/Документы/scripts/GAWK/icons.bin", icons)
reada("/home/joker/Документы/scripts/GAWK/iconparents.bin", iconparents)
reada("/home/joker/Документы/scripts/GAWK/iconchildren.bin", iconchildren)
reada("/home/joker/Документы/scripts/GAWK/iconlinks.bin", linksa)

}


BEGIN{
FS="|"
imgsize=48 #size of images in each html table

#print abspath("../../mimetypes/64/message.png","/home/joker/GitHub/Win98SE/SE98/apps/64/")

## create and save icon array OR read it from bin file (Only ASCII paths! No Unicode!)
# getthemes("/home/joker/GitHub/Win98SE/SE98|/usr/share/icons",themearray)
writeIconArray("icons.bin")
#reada("/home/joker/Документы/scripts/GAWK/icons.bin", icons)

####find_and_save()
#load_saved()

## garbage
#reada("/home/joker/Документы/scripts/GAWK/all_icons/icons.bin", icons)
#print json::to_json(icons) > "pixmaps.json"

## saving array of icons to json
#print json::to_json(icons) > "/home/joker/Документы/scripts/GAWK/all_icons/icons.json"

## garbage
#json::from_json(readfile("/home/joker/Документы/scripts/GAWK/all_icons/icons.json"),icons)
#arraytree(icons,"icons")
#json=json::to_json(icons)

#papki(icons,"/home/joker/Документы/GitHub/all_icons")

papki(icons)
#getthemes("/home/joker/GitHub/Win98SE/SE98|/usr/share/icons",themearray)
#arraytree(themearray,"themearray")
#arraytree(themearray,"themearray")
#arraytree(linksa,"linksa")
#arraytree(icons,"icons")

## garbage
#print build(json)
#print json | "jq . "
}
