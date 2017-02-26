IF OBJECT_ID('p_gds_info_gststa') IS NOT NULL
    DROP PROCEDURE p_gds_info_gststa
;
create proc p_gds_info_gststa
	@pc_id	char(4),
	@modu_id	 char(2),
	@dbegin	datetime,
	@dend		datetime
as

delete gststa_info where pc_id = @pc_id and modu_id=@modu_id
delete gststa1_info where pc_id = @pc_id and modu_id=@modu_id

insert gststa_info select @pc_id, @modu_id, gclass, order_, nation, descript, descript1, sequence, sum(dtc), sum(dgc), sum(dtt), sum(dgt)
		from ygststa
			where datediff(dd, date, @dbegin)<=0 and datediff(dd, date, @dend)>=0
			group by gclass, order_, nation, descript, descript1, sequence
			order by gclass, order_, nation, descript, descript1, sequence

insert gststa1_info select @pc_id,  @modu_id, gclass, wfrom, descript, descript1, sequence, sum(dtc), sum(dgc), sum(dtt), sum(dgt)
		from ygststa1
			where datediff(dd, date, @dbegin)<=0 and datediff(dd, date, @dend)>=0
			group by gclass, wfrom, descript, descript1, sequence
			order by gclass, wfrom, descript, descript1, sequence

return 0
;
