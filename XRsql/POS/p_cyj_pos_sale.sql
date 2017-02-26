drop proc  p_cyj_pos_sale;
create proc  p_cyj_pos_sale
	@menu			char(10),
	@inumber				int
as
---------------------------------------------------------------------------------------------
--
--		��̨��Ʒ��Ӧ�����۴������⣬���۵�����Ҫ��������һ��һ�ľ�ˮ���ۡ�
--	  		 ע���Ʒ��Ʒ��λ��һ���ı�������, �Լ���Ʒ��Ʒһ�Զ�����
--			 ע����ͨ����Ʒ����ͨ���������?
--
----------------------------------------------------------------------------------------------
declare
	@pccode		char(3),
	@barcode		char(3),
	@number		money,			
	@logdate		datetime,
	@bdate		datetime,
	@store_id	int,
	@plu_id		int,					--pos_plu�е�id
	@pinumber	int,						-- pos_dish.pinumber = pos_price.inumber
	@empno		char(10),
	@type			char(1),				-- '0' ��Ʒ����, '1' ���
	@option		char(1),					--'F'�ð�̨������Ʒ����  'T'�ú�̨��Ʒ����
	@stcode	char(5),
	@deptno	char(2),						--Ӫҵ����������
	@tocode	char(100),
	@sort	char(4),
	@pluid	int,							--��ǰ����
	@cond	char(10),
	@grp		varchar(16),
	@plucode	char(2)
begin tran
save  tran t_sale
select @bdate = bdate1 from sysdata
select @option = value from sysoption where catalog = 'pos' and item = 'using_supply_code' 
if @@rowcount = 0 
	begin
	insert sysoption(catalog,item,value) select 'pos','using_supply_code','F'
	select @option = 'F'
	end 
select @pccode = pccode,@deptno = deptno from pos_menu where menu = @menu

select @plu_id = id, @number = number, @pinumber = pinumber, @empno = empno, @logdate = date0 from pos_dish where menu = @menu and inumber = @inumber

select @barcode = code from pos_store where charindex(@pccode, pccodes)>0
--ע��basecode����grp�ֶ����������Ǿ�ˮ����ʳƷ���Ӷ�ȷ���ǳ��԰�̨���ǳ��Գ���
--basecode �� cat:pos_cond_rep ���ڸ������������
--grp 0: ʳƷ��1:��ˮ
select @pluid = pluid,@tocode = tocode,@sort = sort,@plucode=plucode from pos_plu where id = @plu_id
if @tocode = '' or @tocode is null 
	select @tocode = tocode from pos_sort_all where pluid = @pluid and sort = @sort and plucode = @plucode

select @stcode = isnull(kit,'') from pos_sort_all where pluid = @pluid and sort = @sort and plucode = @plucode   --�����������,������ɱ�������ó���

select @cond = cond from pos_namedef where charindex(code,@tocode) > 0 and deptno = @deptno
select @grp = grp from basecode where cat = 'pos_cond_rep' and code = @cond
if @grp = '' or @grp is null 
	select @grp = '0'			--Ĭ��ΪʳƷ����Ʒ��Ϊ����
if @stcode = '' Or @stcode is null or rtrim(@stcode)='###'
begin
	if @grp = '0'
		select @stcode = isnull(stcode,'') from pos_stcode where pccode = @pccode
	else if @grp = '1'
		select @stcode = isnull(barcode,'') from pos_stcode where pccode = @pccode
end

if @stcode is null
	select @stcode = ''
if @barcode is null
	select @barcode = ''
	
select @type ='0'
--��̨����Pos�Լ�����
--if charindex('TtYy', @option) > 0 
if charindex(@option,'FfNn') > 0                                                                                                                                                                                                                                                                                                                                                                                                                        
	--���õ�λ����ɰ�̨��λ�������ͳ�����۵���ʱ��ȷ��--pos_store_stock���� ��ʵʱ���£�ҹ������,���ۻ��ɿ�浥λ
	insert into pos_sale(type,bdate,menu,inumber,id,storecode,stcode,pccode,condid,artcode,article,unit,descript,number,empno,logdate,pnumb,amount)
		select @type,@bdate,@menu,@inumber,@plu_id,@barcode,'',@pccode,0,b.code,'',b.unit,a.descript,round(@number * a.number/b.csnumber,3),@empno,@logdate,@pinumber,isnull(round(@number * a.number * b.price/b.csnumber,2), 0) from pos_pldef_price a,pos_st_article b
		where a.artcode = b.code and a.id = @plu_id and a.inumber = @pinumber
else if rtrim(@stcode) <> '9999' 		--����ͨ����̨����ϵͳ����
begin
	if exists(select 1 from pos_pldef_price where id = @plu_id and inumber = @pinumber)
	insert into pos_sale(type,bdate,menu,inumber,id,storecode,stcode,pccode,condid,artcode,article,unit,descript,number,empno,logdate,pnumb,amount)
		select @type,@bdate,@menu,@inumber,@plu_id,'',@stcode,@pccode,0,'',a.article,a.csunit,a.descript,@number * a.number,@empno,@logdate,@pinumber,isnull(@number * a.number * a.price, 0) from pos_pldef_price a
		where a.id = @plu_id and a.inumber = @pinumber 
	else
	insert into pos_sale(type,bdate,menu,inumber,id,storecode,stcode,pccode,condid,artcode,article,unit,descript,number,empno,logdate,pnumb,amount)
			select @type,@bdate,@menu,@inumber,@plu_id,'',@stcode,@pccode,0,'','','','',0,@empno,@logdate,@pinumber,0
		
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    

-- ������pos_condst�����
select @type = '1'
if  charindex(@option,'FfNn') > 0 and exists(select 1 from pos_order_cook a, pos_condgp b, pos_condst c where a.menu = @menu and inumber = @inumber and a.sta ='0' and  a.type ='1' and a.amount <> 0 and a.id = c.condid and charindex(b.code, c.condgp)>0 and b.dish_use = 'F')
	begin
	insert into pos_sale(type,bdate,menu,inumber,id,storecode,stcode,pccode,condid,descript,number,empno,logdate,amount)
		select @type,@bdate,@menu,@inumber,c.id,@barcode,'',@pccode,b.condid,b.descript,sum(c.number),@empno,@logdate,sum(c.number * b.price)  from pos_condst b, pos_order_cook c
		where b.condid = c.id and c.menu = @menu and c.inumber = @inumber and c.sta ='0' and c.type ='1' and c.amount <> 0
		group by c.id,b.condid,b.descript
		order by c.id,b.condid,b.descript
	end

commit  t_sale;