------------------------------------------------////////////////////////////////////////////----------------------------------------------------
/* SCRIPT PURPOSE:
                - To create   Procedure silver.load_silver in the Silver Schema that performs ETL
                - The script Transforms and Load data in Silver Layer  
                - The Transformation includes cleansing data by trimming extra spaces , ,standardizing/Normalizing data, 
                  Data enncrichment , Handling Missing Values , Derived Columns  

   	Parameters:
			  - This Script Does not accept any parameters
   	Example Usage:
				  Exec silver.load_silver
*/
------------------------------------------------////////////////////////////////////////////----------------------------------------------------


create or alter procedure silver.load_silver as
	begin
		declare @start_time datetime , @end_time datetime , @batch_start_time datetime , @batch_end_time datetime ;

			begin try 
			set @batch_start_time = GETDATE()
			Print '=========================================================='
			print ' Loading Silver Layer'
			Print '=========================================================='
	
			Print '---------------------------------------------------------';
			Print '1) Loading Crm Tables'
			print '----------------------------------------------------------';
			Set @start_time = GETDATE()
------------------------------------------------------------------------------------------------------------------------------------------
-- INSERTING INTO silver.crm_cust_info
------------------------------------------------------------------------------------------------------------------------------------------
			if object_id('silver.crm_cust_info' ) is not null
				Print '>> Truncating table silver.crm_cust_info'
				truncate Table silver.crm_cust_info
			PRINT ' INSERTING INTO silver.crm_cust_info'
			insert into silver.crm_cust_info 
			(cst_id, 
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)

			Select cst_id,
			cst_key,
			Trim(cst_firstname) as cst_firstname,
			Trim(cst_lastname) as cst_lastname,
			case when Upper(Trim(cst_marital_status)) = 'M' then 'Married' 
				when Upper(Trim(cst_marital_status)) = 'S' then 'Single' 
				else 'n/a' end as cst_marital_status,
			case when Upper(Trim(cst_gndr)) = 'M' then 'Male' 
				when Upper(Trim(cst_gndr)) = 'F' then 'Female' 
				else 'n/a' end as cst_gndr,
			cst_create_date
			from 
			(Select * ,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rn
			from bronze.crm_cust_info where cst_id is not Null) as src
			where rn=1 ;
			
			Set @end_time = GETDATE()
			print 'Loading and Transforming Duration ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';

			Print '---------------------------------------------------------'
			Print '---------------------------------------------------------'
------------------------------------------------------------------------------------------------------------------------------------------
-- INSERTING INTO silver.crm_prd_info
------------------------------------------------------------------------------------------------------------------------------------------
			Set @start_time = GETDATE()

			if object_id('silver.crm_prd_info') is not null
				Print 'Truncating table silver.crm_prd_info'
				truncate table silver.crm_prd_info; 
			PRINT 'INSERTING INTO silver.crm_prd_info'
			insert into silver.crm_prd_info (prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt) 

			Select prd_id 
			, substring(prd_key,1,5) as cat_id
			, SUBSTRING( prd_key,7,len(prd_key)) as prd_key   
			, prd_nm 
			, coalesce(prd_cost,0) as prd_cost
			, case upper(Trim(prd_line))  when 'M'   then 'Mountain'
					when 'R'  then 'Road' 
					when 'S'  then 'Other Sales'
					when 'T'  then 'Touring'
					else 'n/a' 
			  end as prd_line
			, prd_start_dt
			,  lead(DATEADD(DAY,   -1,  prd_start_dt)  ) over(partition by prd_key order by prd_start_dt )  as prd_end_dt	
			from bronze.crm_prd_info order by prd_id asc ;


			Set @end_time = GETDATE()
			print 'Loading and Transforming Duration ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';
			Print '---------------------------------------------------------'
			Print '---------------------------------------------------------'
------------------------------------------------------------------------------------------------------------------------------------------
-- INSERTING INTO silver.crm_sales_details
------------------------------------------------------------------------------------------------------------------------------------------
			Set @start_time = GETDATE()
			if object_id('silver.crm_sales_details') is not null
			Print 'Truncating table silver.crm_sales_details'
				truncate table silver.crm_sales_details;
			PRINT 'INSERTING INTO silver.crm_sales_details'	
			insert  into silver.crm_sales_details 
				(sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				sls_order_dt,
				sls_ship_dt,
				sls_due_dt,
				sls_price,
				sls_quantity,
				sls_sales)

			Select sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			case 
			 when sls_order_dt <= 0 or len(sls_order_dt) != 8 then null
			 else cast(cast(sls_order_dt as varchar) as date) end as sls_order_dt,
			case 
			 when sls_ship_dt <= 0 or len(sls_ship_dt) != 8 then null
			 else cast(cast(sls_ship_dt as varchar) as date) end as sls_ship_dt,
			case 
			 when sls_due_dt <= 0 or len(sls_due_dt) != 8 then null
			 else cast(cast(sls_due_dt as varchar) as date) end as sls_due_dt,
			case 
			 when sls_price <= 0  or  sls_price is null then ABS(sls_sales) / nullif(sls_quantity,0)
			 else sls_price
			 end as sls_price,
			 sls_quantity,
			case
			 when sls_sales <=0 or sls_sales is null or sls_sales != Abs(sls_price) * sls_quantity
			 then Abs(sls_price) * sls_quantity 
			 else sls_sales end as sls_sales
			from bronze.crm_sales_details ;


			Set @end_time = GETDATE()
			print 'Loading and Transforming Duration ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';
			Print '---------------------------------------------------------'
			Print '---------------------------------------------------------'
			
			Print '---------------------------------------------------------';
			Print '2) Loading erp Tables'
			print '----------------------------------------------------------';	
