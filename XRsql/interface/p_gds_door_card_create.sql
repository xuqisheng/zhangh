drop proc p_gds_door_card_create;
create proc p_gds_door_card_create
   @pc_id      char(10),
	@mode			varchar(10) = 'accnt' ,
	@flag			char(1) = 'T'
as
-- ----------------------------------------------------------------------------------
--		产生制作门卡的需求
--
--			这个过程一般都需要根据客户个性化定制 
-- ----------------------------------------------------------------------------------
declare
	@master		char(10)

create table #goutput (
	accnt				char(10)							not null,
	roomno			char(5)			default ''	not null,
	name				varchar(50)		default ''	not null,
	arr				datetime							not null,
	dep				datetime							not null,
	card_type		char(10)							not null,
	card_t   		char(10)							not null,
	number			int				default 1	not null,
	created			int				default 0	not null,
	flag				char(1)			default 'F' not null,
	encoder			char(10)  						null		,
	done				int				default 0   not null,
	back				int				default 0   not null
)

-- Insert data
if @mode = 'accnt' 
begin
	insert #goutput select distinct a.accnt, a.roomno, b.name, a.arr, a.dep, 'GUEST', '0', 1, 0, 'F', 'ZK',0,0
		from master a, guest b, selected_account c
		where c.type = 'd' and c.mdi_id = 0 and c.pc_id = @pc_id
			and (a.accnt = c.accnt or a.master = c.accnt or a.groupno = c.accnt or 
			a.saccnt in (select m.saccnt from master m, selected_account h where m.accnt = h.accnt and h.pc_id = @pc_id and h.type = 'd') or
			(a.pcrec in (select m.pcrec from master m, selected_account h where m.accnt = h.accnt and h.pc_id = @pc_id and h.type = 'd') and a.pcrec <> '') )
			and a.haccnt = b.no and a.sta in ('R', 'I') and a.roomno <> ''
	
	select @master = min(master) from master a, selected_account c where a.accnt = c.accnt and a.accnt <> a.master and c.pc_id = @pc_id and c.type = 'd'

	if @master <> '' and @master <> null
		insert #goutput select a.accnt,a.roomno,b.name,a.arr,a.dep,'GUEST','0',1,0,'T','ZK',0,0
			from master a, guest b where a.accnt = @master and a.haccnt = b.no and a.accnt not in (select accnt from #goutput)

	if @flag= 'F'
		begin
		delete from #goutput where accnt in (select accnt from doorcard_req where sta = 'I')
		end
	
	--调整 到店时间
	update #goutput set dep = convert(datetime,convert(char(8),dep,1) + ' 15:00:00')
	update #goutput set arr = dateadd(minute,-10,getdate())


end
else
begin  -- mode = 'room' --> selected_account.accnt = room 
	declare	@arr		datetime,
				@dep		datetime

	select @arr = getdate()
	select @dep = dateadd(hh, 1, @arr) 

	insert #goutput select 'Accnt', substring(c.accnt,1,5), 'Name', @arr, @dep, 'GUEST', '0', 1, 0, 'T', '',0,0
		from selected_account c, rmtmpsta a
		where c.accnt = a.roomno and c.type = 'd' and c.mdi_id = 0 and c.pc_id = @pc_id                                                 
	
	insert #goutput select 'Accnt', substring(c.accnt,1,5), 'Name',@arr, @dep, 'GUEST EXEC', '1', 1, 0, 'T', '',0,0
		from selected_account c, rmtmpsta a 
		where c.accnt = a.roomno and c.type='d' and c.mdi_id = 0 and c.pc_id = @pc_id                                             
end                                       

update #goutput set done = isnull((select count(1) from doorcard_req a where #goutput.accnt = a.accnt and sta = 'I'),0)
update #goutput set back = isnull((select count(1) from doorcard_req a where #goutput.accnt = a.accnt and sta = 'X'),0)

-- Summary Created Number .

select #goutput.accnt, #goutput.roomno, #goutput.name, #goutput.arr, #goutput.dep, #goutput.card_type, #goutput.card_t, #goutput.number, #goutput.created, #goutput.flag, #goutput.done,back from #goutput order by roomno, card_t

return 0;
