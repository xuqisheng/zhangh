// ----------------------------------------------------------------------------
//		t_gds_bos_folio_update
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
//		bos_folio ---> ���ʣ�����
// 		���ı仯 --- !
// ----------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = 't_gds_bos_folio_update')
	drop trigger t_gds_bos_folio_update;
//create trigger t_gds_bos_folio_update
//on bos_folio for update
//as
//if update(sta) 
//	begin
//	declare @sta0 char(1), @sta1 char(1), @pccode char(2), @site0 char(5), @folio char(10), @code char(8)
//	declare @bdate datetime, @number0 money, @amount0 money, @number money, @amount money
//	declare @kcid char(6), @jxc int, @id int, @msg varchar(60)
//	select @sta0 =sta from deleted
//	select @sta1 =sta,@pccode=pccode from inserted
//	select @jxc = jxc from bos_pccode where pccode=@pccode 
//	if @@rowcount=0 select @jxc=0
//	if (@sta1='O' or @sta0='O') and @jxc > 0
//		begin
//		select @kcid = min(id) from bos_store where pccode=@pccode
//		if @bdate is null
//			select @bdate = bdate1 from sysdata
//		select @folio=foliono,@site0=site0 from inserted
//	
//		declare cc cursor for select id, code, number, fee from bos_dish where foliono = @folio and sta='I' order by code
//		open cc
//		fetch cc into @id, @code, @number, @amount
//		while @@sqlstatus = 0
//			begin
//			if @number=0 continue
//			// ��ȡ���۸���Ϣ
//			if not exists(select 1 from bos_store where pccode=@pccode and site = @site0 and code = @code)
//				begin
//				insert bos_store (id, pccode, site, code) select @kcid, @pccode, @site0, @code
//				if @@rowcount=0
//					begin
//					close cc
//					deallocate cursor cc
//					rollback trigger with raiserror 55555 "��������� !HRY_MARK "
//					return 
//					end
//				end
//	
//			if @sta1 = 'O'  // ����
//				begin
////				select @number0=number9, @amount0=amount9 from bos_store where pccode=@pccode and site = @site0 and code = @code 
//				select @number0=sum(number9), @amount0=sum(amount9) from bos_store where pccode=@pccode and code = @code  // û���Ϲ��ʱ��, ��Ҫ����ֿ�ļ۸�
//				if @number0=0 
//					begin
//					// û�п��, ֱ��ȡ�ۼ�
////					select @number0=@number, @amount0=@amount  
//					
//					// ���ڸ�Ϊû����Ʒ, ��������
//					close cc
//					deallocate cursor cc
//					select @msg = "ϵͳ�����û�и���Ʒ "+@code+"!HRY_MARK "
//					rollback trigger with raiserror 55555 @msg
//					return 
//					end
//				else if @number0 <> @number
//					begin
//					select @amount0 = round(@number*@amount0/@number0, 2)  // �ɱ���; ������ȣ���ֱ��ȡ���
//					select @number0=@number
//					end
//				update bos_dish set amount0 = @amount0 where foliono=@folio and id = @id
//				update bos_store set number5=number5+@number0,amount5=amount5+@amount0,
//					number9=number9-@number0,amount9=amount9-@amount0 where pccode=@pccode and site = @site0 and code = @code
//				end
//			else		// ����
//				begin
//				select @number0=number, @amount0=amount0 from bos_dish where foliono=@folio and code=@code
//				update bos_store set number5=number5-@number0,amount5=amount5-@amount0,
//					number9=number9+@number0,amount9=amount9+@amount0 where pccode=@pccode and site = @site0 and code = @code
//				end
//
//			if @@rowcount = 0
//				begin
//				close cc
//				deallocate cursor cc
//				rollback trigger with raiserror 55555 "����ʧ�� !HRY_MARK "
//				return 
//				end
//	
//			fetch cc into @id, @code, @number, @amount
//		end
//		close cc
//		deallocate cursor cc
//		end
//	end
//;
//
//