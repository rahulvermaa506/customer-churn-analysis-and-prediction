select * from stg_churn

-- ETL Process 

-- info of columns 
select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS
where table_name='stg_churn'

-- Null check 
select 
sum(case when Customer_ID is null then 1 else 0 end ) as Customer_ID_null,
sum(case when Gender is null then 1 else 0 end ) as gender_null,
sum(case when Age is null then 1 else 0 end ) as age_null , 
sum(case when Married is null then 1 else 0 end ) as Married_ID_null,
sum(case when State is null then 1 else 0 end ) as state_null,
sum(case when Number_of_Referrals is null then 1 else 0 end ) as Number_of_Referrals_null ,
sum(case when Tenure_in_Months is null then 1 else 0 end ) as Tenure_in_Months,
sum(case when Value_Deal is null then 1 else 0 end ) as Value_Deal,
sum(case when Phone_Service is null then 1 else 0 end ) as Phone_Service_null ,
sum(case when Multiple_Lines is null then 1 else 0 end ) as Multiple_Lines_null,
sum(case when Internet_Service is null then 1 else 0 end ) as Internet_Service_null,
sum(case when Internet_Type is null then 1 else 0 end ) as Internet_type_null ,
sum(case when Online_Security is null then 1 else 0 end ) as Online_Security_null,
sum(case when Online_Backup is null then 1 else 0 end ) as Online_backup_null,
sum(case when Device_Protection_Plan is null then 1 else 0 end ) as Device_Protection_Plan_null ,
sum(case when Premium_Support is null then 1 else 0 end ) as Premium_Support_null,
sum(case when Streaming_TV is null then 1 else 0 end ) as Streaming_TV_null,
sum(case when Streaming_Music is null then 1 else 0 end ) as Streaming_Music_null ,
sum(case when Streaming_Movies is null then 1 else 0 end ) as Streaming_Movies_null,
sum(case when Unlimited_Data is null then 1 else 0 end ) as unlimited_data_null,
sum(case when Contract is null then 1 else 0 end ) as Contract_null ,
sum(case when Paperless_Billing is null then 1 else 0 end ) as Paperless_Billing_null,
sum(case when Payment_Method is null then 1 else 0 end ) as Payment_Method_null,
sum(case when Monthly_Charge is null then 1 else 0 end ) as Monthly_Charge_null ,
sum(case when Total_Charges is null then 1 else 0 end ) as Total_Charges_null,
sum(case when Total_Refunds is null then 1 else 0 end ) as Total_Refunds_null,
sum(case when Total_Extra_Data_Charges is null then 1 else 0 end ) as Total_Extra_Data_Charges_null ,
sum(case when Total_Long_Distance_Charges is null then 1 else 0 end ) as Total_Long_Distance_Charges_null,
sum(case when Total_Revenue is null then 1 else 0 end ) as Total_Revenue_null,
sum(case when Customer_Status is null then 1 else 0 end ) as Customer_Status_null ,
sum(case when Churn_Category is null then 1 else 0 end ) as Churn_Category_null,
sum(case when Churn_Reason is null then 1 else 0 end ) as Churn_Reason_null
from stg_churn

-- imputation 
select 
Customer_ID,
Gender,
Age,
Married,
State,
Number_of_Referrals,
Tenure_in_Months,
isnull(Value_Deal,'None') as Value_Deal,
Phone_Service,
isnull(Multiple_Lines,'No') As Multiple_Lines ,
Internet_Service,
isnull(Internet_Type,'None') as Internet_Type,
isnull(Online_Security,'No') as Online_Security,
isnull(Online_Backup,'No') as Online_Backup,
isnull(Device_Protection_Plan,'No') as Device_Protection_Plan,
isnull(Premium_Support,'No') as Premium_Support,
isnull(Streaming_TV,'No') as Streaming_TV,
isnull(Streaming_Movies,'No') as Streaming_Movies,
isnull(Streaming_Music,'No') as Streaming_Music,
isnull(Unlimited_Data,'No') as Unlimited_Data,
Contract,
Paperless_Billing,
Payment_Method,
Monthly_Charge,
Total_Charges,
Total_Refunds,
Total_Extra_Data_Charges,
Total_Long_Distance_Charges,
Total_Revenue,
Customer_Status,
isnull(Churn_Category,'Other') as Churn_Category,
isnull(Churn_Reason,'Other') as Churn_Reason
into [pro].[dbo].[clean_stg]
from [pro].[dbo].[stg_churn];

-- create a view 
create view vw_ChurnData as 
    select * from clean_stg where Customer_Status in ('Churned','Stayed') 

create view vw_JoinData as 
     select * from clean_stg where Customer_Status = 'Joined'


-- create a index 
create index idx_customer_status 
on stg_churn(Customer_status );

-- * Data Distribution 

-- Gender 
select Gender , count(Gender) as total_count ,
round(100.0*count(Gender)/(select count(*) from stg_churn),2) as percentage_
from stg_churn
group by Gender;

-- contract 

select Contract , count(Contract) as total_count ,
round(count(Contract)*100.0/(select count(*) from stg_churn),2) as percentage_
from stg_churn
group by Contract;


-- churn

select Customer_Status , count(Customer_Status) as total_count , 
round(count(Customer_Status)*100.0/(select count(*) from stg_churn),2) as percentage_,
sum(Total_Revenue) as total_reven , 
ROUND(SUM(Total_Revenue)*100.0/(select sum(Total_Revenue) from stg_churn),2) as rev_precentage
from stg_churn
group by Customer_Status;

-- state

select State ,  count(State) as total_count ,
round(count(State)*100.0/(select count(*) from stg_churn),2) as percentage_ 
from stg_churn
group by State

-- state and customer status 

select State, Customer_Status ,  count(State) as total_count ,
round(COUNT(State)*100.0/ sum(COUNT(*)) over(partition by state),2) as percentage_state
from stg_churn
group by State , Customer_Status
order by State , total_count desc


-- top 5 satyed rate state

select  top 5 * from (select State, Customer_Status ,  count(State) as total_count ,
                 round(COUNT(State)*100.0/ sum(COUNT(*)) over(partition by state),2) as percentage_state
                 from stg_churn
                 group by State , Customer_Status) as f 
where f.Customer_Status = 'Stayed'
order by f.percentage_state desc

-- top 5 churn rate state

select  top 5 * from (select State, Customer_Status ,  count(State) as total_count ,
                 round(COUNT(State)*100.0/ sum(COUNT(*)) over(partition by state),2) as percentage_state
                 from stg_churn
                 group by State , Customer_Status) as f 
where f.Customer_Status = 'Churned'
order by f.percentage_state desc


-- internet type revenue 

select Internet_Type , sum(Total_Revenue),
round(sum(Total_Revenue)*100.0/(select sum(Total_Revenue) from stg_churn),2) as percentage_
from stg_churn
group by Internet_Type


-- contract and payment method 

select Payment_Method, Contract , count(*) as total_customer,
sum(case when Customer_Status = 'Churned' then 1 else 0 end) as total_churn , 
round(sum(case when Customer_Status = 'Churned' then 1 else 0 end)
*100.0/(select count(*) from clean_stg where Customer_Status = 'Churned' ),2)
as churn_contribution , 
round(sum(case when Customer_Status = 'Churned' then 1 else 0 end)*100.0/count(*),2) as churn_rate_segment
from clean_stg
group by Payment_Method, Contract
order by Payment_Method ,churn_contribution desc;
