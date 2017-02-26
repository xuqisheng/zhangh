//------------------------------------------------------------------------------
//	BOS  -- ������ص� proc 
//
//		p_gds_bos_kc_folio_input		-- �������ݵ�����
//		p_gds_bos_kc_sta					-- �������ݵ�ɾ�����ָ�
//		p_gds_bos_maint_store			-- ���ά��
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//			bos_kcmenu ---> bos_store
//				�ʵ�������, ����, ����
//				���� bos_store, ��¼ bos_kcdish -- ԭ���	
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_gds_bos_kc_folio_input')
	drop proc p_gds_bos_kc_folio_input;
create proc  p_gds_bos_kc_folio_input
	@modu_id		char(2),
	@pc_id		char(4),
	@mode			char(2),          //IN-����  OU-����  BJ-����
	@folio		char(10),
	@empno		char(10),
	@msg			varchar(60) output,
	@returnmode	char(1)	= 'S'         // 'R'
as
declare 	@flag		char(2),
			@pccode	char(5),
			@sta		char(1),
			@site0	varchar(5),
			@site1	varchar(5),
			@code		char(8),
			@number	money,
			@price	money,
			@blow		money,
			@amount 	money,
			@amount1	money,
			@profit 	money,
			@bdate 	datetime,
			@bdate0 	datetime,
			@ret	 	int,
			@pc_id0	char(4),
			@id		char(6)

select @ret = 0, @msg = 'ok !'

// ȡ��Ӫҵ����   
select @bdate = bdate1 from sysdata

begin tran 
save tran p_gds_bos_kc_folio_input1

if not exists(select 1 from bos_kcmenu where folio = @folio) or not exists(select 1 from bos_kcdish where folio = @folio) 
	select @ret = 1, @msg = '���ʺŲ�����,�򵥾ݲ����� ! ---- ' + @folio

if @ret = 0 and @mode = 'IN'
	if not exists(select 1 from bos_kcmenu where folio = @folio and sta='I')
		select @ret = 1, @msg = '���ʺŷ���Ч״̬ ! '

if @ret = 0 and @mode='IN'
begin
	select @pc_id0 = pc_id from bos_kcmenu where folio = @folio
	if @pc_id0 is not null and @pc_id0 <> @pc_id
		select @ret = 1, @msg = '�õ������� '+@pc_id0+' ����վ�޸� ! '
end

if @ret = 0 and @mode <> 'IN'
	if not exists(select 1 from bos_kcmenu where folio = @folio and sta='O')
		select @ret = 1, @msg = '���ʺŷ�����״̬ ! '
/*  --> ����Ҫ����,�������� !
	else
	begin
		select @bdate0 = bdate from bos_kcmenu where folio = @folio
		if datediff(dd, @bdate, @bdate0) <> 0 
			select @ret = 1, @msg = 'ֻ�ܳ������ȵ��յ��� ! '
	end
*/

// 2002/03 
if @mode = 'OU'  // ����
	select @ret = 1, @msg = '���ܽ��г��� ! ---- ���˴����������෴�ĵ��ݽ��д���'
else if @mode = 'BJ'	// ����
	select @ret=1, @msg='��ʱ���ṩ���ȹ��ܣ����ó��� !'
else if @mode <> 'IN'
	select @ret=1, @msg='δ֪�������־'

// ��ϸ����
if @ret = 0
	exec @ret = p_gds_bos_detail @modu_id, @pc_id, @folio, '', '', @msg output

if @ret = 0 
begin
	// ȡ��Ӫҵ����  
	select @bdate = bdate1 from sysdata
	if @mode = 'IN'
	begin
		update bos_kcmenu set bdate=@bdate, sta = 'O', pc_id=null,cby=@empno, cdate=getdate(), logmark=logmark + 1 where folio = @folio
		if @@error <> 0 
			select @ret = 1, @msg = '���� FOLIO ʧ�� !'
	end
	else if @mode = 'OU'  // ����
		select @ret = 1, @msg = '���ܽ��г��� ! ---- ���˴����������෴�ĵ��ݽ��д���'
	else if @mode = 'BJ'	// ����
		select @ret=1, @msg='��ʱ���ṩ���ȹ��ܣ����ó��� !'
	else
		select @ret=1, @msg='δ֪�������־'
