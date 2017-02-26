create Proc p_fhb_retrieve_docu
	@pc_id	char(4),
	@id		int
as

declare
	@lockmark char(4),
   @ostcode  char(3),          
   @istcode   char(3),		
   @vdate    datetime,
   @vtype    char(2),
   @vno      int,
   @spcode   char(4),
   @invoice  char(10),
   @ref      varchar(60),
   @vmark    char(2), 
   @empno    char(10),	 
   @log_date datetime,
   @logmark  int,
   @empno0   char(10),
	@empno1   char(10),
   @costitem char(5),
   @paymth   char(5),
   @tag     char(1)
declare	@ret	int,
		@msg	char(60)
select @ret = 0,@msg = ""

select @lockmark=isnull(lockmark,''),@ostcode=isnull(ostcode,''),@istcode=istcode,@vdate=vdate,@vtype=vtype,@vno=isnull(vno,0),@spcode=isnull(spcode,''),@invoice=isnull(invoice,''),@ref=isnull(ref,''),@vmark=vmark,@empno=empno,@log_date=log_date,@logmark=logmark,@empno0=empno0,@empno1=empno1,@costitem=costitem,@paymth=paymth,@tag=tag
	from pos_st_documst where id = @id
if @@rowcount <= 0
	begin
		select @ret = 1,@msg = "当前单据ID无效，检索失败！"
		select @ret,@msg
		return 0
	end
--插入主单、明细数据
delete from st_docu_mst_pcid where pc_id = @pc_id and id = @id
insert st_docu_mst_pcid 
	select @pc_id,@id,@lockmark,@ostcode,'',@istcode,'',@vdate,@vtype,@vno,@spcode,'',@invoice,@ref,@vmark,@empno,@log_date,@logmark,@empno0,@empno1,@costitem,@paymth,@tag
if @@rowcount <= 0
	begin
		select @ret = 1,@msg = "主单信息检索失败！"
		select @ret,@msg
		return 0
	end
delete from st_docu_dtl_pcid where pc_id = @pc_id and id = @id
insert st_docu_dtl_pcid 
	select @pc_id,@id,subid,code,'','','',number,amount,price,validdate,tax,deliver,rebate,csaccnt,prid,tag from pos_st_docudtl where id = @id
if @@rowcount <= 0
	begin
		select @ret = 1,@msg = "单据明细信息检索失败！"
		select @ret,@msg
		return 0
	end
update st_docu_mst_pcid 
	set ostname = isnull(pos_store.descript,'') 
		from pos_store where pos_store.code = st_docu_mst_pcid.ostcode and st_docu_mst_pcid.pc_id = @pc_id and st_docu_mst_pcid.id = @id
update st_docu_mst_pcid 
	set istname = pos_store.descript 
		from pos_store where pos_store.code = st_docu_mst_pcid.istcode and st_docu_mst_pcid.pc_id = @pc_id and st_docu_mst_pcid.id = @id
--供应商暂不考虑
--物品信息
update st_docu_dtl_pcid 
	set name = pos_st_article.name,standent = pos_st_article.standent,unit = pos_st_article.unit 
		from pos_st_article where pos_st_article.code = st_docu_dtl_pcid.code and st_docu_dtl_pcid.pc_id = @pc_id and st_docu_dtl_pcid.id = @id


select @ret,@msg
return 0;