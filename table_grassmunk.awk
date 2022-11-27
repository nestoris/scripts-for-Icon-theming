#!/usr/bin/gawk -f

## Readme.
## This script automatically builds html-file with icons in a Context-directory of Icon Theme.
## It requires GAWK (GNU Awk scripting language -- not POSIX-awk, mawk or nawk!).
## To use this script, make it executable (chmod +x table_grassmunk.awk), then run it in a context folder, for example:
### [user@computer places]$ table_grassmunk.awk > places.html
## It will create a HTML-file with table of found icons Grassmunk's decoration.
## The structure of theme MUST be as:
### Theme/Context/Size/icon.png
### For example: SE98/places/48/user-desktop.png
## (NOT ThemeName/places/48X48/user-desktop.png
## and NOT ThemeName/48X48/places/user-desktop.png
## and NOT ThemeName/48/places/user-desktop.png)

@load "readdir"

function capital(word){ #Make first letter capital
return toupper(substr(word,1,1)) tolower(substr(word,2,length(word)))
}

function iconames(dirar,iconarr,	i,pwdi){ #Get all names of .png icons in this context
	for(i in dirar){
		pwdi=ENVIRON["PWD"]"/"i
		fs=FS
		FS="/"
		while((getline<pwdi)>0){
			if($3~"f"&&$2~/\.png$/){gsub(/\.[^.]*$/,"",$2);iconarr[$2];dirnam=i"/"$2;existar[dirnam]=dirnam}
		}
		FS=fs
	}
}

function prepare(){ #Define html variables and get size folders.
fol_nam=ENVIRON["PWD"]
gsub(/^.*\//,"",fol_nam)
fs=FS
FS="/"
while((getline<ENVIRON["PWD"])>0){
if($3=="d"&&$2!~/^\.+$/&&$2~/[0-9]+/){dirar[$2]}
}
FS=fs

head="<!DOCTYPE html>\n\
<html>\n\
<head>\n\
<style>\n\
td {\n\
  border: 1px solid black;\n\
  padding: 10px;\n\
  text-align:center;\n\
  font-size: x-small;\n\
  vertical-align: bottom;\n\
  background: white;\n\
}\n\
table {\n\
  position: relative;\n\
  margin-left: auto;\n\
  margin-right: auto;\n\
}\n\
\n\
th {\n\
  background: #000080;\n\
  color: white;\n\
  position: sticky;\n\
  top: 0;\n\
  border: 1px solid black;\n\
  padding: 10px;\n\
  text-align:center;\n\
}\n\
\n\
body {\n\
  background: #008080;\n\
  font-family: Arial, Helvetica, Arial, sans-serif;\n\
}\n\
h1, h2 {\n\
  font-family: Arial, Helvetica, Arial, sans-serif;\n\
  color: white;\n\
  text-align:center;\n\
  font-weight: bold;\n\
}\n\
</style>\n\
<title>Chicago 95 Icons: stock</title>\n\
<!-- Part of the Chicago95 project -->\n\
</head>\n\
<body><h1>SE98 Icons: "capital(fol_nam)"</h1>\n\
<br><br>\n\
<center><p style=\"color:white\">Below is the list of all icons using in the <b>"capital(fol_nam)"</b> section. Each icon is identified by its name. If the icon is a symlink to another icon it will be followed by the name of the link target.</p></center>\n\
<br><br>"
foot="</body></html>"
}

function table(){ #Build and print HTML table to stdout.
print head

print "<table>\n"

print "\t<tr>"
for(i in dirar){
	print "\t\t<th>" i "</th>"
}
print "\t</tr>\n"

iconames(dirar,iconarr)
for(ic in iconarr){

print "\t<tr>"
for(k in dirar){
#print k"/"ic
dirnam=k"/"ic
#print dirnam existar[dirnam]
	imgtag=(existar[dirnam]?"\t\t\t<img src=\"./"k"/"ic".png\" alt=\""ic".png\">\n\t\t\t<br>"ic".png\n":"")
	print "\t\t<td>\n" imgtag "\n\t\t</td>"
}
print "\t</tr>"
}
print "</table>"
print foot
}

BEGIN{
prepare()
table()
}
