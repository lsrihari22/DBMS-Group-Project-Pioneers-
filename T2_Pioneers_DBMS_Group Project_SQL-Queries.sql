-- Q1
select
  distinct t2_customer.*,
  t2_vehicle.*
from
  t2_customer
  inner join t2_vehicle t2_vehicle on t2_customer.t2_cust_id = t2_vehicle.t2_cust_id
  inner join t2_claim on t2_claim.t2_cust_id = t2_customer.t2_cust_id
WHERE
  t2_claim.T2_Incident_Id IS NOT NULL
  AND t2_claim_status like 'pending';

-- Q2
select
  t2_customer.*,
  t2_premium_payment.*
from
  t2_customer
  RIGHT JOIN t2_premium_payment on t2_customer.t2_cust_id = t2_premium_payment.t2_cust_id
WHERE
  t2_premium_payment.T2_Premium_Payment_Amount > (
    SELECT
      SUM(CAST(T2_Cust_Id AS UNSIGNED))
    FROM
      T2_CUSTOMER
  );

-- Q3
SELECT
  DISTINCT (t2_COMPANY_NAME)
FROM
  t2_insurance_company
WHERE
  t2_COMPANY_NAME IN (
    SELECT
      t2_insurance_company.t2_COMPANY_NAME
    FROM
      t2_insurance_company
    WHERE
      t2_insurance_company.t2_Company_Name IN (
        SELECT
          t2_Company_Name
        FROM
          t2_office
        GROUP BY
          t2_Company_Name
        HAVING
          t2_Company_Name IN (
            SELECT
              t2_office.t2_Company_Name
            FROM
              t2_product
              INNER JOIN t2_office ON t2_office.t2_company_name = t2_product.t2_Company_Name
            GROUP BY
              t2_office.t2_Company_Name
            HAVING
              COUNT(DISTINCT (t2_product_number)) > COUNT(DISTINCT (t2_department_name))
          )
      )
  )
  AND t2_COMPANY_NAME IN (
    SELECT
      t2_customer.t2_COMPANY_NAME
    FROM
      t2_insurance_company t2_customer
      INNER JOIN t2_product ON t2_product.t2_COMPANY_NAME = t2_customer.t2_COMPANY_NAME
    GROUP BY
      t2_product.t2_COMPANY_NAME
    HAVING
      COUNT(*) > ALL (
        SELECT
          COUNT(*)
        FROM
          t2_insurance_company
        GROUP BY
          t2_COMPANY_NAME
        HAVING
          COUNT(t2_COMPANY_LOCATION) > 1
      )
  );

-- Q4
select
  *
from
  T2_CUSTOMER
where
  T2_CUSTOMER.T2_Cust_id in (
    select
      T2_Cust_Id
    from
      T2_VEHICLE
    where
      t2_VEHICLE.T2_Policy_Id not in (
        select
          T2_Policy_Number
        from
          t2_PREMIUM_PAYMENT
      )
      and t2_VEHICLE.t2_Cust_Id in (
        select
          t2_Cust_Id
        from
          t2_VEHICLE
        GROUP BY
          t2_VEHICLE.t2_Cust_Id
        having
          count(t2_VEHICLE.t2_Cust_Id) > 1
      )
      and t2_VEHICLE.t2_Cust_Id in (
        select
          t2_Cust_Id
        from
          t2_INCIDENT_REPORT
        where
          t2_Incident_Type = 'accident'
      )
  );

-- Q5
SELECT
  t2_vehicle.*
FROM
  t2_vehicle
  INNER JOIN t2_customer ON t2_customer.T2_Cust_Id = t2_vehicle.T2_Cust_Id
  INNER JOIN t2_premium_payment ON t2_premium_payment.T2_Cust_Id = t2_customer.T2_Cust_Id
WHERE
  CAST(t2_vehicle.T2_Vehicle_Id AS UNSIGNED) < t2_premium_payment.T2_Premium_Payment_Amount;

-- Q6
SELECT
  T2_CUSTOMER.*
FROM
  T2_CUSTOMER
  INNER JOIN T2_VEHICLE ON T2_VEHICLE.T2_Cust_Id = T2_CUSTOMER.T2_Cust_Id
  INNER JOIN T2_CLAIM ON T2_CLAIM.T2_Cust_Id = T2_CUSTOMER.T2_Cust_Id
  INNER JOIN t2_insurance_policy_coverage on t2_insurance_policy_coverage.T2_Agreement_Id = t2_claim.T2_Agreement_Id
  INNER JOIN T2_COVERAGE ON T2_COVERAGE.T2_Coverage_Id = T2_INSURANCE_POLICY_COVERAGE.T2_Coverage_Id
  INNER JOIN T2_CLAIM_SETTLEMENT ON T2_CLAIM_SETTLEMENT.T2_Claim_Id = T2_CLAIM.T2_Claim_Id
WHERE
  T2_CLAIM.T2_Claim_Amount < T2_COVERAGE.T2_Coverage_Amount
  AND T2_COVERAGE.T2_Coverage_Amount > (
    CAST(
      T2_CLAIM_SETTLEMENT.T2_Claim_Settlement_Id AS UNSIGNED
    ) + CAST(T2_VEHICLE.T2_Vehicle_Id AS UNSIGNED) + CAST(T2_CLAIM.T2_Claim_Id AS UNSIGNED) + CAST(T2_CUSTOMER.T2_Cust_Id AS UNSIGNED)
  );