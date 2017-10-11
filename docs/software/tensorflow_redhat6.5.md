# Compile tensorflow shared libs for redhat6.5

##Install java 8
* Download [jdk-8u141-linux-x64.rpm](http://www.oracle.com/technetwork/java/javase/downloads/java-archive-javase8-2177648.html)
* run the following command to install java, for more details, please visit [Java installation](https://docs.oracle.com/javase/8/docs/technotes/guides/install/linux_jdk.html)
   ``` 
   rpm -ivh jdk-8u141-linux-x64.rpm 

   ``` 
  
* run to select the java version you need
  ``` 
  alternatives --config java 
  ``` 
  

## Build python from source with system default gcc
* Download [python source code](https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tar.xz), Here I choose python 2.7.14, you can go to the python web page to download the version you need.

* Go to python source directory and run
```
install_dir="$HOME"/"python27" ## choose the place you want to install python27
mkdir -p "$install_dir"
mkdir build
cd build
../configure --prefix="$install_dir" --enable-shared --enable-static
make -j4 && make install

```
* Add python to system environment
```
echo 'export LD_LIBRARY_PATH="$install_dir"/lib:$LD_LIBRARY_PATH >> "$HOME"/".bashrc'
echo -e "\n"
echo 'export LD_LIBRARY_PATH="$install_dir"/lib64:$LD_LIBRARY_PATH >> "$HOME"/".bashrc'
echo -e "\n"
echo 'export PATH="$install_dir"/bin:$PATH >> "python27.env'
echo -e "\n"
echo 'export C_INCLUDE_PATH="$install_dir"/include:$C_INCLUDE_PATH >> "$HOME"/".bashrc'
echo -e "\n"
echo 'export CPLUS_INCLUDE_PATH="$install_dir"/include:$CPLUS_INCLUDE_PATH >> "$HOME"/".bashrc'
source "$HOME"/.bashrc

```

## Build gcc from source with system default gcc
* Download [gcc 4.8.2 ](ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.8.2/gcc-4.8.2.tar.gz), [mpfr 2.4.2](ftp://gcc.gnu.org/pub/gcc/infrastructure/mpfr-2.4.2.tar.bz2), [gmp 4.3.2](ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-4.3.2.tar.bz2), [mpc 0.8.1](ftp://gcc.gnu.org/pub/gcc/infrastructure/mpc-0.8.1.tar.gz). You can choose different versions as you want from [gcc gnu org](ftp://gcc.gnu.org/pub/gcc).

* Uncompressed the four tarballs, and move mpfr, gmp and mpc into gcc directory, drop the version numbers, please. 
  The structure should be like this:
```
|--gcc
     |--- mpfr
     |--- gmp
     |--- mpc
``` 

* Run the following command to unset some system variables. This is not necessary sometimes, but some weird problems may happen.
```
 unset LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE

```


* cd into gcc source directory and run the following command to compile and install gcc
```
mkdir -p build
cd build
../configure --enable-checking=release \
             --disable-multilib \
             --enable-languages=c,c++ \
             --prefix=/home/xiaochunlin/3rdparty/gcc \
             
make -j8
make install

```
change --prefix to where you want gcc to be installed. A local directory is highly recommended.

* Add gcc installation directory to system search path. Add the following lines to ~/.bashrc. Please change the path accordingly. run source ~/.bashrc to refresh system variables.
```
export LD_LIBRARY_PATH=/home/xiaochunlin/3rdparty/gcc/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/home/xiaochunlin/3rdparty/gcc/lib64:$LD_LIBRARY_PATH
export PATH=/home/xiaochunlin/3rdparty/gcc/bin:$PATH
export C_INCLUDE_PATH=/home/xiaochunlin/3rdparty/gcc/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=/home/xiaochunlin/3rdparty/gcc/include:$CPLUS_INCLUDE_PATH

```

## Build bazel from source with compiled gcc installed locally

* Install Java 8

* Download [Bazel release source code](https://github.com/bazelbuild/bazel/releases/download/0.5.4/bazel-0.5.4-dist.zip), visit [release page](https://github.com/bazelbuild/bazel/releases) to download a different version.

* To let bazel to use a locally installed gcc, you need to change the value of "use_default_shell_env" from "False" to "True" in /src/main/java/com/google/devtools/build/lib/rules/SkylarkRuleImplementationFunctions.java. It was in line 165 for bazel 0.5.4. (If you do not change this line, GLIBCXX_xxxx not found error may occur when using bazel to compile tensorflow latter on).


* cd into the root of bazel source code directory and run 
```
./compile.sh
```
when finishing compiling, the bazel excitable binary will be in the directory "output", copy it to where you want it to be installed. visit [bazel installation page](https://docs.bazel.build/versions/master/install.html#installing-menu) for more information. 

Errors I had:

* AttributeError: ZipFile instance has no attribute '__exit__'
Solution: This error was caused by the outdated ZipFile python packages. just install a new version of zipfile using pip, see [reference](https://groups.google.com/forum/#!topic/bazel-discuss/4agXK1VpfkM) 
* GLIBCXX_xxxx not found
solution : change "use_default_shell_env" value from False to True.


## Build tensorflow from source with compiled gcc installed locally

* Download tensorflow source code and  checkout v1.3.1
```
git clone https://github.com/tensorflow/tensorflow
git checkout v1.3.1

```
* run config and select options accordingly
```
./configure

```

* To build, run
```
bazel build -c opt //tensorflow:libtensorflow_cc.so

```

* To install to a local directory, run
```
prefix="$HOME"/"3rdparty/tensorflow"
mkdir -p "$prefix"
mkdir -p "$prefix"/"lib"
mkdir -p "$prefix"/"include"
mkdir -p "$prefix"/"include"/"third_party"

cp -f  bazel-bin/tensorflow/libtensorflow_cc.so "$prefix"/"lib"
cp -rf tensorflow "$prefix"/"include"
cp -rf bazel-genfiles/tensorflow "$prefix"/"include"
cp -rf bazel-tensorflow/external/protobuf/src/google "$prefix"/"include"
cp -rf third_party/eigen3 "$prefix"/"include/third_party"

```

* To link libtensorflow_cc.so in your gcc program, you need to have eigen3 installed. Download [eigen3](wget http://bitbucket.org/eigen/eigen/get/3.3.4.tar.gz) and install it locally.

Tensorflow links protobuf statically, it may happen that you use another version of protobuf somewhere else, it may contradict. So you may need to compile tensorflow with a specific version of protobuf. Following are instructions:

* After running configure, fetch dependencies before build
```
bazel fetch //tensorflow:libtensorflow_cc.so

```

* Download protobuf source code and checkout to the version you want. I use 3.0.0 as an example.
```
git clone https://github.com/google/protobuf
git checkout 3.0.x

```

* replace tensorflow downloaded protobuf with the one you need. tensorflow downloaded protobuf is located in bazel-tensorflow/external. If you have not build tensorflow yet, go ~/.cache/bazel/XXXXX/XXhashcodeX/external. copy "protobuf.bzl" from tensorflow downloaded protobuf to the one you downloaded.

* Some of the protobuf API may changed. You can try to build first and then change code accordingly. Here I used protobuf 3.0.0, I only need to change tensorflow/core/grappler/costs/op_level_cost_estimator.cc:185:32 from:
```
return {strides[0], strides[1], strides[2], strides[3]};
```
to 
```
return {strides[0] -> strides.Get(0), strides[1] -> strides.Get(1), strides[2] -> strides.Get(2), strides[3] -> strides.Get(3) };
```


Error you may have:
*_pywrap_tensorflow_internal.so: undefined symbol: clock_gettime
solution: modify tensorflow/tensorflow/tensorflow.bzl line 975 or search tf_extension_linkopts(): change "return []" to 'return ["-lrt"] ' see [ref]( https://github.com/tensorflow/tensorflow/issues/121 )



* Build tensorflow as normal.


## Install eigen3 from sources
* Download [eigen3](http://eigen.tuxfamily.org/index.php?title=Main_Page) and uncompressed it to the place you want.

