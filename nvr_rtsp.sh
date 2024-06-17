#!/bin/bash
script_dir=$(dirname "${0}")
script_config_file="${script_dir}/nvr_config.sh"
source "${script_config_file}"

#备注：
#  find /mnt/tfcard/alist/nvr/rec -type f -name "*.mp4" -delete
# 删除所有的视频
# 录制函数勿动
start_recording() {
    local project_name="${1}"
    local rtsp_url="${2}"
    if [ -z "${3}" ]; then
        local video_codec="copy"
    else
        local video_codec="${3}"
    fi
    if [ -z "${4}" ]; then
        local audio_codec="copy"
    else
        local audio_codec="${4}"
    fi
    local output_dir="${savePath}/${project_name}"
    local current_time=$(date +"%Y%m%d%H%M%S")
    local output_file="${output_dir}/${current_time}_%05d.mp4"

    # Create output directory if it does not exist
    mkdir -p "${output_dir}"
    echo "保存位置: ${output_file}"
    echo "视频地址：${rtsp_url}"
    echo "视频编码：${video_codec}"
    echo "音频编码：${audio_codec}"
    echo "项目名称：${project_name}"
    # Start recording with ffmpeg
    # 可用的："${ffmpeg}" -i "${rtsp_url}" -vcodec copy -acodec copy -map 0 -f segment -segment_time 300 -segment_format mp4 -reset_timestamps 1 "${output_file}"
    "${ffmpeg}" ${ffmpeg_hwaccels} -i "${rtsp_url}" -vcodec "${video_codec}" -acodec "${audio_codec}" -map 0 -f segment -segment_time 300 -segment_format mp4 -reset_timestamps 1 -rtsp_transport tcp -rw_timeout 5000000 -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 2 "${output_file}"
}



# Check if the directory exists
if [ ! -f "${checkFilePath}" ]; then
    echo "Error: Check file ${checkFilePath} does not exist."
    exit 1
fi
echo 'JL-NVR-RTSP-Recorder'
echo '/opt/nvr_rtsp.sh "项目名" "rtsp流地址"'
echo '/opt/nvr_rtsp.sh "项目名" "rtsp流地址" "视频编码"'
echo '/opt/nvr_rtsp.sh "项目名" "rtsp流地址" "视频编码" "音频编码"'
echo '编码模式默认copy'

if [ "$#" -eq 0 ]; then
    echo "没有传递参数，结束脚本。"
    exit 1
fi
#start_recording "${1}" "${2}" "${3}" "${4}"
start_recording $@