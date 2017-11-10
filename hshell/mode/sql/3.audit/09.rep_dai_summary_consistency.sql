/*
----each----:[rep_dai_history.biz_date][rep_dai_history.classno]
----each----:[rep_dai_history.last_bl][rep_dai_history.debit][rep_dai_history.credit][rep_dai_history.till_bl]
*/

select date(a.biz_date) biz_date,

       ifnull(sum(last_bl),0) as lastbl,
       ifnull(sum(debit ),0)  as debit,
       ifnull(sum(credit),0)  as credit,
       ifnull(sum(last_bl+debit-credit),0)  as computed_tillbl,
       ifnull(sum(till_bl),0) as tillbl,
       ifnull(sum(last_bl+debit-credit-till_bl),0) as diff
       from rep_dai_history a

       where #a#gh# and (a.classno='02000' or a.classno='03000')
       group by a.biz_date
       having diff <> 0
       order by a.biz_date
             