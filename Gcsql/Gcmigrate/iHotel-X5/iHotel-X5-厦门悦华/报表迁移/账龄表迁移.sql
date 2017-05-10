SELECT 	MAX(b.date)
	FROM ar_master a,migrate_xmyh.yarging_rep b WHERE b.date >= '2014.01.01' AND a.arno = b.accnt ;
 
INSERT INTO `portal_tr`.`rep_arging_history` (`hotel_group_id`,`hotel_id`, `biz_date`, `descript`, `accnt`, `manual_no`, `name2`, `address`, 
	`mone11`, `mone12`, `mone13`, `mone14`, `mone15`,`mone16`, `mone17`, `mone18`, `mone19`, `mone20`)
SELECT 	1, 1, b.date, b.descript, a.id, b.accnt, b.name, b.address2, 
	b.m11, b.m12, b.m13, b.m14, b.m15, b.m16, b.m17, b.m18, b.m19, b.m20
	FROM ar_master a,migrate_xmyh.yarging_rep b WHERE b.date >= '2014.01.01' AND b.date <'2014.11.26' AND a.arno = b.accnt ;
