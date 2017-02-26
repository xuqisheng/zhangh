
if exists(select 1 from sysobjects where type='P' and name="p_cyj_pos_store_dtl_add")
   drop procedure p_cyj_pos_store_dtl_add;

create proc  p_cyj_pos_store_dtl_add
	@no			char(10),				-- 入库单号 pos_store_mst.no
   @plu_id     integer,					-- 菜谱号 pos_plu.id
	@condid		integer,             --  pos_condst.condid
	@descript	char(30),
	@descript1	char(60),
	@number		money	,
	@empno		char(10),
	@remark		varchar(20)	
as
-------------------------------------------------------------------------------------------*/
--
--			吧台入库: 明细入库
--
-------------------------------------------------------------------------------------------*/

declare 
	@type 		char(1),                                     
	@inumber			int,		
	@storecode 	char(3),
	@storecode1	char(3),
	@ret			int,
	@msg			char(32)

select @ret = 0, @msg = ''

begin tran 
save 	tran t_store_dtl
select @type = type, @storecode = storecode, @storecode1 = isnull(storecode1, storecode) from pos_store_mst where no = @no

select @inumber = isnull(max(inumber), 0) + 1 from pos_store_dtl where no = @no
insert into pos_store_dtl(no, inumber, storecode, storecode1, plu_id, condid, descript,descript1, number, empno, logdate, remark)
	values(@no, @inumber, @storecode, @storecode1, @plu_id, @condid, @descript,@descript1, @number, @empno, getdate(), @remark)
              
if @type = '1'				-- 调拨
	begin
	if exists(select 1 from pos_store_store where storecode = @storecode and condid = @condid)	
		update pos_store_store set number = isnull(number, 0) + @number where storecode = @storecode and condid = @condid
	else
		insert into pos_store_store(storecode, condid, descript,descript1, number) values(@storecode, @condid, @descript,@descript1, @number)

	if exists(select 1 from pos_store_store where storecode = @storecode1 and condid = @condid)	
		update pos_store_store set number = isnull(number, 0) - @number where storecode = @storecode1 and condid = @condid
	else
		insert into pos_store_store(storecode, condid, descript, descript1, number) values(@storecode1, @condid, @descript, @descript1,-1.0 * @number)
	end
else         -- 入库,盘点,倒入
	begin
	if exists(select 1 from pos_store_store where storecode = @storecode and condid = @condid)	
		update pos_store_store set number = isnull(number, 0) + @number where storecode = @storecode and condid = @condid
	else
		insert into pos_store_store(storecode, condid, descript,descript1, number) values(@storecode, @condid,  @descript,@descript1, @number)
	end
if @ret <> 0 
	rollback tran t_store_dtl

commit  tran t_store_dtl
select @inumber

;
