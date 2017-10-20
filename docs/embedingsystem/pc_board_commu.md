#版子和PC之间的通讯

##通过串口控制版子
*用串口先将PC和开发版连接好；如果PC没有串口接口，可以用串口转USB连接PC（以下的教程基于串口转USB的方式）。确定一下版子用的是交叉串口线还是直连串口线。
*查看串口号。Linux下在命令窗中运行lsusb找到相应的USB;例如我的显示 ”Bus 001 Device 006: ID 067b:2303 Prolific Technology, Inc. PL2303 Serial Port“；
 用dmesg 命令可以从打印信息看到类似下面的信息

```
[92092.696353] usb 1-8: New USB device found, idVendor=067b, idProduct=2303
[92092.696361] usb 1-8: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[92092.696366] usb 1-8: Product: USB-Serial Controller D
[92092.696370] usb 1-8: Manufacturer: Prolific Technology Inc. 
[92092.696959] pl2303 1-8:1.0: pl2303 converter detected
[92092.697639] usb 1-8: pl2303 converter now attached to ttyUSB0

```
记住上面的串口号 ttyUSB0
* sudo apt-get install gtkterm 安装gtkterm
* sudo gtkterm 启动gtkterm
* 点击Configuration/Port ;Port选择上面查询到的串号号， Baud Rate按照开发板的波特率来设，通常为11520；点击OK
* 给开发版上电（如果版子已经上电，关了再上电），正常如果开发版上已经烧好U-boot就有信息打印出来了。


如果信息太多，可以加上grep 筛选信息，例如 dmesg | grep USB

##通过tfpt向版子发送文件

### tftp 服务端设置 （服务端指的是存放文件的地方,通常是服务器,一下教程为ubuntu14.04）
1. 安装xinet, tftp-pha, tftp-hpa 

```
sudo apt-get install xinetd
sudo apt-get install tftp-hpa tftpd-hpa

```

2. 设置tftp的配置文件， 在/etc/xinetd.d/tftp 中添加如下代码，如没有改文件，重新新建

```
service tftp
{
        socket_type = dgram
        protocol = udp
        wait = yes
        user = channing
        server = /usr/sbin/in.tftpd
        server_args = -s /tftproot
        disable = no
        per_source = 11
        cps = 100 2
        flags = IPv4
}

```
其中user选项为你的系统登入用户名， 保存退出。

3. 设置 tftpd-hpa 的配置文件，vim打开 /etc/default/tftp-hpa, 添加一下代码，保存并退出

```
# /etc/default/tftpd-hpa
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/home/channing/data/tftproot"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="-l -c -s"

```
其中TFTP_DIRECTORY就是需要共享的文件夹； 69表示tftp协议的端口号； OPTIONS是操作权限

4. 创建分享的文件夹，并修改权限

```
mkdir -p /home/channing/data/tftproot
chmod 777 /home/channing/data/tftproot

```
文件夹 /home/channing/data/tftproot 改成你自己需要共享的文件夹，和tftpd-hpa中的需保持一致

5. 启动xinetd和tftp服务

```
sudo /etc/init.d/tftpd-hpa restart
sudo /etc/init.d/xinetd restart

```

6. 测试tftp服务端部署成功

 ```
 touch /home/channing/data/tftproot/test
 echo "Everything is good !" > /home/channing/data/tftproot/test
 cd ~
 tftp 127.0.0.1 // 本地ip
 tftp > get test
 tftp > q
 cat /home/channing/data/tftproot/test

  ```
 如果"Everything is good !"打印出来，说明服务端部署成功。

### 配置客户端
客户端通常指的是你操作的机器，在我们的例子中位开发板。在开发板中，通常情况有两个地方会用到tftp，
一是在u-boot中，用户传输需要烧写的内核、文件系统等；另外一个是在正常进入开发版系统中用于在服务端和开发板之间传输文件。

#### u-boot中配置客户端

1. 开发板上电之后，进入u-boot中，注意不要进入系统。（通常上电之后快速按任意键就不会自动进入系统）

2. 参数设置

