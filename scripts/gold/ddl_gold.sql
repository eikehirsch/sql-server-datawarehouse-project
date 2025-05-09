/*
===============================================================================
DDL Script: Criando as Views Gold
===============================================================================
Objetivo do Script:
    Esse script cria as views da camada Gold no DataWarehouse. 
    A camada Gold representa as tabelas dimensões e fato finais (Star Schema)

    Cada view executa transformações e combina dados da camada Silver 
    para produzir um dataset limpo, padronizado e pronto para o usuário final.

Uso:
    - Essas views podem ser consumidas diretamente para análises e relatórios.
===============================================================================
*/

-- ================================================ VIEW DIM_CUSTOMERS ================================================
CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS customer_firstname,
	ci.cst_lastname AS customer_lastname,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE
			WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM é a tabela mestra
			ELSE COALESCE(ci.cst_gndr, 'n/a')
	END AS gender,
	ca.bdate AS birth_date,
	ci.cst_create_date AS create_date
FROM
	silver.crm_cust_info ci
LEFT JOIN
	silver.erp_cust_az12 ca	ON ci.cst_key = ca.cid
LEFT JOIN
	silver.erp_loc_a101 la ON ci.cst_key = la.cid;




-- ================================================ VIEW DIM_PRODUCTS ================================================
CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line  AS product_line,
	pn.prd_start_dt AS start_date
FROM
	silver.crm_prd_info pn
LEFT JOIN
	silver.erp_px_cat_g1v2 pc ON pn.cat_id = pc.id
WHERE
	prd_end_dt IS NULL; -- Retorna apenas o registro atuais de cada produto.




-- ================================================ VIEW FACTS_PRODUCTS ================================================
DROP VIEW gold.fact_sales;
CREATE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num AS order_number,
	pr.product_key,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price price
FROM
	silver.crm_sales_details sd
LEFT JOIN
	gold.dim_products pr ON sd.sls_prd_key = pr.product_number
LEFT JOIN
	gold.dim_customers cu ON sd.sls_cust_id = cu.customer_id;
