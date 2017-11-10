/*
----each----:[pos_menu.hotel_group_id][pos_menu.hotel_id][pos_menu.biz_date][pos_menu.menu_no][pos_menu.id]
----each----:[pos_dish.hotel_group_id][pos_dish.hotel_id][pos_dish.fee][pos_dish.menu_id][pos_dish.code]
----each----:[code_transaction.code][code_transaction.arrange_code]
*/

SELECT b.hotel_group_id gid,
       b.hotel_id hid,
       date(b.biz_date) biz_date,
       b.menu_no,
       b.id,
       (SELECT ifnull(SUM(fee),0) FROM pos_dish a,code_transaction c WHERE #a#gh# and a.menu_id=b.id and #c#gh# and a.code=c.code AND c.arrange_code<'9') as charge,
       (SELECT ifnull(SUM(fee),0) FROM pos_dish a,code_transaction c WHERE #a#gh# and a.menu_id=b.id and #c#gh# and a.code=c.code AND c.arrange_code>'9') as pay,
       (SELECT ifnull(SUM(fee),0) FROM pos_dish a,code_transaction c WHERE #a#gh# and a.menu_id=b.id and #c#gh# and a.code=c.code AND c.arrange_code<'9')-
       (SELECT ifnull(SUM(fee),0) FROM pos_dish a,code_transaction c WHERE #a#gh# and a.menu_id=b.id and #c#gh# and a.code=c.code AND c.arrange_code>'9') as balance
       FROM pos_menu b
       WHERE #b#gh#
       having balance <> 0
       ORDER BY b.biz_date,b.menu_no,b.id
