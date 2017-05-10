SELECT 27102.2+ 2520

-- 海宇咖啡厅 主营+2520 合计+2520
SELECT classno,descript,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99 FROM rep_jie_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.7' AND classno = '0104015';
UPDATE rep_jie_history SET month02 = month02 + 2520,month99 = month99 + 2520 WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07' AND classno = '0104015';
-- 其中 : 海宇咖啡厅 主营-2520 场租-1000,合计-2520
SELECT classno,descript,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99 FROM rep_jie_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.7' AND classno = '0104016';
UPDATE rep_jie_history SET month02 = month02 - 2520,month05=month05-1000,month99 = month99 - 2520 WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07' AND classno = '0104016';

-- 主营
SELECT classno,descript,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99 FROM rep_jie_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date > '2014.12.7' AND classno = '010';
UPDATE rep_jie_history SET month01 = month01 - 2520  WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07' AND classno = '010';


SELECT 27102.2+ 2520

-- 海宇咖啡厅 主营+2520 合计+2520
SELECT classno,descript,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99 FROM rep_jie_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date > '2014.12.7' AND classno = '0104015';
UPDATE rep_jie_history SET month02 = month02 + 2520,month99 = month99 + 2520 WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date > '2014.12.07' AND classno = '0104015';
-- 其中 : 海宇咖啡厅 主营-2520 场租-1000,合计-2520
SELECT classno,descript,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99 FROM rep_jie_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.7' AND classno = '0104016';
UPDATE rep_jie_history SET month02 = month02 - 2520,month05=month05-1000,month99 = month99 - 2520 WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date > '2014.12.07' AND classno = '0104016';

-- 主营
SELECT classno,descript,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99 FROM rep_jie_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date > '2014.12.7' AND classno = '010';
UPDATE rep_jie_history SET month01 = month01 - 2520  WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date > '2014.12.07' AND classno = '010';

-- 当前表

-- 海宇咖啡厅 主营+2520 合计+2520
SELECT classno,descript,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99 FROM rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date > '2014.12.7' AND classno = '0104015';
UPDATE rep_jie SET month02 = month02 + 2520,month99 = month99 + 2520 WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date > '2014.12.07' AND classno = '0104015';
-- 其中 : 海宇咖啡厅 主营-2520 场租-1000,合计-2520
SELECT classno,descript,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99 FROM rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date > '2014.12.7' AND classno = '0104016';
UPDATE rep_jie SET month02 = month02 - 2520,month05=month05-1000,month99 = month99 - 2520 WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date > '2014.12.07' AND classno = '0104016';

-- 主营
SELECT classno,descript,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99 FROM rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date > '2014.12.7' AND classno = '010';
UPDATE rep_jie SET month01 = month01 - 2520  WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date > '2014.12.07' AND classno = '010';
