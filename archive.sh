#!/bin/bash

#-------------------
# 功能：Archive Xcode项目，
# 使用说明
#       bash ./archive.sh -p Debug -t AdHoc
#       bash ./archive.sh -p Release -t AppStore
#
# 参数说明：
#
#         -p Name   平台标识码 （Develop 连接开发服务器, Debug 连接测试服务器, Release 连接正式服务器,Prepublish 连接预发布服务器）
#		  -t NAME	需要编译的target的名称（AdHoc AppStore All）
#                   AdHoc 在目录archive和ipa中可以找到，
#                   AppStore 只在-p Release有效，默认的xcode的Organizer中找到,
#                   All 只在-p Release有效,同时在Organizer 和 archive 中各有一份)
#         -v		设置版本号vesion （-v 4.2.0, 无 不修改 ）
#         -b		编译版本号build （-b 自动增加, -b 1.0.1 手动设置，无 不修改）
#         -e        编译完成后是否发送Email (Yes No) (暂未实现)
#         -s		编译完成后是否上传到svn (Yes No) (暂未实现)
#         -h		帮助
#         					
#        	
# 作者：iNaiton
#-------------------


if [ $# -lt 1 ];then
    echo "enter bash ./archive.sh -h  get some help"
    echo ""
    exit 2
fi

build_target=AdHoc
build_platform=Release
build_opsendEmial=false
build_opupdateSvn=false

build_setversion=false
build_setversion_value=""

build_setbuildversion=false
build_setbuildversion_auto=false
build_setbuildversion_value=""

param_pattern=":p:t:v:b:e:s:h"
while getopts $param_pattern optname
do
    case "$optname" in
    "p")
        if [ ${OPTARG} != "Develop" ] && [ ${OPTARG} != "Debug" ] && [ ${OPTARG} != "Release" ] && [ ${OPTARG} != "Prepublish" ];then
            echo "invalid platform parameter of $OPTARG"
            echo ""
            exit 2
        fi
        build_platform=$OPTARG
        echo "platform parameter is $build_platform"
        echo ""
        ;;
    "t")
    	if [ ${OPTARG} != "AdHoc" ] && [ ${OPTARG} != "AppStore" ] && [ ${OPTARG} != "All" ];then
            echo "invalid target parameter of $OPTARG"
            echo ""
            exit 2
        fi
        build_target=$OPTARG
        echo "target parameter is $build_target"
        echo ""
        ;;
    "v")
        reg='^([1-9]{1}.){2}[0-9]{1}$'
        if [[ $OPTARG =~ $reg ]];then
            build_setversion=true
            build_setversion_value=$OPTARG
        else
            echo "invalid version parameter of $OPTARG"
            exit 2
        fi
        echo "version parameter is $build_setversion_value"
        echo ""
        ;;
    "b")
        if [ ${OPTARG} = "" ];then
            build_setbuildversion=true
            build_setbuildversion_auto=true
        else
            reg='^([1-9]{1,2}.){2}[0-9]{1}$'
            if [[ $OPTARG =~ $reg ]];then
                build_setbuildversion=true
                build_setbuildversion_auto=false
                build_setbuildversion_value=$OPTARG
            else
                echo "invalid version parameter of $OPTARG"
                exit 2
            fi
        fi

        if [ $build_setbuildversion_auto = true ];then
            echo "bulidversion parameter is set auto to increase"
            echo ""
        else
            if [ $build_setbuildversion = true ];then
                echo "bulidversion parameter is $build_setbuildversion_value"
                echo ""
            fi
        fi
        ;;
    "e")
    	echo "Error! Unknown e"
        echo ""
        exit 2
        ;;
    "s")
    	if [ ${OPTARG} = "Yes" ];then
            build_opupdateSvn=true
        elif [ ${OPTARG} = "No" ];then
            build_opupdateSvn=false
        fi
    	echo "updateSvn parameter is $build_opupdateSvn"
        echo ""
        ;;
    "h")
        echo "*************** archive.sh help ***************"
        echo ""
        echo "@brife"
        echo " 家校帮打包脚本，目的解放复杂的打包流程"
        echo ""
        echo "@note"
        echo " bash ./archive.sh -p Debug -t AdHoc"
        echo " bash ./archive.sh -p Release -t AppStore"
        echo ""
        echo "@param"
        echo " -p           服务器平台连接标识码"
        echo "               Develop 连接开发服务器"
        echo "               Debug 连接测试服务器"
        echo "               Prepublish 连接预发布服务器"
        echo "               Release 连接正式服务器"
        echo ""
        echo " -t           需要编译的target的名称"
        echo "               AdHoc 输出测试包"
        echo "               AppStore  -p Release有效"
        echo "               All -p Release有效"
        echo ""
        echo " -v           设置版本号vesion"
        echo "               -v 4.2.0 ，手动修改版本号"
        echo "               无 不修改"
        echo ""
        echo " -b           编译版本号build"
        echo "               -b 自动增加"
        echo "               -b 1.0.1 手动设置"
        echo "               无 不修改"
        echo ""
        echo " -e           编译完成后是否发送Email (Yes No)"
        echo ""
        echo " -s           编译完成后是否上传到svn (Yes No)"
        echo ""
        echo " -h           帮助"
        echo ""
        echo "**********************************************"
        exit 2
        ;;
    *)
        echo "Error! Unknown error while processing options"
        echo ""
        exit 2
        ;;
    esac
