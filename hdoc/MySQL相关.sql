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


《MySQL DBA面试题》

MySQL DBA面试题

1、MySQL的复制原理以及流程
(1)、先问基本原理流程，3个线程以及之间的关联；
(2)、再问一致性延时性，数据恢复；
(3)、再问各种工作遇到的复制bug的解决方法。


2、MySQL中myisam与innodb的区别，至少5点

(1)、问5点不同:
	1.1 事务处理 innodb支持,myisam不支持
	1.2 锁机制   innodb为行锁,myisam为表锁
	1.3 物理结构
	1.4 InnoDB不支持FULLTEXT类型的索引
	1.5 对于AUTO_INCREMENT类型的字段，InnoDB中必须包含只有该字段的索引，但是在MyISAM表中，可以和其他字段一起建立联合索引。
	1.6 DELETE FROM table时，InnoDB不会重新建立表，而是一行一行的删除
	1.7 InnoDB中不保存表的具体行数
	1.8 MyISAM在磁盘上存储成三个文件,InnoDB：基于磁盘的资源是InnoDB表空间数据文件和它的日志文件，InnoDB 表的大小只受限于操作系统文件的大小，一般为 2GB
(2)、问各种不同mysql版本的2者的改进；
(3)、2者的索引的实现方式。

3、问MySQL中varchar与char的区别以及varchar(50)中的30代表的涵义

(1)、varchar与char的区别；
	varchar 可变长度,char 固定长度
	根据实际存储的数据来分配最终的存储空间。而后者则不管实际存储数据的长度，都是根据CHAR规定的长度来分配存储空间
	varchar存储可变长字符串，小于255字节时需要1个额外字节(大于255需要2个额外字节)存储长度，最大长度为65532字节(所有列总和)；
	char存储定长(right padding)，读取时会截断末尾空格，长度最大为255字符；
(2)、varchar(50)中50的涵义；
	最大存储50个字符
(3)、int(20)中20的涵义；
	20表示最大显示宽度为20，但仍占4字节存储，存储范围不变
(4)、为什么MySQL这样设计。
	对大多数应用没有意义，只是规定一些工具用来显示字符的个数；int(1)和int(20)存储和计算均一样；
[备注] 本人也面试了近12个2年MySQL DBA经验的朋友，没有一个能回答出第(2)、(3)题



4、innodb的事务与日志的实现方式

(1)、有多少种日志；
(2)、日志的存放形式；
(3)、事务是如何通过日志来实现的，说得越深入越好。
	在Innodb存储引擎中，事务日志是通过redo和innodb的存储引擎日志缓冲（Innodb log buffer）来实现的，当开始一个事务的时候，会记录该事务的lsn(log sequence number)号; 当事务执行时，会往InnoDB存储引擎的日志
的日志缓存里面插入事务日志；当事务提交时，必须将存储引擎的日志缓冲写入磁盘（通过innodb_flush_log_at_trx_commit来控制），也就是写数据前，需要先写日志。这种方式称为“预写日志方式”，
innodb通过此方式来保证事务的完整性。也就意味着磁盘上存储的数据页和内存缓冲池上面的页是不同步的，是先写入redo log，然后写入data file，因此是一种异步的方式。


5、问了MySQL binlog的几种日志录入格式以及区别

(1)、各种日志格式的涵义；
(2)、适用场景；
(3)、结合第一个问题，每一种日志格式在复制中的优劣。


6、问了下MySQL数据库cpu飙升到500%的话他怎么处理？
(1)、没有经验的，可以不问；
(2)、有经验的，问他们的处理思路。

7、sql优化

(1)、explain出来的各种item的意义；
(2)、profile的意义以及使用场景；
(3)、explain中的索引问题。



8、备份计划，mysqldump以及xtranbackup的实现原理

(1)、备份计划；
(2)、备份恢复时间；
(3)、备份恢复失败如何处理。


9、500台db，在最快时间之内重启


10、在当前的工作中，你碰到到的最大的MySQL DB问题是？


11、innodb的读写参数优化

(1)、读取参数，global buffer pool以及 local buffer；
(2)、写入参数；
(3)、与IO相关的参数；
(4)、缓存参数以及缓存的适用场景。


