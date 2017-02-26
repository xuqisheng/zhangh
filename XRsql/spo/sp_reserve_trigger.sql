
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
	@meet				char(1),							-- �������
	@type				char(1),							-- 0-�ò�, 1-����
	@code				char(5),
	@pccode			char(3),
	@empno			char(10),
	@btime			datetime,                  -- ��ʼʱ��
	@etime			datetime,						-- ����ʱ��
	@date0			datetime,
	@stats			money,							-- ��׼
	@statstype		char(1),							-- 1 -��, 2-��
	@guests			int								-- ����


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



