IF OBJECT_ID('dbo.p_sc_getactivity') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_getactivity
    IF OBJECT_ID('dbo.p_sc_getactivity') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_getactivity >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_getactivity >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_getactivity
                 @begin datetime,
                 @empno char(10),
                 @sta   char(1),
                 @mod   char(1)    --'1'   一天的活动    '2'   跨天的活动
as
create table #activity
(
 activityid     char(10),
 begintime      datetime,
 endtime        datetime,
 color          varchar(10)
)
select @empno=code from saleid where empno=@empno

if @mod='1' 
	begin
		if @sta='d' 
			insert #activity select activityid,begintime,endtime,color from sc_activitydetail where activityto=@empno and datediff(day,@begin,begintime)=0    and (del<>'T' or del is null)  and datediff(day,begintime,endtime)=0 order by begintime 
		else if @sta='w' 
			insert #activity select activityid,begintime,endtime,color from sc_activitydetail where activityto=@empno and ((datediff(day,@begin,begintime)>=0 and datediff(day,@begin,begintime)<7) or (datediff(day,@begin,begintime)<=0 and datediff(day,@begin,endtime)>=0))  and (del<>'T' or del is null) and datediff(day,begintime,endtime)=0 order by begintime 
		else if @sta='m'
			insert #activity select activityid,begintime,endtime,color from sc_activitydetail where activityto=@empno and ((datediff(day,@begin,begintime)>=0 and datediff(day,@begin,begintime)<31) or (datediff(day,@begin,begintime)<=0 and datediff(day,@begin,endtime)>=0)) and (del<>'T' or del is null) and datediff(day,begintime,endtime)=0 order by begintime 
	end
if @mod='2'
   begin
     	if @sta='d' 
			insert #activity select activityid,begintime,endtime,color from sc_activitydetail where activityto=@empno and (datediff(day,@begin,begintime)=0 or datediff(day,@begin,endtime)=0 or (datediff(day,@begin,begintime)<0 and datediff(day,@begin,endtime)>0))  and (del<>'T' or del is null) and datediff(day,begintime,endtime)>0 order by begintime 
		else if @sta='w' 
			insert #activity select activityid,begintime,endtime,color from sc_activitydetail where activityto=@empno and ((datediff(day,@begin,begintime)>=0 and datediff(day,@begin,begintime)<7) or (datediff(day,@begin,begintime)<=0 and datediff(day,@begin,endtime)>=0))  and  (del<>'T' or del is null) and datediff(day,begintime,endtime)>0 order by begintime 
		else if @sta='m'
			insert #activity select activityid,begintime,endtime,color from sc_activitydetail where activityto=@empno and ((datediff(day,@begin,begintime)>=0 and datediff(day,@begin,begintime)<=31) or (datediff(day,@begin,begintime)<=0 and datediff(day,@begin,endtime)>=0))  and (del<>'T' or del is null) and datediff(day,begintime,endtime)>0 order by begintime 
   end
select * from #activity
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_getactivity') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_getactivity >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_getactivity >>>'
;