12、请简洁地描述下MySQL中InnoDB支持的四种事务隔离级别名称，以及逐级之间的区别？


13、表中有大字段X(例如：text类型)，且字段X不会经常更新，以读为为主，请问
(1)、您是选择拆成子表，还是继续放一起；
(2)、写出您这样选择的理由。


14、MySQL中InnoDB引擎的行锁是通过加在什么上完成(或称实现)的？为什么是这样子的？
	
	
《MySQL 性能优化方案》

网上有不少mysql性能优化方案，不过，mysql的优化同sql server相比，更为麻烦与复杂，同样的设置，
在不同的环境下 ，由于内存，访问量，读写频率，数据差异等等情况，可能会出现不同的结果，
因此简单地根据某个给出方案来配置mysql是行不通的，最好能使用status信息对mysql进行具体的优化。

mysql> show global status;

可以列出MySQL服务器运行各种状态值，另外，查询MySQL服务器配置信息语句：

mysql> show variables;

一、慢查询

mysql> show variables like ‘%slow%‘;
+------------------+-------+
| Variable_name　　| Value |
+------------------+-------+
| log_slow_queries | ON 　 |
| slow_launch_time | 2　　 |
+------------------+-------+

mysql> show global status like ‘%slow%‘;
+-----------------------+----——-+
| Variable_name　　　　 | Value |
+-----------------------+----——-+
| Slow_launch_threads 	| 0　　 |
| Slow_queries　　　　	| 4148  |
+-----------------------+----——-+

配置中打开了记录慢查询，执行时间超过2秒的即为慢查询，系统显示有4148个慢查询，你可以分析慢查询日志，找出有问题的SQL语句，
慢查询时间不宜设置过长，否则意义不大，最好在5秒以内，如果你需要微秒级别的慢查询，
可以考虑给MySQL打补丁：http://www.percona.com/docs/wiki/release:start，记得找对应的版本。

打开慢查询日志可能会对系统性能有一点点影响，如果你的MySQL是主－从结构，可以考虑打开其中一台从服务器的慢查询日志，
这样既可以监控慢查询，对系统性能影响又小。

二、连接数

经常会遇见”MySQL: ERROR 1040: Too many connections”的情况，一种是访问量确实很高，MySQL服务器抗不住，这个时候就要考虑
增加从服务器分散读压力，另外一种情况是MySQL配置文件中max_connections值过小：

mysql> show variables like ‘max_connections‘;
+—————–+——-+
| Variable_name　　　 	| Value |
+—————–+——-+
| max_connections 		| 256　	|
+—————–+——-+

这台MySQL服务器最大连接数是256，然后查询一下服务器响应的最大连接数：

mysql> show global status like ‘Max_used_connections‘;

MySQL服务器过去的最大连接数是245，没有达到服务器连接数上限256，应该没有出现1040错误，比较理想的设置是

Max_used_connections / max_connections * 100% ≈ 85%

最大连接数占上限连接数的85％左右，如果发现比例在10%以下，MySQL服务器连接数上限设置的过高了。

三、Key_buffer_size

key_buffer_size是对MyISAM表性能影响最大的一个参数，下面一台以MyISAM为主要存储引擎服务器的配置：

mysql> show variables like ‘key_buffer_size‘;+—————–+————+
| Variable_name　　　 	| Value　　　　　　 |
+—————–+————+
| key_buffer_size 		| 536870912 		|
+—————–+————+

分配了512MB内存给key_buffer_size，我们再看一下key_buffer_size的使用情况：

mysql> show global status like ‘key_read%‘;
+————————+————-+
| Variable_name　　　　　　　　　　 | Value　　　　　　　 |
+————————+————-+
| Key_read_requests　　　　　　 | 27813678764 |
| Key_reads　　　　　　　　　　　　　　 | 6798830　　　　　 |
+————————+————-+

一共有27813678764个索引读取请求，有6798830个请求在内存中没有找到直接从硬盘读取索引，计算索引未命中缓存的概率：

key_cache_miss_rate ＝ Key_reads / Key_read_requests * 100%