done

need_export_adhoc=true
need_copy_archive_to_organizer=false
#禁止AppStore版编译 Develop,Debug,Prepublish平台的包
if  [ "$build_platform" != "Release" ];then

    if [ "$build_target" = "AppStore" ] || [ "$build_target" = "All" ];then
        echo "--- Error ----"
        echo ""
        echo "--- AppStore Not Allow Link No Release Service ---"
        echo ""
        exit
    else
        need_export_adhoc=true
        need_copy_archive_to_organizer=false
    fi
else
    if [ "$build_target" = "AdHoc" ];then

        need_export_adhoc=true
        need_copy_archive_to_organizer=false

    elif [ "$build_target" = "AppStore" ];then

        need_export_adhoc=false
        need_copy_archive_to_organizer=true

    elif [ "$build_target" = "All" ];then

        need_export_adhoc=true
        need_copy_archive_to_organizer=true

    else
        echo "--- Error ----"
        echo ""
        echo "invalid build_target parameter of $build_target"
        echo ""
        exit

    fi
fi

# 读取ArchiveConfig.plist
echo "--- begin read ArchiveConfig.plist"
echo ""
archiveShellPath=$(pwd)
archiveConfigPath=${archiveShellPath}/ArchiveConfig.plist
project_path=$(/usr/libexec/PlistBuddy -c "print project_path" ${archiveConfigPath})
app_info_path=$(/usr/libexec/PlistBuddy -c "print app_info_path" ${archiveConfigPath})

codeSignIdentity=$(/usr/libexec/PlistBuddy -c "print codeSignIdentity" ${archiveConfigPath})
adHocProvisioningProfile=$(/usr/libexec/PlistBuddy -c "print adHocProvisioningProfile" ${archiveConfigPath})
appStoreProvisioningProfile=$(/usr/libexec/PlistBuddy -c "print appStoreProvisioningProfile" ${archiveConfigPath})
project_name=$(/usr/libexec/PlistBuddy -c "print project_name" ${archiveConfigPath})
project_type=$(/usr/libexec/PlistBuddy -c "print project_type" ${archiveConfigPath})
scheme=$(/usr/libexec/PlistBuddy -c "print scheme" ${archiveConfigPath})

ipconfig_path=$(/usr/libexec/PlistBuddy -c "print ipconfig_path" ${archiveConfigPath})

echo "--- archiveShellPath is $archiveShellPath"
echo ""
echo "--- xcode_Info_Plist_path is $app_info_path"
echo ""
echo "--- project_path is $project_path"
echo ""
echo "--- end read ArchiveConfig.plist"
echo ""

# 修改xcode info.plist
bundleName=$(/usr/libexec/PlistBuddy -c "print CFBundleName" ${app_info_path})
bundleDisPlayName=$(/usr/libexec/PlistBuddy -c "print CFBundleDisplayName" ${app_info_path})
modify_plist=false

