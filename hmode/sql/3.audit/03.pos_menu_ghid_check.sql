/*
----each----:[pos_menu.hotel_group_id][pos_menu.hotel_id][pos_menu.biz_date][pos_menu.menu_no][pos_menu.id]
----each----:[pos_dish.hotel_group_id][pos_dish.hotel_id]
----each----:[do_not_check]
*/

SELECT 
       date(b.biz_date) as biz_date,
       b.menu_no,
       b.id,
       b.hotel_group_id as pos_menu_gid,
       b.hotel_id as pos_menu_hid,
       (select min(c.hotel_group_id) from pos_dish c where c.menu_id=b.id) as pos_dish_gid,
       (select min(c.hotel_id)       from pos_dish c where c.menu_id=b.id) as pos_dish_hid
       FROM pos_menu b
       WHERE #b#gh#
       having pos_menu_gid <> pos_dish_gid or pos_menu_hid <> pos_dish_hid
       ORDER BY b.biz_date,b.menu_no,b.id
