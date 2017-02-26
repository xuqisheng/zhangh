// 点菜宝结构

// 酒店名称定义
// select value from sysoption where catalog = 'hotel' and item = 'name';

// 基站定义
insert into basecode_cat (cat,descript,descript1,len,flag,center) select 'poswdt_base','基站定义','基站定义',1,'','F';
insert into basecode (cat,code,descript,descript1) select 'poswdt_base','1','COM1','COM1';

// 点菜机定义
create table poswdt_station (
	base		char(1)  default space(1) not null,             --基站编号
	code		char(3)  default space(3) not null,             --编号
	empno		char(10) default space(10) not null,            --当前操作员, 没用为空
	date0		datetime														--登陆时间
);
	

//	菜品类别表
insert into basecode_cat (cat,descript,descript1,len,flag,center) select 'poswdt_sort','菜类','菜类',2,'','F';

// 菜品
create table poswdt_plu (
	code		char(5)  default space(5) not null,             --编号
	sort 		char(2)  default space(2) not null,					--类别号(2位)、
	name1		char(18) default space(18) not null,			 	--中文名称(18位)、
 	price1	money 	default 0 		  not null,					--	25单价1(8位)、
 	price2	money 	default 0 		  not null,					--	25单价2(8位)、
 	price3	money 	default 0 		  not null,					--	25单价3(8位)、
 	price4	money 	default 0 		  not null,					--	25单价4(8位)、
	unit1		char(4)	default space(4) not null,					--	57单位1(4位)、
	unit2		char(4)	default space(4) not null,					--	57单位2(4位)、
	unit3		char(4)	default space(4) not null,					--	57单位3(4位)、
	unit4		char(4)	default space(4) not null,					--	57单位4(4位)、
	cook		char(30) default space(30) not null,				--	73制作要求(30位)、
 	helpcode char(4)	default space(4) not null,					--	103拼音编码(4位) 
	id			int		default 0 		  not null					-- 对应Pos_plu.id
);

// 菜品套餐
insert into basecode_cat (cat,descript,descript1,len,flag,center) select 'poswdt_std','套餐','套餐',2,'','F';


//	菜品套餐明细内容
create table poswdt_stdmx (
	std		char(2)  default space(2) not null,             --编号
	code		char(5)  default space(5) not null,             --菜品编号
	number	money		default 0		  not null,					-- 数量
	price		money		default 0		  not null,					-- 单价
	unit		char(4)  default space(5) not null	            --单位
)
;

//	推荐菜品表, 暂时不处理  


// 推荐菜品内容表, 暂时不处理

// 客户要求表, 从pos_condst 生成

// 退菜理由 select * from basecode where cat = 'pos_dish_cancel'

// 短信息表
insert into basecode_cat (cat,descript,descript1,len,flag,center) select 'poswdt_mail','短消息','短消息',2,'','F';
insert into basecode (cat,code,descript,descript1) select 'poswdt_mail','01','快上菜','快上菜';

// 包房名称表, pos_tblsta 生成, pos_tblsta.tableno  为4位,为数字,不能相同


//	操作日志
create table poswdt_log (
	type		char(10) default space(10) not null,            --操作类别
	base		char(1)  default space(1) not null,             --基站
	posno		char(5)  default space(5) not null,             --点菜机号
	empno		char(10) default space(10) not null,            --操作员
	logdate	datetime	,													--时间
	ref		varchar(255)  null						            --内容, 点菜内容存放在本地文件中
)
;
	
// 代码下载次序和内容
insert into basecode_cat (cat,descript,descript1,len,flag,center) select 'poswdt_down','代码下载次序和内容','代码下载次序和内容',2,'','F';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','01','酒店名称','酒店名称';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','02','基站定义','基站定义';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','03','点菜机定义','点菜机定义';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','04','菜品表','菜品表';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','05','菜品类别表','菜品类别表';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','06','菜品套餐表','菜品套餐表';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','07','菜品套餐内容表','菜品套餐内容表';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','08','客户要求表','客户要求表';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','09','退菜理由表','退菜理由表';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','10','短信息表','短信息表';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','11','包房名称表','包房名称表';

