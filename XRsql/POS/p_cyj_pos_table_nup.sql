if exists(select 1 from sysobjects where name ='p_cyj_pos_table_nup' and type ='P')
	drop proc p_cyj_pos_table_nup;
create proc p_cyj_pos_table_nup
	@pc_id		char(4),					--ˢ��IP
	@bdate		datetime,				          
	@shift		char(1),					          
	@pccode		char(3),
	@tableno		char(4),             -- ��ѯ��ʼ̨�ţ� X5��汾���ã���֤�汾ͳһ����
	@pccodes		char(255),
	@status		char(4),					          
	@menu			char(10),				    
	@foot			char(1) = 'F'	,
	@flag			char(1) 					--1.��λͼ  2.	�б�	                                          

as
-------------------------------------------------------------------------------------------------
--
--	��λͼһ: datawindow��nup��ʾ��ʽ
--	 ̨λͼ�����»���״̬
--		sta = '0'  --- ����
--		sta = '1'  --- Ԥ��
--		sta = '2'  --- ��̨
--		sta = '3'  --- �㵥
--		sta = '4'  --- ����
--		sta = '5'  --- �ϲ�
--		sta = '6'  --- ����
--		sta = '7'  --- Ԥ��

--		����̬��
--		�Ƿ��Ѵ򵥣���ѡ�е��Ƿ�ͬ�����������Ƿ��м�ʱ��
--
-------------------------------------------------------------------------------------------------

declare
	@sta			char(1),
	@box			char(1),
	@timesta		char(1),                                  
	@showtimes	int,						                              
	@num0			int,						        
	@num1			int,						        
	@num2			int,						        	
	@num3			int,						        
	@num4			int,						        	
	@num5			int,						        
	@num6			int,						        
	@num7			int,
	@num8			int,			
	@num			int						        

create table #tblsta
(
	tableno 		char(16)      default space(16) not null,
	pcdes			char(20)      default space(20) not null,
	tabdes1		char(10)  default space(10) not null,
	tabdes2		char(10)      default space(10) not null,
	maxno			int     		  default 0 not null,
	pccode		char(3)       default space(3) not null,
	sta			char(1)       default space(1) not null,
	remark1		char(10)      default space(10) not null,
	remark2		char(20)      default space(20) not null,
	menu			char(10)      default space(10) not null,
	box			char(1)       default space(1) not null,
	timesta		int      	  default 0 not null, 
	lasttimes	char(4)		  default ''  null,    		                                    
	showtime		char(10)		  default 'F' null,                                          
	jion			char(10)		  default 'F' null,  
	prn			char(10)		  default 'F' null,
	tag_des		char(10)		  null,
	bdate			datetime		  ,
	shift			char(1)		  not null,
	tables		integer			,
	guests		integer			,
	empno3		char(10)			,
	amount		money				,
	pcrec			char(10),	
	resno			char(10),
	sta0			char(1)     
)

select @box = '0'

if @status = '����'
begin
	if @flag = '1'
		begin
--��ʾ��ǰԤ����Ϣ
		insert into #tblsta
		SELECT b.tableno, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = b.sta, remark1 = d.resno, remark2 = isnull(d.phone,''), b.menu, box = @box, timesta =0, lasttimes ='',showtime='0', jion = 'F',prn='F',
					e.descript,b.bdate,d.shift,d.tables,d.guest,d.empno,0.00,'',d.resno,''
		 FROM pos_tblsta a, pos_tblav b, pos_pccode c, pos_reserve d,basecode e
		 WHERE d.pccode = c.pccode and d.resno = b.menu  and b.sta > '0' and b.tableno *= a.tableno and datediff(day, b.bdate, @bdate)=0 and b.shift = @shift and d.sta <> '7' 
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0)) and b.menu = d.resno and d.tag = e.code and e.cat = 'pos_tag'
--��ʾ��ǰ��̨��Ϣ			
		UNION ALL SELECT rtrim(b.tableno) + '-' + d.foliono, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = d.sta, remark1 = d.menu, remark2 = ltrim(convert(char(20), d.amount)), b.menu, box = @box, 
					timesta =0, lasttimes='',
				showtime='0',jion='F',prn='F',
				e.descript,d.bdate,d.shift,d.tables,d.guest,d.empno3,d.amount,d.pcrec,d.resno,''
		 FROM pos_tblsta a, pos_tblav b, pos_pccode c, pos_menu d ,basecode e
		 WHERE d.pccode = c.pccode  and b.menu = d.menu and b.sta >= '0' and b.tableno *= a.tableno and datediff(day, d.bdate, @bdate)=0 and d.shift = @shift
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0 )) 
				 and charindex(d.sta, '256')>0 and d.tag = e.code and e.cat = 'pos_tag'
