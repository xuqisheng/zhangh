//查找待合并档案cmb_pool

IF OBJECT_ID('cmb_pool') IS NOT NULL
	drop table cmb_pool;

create table cmb_pool
(
	id numeric  identity  not null ,
 no char(7) not null ,
 grpid int  null ,
	halt char(1) default 'F' null,
constraint PK_cmb_pool primary key (id)
);

IF OBJECT_ID('idx_cmb_pool_no') IS NOT NULL
	drop index cmb_pool.idx_cmbs_no;
create index idx_cmb_pool
on cmb_pool (no);


IF OBJECT_ID('idx_cmb_pool_halt') IS NOT NULL
	drop index cmb_pool.idx_cmb_pool_halt;
create index idx_cmb_pool_halt
on cmb_pool (halt);
