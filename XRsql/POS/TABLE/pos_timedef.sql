
// 餐饮计费定义

insert into basecode_cat(cat,descript) select 'pos_timedef', '餐饮计费';
insert into basecode(cat,code,descript,descript1) select 'pos_timedef', '01','棋牌室计费','棋牌室计费';
insert into basecode(cat,code,descript,descript1) select 'pos_timedef', '02','保龄球计费','保龄球计费';

CREATE TABLE pos_timedef (
	id 		char(2)			default ''  not null ,
	thisid 	char(2)			default ''  not null ,
	timedesc char(30)			default ''  not null ,
	datecond char(60)			default ''  not null ,
	start_t 	char(8)			default '00:00:00'  not null ,          -- 开始时间
	end_t 	char(8)			default '00:00:00'  not null ,			  -- 结束时间
	leng_ 	integer			default 60  not null ,			  -- 单位时长
	factor 	money 			default 0   not null )          -- 计价 
;

exec sp_primarykey pos_timedef,id,thisid
create unique index index1 on pos_timedef(id,thisid)
;
INSERT INTO pos_timedef VALUES (	'01',	'01',	'周一至周天0时至7时',	'w:1234567',	'00:00:00',	'06:59:59',	60, 50);
INSERT INTO pos_timedef VALUES (	'01',	'02',	'周一至周日7时至24时',	'w:1234567',	'07:00:00',	'23:59:59',	60, 100);
INSERT INTO pos_timedef VALUES (	'02',	'01',	'周一至周日0时至7时',	'w:1234567',	'00:00:00',	'06:59:59',	60, 50);
INSERT INTO pos_timedef VALUES (	'02',	'02',	'周一至周日7时至22时',	'w:1234567',	'07:00:00',	'21:59:59',	60, 100);
INSERT INTO pos_timedef VALUES (	'02',	'03',	'周一至周日22时至0点',	'w:1234567',	'22:00:00',	'23:59:59',	60, 120);

// 临时存放计算结果
CREATE TABLE pos_timeanal (
	pc_id    char(4)				default ''  not null ,
	id 	   char(2)				default ''  not null ,
	thisid   char(2)				default ''  not null ,
	start_t  char(8)				default '00:00:00'  not null ,
	end_t    char(8)				default '00:00:00'  not null ,
	factor   money					default 0   not null ,          -- 单价
	leng_ 	integer			   default 60  not null ,			  -- 单位计价时长,分钟
	duration money					default 0   not null );         -- 分钟

exec sp_primarykey pos_timeanal,pc_id,id,thisid
create unique index index1 on pos_timeanal(pc_id,id,thisid)
;
