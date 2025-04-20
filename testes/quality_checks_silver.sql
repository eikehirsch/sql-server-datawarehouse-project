/*
===============================================================================
Testes de qualidade
===============================================================================
Objetivo do Script:
    Esse script executa vários testes de qualidade de consistência e padronização  
    dos dados na camada 'silver'. Isso inclui checagens para:
    - Chaves-primárias nulas ou duplicadas.
    - Espaços desnecessários em campos de strings.
    - Consistência e padronização dos dados.
    - Pedidos e abrangêngia de datas inválidos.
    - Inconsistência de dados entre campos relacionados.

Notas para uso:
    - Rodar essas checagens depois do carregamento da Camada Silver.
    - Investigar e resolver quaisquer discrepâncias encontradas durantes as checagens.
===============================================================================
*/

-- ====================================================================
-- Checando 'silver.crm_cust_info'
-- ====================================================================
-- Checagem de Chaves-primárias NULAS ou Duplicadas
-- Esperado: 0 resultados
SELECT 
    cst_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Checagem para espaços desnecessários
-- Esperado: 0 resultados
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Consistência de padronização dos dados
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;

-- ====================================================================
-- Checando 'silver.crm_prd_info'
-- ====================================================================
-- Checagem para Chaves-primárias NULAS ou Duplicadas
-- Esperado: 0 resultados
SELECT 
    prd_id,
    COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Checagem para espaços desnecessários
-- Esperado: 0 resultados
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Checagem para valores NULOS ou Negativos na coluna Cost
-- Esperado: 0 resultados
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Consistência e padronização dos dados
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Checagem de datas históricas dos produtos (Start Date > End Date)
-- Expectation: No Results
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ====================================================================
-- Checando 'silver.crm_sales_details'
-- ====================================================================
-- Checando para datas inválidas
-- Esperado: 0 resultados
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_due_dt) != 8 
    OR sls_due_dt > 20500101 
    OR sls_due_dt < 19000101;

-- Checagem para datas de pedidos inválidas (Order Date > Shipping/Due Dates)
-- Esperado: 0 resultados
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Checagem de consistência de dados: Sales precisa ser = Quantity * Price
-- Esperado: 0 resultados
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ====================================================================
-- Checando 'silver.erp_cust_az12'
-- ====================================================================
-- Identificar datas com abrangência inesperada
-- Esperado: Birthdates entre 1924-01-01 e Hoje
SELECT DISTINCT 
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();

-- Consistência e padronização de dados
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;

-- ====================================================================
-- Checando 'silver.erp_loc_a101'
-- ====================================================================
-- Consistência e padronização de dados
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Checando 'silver.erp_px_cat_g1v2'
-- ====================================================================
-- Checando para espaços desnecessários
-- Esperado: 0 resultados
SELECT 
    * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Consistência e padronização de dados
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;
