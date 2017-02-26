if exists (select 1 from sysobjects where name = 'p_invoice4accnt' and type = 'P')
   drop procedure p_invoice4accnt
; 
--------------------------------------------------------------------------------
-- p_invoice4accnt
--------------------------------------------------------------------------------
create procedure p_invoice4accnt
	@accnt char(10),  
	@langid		int = 0 
as	
begin 
    
    create table #tmp 
	 (
		id					varchar(10)		not null,/*发票流水*/
		sta				char(1)			not null,/*类别 ，在basecode(invoice_sta) 中维护,单选   O结账|R预开|X作废 */
		staname     	varchar(50)  		 null, 
		tag				varchar(254)	not null,/*标志 用户自定义，在basecode(invoice_tag) 中维护,多选*/
	
		moduno			char(2)			not null,/*营业点 basecode=moduno*/
		invplace			char(10)			not null,/*开票点 basecode=invoice_place */  
		modunoname     varchar(50)  		 null, 
		invplacename   varchar(50)  		 null, 
	
		billno			char(10)				 null,/*该发票对应的结账单号*/   
		accnt       	char(10)  			 null,/*该发票对应的账号*/
		unitno       	char(10)  			 null,/*开票单位 = guest.no */
		unitname      	varchar(50)  		 null,/*开票单位名称 = guest.name or free input */

		inno        	varchar(16) 	not null, /*发票号*/
		credit     		money     			 null,/*金额*/ 
		remark			varchar(254)		 null,/*备注*/
		empno				varchar(10)		not null,/*用户*/
		crtdate			datetime 			 null /*时间*/
    )
    create table #tmp1 
	 (
		id					varchar(10)		not null 
	 )
 	 insert into #tmp1(id) 
		select id from invoice_op where accnt= @accnt  
 	 insert into #tmp1(id) 
		select a.id from invoice_op a,account b where a.billno <> '' and a.billno = b.billno and b.accnt = @accnt
 	 insert into #tmp1(id) 
		select a.id from invoice_op a,haccount b where a.billno <> '' and a.billno = b.billno and b.accnt = @accnt 

 	 insert into #tmp(id,sta,tag,moduno,modunoname,invplace,invplacename,billno,accnt,unitno,unitname,inno,credit,remark,empno,crtdate )
		select a.id,a.sta,a.tag,a.moduno,'',a.invplace,'',a.billno,a.accnt,a.unitno,a.unitname,b.inno,b.credit,b.remark,b.empno,b.crtdate 
		from invoice_op a ,invoice_opdtl b
		where a.id = b.id and a.id in(select id from #tmp1)
	if @langid = 0 
	begin
		update #tmp set staname = b.descript from #tmp a,basecode b where a.sta=b.code and b.cat='invoice_sta' 
		update #tmp set modunoname = b.descript from #tmp a,basecode b where a.moduno=b.code and b.cat='moduno' 
		update #tmp set invplacename = b.descript from #tmp a,basecode b where a.invplace=b.code and b.cat='invoice_place' 
	end
	else
	begin
		update #tmp set staname = b.descript1 from #tmp a,basecode b where a.sta=b.code and b.cat='invoice_sta' 
		update #tmp set modunoname = b.descript1 from #tmp a,basecode b where a.moduno=b.code and b.cat='moduno' 
		update #tmp set invplacename = b.descript1 from #tmp a,basecode b where a.invplace=b.code and b.cat='invoice_place' 
	end

	select * from #tmp order by id 
end
;

	 