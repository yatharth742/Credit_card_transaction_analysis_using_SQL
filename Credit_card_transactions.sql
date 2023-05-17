
select * 
from Credit_card_transac
-- how many cities are present in dataset
select count(distinct City)
from Credit_card_transac

-- top 5 cities with highest spends and their percentage contribution of total credit card spends 

with N as (select City , sum(Amount_spend) as Amount_spend1
from Credit_card_transac
Group by City)

,M as (select sum(Amount_spend1) as Total_spend_amount  -- 4074833373
from N )

select top 5 city ,   Amount_spend1 , 
round(100.0* Amount_spend1/4074833373.0,2) as percentage_contribution_by_city
from N
order by Amount_spend1 desc

-- query to print highest spend month and amount spent in that month for each card type



with M as (select datepart(year, Transac_Date) as year_ , datepart(MONTH, Transac_Date) as month_ , 
Card_Type , sum(Amount_spend) as amt
from Credit_card_transac
group by Card_Type , datepart(year, Transac_Date),datepart(MONTH, Transac_Date)
) 

,k as (select year_ , month_ ,Card_type ,
Max(amt) over(partition by Card_type order by amt desc) highest_amt_spend_mnt,
ROW_NUMBER() over(partition by Card_type order by amt desc) as rn
from M)

select year_ , month_ ,Card_type ,highest_amt_spend_mnt
from K 
where rn = 1


-- 3- write a query to print the transaction details(all columns from the table) for each card type when
-- it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)

-- a query to find city which had lowest percentage spend for gold card type

with M as (select City , count(City) as cnt_gold_card, sum(Amount_spend) as amt_spend_by_gold_crd
from Credit_card_transac
where Card_Type = 'Gold'
group by City
)
select *
,(select sum(amt_spend_by_gold_crd)
from M) as Total_spend_by_gld_card,
amt_spend_by_gold_crd/(select sum(amt_spend_by_gold_crd) as per_spend
from M) as per_spend_
from M
order by amt_spend_by_gold_crd/(select sum(amt_spend_by_gold_crd)from M) asc

-- write a query to find percentage contribution of spends by females for each expense type

select * from Credit_card_transac

select Gender ,Exp_Type , sum(amount_spend) as amt_spend_by_females
from Credit_card_transac
where Gender = 'F'
group by Gender , Exp_Type
order by amt_spend_by_females desc

-- which card and expense type combination saw highest month over month growth in Jan-2014
with M as (select datepart(year,Transac_Date) as yy ,datepart(MONTH,Transac_Date) as mm,
Card_Type , sum(Amount_spend) as amt
from Credit_card_transac
where datepart(year,Transac_Date) = 2014 and datepart(MONTH,Transac_Date) = 1
Group by datepart(year,Transac_Date) , datepart(MONTH,Transac_Date) , Card_Type  
union all
select datepart(year,Transac_Date) as yy ,datepart(MONTH,Transac_Date) as mm,
Card_Type , sum(Amount_spend) as amt
from Credit_card_transac
where datepart(year,Transac_Date) = 2013 and datepart(MONTH,Transac_Date) = 12
Group by datepart(year,Transac_Date) , datepart(MONTH,Transac_Date) , Card_Type 
 )

select * ,
round(100.0*(amt - lag(amt,1) over(partition by Card_Type order by Card_Type , mm desc))/lag(amt,1) over(partition by Card_Type order by Card_Type , mm desc),2)
from M
Order by Card_Type , mm desc

-- only gold has shown highest month over month growth by margin

-- during weekends which city has highest total spend to total no of transcations ratio 

with M as (select datepart(year,Transac_Date) as yy  , datepart(WEEKDAY,Transac_Date) as ww , datename(weekday, Transac_Date) as name1 
, City , sum(Amount_spend)/count(*) as highest_total_spend_to_total_no_of_transcations_ratio 
from Credit_card_transac
group by City , datepart(year,Transac_Date) , datepart(WEEKDAY,Transac_Date) , datename(weekday, Transac_Date)
)
select City , yy , ww , name1,
sum(highest_total_spend_to_total_no_of_transcations_ratio) as highest_total_spend_to_total_no_of_transcations_ratio_
from M
where ww = 1 or ww = 7
group by City ,  yy , ww , name1
order by highest_total_spend_to_total_no_of_transcations_ratio_ desc

-- which city took least number of days to reach its 500th transaction after the first transaction in that city

with M as (select * , ROW_NUMBER() over(partition by City order by Transac_Date) as rn
from Credit_card_transac)
, N as (select *
from M 
where rn = 500)
,T as (select *
from M 
where rn = 1
)
select top 1 T.city , T.Transac_Date , N.Transac_Date , Datediff(day,T.Transac_Date , N.Transac_Date) as day_diff
from N 
inner join T 
on N.City = T.City
order by Datediff(day,T.Transac_Date , N.Transac_Date) asc
