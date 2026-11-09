/******************************************************************************/
/*  Paid Leave (PL_SW / PL_PLP) payment rate - DDL & initial data              */
/*                                                                            */
/*  Screens : LGVPAY00031 Paid Leave Registration (Upload / Apply to T&A)     */
/*            LGVPAY00032 Paid Leave Payment Calculation                      */
/*            LGVPAY00033 Paid Leave Payment Rate Setup                       */
/*  Package : LGVPAY_PAID_LEAVE_PKG                                           */
/*                                                                            */
/*  Run order : 1) this script  2) lgvpay_paid_leave_pkg.pck                  */
/*                                                                            */
/*  2026-10-26  HMT  Initial Release                                          */
/******************************************************************************/

/*============================================================================*/
/* 1. Payment rate setup (LGVPAY00033 - upper grid)                           */
/*    One row = (PL code, employee category, tier) valid in an effective      */
/*    period. Tier is chosen by "a" = continuous days (PL + WH + PH) counted  */
/*    backward from each PL day : FROM_DAYS <= a <= TO_DAYS (NULL = no limit) */
/*============================================================================*/
CREATE SEQUENCE VHR_MGR.SQ_PAY_PL_RATE_ID START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE VHR_MGR.TB_PAY_PL_RATE_M
(   PL_RATE_ID                NUMBER        NOT NULL
  , SUBSIDIARY_CODE           VARCHAR2(10)  NOT NULL
  , PAID_LEAVE_DETAIL_CODE    VARCHAR2(30)  NOT NULL   /* LGVHR_ATTENDANCE_PL_DETAIL_CODE : PL_SW, PL_PLP ... */
  , EMP_CATEGORY_CODE         VARCHAR2(30)  NOT NULL   /* EMP_MASTER.ASSIGNMENT_CATEGORY : LGD_OW, LGD_LW, ALL  */
  , TIER_NO                   NUMBER(2)     NOT NULL   /* 1, 2, 3 ... (thang thu 1/2/3)                         */
  , FROM_DAYS                 NUMBER(5)     NOT NULL
  , TO_DAYS                   NUMBER(5)                /* NULL = no upper limit                                */
  , BASE_AMOUNT_TYPE          VARCHAR2(30)  DEFAULT 'BASE_SALARY' NOT NULL /* BASE_SALARY | MIN_WAGE (Global Value REGION_MINIMUM_WAGE) */
  , BASE_SALARY_RATE          NUMBER(5,2)   DEFAULT 0 NOT NULL
  , POSITION_ALLW_RATE        NUMBER(5,2)   DEFAULT 0 NOT NULL
  , JOB_ALLW_RATE             NUMBER(5,2)   DEFAULT 0 NOT NULL
  , QUALIFICATION_ALLW_RATE   NUMBER(5,2)   DEFAULT 0 NOT NULL
  , ADJ1_ALLW_RATE            NUMBER(5,2)   DEFAULT 0 NOT NULL
  , ADJ2_ALLW_RATE            NUMBER(5,2)   DEFAULT 0 NOT NULL
  , ADJ3_ALLW_RATE            NUMBER(5,2)   DEFAULT 0 NOT NULL
  , EFFECTIVE_START_DATE      DATE          NOT NULL
  , EFFECTIVE_END_DATE        DATE          NOT NULL
  , NOTE                      VARCHAR2(500)
  , CREATION_DATE             DATE          NOT NULL
  , CREATION_USER_ID          VARCHAR2(40)  NOT NULL
  , LAST_UPDATE_DATE          DATE
  , LAST_UPDATE_USER_ID       VARCHAR2(40)
  , CONSTRAINT PK_TB_PAY_PL_RATE_M PRIMARY KEY (PL_RATE_ID)
);
CREATE INDEX VHR_MGR.TB_PAY_PL_RATE_M_N1 ON VHR_MGR.TB_PAY_PL_RATE_M (SUBSIDIARY_CODE, PAID_LEAVE_DETAIL_CODE, EFFECTIVE_START_DATE);

