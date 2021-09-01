#!/usr/bin/gawk -f
@load "readfile"
@load "readdir"
@load "filefuncs"
@include "arraytree.awk"

#######################################################################################

function printstyle(	style){
style="\
<style>\n\
body {text-align:center; background-color:#3A6EA5;}\n\
table { border: 1px outset #EDE8DF;background:#D4D0C8;}\n\
table.description {border: 1px solid #333300;padding:6px;border-radius:4px;background:#FFFFE1;box-shadow: 0 0 10px rgba(0,0,0,0.5); /* Параметры тени */}\n\
table.description tr {border:none;background:#D4D0C8}\n\
table.description td {padding:5px;border:none;background:#FFFFE1}\n\
tr, td { border: 1px inset #EDE8DF; background:white; }\n\
td.title { border: none; font-family: Sans; font-weight:500; background: -webkit-linear-gradient(left, #0A246A, #A6CAF0); /* Safari 5.1, iOS 5.0-6.1, Chrome 10-25, Android 4.0-4.3 */\n\
background: -moz-linear-gradient(left, #0A246A, #A6CAF0); /* Firefox 3.6-15 */\n\
background: -o-linear-gradient(left, #0A246A, #A6CAF0); /* Opera 11.1-12 */\n\
background: linear-gradient(to right, #0A246A, #A6CAF0); /* Opera 15+, Chrome 25+, IE 10+, Firefox 16+, Safari 6.1+, iOS 7+, Android 4.4+ */ \n\
color: white;\n\
padding: 10;}\n\
tr.cap td{border: 1px inset #EDE8DF;background-color:#D4D0C8;}\n\
td.shortcut { background-color: #EDE8DF}\n\
#title {height: 24px; font-size:19px; text-align:left; overflow:hidden;}\n\
#icontbl{box-shadow: 0.4em 0.4em 15px rgba(0,0,0,0.3);}\n\
#caption {text-shadow: 1px 1px 2px black, 0 0 1em #A6CAF0; font-size:39px; color:white; font-weight:bold; font-family:Sans,Sans-Serif,MS-Sans-Serif}\n\
#tooltip {\n\
  text-decoration:none;\n\
  position:relative;\n\
  margin-top:100;\n\
}\n\
.orig {\n\
  text-decoration:none;\n\
  position:relative;\n\
  padding:4;\n\
  margin-top:100;\n\
  margin-left:100;\n\
  -moz-border-radius:3px;\n\
  -webkit-border-radius:3px;\n\
  border-radius:3px;\n\
  color:black;\n\
  border:1px solid #EDE8DF;\n\
}\n\
.symlink {\n\
  text-decoration:none;\n\
  position:relative;\n\
  padding:4;\n\
  margin-top:100;\n\
  margin-left:100;\n\
  -moz-border-radius:3px;\n\
  -webkit-border-radius:3px;\n\
  border-radius:3px;\n\
  color:black;\n\
  border:1px solid #666666;\n\
}\n\
.none {\n\
  text-decoration:none;\n\
  position:relative;\n\
  padding:0;\n\
  margin-top:100;\n\
  margin-left:100;\n\
}\n\
\n\
#tooltip img {\n\
  cursor:pointer;\n\
}\n\
\n\
#tooltip span {\n\
  display:none;\n\
  margin:4px;\n\
}\n\
 \n\
#tooltip span img {\n\
  float:left;\n\
  margin:0px 1px 1px 0;\n\
}\n\
#tooltip:hover span {\n\
  position:absolute;\n\
  display:block;\n\
  width:auto;\n\
  --max-width:220px;\n\
  --min-height:128px;\n\
  background-color:#FFEEAA;\n\
  padding:0;\n\
  margin-top:0;\n\
  margin-left:0;\n\
  -moz-border-radius:3px;\n\
  -webkit-border-radius:3px;\n\
  border-radius:3px;\n\
  color:black;\n\
  border:1px solid #AA3366;\n\
  z-index:1000;\n\
}\n\
#tooltip span pre {\n\
  position:absolute;\n\
  display:block;\n\
  width:auto;\n\
  --max-width:220px;\n\
  --min-height:128px;\n\
  background-color:#FFEEAA;\n\
  padding:0;\n\
  margin-top:0;\n\
  margin-left:0;\n\
  -moz-border-radius:3px;\n\
  -webkit-border-radius:3px;\n\
  border-radius:3px;\n\
  color:black;\n\
  border:1px solid #AA3366;\n\
  z-index:1000;\n\
}\n\
</style>"
return style;
}