--��Ӫҵ��������ʾ���˵���Ϣ
		UNION ALL SELECT rtrim(d.tableno) + '-' + d.foliono, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = d.sta, remark1 = d.menu, remark2 = ltrim(convert(char(20), d.amount)), d.menu, box = @box, 
					timesta =0, lasttimes='',
				showtime='0',jion='F',prn='F',
				e.descript,d.bdate,d.shift,d.tables,d.guest,d.empno3,d.amount,d.pcrec,d.resno,''
		 FROM pos_tblsta a, pos_pccode c, pos_menu d ,basecode e
		 WHERE d.pccode = c.pccode and datediff(day, d.bdate, @bdate)=0 and d.shift = @shift and d.tableno *= a.tableno
				 and d.sta = '4' and d.tag = e.code and e.cat = 'pos_tag'
--				 and (rtrim(@pccode) is null) and d.sta = '4' and d.tag = e.code and e.cat = 'pos_tag'
					 
--��ʾδռ�õ�̨����Ϣ
		UNION ALL SELECT a.tableno, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), a.maxno, a.pccode,
				 sta = "0", '', '', '', box = @box, timesta =0, lasttimes ='',showtime='0', jion='F',prn='F',
					'',getdate(),'',0,0,'',0.00,'','',''
		 FROM pos_tblsta a, pos_pccode c
		 WHERE a.pccode = c.pccode and (a.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(a.pccode), @pccodes) > 0))
				and (select isnull(max(b.sta), '0') from pos_tblav b,pos_menu d where b.tableno = a.tableno and b.menu=d.menu and d.pccode = a.pccode and datediff(day, b.bdate, @bdate) = 0 and b.shift = @shift and d.sta<>'7') = '0'
				and (select isnull(max(b.sta), '0') from pos_tblav b,pos_reserve d where b.tableno = a.tableno and b.menu=d.resno and d.pccode = a.pccode and datediff(day, b.bdate, @bdate) = 0 and b.shift = @shift) = '0'
					
		 ORDER BY d.pccode, b.tableno, sta
		end
	else if @flag = '2'  --�б���Ч
		begin
--��ʾ��ǰԤ����Ϣ
		insert into #tblsta
		SELECT b.tableno, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = b.sta, remark1 = d.resno, remark2 = isnull(d.phone,''), b.menu, box = @box, timesta =0, lasttimes ='',showtime='0', jion = 'F',prn='F',
					e.descript,b.bdate,d.shift,d.tables,d.guest,d.empno,0.00,'',d.resno,''
		 FROM pos_tblsta a, pos_tblav b, pos_pccode c, pos_reserve d,basecode e
		 WHERE d.pccode = c.pccode and d.resno = b.menu  and b.sta > '0' and b.tableno *= a.tableno and datediff(day, b.bdate, @bdate)=0 and b.shift = @shift and d.sta <> '7' 
				 and (d.pccode = @pccode or((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0)) and b.menu = d.resno and d.tag = e.code and e.cat = 'pos_tag'
--��ʾ��ǰ��̨��Ϣ					
		UNION ALL SELECT rtrim(b.tableno) + '-' + d.foliono, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = b.sta, remark1 = d.menu, remark2 = ltrim(convert(char(20), d.amount)), b.menu, box = @box, 
				timesta =0, lasttimes='',
				showtime='0',jion='F',prn='F',
				e.descript,b.bdate,d.shift,d.tables,d.guest,d.empno3,d.amount,d.pcrec,d.resno,''
		 FROM pos_tblsta a, pos_tblav b, pos_pccode c, pos_menu d ,basecode e
		 WHERE d.pccode = c.pccode and b.menu = d.menu and b.sta >= '0' and b.tableno *= a.tableno and datediff(day, d.bdate, @bdate)=0 and d.shift = @shift
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0)) and d.tag = e.code and e.cat = 'pos_tag'
				 and charindex(d.sta, '256')>0
