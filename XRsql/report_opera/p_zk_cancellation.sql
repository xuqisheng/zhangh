if exists(select * from sysobjects where name = "p_zk_room_plan" and type ='P')
	drop proc p_zk_room_plan
;


create proc p_zk_room_plan
   @start  datetime,
   @end    datetime,
   @roomtype   varchar(10)
as
declare
   @date   char(12),
   @ind_r  integer,
   @blk_r   integer,
   @d_blk    integer,
   @n_blk    integer,
   @t_rms    integer,
   @ooo      integer,
   @avbl     integer,
   @occ    money,
   @ind_revenue  money,
   @ind_avgrate   money,
   @blk_revenue   money,
   @blk_avgrate   money,
   @total_revenue money,
   @total_avgrate  money,
   @cur_date   char(12)
   
 
create table #bob
(
	date   char(12) null,
   ind_r  integer null,
   blk_r   integer null,
   d_blk    integer null,
   n_blk    integer null,
   t_rms    integer null,
   ooo      integer null,
   avbl     integer null ,
   occ    money null ,
   ind_revenue  money null ,
   ind_avgrate   money null,
   blk_revenue   money null,
   blk_avgrate   money null,
   total_revenue money null,
   total_avgrate  money null
)

