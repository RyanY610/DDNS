## 本篇教程由 https://t.me/fun513 编写，转载请注明出处
教程使用的环境：MWserver(金灵面板) x86_64 架构

## 安装 MWserver

MWserver 项目地址：https://github.com/midoks/mdserver-web
## 一键脚本
```
curl --insecure -fsSL https://cdn.jsdelivr.net/gh/midoks/mdserver-web@latest/scripts/install.sh | bash
```
面板安装完毕后访问面板安装LNMP环境
- OpenResty
- PHP 8.1
- MariaDB

注意请选择快速安装(apt)，在面板首页直接安装，去软件管理页面安装，首页直接安装是编译安装，需要很长时间

环境安装完毕后开始安装php扩展
软件管理->已安装->php->安装扩展
- bcmath
- zip
- ioncube

手动安装ioncube，注意区分架构
## 查看架构命令
```
uname -m
```
- x86_64
```
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && tar xvf ioncube_loaders_lin_x86-64.tar.gz && cp ioncube/ioncube_loader_lin_8.1.so /usr/lib/php/20210902/ioncube_loader_lin_8.1.so && echo "zend_extension = /usr/lib/php/20210902/ioncube_loader_lin_8.1.so" > /etc/php/8.1/cli/conf.d/00-ioncube.ini && echo "zend_extension = /usr/lib/php/20210902/ioncube_loader_lin_8.1.so" > /etc/php/8.1/fpm/conf.d/00-ioncube.ini && rm -rf ioncube ioncube_loaders_lin_x86-64.tar.gz
```
- aarch64
```
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_aarch64.tar.gz && tar xvf ioncube_loaders_lin_aarch64.tar.gz && cp ioncube/ioncube_loader_lin_8.1.so /usr/lib/php/20210902/ioncube_loader_lin_8.1.so && echo "zend_extension = /usr/lib/php/20210902/ioncube_loader_lin_8.1.so" > /etc/php/8.1/cli/conf.d/00-ioncube.ini && echo "zend_extension = /usr/lib/php/20210902/ioncube_loader_lin_8.1.so" > /etc/php/8.1/fpm/conf.d/00-ioncube.ini && rm -rf ioncube ioncube_loaders_lin_aarch64.tar.gz
```
扩展安装完毕后从MWserver重启php

## 创建数据库
MWserver->软件管理->MariaDB->管理列表->添加数据库

## 部署 SSPanel UIM
MWserver->网站->添加站点，这一步不用教了吧
然后ssh登录你的vps，cd进你添加的站点目录后删除所有文件
```
rm -rf *
```
从仓库拉取源码
```
git clone -b 2023.3 https://github.com/Anankke/SSPanel-Uim.git .
```
## 安装composer
```
wget https://getcomposer.org/download/latest-stable/composer.phar -O /usr/local/bin/composer && chmod +x /usr/local/bin/composer
```

## 安装php依赖
```
composer install
```
## 编辑网站配置
```
cp config/.config.example.php config/.config.php
cp config/appprofile.example.php config/appprofile.php
vim config/.config.php
```
只需要修改数据库相关信息即可，注意在MWserver查看数据库端口
## 示例
```
$_ENV['db_driver']    = 'mysql';
$_ENV['db_host']      = '127.0.0.1';
$_ENV['db_socket']    = '';
$_ENV['db_database']  = 'sspanel';           //数据库名
$_ENV['db_username']  = 'sspanel';              //数据库用户名
$_ENV['db_password']  = 'sspanel';           //用户名对应的密码
$_ENV['db_port']      = '33106';              //端口
#高级
$_ENV['db_charset']   = 'utf8mb4';
$_ENV['db_collation'] = 'utf8mb4_unicode_ci';
$_ENV['db_prefix']    = '';
```

## 站点初始化设置
```
php xcat Migration new
```
```
php xcat Tool importAllSettings
```
```
php xcat Tool createAdmin
```
```
php xcat ClientDownload
```

## 设置网站目录伪静态并配置ssl证书
MWserver->网站->你的站点域名->网站目录
取消勾选[防跨站攻击]并设置运行目录为"/public"然后保存
在伪静态一栏中填入下列代码
```
location / {
    try_files $uri /index.php$is_args$args;
}
```

在ssl一栏中申请域名证书并开启强制https

## 配置计划任务
MWserver->计划任务
- 任务类型 shell脚本
- 任务名称 sspanel
- 执行周期 选择N分钟 5分钟
- 脚本内容
```
php /www/wwwroot/你的域名/xcat  Cron
```

## 设置网站目录权限
MWserver->文件->你的sspanel目录
权限循环设置755和www
然后你就可以访问你的sspanel网站了