比如上面的数据，key_cache_miss_rate为0.0244%，4000个索引读取请求才有一个直接读硬盘，已经很BT了，key_cache_miss_rate在0.1%以下
都很好（每1000个请求有一个直接读硬盘），如果key_cache_miss_rate在0.01%以下的话，key_buffer_size分配的过多，可以适当减少。

MySQL服务器还提供了key_blocks_*参数：

mysql> show global status like ‘key_blocks_u%‘;
+————————+————-+
| Variable_name　　　　　　　　　　 | Value　　　　　　　 |
+————————+————-+
| Key_blocks_unused　　　　　　 | 0　　　　　　　　　　　 |
| Key_blocks_used　　　　　　　　 | 413543　　　　　　 |
+————————+————-+

Key_blocks_unused表示未使用的缓存簇(blocks)数，Key_blocks_used表示曾经用到的最大的blocks数，比如这台服务器，所有的缓存都用到了，要么增加key_buffer_size，要么就是过渡索引了，把缓存占满了。比较理想的设置：

Key_blocks_used / (Key_blocks_unused + Key_blocks_used) * 100% ≈ 80%

四、临时表

mysql> show global status like ‘created_tmp%‘;
+————————-+———+
| Variable_name　　　　　　　　　　　 | Value　　　 |
+————————-+———+
| Created_tmp_disk_tables | 21197　　　 |
| Created_tmp_files　　　　　　　 | 58　　　　　　 |
| Created_tmp_tables　　　　　　 | 1771587 |
+————————-+———+

每次创建临时表，Created_tmp_tables增加，如果是在磁盘上创建临时表，Created_tmp_disk_tables也增加,Created_tmp_files表示MySQL服务
创建的临时文件文件数，比较理想的配置是：

Created_tmp_disk_tables / Created_tmp_tables * 100% <= 25%
比如上面的服务器Created_tmp_disk_tables / Created_tmp_tables * 100% ＝ 1.20%，应该相当好了。我们再看一下MySQL服务器对临时表的配置：

mysql> show variables where Variable_name in (‘tmp_table_size‘, ‘max_heap_table_size‘);
+———————+———–+
| Variable_name　　　　　　　 | Value　　　　　 |
+———————+———–+
| max_heap_table_size | 268435456 |
| tmp_table_size　　　　　　 | 536870912 |
+———————+———–+

只有256MB以下的临时表才能全部放内存，超过的就会用到硬盘临时表。

五、Open Table情况

mysql> show global status like ‘open%tables%‘;
+—————+——-+
| Variable_name | Value |
+—————+——-+
| Open_tables　　　 | 919　　　 |
| Opened_tables | 1951　 |
+—————+——-+

Open_tables表示打开表的数量，Opened_tables表示打开过的表数量，如果Opened_tables数量过大，说明配置中table_cache
(5.1.3之后这个值叫做table_open_cache)值可能太小，我们查询一下服务器table_cache值：

mysql> show variables like ‘table_cache‘;
+—————+——-+
| Variable_name | Value |
+—————+——-+
| table_cache　　　 | 2048　 |
+—————+——-+

比较合适的值为：

Open_tables / Opened_tables * 100% >= 85%

Open_tables / table_cache * 100% <= 95%

六、进程使用情况

mysql> show global status like ‘Thread%‘;
+——————-+——-+
| Variable_name　　　　　 | Value |
+——————-+——-+
| Threads_cached　　　　 | 46　　　　 |
| Threads_connected | 2　　　　　 |
| Threads_created　　　 | 570　　　 |
| Threads_running　　　 | 1　　　　　 |
+——————-+——-+

如果我们在MySQL服务器配置文件中设置了thread_cache_size，当客户端断开之后，服务器处理此客户的线程将会缓存起来以响应下一个客户而不是销毁（前提是缓存数未达上限）。Threads_created表示创建过的线程数，如果发现Threads_created值过大的话，表明MySQL服务器一直在创建线程，这也是比较耗资源，可以适当增加配置文件中thread_cache_size值，查询服务器thread_cache_size配置：

mysql> show variables like ‘thread_cache_size‘;
+——————-+——-+
| Variable_name　　　　　 | Value |
+——————-+——-+
| thread_cache_size | 64　　　　 |
+——————-+——-+

示例中的服务器还是挺健康的。

七、查询缓存(query cache)

