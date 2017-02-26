/* �����ո���ϸ(�ȳ��±���) */
if exists ( select * from sysobjects where name = 'p_gl_accnt_detail_scjj2' and type ='P')
	drop proc p_gl_accnt_detail_scjj2;
create proc p_gl_accnt_detail_scjj2
	@pc_id			char(4), 
	@billno			char(10), 
	@descript1		char(54)
as
declare
	@count			integer

create table #detail_scjj
(
	deptno			char(5)	default '' not null,				/* ������ */
	descript			char(24)	default '' not null,				/* ��Ŀ���� */
	charge			money		default 0 not null				/* ��� */
)
insert #detail_scjj select deptno, descript, charge
	from detail_scjj where pc_id = @pc_id and billno = @billno and descript1 = @descript1
// �������в�������
select @count = count(1) from #detail_scjj
while @count < 20
	begin
	insert #detail_scjj values ('ZZZ', '', 0)
	select @count = @count + 1
	end
// ����㲹��
select @count = @count % 4
while @count > 0
	begin
	insert #detail_scjj values ('ZZZ', '', 0)
	select @count = @count - 1
	end
select descript, charge from #detail_scjj order by deptno
;
