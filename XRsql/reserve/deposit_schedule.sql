if exists(select 1 from sysobjects where name='deposit_schedule' and type='U')
drop table deposit_schedule
;
create table deposit_schedule
(
 id     		integer     not null,        --id schedule id
 code   		char(10)    not null,        --Ѻ��������  ref deposit_rule
 descript   varchar(255)    null,		  --Ѻ���������  ref deposit_rule
 ratecode 	char(10)  	null	  ,        --������        ref rmratecode
 restype    char(3)     null    ,        --Ԥ������      ref restype
 begin_     datetime    not null,        --��Ч��ʼʱ��
 end_       datetime   	not null, 		  --��Ч��ֹʱ��
 seq   		int         null,            --����
 cby        char(10)    not null,
 changed 	datetime 	not null
)
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON deposit_schedule(id)
;
 