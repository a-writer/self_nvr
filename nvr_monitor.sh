#!/bin/bash
script_dir=$(dirname "${0}")
script_config_file="${script_dir}/nvr_config.sh"
source "${script_config_file}"

# 初始化变量，用于存储上一个新文件的名称
last_new_file=""
now_time=$(date +"%Y-%m-%d_%H-%M-%S")
writeNewFileTime() {
  local file="${1}"
  local time="${2}"
  local table="${3}"

  # 创建表的 SQL 语句
  create_table_sql="CREATE TABLE IF NOT EXISTS ${table} (
    file TEXT NOT NULL,
    time TEXT NOT NULL
  );"

  # 插入数据的 SQL 语句
  insert_sql="INSERT INTO ${table} (file, time) VALUES ('${file}', '${time}');"

  # 执行 SQL 语句
  sqlite3 "${db_file}" <<EOF
${create_table_sql}
${insert_sql}
EOF

  echo "数据已插入到 ${db_file} 中的 ${table} 表"
}
#检测文件并操作
check_last_new_file_open() {
    local file="${1}"
    local count=$(lsof -Fp "${file}" | wc -l)
    if [ "${count}" -ne 0 ]; then
        echo "文件被其他进程打开: ${file}"
        return
    fi
    echo "文件未被打开: ${file}"
    local file_name=$(basename "${file}")
    if [[ ! "${file_name}" =~ ^20[0-9]{12}_[0-9]+\.mp4$ ]]; then
        echo "文件名规则不匹配: ${file}"
        return
    fi
    # 获取文件的目录
    local file_path=$(dirname "${file}")
    # 获取文件的自带时间（录制启动时间）
    local file_name_datetime=$(echo "${file_name}" | cut -d'_' -f1)
    # 获取文件的创建时间并格式化
    # 更换数据库模式，文件参数经常有问题
    #     creation_time=$(stat -c '%W' "${file}")
    #     local formatted_time=$(date -d "@${creation_time}" +"%Y-%m-%d_%H-%M-%S")
    local sql_query="SELECT time FROM nvr_monitor WHERE file='${file}';"
    local sql_result=$(sqlite3 "${db_file}" "${sql_query}")
    if [ -n "${sql_result}" ]; then
        echo "缓存查询成功 ${sql_result}"
        local formatted_time=${sql_result}
    else
        echo "缓存查询失败"
        return
    fi
    local sql_delete="DELETE FROM nvr_monitor WHERE file='${file}';"
    sqlite3 "${db_file}" "${sql_delete}"
    if [ -n "${sql_result}" ]; then
        echo '缓存删除成功'
    else
        echo "缓存删除失败"
    fi
    
    local new_file_name="${file_path}/${file_name_datetime}_${formatted_time}.${file_name##*.}"
    mv "${file}" "${new_file_name}"
    writeNewFileTime "${new_file_name}" "${?}" "nvr_file"
    echo "${file}新文件名${new_file_name}"
}

#####################################################
echo 'JL-NVR-MonitorFile'
echo '本脚本用于视频文件改名'
echo '/opt/nvr_monitor.sh "项目名"'
if [ "$#" -eq 0 ]; then
    echo "没有传递参数，结束脚本。"
    exit 1
fi
directory_to_watch="${savePath}/${1}"
# 在目录中启动监控
mkdir -p "${directory_to_watch}"
echo "当前监控: ${directory_to_watch}"
inotifywait -m -r -e create --format '%w%f' "${directory_to_watch}" | while read new_file
do
    # 输出上一个新文件的名称
    if [ ! -z "${last_new_file}" ]; then
        echo "上一个文件: ${last_new_file}"
        check_last_new_file_open "${last_new_file}"
    fi

    # 更新上一个新文件的名称
    last_new_file="${new_file}"
    # 输出被创建的文件名
    echo "新文件等待处理: ${new_file}"
    now_time=$(date +"%Y-%m-%d_%H-%M-%S")
    writeNewFileTime "${new_file}" "${now_time}" "nvr_monitor"
done
sleep 1