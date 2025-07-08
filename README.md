# Redmine IP Fence Plugin

## 功能说明
本插件实现Redmine附件的网络隔离功能，根据上传和下载的IP地址控制访问权限。

## 安装步骤
1. 将插件目录复制到Redmine的`plugins/`目录下
2. 在Redmine目录下执行数据库迁移：
   ```bash
   bundle exec rake redmine:plugins:migrate RAILS_ENV=production
   ```
3. 重启Redmine服务

## 配置方法
1. 以管理员身份登录Redmine
2. 进入"管理" → "插件" → "Redmine IP Fence Plugin"
3. 配置内网IP段（每行一个IP段，支持通配符*）

## 功能验证
1. 从内网IP上传文件，应标记为敏感文件
2. 从外网IP尝试下载敏感文件，应被拒绝
3. 从内网IP下载文件，应允许访问
