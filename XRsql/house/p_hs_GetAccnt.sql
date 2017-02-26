/*

	客房中心系统帐号获取

	( 返回值用 Output 方式传出,专供 Server 端调用 !!! )

	存储过程 p_hs_GetAccnt1 用于取得一个新的帐号,帐号类型取决于@type的取值.
		@type = 'MB'   表示取得当天最新可用 MINI ?单号,
		@type = 'XH'   表示取得当天最新可用 消耗   单号,
		@type = 'SB'   表示取得当天最新可用 设备   帐号,
		@type = 'XY'   表示取得当天最新可用 洗衣   帐号,
		@type = 'OO'   表示取得当天最新可用 维修   帐号,
		@type = 'SW'   表示取得当天最新可用 失物   帐号,
		@type = 'PC'   表示取得当天最新可用 赔偿   帐号,
		@type = 'HA'   表示取得当天最新可用 HA     帐号,
		@type = 'HB'   表示取得当天最新可用 HB     帐号,
		@type = 'HC'   表示取得当天最新可用 HC     帐号,
*/
if exists(select * from sysobjects where name = "p_hs_GetAccnt1" and type = 'P')
	drop proc p_hs_GetAccnt1                                               
;                                                
create  proc  p_hs_GetAccnt1                                                   
	@type		char(3),
	@accnt	char(10) out
as

if	@type not in ('MB','XH','SB','XY','OO','SW','PC','HA','HB','HC')
begin
	select @accnt = ""      //return ""
	return	1
end

begin	tran	
save	tran	p_hs_GetAccnt1_tran_1_1

if	@type = 'MB'
begin
	update	hs_sysdata set mbbase = mbbase + 1
	select 	@accnt = str(mbbase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'XH'
begin
	update	hs_sysdata set xhbase = xhbase + 1
	select 	@accnt = str(xhbase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'SB'
begin
	update	hs_sysdata set sbbase = sbbase + 1
	select 	@accnt = str(sbbase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'XY'
begin
	update	hs_sysdata set xybase = xybase + 1
	select 	@accnt = str(xybase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'SW'
begin
	update	hs_sysdata set swbase = swbase + 1
	select 	@accnt = str(swbase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'OO'
begin
	update	hs_sysdata set oobase = oobase + 1
	select 	@accnt = str(oobase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'PC'
begin
	update	hs_sysdata set pcbase = pcbase + 1
	select 	@accnt = str(pcbase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'HA'
begin
	update	hs_sysdata set habase = habase + 1
	select 	@accnt = str(habase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'HB'
begin
	update	hs_sysdata set hbbase = hbbase + 1
	select 	@accnt = str(hbbase - 1 ) from hs_sysdata
	goto LAB1
end
if	@type = 'HC'
begin
	update	hs_sysdata set hcbase = hcbase + 1
	select 	@accnt = str(hcbase - 1 ) from hs_sysdata
	goto LAB1
end

LAB1:
select @accnt = right('0000'+ltrim(@accnt), 10)                     

commit	tran 
return	0
;

/*
( 返回值用 select 方式传出, 专供 PowerBuilder 端调用 !!! )
*/
if exists(select * from sysobjects where name = "p_hs_GetAccnt" and type = 'P')
   drop proc p_hs_GetAccnt
;
create  proc  p_hs_GetAccnt                                                   
	@type	char(3)
as
declare @accnt    char(10),
        @ret     	int    
exec @ret = p_hs_GetAccnt1 @type,@accnt output
if @ret <> 0
   select @accnt = ""
select @accnt
return @ret
;
