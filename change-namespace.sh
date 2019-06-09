#!/bin/bash

if [ $# -lt 3 ] ; then
  echo 'Usage: change-namespace.sh path orginal_namespace new_namespace'
  echo 'IONDV. Framework application change namespace with typically app folders.'
  echo
  echo 'Example:'
  echo '  ./change-namespace.sh ./applications/crm-new crm-prev crm-new'
  exit
fi

bashVer=`bash --version`
regexp='^GNU bash, version ([0-9]+)\.'
if [[ $bashVer =~ $regexp ]] ; then
  if [ ${BASH_REMATCH[1]} -lt 3 ] ; then
    echo "Bash version less 3. Need 3 or hignter" 
    exit
    fi
else 
  echo "Didn't check bash version. Need 3 or hignter"
fi

IFS_def=$IFS
curDate=`date +"%Y%m%d-%H-%M"`

while [ -n "$1" ]
do
  case "$1" in
    -q) quietMode=1; paramInfo="$paramInfo\nFound the quiet data option";;
    *)  if [[ ${1:0:1} == "-" ]] ; then 
        echo "$1 is not an option" 
        shift
        else 
          if ! [ $appPath ] ; then
            appPath=$1
          elif ! [ $nsPrev ] ; then
            nsPrev=$1
          elif ! [ $nsNew ] ; then
            nsNew=$1
          else
            echo "Exteneded parameters, ignored"
          fi
        fi;;
  esac
shift
done
if ! [ $quietMode ] ; then echo -e $paramInfo; fi


if ! [ -d $appPath ]; then
  echo "Path $appPath is wrong"
  exit
fi
echo $appPath

