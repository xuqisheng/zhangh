drop  proc p_cq_newpos_report_item;
create proc p_cq_newpos_report_item
	@pc_id				char(4),			-- վ�� 
	@pccode  			varchar(255),	-- Pccode ����
	@menu					char(10),
	@empno				char(10),		-- ���� null ��ʾ���й��� 
	@shift				char(1),			-- ��� null ��ʾ���а�� 
	@item					varchar(255),
	@date					datetime
as
--------------------------------------------------------------------------------------------------
--
-- ���������--
-- posdai.code = 'FF1' ת�Ǽ�AR��, �Ѿ�������תAR�ֻ���������    --  
-- posdai.code = 'G'   �Ǽ��˽���, ����ת��������   jjhotel cyj --  
--
--------------------------------------------------------------------------------------------------
declare
	@bdate				datetime,	--Ӫҵ����
	@type					char(3), 
	@tocode				char(3), 
	@pccod            char(5),
	@pccode1          char(3),
	@deptno1          char(3),
	@deptno8          char(3),
	@payname          char(12),
	@descript1			char(12), 
	--  
	@dsc_sttype 		char(2) , 
	@p_daokous			varchar(100), 
	@daokou	  			char(1) , 
	-- menu information required 

	-- dish information required 
	@code					char(3), 		--������ 
	@amount				money, 			--�˵����
	-- tmp variables 
	@descript			char(12), 
	@paycode				char(3), 
	@paytail				char(1), 
	@i						integer, 
	@feed					money, 
	@feedd				money, 

	@modu_ids			varchar(255), 
	@codes				varchar(255), 
	@paycodes			varchar(255), 
	@vpos					integer,
	@tocode1          char(3),
	@amountall        money

create table #item
(
		pc_id		char(4)			null,
		pccode	char(3)			null,
		shift		char(1)			null,
		empno		char(10)			null,
		menu		char(10)			null,
		code		char(15)			null,
		id			int				null,
		name1		char(60)			null,
		tocode	char(3)			null,
		amount	money				null,
		tocode1	char(100)		null,
		tocode2	char(100)		null,
		descript char(60)			null
)


select @bdate = bdate1 from sysdata

select deptno = space(2),* into #pos_detail_jie_link from pos_detail_jie_link where 1=2
insert into #pos_detail_jie_link select '',* from pos_detail_jie_link
update #pos_detail_jie_link set amount0 = 0,amount1= 0,amount2 = 0 where type in (select pccode from pccode where pccode>'900' and deptno8<>'' and deptno8 is not null) and special <>'E'
update #pos_detail_jie_link set deptno = b.deptno from #pos_detail_jie_link a,pos_pccode b where a.pccode=b.pccode


if @date = @bdate
	insert #item(pc_id,pccode,shift,empno,menu,code,id,name1,tocode,amount)
	 SELECT a.pc_id, a.pccode,  a.shift,  a.empno,  a.menu,  a.code,d.id, a.name1,a.tocode,  
			sum(amount0 -amount1 - amount2 - amount3)
    FROM #pos_detail_jie_link a, pos_plu_all b,pos_namedef c,pos_dish d
	where a.pc_id = @pc_id and a.deptno=c.deptno and d.id = b.id  and a.tocode = c.code
	and a.menu = d.menu and (a.id = d.inumber or a.id/1000 = d.inumber) and (charindex(a.pccode , @pccode) >0 or @pccode = '') and 
		(a.menu = @menu or @menu = '') and (a.empno = @empno or @empno = '') and (charindex(a.tocode , @item) >0 or @item = '')
		and (a.shift = @shift or @shift = '') and a.special <> 'E' 
		group by a.pc_id,a.pccode,a.shift,a.empno,a.menu,a.code,d.id,a.name1,a.tocode
else
	insert #item(pc_id,pccode,shift,empno,menu,code,id,name1,tocode,amount)
	 SELECT a.pc_id, a.pccode,  a.shift,  a.empno,  a.menu,  a.code,d.id, a.name1,a.tocode,  
			sum(amount0 -amount1 - amount2 - amount3)
    FROM #pos_detail_jie_link a, pos_plu_all b,pos_namedef c,pos_hdish d
	where a.pc_id = @pc_id and a.deptno=c.deptno and d.id = b.id  and a.tocode = c.code
	and a.menu = d.menu and (a.id = d.inumber or a.id/1000 = d.inumber) and (charindex(a.pccode , @pccode) >0 or @pccode = '') and 
		(a.menu = @menu or @menu = '') and (a.empno = @empno or @empno = '') and (charindex(a.tocode , @item) >0 or @item = '')
		and (a.shift = @shift or @shift = '') and a.special <> 'E' 
		group by a.pc_id,a.pccode,a.shift,a.empno,a.menu,a.code,d.id,a.name1,a.tocode

insert #item(pc_id,pccode,shift,empno,menu,code,id,name1,tocode,amount)
SELECT a.pc_id, a.pccode, a.shift, a.empno, a.menu, a.code,0,a.name1,a.tocode,  
			sum(amount0 -amount1 - amount2 - amount3)
    FROM #pos_detail_jie_link a,pos_namedef c
	where a.pc_id = @pc_id  and a.tocode = c.code and a.deptno=c.deptno 
	 and (charindex(a.pccode , @pccode) >0 or @pccode = '') and 
		(a.menu = @menu or @menu = '') and (a.empno = @empno or @empno = '') and (charindex(a.tocode , @item)>0 or @item = '')
		and (a.shift = @shift or @shift = '') and charindex(ltrim(rtrim(a.code)),'XYZ') > 0 and a.special <> 'E' 
		group by a.pc_id,a.pccode,a.shift,a.empno,a.menu,a.code,a.name1,a.tocode
update #item set descript = a.descript from pos_namedef a, pos_pccode b where #item.tocode = a.code and #item.pccode = b.pccode and a.deptno=b.deptno
update #item set tocode1 = a.tocode from pos_plu_all a where #item.id = a.id
update #item set tocode2 = a.tocode from pos_sort_all a,pos_plu_all b where #item.id = b.id and b.sort = a.sort
select * from #item

;