end
gout:
if @ret <> 0
	rollback tran p_gds_bos_kc_folio_input1
commit tran

if @returnmode = 'S' 
	select @ret, @msg

return @ret
;


////------------------------------------------------------------------------------
////			bos_kcmenu ---> bos_store
////				�ʵ�������, ����, ����
////				���� bos_store, ��¼ bos_kcdish -- ԭ���	
////------------------------------------------------------------------------------
//if exists (select 1 from sysobjects where name = 'p_gds_bos_kc_folio_input')
//	drop proc p_gds_bos_kc_folio_input;
//create proc  p_gds_bos_kc_folio_input
//	@pc_id		char(4),
//	@mode			char(2),          //IN-����  OU-����  BJ-����
//	@folio		char(10),
//	@empno		char(10),
//	@msg			varchar(60) output,
//	@returnmode	char(1)	= 'S'         // 'R'
//as
//declare 	@flag		char(2),
//			@pccode	char(3),
//			@sta		char(1),
//			@site0	varchar(5),
//			@site1	varchar(5),
//			@code		char(8),
//			@number	money,
//			@price	money,
//			@blow		money,
//			@amount 	money,
//			@amount1	money,
//			@profit 	money,
//			@bdate 	datetime,
//			@bdate0 	datetime,
//			@ret	 	int,
//			@pc_id0	char(4),
//			@empname	char(12),
//			@id		char(6)
//
//select @ret = 0, @msg = 'ok !'
//
//// ȡ��Ӫҵ����   
//select @bdate = bdate1 from sysdata
//
//begin tran 
//save tran p_gds_bos_kc_folio_input1
//
//if not exists(select 1 from bos_kcmenu where folio = @folio) or not exists(select 1 from bos_kcdish where folio = @folio) 
//	select @ret = 1, @msg = '���ʺŲ�����,�򵥾ݲ����� ! ---- ' + @folio
//
//if @ret = 0 and @mode = 'IN'
//	if not exists(select 1 from bos_kcmenu where folio = @folio and sta='I')
//		select @ret = 1, @msg = '���ʺŷ���Ч״̬ ! '
//
//if @ret = 0 and @mode='IN'
//begin
//	select @pc_id0 = pc_id from bos_kcmenu where folio = @folio
//	if @pc_id0 is not null and @pc_id0 <> @pc_id
//		select @ret = 1, @msg = '�õ������� '+@pc_id0+' ����վ�޸� ! '
//end
//
//if @ret = 0 and @mode <> 'IN'
//	if not exists(select 1 from bos_kcmenu where folio = @folio and sta='O')
//		select @ret = 1, @msg = '���ʺŷ�����״̬ ! '
///*  --> ����Ҫ����,�������� !
//	else
//	begin
//		select @bdate0 = bdate from bos_kcmenu where folio = @folio
//		if datediff(dd, @bdate, @bdate0) <> 0 
//			select @ret = 1, @msg = 'ֻ�ܳ������ȵ��յ��� ! '
//	end
//*/
//
//// 2002/03 
//if @mode = 'OU'  // ����
//	select @ret = 1, @msg = '���ܽ��г��� ! ---- ���˴����������෴�ĵ��ݽ��д���'
//else if @mode = 'BJ'	// ����
//	select @ret=1, @msg='��ʱ���ṩ���ȹ��ܣ����ó��� !'
//else if @mode <> 'IN'
//	select @ret=1, @msg='δ֪�������־'
//
//select @empname = name from auth_login where empno = @empno
//
//if @ret = 0
//begin
//	// ȡ�õ�ǰʱ��ε������־
//	select @id = min(id) from bos_store
//
//	// ȡ�õ��ݵı�־ -- ��,��,��,��,(��),��,��,��
//	select @pccode=pccode,@flag=flag,@site0=site0,@site1=site1 from bos_kcmenu where folio = @folio
//	declare cc cursor for select code, number, amount, amount1,profit from bos_kcdish where folio = @folio order by code
//	open cc
//	fetch cc into @code, @number, @amount, @amount1, @profit
//	while @@sqlstatus = 0
//	begin
//		if @number=0 continue
//		if @mode <> 'IN' 
//			select @number=@number* -1, @amount=@amount* -1, @amount1=@amount1* -1, @profit=@profit* -1
//		if not exists(select 1 from bos_store where pccode=@pccode and site = @site0 and code = @code)
//		begin
//			if not exists(select 1 from bos_site where pccode=@pccode and site=@site0)
//			begin
//				select @ret=1, @msg='�ص�0 ���� !'
//				goto gout
//			end
//			else
//				insert bos_store (id, pccode, site, code) select @id, @pccode, @site0, @code
//		end
//
//		if @flag = '��'
//			update bos_store set number1=number1+@number,amount1=amount1+@amount,sale1=slae1+@amount1,profit1=profit1+@profit,
//				number9=number9+@number,amount9=amount9+@amount,sale9=slae9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site0 and code = @code
//		else if @flag = '��'
//			update bos_store set number2=number2+@number,amount2=amount2+@amount,sale2=slae2+@amount1,profit2=profit2+@profit,
//				number9=number9-@number,amount9=amount9-@amount,sale9=slae9-@amount1,profit9=profit9-@profit where pccode=@pccode and site = @site0 and code = @code
//		else if @flag = '��'  
//			update bos_store set number3=number3+@number,amount3=amount3+@amount,sale3=slae3+@amount1,profit3=profit3+@profit,
//				number9=number9+@number,amount9=amount9+@amount,sale9=slae9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site0 and code = @code
//		else if @flag = '��'  
//		begin
//			update bos_store set number4=number4+@number,amount4=amount4+@amount,sale4=slae4+@amount1,profit4=profit4+@profit,
//				number9=number9+@number,amount9=amount9+@amount,sale9=slae9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site0 and code = @code
//			if @site0 = @site1 
//			begin
//				select @ret=1, @msg='�������������ص���ͬ������ !'
//				goto gout
//			end
//			if not exists(select 1 from bos_store where pccode=@pccode and site = @site1 and code = @code)
//			begin
//				if not exists(select 1 from bos_site where pccode=@pccode and site=@site1)
//				begin
//					select @ret=1, @msg='�ص�1 ���� !'
//					goto gout
//				end
//				else
//					insert bos_store (id, pccode, site, code) select @id, @pccode, @site1, @code
//			end
//			update bos_store set number4=number4-@number,amount4=amount4-@amount,sale4=slae4-@amount1,profit4=profit4-@profit,
//				number9=number9-@number,amount9=amount9-@amount,sale9=slae9-@amount1,profit9=profit9-@profit where pccode=@pccode and site = @site1 and code = @code
//		end
//		else if @flag = '��'  
//		begin
//			update bos_store set number6=number6+@number,amount6=amount6+@amount,sale6=slae6+@amount1,profit6=profit6+@profit,
//				number9=number9+@number,amount9=amount9+@amount,sale9=slae9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site0 and code = @code
//			if @site0 = @site1 
//			begin
//				select @ret=1, @msg='���ϵ��������ص���ͬ������ !'
//				goto gout
//			end
//			if not exists(select 1 from bos_store where pccode=@pccode and site = @site1 and code = @code)
//			begin
//				if not exists(select 1 from bos_site where pccode=@pccode and site=@site1)
//				begin
//					select @ret=1, @msg='�ص�1 ���� !'
//					goto gout
//				end
//				else
//					insert bos_store (id, pccode, site, code) select @id, @pccode, @site1, @code
//			end
//			update bos_store set number6=number6-@number,amount6=amount6-@amount,sale9=slae9-@amount1,profit9=profit9-@profit,
//				number9=number9-@number,amount9=amount9-@amount,sale9=slae9-@amount1,profit9=profit9-@profit where pccode=@pccode and site = @site1 and code = @code
//		end
//		else if @flag = '��'  // �뵱ǰ���������һ���������, amount Ϊ�����Ĳ�� !
//		begin
////			if not exists(select 1 from bos_store where pccode=@pccode and site = @site0 and code = @code and number9=@number)
////			begin
////				select @ret=1, @msg='���۵�������������ڿ������ !'
////				goto gout
////			end
//			update bos_store set number7=number7+@number,amount7=amount7+@amount,sale7=slae7+@amount1,profit7=profit7+@profit,
//				amount9=amount9+@amount,sale9=slae9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site0 and code = @code
//		end
//		else if @flag = '��'  // �뵱ǰ���������һ���������, amount Ϊ�����Ĳ�� !
//		begin
////			if not exists(select 1 from bos_store where pccode=@pccode and site = @site0 and code = @code and number9=@number)
////			begin
////				select @ret=1, @msg='���۵�������������ڿ������ !'
////				goto gout
////			end
//			update bos_store set number8=number8+@number,amount8=amount8+@amount,sale8=slae8+@amount1,profit8=profit8+@profit,
//				amount9=amount9+@amount,sale9=slae9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site0 and code = @code
//		end
//		else 
//		begin
//			select @ret=1, @msg='��Ч�˵���־ !'
//			goto gout
//		end
//
//		// ������ϸ��
//		
//
//		fetch cc into @code, @number, @amount, @amount1, @profit
//	end
//	close cc
//	deallocate cursor cc
//end
//
//if @ret = 0 
//begin
//	// ȡ��Ӫҵ����  
//	select @bdate = bdate1 from sysdata
//	if @mode = 'IN'
//	begin
//		update bos_kcmenu set bdate=@bdate, sta = 'O', pc_id=null,cby=@empno, cdate=getdate(), cname=@empname, logmark=logmark + 1 where folio = @folio
//		if @@error <> 0 
//			select @ret = 1, @msg = '���� FOLIO ʧ�� !'
//	end
//	else if @mode = 'OU'  // ����
//	begin
////		update bos_kcmenu set bdate=@bdate, sta = 'D', pc_id=null,dby=@empno, ddate=getdate(), dname=@empname,logmark=logmark + 1 where folio = @folio
////		if @@error <> 0 
////			select @ret = 1, @msg = '���� FOLIO ʧ�� !'
//
//		// 2002/03 
//		select @ret = 1, @msg = '���ܽ��г��� ! ---- ���˴����������෴�ĵ��ݽ��д���'
//	end
//	else if @mode = 'BJ'	// ����
//	begin
//		select @ret=1, @msg='��ʱ���ṩ���ȹ��ܣ����ó��� !'
//	end
//	else
//	begin
//		select @ret=1, @msg='δ֪�������־'
//	end
//end
//gout:
//if @ret <> 0
//	rollback tran p_gds_bos_kc_folio_input1
//commit tran
//
//if @returnmode = 'S' 
//	select @ret, @msg
//
//return @ret
//;
//