/*============================================================================*/
/* 2. Payroll item mapping (LGVPAY00033 - lower grid)                         */
/*    (PL code, tier, component) -> payroll item                              */
/*    APPLY_VALUE_TYPE : PAY = amount paid for PL days (rate applied)          */
/*                       ADJ = PAY - FULL (negative adjustment, use when the  */
/*                             normal Base salary/allowance item already pays */
/*                             PL days at 100%)                               */
/*============================================================================*/
CREATE SEQUENCE VHR_MGR.SQ_PAY_PL_ITEM_MAP_ID START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE VHR_MGR.TB_PAY_PL_ITEM_MAP_M
(   PL_ITEM_MAP_ID            NUMBER        NOT NULL
  , SUBSIDIARY_CODE           VARCHAR2(10)  NOT NULL
  , PAID_LEAVE_DETAIL_CODE    VARCHAR2(30)  NOT NULL
  , TIER_NO                   NUMBER(2)     NOT NULL
  , COMPONENT_CODE            VARCHAR2(30)  NOT NULL   /* BASE_SALARY, POSITION_ALLW, JOB_ALLW, QUALIFICATION_ALLW, ADJ1_ALLW, ADJ2_ALLW, ADJ3_ALLW */
  , PAYROLL_ITEM_ID           NUMBER        NOT NULL
  , APPLY_VALUE_TYPE          VARCHAR2(10)  DEFAULT 'PAY' NOT NULL
  , NOTE                      VARCHAR2(500)
  , CREATION_DATE             DATE          NOT NULL
  , CREATION_USER_ID          VARCHAR2(40)  NOT NULL
  , LAST_UPDATE_DATE          DATE
  , LAST_UPDATE_USER_ID       VARCHAR2(40)
  , CONSTRAINT PK_TB_PAY_PL_ITEM_MAP_M PRIMARY KEY (PL_ITEM_MAP_ID)
  , CONSTRAINT UK_TB_PAY_PL_ITEM_MAP_M UNIQUE (SUBSIDIARY_CODE, PAID_LEAVE_DETAIL_CODE, TIER_NO, COMPONENT_CODE)
);
CREATE INDEX VHR_MGR.TB_PAY_PL_ITEM_MAP_M_N1 ON VHR_MGR.TB_PAY_PL_ITEM_MAP_M (PAYROLL_ITEM_ID);

/*============================================================================*/
/* 3. Daily calculation result (LGVPAY00032 - lower grid)                     */
/*============================================================================*/
CREATE TABLE VHR_MGR.TB_PAY_PL_CALC_DAILY_N
(   SUBSIDIARY_CODE           VARCHAR2(10)  NOT NULL
  , PAYMENT_YYYYMM            VARCHAR2(6)   NOT NULL
  , EMPLOYEE_NO               VARCHAR2(30)  NOT NULL
  , TIME_AND_ATTENDANCE_DATE  DATE          NOT NULL
  , PAID_LEAVE_DETAIL_CODE    VARCHAR2(30)  NOT NULL
  , EMP_CATEGORY_CODE         VARCHAR2(30)
  , SHIFT_TYPE_CODE           VARCHAR2(10)
  , CHAIN_START_DATE          DATE                     /* first PL day of the continuous chain   */
  , CONTINUOUS_DAYS           NUMBER(5)                /* a                                      */
  , TIER_NO                   NUMBER(2)                /* NULL = no rate found (not paid)        */
  , PL_RATE_ID                NUMBER
  , PL_HOURS                  NUMBER
  , BASE_AMOUNT_TYPE          VARCHAR2(30)
  , BASE_SALARY_RATE          NUMBER(5,2)
  , POSITION_ALLW_RATE        NUMBER(5,2)
  , JOB_ALLW_RATE             NUMBER(5,2)
  , QUALIFICATION_ALLW_RATE   NUMBER(5,2)
  , ADJ1_ALLW_RATE            NUMBER(5,2)
  , ADJ2_ALLW_RATE            NUMBER(5,2)
  , ADJ3_ALLW_RATE            NUMBER(5,2)
  , CREATION_DATE             DATE          NOT NULL
  , CREATION_USER_ID          VARCHAR2(40)  NOT NULL
  , CONSTRAINT PK_TB_PAY_PL_CALC_DAILY_N PRIMARY KEY (SUBSIDIARY_CODE, PAYMENT_YYYYMM, EMPLOYEE_NO, TIME_AND_ATTENDANCE_DATE)
);

