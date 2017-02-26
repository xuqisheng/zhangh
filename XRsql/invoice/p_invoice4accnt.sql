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
		id					varchar(10)		not null,/*��Ʊ��ˮ*/
		sta				char(1)			not null,/*��� ����basecode(invoice_sta) ��ά��,��ѡ   O����|RԤ��|X���� */
		staname     	varchar(50)  		 null, 
		tag				varchar(254)	not null,/*��־ �û��Զ��壬��basecode(invoice_tag) ��ά��,��ѡ*/
	
		moduno			char(2)			not null,/*Ӫҵ�� basecode=moduno*/
		invplace			char(10)			not null,/*��Ʊ�� basecode=invoice_place */  
		modunoname     varchar(50)  		 null, 
		invplacename   varchar(50)  		 null, 
	
		billno			char(10)				 null,/*�÷�Ʊ��Ӧ�Ľ��˵���*/   
		accnt       	char(10)  			 null,/*�÷�Ʊ��Ӧ���˺�*/
		unitno       	char(10)  			 null,/*��Ʊ��λ = guest.no */
		unitname      	varchar(50)  		 null,/*��Ʊ��λ���� = guest.name or free input */

		inno        	varchar(16) 	not null, /*��Ʊ��*/
		credit     		money     			 null,/*���*/ 
		remark			varchar(254)		 null,/*��ע*/
		empno				varchar(10)		not null,/*�û�*/
		crtdate			datetime 			 null /*ʱ��*/
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

	 