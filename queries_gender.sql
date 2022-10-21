create database if not exists gender;

use gender;

UPDATE tertiary_female
SET tertiary_female.2020 = 53.3
WHERE Geographicregion = 'UK';

UPDATE tertiary_male
SET tertiary_male.2020 = 46.6
WHERE Geographicregion = 'UK';

UPDATE paygap
SET paygap.2020 = 10.4
WHERE Geographicregion = 'Greece';

UPDATE paygap
SET paygap.2020 = 19.8
WHERE Geographicregion = 'UK';

UPDATE paygap
SET paygap.2020 = 11.3
WHERE Geographicregion = 'Ireland';

CREATE TABLE hf AS
SELECT *
FROM hrst
where hrst.sex = 'F' ;
    
CREATE TABLE hm AS
SELECT *
FROM hrst
where hrst.sex = 'M' ;

-- first indicator is the ratio of women to men in tertiary education of stem/or working in stem :hrst_ratio
-- as a percentage of labor force
select * from hrst;

CREATE TEMPORARY TABLE hrst_ratio AS
SELECT hm.geo, (hf.2020 / hm.2020) as ratio_stem
from hf
left join hm
on hf.geo = hm.geo;

-- second indicator is ratio of percentage of women to men that achieve a degree in IT or engineering: degree_ratio
select * from degree_per;
drop temporary table degree_ratio;
CREATE TEMPORARY TABLE degree_ratio AS
select Country as geo, AVG(value) as ratio_iteng
from degree_per
where job = 'Information & Comm. Technologies, attainment %'
or job = 'Engineering, Manuf. & Construction, attainment %'
GROUP BY Country;

-- third indicator, paygap as a difference in percent of male role pay unadjusted: paygap_rat
select * from paygap;

CREATE TEMPORARY TABLE paygap_rat AS
select Geographicregion as geo, (1-paygap.2020/100) as pay_ratio from paygap;

-- show inequality in tech jobs between men and women: tech_job_rat
CREATE temporary TABLE tech_job_rat AS
select Country as geo, avg(WOMEN/MEN) AS tech_job_ratio from tech_jobs_per
where JOBS = 'cloud computing (%)' 
or JOBS = 'engineering(%)'
OR JOBS = 'Data and AI(%)'
group by Country;

-- fourth indicator is ratio of women to men completing tertiary education: tertiary_ratio
CREATE temporary TABLE tertiary_ratio AS
select tm.Geographicregion as geo, CAST(tf.2019 AS DECIMAL(10, 4))/CAST(tm.2019 AS DECIMAL(10, 4)) as ter_rat
from tertiary_female tf
left join tertiary_male tm
on tf.Geographicregion = tm.Geographicregion
;

-- find index and join
select max(hr.ratio_stem), min(hr.ratio_stem)
from hrst_ratio hr;

select max(dr.ratio_iteng), min(dr.ratio_iteng)
from degree_ratio dr;

select max(pr.pay_ratio), min(pr.pay_ratio) 
from paygap_rat pr;

select max(tr.ter_rat), min(tr.ter_rat)
from tertiary_ratio tr;

select geo, -(2* norm_ratio_stem + 3* norm_ratio_iteng + norm_pay_ratio + norm_ter_ratio) as _index_
from(
select hr.geo, ((hr.ratio_stem  - 1.52)/(1.52 - 0.99)) as norm_ratio_stem, 
((dr.ratio_iteng - 0.39)/(0.39 - 0.14)) as norm_ratio_iteng,
((pr.pay_ratio - 1)/(1 - 0.78)) as norm_pay_ratio,
((tr.ter_rat - 1.84)/(1.84 - 0.94)) as norm_ter_ratio
from hrst_ratio hr
left join degree_ratio dr
on hr.geo LIKE dr.geo
left join paygap_rat pr 
on hr.geo LIKE pr.geo
left join tertiary_ratio tr
on hr.geo LIKE tr.geo
) as t1
order by _index_;

select hr.geo, ((hr.ratio_stem  - 1.52)/(1.52 - 0.99)) as norm_ratio_stem, 
((dr.ratio_iteng - 0.39)/(0.39 - 0.14)) as norm_ratio_iteng,
((pr.pay_ratio - 1)/(1 - 0.78)) as norm_pay_ratio,
((tr.ter_rat - 1.84)/(1.84 - 0.94)) as norm_ter_ratio
from hrst_ratio hr
left join degree_ratio dr
on hr.geo LIKE dr.geo
left join paygap_rat pr 
on hr.geo LIKE pr.geo
left join tertiary_ratio tr
on hr.geo LIKE tr.geo;
