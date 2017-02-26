/*
----each----:[rep_dai_history.biz_date][rep_dai_history.classno][rep_dai_history.last_bl][rep_dai_history.till_bl]
*/

select date(a.biz_date) biz_date,

       ifnull(sum(a.last_bl),0) 
       as lastbl_of_thisday,

       (select ifnull(sum(b.till_bl),0) from rep_dai_history b
                                        where #ba#gh# and (b.classno='02000' or b.classno='03000') and b.biz_date=adddate(a.biz_date,-1))
       as tillbl_of_lastday,

       ifnull(sum(a.last_bl),0) - 
       (select ifnull(sum(b.till_bl),0) from rep_dai_history b
                                        where #ba#gh# and (b.classno='02000' or b.classno='03000') and b.biz_date=adddate(a.biz_date,-1))

       as diff_2balances

       from rep_dai_history a

       where #a#gh# and (a.classno='02000' or a.classno='03000')
       group by a.biz_date
       having diff_2balances <> 0
       order by a.biz_date
             