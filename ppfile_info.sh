#!/bin/bash


shellpath="$(pwd)"
echo "--------   shell in $shellpath"

cd ~/Documents
echo "--------   cd in $(pwd)"
if [ ! -d ./tempppfile ];then
   touch tempppfile
   echo "  ------   create temppfile"
fi

plistpath="$(pwd)/tempppfile"

cd ~/Library/MobileDevice/Provisioning\ Profiles
echo "--------   cd in $(pwd)"

echo "--------   begin read files"
echo ""
for file in *
do
if test -f $file
then
echo "  ------   $file"
ppfilecontent=$(security cms -D -i $file)
echo "$ppfilecontent" &>"${plistpath}"
name=$(/usr/libexec/PlistBuddy -c "print Name" ${plistpath})
echo "    ----   name : $name"
echo ""



#echo $file 是文件
fi
#if test -d $file
#then
#echo $file 是目录
#fi
done

echo "-----   end read files"

cd "${shellpath}"
echo "-----   cd in $(pwd)"
echo ""




