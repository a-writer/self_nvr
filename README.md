# self_nvr

## 一个自用的nvr录制脚本，写的很乱容易脏您眼睛，极端针对性不建议用。

闲置盒子和录像比较多，不想NVR录像机也多，便与chatgpt合作编写了这个项目。
在测试环境中可用，主要自用，在不进行转码和只转码音频到aac的情况下占用不大。

### 测试环境：
- 硬件：R3300-L
- 系统：armbian 6.1.66-ophub
- 软件：
  - 1Panel v1.8.5 (主要是进程守护supervisor)
  - sqlite3 (apt-get install)
  - inotify-tools (apt install, 用于监控文件创建)
  - (可能还有但是我不记得)

### 程序目录：
**nvr_check.sh**
  - 用于检测当前系统硬解码器和视频流（即RTSP地址，下同）信息。

**nvr_config.sh**
  - 配置文件，包括不限于ffmpeg地址、更多ffmpeg参数(ffmpeg_hwaccels)、录像文件目录等

**nvr_ctl.sh**
  - supervisor控制

**nvr_monitor.sh**
  - 监听录制文件、重命名、记入数据库

**nvr_rtsp.sh**
  - 录制主程序

### 备忘例子：
- 脚本安装目录`/opt/`
- 录制目录为`/data/`
- 录制项目为`5`
- RTSP取流地址：`rtsp://192.168.1.5/264live`

0. 编辑nvr_config.sh
   根据正确信息填写
1. 在1Panel设置启动项目
   - 名字：`nvr_monitor_5`
   - 进程：`/opt/nvr_monitor.sh "5"`
2. 在1Panel设置启动项目
   - 名字：`nvr_rtsp_5`
   - 进程：`/opt/nvr_rtsp.sh "5" "rtsp://192.168.1.5/264live"`
   - 如果仅视频转码h.265可更改`/opt/nvr_rtsp.sh "5" "rtsp://192.168.1.5/264live" "hevc"`
   - 如果仅音频转码aac可更改`/opt/nvr_rtsp.sh "5" "rtsp://192.168.1.5/264live" "copy" "aac"`
3. 编辑nvr_ctl.sh
   - 最下面按照`ctl_command "nvr_monitor_5" $@`格式填写
   - 正常来说1Panel添加完就已经启动，就不需要其他操作。
4. 视频信息
   - 视频会位于`/data/<项目名称>`即例子中的`/data/5`
   - 在正常录制的情况下
   - `/data/5/<年月日时分秒>_<5位数字>.mp4`是正在录制的视频，不可观看。
   - `/data/5/<年月日时分秒>_<年-月-日>_<时-分-秒>.mp4`是录制结束的可观看视频。
   - 可观看视频如：`20240617111157_2024-06-17_11-11-59.mp4`，解读方式是20240617111157为批次(批次变化是录制有过中断)，2024-06-17_11-11-59为视频的开始录制时间，时长5分钟(硬编码固定)。

### tips:
- 经过测试发现有时候supervisor退出脚本后仍然残留一些ffmpeg进程，可用`/opt/nvr_rtsp.sh kill`结束
- nvr_ctl.sh其实可去遍历和生成1Panel配置文件，更加好用，但是懒。
- nvr_rtsp.sh写死了分段时间，直接改`-segment_time 300`即可。
- 自测支持萤石、小看智能。

### 萤石：
- 本地工具-局域网设备-开启RTSP
- `rtsp://admin:<标签中的验证码>@<IP>:554/h264/ch1/main/av_stream`
- ch1可改通道，实际测试地址中h264实际作用不大，设备支持h.265会显示h.265视频。
- 另发现设置固定码率最高分辨率，设备有的时候也会以1080P输出。
