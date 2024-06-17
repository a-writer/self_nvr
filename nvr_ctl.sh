#!/bin/bash
script_dir=$(dirname "${0}")
script_config_file="${script_dir}/nvr_config.sh"
source "${script_config_file}"

ctl_status() {
    ${supervisorctl} status
}
ctl_command() {
    # 以1Panel为主
    local confName="${1}"
    local command="${2}"
    local res=$(${supervisorctl} status | grep "^${confName}:${confName}_" | awk '{print $1}')
    local count=$(echo ${res}|wc -l)
    if [ -z "$res" ]; then #修复匹配不到也为1
        count=0
    else
        count=$(echo ${res} | wc -l)
    fi
    if [ "${count}" -eq 0 ]; then
        echo "未找到配置: ${confName}"
        return
    fi
    for item in ${res}; do
        echo "====${item}===="
        ${supervisorctl} ${command} "${item}"
    done
}

echo 'JL-NVR-1Panel-Ctl'
if [ "$#" -eq 0 ]; then
    echo '/opt/nvr_ctl.sh [正常supervisorctl参数]'
    echo '/opt/nvr_ctl.sh delrec 删除所有视频'
    echo '/opt/nvr_ctl.sh kill   结束所有ffmpeg进程'
    echo '没有传递参数，结束脚本。'
    exit 1
fi

if [ "${#}" -eq 1 ]; then
    if [ "${1}" = "delrec" ]; then
        echo "特殊指令:删除所有视频"
        find "${savePath}" -type f -name "*.mp4" -delete
        exit 0
    fi
    if [ "${1}" = "kill" ]; then
        echo "特殊指令:结束ffmpeg进程"
        killall ffmpeg
        exit 0
    fi
fi

ctl_command "nvr_monitor_5" $@
ctl_command "nvr_monitor_198" $@
ctl_command "nvr_monitor_224" $@
ctl_command "nvr_rtsp_5" $@
ctl_command "nvr_rtsp_198" $@
ctl_command "nvr_rtsp_224" $@