function warning(	text){
system("zenity --warning --text="text)
}

function frontend_detect(){
 detectsoft="command -v gtkdialog yad zenity easydialog-legacy kdialog Xdialog dialog whiptail"
 while((detectsoft|getline)>0){
 if($0~"gtkdialog"){gtkdialog=$0}
 if($0~"yad"){yad=$0}
 if($0~"zenity"){zenity=$0}
 if($0~"kdialog"){kdialog=$0}
 if($0~"Xdialog"){Xdialog=$0}
 if($0~"easydialog-legacy"){easydialog=$0}
 if($0~"dialog"){dialog=$0}
 if($0~"whiptail"){whiptail=$0}
 #yad=($0~/yad/?$0:""); zenity=($0~"zenity"?$0:""); dialog=($0~"dialog"?$0:"")
 
 }
 con_gui_cmd="if [ -t 0 ]; then echo \"con\" ;else echo \"gui\"; fi"
 while((con_gui_cmd|getline con_gui)>0){
  if(con_gui~"gui"){
   #if(yad){fe[1]="yad";fe[2]=yad}else{if(zenity){fe[1]="zenity";fe[2]=zenity}}
   fe[1]=yad?"yad":zenity?"zenity":kdialog?"kdialog":Xdialog?"Xdialog":""
  }else{
   fe[1]=dialog?"dialog":Xdialog?"Xdialog":yad?"yad":zenity?"zenity":kdialog?"kdialog":""
   #if(dialog){fe[1]="dialog";fe[2]=dialog}else{if(yad){fe[1]="yad";fe[2]=yad}else{if(zenity){fe[1]="zenity";fe[2]=zenity}}}
  }
 }
 #fe[1]=""
}

function choosefolder(	path,	tempfile,	dargs,	loc,	loca,	cmd){
if(!isarray(fe)){frontend_detect()}
#fe[1]="kdialog"
#print fe[1]
#fe[1]=""

if(fe[1]=="yad"){ # If Yet Another Dialog
cmd="yad --title=\"Choose directory for saving HTML-files\" --file --directory"
(cmd|getline loc)
close(cmd)
re_turn_v=loc
}

if(fe[1]=="zenity"){ # If Zenity
cmd="zenity --title=\"Choose directory for saving HTML-files\" --file-selection --directory"
(cmd|getline loc)
close(cmd)
re_turn_v=loc
}

if(fe[1]=="Xdialog"){ # If XDialog
#cmd="mktemp 2>/dev/null"
#while((cmd|getline tempfile)>0);
#close(cmd)

cmd=("Xdialog --stdout --dselect "path" 42 70")
(cmd|getline loc)
close(cmd)
#system(cmd);
#loc=readfile(tempfile)
#cmd="rm "tempfile" 2> /dev/null"
#system(cmd);close(cmd)
#print "+++"loc"+++"
re_turn_v=loc
}

if(fe[1]=="kdialog"){ # If KDE KDialog
cmd="kdialog --getexistingdirectory --title \"Choose directory for saving HTML-files\""
(cmd|getline loc)
re_turn_v=loc
}

if(fe[1]=="dialog"){ # If CLI Dialog
#cmd="mktemp 2>/dev/null"
#while((cmd|getline tempfile)>0);
#close(cmd)
#cmd="dialog --dselect "path" 12 70 2> "tempfile
cmd="dialog --stdout --dselect "path" 12 70"
(cmd|getline loc);close(cmd)
#loc=readfile(tempfile)
if(loc){
cmd="dialog --stdout --inputbox \"Save HTML-files in this directory?\\n\\nYou can select the folder (in previous dialog) by pressing a spacebar and typing '/' to browse it. Or by editing it here.\" 10 70 \""loc"\"" #" && cat "tempfile
while((cmd|getline loca)>0);
#if(loca){return loca}
#system(cmd);close(cmd)
#loca=readfile(tempfile)
#cmd="rm "tempfile" 2> /dev/null"
#system(cmd);close(cmd)
if(loca){
#system("zenity --question --text='"loca"'")
re_turn_v=loca
}else{
#system("zenity --question --text='"loca"'")
close(cmd);choosefolder(loc)
}
}
}

if(!fe[1]){ # If Nothing
if(con_gui!~"con"){exit}
print "Enter path for saving HTML-files:"
(getline typer < "-" && !"-");
re_turn_v=typer
}

}

