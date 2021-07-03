function rne(rusnum,raz,dva,mnogo){
 rusnum_tmp[1]=substr(rusnum,length(rusnum),1)
 rusnum_tmp[2]=substr(rusnum,length(rusnum)-1,1)
 rusnum_tmp[1]=rusnum_tmp[1]/1
 rusnum_tmp[2]=rusnum_tmp[2]/1

 if(rusnum_tmp[1]==1&&(rusnum_tmp[2]!=1||length(rusnum)==1)){
  outrusend=raz
 }else{
  if(rusnum_tmp[1]<=4&&rusnum_tmp[1]>=2&&rusnum_tmp[2]!=1){outrusend=dva}else{outrusend=mnogo}
 }
 return outrusend;
}



function localize(){
langsarr["ru"]="ru"
langsarr["en"]="en"

get_text["scripdesc"]["ru"]="Скрипт для просмотра и сравнения тем значков GNU/Linux.\n"
get_text["scripdesc"]["en"]="Script for viewing and comparing icon themes of GNU/Linux.\n"

get_text["scripsyntax"]["ru"]="Синтаксис: " scriptname "[ФАЙЛ1] [ФАЙЛ2]… [ПАРАМЕТР]…\n\tФайлы могут быть как с полным путём, так и с относительным. Но всегда - index.theme. Вводятся через пробел перед указанием параметров.\n\tЕсли указан один файл темы, то создаётся таблица значков этой темы."
get_text["scripsyntax"]["en"]="Syntax: " scriptname "[FILE1] [FILE2]… [OPTION]…\n\tThe files can be either full path or relative path. But always index.theme. Options are entered through a space before specifying the parameters.\n\tIf only one theme file is specified, then a table of icons of this theme is created."

get_text["paramtitle"]["ru"]="Параметры бывают такие:"
get_text["paramtitle"]["en"]="List of options:"

get_text["opts_contexts"]["ru"]="\t-с\tВыбор контекстов для сравнения. Указывается таким образом: «-c=Actions,MimeTypes»"
get_text["opts_contexts"]["en"]="\t-с\tSelection of contexts for comparison. It is indicated in this way: «-c=Actions,MimeTypes»"

get_text["opts_sizes"]["ru"]="\t-s\tВыбор размеров значков для обработки. Указывается таким же образом: «-s=16,32,48»"
get_text["opts_sizes"]["en"]="\t-s\tChoosing the size of the icons for processing. Indicated in the same way: «-s=16,32,48»"

get_text["opts_descriptions"]["ru"]="\t-d\tС этим параметром выводятся описания для контекстов и значков, указанные в файле-списке. «-d=[ФАЙЛ]»."
get_text["opts_descriptions"]["en"]="\t-d\tThis parameter displays descriptions for the contexts and icons specified in the list file. «-d=[ФАЙЛ]»."

get_text["opts_descripted_only"]["ru"]="\t-u\tТо же самое, что и -d, но пропуская значки, отсутствующие в файле-списке. «-u=[ФАЙЛ]».\n\t\t\tСинтаксис файла-списка:Контекст - одно слово в строке, далее список из строк типа: имя и описание значка, разделённые табуляцией.\n\t\t\tСтроки, содержащие пробелы И заглавные буквы, начинающиеся с решётки, а так же пустые игнорируются"
get_text["opts_descripted_only"]["en"]="\t-u\tSame as -d, but omitting icons that are not in the list file.«-u=[ФАЙЛ]».\n\t\t\tSyntax of the list file: Context - one word per line, then a list of lines of type: name and description of the icon, separated by tabs.\n\t\t\tLines containing spaces AND capital letters starting with a hash, as well as empty ones are ignored"

get_text["opts_outfolder"]["ru"]="\t-f\tПапка для сохранения html-файлов. «-f=[папка]»."
get_text["opts_outfolder"]["en"]="\t-f\tFolder for saving html files. «-f=[папка]»."

get_text["zenity"][1]["ru"]="Выбери контексты темы (Ctrl+click - выбор нескольких)"
get_text["zenity"][1]["en"]="Choose contexts of theme (Ctrl+click - multiple selection)"

get_text["zenity"][2]["ru"]="Выбор контекстов"
get_text["zenity"][2]["en"]="Context choosing"

get_text["Context"]["ru"]="Контекст"
get_text["Context"]["en"]="Context"

get_text["zenity"][4]["ru"]=""
get_text["zenity"][4]["en"]=""

get_text["Theme"]["ru"]="Тема"
get_text["Theme"]["en"]="Theme"

get_text["Creating"]["ru"]="Создаётся"
get_text["Creating"]["en"]="Creating"

get_text["Copy"]["ru"]="Скопировать"
get_text["Copy"]["en"]="Copy"

get_text["Folder"]["ru"]="Папка"
get_text["Folder"]["en"]="Folder"

get_text["FileOptTmpNotFound"]["ru"]="Файл '"opt_tmp"' не найден"
get_text["FileOptTmpNotFound"]["en"]="File '"opt_tmp"' not found"

get_text["HowManyIcInCont"]["ru"]="В контексте \""i"\" - " numic " знач" rne(numic,"ок","ка","ков") "."
get_text["HowManyIcInCont"]["en"]="There are " numic " icon"(numic==1?"":"s")" in \""i"\" context."

get_text["CollectData"]["ru"]="Собираются данные тем" (ARGC==2?"ы":"") "..."
get_text["CollectData"]["en"]="Collecting data of theme"(ARGC==2?"":"s") "..."

get_text["file_with_descs"]["ru"]="Файл со значками и описаниями:"
get_text["file_with_descs"]["en"]="File with icons and descriptions:"

get_text["deleting"]["ru"]="удалятся"
get_text["deleting"]["en"]="deleting"

get_text["Overwritefile"]["ru"]="Заменить файл"
get_text["Overwritefile"]["en"]="Overwrite file"

get_text["TotalyFoundIcons"]["ru"]="Всего найден"rne(numic,"","ы","о")" "numic" знач" rne(numic,"ок","ка","ков") " в контексте \""i"\""
get_text["TotalyFoundIcons"]["en"]="Totaly found "numic" icons in \""i"\" context."

get_text["DescIsGot"]["ru"]="<br>\nОписание взято из списка: \""std_icon_list"\"."
get_text["DescIsGot"]["en"]="<br>\nDescription is got from: \""std_icon_list"\" list."

get_text["CompOfThms"]["ru"]="<br>\nСравнение " length(ARGV) "-"rne(length(ARGV),"й","х","и")" тем"rne(length(ARGV),"ы","","")": "
get_text["CompOfThms"]["en"]="<br>\nComparison of " length(ARGV) " themes: "

get_text["TblOfCont"]["ru"]="Таблица контекста \"<b>"i"</b>\" в теме \"<b>" name "</b>\""
get_text["TblOfCont"]["en"]="Table of \"<b>"i"</b>\" context in \"<b>" name "</b>\" theme"

get_text["MaybeContext"]["ru"]="<br>Возможно, значок <b>\""n"\"</b> принадлежит контексту <b>\""stdicon_cont[n]"\"</b>?"
get_text["MaybeContext"]["en"]="<br>Maybe the context of <b>\""n"\"</b> is <b>\""stdicon_cont[n]"\"</b>?"

get_text["AddedIconsInFile"]["ru"]="В файл \""fileoutput"\" добавлено " numic_print " знач" rne(numic_print,"ок","ка","ков") "."
get_text["AddedIconsInFile"]["en"]=numic_print " icon" (numic_print==1?"":"s") " added to the file \"" fileoutput "\"."

get_text["ContsChosen"]["ru"]="Выбраны контексты: " conts # gensub(", "," и ",(conts~" "?gsub(" ",", ",conts):1))
get_text["ContsChosen"]["en"]="Chosen contexts: " conts # gensub(", ",", and ",(conts~" "?gsub(" ",", ",conts):1))

get_text["Done"]["ru"]="Готово"
get_text["Done"]["en"]="Done"
}

function _(gtstring){
gttrans=get_text[gtstring][lang]
return gttrans
}
