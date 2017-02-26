
if exists (select 1 from sysobjects where name='p_cyj_pos_dishcard_query' and type='P')
   drop procedure p_cyj_pos_dishcard_query;

create proc p_cyj_pos_dishcard_query
	@pserver	char(3),               	-- 打印控制器
   @color   integer						-- 仅用于区分打印批次
as
--============================================================================================
--
--		厨房打印程序: 打印服务检索程序
--
--============================================================================================
declare
	@line			int,
	@printid		int,
	@dinput		datetime,
	@kitchens	char(20),              -- 厨房串
	@printer		char(3),
	@tableno		char(5),
   @changed    char(1),
   @menu       char(10),
	@id			varchar(30),
	@guest		int

create table #card (
	menu  	char(10)  not null,                   
	printid	integer   not null,      		     
	inumber	integer   not null,                        
  	id    	integer   not null,                   
  	code  	char(15)  not null,                      
  	name1 	char(20)  not null,             
  	unit    	char(4) 	 null,  
  	number  	money default 1		not null, 
  	empno  	char(10)  null,   
	date		datetime	not null,
	kitchen	char(3)	not null,
	kit_des	varchar(40)	not null,
	printer	char(3)	not null,
	prn_name	varchar(100)	not null,
	remark	varchar(20)		null, 			                
	cook		varchar(100) default '' null,
	changed  char(1) default 'F' not null,
   color    integer not null,
   tableno  char(6) default ''  null,
   tbl_des  char(10) default ''  null,
	foliono	char(10)	default ''  null,                -- 有的饭店用单号（pos_menu.foliono）不用桌号
   pc_id    char(4) default '' not null,
   flag     char(4) default '' not null,
   times    integer default 0  not null,
   price    money    null,
	guest		int,
	pc_des	char(32)	not null									-- 餐厅
)

select @printid = -1

 -- 打印客单,起菜等
if exists(select 1 from pos_dishcard a, pos_kitchen b, pos_printer c where  a.changed<>'T' and b.pcode = @pserver and a.printer = c.code and b.printer1 = c.code)
	select @printid = min(a.printid) from pos_dishcard a, pos_kitchen b, pos_printer c
	 where  a.changed<>'T' and b.pcode = @pserver and a.printer = c.code and b.printer1 = c.code
else
	begin  -- 打印餐单
	select @printid = min(a.printid) from pos_dishcard a, pos_kitchen b   
		where  a.changed='F' and charindex(rtrim(b.code), a.kitchens)>0 and b.pcode = @pserver
	end

if @printid is null or @printid = -1
begin
	select * from #card
	return 0
end

select @kitchens = ''
select  @changed=a.changed,@printer=printer,@menu=a.menu, @kitchens = isnull(a.kitchens,'') from pos_dishcard a where a.printid = @printid 

if @kitchens = '' and @changed = 'F'
	begin
	delete pos_dishcard where  printid = @printid 
	select * from #card
	return 0
	end
		
select @guest = guest, @tableno = tableno from pos_menu where menu = @menu
if @@rowcount = 0     -- menu记录不在pos_menu, 则删除该dishcard记录
	delete pos_dishcard where printid = @printid
else
	begin
	-- 点菜、起菜、备注
	if @changed<>'G' 
		insert #card select a.menu,a.printid,a.inumber,a.id,a.code,a.name1,a.unit,a.number,a.empno,a.date,b.code,'',c.code,'',a.refer,a.cook,a.changed,@color,a.tableno,'','',a.pc_id,'',a.times,a.price,@guest,'' from pos_dishcard a, pos_kitchen b, pos_printer c  where a.printid = @printid  and charindex(rtrim(b.code),a.kitchens)>0 and b.printer1 = c.code
	-- 打印客单
   else if @changed='G' 
   	insert #card select menu,printid,inumber,id,code,name1,unit,number,empno,date0,@kitchens,'',@printer,'','','','G',@color,@tableno,'','','0.00','',0 ,amount, @guest,'' from pos_dish where menu=@menu and charindex(sta,'0357M')>0 and charindex(rtrim(code),'XYZ')=0
	end


update #card set prn_name= b.name from #card a, pos_printer b where a.printer = b.code
update #card set kit_des= b.descript from #card a, pos_kitchen b where a.kitchen = b.code
update #card set tbl_des = b.descript1 from #card a, pos_tblsta b where a.tableno = b.tableno
update #card set pc_des = c.descript from #card a, pos_menu b, pos_pccode c where a.menu=b.menu and b.pccode=c.pccode
update #card set foliono = b.foliono from #card a, pos_menu b where a.menu=b.menu  

select * from #card order by printid, changed desc, date
return 0
;


