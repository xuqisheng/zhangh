
/* 维护一帐号的发生额等(不支持'帐务转储') */

if exists(select * from sysobjects where name = 'p_gl_accnt_rebuild')
	drop proc p_gl_accnt_rebuild;

create proc p_gl_accnt_rebuild
	@accnt		char(7),
	@retmode		char(1),
	@msg			varchar(70) output
as
declare
	@class		char(3),
	@rmb_db		money  , @rmb_td		money, @rmb_od		money,
	@escr_db		money  , @escr_td		money, @escr_od	money,
	@depr_cr		money  , @depr_tc		money, @depr_oc	money,
	@addrmb		money  , @addtr		money, @addor		money,
	@balance		money  ,
	@plastnumb	integer,
	@plastinumb	integer,
	@lastnumb	integer,
	@lastinumb	integer,
	@number		integer,
	@inumber		integer,
	@pccode		char(2),
	@servcode	char(1),
	@tofrom		char(2),
	@accntof		char(7),
	@charge		money  ,
	@credit		money  ,
	@bdate		datetime,
	@bdate1		datetime,
	@ac_bdate	datetime,
	@ret			integer

select @bdate  = bdate, @bdate1 = bdate1 from sysdata
select @rmb_db = 0, @escr_db = 0, @depr_cr = 0, @addrmb = 0, @balance = 0, @plastnumb = 0, @plastinumb = 0
select @rmb_td = 0, @escr_td = 0, @depr_tc = 0, @addtr = 0 
select @rmb_od = 0, @escr_od = 0, @depr_oc = 0, @addor = 0, @ret = 0
exec p_hry_accnt_class @accnt, @class out
if substring(@class, 1, 1) in ('T', 'M', 'H')
	select @lastnumb = lastnumb, @lastinumb = lastinumb from master where accnt = @accnt
else if substring(@class, 1, 1) in ('G')
	select @lastnumb = lastnumb, @lastinumb = lastinumb from grpmst where accnt = @accnt
else if substring(@class, 1, 1) in ('C')
	select @lastnumb = lastnumb, @lastinumb = lastinumb from armst where accnt = @accnt
else
   return 1
declare c_rebuild cursor for
	select bdate, number, pccode, servcode, charge, credit, tofrom, accntof
		from account where accnt = @accnt order by number
open c_rebuild
fetch c_rebuild into @ac_bdate, @number, @pccode, @servcode, @charge, @credit, @tofrom, @accntof
while @@sqlstatus = 0
	begin
	select @plastnumb = @plastnumb + 1, @balance = @balance + @charge - @credit
	if @pccode in ('05', '06')
		begin
		select @depr_cr = @depr_cr + @credit
		if dateadd(day, 1, @bdate) = @bdate1
			begin
			if @ac_bdate <= @bdate 
				select @depr_tc = @depr_tc + @credit
			end
		else if @bdate = @bdate1
			begin
			if @ac_bdate < @bdate
				select @depr_oc = @depr_oc + @credit
			end
		end 
	else if @pccode = '03'
		begin
		select @addrmb = @addrmb + @credit
		if dateadd(day, 1, @bdate) = @bdate1
			begin
			if @ac_bdate <= @bdate 
				select @addtr = @addtr + @credit
			end
		else if @bdate = @bdate1
			begin
			if @ac_bdate < @bdate
				select @addor = @addor  + @credit
			end
		end 
	else
		begin
		select @rmb_db = @rmb_db + @charge
		if dateadd(day, 1, @bdate) = @bdate1
			begin
			if @ac_bdate <= @bdate 
				select @rmb_td = @rmb_td + @charge
			end
		else if @bdate = @bdate1
			begin
			if @ac_bdate < @bdate
				select @rmb_od = @rmb_od + @charge
			end
		if @servcode in ('S','T')
			begin
			select @escr_db = @escr_db - @charge
			if dateadd(day, 1, @bdate) = @bdate1
				begin
				if @ac_bdate <= @bdate 
					select @escr_td = @escr_td - @charge
				end
			else if @bdate = @bdate1
				begin
				if @ac_bdate < @bdate
					select @escr_od = @escr_od - @charge
				end
			end 
		end
	update account set balance = @balance where accnt = @accnt and number = @number
	if @number <> @plastnumb
		begin
			/* 帐次 */
			update account set number = @plastnumb where accnt = @accnt and number = @number
			/* 包的帐次 */
			update account set pnumber = @plastnumb where accnt = @accnt and pnumber = @number
			/* 关联帐次 */
			update account set inumber = @plastnumb where accnt = @accnt and inumber = @number
			if @tofrom = 'TO'
				begin
					update account set inumber = @plastnumb
						where accnt = @accntof and inumber = @number and tofrom = 'FM' and accntof = @accnt
					if @@rowcount = 0
						update haccount set inumber = @plastnumb
						where accnt = @accntof and inumber = @number and tofrom = 'FM' and accntof = @accnt
				end
		end
	fetch c_rebuild into @ac_bdate, @number, @pccode, @servcode, @charge, @credit, @tofrom, @accntof
	end
