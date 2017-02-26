/* ��̯����ʱ�� */
if exists (select * from sysobjects where name ='apportion_jie' and type ='U')
	drop table apportion_jie;

create table apportion_jie
(
	pc_id				char(4)	not null,							/* IP��ַ */
	accnt				char(10)	not null,							/* �ʺ�(ǰ̨)
																				�˵���(�ۺ�����)
																				��ˮ��(��������) */
	number			integer	default 0 not null,				/* �д� */
	pccode			char(5)	not null,							/* ������ */
	refer				char(15) null,									/* tag(ǰ̨)
																				code(�ۺ�����) */
	charge			money		default 0 not null				/* ��� */
)
exec sp_primarykey apportion_jie, pc_id, accnt, number
create unique index index1 on apportion_jie(pc_id, accnt, number)
;

if exists (select * from sysobjects where name ='apportion_dai' and type ='U')
	drop table apportion_dai;

create table apportion_dai
(
	pc_id				char(4)	not null,							/* IP��ַ */
	paycode			char(5)	not null,							/* ���ʽ */
	credit			money		default 0 not null,				/* ��� */
	key0				char(3)	null,									/* �Ż���Ա���� */
	accnt				char(10)	not null								/* �ʺ�(ǰ̨)
																				�˵���(�ۺ�����)
																				��ˮ��(��������) */
)
exec sp_primarykey apportion_dai, pc_id, paycode, key0, accnt
create unique index index1 on apportion_dai(pc_id, paycode, key0, accnt)
;

if exists (select * from sysobjects where name ='apportion_jiedai' and type ='U')
	drop table apportion_jiedai;

create table apportion_jiedai
(
	pc_id				char(4)	not null,							/* IP��ַ */
	accnt				char(10)	not null,							/* �ʺ�(ǰ̨)
																				�˵���(�ۺ�����)
																				��ˮ��(��������) */
	number			integer	default 0 not null,				/* �д� */
	pccode			char(5)	not null,							/* ������ */
	refer				char(15) null,									/* tag(ǰ̨)
																				code(�ۺ�����) */
	charge			money		default 0 not null,				/* ��� */
	paycode			char(5)	not null,							/* ���ʽ */
	key0				char(3)	default '' null					/* �Ż���Ա���� */
)
exec sp_primarykey apportion_jiedai, pc_id, accnt, number, paycode, key0
create unique index index1 on apportion_jiedai(pc_id, accnt, number, paycode, key0)
;

/* ��̯ */
if exists ( select * from sysobjects where name = 'p_gl_audit_apportion' and type ='P')
	drop proc p_gl_audit_apportion;
create proc p_gl_audit_apportion
	@pc_id			char(4), 
	@pccode			char(5) = '010'
as

declare
	@this				money, 
	@sum				money, 
	@paycode			char(5), 
	@key0				char(3), 
	@accnt			char(10), 
	@number			integer, 
	@refer			char(15), 
	@opccode			char(5), 
	@orefer			char(15), 
	@onumber			integer, 
	@countjie		integer, 
	@countdai		integer, 
	@mcredit			money, 
	@charge			money,
	@credit			money

select @countjie = isnull((select count(1) from apportion_jie where pc_id = @pc_id), 0)
select @countdai = isnull((select count(1) from apportion_dai where pc_id = @pc_id), 0)
select @mcredit = isnull((select sum(credit) from apportion_dai where pc_id = @pc_id), 0)
declare charge_cursor cursor for
	select accnt, number, pccode, refer, charge from apportion_jie 
	where pc_id = @pc_id and charge != 0 and rtrim(accnt) is not null
	order by accnt, number
declare credit_cursor cursor for
	select paycode, key0, sum(credit) from apportion_dai 
	where pc_id = @pc_id and credit != 0
	group by paycode, key0
open credit_cursor
fetch credit_cursor into @paycode, @key0, @credit
// �跽(����)Ϊ��
if round(@mcredit, 2) = 0
	begin
	if @countjie = 0
		insert apportion_jiedai select @pc_id, accnt, 0, @pccode, '', credit, paycode, key0
			from apportion_dai where pc_id = @pc_id and rtrim(accnt) is not null
	else if @countdai = 0
		insert apportion_jiedai select @pc_id, accnt, number, pccode, refer, charge, '901', ''
			from apportion_jie where pc_id = @pc_id and rtrim(accnt) is not null
	else
		begin
		insert apportion_jiedai select @pc_id, accnt, 0, @pccode, '', credit, paycode, key0
			from apportion_dai where pc_id = @pc_id and rtrim(accnt) is not null
		insert apportion_jiedai select @pc_id, accnt, number, pccode, refer, charge, '901', ''
			from apportion_jie where pc_id = @pc_id and rtrim(accnt) is not null
		end
	end
else
	// ��̯
	begin
	while @@sqlstatus = 0
		begin
		select @sum = 0
		open charge_cursor
		fetch charge_cursor into @accnt, @number, @pccode, @refer, @charge
		while @@sqlstatus = 0
			begin
			if rtrim(@accnt) is  null continue // gds
			if @opccode is null and @charge <> 0 
				select @opccode = @pccode, @onumber = @number, @orefer = @refer
			select @this = round(@charge * @credit / @mcredit * 1.0 , 2)
			if not exists (select 1 from apportion_jiedai where pc_id = @pc_id and accnt = @accnt 
				and number = @number and paycode = @paycode and key0 = @key0)
				insert apportion_jiedai values (@pc_id, @accnt, @number, @pccode, @refer, @this, @paycode, @key0)
			else
				update apportion_jiedai set charge = charge + @this where pc_id = @pc_id 
				and accnt = @accnt and number = @number and paycode = @paycode and key0 = @key0
			select @sum = @sum + @this
			fetch charge_cursor into @accnt, @number, @pccode, @refer, @charge
			end
		close charge_cursor 
		// ����
		if round(@sum, 2) <> round(@credit, 2) and rtrim(@accnt) is not null  // gds
			begin 
			if not exists (select 1 from apportion_jiedai where pc_id = @pc_id and accnt = @accnt 
				and number = @onumber and paycode = @paycode and key0 = @key0)
				insert apportion_jiedai values (@pc_id, @accnt, @onumber, @opccode, @orefer, @credit - @sum, @paycode, @key0)
			else
				update apportion_jiedai set charge = charge + @credit - @sum where pc_id = @pc_id 
				and accnt = @accnt and number = @onumber and paycode = @paycode and key0 = @key0
			end
		fetch credit_cursor into @paycode, @key0, @credit
		end
	end
close credit_cursor
deallocate cursor credit_cursor
deallocate cursor charge_cursor
/* ������������ϵ */
select @paycode = min(paycode) from apportion_dai where pc_id = @pc_id
select @key0 = min(key0) from apportion_dai where pc_id = @pc_id and paycode = @paycode
update apportion_jiedai set charge = charge
	- (select isnull(sum(charge), 0) from apportion_jiedai a 
		where a.pc_id = @pc_id and a.accnt = apportion_jiedai.accnt and a.number = apportion_jiedai.number)
	+ (select isnull(sum(charge), 0) from apportion_jie b 
		where b.pc_id = @pc_id and b.accnt = apportion_jiedai.accnt and b.number = apportion_jiedai.number)
	where accnt <> '' and paycode = @paycode and key0 = @key0
return
;
