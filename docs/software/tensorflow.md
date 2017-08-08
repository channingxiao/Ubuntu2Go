#Compile Tensorflow C++ library for bazel-independent use

Follow the [Installing Tensorflow from Source](https://www.tensorflow.org/install/install_sources) instructions to install all the dependens. Clone the source code from [Github](https://github.com/tensorflow/tensorflow), and ckeckout to the specific version you want. Then follow the instructions below 

```shell
cd tensorflow

./configure

bazel build -c opt //tensorflow:libtensorflow_cc.so
```

Copy libtensorflow_cc.so to your installation directories, then you can link libtensorflow_cc.so in g++ as the other normal shared libs. As for the include files, I do not know which are they exactly, I copy the following directories the include directories.

Supporse you are in the root directory of tensorflow source code, and your include directory is "INCLUDE_DIR". Copy the following to "INCLUDE_DIR" should work.

```
mkdir INCLUDE_DIR/tensorflow

cp -r tensorflow INCLUDE_DIR/tensorflow

cp -r bazel-genfiles/tensorflow INCLUDE_DIR/tensorflow

mkdir -p INCLUDE_DIR/tensorflow/third_party

cp -r third_party/eigen3 INCLUDE_DIR/tensorflow/third_party

``` 
And now, when you use libtensroflow_cc.so, you just need to add "INCULDE_DIR/tensorflow" to the include search path.

To use libtensorflow_cc.so, you need to have the right version Eigen and protobuf installed. If you notice the workspace.bzl under
"tensorflow/tensorflow", the building tools downloaded Eigen and protobuf. For Eigen, you just need to download and uncompress it.
As for the protobuf, you can download the right pre-compiled version, or download the source code and compile it yourself, see [Compile protobuf from source](https://github.com/google/protobuf/blob/master/src/README.md) for more information.