```
setenv serverip xxx.xxx.xxx.xxx
setenv ipdaddr xxx.xxx.xxx.xxx
setenv ethaddr xx:xx:xx:xx:xx:xx
setenv netmask 255.255.255.0
setenv gatewayip 192.168.50.1

```
其中 serverip是tftp服务端的ip； ipdaddr 是客户端也就是开发板的ip，这个ip是自己选的，在自己的网段中选一个没人用的就行；
ethaddr 是开发板的物理地址, mac地址可以先用printenv查看有没有，如果已经有了物理地址则不再设置，如果没有则自己随便设一个；
netmask是网络掩码，通常位255.255.255.0,如不确定，可在本地机器运行ifconfig -a获得； gatewatip是网关。

3. 测试

```
ping xxx.xxx.xxx.xxxx

```
xxx.xxx.xxx.xxx是服务端的IP， 如返回“host 192.168.50.200 is alive”说明网络是通的。

4. 用tftp加载文件

```
tftp 0x4200000 test

```
其中0x4200000是内存地址 test是要加载过来的问价

#### 进入开发板系统后客户端配置

1. 设置网络环境

```
ifconfig etho xxx.xxx.xxx.xxx netmask xxx.xxx.xxx.xxx
route add default gw xxx.xxx.xxx.xxx

```
其中 eth0对应的是ip地址，选择与服务端机器同一个网段的没人用的一个ip； netmask 位掩码，通常位255.255.255.0；
gw 位网关， 通常掩码和网关可以在服务端运行 ifconfig -a，从输出信息中找得。






##通过nfs向版子发送文件
nfs位网络文件夹系统，通过将服务端的文件夹映射到客户端，客户端可以像访问本地文件夹一样来浏览服务端共享的文件夹。

### 配置nfs服务端
1. 安装 nfs-kernel-server

```
sudo apt-get install nfs-kernel-server

```

2. 配置/etc/exports. vim打开/etc/exports,添加如下代码

```
/home/name/shared/directory  *(rw,sync,no_root_squash,no_subtree_check)

```

其中 /home/name/shared/directory是希望通过nfs共享的文件夹， 保存并退出

3. 重启服务，不同的linux可能稍微有些差别，一下是Ubuntu 14.04的启动方式

```
sudo /etc/init.d/rpcbind restart
sudo /etc/init.d/nfs-kernel-server restart 

```

### 配置客户端

1. 配置网络环境


2. mount文件夹

```
sudo mount -t nfs xxx.xxx.xxx.xxx:/home/name/shared/directory /mnt 

```
其中 xxx.xxx.xxx.xxx 是nfs服务端的ip， /home/name/shared/directory是服务端共享的文件夹， /mnt 是客户端将挂在的地址

3. 如果挂在不成功，安装 nfs-common

```
sudo apt-get install nfs-common

```



##telnet 控制远程机器
telnet 
### telnet 服务端配置（服务端指的是需要被远程控制的机器，我们教程中指的是开发板）
1. 在服务端上的/etc/securetty 添加以下代码 （如文件不存在，重新创建）

```
pts/0
pts/1
pts/2
pts/3

```

2. 设置服务端的root密码,在命令窗中运行

```
passwd

```

3. 设定服务端IP地址

```
ifconfig eth0 xxx.xxx.xxx.xxx

```

4. 服务端后台运行telnetd

```
telnetd
telnetd -F

```
5. 设置服务端网关及转发规则

```
ip route add 255.255.255.0 dev eth0
ip route add default via 192.168.50.1 dev eth0

```
本人没有设置这一步，但在之前已经通过ifconfig设置过网关和路由转发，以下是设置代码

```
ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx:xx  // 物理地址
ifconfig eth0 xxx.xxx.xxx.xxx netmask xxx.xxx.xxx.xxx
route add default gw xx.xx.xx.xx

```

### 客户端设置和连接
1. 安装telnet，一般Linux都是自带的；如果没有，请自行Google安装

2. 运行如下代码连接服务端

```
telnet xxx.xxx.xxx.xxx

```
xxx.xxx.xxx.xxx是服务端的ip

3. 按照提示输入登入密码

