echo "--- begin modify bundleDisPlayName in $app_info_path"
echo ""

if [ "$build_platform" = "Develop" ];then
	modify_plist=true

	newBundleDisPlayName="$bundleName(开发)"
	/usr/libexec/PlistBuddy -c "set CFBundleDisplayName $newBundleDisPlayName" ${app_info_path}
	bundleDisPlayName=$(/usr/libexec/PlistBuddy -c "print CFBundleDisplayName" ${app_info_path})

elif [ "$build_platform" = "Debug" ];then
    modify_plist=true

    newBundleDisPlayName="$bundleName(测试)"
    /usr/libexec/PlistBuddy -c "set CFBundleDisplayName $newBundleDisPlayName" ${app_info_path}
    bundleDisPlayName=$(/usr/libexec/PlistBuddy -c "print CFBundleDisplayName" ${app_info_path})

elif [ "$build_platform" = "Prepublish" ];then
    modify_plist=true

    newBundleDisPlayName="$bundleName(预发布)"
    /usr/libexec/PlistBuddy -c "set CFBundleDisplayName $newBundleDisPlayName" ${app_info_path}
    bundleDisPlayName=$(/usr/libexec/PlistBuddy -c "print CFBundleDisplayName" ${app_info_path})

elif [ "$build_platform" = "Release" ];then
	modify_plist=true

	/usr/libexec/PlistBuddy -c "set CFBundleDisplayName $bundleName" ${app_info_path}
	bundleDisPlayName=$(/usr/libexec/PlistBuddy -c "print CFBundleDisplayName" ${app_info_path})

fi

echo "  ---- modify bundleDisPlayName success"
echo "  ---- new bundleDisPlayName is $bundleDisPlayName"
echo ""
echo "--- end modify bundleDisPlayName in $app_info_path"
echo ""

# 修改版本号
if [ $build_setversion = true ];then
    echo "--- begin modify version in $app_info_path"
    echo ""

    oldShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" ${app_info_path})
    /usr/libexec/PlistBuddy -c "set CFBundleShortVersionString $build_setversion_value" ${app_info_path}

    echo "  --- modify version $oldShortVersion to $build_setversion_value"
    echo ""

    echo "--- end modify version in $app_info_path"
    echo ""
fi

# 自动增加编译版本号
if [ $build_setbuildversion_auto = true ];then

    echo "--- begin auto incrase build version "
    echo ""

    oldBulidVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" ${app_info_path})