/*============================================================================*/
/* 4. Monthly calculation result per employee / PL code / tier                */
/*    (LGVPAY00032 - upper grid, source of payroll items)                     */
/*    *_BASE : monthly amount  *_FULL : 100% value of PL hours                */
/*    *_PAY  : amount to pay (rate applied)        ADJ = PAY - FULL           */
/*============================================================================*/
CREATE TABLE VHR_MGR.TB_PAY_PL_CALC_RESULT_N
(   SUBSIDIARY_CODE           VARCHAR2(10)  NOT NULL
  , PAYMENT_YYYYMM            VARCHAR2(6)   NOT NULL
  , EMPLOYEE_NO               VARCHAR2(30)  NOT NULL
  , PAID_LEAVE_DETAIL_CODE    VARCHAR2(30)  NOT NULL
  , TIER_NO                   NUMBER(2)     NOT NULL   /* 0 = PL days without rate (not paid) */
  , EMP_CATEGORY_CODE         VARCHAR2(30)
  , PL_DAYS                   NUMBER
  , PL_HOURS                  NUMBER
  , PERFECT_WORK_DAYS         NUMBER
  , PERFECT_WORK_HOURS        NUMBER
  , MIN_WAGE                  NUMBER
  , BASE_SALARY_BASE          NUMBER
  , BASE_SALARY_FULL          NUMBER
  , BASE_SALARY_PAY           NUMBER
  , POSITION_ALLW_BASE        NUMBER
  , POSITION_ALLW_FULL        NUMBER
  , POSITION_ALLW_PAY         NUMBER
  , JOB_ALLW_BASE             NUMBER
  , JOB_ALLW_FULL             NUMBER
  , JOB_ALLW_PAY              NUMBER
  , QUALIFICATION_ALLW_BASE   NUMBER
  , QUALIFICATION_ALLW_FULL   NUMBER
  , QUALIFICATION_ALLW_PAY    NUMBER
  , ADJ1_ALLW_BASE            NUMBER
  , ADJ1_ALLW_FULL            NUMBER
  , ADJ1_ALLW_PAY             NUMBER
  , ADJ2_ALLW_BASE            NUMBER
  , ADJ2_ALLW_FULL            NUMBER
  , ADJ2_ALLW_PAY             NUMBER
  , ADJ3_ALLW_BASE            NUMBER
  , ADJ3_ALLW_FULL            NUMBER
  , ADJ3_ALLW_PAY             NUMBER
  , CREATION_DATE             DATE          NOT NULL
  , CREATION_USER_ID          VARCHAR2(40)  NOT NULL
  , CONSTRAINT PK_TB_PAY_PL_CALC_RESULT_N PRIMARY KEY (SUBSIDIARY_CODE, PAYMENT_YYYYMM, EMPLOYEE_NO, PAID_LEAVE_DETAIL_CODE, TIER_NO)
);

/*============================================================================*/
/* 5. Registration table (existing) : index for Apply to T&A                  */
/*============================================================================*/
CREATE INDEX VHR_MGR.TB_PAY_PAID_LEAVE_N_N1 ON VHR_MGR.TB_PAY_PAID_LEAVE_N (PAYMENT_YYYYMM, PAID_LEAVE_DETAIL_CODE, EMPLOYEE_NO);

