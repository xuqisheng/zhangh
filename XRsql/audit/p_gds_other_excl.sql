
IF OBJECT_ID('p_gds_other_excl') IS NOT NULL
    DROP PROCEDURE p_gds_other_excl
;
create proc p_gds_other_excl
as
declare	@bdate			datetime
select  @bdate = bdate1 from sysdata

---------------------------
--	ҹ����˶�ռ���֣�����
---------------------------

---------------------------
-- fec ��Ҷһ�
---------------------------
insert fec_hfolio select * from fec_folio
truncate table fec_folio

---------------------------
-- accnt pointer  ����ָ��
---------------------------
-- (ebase1 - fec)
update sysdata set ebase1 = datepart(yy, @bdate) % 100 * 100000000.0 + datepart(mm, @bdate) * 1000000.0 + datepart(dd, @bdate) * 10000.0 + 1
-- (ebase2 - fit accnt)
update sysdata set ebase2 = datepart(yy, @bdate) % 100 * 100000000.0 + datepart(mm, @bdate) * 1000000.0 + datepart(dd, @bdate) * 10000.0 + 1
-- (msbase - ԭ����Ԥ���ţ����ڲ�����)
update sysdata set msbase = datepart(yy, @bdate) % 100 * 100000000.0 + datepart(mm, @bdate) * 1000000.0 + datepart(dd, @bdate) * 10000.0 + 1
-- (ebase4 - business block)
update sysdata set ebase4 = datepart(yy, @bdate) % 100 * 100000000.0 + datepart(mm, @bdate) * 1000000.0 + datepart(dd, @bdate) * 10000.0 + 1

---------------------------
-- other 
---------------------------
-- ?


return 0
;