close c_rebuild
deallocate cursor c_rebuild
if dateadd(day, 1, @bdate) = @bdate1
	begin
	if substring(@class, 1, 1) in ('T', 'M', 'H')
		update master set rmb_td = @rmb_td, escr_td = @escr_td, depr_tc = @depr_tc, addtr = @addtr
			where accnt = @accnt 
	else if substring(@class, 1, 1) in ('G')
		update grpmst set rmb_td = @rmb_td, escr_td = @escr_td, depr_tc = @depr_tc, addtr = @addtr
			where accnt = @accnt 
	else if substring(@class, 1, 1) in ('C')
		update armst set rmb_td = @rmb_td, escr_td = @escr_td, depr_tc = @depr_tc, addtr = @addtr
			where accnt = @accnt
	end
else if @bdate = @bdate1
	begin
	if substring(@class, 1, 1) in ('T', 'M', 'H')
		update master set rmb_od = @rmb_od, escr_od = @escr_od, depr_oc = @depr_oc, addor = @addor
			where accnt = @accnt 
	else if substring(@class, 1, 1) in ('G')
		update armst set rmb_od = @rmb_od, escr_od = @escr_od, depr_oc = @depr_oc, addor = @addor
			where accnt = @accnt 
	else if substring(@class, 1, 1) in ('C')
		update armst set rmb_od = @rmb_od, escr_od = @escr_od, depr_oc = @depr_oc, addor = @addor
			where accnt = @accnt 
	end
begin tran
save tran p_gl_accnt_rebuild_s1
if substring(@class, 1, 1) in ('T', 'M', 'H')
	update master set lastnumb = @plastnumb,
		rmb_db = @rmb_db, escr_db = @escr_db, depr_cr = @depr_cr, addrmb = @addrmb
		where accnt = @accnt and lastnumb = @lastnumb
else if substring(@class, 1, 1) in ('G')
   update grpmst set lastnumb = @plastnumb,
		rmb_db = @rmb_db, escr_db  = @escr_db, depr_cr = @depr_cr, addrmb = @addrmb
		where accnt = @accnt and lastnumb = @lastnumb
else if substring(@class, 1, 1) in ('C')
   update armst set lastnumb = @plastnumb,
		rmb_db = @rmb_db, escr_db = @escr_db, depr_cr = @depr_cr, addrmb = @addrmb
		where accnt = @accnt and lastnumb = @lastnumb
if @@rowcount = 0
	begin
	rollback tran p_gl_accnt_rebuild_s1
	select @ret = 1, @msg = '重建失败, 可能重建过程中有帐务发生'
	end
commit tran
if @retmode ='S'
	select @ret, @msg
return @ret
;

/* 设置帐号的允许记帐状态 */

if exists(select * from sysobjects where name = 'p_hry_accnt_getset_locksta')
	drop proc p_hry_accnt_getset_locksta;

create proc p_hry_accnt_getset_locksta
	@accnt	char(7),
   @empno   char(3),
   @getset  char(1),
   @retmode char(1),
   @locksta char(1)     out,
	@msg     varchar(60) out
as
declare 
   @ret     int,
   @empname char(12)
 
if @getset = 'S' and charindex(@locksta,'YN') = 0
   select @locksta = 'N'
select @empname = name from auth_login where empno=@empno
select @ret = 0,@msg=''
if substring(@accnt,1,1) = 'A'
   begin
   if exists(select 1 from armst where accnt = @accnt)
      begin
      if @getset ='G' 
         select @locksta = locksta from armst where accnt = @accnt
      else 
         update armst  set locksta = @locksta,cby=@empno,cbyname=@empname,logmark=logmark+1 where accnt = @accnt
      end 
   else
      select @ret=1
   end 