# Function for check the previous namespace and rename temporary filename to original file
# $1 - path to prepared filename 
function checkPrevNsAndRenameFile {
  local prepareFile=$1
  mv -f "$prepareFile-$curDate" $prepareFile
  local checkRes=`grep -n "$nsPrev" "$prepareFile"`
  if [ ${#checkRes} -ne 0 ] ; then
    echo "Didn't all $nsPrev replace to $nsNew in $prepareFile. Need manual check"
    grep -n "$nsPrev" "$prepareFile"
  fi
}

fileCount=0
filePrepareCount=0

# Function for change namespace in different instraction for different folder
# $1 - prepared app folder
# $2 - prepared file
function changeNamespace {
  local prepareFile=$2
  # Skip files
  # Specific folder prepare
  case "$1" in 
    'data')
      if [ ${prepareFile##*.} = 'zip' ] ; then
        echo "Skip: $prepareFile"
        return
      fi
      ;;
    * )
      ;;
  esac

  # Files prepare
  local checkRes=`grep -n "$nsPrev" "$prepareFile"`
  if [ ${#checkRes} -eq 0 ] ; then return; fi
  case "$1" in 
    'data')
      if [ ${prepareFile##*.} = 'json' ] ; then
        tempName=${prepareFile%@*}
        newDataFileName="${tempName%@*}@$nsNew@${prepareFile##*@}" 
        cat $prepareFile | \
          sed -r "s|@$nsPrev\"|@$nsNew\"|" > "$newDataFileName-$curDate"
        rm -f $prepareFile
        prepareFile=$newDataFileName
        local prepared=1
      fi
      ;;
    'geo')
      if [[ $prepareFile =~ "/geo/layers/" ]] ; then 
        if [ ${prepareFile##*.} = 'json' ] ; then 
          cat $prepareFile | \
            sed -r "s|geomap/render/$nsPrev|geomap/render/$nsNew|" |
            sed -r "s|@$nsPrev\"|@$nsNew\"|" |
            sed -r "s|/registry/$nsPrev@|/registry/$nsNew@|" |
            sed -r "s|@$nsPrev/|@$nsNew/|" > "$prepareFile-$curDate"
          local prepared=1
        fi
      elif [[ $prepareFile =~ "/geo/navigation/" ]] ; then 
        if [ ${prepareFile##*.} = 'json' ] ; then 
          cat $prepareFile | \
            sed -r "s|geomap/render/$nsPrev|geomap/render/$nsNew|" | \
            sed -r "s|@$nsPrev\"|@$nsNew\"|" > "$prepareFile-$curDate"
          local prepared=1
        fi
      fi
      ;;
    'meta')
      if [ ${prepareFile##*.} = 'json' ] ; then 
        cat $prepareFile | \
          sed -r "s|@$nsPrev,|@$nsNew,|" > "$prepareFile-$curDate"
        local prepared=1
      fi
      ;;
    'navigation')
      if [ ${prepareFile##*.} = 'json' ] ; then 
        cat $prepareFile |
          sed -r "s|@$nsPrev\"|@$nsNew\"|" > "$prepareFile-$curDate"
        local prepared=1
      fi
      ;;
    'templates')
      if [ ${prepareFile##*.} = 'ejs' ] ; then 
        cat $prepareFile | \
          sed -r "s|geomap/render/$nsPrev|geomap/render/$nsNew|" |
          sed -r "s|/report/public/$nsPrev@|/report/public/$nsNew@|" |
          sed -r "s|/registry/$nsPrev@|/registry/$nsNew@|" |
          sed -r "s|@$nsPrev/|@$nsNew/|" > "$prepareFile-$curDate"

        local prepared=1
      fi
      ;;

    * ) 
      if ! [ $quietMode ] ; then echo "$1 folder didn't have instruction to prepare. Skip $prepareFile"; fi      
      ;;
  esac
  if [ $prepared ] ; then
    if ! [ $quietMode ] ; then echo "Prepared: $prepareFile"; fi    
    filePrepareCount=$(( $filePrepareCount + 1 ))
    checkPrevNsAndRenameFile $prepareFile
  fi
}


# Recursive function for cnange namespasece in all files in folder
# $1 - prepared app folder
# $2 - folder for search files to prepare 
function changeNsInAllFilesInFolder {
  local filesPath=$2
  for file in $filesPath/* ; do
    if [ -f "$file" ] ; then
      fileCount=$(( $fileCount + 1 ))
      changeNamespace $1 $file
    elif [ -d "$file" ] ; then
      changeNsInAllFilesInFolder $1 $file
    fi
  done
}

if [ -d $appPath/export/item/$nsPrev ] ; then
  mv -f $appPath/export/item/$nsPrev $appPath/export/item/$nsNew
fi

for folder in $appPath/* ; do
  fileCount=0
  filePrepareCount=0
  if [ -d $folder ] ; then
    prepareFolder=${folder##*/}
    changeNsInAllFilesInFolder $prepareFolder $folder
    if ! [ $quietMode ] ; then echo "Prepared $filePrepareCount($fileCount)files in $folder"; fi          
  fi
done


#отдельной утилитой
#- deploy.json
#namespace: "ns"
#"namespaces": {
#"ns": ""
#}
#"[a-zA-Z\-_]@ns"
#"ns@[a-zA-Z\-_]"
#пути applications/ns

#      "refClass": "",
#      "itemsClass": "conclusion",


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


if [ -f "$appPath/package.json" ] ; then
  if ! [ $quietMode ] ; then echo "Process package.json"; fi  
  cat $appPath/package.json | \
    sed -r "s|\"name\"\s*:\s*\"$nsPrev\"|\"name\": \"$nsNew\"|" > \
       $appPath/package_temp_$curDate.json
  mv -f $appPath/package_temp_$curDate.json $appPath/package.json
fi

if [ -f "$appPath/deploy.json" ] ; then
  if ! [ $quietMode ] ; then echo "Process deploy.json"; fi  
  cat $appPath/deploy.json | \
    sed -r "s|\"applications/$nsPrev/|\"applications/$nsNew/|" | \
    sed -r "s|\"namespace\"\s*:\s*\"$nsPrev\"|\"namespace\": \"$nsNew\"|" | \
    sed -r "s|\"$nsPrev\"\s*:\s*\"|\"$nsNew\": \"|" | \
    sed -r "s|\"$nsPrev\"\s*:\s*\{|\"$nsNew\": \{|" | \
    sed -r "s|@$nsPrev\"|@$nsNew\"|" | \
    sed -r "s|\"$nsPrev@|\"$nsNew@|" > \
      $appPath/deploy_temp_$curDate.json

  mv -f $appPath/deploy_temp_$curDate.json $appPath/deploy.json
  checkRes=`grep -n "$nsPrev" $appPath/deploy.json`
  if ! [ ${#checkRes} -eq 0 ] ; then
    echo "Didn't all $nsPrev replace to $nsNew. Need manual check"
    grep -n "$nsPrev" $appPath/deploy.json
  fi
fi


