if exists(select 1 from sysobjects where name='deposit_schedule' and type='U')
drop table deposit_schedule
;
create table deposit_schedule
(
 id     		integer     not null,        --id schedule id
 code   		char(10)    not null,        --押金规则代码  ref deposit_rule
 descript   varchar(255)    null,		  --押金规则描述  ref deposit_rule
 ratecode 	char(10)  	null	  ,        --房价码        ref rmratecode
 restype    char(3)     null    ,        --预定类型      ref restype
 begin_     datetime    not null,        --有效开始时间
 end_       datetime   	not null, 		  --有效截止时间
 seq   		int         null,            --排序
 cby        char(10)    not null,
 changed 	datetime 	not null
)
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON deposit_schedule(id)
;
 