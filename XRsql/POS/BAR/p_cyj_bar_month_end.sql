if exists(select 1 from sysobjects where type='P' and name='p_cyj_bar_month_end')
  drop proc p_cyj_bar_month_end;

create proc  p_cyj_bar_month_end
	@month		datetime,
   @date1      datetime,
   @date2      datetime,
   @empno      char(10)
as
----------------------------------------------------------------------------------------
--
--		��̨�½᣺ �½���� pos_store_mst, pos_store_dtl��������ʷ��
--
----------------------------------------------------------------------------------------
declare		
	@no			char(10),
	@barcode		char(3),
	@descript	char(30),
	@descript1	char(60),
	@inumber		int,
	@stdid		int,
	@oldmonth	datetime

begin tran
save  tran t_bar_end
select @oldmonth = max(month) from pos_store_month

if @oldmonth is not null and @oldmonth >= @month 
	return

--  ��ʷ���ݴ���
insert pos_store_hmst select * from pos_store_mst where type <> '3'
insert pos_store_hdtl select a.* from pos_store_dtl a, pos_store_mst b where a.no = b.no and b.type <> '3'
insert pos_hsale select * from pos_sale
delete pos_store_mst
delete pos_store_dtl
delete pos_sale

--  �ӿ��pos_store_store������������ת����ϸ����
exec p_cyj_bar_month_first_data 	@month, @date2, @empno    

-- �½��¼
INSERT INTO pos_store_month (month, bdate,edate,empno,logdate ) VALUES (@month,@date1,@date2,@empno,getdate())  

commit t_bar_end
;