else if convert(int,substring(@accnt,2,3)) between 800 and 949
   begin
   if exists(select 1 from grpmst where accnt = @accnt)
      begin
      if @getset ='G' 
         select @locksta = locksta from grpmst where accnt = @accnt
      else 
         update grpmst  set locksta = @locksta,cby=@empno,cbyname=@empname,logmark=logmark+1 where accnt = @accnt
      end 
   else
      select @ret=1
   end 
else
   begin
   if exists(select 1 from master where accnt = @accnt)
      begin
      if @getset ='G' 
         select @locksta = locksta from master where accnt = @accnt
      else 
         update master set locksta = @locksta,cby=@empno,cbyname=@empname,logmark=logmark+1 where accnt = @accnt
      end 
   else
      select @ret=1
   end 
if @ret = 1
   select @msg = '帐号('+@accnt+')不存在' 
else if @getset = 'G' and charindex(@locksta,'YN') = 0
   select @locksta = 'N'
if @retmode = 'S'
   select @ret,@locksta,@msg
return @ret
;   

/*取帐号的允许记帐状态*/

if exists(select * from sysobjects where name = 'p_hry_accnt_locksta')
	drop proc p_hry_accnt_locksta;

create proc p_hry_accnt_locksta
	@accnt	char(7),
	@msg     varchar(60) out
as
declare 
   @ret     int ,
   @locksta char(1)

select @ret = 0
if substring(@accnt,1,1) = 'A'
   select @locksta = locksta from armst where accnt = @accnt
else if convert(int,substring(@accnt,2,3)) between 800 and 949
   select @locksta = locksta from grpmst where accnt = @accnt 
else
   select @locksta = locksta from master where accnt = @accnt 
//if charindex(@locksta,'Y') = 0 
//   select @ret = 1,@msg = '帐号('+@accnt+')不允许记帐,只能现金结算' 
return @ret
;   

/* 帐号归类 Changed For X5 */
if exists(select * from sysobjects where name = 'p_hry_accnt_class')
	drop proc p_hry_accnt_class;

create proc p_hry_accnt_class
	@accnt	char(10),
	@class	char(3)		out
as
declare @groupno	char(7)

if substring(@accnt,1,1) = 'A'
   begin
   select @class = 'C' from armst where accnt = @accnt 
   if @@rowcount = 0 
      select @class = 'ERR'
   end
else if convert(int,substring(@accnt,2,3)) between 800 and 949
   begin
   select @class = 'G'+class+src from grpmst where accnt = @accnt 
   if @@rowcount = 0 
      select @class = 'ERR'
   end
else if convert(int,substring(@accnt,2,3)) >= 950
   begin
   select @class = 'H' from master where accnt = @accnt 
   if @@rowcount = 0 
      select @class = 'ERR'
   end
else
   begin
   select @groupno = groupno from master where accnt = @accnt
   if @@rowcount = 1
      begin
	   if rtrim(@groupno) is not null
//		   select @class = 'M'+class+src from grpmst where accnt = @groupno 
		   select @class = 'M  ' from grpmst where accnt = @groupno 
	   else
//		   select @class = 'T'+class+src from master where accnt = @accnt 
		   select @class = 'T  ' from master where accnt = @accnt 
	   end
   else
	   select @class = 'ERR'
   end
if @class = 'ERR'
   return 1
else
   return 0
;   
	
/*费用或款项明细的归类 Changed For X5 */

if  exists(select * from sysobjects where name = 'p_hry_accnt_value_class')
	drop proc p_hry_accnt_value_class;

create proc p_hry_accnt_value_class
	@code				char(3),				/*费用码(定金:97,98;99:结账付款;其它:费用)*/
	@charge			money,				/*借方*/
	@credit			money,				/*贷方*/
	@rmb_db			money	out,			/*借方，费用*/
	@escr_db			money	out,			/*借方，逃帐*/
	@depr_cr			money	out,			/*贷方，定金*/
	@addrmb			money	out			/*贷方，结算追加款*/
as
	select @rmb_db = 0, @escr_db = 0, @depr_cr = 0, @addrmb = 0
	if substring(@code,1,2) in ('97','98')
	   select @depr_cr = @credit
	else
	if substring(@code,1,2) = '99'
	   select @addrmb = @credit
	else
    begin
	   select @rmb_db = @charge
	   if substring(@code,3,1) in ('S','T')
			select @escr_db = @charge * -1
	end
	return 0
;

/*获得帐号的lastnumb*/

if exists(select * from sysobjects where name = 'p_hry_get_mstinfo')
   drop proc p_hry_get_mstinfo;

create proc p_hry_get_mstinfo		
	@accnt 		char(7)
as
declare @class	char(3)


