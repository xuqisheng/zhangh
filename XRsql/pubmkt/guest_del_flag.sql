
// -------------------------------------------------------------------------------------
//	客史档案 -- 删除标记 
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest_del_flag")
	drop table guest_del_flag;
create table  guest_del_flag
(
	no    		char(7)		 						not null,		// 档案号:电脑自动生成 
	lastdate		datetime								not null,		// 最新修改时间
   crtby       char(10)								not null,		// 建立 
	crttime     datetime 		default getdate()	not null,
	bdate			datetime								not null 
)
exec sp_primarykey guest_del_flag,no
create unique index index1 on guest_del_flag(no)
create index index2 on guest_del_flag(crttime)
;
