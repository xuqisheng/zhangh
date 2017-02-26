
IF OBJECT_ID('p_gds_hs_excl') IS NOT NULL
    DROP PROCEDURE p_gds_hs_excl
;
create proc p_gds_hs_excl
as
-- ------------------------------------------------------------------------------------
-- 客房中心夜审数据备份
-- ------------------------------------------------------------------------------------

declare	@bdate			datetime
select  	@bdate = bdate1 from sysdata

begin tran

-- 存储已经解除的维修房记录
insert hrm_ooo select * from rm_ooo where charindex(status, 'O,X') > 0
delete rm_ooo where charindex(status, 'O,X') > 0

-- 存储已经领取的失物招领记录
insert hswrep select * from swrep where charindex(sta, 'O,X') > 0
insert hswreg select * from swreg where charindex(sta, 'O,X') > 0
delete swrep where charindex(sta, 'O,X') > 0
delete swreg where charindex(sta, 'O,X') > 0
commit tran

-- 单据号码的更新
begin tran
update hs_sysdata set mbbase = datepart(yy, @bdate) % 100 * 100000000.0 + datepart(mm, @bdate) * 1000000.0 + datepart(dd, @bdate) * 10000.0 + 1
update hs_sysdata set xhbase = datepart(yy, @bdate) % 100 * 100000000.0 + datepart(mm, @bdate) * 1000000.0 + datepart(dd, @bdate) * 10000.0 + 1
update hs_sysdata set sbbase = datepart(yy, @bdate) % 100 * 100000000.0 + datepart(mm, @bdate) * 1000000.0 + datepart(dd, @bdate) * 10000.0 + 1
update hs_sysdata set xybase = datepart(yy, @bdate) % 100 * 100000000.0 + datepart(mm, @bdate) * 1000000.0 + datepart(dd, @bdate) * 10000.0 + 1
update hs_sysdata set oobase = datepart(yy, @bdate) % 100 * 100000000.0 + datepart(mm, @bdate) * 1000000.0 + datepart(dd, @bdate) * 10000.0 + 1
update hs_sysdata set swbase = datepart(yy, @bdate) % 100 * 100000000.0 + datepart(mm, @bdate) * 1000000.0 + datepart(dd, @bdate) * 10000.0 + 1
update hs_sysdata set pcbase = datepart(yy, @bdate) % 100 * 100000000.0 + datepart(mm, @bdate) * 1000000.0 + datepart(dd, @bdate) * 10000.0 + 1
commit tran

return 0
;