function re_turn(){
return re_turn_v
}

function ask(	array,	arrout,	a,	maxlistlength,	tempfile,	cmd,	dargs,	yargs,	zargs, dargs_m){
 if(isarray(arrout)){delete 	arrout}
 if(!isarray(fe)){frontend_detect()}
 #fe[1]=""

 if(fe[1]=="yad"){ # If Yet Another Dialog
  yargs=" --width=\"500\" --height=\"300\" --list  --separator='' --multiple --column=\"Contexts\" --text=\"Hold 'Control' button for multiple selection.\""
  for(a in array){
   yargs=yargs " \""array[a]"\""
  }
  a=0
  while((yad yargs|getline)>0){
   a++
   arrout[a]=$0
  }
 }

 if(fe[1]=="zenity"){ # If Zenity
  zargs=" --list --width=500 --height=400 --multiple --separator=\"\\n\" --column \"Contexts\""
  for(a in array){
   zargs=zargs " \""array[a]"\""
  }
  a=0
  while((zenity zargs|getline)>0){
   a++
   arrout[a]=$0
  }
 }

 if(fe[1]=="dialog"){ # If CLI Dialog
  cmd="mktemp 2>/dev/null"
  while((cmd|getline tempfile)>0);
  close(cmd)
  for(a in array){
   dargs_m=dargs_m " \""array[a]"\" \"\" \"off\""
   maxlistlength=length(array[a])>maxlistlength?length(array[a]):maxlistlength
  }
  a=0
  dargs=" --clear --separator \"|\" --checklist \"Select Contexts\" "length(array)+7" "(maxlistlength+10)" 5 "dargs_m" 2> " tempfile
  cmd=(dialog dargs)
  system(cmd);close(cmd)
  while((getline < tempfile)>0){sub(/^\|/,"");split($0,arrout,"|")}
  cmd="rm -f "tempfile"; clear"
  system(cmd);close(cmd)
  if(!isarray(arrout)){exit -1}
 }

 if(fe[1]=="kdialog"){ # If KDE KDialog
 kargs=" --separate-output --checklist Contexts:"
  for(a in array){
   kargs=kargs " \""array[a]"\" \""array[a]"\" \"off\""
  }
  a=0
  cmd=(kdialog kargs)
  while((cmd|getline)>0){a++;arrout[a]=$0};close(cmd)
 }

 if(fe[1]=="Xdialog"){ # If KDE KDialog
 #_Xargs="--separate-output --title \"Choose Contexts\" --no-tags --checklist Contexts: 22 70 13 output label on"
 Xargs=" --stdout --title \"Choose Contexts\" --separator=\"|\" --no-tags --checklist Contexts: 22 70 13"
  for(a in array){
   Xargs=Xargs " \""array[a]"\" \""array[a]"\" \"on\""
  }
  a=0
  cmd=Xdialog Xargs
  #print cmd
  while((cmd|getline bu)>0);
  print bu
  split(bu,arrout,"|")
  close(cmd)
 }

 if(fe[1]==""){ # If nothing
  if(con_gui!~"con"){exit}
  for(a=1;a<=length(array);a++){_str=(_str?_str" "a:a)}
  a=0
  print "Choose Contexts to render:\nDefault is all ("_str")."
  for(a in array){
   print a". "array[a]
  }
  (getline typer < "-" && !"-");
  typer=typer?typer:_str
  split(typer,typera)
  #arraytree(typera,"typera")
  for(a in typera){
  #print typera[a], array[typera[a]]
  arrout[typera[a]]=array[typera[a]]
  }
  #arraytree(arrout,"arrout")
#  for(a=1;a<=length(_str);a++){
#   e=substr(_str,a,1)
#   if(e~/[0-9]/&&typer~e||!typer){arrout[e]=array[e]}
#  }
 }
}

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

