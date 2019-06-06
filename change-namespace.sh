#!/bin/bash

if ! [ $# -eq 3 ] ; then
  echo 'Usage: change-namespace.sh path orginal_namespace new_namespace'
  echo 'Install IONDV. Framework application change namespace.'
  echo
  echo 'Example:'
  echo '  ./change-namespace.sh ./applications/crm-new crm-prev crm-new'
  exit
fi

appPath=$1
nsPrev=$2
nsNew=$3
IFS_def=$IFS

curDate=`date +"%Y%m%d-%H-%M"`


if ! [ -d $appPath ]; then
  echo "Path $appPath is wrong"
  exit
fi
echo $appPath

# Function for check the previous namespace and rename temporary filename to original file
# $1 - path to prepared filename 
function checkPrevNsAndRenameFile {
  local prepareFile=$1
  local checkRes=`grep -n "$nsPrev" "$prepareFile-$curDate"`
  if [ ${#checkRes} -ne 0 ] ; then
    echo "Didn't all $nsPrev replace to $nsNew in $prepareFile. Need manual check"
    echo -e "$checkRes"
  fi
  mv -f "$prepareFile-$curDate" $prepareFile
}

fileCount=0
filePrepareCount=0
appFolders=("meta" "navigation" "geo/layers" "geo/navigation")


# Function for change namespace in different instraction for different folder
# $1 - prepared app folder
# $2 - prepared file
function changeNamespace {
  local prepareFile=$2
  local checkRes=`grep -n "$nsPrev" "$prepareFile"`
  if [ ${#checkRes} -eq 0 ] ; then
    return
  fi
  echo "Prepare: $prepareFile"
  filePrepareCount=$(( $filePrepareCount + 1 ))
  case "$1" in 
    'geo')
    #/layers 
      if [ ${fprepareFile##*.} = 'json' ] ; then 
        cat $prepareFile | \
          sed -r "s|geomap/render/$nsPrev|geomap/render/$nsNew|" | \
          sed -r "s|@$nsPrev\"|@$nsNew\"|" |
          sed -r "s|/registry/$nsPrev@|/registry/$nsNew@|" |
          sed -r "s|@$nsPrev/|@$nsNew/|" > \
            "$prepareFile-$curDate"
      fi
      #/navigation
       if [ ${prepareFile##*.} = 'json' ] ; then 
        cat $prepareFile | \
          sed -r "s|geomap/render/$nsPrev|geomap/render/$nsNew|" | \
          sed -r "s|@$nsPrev\"|@$nsNew\"|" > \
            "$prepareFile-$curDate"
      fi
      ;;
    'meta')
      if [ ${prepareFile##*.} = 'json' ] ; then 
        cat $prepareFile | \
          sed -r "s|@$nsPrev,|@$nsNew,|" > \
            "$prepareFile-$curDate"
      fi
      ;;
    'navigation')
      if [ ${prepareFile##*.} = 'json' ] ; then 
        cat $prepareFile | \
          sed -r "s|@$nsPrev\"|@$nsNew\"|" > \
            "$prepareFile-$curDate"
      fi
      ;;
    * ) echo "$1 folder didn't have instruction to prepare. Skip";;
  esac
  checkPrevNsAndRenameFile $prepareFile
}


# Recursive function for cnange namespasece in all files in folder
# $1 - prepared app folder
# $2 - folder for search files to prepare 
function changeNsInAllFilesInFolder {
  local filePath=$2
  for file in $filePath/* ; do 
    if [ -f "$file" ] ; then
      fileCount=$(( $fileCount + 1 ))
      changeNamespace $1 $file   
    else
      changeNsInAllFilesInFolder $1 $file           
    fi
  done
}

for prepareFolder in ${appFolders[@]} ; do
  fileCount=0
  filePrepareCount=0
  if [ -d "$appPath/$prepareFolder" ] ; then
    changeNsInAllFilesInFolder $prepareFolder $appPath/$prepareFolder          
  fi
  echo "Prepared $filePrepareCount($fileCount)files in $appPath/$prepareFolder"
done



# Вырезать
#sed 's/"logo": "geoicons\/logo.png",//' ./applications/khv-svyaz-info/deploy.json > ./applications/khv-svyaz-info/deploy_temp_$curDate.json
#grep '"engines"\s*:\s*{' $frameworkPath/applications/$appName/package.json > /dev/null # Check empty
#if [ $? -eq 0 ]; then
#grep '"engines"\s*:\s*{[\s\n]*}' $frameworkPath/applications/$appName/package.json > /dev/null
#fi
#if [ $? -ne 0 ]; then
#  engines=`sed -n -r '/"engines":\s+\{/,/\}/{ /"engines":\s+\{/d; /}/d; p; }' $frameworkPath/applications/$appName/package.json`
#  if ! [ ${#engines[@]} = 0 ] ; then
#    for i in ${enginelist[@]}
#    do
#    enginelist=`echo $engines | tr -d [:space:] | tr -d '"' | tr ',' '\n'`
#      IFS=':' tmp=($i)
#      if [ ${tmp[0]} = "ion" ]; then
#        git checkout tags/${tmp[1]}


#  imageVer=`grep "version" $frameworkPath/applications/$appName/package.json | sed 's/"version\"://' | sed 's/"//g' | sed 's/,//g' | sed 's/ //g'`


#отдельной утилитой
#- deploy.json
#namespace: "ns"
#"namespaces": {
#"ns": ""
#}
#"[a-zA-Z\-_]@ns"
#"ns@[a-zA-Z\-_]"
#пути applications/ns

# if [ -f "$appPath/package.json" ] ; then
#   # echo "Process package.json"
#   # cat $appPath/package.json | \
#   #   sed -r "s|\"name\"\s*:\s*\"$nsPrev\"|\"name\": \"$nsNew\"|" > \
#   #      $appPath/package_temp_$curDate.json
#   # mv -f $appPath/package_temp_$curDate.json $appPath/package.json
# fi

if [ -f "$appPath/deploy.json" ] ; then
  echo "Process deploy.json"
  echo "  replace namespace" "namespace": "khv-svyaz-info"
 #   sed -r "s|(\"namespaces\"\s*:\s*\{\[\s\d\w\-а-яА-ЯёЁ\":\]*\[\^\}\])(\"$nsPrev\")|\1\"$nsNew\"|" \
    #  sed -r "s|(\"namespaces\"\s*:\s*\{\[\s\d\w\-а-яА-ЯёЁ\":\]*\[\^\}\])|\1     -|" > \
  cat $appPath/deploy.json | \
    sed -r "s|\"applications/$nsPrev/|\"applications/$nsNew/|" | \
    sed -r "s|\"namespace\"\s*:\s*\"$nsPrev\"|\"namespace\": \"$nsNew\"|" | \
    sed -r "s|@$nsPrev\"|@$nsNew\"|" | \
    sed -r "s|\"$nsPrev@|\"$nsNew@|" > \
      $appPath/deploy_temp_$curDate.json

  checkRes=`grep -n "$nsPrev" $appPath/deploy_temp_$curDate.json`
  if [ ${#checkRes} -eq 0 ] ; then
    echo "Namespace $nsPrev replace to $nsNew. Please, do manual recheck"
  else
    echo "Didn't all $nsPrev replace to $nsNew. Need manual check"
    echo -e "$checkRes"
  fi
fi


echo "All done"
  #      "refClass": "",
#      "itemsClass": "conclusion",

# for file in /home/likegeeks/*
# do
# if [ -d "$file" ]
# then
# echo "$file is a directory"
# elif [ -f "$file" ]
# then
# echo "$file is a file"
# fi
# done



#ACL n:::sakh-pm@
#c:::eventObjectBasic@sakh-pm:
#sys:::url:registry/sakh-pm@project/*:


# bi/navigation/object.json
#"namespace": "sakh-pm",
# "mine": "sakh-pm@eventsBase",


# dashboard/layouts/indicator.ejs
#redirect: 'registry/sakh-pm@indicatorValue.edit',
# url: 'registry/api/indicatorValueBasic@sakh-pm',
#node: 'sakh-pm@indicatorValue.edit',

# data
# "_class": "employee@sakh-pm",