--��Ӫҵ��������ʾ���˵���Ϣ		
		UNION ALL SELECT rtrim(d.tableno) + '-' + d.foliono, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = d.sta, remark1 = d.menu, remark2 = ltrim(convert(char(20), d.amount)), d.menu, box = @box, 
				timesta =0, lasttimes='',
				showtime='0',jion='F',prn='F',
				e.descript,d.bdate,d.shift,d.tables,d.guest,d.empno3,d.amount,d.pcrec,d.resno,''
		 FROM pos_tblsta a, pos_pccode c, pos_menu d ,basecode e
		 WHERE d.pccode = c.pccode and d.tableno *= a.tableno and datediff(day, d.bdate, @bdate)=0 and d.shift = @shift
				 and (rtrim(@pccode) is null) and d.sta = '4' and d.tag = e.code and e.cat = 'pos_tag'
		end
	else if @flag = '3'	--�б�ɾ��
		begin
		insert into #tblsta
		SELECT rtrim(d.tableno) + '-' + d.foliono, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = d.sta, remark1 = d.menu, remark2 = ltrim(convert(char(20), d.amount)), d.menu, box = @box, 
				timesta =0, lasttimes='',
				showtime='0',jion='F',prn='F',
				e.descript,d.bdate,d.shift,d.tables,d.guest,d.empno3,d.amount,d.pcrec,d.resno,''
		 FROM pos_tblsta a, pos_pccode c, pos_menu d ,basecode e
		 WHERE d.pccode = c.pccode  and d.tableno *= a.tableno and datediff(day, d.bdate, @bdate)=0 and d.shift = @shift
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0)) and d.tag = e.code and e.cat = 'pos_tag'
					and d.sta = '7'
		end
	else if @flag = '4'	--�б����
		begin
		insert into #tblsta
		SELECT rtrim(d.tableno) + '-' + d.foliono, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = d.sta, remark1 = d.menu, remark2 = ltrim(convert(char(20), d.amount)), d.menu, box = @box, 
				timesta =0, lasttimes='',
				showtime='0',jion='F',prn='F',
				e.descript,d.bdate,d.shift,d.tables,d.guest,d.empno3,d.amount,d.pcrec,d.resno,''
		 FROM pos_tblsta a, pos_pccode c, pos_menu d ,basecode e
		 WHERE d.pccode = c.pccode  and d.tableno *= a.tableno and datediff(day, d.bdate, @bdate)=0 and d.shift = @shift
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0)) and d.tag = e.code and e.cat = 'pos_tag'
					and d.sta = '3'
		end
	else if @flag = '5'	--����
		begin
		insert into #tblsta
		SELECT rtrim(d.tableno) + '-' + d.foliono, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = d.sta, remark1 = d.menu, remark2 = ltrim(convert(char(20), d.amount)), d.menu, box = @box, 
				timesta =0, lasttimes='',
				showtime='0',jion='F',prn='F',
				e.descript,d.bdate,d.shift,d.tables,d.guest,d.empno3,d.amount,d.pcrec,d.resno,''
		 FROM pos_tblsta a, pos_pccode c, pos_menu d ,basecode e
		 WHERE d.pccode = c.pccode  and d.tableno *= a.tableno and datediff(day, d.bdate, @bdate)=0 and d.shift = @shift
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0)) and d.tag = e.code and e.cat = 'pos_tag'
					and d.sta = '4'
		end
	else if @flag = '6'	--Ԥ��
		begin
		insert into #tblsta
		SELECT rtrim(d.tableno) + '-' + d.foliono, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = d.sta, remark1 = d.menu, remark2 = ltrim(convert(char(20), d.amount)), d.menu, box = @box, 
				timesta =0, lasttimes='',
				showtime='0',jion='F',prn='F',
				e.descript,d.bdate,d.shift,d.tables,d.guest,d.empno3,d.amount,d.pcrec,d.resno,''
		 FROM pos_tblsta a, pos_pccode c, pos_menu d ,basecode e
		 WHERE d.pccode = c.pccode  and d.tableno *= a.tableno and datediff(day, d.bdate, @bdate)=0 and d.shift = @shift
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0)) and d.tag = e.code and e.cat = 'pos_tag'
					and d.sta = '6'
		end
	else if @flag = '7'  --�б�����
		begin
		insert into #tblsta
		SELECT b.tableno, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = b.sta, remark1 = d.resno, remark2 = isnull(d.phone,''), b.menu, box = @box, timesta =0, lasttimes ='',showtime='0', jion = 'F',prn='F',
					e.descript,b.bdate,d.shift,d.tables,d.guest,d.empno,0.00,'',d.resno,''
		 FROM pos_tblsta a, pos_tblav b, pos_pccode c, pos_reserve d,basecode e
		 WHERE d.pccode = c.pccode and d.resno = b.menu  and b.sta > '0' and b.tableno *= a.tableno and datediff(day, b.bdate, @bdate)=0 and b.shift = @shift and d.sta <> '7' 
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0)) and b.menu = d.resno and d.tag = e.code and e.cat = 'pos_tag'
					
		UNION ALL SELECT rtrim(d.tableno) + '-' + d.foliono, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta= d.sta, remark1 = d.menu, remark2 = ltrim(convert(char(20), d.amount)), d.menu, box = @box, 
				timesta =0, lasttimes='',
				showtime='0',jion='F',prn='F',
				e.descript,d.bdate,d.shift,d.tables,d.guest,d.empno3,d.amount,d.pcrec,d.resno,''
		 FROM pos_tblsta a, pos_pccode c, pos_menu d ,basecode e
		 WHERE d.pccode = c.pccode and d.tableno *= a.tableno and datediff(day, d.bdate, @bdate)=0 and d.shift = @shift
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and d.sta<>'4' and charindex(rtrim(d.pccode), @pccodes) > 0 )) and d.tag = e.code and e.cat = 'pos_tag'
--��Ӫҵ��������ʾ���˵���Ϣ
		UNION ALL SELECT rtrim(d.tableno) + '-' + d.foliono, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta =d.sta, remark1 = d.menu, remark2 = ltrim(convert(char(20), d.amount)), d.menu, box = @box, 
				timesta =0, lasttimes='',
				showtime='0',jion='F',prn='F',
				e.descript,d.bdate,d.shift,d.tables,d.guest,d.empno3,d.amount,d.pcrec,d.resno,''
		 FROM pos_tblsta a, pos_pccode c, pos_menu d ,basecode e
		 WHERE d.pccode = c.pccode and d.tableno *= a.tableno and datediff(day, d.bdate, @bdate)=0 and d.shift = @shift
				 and (rtrim(@pccode) is null) and d.sta = '4' and d.tag = e.code and e.cat = 'pos_tag'


		end
	
