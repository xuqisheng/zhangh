create proc p_fhb_docu_save
	@pc_id	char(4),
	@id	int,
	@mode	char(1),
	@type	char(2),
	@ret	int out,
	@msg varchar(60) out
as

declare	@istcode	char(3),
			@code	char(12),
			@subid	int,
			@number	money,
			@price	money,
			@amount	money,
			@newid	int

if @id < 0 and @mode <> 'A'           --���������ЧID�������µ�����
	select @mode = 'A'
select @ret = -@id,@msg = '���ݱ���ɹ���'
begin tran 
save tran p_fhb_docu_save_s
if @mode = 'A'
begin                     
	exec @ret = p_fhb_get_newid @id = @newid out
	if @ret <> 0 
	begin
		rollback
		select @ret = 1,@msg = '�µ���ID����ʧ��'
		return @ret
	end
	update st_docu_mst_pcid set id = @newid where pc_id = @pc_id and id = @id
	update st_docu_dtl_pcid set id = @newid where pc_id = @pc_id and id = @id
	insert pos_st_documst (id,lockmark,ostcode,istcode,vdate,vtype,vno,spcode,invoice,ref,vmark,empno,log_date,logmark,empno0,empno1,costitem,paymth,tag)
   	select id,lockmark,isnull(ostcode,''),istcode,vdate,vtype,vno,'',invoice,ref,vmark,empno,log_date,logmark,empno0,empno1,costitem,paymth,tag from st_docu_mst_pcid where pc_id = @pc_id and id = @newid
	insert pos_st_docudtl (id,subid,code,number,amount,price,validdate,tax,deliver,rebate,csaccnt,prid,tag,productor,pdate,kpdays,note)
		select id,subid,code,number,amount,price,validdate,tax,deliver,rebate,csaccnt,0,tag,'',getdate(),'','' from st_docu_dtl_pcid where pc_id = @pc_id and id = @newid
	--�������ݸ��¿��
	exec p_fhb_update_stock @pc_id = @pc_id,@id = @newid,@mode = 'A',@type = @type,@ret = @ret out,@msg = @msg out
	if @ret > 0
		rollback p_fhb_docu_save_s
	else	
		commit p_fhb_docu_save_s
	
	return 0
end
else if @mode = 'M'
begin
	--��ɾ==����
	exec p_fhb_update_stock @pc_id = @pc_id,@id = @id,@mode = 'D',@type = @type,@ret = @ret out,@msg = @msg out
	--�����޸Ĺ��̵�ɾ����������������澯ʾ
	--if @ret > 0
	--begin
	--	rollback p_fhb_docu_save_s
	--	return 0
	--end
	--����ִ�гɹ�����ɾ���õ��ݣ���ID����
	update pos_st_documst 
		set lockmark = a.lockmark,ostcode = a.ostcode,istcode = a.istcode,vdate = a.vdate,vtype = a.vtype,vno = a.vno,spcode = a.spcode,invoice = a.invoice,ref = a.ref,vmark = a.vmark,empno = a.empno,log_date = a.log_date,logmark = a.logmark,empno0 = a.empno0,empno1 = a.empno1,costitem = a.costitem,paymth = a.paymth,tag = a.tag
			from st_docu_mst_pcid a where pos_st_documst.id = a.id and a.pc_id = @pc_id and a.id = @id 
	
	delete from pos_st_docudtl where id = @id
	--�����µ���ϸ����
	insert pos_st_docudtl (id,subid,code,number,amount,price,validdate,tax,deliver,rebate,csaccnt,prid,tag,productor,pdate,kpdays,note)
		select id,subid,code,number,amount,price,validdate,tax,deliver,rebate,csaccnt,0,tag,'',getdate(),'','' from st_docu_dtl_pcid where pc_id = @pc_id and id = @id
	if @@rowcount = 0 
	begin
		select @ret = 1,@msg = '��Ʒ��ϸ��Ϣ����ʧ�ܣ�'
		rollback
		return 0
	end
	--���¿��
	exec p_fhb_update_stock @pc_id = @pc_id,@id = @id,@mode = 'A',@type = @type,@ret = @ret out,@msg = @msg out
	if @ret > 0
		rollback p_fhb_docu_save_s
	else	
		commit p_fhb_docu_save_s
	--@ret ����Ϊ��������ID���෴��
	return 0
end
else if @mode = 'D'
begin
	--ɾ������
	--�ȸ��¿�棬��ɾ����
	exec p_fhb_update_stock @pc_id = @pc_id,@id = @id,@mode = 'D',@type = @type,@ret = @ret out,@msg = @msg out
	if @ret > 0
	begin
		rollback p_fhb_docu_save_s
	end
	else
	begin
		delete from pos_st_documst where id = @id
		delete from pos_st_docudtl where id = @id
		commit p_fhb_docu_save_s
		select @ret = 0,@msg = ''                --�ͻ������µ�          @ret = 0 ,��ʾΪɾ�����ݣ��޵�ǰID
	end
	--select @ret = 100                             --�������ɹ�������100�������ϵ�ID���¼���
	return 0
end;