exec p_hry_accnt_class @accnt,@class out

if substring(@class,1,1) in ('T','M','H')
   select sta,lastnumb,balance = rmb_db - depr_cr - addrmb  from master where accnt = @accnt
else if substring(@class,1,1) in ('G')
   select sta,lastnumb,balance = rmb_db - depr_cr - addrmb  from grpmst where accnt = @accnt
else if substring(@class,1,1) in ('C')
   select sta,lastnumb,balance = rmb_db - depr_cr - addrmb  from armst where accnt = @accnt
return 0
;

/*获得帐号的定金结余*/
if exists(select * from sysobjects where name = 'p_hry_get_deposit')
   drop proc p_hry_get_deposit;

create proc p_hry_get_deposit
	@accnt 		char(7)
as
declare @class	char(3)


exec p_hry_accnt_class @accnt,@class out

if substring(@class,1,1) in ('T','M','H')
   select depr_cr from master where accnt = @accnt
else if substring(@class,1,1) in ('G')
   select depr_cr from grpmst where accnt = @accnt
else if substring(@class,1,1) in ('C')
   select depr_cr from armst where accnt = @accnt
return 0
;


/*获得帐号的帐号状态*/
if exists(select * from sysobjects where name = 'p_hry_accnt_get_sta')
   drop proc p_hry_accnt_get_sta;

create proc p_hry_accnt_get_sta		
	@accnt 		char(7),
	@ret_mode	char(1) = 'S',       /*'S' select,'R' return*/
	@sta		char(1)	= NULL	out
as
declare @class	char(3)


exec p_hry_accnt_class @accnt,@class out

if substring(@class,1,1) in ('T','M','H')
   select @sta = sta from master where accnt = @accnt
else if substring(@class,1,1) in ('G')
   select @sta = sta from grpmst where accnt = @accnt
else if substring(@class,1,1) in ('C')
   select @sta  = sta from armst where accnt = @accnt

if @ret_mode = 'S'
   select @sta
return 0
;

///* 获得帐号的帐单所需要素 */
//
//if exists(select * from sysobjects where name = 'p_hry_accnt_bill_elements' and type ='P')
//   drop proc p_hry_accnt_bill_elements;
//
//create proc  p_hry_accnt_bill_elements
//   @accnt 	 char(7)
//as
//declare 
//   @class    char(3),
//   @name     varchar(255),
//   @fir      varchar(255),
//   @roomno   varchar(5),
//   @arr      datetime,
//   @dep      datetime,
//   @appl     varchar(60),
//   @ref      varchar(60),
//   @tranlog  varchar(10)
//exec p_hry_accnt_class @accnt,@class out
//if substring(@class,1,1) in ('T','M','H')
//   begin
//   declare @singlename varchar(50)
//   declare c_accnt_get_name cursor for select rtrim(name) from guest where accnt=@accnt order by guestid
//   open  c_accnt_get_name
//   fetch c_accnt_get_name into @singlename
//   while @@sqlstatus = 0
//	  begin
//	  select @name = @name+','+@singlename
//	  fetch c_accnt_get_name into @singlename
//	  end
//   close c_accnt_get_name
//   deallocate cursor c_accnt_get_name
//   if substring(@name,1,1) = ','
//	  select @name = substring(@name,2,254)
//   select @tranlog=tranlog,@appl = applicant,@ref=ref from master where accnt = @accnt 
//   if datalength(@tranlog) >= 3 and @tranlog not like '[A-Z][A-Z]%'
//      select @fir = @appl 
//   else
//      begin
//      select @fir = rtrim(fir) from guest where
//                    guestid = (select min(b.guestid) from guest b where b.accnt=@accnt)
//      end
//   if rtrim(@tranlog) is not null and rtrim(@ref) is not null 
//      select @fir = @fir+'('+rtrim(@ref)+')'
//   select @roomno=roomno,@arr=arr,@dep=dep from master where accnt = @accnt 
//   end 
//else if substring(@class,1,1) in ('G')
//   select @name = name,@fir=appl1,@roomno='',@arr=arr,@dep=dep from grpmst where accnt = @accnt
//else if substring(@class,1,1) in ('C')
//   select @name = name,@fir='',@roomno='',@arr=arr,@dep=dep from armst where accnt = @accnt
//select @name,@fir,@roomno,@arr,@dep
//return 0
//;
//
//
/*获得帐号的名称*/
if exists(select * from sysobjects where name = 'p_hry_accnt_get_name' and type ='P')
	drop proc p_hry_accnt_get_name;