//------------------------------------------------------------------------------
//			�ʵ� ɾ�� �ָ� ����
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_gds_bos_kc_sta')
	drop proc p_gds_bos_kc_sta;
create proc  p_gds_bos_kc_sta
	@pc_id		char(4),
	@folio		char(10),
	@mode			char(4),        			// dele, back
	@msg			varchar(60) output,
	@returnmode	char(1)	= 'S'         	// 'R'
as

declare 	@ret		int, 
			@pc_id0	char(4)

select @ret = 0, @msg = ''

begin tran 
save tran p_gds_bos_kc_sta1

if @mode <> 'dele' and @mode <> 'back' 
	select @ret = 1, @msg = 'SP �Ĳ���ģʽ���� !'

if @ret = 0
	if not exists(select 1 from bos_kcmenu where folio = @folio)
		select @ret = 1, @msg = '�õ��ݲ����� !'

if @ret = 0
begin
	select @pc_id0 = pc_id from bos_kcmenu where folio = @folio
	if @pc_id0 is not null and @pc_id <> @pc_id0
		select @ret = 1, @msg = '�õ�������'+@pc_id0+'����վ�޸� !'
end

if @ret = 0
begin
	if @mode = 'dele'
	begin
		if not exists(select 1 from bos_kcmenu where folio = @folio and sta='I')
			select @ret = 1, @msg = '�õ��ݷ���Ч״̬ !'
		else
		begin
			update bos_kcmenu set sta = 'X', pc_id=null where folio = @folio
			if @@error <> 0 
				select @ret = 1, @msg = '���ݿ����ʧ�� !'
		end
	end	
	else
	begin
		if not exists(select 1 from bos_kcmenu where folio = @folio and sta='X')
			select @ret = 1, @msg = '�õ��ݷ���Ч״̬ !'
		else
		begin
			update bos_kcmenu set sta = 'I', pc_id=null where folio = @folio
			if @@error <> 0 
				select @ret = 1, @msg = '���ݿ����ʧ�� !'
		end
	end	
