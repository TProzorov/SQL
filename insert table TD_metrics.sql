
insert into TD_metrics_dayly ( effective_date, branch_name, segment,product_type_id, category_type,macroregion, AU, AU_balance, NU, NU_balance,  CU, CU_balance)

select 

        AU.effective_date,  
        AU.branch_name,
        AU.segment,
        AU.product_type_id,
        AU.category_type,
        macroregion,
      AU,
      AU_balance,
      NU,
      NU_balance,
      CU,
      CU_balance
           
from   (select 
                          effective_date,  
                          branch_name,
                          segment,
                          product_type_id,
                          category_type,
                        count(distinct customer) as AU,
                        sum(SUM_AMOUNT_LCY + ACCRUED_AMOUNT_LCY) as AU_balance                        
                  from   TD_DEPOSITS_dayly 
                  where effective_date = to_date(current_date - 1)   --current_date 
                  group by  effective_date, branch_name, segment, product_type_id,category_type
                  order by effective_date)  AU
                  
        left join (select 
                          effective_date ,
                          branch_name,
                          segment,
                          product_type_id,
                          category_type,
                        count(distinct customer) as NU,
                        sum(SUM_AMOUNT_LCY+ACCRUED_AMOUNT_LCY) as NU_balance                        
                  from   TD_DEPOSITS_dayly 
                  where effective_date = to_date(current_date - 1)  
                      and (customer) not in (select customer from TD_DEPOSITS_dayly  where effective_date = to_date(current_date - 2)   )
                  group by  effective_date, branch_name, segment, product_type_id, category_type)  NU
                  
            on AU.effective_date=NU.effective_date and AU.branch_name=NU.branch_name and AU.segment=NU.segment and AU.product_type_id=NU.product_type_id and AU.category_type=NU.category_type
            
            
        left join (select 
                          effective_date as last_effective_date,
                          effective_date+1 as current_day,   -- last_day(effective_date + 31) as next_effective_date,     -- Узкое место - будут ошибкию если будем искать CU относительно вчерашнего дня - то решение: (CURRENT_DATE - 1)
                          branch_name,
                          segment,
                          product_type_id,
                          category_type,
                        count(distinct customer) as CU,
                        sum(SUM_AMOUNT_LCY+ACCRUED_AMOUNT_LCY) as CU_balance                        
                  from   TD_DEPOSITS_dayly 
                  where effective_date = to_date(current_date - 2)        -- add_mounths(current_date, - 1)
                        and (customer) not in (select customer from TD_DEPOSITS_dayly  where effective_date = to_date(current_date - 1)  ) 
                  group by  effective_date, branch_name, segment, product_type_id, category_type) CU
                  
            on AU.effective_date=CU.current_day and AU.branch_name=CU.branch_name and AU.segment=CU.segment and AU.product_type_id=CU.product_type_id and AU.category_type=CU.category_type
            
     
      left join RU_L_MDC_RDM_DATA.BRANCH Br
               on AU.branch_name = Br.bcode
               and Br.date_from_gdwh_ru= to_date(current_date - 1)  


--               
;