create proc  p_hry_accnt_get_name
	@accnt			char(14)
as

declare
	@guestid			char(7),
	@class			char(3),
	@name				varchar(60),
	@singlename		varchar(50)

exec p_hry_accnt_class @accnt,@class out

if substring(@class,1,1) in ('T','M','H')
	select @name = ref from master where accnt = @accnt
else if substring(@class,1,1) in ('G')
	select @name = name from grpmst where accnt = @accnt
else if substring(@class,1,1) in ('C')
	select @name = name from armst where accnt = @accnt
select @name
return 0
;

///*获得帐号的打印单位*/
//if exists(select * from sysobjects where name = 'p_hry_accnt_get_firetc' and type ='P')
//   drop proc p_hry_accnt_get_firetc;
//
//create proc  p_hry_accnt_get_firetc
//   @accnt 	 char(7)
//as
//
//declare
//   @class	char(3),
//   @name	   varchar(130),
//   @appl    varchar(60),
//   @ref     varchar(60),
//   @tranlog varchar(10)
//
//exec p_hry_accnt_class @accnt,@class out
//
//if substring(@class,1,1) in ('T','M','H')
//   begin
//   select @tranlog=tranlog,@appl = applicant,@ref=ref from master where accnt = @accnt 
//   if datalength(@tranlog) >= 3 
//      select @name = @appl 
//   else
//      select @name = rtrim(fir) from guest where accnt=@accnt order by guestid desc
//   if rtrim(@tranlog) is not null and rtrim(@ref) is not null 
//      select @name = @name+'('+rtrim(@ref)+')'
//   end 
//else if substring(@class,1,1) in ('G')
//   select @name = appl1 from grpmst where accnt = @accnt
//else if substring(@class,1,1) in ('C')
//   select @name = ''
//select @name
//return 0
//;
//
//
/*获得帐号的付款方式*/
if  exists(select * from sysobjects where name = 'p_hry_accnt_get_paymth')
	drop proc p_hry_accnt_get_paymth;

create proc p_hry_accnt_get_paymth		
	@accnt 	char(7)
as
declare @class	char(3),
        @paymth	char(3)

exec p_hry_accnt_class @accnt,@class out

if substring(@class,1,1) in ('T','M','H')
   select @paymth = substring(paycode,1,3) from master where accnt = @accnt
else if substring(@class,1,1) in ('G')
   select @paymth = substring(paycode,1,3) from grpmst where accnt = @accnt
select @paymth
return 0;

/*设置帐号的付款方式*/

if  exists(select * from sysobjects where name = 'p_gl_accnt_set_paymth')
	drop proc p_gl_accnt_set_paymth;

create proc p_gl_accnt_set_paymth		
	@accnt		char(7),
	@paymth		char(4),
	@cby			char(3),
	@cbyname		char(12)
as

declare 
	@class		char(3)

exec p_hry_accnt_class @accnt, @class out
if substring(@class, 1, 1) in ('T', 'M', 'H')
	update master set paycode = @paymth, cby = @cby, cbyname = @cbyname, changed = getdate(), logmark = logmark + 1
		where accnt = @accnt
else if substring(@class, 1, 1) in ('G')
	update grpmst set paycode = @paymth, cby = @cby, cbyname = @cbyname, changed = getdate(), logmark = logmark + 1
		where accnt = @accnt
return 0;


/*获取帐号的客欠*/
if exists(select * from sysobjects where name = 'p_hry_accnt_get_rmb')
   drop proc p_hry_accnt_get_rmb;

create proc p_hry_accnt_get_rmb		
	@accnt 	char(7)
as
declare @class  char(3),@rmb money

exec p_hry_accnt_class @accnt,@class out

if substring(@class,1,1) in ('T','M','H')
   select @rmb = rmb_db - depr_cr - addrmb from master where accnt = @accnt
else if substring(@class,1,1) = 'G' 
   select @rmb = rmb_db - depr_cr - addrmb from grpmst where accnt = @accnt
else if substring(@class,1,1) = 'C'
   select @rmb = rmb_db - depr_cr - addrmb from armst  where accnt = @accnt
select @rmb
return 0
;


/*维护帐号的客欠*/
if exists(select * from sysobjects where name = 'p_hry_accnt_set_rmb')
   drop proc p_hry_accnt_set_rmb;

create proc p_hry_accnt_set_rmb
	@accnt	char(7),
	@code	   char(3),	/*费用码*/
	@charge	money,		/*借方*/
	@credit	money		/*贷方*/