------------------------------------------------------------------------------------------------------------------------------------------
-- INSERTING INTO silver.erp_CUST_AZ12
------------------------------------------------------------------------------------------------------------------------------------------
			Set @start_time = GETDATE()
			if object_id('silver.erp_CUST_AZ12') is not null
				Print 'Truncating table silver.erp_CUST_AZ12'
				truncate table silver.erp_CUST_AZ12
			PRINT 'INSERTING INTO silver.erp_CUST_AZ12'	
			insert into silver.erp_CUST_AZ12 
			(CID, 
			BDATE, 
			GEN)
			Select   
			case 
				when cid like 'NAS%' then SUBSTRING(Cid,4,len(cid)) 
				else cid 
			end as CID,
			case 
				when Year(BDATE) > GETDATE() then Null 
				else BDATE 
			end as BDATE, 
			case 
				when GEN=Upper(Trim('M')) or GEN=Upper(Trim('MALE')) then 'Male'
				when GEN=Upper(Trim('F')) or GEN=Upper(Trim('FEMALE')) then 'Female'
				else 'n/a' end as Gen
			from bronze.erp_CUST_AZ12;


			Set @end_time = GETDATE()
			print 'Loading and Transforming Duration ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';
			Print '---------------------------------------------------------'
			Print '---------------------------------------------------------'
			
------------------------------------------------------------------------------------------------------------------------------------------
-- INSERTING INTO silver.erp_LOC_A101
------------------------------------------------------------------------------------------------------------------------------------------
			Set @start_time = GETDATE();
			if object_id('silver.erp_LOC_A101') is not null
				Print 'Truncating table silver.erp_LOC_A101'
				truncate table silver.erp_LOC_A101
			PRINT 'INSERTING INTO silver.erp_LOC_A101'
			insert into silver.erp_LOC_A101 (CID, CNTRY)

			Select replace(Cid,'-','') as CID ,
			Case when Upper(Trim(CNTRY)) in ('USA' ,'US') then  'United States'
			when Upper(Trim(CNTRY)) ='DE' then 'Germany'
			when Trim(CNTRY) = '' or  CNTRY is null then 'n/a'
			else Trim(CNTRY) end as CNTRY
			from bronze.erp_LOC_A101 ;

			Set @end_time = GETDATE()
			print 'Loading and Transforming Duration ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds'
			Print '---------------------------------------------------------'
			Print '---------------------------------------------------------'
------------------------------------------------------------------------------------------------------------------------------------------
-- INSERTING INTO silver.erp_PX_CAT_G1V2
------------------------------------------------------------------------------------------------------------------------------------------
			Set @start_time = GETDATE()
			if object_id('silver.erp_PX_CAT_G1V2') is not null
				Print 'Truncating table silver.erp_PX_CAT_G1V2'
				truncate table silver.erp_PX_CAT_G1V2
				PRINT 'INSERTING INTO silver.erp_PX_CAT_G1V2'
			insert into silver.erp_PX_CAT_G1V2 (ID, CAT, SUBCAT, MAINTENANCE)
			Select  id ,
			CAT,
			SUBCAT,
			MAINTENANCE
			from bronze.erp_PX_CAT_G1V2
			;
			Set @end_time = GETDATE()
			print 'Loading and Transforming Duration ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';
			Print '---------------------------------------------------------'
			Print '---------------------------------------------------------'

		set @batch_end_time = GETDATE()
		print 'Loading and Transforming is Completed'
		print 'Total batch Duration ' + cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar) + ' seconds';
		end try
		
		begin catch
		print 'Error Occured in procedure silver.load_from_bronze_to_silver'
		print 'Error Message ' + ERROR_MESSAGE()
		print 'Error Line' + cast(Error_Line() as nvarchar)
		print 'Error Number' + cast(Error_Number() as nvarchar)
		end catch ;
	end;

	




	