#将4.2.5格式转化成425格式
    versionStrArr=(${oldBulidVersion//./ })
    versionInt=""
    for i in ${versionStrArr[@]}
    do
        versionInt="$versionInt$i"
    done

#自动+1
    versionInt=$(expr $versionInt + 1)
    versionIntLength=${#versionInt}

#将425格式转换成4.2.5
    index=$(expr $versionIntLength - 2)
    result="${versionInt:0:$index}.${versionInt:$index:1}"
    index=$(expr $versionIntLength - 1)
    result="$result.${versionInt:$index:1}"

    build_setbuildversion_value=$result

    echo "  --- bulid version ¥oldBulidVersion auto increace to $build_setbuildversion_value"
    echo ""

    echo "--- end auto incrase build version "
    echo ""

fi

# 修改编译版本号
if [ $build_setbuildversion = true ];then
    echo "--- begin modify build version in $app_info_path"
    echo ""

    oldBulidVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" ${app_info_path})
    /usr/libexec/PlistBuddy -c "set CFBundleVersion $build_setbuildversion_value" ${app_info_path}

    echo "  --- modify bulid version $oldBulidVersion to $build_setbuildversion_value"
    echo ""

    echo "--- end modify build version in $app_info_path"
    echo ""
fi

# 修改代码中ipconfig

echo "--- begin modify server_link_flag in $ipconfig_path"
echo ""
if [ "$build_platform" = "Develop" ];then

sed -i '' "s/#define SERVICE_LINK_FLAG .*/#define SERVICE_LINK_FLAG 0/" ${ipconfig_path}

elif [ "$build_platform" = "Debug" ];then

sed -i '' "s/#define SERVICE_LINK_FLAG .*/#define SERVICE_LINK_FLAG 1/" ${ipconfig_path}

elif [ "$build_platform" = "Release" ];then

sed -i '' "s/#define SERVICE_LINK_FLAG .*/#define SERVICE_LINK_FLAG 2/" ${ipconfig_path}

elif [ "$build_platform" = "Prepublish" ];then

sed -i '' "s/#define SERVICE_LINK_FLAG .*/#define SERVICE_LINK_FLAG 3/" ${ipconfig_path}

fi

grep -n '#define SERVICE_LINK_FLAG' ${ipconfig_path}
echo "  --- App Link $build_platform Service ---"

echo ""
echo "--- end modify server_link_flag in $ipconfig_path"
echo ""

# 创建archive文件夹

echo "--- begin remove and create archive dir in $(pwd)"
echo ""

if [ -d ./archive ];then
	rm -rf archive
fi
mkdir archive

echo "--- end remove and create archive dir in $(pwd)"
echo ""

echo "--- begin create ipa dir in $(pwd)"
echo ""

# 创建ipa文件夹
if [ -d ./ipa ];then
#	rm -rf ipa
    echo "  --- ipa dir exist in $(pwd)"
    echo ""
elif [ ! -d ./ipa ];then
    mkdir ipa

    echo "  --- create ipa dir in $(pwd)"
    echo ""
fi

echo "--- end create ipa dir in $(pwd)"
echo ""

cd ipa

# 创建年月日文件夹
ymdDir=`date '+%Y-%m-%d'`

echo "--- begin create sub dir in $(pwd)"
echo ""

if [ -d ./${ymdDir} ];then
#	rm -rf ipa
    echo "  --- ${ymdDir} exist in $(pwd)"
    echo ""
elif [ ! -d ./${ymdDir} ];then
    mkdir ${ymdDir}
    echo "  --- create ${ymdDir} in $(pwd)"
    echo ""
fi

echo "--- end create sub dir in $(pwd)"
echo ""

# 清理构建目录 [Product -> Clean]
echo "----------------  begin clean of commond ---------------"
echo ""
#log_path=$(pwd)
#configuration="Release"
#xcodebuild clean -configuration "$configuration" -alltargets >> $log_path

cd $project_path
configuration="Release"
xcodebuild clean -configuration "$configuration" -alltargets
echo ""
echo "----------------  end clean of commond -----------------"
echo ""

# 编译打包成Archive [Product -> Archive]

#取版本号
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" ${app_info_path})
#取build值
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" ${app_info_path})
#当前时间
curDate=`date '+%Y-%m-%d_%H-%M-%S'`
#xcode
xcode_organizer_archive_date=`date '+%y-%m-%d %p%-l.%M'`
#archive名称
archive_name="${scheme}_${bundleShortVersion}_${curDate}_${build_platform}"
echo "-- archive name $archive_name "
echo ""

#开始执行archive命令
echo "----------------  begin archive of commond ---------------"
echo ""

archivePath=${archiveShellPath}/archive/${archive_name}.xcarchive
if [ "$project_type" = "workspace" ];then

    echo "  --- archive $project_name.xcworkspace->$scheme ---"
    echo ""

    xcodebuild archive -workspace "$project_name.xcworkspace" -scheme "$scheme" -configuration "$configuration" -archivePath "$archivePath" CODE_SIGN_IDENTITY="$codeSignIdentity" PROVISIONING_PROFILE="$appStoreProvisioningProfile"
else
    echo "  --- archive $project_name.xcodeproj->$scheme ---"
    echo ""

    xcodebuild archive -project "$project_name.xcodeproj" -scheme "$scheme" -configuration "$configuration" -archivePath "$archivePath" CODE_SIGN_IDENTITY="$codeSignIdentity" PROVISIONING_PROFILE="$appStoreProvisioningProfile"
fi

echo "----------------  end archive of commond ---------------"
echo ""


# 导出Archive
if [ $need_export_adhoc = true ];then

    echo "----------------  begin export archive to adhoc of commond ---------------"
    echo ""

    #IPA名称
    ipa_name="${archive_name}_AdHoc"
    echo $ipa_name
    echo ""

    echo "  --- begin exportIpa of commond"
    echo ""

    exportPath=${archiveShellPath}/ipa/${ymdDir}
    exportOptionsPlist=${archiveShellPath}/AdHocExportOptions.plist
    xcodebuild -exportArchive -archivePath "$archivePath" -exportOptionsPlist "$exportOptionsPlist" -exportPath "$exportPath"

    echo "  --- end exportIpa of commond"
    echo ""

    # 修改ipa名称
    echo "  --- begin rename ipa"
    echo ""

    cd $exportPath
    mv -v $scheme.ipa $ipa_name.ipa

    echo "  --- end rename ipa"
    echo ""

    echo "----------------  end export archive to adhoc of commond ---------------"
    echo ""

fi

# 将archive导入到xcode organizer中去
if [ $need_copy_archive_to_organizer = true ];then
	
	echo "----------------  begin copy archive to organizer of commond ---------------"
	echo ""

    #进入xcode的Archives目录
    cd ~/Library/Developer/Xcode/Archives
    #在xcode的Archives目录下创建年月日文件夹
    xcodeArchivesSubYMDDir=`date '+%Y-%m-%d'`

    echo "  --- begin create sub dir in $(pwd)"
    echo ""

    if [ -d ./${xcodeArchivesSubYMDDir} ];then
        #   rm -rf ${xcodeArchivesSubYMDDir}
        echo "--- ${xcodeArchivesSubYMDDir} exist in $(pwd)"
        echo ""
    elif [ ! -d ./${xcodeArchivesSubYMDDir} ];then
        mkdir ${xcodeArchivesSubYMDDir}
        echo "--- create ${xcodeArchivesSubYMDDir} in $(pwd)"
        echo ""
    fi

    cd ${xcodeArchivesSubYMDDir}

    echo "  --- begin copy ${archivePath} to $(pwd)"
    echo ""

    cp -r $archivePath "$pwd"

    echo "  --- end copy ${archivePath} to $(pwd)"
    echo ""

    # 修改ipa名称
    echo "  --- begin rename ${archive_name}.xcarchive in $(pwd)"
    echo ""

    archiveNewName="${scheme} ${xcode_organizer_archive_date}.xcarchive"

    mv -v "${archive_name}.xcarchive" "$archiveNewName"

    echo "  --- end rename ${archive_name}.xcarchive in $(pwd)"
    echo ""

	echo "----------------  end copy archive to organizer of commond ---------------"
	echo ""
	
fi

# 清楚build文件夹
echo "--- begin clear build"
echo ""

cd $project_path
if [ -d ./build ];then
    rm -rf build
fi

echo "--- end clear build"
echo ""

# 打包完成后还原xcode info.plist
if [ $modify_plist = true ];then
    cd $archiveShellPath
    echo "--- begin modify bundleDisPlayName in $app_info_path"
    echo ""
    /usr/libexec/PlistBuddy -c "set CFBundleDisplayName $bundleName" ${app_info_path}
    bundleDisPlayName=$(/usr/libexec/PlistBuddy -c "print CFBundleDisplayName" ${app_info_path})
    echo "---- modify bundleDisPlayName success"
    echo "---- new bundleDisPlayName is $bundleDisPlayName"
    echo ""
    echo "--- end modify bundleDisPlayName in $app_info_path"
    echo ""
fi

# 上传到svn
if [ $build_opupdateSvn = true ] && [ "$build_target" = "AdHoc" ];then
	echo "--- begin upload ipa to svn"
	echo ""
		
	svn_work_path=$(/usr/libexec/PlistBuddy -c "print svn_work_path" ${archiveConfigPath})
	
	cd $exportPath
	cp $ipa_name.ipa $svn_work_path
	
#	添加ipa到svn，目前未实现
#	cd $svn_work_path
#	TO_ADD_FILE=(`svn status $svn_work_path | grep ^? | awk '{printf "%s ", $ipa_name.ipa}'`)
#	if [ "$TO_ADD_FILE" != "" ];then
#			svn add ${TO_ADD_FILE[*]}
#	fi
#	svn commit -m "安装包"
		
	echo "--- end upload ipa to svn"
	echo ""
fi

