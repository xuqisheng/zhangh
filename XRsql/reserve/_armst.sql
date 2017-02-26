
// ----------------------------------------------------------------
// ��ͼ view  = armst 
//		--- ��ϧ��view ����ʹ�� union 
// ----------------------------------------------------------------

// ----------------------------------------------------------------
//	armst 
// ----------------------------------------------------------------
-- �����µ� ar ϵͳ��
if exists(select * from sysobjects where name = "armst")
	drop view armst;
if exists(select 1 from sysoption where catalog='hotel' and item='lic_buy.1' and charindex(',nar,', value)>0)
begin
	create view armst as 
		select a.accnt,b.sno,a.haccnt,b.name,b.name2,a.bdate,a.sta,a.arr,a.dep,a.limit,a.charge,a.credit,a.accredit,a.artag1,a.artag2
			from ar_master a, guest b where a.haccnt=b.no
end
;

-- �����ϵ� ar ϵͳ��
if exists(select 1 from sysoption where catalog='hotel' and item='lic_buy.1' and charindex(',oar,', value)>0)
begin
	create view armst as 
		select a.accnt,b.sno,a.haccnt,b.name,b.name2,a.bdate,a.sta,a.arr,a.dep,a.limit,a.charge,a.credit,a.accredit,a.artag1,a.artag2
			from master a, guest b where a.accnt like 'A%' and a.haccnt=b.no
end
;


// ----------------------------------------------------------------
//	harmst 
// ----------------------------------------------------------------
-- �����µ� ar ϵͳ��
if exists(select * from sysobjects where name = "armst")
	drop view harmst;
if exists(select 1 from sysoption where catalog='hotel' and item='lic_buy.1' and charindex(',nar,', value)>0)
begin
	create view harmst as 
		select a.accnt,b.sno,a.haccnt,b.name,b.name2,a.bdate,a.sta,a.arr,a.dep,a.limit,a.charge,a.credit,a.accredit,a.artag1,a.artag2
			from har_master a, guest b where a.haccnt=b.no
end
;

-- �����ϵ� ar ϵͳ��
if exists(select 1 from sysoption where catalog='hotel' and item='lic_buy.1' and charindex(',oar,', value)>0)
begin
	create view harmst as 
		select a.accnt,b.sno,a.haccnt,b.name,b.name2,a.bdate,a.sta,a.arr,a.dep,a.limit,a.charge,a.credit,a.accredit,a.artag1,a.artag2
			from hmaster a, guest b where a.accnt like 'A%' and a.haccnt=b.no
end
;

select * from armst ;
select * from harmst ;