/*============================================================================*/
/* 6. Initial rate data (from "Tinh luong PL_SW&PLP.xlsx")                    */
/*    PL_SW  OW : <=30 days 60% base / 31~60 days 30% base / >60 not paid     */
/*    PL_SW  LW : <=30 days minimum wage / 31~60 days 50% base / >60 not paid */
/*    PL_PLP OW, LW : 60% base                                                */
/*    All allowances : 0%                                                     */
/*    -> Adjust EFFECTIVE_START_DATE before running.                          */
/*============================================================================*/
INSERT INTO VHR_MGR.TB_PAY_PL_RATE_M (PL_RATE_ID, SUBSIDIARY_CODE, PAID_LEAVE_DETAIL_CODE, EMP_CATEGORY_CODE, TIER_NO, FROM_DAYS, TO_DAYS, BASE_AMOUNT_TYPE, BASE_SALARY_RATE, EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, NOTE, CREATION_DATE, CREATION_USER_ID)
VALUES (VHR_MGR.SQ_PAY_PL_RATE_ID.NEXTVAL, 'LGDVN', 'PL_SW' , 'LGD_OW', 1,  1,   30, 'BASE_SALARY', 60 , DATE '2026-01-01', DATE '4712-12-31', 'Month 1 : 60% base salary'     , SYSDATE, '-1');
INSERT INTO VHR_MGR.TB_PAY_PL_RATE_M (PL_RATE_ID, SUBSIDIARY_CODE, PAID_LEAVE_DETAIL_CODE, EMP_CATEGORY_CODE, TIER_NO, FROM_DAYS, TO_DAYS, BASE_AMOUNT_TYPE, BASE_SALARY_RATE, EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, NOTE, CREATION_DATE, CREATION_USER_ID)
VALUES (VHR_MGR.SQ_PAY_PL_RATE_ID.NEXTVAL, 'LGDVN', 'PL_SW' , 'LGD_OW', 2, 31,   60, 'BASE_SALARY', 30 , DATE '2026-01-01', DATE '4712-12-31', 'Month 2 : 30% base salary'     , SYSDATE, '-1');
INSERT INTO VHR_MGR.TB_PAY_PL_RATE_M (PL_RATE_ID, SUBSIDIARY_CODE, PAID_LEAVE_DETAIL_CODE, EMP_CATEGORY_CODE, TIER_NO, FROM_DAYS, TO_DAYS, BASE_AMOUNT_TYPE, BASE_SALARY_RATE, EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, NOTE, CREATION_DATE, CREATION_USER_ID)
VALUES (VHR_MGR.SQ_PAY_PL_RATE_ID.NEXTVAL, 'LGDVN', 'PL_SW' , 'LGD_OW', 3, 61, NULL, 'BASE_SALARY', 0  , DATE '2026-01-01', DATE '4712-12-31', 'Month 3 : not paid'            , SYSDATE, '-1');
INSERT INTO VHR_MGR.TB_PAY_PL_RATE_M (PL_RATE_ID, SUBSIDIARY_CODE, PAID_LEAVE_DETAIL_CODE, EMP_CATEGORY_CODE, TIER_NO, FROM_DAYS, TO_DAYS, BASE_AMOUNT_TYPE, BASE_SALARY_RATE, EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, NOTE, CREATION_DATE, CREATION_USER_ID)
VALUES (VHR_MGR.SQ_PAY_PL_RATE_ID.NEXTVAL, 'LGDVN', 'PL_SW' , 'LGD_LW', 1,  1,   30, 'MIN_WAGE'   , 100, DATE '2026-01-01', DATE '4712-12-31', 'Month 1 : regional minimum wage', SYSDATE, '-1');
INSERT INTO VHR_MGR.TB_PAY_PL_RATE_M (PL_RATE_ID, SUBSIDIARY_CODE, PAID_LEAVE_DETAIL_CODE, EMP_CATEGORY_CODE, TIER_NO, FROM_DAYS, TO_DAYS, BASE_AMOUNT_TYPE, BASE_SALARY_RATE, EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, NOTE, CREATION_DATE, CREATION_USER_ID)
VALUES (VHR_MGR.SQ_PAY_PL_RATE_ID.NEXTVAL, 'LGDVN', 'PL_SW' , 'LGD_LW', 2, 31,   60, 'BASE_SALARY', 50 , DATE '2026-01-01', DATE '4712-12-31', 'Month 2 : 50% base salary'     , SYSDATE, '-1');
INSERT INTO VHR_MGR.TB_PAY_PL_RATE_M (PL_RATE_ID, SUBSIDIARY_CODE, PAID_LEAVE_DETAIL_CODE, EMP_CATEGORY_CODE, TIER_NO, FROM_DAYS, TO_DAYS, BASE_AMOUNT_TYPE, BASE_SALARY_RATE, EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, NOTE, CREATION_DATE, CREATION_USER_ID)
VALUES (VHR_MGR.SQ_PAY_PL_RATE_ID.NEXTVAL, 'LGDVN', 'PL_SW' , 'LGD_LW', 3, 61, NULL, 'BASE_SALARY', 0  , DATE '2026-01-01', DATE '4712-12-31', 'Month 3 : not paid'            , SYSDATE, '-1');
INSERT INTO VHR_MGR.TB_PAY_PL_RATE_M (PL_RATE_ID, SUBSIDIARY_CODE, PAID_LEAVE_DETAIL_CODE, EMP_CATEGORY_CODE, TIER_NO, FROM_DAYS, TO_DAYS, BASE_AMOUNT_TYPE, BASE_SALARY_RATE, EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, NOTE, CREATION_DATE, CREATION_USER_ID)
VALUES (VHR_MGR.SQ_PAY_PL_RATE_ID.NEXTVAL, 'LGDVN', 'PL_PLP', 'ALL'   , 1,  1, NULL, 'BASE_SALARY', 60 , DATE '2026-01-01', DATE '4712-12-31', 'Prenatal leave : 60% base salary', SYSDATE, '-1');

