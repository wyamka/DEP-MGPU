
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select number_of_orders
from "superstore"."dw_test"."mart_order_processing_time"
where number_of_orders is null



  
  
      
    ) dbt_internal_test