https://trac.ffmpeg.org/wiki/CompilationGuide/Centos


编译ffmpeg
git clone https://github.com/FFmpeg/FFmpeg
cd FFmpeg
//用 git tag -l 查看支持的版本号
// git checkout <tag>  切换到想要的版本
./configure --prefix="$HOME/3rdparty" --disable-yasm --enable-pic --enable-shared --enable-avresample --extra-ldexeflags="-pie" --extra-ldflags="--Wl,-Bsymbolic"
// 安装路径按照自己想装的地方修改, 参考 https://trac.ffmpeg.org/wiki/CompilationGuide/Centos 修改需要的模块
make & make install

编译opencv
git clone https://github.com/opencv/opencv
// 修改 cmake 文件夹下的 OpenCVFindLibsVideo.cmake 文件， 将 libavcodec.a , libavformat.a,  libavutil.a , libswscale.a, 和 libavresample.a 修改成 .so
// 似乎在redhat上opencv config 的时候默认链接ffmpeg的静态库。 链接静态库的时候会出现 “ Relocation R_X86_64_PC32 against symbol ff_M24A can not be
used when making a shared object;”
的错误。

cd opencv
mkdir build
cmake .. -DWITH_FFMPEG=ON
ccmake .  // 修改各类需要的选项
make & make install

