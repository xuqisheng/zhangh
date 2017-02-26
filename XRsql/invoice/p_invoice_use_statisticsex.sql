if exists (select 1 from sysobjects where name = 'p_invoice_use_statisticsex' and type = 'P')
   drop procedure p_invoice_use_statisticsex
; 
--------------------------------------------------------------------------------
-- p_invoice_use_statisticsex
--------------------------------------------------------------------------------
create procedure p_invoice_use_statisticsex
	@sta				char(1)			,/*���*/
	@tag				varchar(254)	,/*��־*/
	@moduno			char(2),/*Ӫҵ�� basecode=moduno*/
	@invplace		char(10),/*��Ʊ�� basecode=invoice_place */  
	@billno			char(10),/*�÷�Ʊ��Ӧ�Ľ��˵���*/   
	@accnt       	char(10),/*�÷�Ʊ��Ӧ���˺�*/
	@unitno       	char(10),/*��Ʊ��λ = guest.no */
	@unitname      varchar(50),/*��Ʊ��λ���� = guest.name or free input */
	@credit0   		money,/*���*/ 
	@credit1   		money,/*���*/ 
	@empno			varchar(10),/*�û�*/
	@bgndate	 		datetime,/*��ʼʱ��*/
	@enddate	 		datetime /*����ʱ��*/
as	
begin 
    create table #tmp 
	 (
		id					varchar(10)		not null,/*��Ʊ��ˮ*/
		sta				char(1)			not null,/*״̬��� O����|RԤ��|X����*/
		tag				varchar(254)		 null,/*������־ �û��Զ��壬��basecode(invoice_tag) ��ά��,��ѡ*/
		billno			char(10)				 null,/*�÷�Ʊ��Ӧ�Ľ��˵���*/   
		accnt       	char(10)  			 null,/*�÷�Ʊ��Ӧ���˺�*/
		inno        	varchar(16) 	not null, /*��Ʊ��*/
		credit     		money     			 null,/*���*/ 
		unitname      	varchar(50)  	    null,/*��Ʊ��λ���� = guest.name or free input */
		remark			varchar(254)		 null,/*��ע*/
		empno				varchar(10)		not null,/*�û�*/
		crtdate			datetime 			 null /*ʱ��*/
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


	 