end 
else if @status = '����'
	insert into  #tblsta
	SELECT a.tableno, isnull(c.descript,''), isnull(a.descript1,''),isnull(a.descript2,''), a.maxno, a.pccode,
			 '0', '', '', '', box = @box, timesta =0, lasttimes ='',showtime='0',jion='F',prn='F',
				'',getdate(),'',0,0,'',0.00,'','',''
	 FROM pos_tblsta a, pos_pccode c
	 WHERE a.pccode = c.pccode and (a.pccode = @pccode or (@pccode = '  ' and charindex(rtrim(a.pccode), @pccodes) > 0))
	 		and (select isnull(max(b.sta), '0') from pos_tblav b where b.tableno = a.tableno and datediff(day, b.bdate, @bdate) = 0 and b.shift = @shift) = '0'
	 ORDER BY a.pccode, a.tableno
   
delete #tblsta from #tblsta a  where sta = '7' and  tableno + menu in (select tableno + menu from #tblsta b where a.tableno = b.tableno and a.menu = b.menu and b.sta ='8')

update #tblsta set sta = '3' from #tblsta a, pos_menu b where a.menu = b.menu and b.amount > 0 and exists(select 1 from pos_dish c where b.menu = c.menu  and  charindex(rtrim(c.code),'XYZ') =0 )
-- ����
update #tblsta set sta = '4' from #tblsta a, pos_menu b where a.menu = b.menu and b.sta = '4' 
-- ����2�У�����ٶ�����Ҫע�͵�
update #tblsta set sta = '5' from #tblsta a where exists(select 1 from pos_dish b where a.menu = b.menu and substring(b.flag,23,1) = 'T' )
update #tblsta set sta = '6' from #tblsta a where not exists(select 1 from pos_dish b where a.menu = b.menu and substring(b.flag,23,1) = 'F'  and  charindex(rtrim(code),'XYZ') =0 ) and exists(select 1 from pos_dish c where a.menu = c.menu and charindex(rtrim(code),'XYZ') =0)