end

if @ret <> 0
	rollback tran p_gds_bos_kc_sta1
commit tran 

if @returnmode = 'S' 
	select @ret, @msg

return @ret
;

//------------------------------------------------------------------------------
// �򵥵� ά���������۳ɱ�������� !
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_gds_bos_maint_store')
	drop proc p_gds_bos_maint_store;
create proc p_gds_bos_maint_store
as

// �����ۺϵ�<����>��浥��
create table #price 
(
	pccode	char(5)		not null,
	site		char(5)		not null,		
	code		char(8)		not null,		
	price		money	default 0	not null
)
insert #price select pccode,site,code,0 from bos_store

update #price set price = (a.amount0+a.amount1)/(a.number0+a.number1)
	from bos_store a where a.number0+a.number1 <> 0
		and a.pccode=#price.pccode and a.site=#price.site and a.code=#price.code
update #price set price = a.amount0/a.number0
	from bos_store a where a.number0+a.number1=0 and a.number0<>0
		and a.pccode=#price.pccode and a.site=#price.site and a.code=#price.code

// -- ��ʱ��Ҫһ���ο���
//update #price set price =  ???
//	from bos_store a where a.number1=0 and a.number0=0
//		and a.pccode=#price.pccode and a.site=#price.site and a.code=#price.code

// ά�����۵��ݵĳɱ���
update bos_hdish set amount0=round(number*b.price, 4)
	from bos_hfolio a, #price b
		where bos_hdish.foliono=a.foliono  
				and a.setnumb is not null
				and a.pccode=b.pccode 
				and a.site=b.site
				and bos_hdish.code=b.code
				
// ά����������۽��Ϳ����
update bos_store set amount5 = round(number5*a.price, 2)
	from #price a where bos_store.pccode=a.pccode and bos_store.site=a.site 
		and bos_store.code=a.code

update bos_store set amount9 = amount0+amount1-amount2+amount3-amount4-amount5

return 0
;

// ������������=0�����ǽ��<>0����ʱ��Ҫ�����۳ɱ����� !
// select * from bos_store where number9=0 and amount9<>0;

// �˲� :
// select * from bos_store where number0+number1-number2+number3-number4-number5<>number9;
// select * from bos_store where amount0+amount1-amount2+amount3-amount4-amount5<>amount9;

// �˲���һ��ĵر�ƽ
//select a.date, a.day99, b.sumcre 
//	from yjierep a, ydairep b 
//	where a.date=b.date and a.class='999' and b.class='09000'
//			and a.day99<>b.sumcre
//			order by a.date;