/*============================================================================*/
/* 7. Global Value : regional minimum wage (also editable in LGVPAY10001)     */
/*============================================================================*/
INSERT INTO VHR_MGR.TB_PAY_CALC_VAR_N (PAYROLL_CALC_VARIABLE_ID, PAYROLL_CALC_VARIABLE_NAME, DETAIL_DESC, SUBSIDIARY_CODE, CREATION_DATE, CREATION_USER_ID)
SELECT (SELECT NVL(MAX(PAYROLL_CALC_VARIABLE_ID), 0) + 1 FROM VHR_MGR.TB_PAY_CALC_VAR_N), 'REGION_MINIMUM_WAGE', 'Regional minimum wage (VND/month) - PL_SW LW month 1', 'LGDVN', SYSDATE, '-1'
FROM   DUAL
WHERE  NOT EXISTS (SELECT 1 FROM VHR_MGR.TB_PAY_CALC_VAR_N WHERE SUBSIDIARY_CODE = 'LGDVN' AND PAYROLL_CALC_VARIABLE_NAME = 'REGION_MINIMUM_WAGE');

INSERT INTO VHR_MGR.TB_PAY_CALC_VAR_VALUE_N (PAYROLL_CALC_VARIABLE_ID, EFFECTIVE_START_YYYYMMDD, EFFECTIVE_END_YYYYMMDD, RESULT_VALUE, CREATION_DATE, CREATION_USER_ID)
SELECT v.PAYROLL_CALC_VARIABLE_ID, '20260101', '47121231', '4680000', SYSDATE, '-1'
FROM   VHR_MGR.TB_PAY_CALC_VAR_N v
WHERE  v.SUBSIDIARY_CODE = 'LGDVN'
AND    v.PAYROLL_CALC_VARIABLE_NAME = 'REGION_MINIMUM_WAGE'
AND    NOT EXISTS (SELECT 1 FROM VHR_MGR.TB_PAY_CALC_VAR_VALUE_N x WHERE x.PAYROLL_CALC_VARIABLE_ID = v.PAYROLL_CALC_VARIABLE_ID);

/*============================================================================*/
/* 8. Menu name (program IDs kept, only names changed)                        */
/*============================================================================*/
UPDATE VHR_MGR.LGCOM_MENU_M SET MENU_NAME = 'Paid Leave Registration'        , MENU_DESC = 'Paid Leave (PL_SW/PL_PLP) registration, upload, apply to T&A', LAST_UPDATE_DATE = SYSDATE WHERE MENU_ID = 'M_LGVPAY_1057';
UPDATE VHR_MGR.LGCOM_MENU_M SET MENU_NAME = 'Paid Leave Payment Calculation' , MENU_DESC = 'Calculate payment amount of Paid Leave days by rate'         , LAST_UPDATE_DATE = SYSDATE WHERE MENU_ID = 'M_LGVPAY_1058';
UPDATE VHR_MGR.LGCOM_MENU_M SET MENU_NAME = 'Paid Leave Payment Rate Setup'  , MENU_DESC = 'Payment rate of Paid Leave days and payroll item mapping'    , LAST_UPDATE_DATE = SYSDATE WHERE MENU_ID = 'M_LGVPAY_1059';