mysql> show global status like ‘qcache%‘;
+————————-+———–+
| Variable_name　　　　　　　　　　　 | Value　　　　　 |
+————————-+———–+
| Qcache_free_blocks　　　　　　 | 22756　　　　　 |
| Qcache_free_memory　　　　　　 | 76764704　 |
| Qcache_hits　　　　　　　　　　　　　 | 213028692 |
| Qcache_inserts　　　　　　　　　　 | 208894227 |
| Qcache_lowmem_prunes　　　　 | 4010916　　　 |
| Qcache_not_cached　　　　　　　 | 13385031　 |
| Qcache_queries_in_cache | 43560　　　　　 |
| Qcache_total_blocks　　　　　 | 111212　　　　 |
+————————-+———–+

MySQL查询缓存变量解释：

Qcache_free_blocks：缓存中相邻内存块的个数。数目大说明可能有碎片。FLUSH QUERY CACHE会对缓存中的碎片进行整理，从而得到一个空闲块。

Qcache_free_memory：缓存中的空闲内存。

Qcache_hits：每次查询在缓存中命中时就增大

Qcache_inserts：每次插入一个查询时就增大。命中次数除以插入次数就是不中比率。

Qcache_lowmem_prunes：缓存出现内存不足并且必须要进行清理以便为更多查询提供空间的次数。这个数字最好长时间来看；如果这个数字在不断增长，就表示可能碎片非常严重，或者内存很少。（上面的 free_blocks和free_memory可以告诉您属于哪种情况）

Qcache_not_cached：不适合进行缓存的查询的数量，通常是由于这些查询不是 SELECT 语句或者用了now()之类的函数。

Qcache_queries_in_cache：当前缓存的查询（和响应）的数量。

Qcache_total_blocks：缓存中块的数量。

我们再查询一下服务器关于query_cache的配置：

mysql> show variables like ‘query_cache%‘;
+——————————+———–+
| Variable_name　　　　　　　　　　　　　　　　 | Value　　　　　 |
+——————————+———–+
| query_cache_limit　　　　　　　　　　　　 | 2097152　　　 |
| query_cache_min_res_unit　　　　　 | 4096　　　　　　 |
| query_cache_size　　　　　　　　　　　　　 | 203423744 |
| query_cache_type　　　　　　　　　　　　　 | ON　　　　　　　　 |
| query_cache_wlock_invalidate | OFF　　　　　　　 |
+——————————+———–+

各字段的解释：

query_cache_limit：超过此大小的查询将不缓存

query_cache_min_res_unit：缓存块的最小大小

query_cache_size：查询缓存大小

query_cache_type：缓存类型，决定缓存什么样的查询，示例中表示不缓存 select sql_no_cache 查询

query_cache_wlock_invalidate：当有其他客户端正在对MyISAM表进行写操作时，如果查询在query cache中，是否返回cache结果还是等写操作完成再读表获取结果。

query_cache_min_res_unit的配置是一柄”双刃剑”，默认是4KB，设置值大对大数据查询有好处，但如果你的查询都是小数据查询，就容易造成内存碎片和浪费。

查询缓存碎片率 = Qcache_free_blocks / Qcache_total_blocks * 100%

如果查询缓存碎片率超过20%，可以用FLUSH QUERY CACHE整理缓存碎片，或者试试减小query_cache_min_res_unit，如果你的查询都是小数据量的话。

查询缓存利用率 = (query_cache_size – Qcache_free_memory) / query_cache_size * 100%

查询缓存利用率在25%以下的话说明query_cache_size设置的过大，可适当减小；查询缓存利用率在80％以上而且Qcache_lowmem_prunes > 50的话说明query_cache_size可能有点小，要不就是碎片太多。

查询缓存命中率 = (Qcache_hits – Qcache_inserts) / Qcache_hits * 100%

示例服务器 查询缓存碎片率 ＝ 20.46％，查询缓存利用率 ＝ 62.26％，查询缓存命中率 ＝ 1.94％，命中率很差，可能写操作比较频繁吧，而且可能有些碎片。

八、排序使用情况

