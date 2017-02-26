IF OBJECT_ID('dbo.p_sc_getdatetimediff') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_getdatetimediff
    IF OBJECT_ID('dbo.p_sc_getdatetimediff') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_getdatetimediff >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_getdatetimediff >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_getdatetimediff
(
	@modu char(1),       --·µ»ØÄ£Ê½ d-day,h-hour,m_minute,s_second
   @begin_ datetime,
   @end_   datetime
)
as
declare
  @diff integer

if @modu='d'
	select @diff=datediff(day,@begin_,@end_)
if @modu='h'
	select @diff=datediff(hour,@begin_,@end_)
if @modu='m'
	select @diff=datediff(minute,@begin_,@end_)
if @modu='s'
	select @diff=datediff(second,@begin_,@end_)

select  @diff
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_getdatetimediff') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_getdatetimediff >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_getdatetimediff >>>'
;