/*============================================================================*/
/* 9. Screen labels (copy label type from an existing label)                  */
/*============================================================================*/
INSERT INTO VHR_MGR.LGCOM_SCREEN_LABEL_M (LABEL_ID, LANGUAGE_CODE, LABEL_TYPE_CODE, LABEL_NAME, CREATED_BY, CREATION_DATE)
SELECT n.label_id, b.language_code, b.label_type_code, n.label_name, -1, SYSDATE
FROM   VHR_MGR.LGCOM_SCREEN_LABEL_M b
     , ( SELECT 'label.pay.plDetailCode'      label_id, 'Paid Leave Type'        label_name FROM DUAL UNION ALL
         SELECT 'label.pay.plEmpCategory'             , 'Emp. Category (OW/LW)'             FROM DUAL UNION ALL
         SELECT 'label.pay.plTierNo'                  , 'Tier (Month No.)'                  FROM DUAL UNION ALL
         SELECT 'label.pay.plFromDays'                , 'From Days (a)'                     FROM DUAL UNION ALL
         SELECT 'label.pay.plToDays'                  , 'To Days (a)'                       FROM DUAL UNION ALL
         SELECT 'label.pay.plBaseAmountType'          , 'Base Amount Type'                  FROM DUAL UNION ALL
         SELECT 'label.pay.plRate'                    , 'Payment Rate (%)'                  FROM DUAL UNION ALL
         SELECT 'label.pay.plComponent'               , 'Salary Component'                  FROM DUAL UNION ALL
         SELECT 'label.pay.plApplyValueType'          , 'Apply Value'                       FROM DUAL UNION ALL
         SELECT 'label.pay.plRateSetup'               , 'Payment Rate Setup'                FROM DUAL UNION ALL
         SELECT 'label.pay.plItemMapping'             , 'Payroll Item Mapping'              FROM DUAL UNION ALL
         SELECT 'label.pay.plContinuousDays'          , 'Continuous Days (a)'               FROM DUAL UNION ALL
         SELECT 'label.pay.plChainStartDate'          , 'Chain Start Date'                  FROM DUAL UNION ALL
         SELECT 'label.pay.plHours'                   , 'PL Hours'                          FROM DUAL UNION ALL
         SELECT 'label.pay.plDays'                    , 'PL Days'                           FROM DUAL UNION ALL
         SELECT 'label.pay.plMonthlyBase'             , 'Monthly'                           FROM DUAL UNION ALL
         SELECT 'label.pay.plFullAmount'              , '100% Value'                        FROM DUAL UNION ALL
         SELECT 'label.pay.plPayAmount'               , 'Pay'                               FROM DUAL UNION ALL
         SELECT 'label.pay.plAdjAmount'               , 'Adjustment'                        FROM DUAL UNION ALL
         SELECT 'label.pay.plTotalPay'                , 'Total Pay'                         FROM DUAL UNION ALL
         SELECT 'label.pay.plMinWage'                 , 'Minimum Wage'                      FROM DUAL UNION ALL
         SELECT 'label.pay.plDailyDetail'             , 'Daily Detail'                      FROM DUAL UNION ALL
         SELECT 'label.pay.plApplyAtt'                , 'Apply to T&A'                      FROM DUAL UNION ALL
         SELECT 'label.pay.adjustmentAllowance1'      , 'Adjustment 1 Allowance'            FROM DUAL UNION ALL
         SELECT 'label.pay.adjustmentAllowance2'      , 'Adjustment 2 Allowance'            FROM DUAL UNION ALL
         SELECT 'label.pay.adjustmentAllowance3'      , 'Adjustment 3 Allowance'            FROM DUAL
       ) n
WHERE  b.label_id = 'label.pay.baseSalary'
AND    NOT EXISTS (SELECT 1 FROM VHR_MGR.LGCOM_SCREEN_LABEL_M x WHERE x.label_id = n.label_id AND x.language_code = b.language_code);

COMMIT;
