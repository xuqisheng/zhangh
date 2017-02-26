
if exists(select 1 from sysobjects where name = 't_cq_sp_reserve_update' and type ='TR')
	drop trigger t_cq_sp_reserve_update;
create trigger t_cq_sp_reserve_update
	on sp_reserve for update
as
declare
	@resno 			char(10),
	@bdate			datetime,
	@shift			char(1),
	@tables 			int,
	@guest			int,
	@sta				char(1),
	@meet				char(1),							-- 管理会议
	@type				char(1),							-- 0-用餐, 1-会议
	@code				char(5),
	@pccode			char(3),
	@empno			char(10),
	@btime			datetime,                  -- 开始时间
	@etime			datetime,						-- 结束时间
	@date0			datetime,
	@stats			money,							-- 标准
	@statstype		char(1),							-- 1 -人, 2-桌
	@guests			int								-- 人数


if update(logmark)
	insert into sp_reserve_log select * from deleted


;

if exists(select 1 from sysobjects where name = 't_cq_sp_reserve_delete' and type ='TR')
	drop trigger t_cq_sp_reserve_delete;
create trigger t_cq_sp_reserve_delete
	on sp_reserve for delete
as

declare 
	@resno 		char(10),
	@pccode		char(3),
	@bdate		datetime,
	@shift		char(1)

//insert into sp_reserve_log select * from deleted
;



