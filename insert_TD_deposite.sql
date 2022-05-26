	
insert into  TD_Deposits_Dayly  (    
    effective_date,
    customer,
    sum_amount_lcy,
    accrued_amount_lcy,
    segment,
    Category_Type,
    product_type_id,
    branch_name,
    TODAY )
     
  select 		
     t_.effective_date,
    cust.customer_id as customer,					
    t_.sum_amount_lcy as sum_amount_lcy,
    nvl(contr_t2.accrued_amount_lcy, 0) as accrued_amount_lcy, 		
    
    case  when substr(cust.ias_profit_centre_code,1,6) in ('AFFL', 'AFPD', 'AFPO') then 'Premium'
            when substr(cust.ias_profit_centre_code,1,6) = 'CONS' then 'PI' else substr(cust.ias_profit_centre_code,1,6) end as segment,
            
    substr(cust.local_attribute_1,1,2) as Category_Type,
    product_type_id,
    cust.branch_name as branch_name,
    
    to_date(current_date - 1)  as today
  
  from dwhco.tb0_contract contr									
      inner join	
                  (	select								
                      nvl(contr_t11.effective_date, contr_t12.effective_date) as effective_date,
                      nvl(contr_t11.contract_unid, contr_t12.contract_unid) as contract_unid,			
                      nvl(contr_t11.current_principal, contr_t12.balance_amount) as sum_amount,			
                      nvl(contr_t11.current_principal_lcy, contr_t12.balance_amount_lcy) as sum_amount_lcy	
                    from 								
                            (	       select 	
                                              effective_date,							
                                              contract_unid,							
                                              current_principal,							
                                              current_principal_lcy							
                                     from dwhco.tb0_contract_balance
                                     where effective_date = to_date(current_date - 1)        -- where contr_t11.effective_date between
                            ) contr_t11
                            
                    full join								
                            (		 select 							
                                    effective_date,						
                                    contract_unid,						
                                    balance_amount,						
                                    balance_amount_lcy						
                                  from dwhco.tb0_contract_other_balance 		                                         
                                  where balance_type_id = 'IFRS'            
                                  and effective_date = to_date(current_date - 1)               -- where contr_t12.effective_date between                                               
                              ) contr_t12	
                            
                          on contr_t11.contract_unid = contr_t12.contract_unid				
                              and contr_t11.effective_date = contr_t12.effective_date
                      ) t_

                on t_.contract_unid = contr.unid								
                  and t_.effective_date between contr.bus_date_from and contr.bus_date_until	               
  
        left join dwhco.tb0_contract_accruals contr_t2								
                on contr_t2.contract_unid = t_.contract_unid	
                  and contr_t2.effective_date = t_.effective_date							               --contr_t2.effective_date between 
                  and contr_t2.accrual_type_id in ('TAA', 'IFRSTAA')	
                                  
        
        inner join dwhco.tb0_customer cust									
              on contr.ref_customer_id = cust.ref_customer_id						
                and t_.effective_date between cust.bus_date_from and cust.bus_date_until			
                and cust.ias_profit_centre_code in ('CONS','EMPL','GMAO','SPEC','PRIV','PRFO','AFFL','AFPO','AFPD')
                and cust.virtual_indicator = 'N'		
                       		
  where   
        contr.counterparty_indicator = 'M'
        and t_.sum_amount_lcy <>0	
        and t_.effective_date = to_date(current_date - 1)          

;

