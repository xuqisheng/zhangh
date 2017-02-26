// ------------------------------------------------------------------------------------
//		guest 更新触发器
// ------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_gds_guest_update' and type = 'TR')
	drop trigger t_gds_guest_update
;
create trigger t_gds_guest_update
   on guest for update
	as

begin

if update(logmark)   -- 注意，这里插入的是 deleted
	insert guest_log select deleted.* from deleted

declare 	@no  			char(7),
			@accnt		char(10),
			@roomno		char(5),
			@phonesta	char(1)

select @no = no, @accnt = '' from inserted 

if update(name) or update(sex) or update(lang)
begin

--  phone pms --> 修改宾客的姓名、语种等信息
	select @accnt = isnull((select min(accnt) from master where class='F' and sta='I' and haccnt=@no and accnt>@accnt), '')
	while @accnt <> ''
	begin
		select @roomno=roomno, @phonesta=substring(extra,6,1) from master where accnt=@accnt
		exec p_gds_phone_grade @roomno, 'grad', @phonesta, @accnt

		--clg for update guest name lgfl
      insert into lgfl select 'r_haccnt', 'rm:'+@roomno, @accnt+'-'+b.name+'#', @accnt+'-'+a.name+'#', a.cby, getdate(),'' from inserted a,deleted b where a.name<>b.name

		select @accnt = isnull((select min(accnt) from master where class='F' and sta='I' and haccnt=@no and accnt>@accnt), '')
	end
end

if update(name)
begin
	-- 分帐户的名称
	update subaccnt set name=b.name from master a, inserted b
		where a.haccnt=b.no and subaccnt.accnt=a.accnt 
			and subaccnt.type='5' and subaccnt=1
	update subaccnt set name=b.name from ar_master a, inserted b
		where a.haccnt=b.no and subaccnt.accnt=a.accnt 
			and subaccnt.type='5' and subaccnt=1

	-- master_des
	update master_des      set haccnt=a.name from inserted a where master_des.haccnt_o=a.no
	update master_des_till set haccnt=a.name from inserted a where master_des_till.haccnt_o=a.no
	update master_des_last set haccnt=a.name from inserted a where master_des_last.haccnt_o=a.no

	update master_des      set groupno=a.name from inserted a where master_des.haccnt_o=a.no and master_des.accnt like '[GM]%'
	update master_des_till set groupno=a.name from inserted a where master_des_till.haccnt_o=a.no and master_des_till.accnt like '[GM]%'
	update master_des_last set groupno=a.name from inserted a where master_des_last.haccnt_o=a.no and master_des_last.accnt like '[GM]%'

	update master_des      set groupno=a.name from inserted a, master b where master_des.groupno_o=b.accnt and b.haccnt=a.no
	update master_des_till set groupno=a.name from inserted a, master_till b where master_des_till.groupno_o=b.accnt and b.haccnt=a.no
	update master_des_last set groupno=a.name from inserted a, master_last b where master_des_last.groupno_o=b.accnt and b.haccnt=a.no

end

if update(unit)
begin
	-- master_des
	update master_des      set unit=a.unit from inserted a where master_des.haccnt_o=a.no and master_des.cusno_o=''
	update master_des_till set unit=a.unit from inserted a where master_des_till.haccnt_o=a.no and master_des_till.cusno_o=''
	update master_des_last set unit=a.unit from inserted a where master_des_last.haccnt_o=a.no and master_des_last.cusno_o=''
end

-- 团体主单
if (update(name) or update(name2) or update(vip) or update(country) or update(lang) or update(feature) or update(refer1))
	and exists(select 1 from master where accnt like '[GM]%' and haccnt=@no)
begin
	update guest set name=a.name, fname=a.fname,lname=a.lname,name2=a.name2,name3=a.name3,name4=a.name4,
		vip=a.vip,country=a.country,lang=a.lang,feature=a.feature,refer1=a.refer1 
	from inserted a, master b where a.no=b.haccnt and b.exp_s1=guest.no
end

end
;


// ------------------------------------------------------------------------------------
//		guest insert 触发器
// ------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_gds_guest_insert' and type = 'TR')
	drop trigger t_gds_guest_insert;
create trigger t_gds_guest_insert
   on guest for insert
	as
begin
-- GaoLiang 2004/11/10
insert lgfl select 'g_profile', no, '', no, cby, changed,'' from inserted
end
;


// ------------------------------------------------------------------------------------
//		guest delete 触发器
// ------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_gds_guest_delete' and type = 'TR')
   drop trigger t_gds_guest_delete;