mysql> show global status like ‘sort%‘;
+——————-+————+
| Variable_name　　　　　 | Value　　　　　　 |
+——————-+————+
| Sort_merge_passes | 29　　　　　　　　　 |
| Sort_range　　　　　　　　 | 37432840　　　 |
| Sort_rows　　　　　　　　　 | 9178691532 |
| Sort_scan　　　　　　　　　 | 1860569　　　　 |
+——————-+————+

Sort_merge_passes 包括两步。MySQL 首先会尝试在内存中做排序，使用的内存大小由系统变量 Sort_buffer_size 决定，如果它的大小不够把所有的记录都读到内存中，MySQL 就会把每次在内存中排序的结果存到临时文件中，等 MySQL 找到所有记录之后，再把临时文件中的记录做一次排序。这再次排序就会增加 Sort_merge_passes。实际上，MySQL 会用另一个临时文件来存再次排序的结果，所以通常会看到 Sort_merge_passes 增加的数值是建临时文件数的两倍。因为用到了临时文件，所以速度可能会比较慢，增加 Sort_buffer_size 会减少 Sort_merge_passes 和 创建临时文件的次数。但盲目的增加 Sort_buffer_size 并不一定能提高速度，见 How fast can you sort data with MySQL?（引自http://qroom.blogspot.com/2007/09/mysql-select-sort.html，貌似被墙）

另外，增加read_rnd_buffer_size(3.2.3是record_rnd_buffer_size)的值对排序的操作也有一点的好处，参见：http://www.mysqlperformanceblog.com/2007/07/24/what-exactly-is-read_rnd_buffer_size/

九、文件打开数(open_files)

mysql> show global status like ‘open_files‘;
+—————+——-+
| Variable_name | Value |
+—————+——-+
| Open_files　　　　 | 1410　 |
+—————+——-+

mysql> show variables like ‘open_files_limit‘;
+——————+——-+
| Variable_name　　　　 | Value |
+——————+——-+
| open_files_limit | 4590　 |
+——————+——-+

比较合适的设置：Open_files / open_files_limit * 100% <= 75％

十、表锁情况

mysql> show global status like ‘table_locks%‘;
+———————–+———–+
| Variable_name　　　　　　　　　 | Value　　　　　 |
+———————–+———–+
| Table_locks_immediate | 490206328 |
| Table_locks_waited　　　　 | 2084912　　　 |
+———————–+———–+

Table_locks_immediate表示立即释放表锁数，Table_locks_waited表示需要等待的表锁数，如果Table_locks_immediate / Table_locks_waited > 5000，最好采用InnoDB引擎，因为InnoDB是行锁而MyISAM是表锁，对于高并发写入的应用InnoDB效果会好些。示例中的服务器Table_locks_immediate / Table_locks_waited ＝ 235，MyISAM就足够了。

十一、表扫描情况

mysql> show global status like ‘handler_read%‘;
+———————–+————-+
| Variable_name　　　　　　　　 Value　　　　　　　 |
+———————–+————-+
| Handler_read_first　　　　  | 5803750　　　　　 |
| Handler_read_key　　　　　　| 6049319850　 |
| Handler_read_next　　　　　 | 94440908210 |
| Handler_read_prev　　　　　 | 34822001724 |
| Handler_read_rnd　　　　　　| 405482605　　　 |
| Handler_read_rnd_next | 18912877839 |
+———————–+————-+

各字段解释参见http://hi.baidu.com/thinkinginlamp/blog/item/31690cd7c4bc5cdaa144df9c.html，调出服务器完成的查询请求次数：

mysql> show global status like ‘com_select‘;
+—————+———–+
| Variable_name | Value　　　　　 |
+—————+———–+
| Com_select　　　　 | 222693559 |
+—————+———–+

计算表扫描率：

表扫描率 ＝ Handler_read_rnd_next / Com_select

如果表扫描率超过4000，说明进行了太多表扫描，很有可能索引没有建好，增加read_buffer_size值会有一些好处，但最好不要超过8MB。

后记：

文中提到一些数字都是参考值，了解基本原理就可以，除了MySQL提供的各种status值外，操作系统的一些性能指标也很重要，比如常用
的top,iostat等，尤其是iostat，现在的系统瓶颈一般都在磁盘IO上，关于iostat的使用，
可以参考：http://www.php-oa.com/2009/02/03/iostat.html