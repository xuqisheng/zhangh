
IF OBJECT_ID('p_yjw_cms_payinfo') IS NOT NULL
    DROP PROCEDURE p_yjw_cms_payinfo
;
create procedure p_yjw_cms_payinfo
	@pc_id	 char(4), 
	@belong   varchar(10),		-- ��Ӷ�ͻ�
	@ncms     money,				-- ��Ӷ���
	@nrate    money,				-- ��Ӷ���� 
	@cby      varchar(20),
	@cbydate  datetime,
	@payby    varchar(20),
	@paydate  datetime,
	@billno   varchar(10) 
as
-----------------------------------------------------------------
-- Ӷ��֧��������Ҫ֧���������� selected_account���� 
----------------------------------------------------------------- 
declare
   @maxno      integer,
   @ret        integer

select @maxno=max(cms_id)  from cms_pay_history
if @maxno is null
	select @maxno=1
else
	select @maxno=@maxno+1

update cms_rec set ispaied=@maxno,payby=@payby,paydate=@paydate,cby=@cby,changed=@cbydate,logmark=logmark+1  
	from selected_account a 
		where a.type='C' and a.pc_id=@pc_id and cms_rec.id=a.number

insert cms_pay_history(cms_id,cms_cusid,cms0sum,w_or_hsum,cby,cbydate,payby,paydate,billno) 
	values (@maxno,@belong,@ncms,@nrate,@cby,@cbydate,@payby,@paydate,@billno)

delete selected_account where type='C' and pc_id=@pc_id 

return 0 
;
