
/*
	会费输入, 用sp_menu, sp_dish 处理, vipcard 的有效期设置
*/
if exists(select 1 from sysobjects where name = 'p_cyj_spo_intput_tax' and type = 'P' )
	drop proc p_cyj_spo_intput_tax;
create proc p_cyj_spo_intput_tax
	@pccode	char(3),
	@cardno	char(7),
	@menu		char(10),
	@type		char(2),
	@sdate	datetime,
	@edate	datetime,
	@sdate_old	datetime,
	@edate_old	datetime,
	@id		integer,
	@code		char(15),
	@amount	money, 
	@empno	char(3),
	@shift	char(1),
	@pc_id	char(3)

as
declare
	@ret		int,
	@msg		char(32),
	@deptno	char(2),
	@bdate	datetime,
	@mode		char(3),
	@name1	char(20)

select @ret = 0, @msg = ''
select @bdate = bdate from sysdata
select @deptno = deptno from pccode where pccode = (select chgcod from pos_pccode where pccode = @pccode)
select @mode = mode from pos_pccode where pccode = @pccode
begin tran
save  tran t_tax
// menu
delete sp_menu where menu = @menu
insert sp_menu (	tag,menu,tables,guest,date0,bdate,shift,deptno,pccode,posno,tableno,
	mode,dsc_rate,reason,tea_rate,serve_rate,tax_rate,amount,empno3,sta,cardno,remark)
values('0', @menu, 0, 0, getdate(), @bdate, @shift, @deptno, @pccode, '', '',
	@mode, 0, '', 0, 0, 0, @amount, @empno, '2', @cardno, '会费输入')
//  dish

delete sp_dish where menu = @menu
select @name1 = name1 from pos_plu where charindex(plucode,(select plucode from pos_plucode_link where pccode = @pccode)) > 0 and id = @id
--exec p_cyj_spo_tax_input_dish	@menu	,@empno,	@code,1,@amount,'',@pc_id,'1',@name1,@ret output,@msg output		
exec p_cq_sp_input_dish @menu ,@empno, @id,1,@amount, '','',@name1,@pc_id, '', '',0
// sp_tax
delete sp_tax where cardno = @cardno and menu = @menu
insert sp_tax(cardno, type, menu, sdate, edate, amount, empno, logdate)
	values(@cardno, @type, @menu, @sdate, @edate, @amount, @empno, getdate())
// vipcard : arr , dep
//update vipcard set arr = @sdate, dep = @edate where no = @cardno
if @ret <> 0 
	rollback tran t_tax
commit tran
select @ret, @msg
;