as
declare
   @rmb_db	money,		/*借方，费用*/
   @escr_db	money,		/*借方，逃帐*/
   @depr_cr	money,		/*贷方，定金*/
  	@addrmb	money,		/*贷方，结算追加款*/
   @class	char(3)

exec p_hry_accnt_class @accnt,@class out
exec p_hry_accnt_value_class @code,@charge,@credit,@rmb_db out,
                            @escr_db out,@depr_cr out,@addrmb out

if substring(@class,1,1) in ('T','M','H')
   update master set rmb_db = rmb_db + @rmb_db,escr_db = escr_db + @escr_db,
			         depr_cr = depr_cr + @depr_cr,addrmb = addrmb + @addrmb
else if substring(@class,1,1) in ('G')
   update grpmst set rmb_db = rmb_db + @rmb_db,escr_db = escr_db + @escr_db,
    			     depr_cr = depr_cr + @depr_cr,	addrmb = addrmb + @addrmb
			     where accnt = @accnt 
else if substring(@class,1,1) in ('C')
   update armst set rmb_db = rmb_db + @rmb_db,escr_db = escr_db + @escr_db,
		            depr_cr = depr_cr + @depr_cr,addrmb = addrmb + @addrmb
		        where accnt = @accnt
return 0
;

/*  记帐时主单锁定:只锁定而暂不更新 */
/*  主要用于自动转帐时先更新目的帐号,但源帐号必须首先有效*/
/*  注意死锁的检测*/
if exists(select * from sysobjects where name = 'p_hry_lock_master' and type='P')
	drop proc p_hry_lock_master;

create proc p_hry_lock_master
	@accnt	    char(10),            /*帐号*/
   @operation   char(2),
	@roomno	    char(5)		out,    /*房号跟踪*/
	@groupno	    char(7)	    out,    /*团号跟踪*/
	@class  	    char(3)	    out,    /*类别跟踪*/
   @msg         varchar(60) out
as
declare
    @ret	    int,
    @statype    char(1),
    @sta        char(1)
select @statype = substring(@msg,1,1)
begin tran
save tran p_hry_lock_master_s1
exec p_hry_accnt_class @accnt,@class out
select @ret = 0,@msg=''
if @class = 'ERR'
   select @ret = 1,@msg='帐号p_hry_lock_master(1)'+@accnt+'不存在'
else if substring(@class,1,1) in ('T','M','H')
   begin
   if substring(@class,1,1) = 'M' and @operation='IN' 
      begin
      select @groupno = groupno from master where accnt = @accnt 
      if exists (select 1 from grpmst where accnt = @groupno)
         update grpmst set sta = sta where accnt = @groupno
      end 
   update master set sta = sta where accnt = @accnt
   select @sta = sta from master where accnt = @accnt
   if @@rowcount = 0  
		select @ret=1,@msg = '帐号p_hry_lock_master(2)'+@accnt+'不存在'
   else if (@statype='-' and charindex(@sta,@msg) =0 or @statype<>'-' and charindex(@sta,@msg) > 0)
	  select @roomno=roomno,@groupno = groupno from master where accnt = @accnt
   else if charindex(@sta,'ODE') > 0 
		select @ret=1,@msg = '帐号'+@accnt+'已结帐'
   else 
	   select @ret = 1,@msg = '帐号'+@accnt+'相应状态不允许本交易发生,请检查'
   end   
else if substring(@class,1,1) in ('G')
   begin
   update grpmst set sta = sta where accnt = @accnt
   select @sta = sta from grpmst where accnt = @accnt
   if @@rowcount = 0  
		select @ret=1,@msg = '团体帐号'+@accnt+'不存在'
   else if (@statype='-' and charindex(@sta,@msg) =0 or @statype<>'-' and charindex(@sta,@msg) > 0)
      select @roomno=null,@groupno = null
   else if charindex(@sta,'ODE') > 0 
		select @ret=1,@msg = '团体帐号'+@accnt+'已结帐'
   else
	   select @ret = 1,@msg = '团体帐号'+@accnt+'相应状态不允许本交易发生,请检查'
   end
else if substring(@class,1,1) in ('C')
   begin
   update armst set sta = sta where accnt = @accnt
   select @sta = sta from armst where accnt = @accnt
   if @@rowcount = 0  
		select @ret=1,@msg = 'ＡＲ帐号'+@accnt+'不存在'
   else if (@statype='-' and charindex(@sta,@msg) =0 or @statype<>'-' and charindex(@sta,@msg) > 0)
      select @roomno=null,@groupno = null
   else if charindex(@sta,'ODE') > 0 
		select @ret=1,@msg = 'ＡＲ帐号'+@accnt+'已结帐'
   else
	   select @ret = 1,@msg = 'ＡＲ帐号'+@accnt+'相应状态不允许本交易发生,请检查'
   end
