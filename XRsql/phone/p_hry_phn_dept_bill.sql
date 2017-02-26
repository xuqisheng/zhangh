IF OBJECT_ID('dbo.p_hry_phn_dept_bill') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_hry_phn_dept_bill
END;
create proc   p_hry_phn_dept_bill
   @pc_id     char(4),
   @dept      char(8),
   @s_time    datetime,
   @e_time    datetime,
   @rent      money

as

declare
   @date      datetime,
   @room      char(5),
   @calltype  char(1),
   @fee_base  money,
 @fee       money,
   @ret       int,
   @msg       varchar(60) 

select @ret=0,@msg=''
if @s_time > @e_time
   begin
   select @date = @s_time
   select @s_time = @e_time
   select @e_time = @date
   end

delete phn_dept_bill where pc_id = @pc_id
if @rent <> 0
   insert phn_dept_bill (pc_id,room,calltype,descript,no,fee_base,fee)
          select @pc_id,room,'{','',0,@rent,@rent from phdeptroom where dept = rtrim(@dept)
insert phn_dept_bill
       select @pc_id,room,calltype,'',count(*),sum(fee_base),sum(fee)
       from phfolio where refer = rtrim(@dept) and date >= @s_time and date <= @e_time
       group by room,calltype
update phn_dept_bill set descript = b.descript from phncls b where calltype = b.pgid
update phn_dept_bill set descript = 'ÔÂ×â·Ñ' where calltype = '{'
insert phn_dept_bill select @pc_id,'Total',b.calltype,b.descript,sum(b.no),sum(b.fee_base),sum(b.fee)
                     from phn_dept_bill b where b.pc_id = @pc_id  group by b.calltype,b.descript order by b.calltype,b.descript
select @ret,@msg
return @ret
;