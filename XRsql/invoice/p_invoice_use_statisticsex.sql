if exists (select 1 from sysobjects where name = 'p_invoice_use_statisticsex' and type = 'P')
   drop procedure p_invoice_use_statisticsex
; 
--------------------------------------------------------------------------------
-- p_invoice_use_statisticsex
--------------------------------------------------------------------------------
create procedure p_invoice_use_statisticsex
	@sta				char(1)			,/*类别*/
	@tag				varchar(254)	,/*标志*/
	@moduno			char(2),/*营业点 basecode=moduno*/
	@invplace		char(10),/*开票点 basecode=invoice_place */  
	@billno			char(10),/*该发票对应的结账单号*/   
	@accnt       	char(10),/*该发票对应的账号*/
	@unitno       	char(10),/*开票单位 = guest.no */
	@unitname      varchar(50),/*开票单位名称 = guest.name or free input */
	@credit0   		money,/*金额*/ 
	@credit1   		money,/*金额*/ 
	@empno			varchar(10),/*用户*/
	@bgndate	 		datetime,/*开始时间*/
	@enddate	 		datetime /*结束时间*/
as	
begin 
    create table #tmp 
	 (
		id					varchar(10)		not null,/*发票流水*/
		sta				char(1)			not null,/*状态类别 O结账|R预开|X作废*/
		tag				varchar(254)		 null,/*操作标志 用户自定义，在basecode(invoice_tag) 中维护,多选*/
		billno			char(10)				 null,/*该发票对应的结账单号*/   
		accnt       	char(10)  			 null,/*该发票对应的账号*/
		inno        	varchar(16) 	not null, /*发票号*/
		credit     		money     			 null,/*金额*/ 
		unitname      	varchar(50)  	    null,/*开票单位名称 = guest.name or free input */
		remark			varchar(254)		 null,/*备注*/
		empno				varchar(10)		not null,/*用户*/
		crtdate			datetime 			 null /*时间*/
    )
	insert into #tmp(id,sta,billno,accnt,inno,credit,unitname,remark,empno,crtdate )
		select a.id,a.sta,a.billno,a.accnt,b.inno,b.credit,a.unitname,b.remark,b.empno,b.crtdate 
		from invoice_op a ,invoice_opdtl b
		where a.id = b.id and 
				(a.sta = @sta or @sta = '') and
				(charindex(@tag,a.tag)>0 or @tag = '') and
				(a.moduno = @moduno or @moduno = '') and
				(a.invplace  = @invplace or @invplace = '') and
				(a.billno  = @billno or @billno = '') and
				(a.accnt  = @accnt or @accnt = '') and
				(a.unitno  = @unitno or @unitno = '') and
				(a.unitname  like @unitname+'%' or @unitname = '') and
				(a.credit >= @credit0 or @credit0=0) and 
				(a.credit <= @credit1 or @credit1 = 0) and 
				(a.empno  = @empno or @empno = '') and
				(a.crtdate >=@bgndate and a.crtdate <= @enddate)  
	select * from #tmp order by inno 
end
;


	 