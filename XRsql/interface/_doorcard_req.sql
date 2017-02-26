
------------------------------------------------------------------------------------
-- 新版200805 赵凯
-- 兼顾记录发卡请求和发卡记录的功能。 去掉 number, made 等表示数量的字段 
------------------------------------------------------------------------------------
if object_id('doorcard_req') is not null
	drop table doorcard_req ;
CREATE TABLE doorcard_req 
(
	 id		  numeric		identity,						--流水号
	 sta		  char(1)		not null,						--门卡状态 R=请求, F=制卡失败, I=制卡成功, X=销卡, N=过期卡, L=遗失
    accnt     char(10)    NOT NULL,							--帐号
    roomno    char(5)     DEFAULT ''	 NOT NULL,		--房号
    name      varchar(50) DEFAULT ''	 NOT NULL,		--客人姓名	
    arr       datetime    NOT NULL,							--抵
    dep       datetime    NOT NULL,							--离	
    card_type char(10)    NOT NULL,							--卡类
    card_t    char(10)    NULL,								--卡等级
	 encoder		char(10)   null,								--制卡机
    pc_id     char(4)     NOT NULL,							--pc_id
	 cardno1	  varchar(20)	default ''	not null,      --门卡号
	 cardno2	  varchar(20)	default ''	not null,      --给贵宾卡号码预留 
	 flag1	  varchar(20)	default ''	not null,      --预留字段 
	 flag2	  varchar(20)	default ''	not null,      --
	 flag3	  varchar(20)	default ''	not null,      --
	 flag4	  varchar(20)	default ''	not null,      --
	 remark    varchar(100) null,								-- 备注，制卡失败信息等 
    date      datetime    NOT NULL,							--营业日期
	 cby			char(10)		not null,						--创建人
	 cbydate		datetime		not null,						--创建时间
	 mby			char(10)		 null,							--修改人
	 mbydate		datetime		 null								--修改时间
);
EXEC sp_primarykey 'doorcard_req', id;
CREATE UNIQUE INDEX index1 ON doorcard_req(id);
CREATE INDEX index2 ON doorcard_req(accnt);
CREATE INDEX index3 ON doorcard_req(date);


------------------------------------------------------------------------------------
-- 老版：主要负责记录制卡请求。 不能管理制作好的卡 
------------------------------------------------------------------------------------
--if object_id('doorcard_req') is not null
--	drop table doorcard_req;
--create table doorcard_req (
--	accnt				char(10)							not null,
--	roomno			char(5)			default ''	not null,
--	name				varchar(50)		default ''	not null,
--	arr				datetime							not null,
--	dep				datetime							not null,
--	card_type		char(10)							not null,
--	number			int				default 1	not null,
--	made				int				default 0	not null,
--	done				char(1)			default 'F'	not null,
--	empno				char(10)							not null,
--	date				datetime							not null,
--	pc_id				char(4)							not null
--)
--exec sp_primarykey  doorcard_req, accnt;
--create unique index index1 on doorcard_req(accnt);

