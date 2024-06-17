#!/bin/bash
script_dir=$(dirname "${0}")
script_config_file="${script_dir}/nvr_config.sh"
source "${script_config_file}"
################################
echo 'JL-NVR-URL-Check'
echo '用于检测视频流参数'
echo '/opt/nvr_rtsp.sh "视频流地址"'
if [ "$#" -eq 0 ]; then
    echo "没有传递参数，展示硬解信息并结束脚本。"
    "${ffmpeg}" -hwaccels
    exit 1
fi
echo '-----------------------'
echo 'h265 编码关键字 Video: hevc (Main)'
echo 'h264 编码关键字 Video: h264 (Main)'
echo '-----------------------'
"${ffmpeg}" -v info -hide_banner -i "${1}"