-- Ԥ�� pos_menu.sta='6'
update #tblsta set sta ='7' from #tblsta a, pos_menu b where a.menu=b.menu and b.sta='6'

                    
select @showtimes = convert(int, rtrim(value)) from sysoption where catalog = 'pos' and item ='showtimes'
if @@rowcount = 0 
begin
	--insert into sysoption values('pos', 'showtimes', '0', '','','','',getdate(),'','')
	select @showtimes = 0
end 
update #tblsta set showtime = 'T' where convert(int, lasttimes) - @showtimes < 0

if rtrim(@menu) <> null 
	begin
	update #tblsta set jion = 'J' where menu in (select b.menu from pos_tblav a, pos_tblav b  where a.menu = @menu  and a.pcrec = b.pcrec and rtrim(a.pcrec)<>null)
	update #tblsta set jion = 'T' where menu = @menu 
	end

update #tblsta set prn = 'T' from #tblsta a, pos_menu_bill b where a.menu = b.menu and inumber >0

update #tblsta set jion = '' where jion <> 'J' and jion <> 'T'
update #tblsta set jion = '��' where jion = 'T'
update #tblsta set jion = '��' where jion = 'J'

update #tblsta set prn = '' where prn <> 'T'
update #tblsta set prn = '��' where prn = 'T'
                
delete pos_tblmap where pc_id = @pc_id
insert pos_tblmap select @pc_id,a.pccode,a.tableno,a.tabdes1,a.menu,a.sta,a.bdate,a.shift,a.tables,a.guests,a.empno3,a.amount,a.pcrec,a.resno from #tblsta a

update #tblsta set sta0 = b.sta from #tblsta a, pos_menu b where a.menu = b.menu
update #tblsta set sta0 = b.sta from #tblsta a, pos_reserve b where a.menu = b.resno and b.sta <> '2'
// Ԥ��ȷ��
update #tblsta set sta0 = '8' from #tblsta a, pos_reserve b where a.menu = b.resno and b.sta = '2'


if @foot = 'F'                  
	select a.*,b.date0 from #tblsta a,pos_menu b where a.menu *= b.menu  order by a.pccode,a.tableno
else
	begin
	select @num0 = 0, @num1 = 0, @num2 = 0, @num3 = 0, @num4 = 0, @num5 = 0, @num6 = 0, @num7 = 0, @num8 = 0, @num = 0 
	select @num0 = count(1) from #tblsta where sta = '0'
	select @num1 = count(1) from #tblsta where sta = '1'
	select @num2 = count(1) from #tblsta where sta = '2'
	select @num3 = count(1) from #tblsta where sta = '3'
	select @num4 = count(1) from #tblsta where sta = '4'
	select @num5 = count(1) from #tblsta where sta = '5'
	select @num6 = count(1) from #tblsta where sta = '6'
	select @num7 =count(1) from #tblsta where charindex(sta , '234567') >0
	select @num8 = count(1) from #tblsta where sta = '8'
	select @num = count(1) from pos_tblsta
	select @num0, @num1, @num2,@num3, @num4, @num5, @num6, @num7, @num8, @num
	end
;
