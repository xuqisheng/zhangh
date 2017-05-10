MySQL的日志学习

疑问：1、日志文件何时产生新的，又在何时被删除
		mysql本身不会自动清除日志，但可以使用自带的mysql-log-rotate脚本或手动脚本清除
	  2、数据删除后，如何恢复，比如上次在亚酒的初始化

1、查看MySQL是否启用了日志
	mysql>show variables like  '%bin%';

2、查看当前的日志
	mysql>show master status;
	mysql>show binlog events; 或 show binlog events \G   两者格式不同，结果一样

3、查看日志数量
	mysql>show master logs;

4、如何开户log_bin
	windows系统：在my.ini文件中添加log_bin=mysql_bin，重启mysql即可；
	linux系统：在/etc/my.cnf文件中添加log_bin=mysql_bin，重启mysql即可；

5、日志文件操作工具
	mysqlbinlog，见mysql手册第8章
	
	shell>mysqlbinlog mysql_bin.000001  --> 输出二进制文件内容
	(注意此命令的报告位置,不是登录mysql中执行，并且执行时要指出完整目录)
	win7默认目录：C:\ProgramData\MySQL\MySQL Server 5.1\data，也可通过查看
	my.ini中datadir来定位；
	linux目录：/var/lib/mysql/
	
	
6、使用mysqlbinlog日志恢复
	所谓日志恢复，其实只是重做日志标记范围内的数据库操作。
	6.1 指定恢复时间
		shell>mysqlbinlog --start-date [--stop-date]
	
	6.2 指定恢复位置(精确恢复，推荐)
		shell>mysqlbinlog --start-postion [--stop-postion]
	
	6.3 恢复步骤
		6.3.1 确定大概何时做了危险动作，比如：2013-03-01 10:30:00左右
		6.3.2 结合start-date和stop-date，使用mysqlbinlog将日志导出为可编辑查看文件,此处导为log.sql文件
			shell>mysqlbinlog --start-date="2013-03-01 10:20:00" --stop-date="2013-03-01 10:40:00" mysql-bin.000001 --database="portal"  > /log.sql
		6.3.3 查看log.sql文件，最终确认危险动作在哪个点(at)，以便利用postion进行精确定位
	
	6.4 注意
		在恢复时，若提示字符集不对，先在my.cnf中将原先的默认字符集注释掉(default-character-set)，再重启mysql
		根据数据库：shell>mysqlbinlog -d portal
		根据IP地址：shell>mysqlbinlog -h 192.168.6.15
		根据端口：  shell>mysqlbinlog -P 3336
		
7.启用新的日志(一般在备份完整数据后执行)
	mysql>flush logs;

8、清空所有bin_log
	mysql>reset master;
	
	mysqlbinlog --start-date="2015-03-23 10:00:00" --stop-date="2015-03-24 18:00:00" mysql_bin.000003 --database="portal"  > /log1.sql
	
	
	/usr/bin/mysqlbinlog --start-position=249 --stop-position=1305 mysql-bin.000003
	
	
	
	
	
	
	
	
	
	
	