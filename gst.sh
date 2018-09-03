gst-launch-1.0 rpicamsrc ! h264parse ! 'video/x-h264,width=800,height=600' \
    ! avdec_h264 ! jpegenc quality=50 ! filesink location=output.jpg
