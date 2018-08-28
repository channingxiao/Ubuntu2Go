
## add centos mirros tsinghua mirror

https://mirror.tuna.tsinghua.edu.cn/help/centos/

## solve Coundnt resolve host
add 
nameserver 8.8.8.8
to /etc/resolv.conf
https://blog.csdn.net/qq_38298869/article/details/71485307

## solving "OpenSSL: error:100AE081:elliptic curve routines:EC_GROUP_new_by_curve_name:unknown group"

sudo yum update

## install devtool set 2
https://superuser.com/questions/381160/how-to-install-gcc-4-7-x-4-8-x-on-centos
https://people.centos.org/tru/devtools-2/readme

 devtoolset-2-binutils                    x86_64           2.23.52.0.1-10.el6              testing-devtools-2-centos-6           5.0 M
 devtoolset-2-gcc                         x86_64           4.8.2-15.el6                    testing-devtools-2-centos-6            22 M
 devtoolset-2-gcc-c++                     x86_64           4.8.2-15.el6                    testing-devtools-2-centos-6           7.2 M
 devtoolset-2-gcc-gfortran                x86_64           4.8.2-15.el6                    testing-devtools-2-centos-6           7.2 M
Installing for dependencies:
 audit-libs-python                        x86_64           2.4.5-6.el6                     base                                   64 k
 devtoolset-2-libquadmath-devel           x86_64           4.8.2-15.el6                    testing-devtools-2-centos-6           151 k
 devtoolset-2-libstdc++-devel             x86_64           4.8.2-15.el6                    testing-devtools-2-centos-6           1.9 M
 devtoolset-2-runtime                     noarch           2.1-4.el6                       testing-devtools-2-centos-6           1.0 M
 libcgroup                                x86_64           0.40.rc1-26.el6                 base                                  131 k
 libsemanage-python                       x86_64           2.0.43-5.1.el6                  base                                   81 k
 policycoreutils-python                   x86_64           2.0.83-30.1.el6_8               base                                  437 k
 setools-libs                             x86_64           3.3.7-4.el6                     base                                  400 k
 setools-libs-python 

download packages from https://people.centos.org/tru/devtools-2/6/x86_64/RPMS/
push them into /var/cache/yum/x86_64/6/testing-devtools-2-centos-6/packages
run sudo yun install sudo yum install devtoolset-2-gcc devtoolset-2-binutils devtoolset-2-gcc-gfortran devtoolset-2-gcc-c++

## enable devtoolset-2
source /opt/rh/devtoolset-2/enable
add the above command to .bashrc to eanble automatic enviroment set


#### INstall nvidia driver

https://pyrx.sourceforge.io/blog/103-installing-nvidia-driver-on-centos-6

https://blog.csdn.net/bill_chuang/article/details/18414237
## Solving problem
NVIDIA driver install - Error: Unable to find the kernel source tree


