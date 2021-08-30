#!/usr/bin/gawk -f
## IconTable Script for viewing and extract png-icons from Windows .ico files.
## Needed package "icoutils" installed as dependency.
## Change "browser" variable in BEGIN section from "yelp" to your favorite fast browser if you have it!

function extract(infile){
if(ENVIRON[TMPDIR]){tmproot=ENVIRON[TMPDIR]}else{tmproot="/tmp"}
system("rm -r "tmproot"/*_icotbl")
"mktemp -d --suffix=_icotbl"|getline tmpdir
extrcmd="icotool -x \""infile"\" -o \""tmpdir"\""
system(extrcmd)
close(extrcmd, "to")
}

function buildtable(name,folder){
cmd="find \""folder"\" -regextype sed -regex \".*/"name"_[0-9]*_.*\\.png\"";
while ((cmd|getline fnam)>0){
#print fnam
fattr=fnam;gsub(folder"/"name"_","",fattr);gsub(/.[^.]+$/,"",fattr)
ext=fnam;gsub(/[^\.]*\./,"",ext)
#print fattr
split(fattr,inf,FS)
nomer=inf[1]
#format[nomer][0]=0;delete format[nomer][0]
split(inf[2],format,"x")
imagefile[format[1]][format[2]][format[3]]=fnam
width[format[1]]=format[1]
height[format[2]]=format[2]
color[format[3]]=format[3]
sizeraw=format[1] format[2]
sizeraw=sizeraw+0
sizeraw_arr[sizeraw]=sizeraw
}
close(cmd)
asort(sizeraw_arr)
asort(width)
asort(height)
asort(color)
}

function buildfile(name,folder){
outfile=folder"/"name".html"

print "<html><head><title>"name".ico</title></head></head>"
print "<body style=\"margin:0;padding:0\">">outfile
print "<table border=1 width=\"100%\">">outfile
print "<tr><td colspan=\""length(color)*2"\" style=\"justify-content:center; align-items: center; text-align:center\"><font size=\"120%\">"name".ico</font></td></tr>">outfile
print "<tr>">outfile
for(c in color){
if(color[c]==32){display_color="XP"}else if(color[c]==24){display_color="True"}else if(color[c]==16){display_color="High"}else{display_color=2^color[c]}
print "<td colspan=2 style=\"justify-content:center; align-items: center; text-align:center\"><b>"display_color" color</b></td>">outfile
}

print "</tr>">outfile
for(i in sizeraw_arr){

polovina=length(sizeraw_arr[i])/2
w=substr(sizeraw_arr[i],1,polovina)
h=substr(sizeraw_arr[i],polovina+1,polovina)

print "<tr>">outfile

for(c in color){
print "<td>"w"x"h"</td><td><img width=\""w"\" height=\""h"\" src=\""imagefile[w][h][color[c]]"\"></td>">outfile
}

print "</tr>">outfile
}
print "</table></body>">outfile
}

function deltemp(){
dtemp="rm -r "tmpdir
system(dtemp)
close(dtemp)
}

function openfile(){
openhtml=browser" \""outfile"\" 2>/dev/null"
system(openhtml)
#close(openhtml,"to")
#deltemp()
}

BEGIN{
OFS=":"
FS="_"
#tmpdir="/home/joker/Документы/icons/tmp"
browser="/usr/bin/yelp"
}

END{

extract(ARGV[1])
iconame=ARGV[1];gsub(/.*\//,"",iconame);gsub(/.[^.]+$/,"",iconame)
buildtable(iconame,tmpdir)
buildfile(iconame,tmpdir)
openfile()

#dtemp="rm -r "tmpdir
system(dtemp)
#close(dtemp)

#print ARGV[1]
#print outfile
}