function parsefast(	th_arr,	cmd,	th){ # parse icon themes array
 fstmp=FS
 rstmp=RS
 ofstmp=OFS
 orstmp=ORS
 FS="\n|\r"; RS="[\n.*][[]"; OFS=":"; ORS="\n"
 for(th in th_arr){
 theme=th_arr[th]
 if(theme){
  cmd="realpath -qsz "theme
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
   #parsefast(th_arr[i])
   for(j in folder_a[abs]){
    if(context_fld[abs][j]==cnt_arr[k]){
      # print abs j, folder_a[abs][j], context_fld[abs][j], type_fld[abs][j], size_fld[abs][j]
      fstmp=FS
      FS="/"
      while((getline < (abs j))>0){if($3!~"d"&&$2~/.+\.(png|xpm|svg)$/){
       if($3=="l"){
        stat((abs j "/" $2),filedata)
        linkval=filedata["linkval"]
       }else{
        linkval=$2
       }
       noext=gensub(/.[^.]+$/,"",1,$2)
       icon_a[abs][context_fld[abs][j]][type_fld[abs][j]][size_fld[abs][j]][noext]=abs"|"j"|"$2"|"linkval"|"$3"|"size_fld[abs][j]
       iname_a[context_fld[abs][j]][noext]=noext
      }
     }
     FS=fstmp
    }
   }
  }
 }
}

