使用说明

# 功能：Archive Xcode项目，
# 使用说明
#       bash ./archive.sh -p Debug -t AdHoc
#       bash ./archive.sh -p Release -t AppStore
#
# 参数说明：
#
#         -p name   平台标识码 （Develop 连接开发服务器, Debug 连接测试服务器, Release 连接正式服务器,Prepublish 连接预发布服务器）
#		  -t name	需要编译的target的名称（AdHoc AppStore All）
#                   AdHoc 在目录archive和ipa中可以找到，
#                   AppStore 只在-p Release有效，默认的xcode的Organizer中找到,
#                   All 只在-p Release有效,同时在Organizer 和 archive 中各有一份)
#         -n name   项目名称，ArchiveConfig.plist 中key值
#         -l        打印出ArchiveConfig.plist
#         -v		设置版本号vesion （-v 4.2.0, 无 不修改 ）
#         -b		编译版本号build （-b 自动增加, -b 1.0.1 手动设置，无 不修改）
#         -e        编译完成后是否发送Email (Yes No) (暂未实现)
#         -s		编译完成后是否上传到svn (Yes No) (暂未实现)
#         -h		帮助
#         					
#        	    					