if @ret <>  0
   rollback tran p_hry_lock_master_s1
commit tran
return @ret
;

/*  记帐时主单锁定:注意次序 */

if exists(select * from sysobjects where name = 'p_hry_lock_two_master' and type='P')
	drop proc p_hry_lock_two_master;

create proc p_hry_lock_two_master
	@accnt1	  char(7),
	@accnt2   char(7)   
as
declare
   @ret	    int,
	@class1   char(3),
   @class2   char(3)
begin tran
save tran p_hry_lock_two_master_s1
exec p_hry_accnt_class @accnt1,@class1 out
exec p_hry_accnt_class @accnt2,@class2 out
select @ret = -1
if substring(@class1,1,1) in ('T','M','H')
   begin
   if substring(@class2,1,1) in ('T','M','H')
	  begin
	  if @accnt1 < @accnt2
		  begin
		  update master set sta = sta where accnt = @accnt2
		  update master set sta = sta where accnt = @accnt1
		  end
	  else
        begin
		  update master set sta = sta where accnt = @accnt1
		  update master set sta = sta where accnt = @accnt2
		  end
	  end
   else
	  begin
	  if substring(@class2,1,1) = 'G'
		 update grpmst set sta = sta where accnt = @accnt2
	  else
		 update armst  set sta = sta where accnt = @accnt2
	  update master set sta = sta where accnt = @accnt1
	  end
   end
else if substring(@class1,1,1) in ('G')
   begin
   if substring(@class2,1,1) in ('G')
	  begin
	  if @accnt1 < @accnt2
		  begin
		  update grpmst set sta = sta where accnt = @accnt2
		  update grpmst set sta = sta where accnt = @accnt1
		  end
	  else
        begin
		  update grpmst set sta = sta where accnt = @accnt1
		  update grpmst set sta = sta where accnt = @accnt2
		 end
	  end
   else if substring(@class2,1,1) in ('T','M','H')
      begin
	   update grpmst set sta = sta where accnt = @accnt1
	   update master set sta = sta where accnt = @accnt2
	   end
   else
      begin
	   update armst  set sta = sta where accnt = @accnt2
	   update grpmst set sta = sta where accnt = @accnt1
	   end
   end
else
   begin
   if substring(@class2,1,1) in ('C')
	  begin
	  if @accnt1 < @accnt2
		  begin
		  update armst set sta = sta where accnt = @accnt2
		  update armst set sta = sta where accnt = @accnt1
		  end
	  else
        begin
		  update armst set sta = sta where accnt = @accnt1
		  update armst set sta = sta where accnt = @accnt2
		  end
	  end
   else
	  begin
	  update armst set sta = sta where accnt = @accnt1
	  if substring(@class2,1,1) in ('T','M','H')
		  update master set sta = sta where accnt = @accnt2
	  else
		  update grpmst set sta = sta where accnt = @accnt2
     end 
   end
commit tran
return 0;

/* 新帐务客人主单 */

if exists(select * from sysobjects where name = "p_hry_accnt_mstinfo_new")
	drop proc p_hry_accnt_mstinfo_new;

create proc p_hry_accnt_mstinfo_new
	@accnt		char(7)
as

declare
	@onename		varchar(50), 
	@name1		varchar(50), 
	@name2		varchar(50), 
	@name3		varchar(50), 
	@vip1			char(1), 
	@vip2			char(1), 
	@vip3			char(1), 
	@his1			char(1), 
	@his2			char(1), 
	@his3			char(1), 
	@ref			varchar(254), 
	@to_accnt	char(7), 
	@rtdescript	char(50), 
	@qtrate		money, 
	@discount	money, 
	@discount1	money, 
	@nation		char(3), 
	@vip			char(1), 
	@haccnt		char(7), 
	@cnt			integer, 
	@message		varchar(254), 
	@rmcode		char(3), 
	@rmcodedes	varchar(30)


