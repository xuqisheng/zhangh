show databases;		查看当前有几个数据库
create database dbname;	创建名为dbname;的数据库
drop database dbname;;	删除名为dbname;的数据库
use dbname;		选择名为dbname;的数据库
show tables;		查看某数据库中的所有表
create table tablename(); 创建表名为tablename的一个表
desc tablename;		查看表的定义
show create table tablename;	更全面的查看表的定义信息
drop table tablename;	删除表名为tablename的一个表
alter table tablename modify tablename.column;
alter table tablename add tablename.column;
alter table tablename drop tablename.column;
alter table tablename charge tablename.column;
? 类别名称		对一些内容进行查看，例如：? data types

show variables like 'table_type';	查看当前的默认存储引擎;
show table status like 'account' \G	查看account表的属性情况
show engines;		查看当前数据库支持的存储引擎;

SELECT NOW(),USER(),VERSION(),DATABASE()
DESC table_name; 	显示表结构

------Select语法-------
SELECT select_list
  FORM table_list
    WHERE row_constraint
      GROUP BY grouping_columns
	ORDER BY sorting_columns
	  HAVING grouping_constraint
	    LIMIT count;
--------MySQL优化--------
1、EXPLAIN
2、PROCEDURE ANALYSE    # 此方法可以帮助决定“列是否该被重定义为更小的数据类型”
   # 语法 SELECT ... FROM ... WHERE ... PROCEDURE ANALYSE([max_elements,[max_memory]])




MySQL中EXISTS和IN区别
EXISTS检查行的存在性；IN检查值的存在性；EXISTS效率比IN高

技巧5：用NOT EXISTS替代NOT IN
当NOT IN后面跟子查询，并且查询的结果集较多时，不宜用NOT IN；但如果NOT IN后面的括号内是列表，或子查询所满足的结果集很少时，也是可以用的。

原因：在子查询中，NOT IN子句将执行一个内部的排序和合并，无论哪种情况下，NOT IN都是最低率的，因为它对子查询中的表执行了一个全表遍历。可以改写为外接连或使用NOT EXISTS。

技巧6：关于IN和EXISTS，IN是把内表和外表做HASH连接，则EXISTS是对外表做LOOP循环，每次LOOP循环再对内表进行查询。
   如果内表和外表大小相当，则使用IN和EXISTS效率差不多少。
   如果子查询的表大，则使用EXISTS，如果子查询表小，则使用IN效率高。

CALL up_ihotel_rep_channel(2,35,@a,@b)
带out变量的执行方法


表联结
1,内联结:inner join; 内联结只显示在两个数据表里能找到匹配的数据行。
2,外联结(左联结和右联结):外联结除了内联结的结果外，还可以把其中一个数据表在另一个数据表里没有匹配的数据行也显示出来
LEFT JOIN:把左数据据表在右数据表里没有匹配的数据行也显示出来；
RIGHT JOIN:把右数据据表在左数据表里没有匹配的数据行也显示出来；

INNER JOIN(等值联接):只返回两个表中联结字段相等的行；
LEFT JOIN(左联接):返回包括左表中的所有记录和右表中联结字段相等的记录,左表记录全部显示,右表只显示符合条件
  		  的记录，不足地方均为NULL；
RIGHT JOIN(右联接):返回包括右表中的所有记录和左表中联结字段相等的记录，右表记录全部显示,左表只显示符合条件
  		  的记录，不足地方均为NULL；

---------------------




















