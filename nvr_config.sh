#!/bin/bash
#ffmpeg主程序
ffmpeg="/opt/ffmpeg/ffmpeg-7.0.1-arm64-static/ffmpeg"
#硬解参数
ffmpeg_hwaccels="-hwaccel auto"
#保存录像的目录
savePath="/mnt/tfcard/alist/nvr/rec"
#检测文件：touch一个空白文件用于检测目录是否正确，
#    主要用途是确认挂载是否成功，
#    用不到可用在录像目录touch空白文件填写
checkFilePath="/mnt/tfcard/tfcard_true"
#数据库文件
db_file="${savePath}/nvr.db"
#1Panel的supervisorctl参数
supervisorctl="/usr/bin/python3 /usr/bin/supervisorctl -c /etc/supervisor/supervisord.conf"