function draw(	th_arr,	cnt_arr,	outfolder,	c,	j,	th,	ty,	s,	outline,	outa){
 for(c in cnt_arr){
  outfile=outfolder?outfolder"/"cnt_arr[c]".html":"/dev/stdout"
  print "<!DOCTYPE html>\n<html>\n<head>\n<meta charset=\"utf-8\" />\n<title>" title "</title>\n" > outfile
  print printstyle() >> outfile
  print "</head><body><center>" > outfile
  asort(iname_a[cnt_arr[c]])
  print "<div id=caption>"cnt_arr[c]"</div>" > outfile # Header of context
  #for(i in iname_a[cnt_arr[c]]){iconcount++ # real count of icons in context
  for(i=600;i<1304;i++){ # for testing of 5 icons
   print "<table id=icontbl border=1><tr><td colspan=25 class=\"title\">"iname_a[cnt_arr[c]][i]"</td></tr>" > outfile # icon name
   print "<tr class=cap><td class=shortcut>theme\\type</td>" > outfile
   for(ty in type_a){
    print "<td colspan="length(size_type_a[ty])" class=shortcut>"ty"</td>" > outfile # types
   }
   print "</tr>" > outfile
   for(th in th_arr){
    gsub(/index\.theme$/,"",th_arr[th])
    print "<tr><td><div id=\"tooltip\">"thname_a[th_arr[th]]"<span>"th_arr[th]"</span></div></td>" > outfile #theme name
    for(ty in type_a){
     #print prev_size[th_arr[th]]
     for(s in size_type_a[ty]){ # if there ARE icons of available sizes - draw them
      if(icon_a[th_arr[th]][cnt_arr[c]][ty][s][iname_a[cnt_arr[c]][i]]){
       outline=icon_a[th_arr[th]][cnt_arr[c]][ty][s][iname_a[cnt_arr[c]][i]]
       split(outline,outa,"|")
       prev_dir[th_arr[th]]=outa[2]
       prev_size[th_arr[th]]=outa[6]
       iconfile=outa[1] outa[2] "/" outa[3]
       iconsize=outa[6]*1
       filetype=outa[5]
      }else{ # Draw pantoms
       outline=th_arr[th]"|"tolower(cnt_arr[c])"/"s"|"iname_a[cnt_arr[c]][i]"."(tolower(ty)=="scalable"?"svg":"png")"||n"
       split(outline,outa,"|")
       fls=prev_dir[outa[1]]
       gsub(prev_size[th_arr[th]],(tolower(ty)=="scalable"?"scalable/"s:s),fls)
       gsub("scalable",(tolower(ty)=="scalable"?"scalable/"s:s),fls)
       iconfile=outa[1] (tolower(ty)=="scalable"?"scalable":fls) "/" outa[3]
       iconsize=s*1
       filetype=outa[5]
      }
      drawsize=iconsize<64?iconsize:64
      #printalt="1"
      if(filetype=="l"&&outa[4]~/\.\//){
      bldrp="realpath -s "outa[1] outa[2] "/" outa[4]
      while((bldrp|getline rlpath)>0);
      close(bldrp)
      }
      print "<p><td style=\"background-color:"(outa[5]=="f"?"":(outa[5]=="l"?"#EDE8E0":"#D4D0C8"))"\"><div "(filetype=="n"?"class=\"none\"":filetype=="f"?"class=\"orig\"":"class=\"symlink\"")" id=\"tooltip\"><img src=\""iconfile"\" width=\""drawsize"\" height=\""drawsize"\" "(printalt?"alt=\""(tolower(ty)=="scalable"?"scalable":iconsize):"")"\"><span>"(tolower(ty)=="scalable"?"Scalable":s"x"s)"<br>"(outa[5]=="n"?"Missing":"Icon")":<pre>"iconfile"</pre>"(outa[5]=="l"?("<br><br>Link target:<pre>"rlpath"</pre>"):"")"</span></div></td></p>" > outfile
     }
    }
   }
  }
  print "</tr></table>" > outfile
 }
 print "</center></body>" > outfile
 print "Total icons found in "cnt_arr[c]" context: "iconcount
}


#######################################################################################

BEGIN{

 delete ARGV[0]
 asort(ARGV,filearr)
#filearr[3]="/home/joker/Документы/GitHub/Win98SE/Icons/SE98/index.theme"
#filearr[2]="/home/joker/Документы/GitHub/Chicago95/Icons/Chicago95/index.theme"
#filearr[1]="/home/joker/Документы/icons/share-icons/mate/index.theme"
#arraytree(ARGV,"ARGV")

contarr[1]="Actions"
contarr[2]="Places"
contarr[3]="Devices"
contarr[4]="MimeTypes"
#contarr[5]="Animations"
#contarr[6]="Status"

#ask(contarr,outarr)
#arraytree(outarr,"outarr")

parsefast(filearr)
asorti(context_a,context_s)
ask(context_s,cont_list)
allfolderslist(filearr,cont_list)
choosefolder("~")
if(re_turn_v){
 outfolder=re_turn_v?re_turn_v:"~"
 draw(filearr,cont_list,outfolder)
}
#asort(iname_a[cont_list[1]])
#warning(cnt_arr[1])
#arraytree(iname_a,"iname_a")

# allfolderslist(filearr,arrout)
 #draw(filearr,cont_list,"/home/joker/Документы/scripts/iconthemes/Devs.html")

 #choosefolder("~")
 #if(re_turn_v){print re_turn_v}

#ask(contarr,arrout)
#arraytree(ARGV,"ARGV")



 #allfolderslist(ARGV,contarr)
 #draw(ARGV,contarr)

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
