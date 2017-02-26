/*

边长杰说，在莫泰发现 sybase12.5中，while 语句有错误 - 参见下方的 p_bcj_crs_report_reb

但是我测试的情况似乎没有问题 p_111_test_while_syb12_5

*/
                                  
drop PROC p_111_test_while_syb12_5; 
create PROC p_111_test_while_syb12_5
AS
declare @begin_ datetime, @end_ datetime
select @begin_ = getdate()
select @end_=dateadd(dd, 10, @begin_) 
delete gdsmsg 
insert gdsmsg select @@version
insert gdsmsg select replicate('-', 200) 

insert gdsmsg select 'Begin->' + convert(char(20), @begin_, 111) 
insert gdsmsg select 'End  ->' + convert(char(20), @end_, 111) 

WHILE @begin_ <= @end_
BEGIN
	insert gdsmsg select convert(char(20), @begin_, 111) 
	SELECT @begin_ = DATEADD(DAY, 1, @begin_)
END
select * from gdsmsg 

RETURN 0;
exec  p_111_test_while_syb12_5 null, null, ''; 



/*
                                  
create PROC p_bcj_crs_report_reb
	@begin_ 				datetime,
	@end_ 				datetime,
	@hotelid 			varchar(20)

AS

DECLARE @tmpdate 		datetime


SELECT @tmpdate = bdate FROM sysdata
IF DATEDIFF(DAY, @begin_, @tmpdate) <= 0
	SELECT @begin_ = DATEADD(DAY,-1, @tmpdate)

IF DATEDIFF(DAY, @end_, @tmpdate) <= 0
	SELECT @end_ = DATEADD(DAY, -1, @tmpdate)

EXEC p_vegeta_crs_cleardata

WHILE @begin_ <= @end_
BEGIN

	exec p_bcj_crs_audit_analysis_reb @begin_, @hotelid

	exec p_bcj_audit_hotel_web_reb @begin_, @hotelid

	exec p_bcj_night_audit_reb @begin_, @hotelid

	exec p_bcj_crs_daily_report_reb @begin_, @hotelid

	exec p_bcj_crs_daily_report_web_reb @begin_, @hotelid

	exec p_bcj_emp_reserve_reb @begin_

	SELECT @begin_ = DATEADD(DAY, 1, @begin_)

END

SELECT 'OK'
RETURN 0;

*/