select @cnt = 0, @name1 = '', @vip1 = 'F', @his1 = 'F', @name2 = '', @vip2 = 'F', @his2 = 'F', @name3 = '', @vip3 = 'F', @his3 = 'F'
declare c_name cursor for select ltrim(name), nation, vip, haccnt from guest where accnt = @accnt order by guestid
open c_name
fetch c_name into @onename, @nation, @vip, @haccnt
while @@sqlstatus = 0
	begin
	select @cnt = @cnt + 1
	if @cnt = 1 
		begin
		select @name1 = substring(@onename+'            ', 1, 12)+' - ['+@nation+']', @vip1 = isnull(rtrim(@vip), 'F')
		if rtrim(@haccnt) is null
			select @his1 = 'F'
		else
			select @his1 = 'T'
		end
	else if @cnt = 2 
		begin
		select @name2 = substring(@onename+'            ', 1, 12)+' - ['+@nation+']', @vip2 = isnull(rtrim(@vip), 'F')
		if rtrim(@haccnt) is null
			select @his2 = 'F'
		else
			select @his2 = 'T'
		end
	else if @cnt = 3
		begin
		select @name3 = substring(@onename+'            ', 1, 12)+' - ['+@nation+']', @vip3 = isnull(rtrim(@vip), 'F')
		if rtrim(@haccnt) is null
			select @his3 = 'F'
		else
			select @his3 = 'T'
		end
	else
		select @name3 = @name3 + '.'

	fetch c_name into @onename, @nation, @vip, @haccnt
	end 
close c_name
deallocate cursor c_name
//            
select @qtrate = qtrate, @discount = discount, @discount1 = discount1 
	from master where accnt = @accnt
if @discount != 0 or @discount1 != 0
	begin
	select @rtdescript = '原价:' + ltrim(convert(char(10), @qtrate)) + '元;'
	if @discount != 0 
		select @rtdescript = @rtdescript + '优惠:' + ltrim(convert(char(10), @discount)) + '元'
	else
		select @rtdescript = @rtdescript + '优惠:' + ltrim(convert(char(10), convert(int, @discount1 * 100))) + '%'
	end
//
if exists (select to_accnt from accnt_ab where accnt = @accnt and type = '4' and pccodes != '-;')
	begin
	declare c_transfer cursor for select distinct to_accnt from accnt_ab where accnt = @accnt and type = '4' and pccodes != '-;' order by to_accnt
	open c_transfer
	fetch c_transfer into @to_accnt
	while @@sqlstatus = 0
		begin
		select @ref = substring(@ref + ', ' + @to_accnt , 1 , 254)
		fetch c_transfer into @to_accnt
		end 
	close c_transfer
	deallocate cursor c_transfer
	select @ref = '自动转帐到' + rtrim(substring(@ref, 2, 254)) + ';'
	end
if exists (select b.accnt from master a, accnt_ab b where a.accnt = @accnt and a.groupno = b.accnt
	and b.type = '2' and b.pccodes != '-;')
	select @ref = rtrim(@ref) + '团体主单为其付帐;'
//
declare c_message cursor for select convert(varchar(254), content) from message 
	where type = '62' and accnt = @accnt order by msgno desc
open c_message
fetch c_message into @message
while @@sqlstatus = 0
	begin
	select @ref = @ref + @message
	fetch c_message into @message
	end
close c_message
deallocate cursor c_message
//
select @rmcode = right('000'+ltrim(rtrim(convert(char(3), ratemode))), 3) from master where accnt = @accnt
if rtrim(@rmcode) is null
	select  @rmcode = '000'
if exists(select 1 from ratemode_name where code = @rmcode and accnt = @accnt)
	select @rmcodedes = descript from ratemode_name where code = @rmcode and accnt = @accnt
else if exists(select 1 from ratemode_name where code = @rmcode)
	select @rmcodedes = descript from ratemode_name where code = @rmcode
else
	select @rmcodedes = ''
select @cnt = (select count(1) from message a, master b where a.accnt = @accnt and a.type = '0' and a.accnt = b.accnt and a.tranmark = 'F')
//
select a.accnt, a.sta, a.roomno, a.arr, a.dep, a.araccnt, 
	name1 = @name1, vip1 = @vip1, his1 = @his1, name2 = @name2, vip2 = @vip2, his2 = @his2, 
	name3 = @name3, vip3 = @vip3, his3 = @his3, mail = @cnt, a.tranlog + ', ' + src, 
	a.applicant, @ref, a.groupno, a.srqs, a.paycode, rate = a.setrate * (1 - a.discount1), 
	a.extrabed, a.rtreason, a.locksta, a.pcrec, @rtdescript, @rmcodedes, limit, credcode, ref
	from master a where a.accnt = @accnt
return 0;
