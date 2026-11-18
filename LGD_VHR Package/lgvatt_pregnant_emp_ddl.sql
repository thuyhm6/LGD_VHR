/*============================================================================*/
/* LGVATT00031 - Pregnant EMP Management                                       */
/*  - Quan ly nhan vien mang thai: thoi gian (bat dau ~ ket thuc), trang thai  */
/*    tang ca (OT_ALLOW_FLAG: Y/N, mac dinh N), ghi chu.                       */
/*  - OT_ALLOW_FLAG = 'N' -> trong khoang thoi gian do khong duoc nhap gio OT  */
/*    o LGVATT20011, LGVATT20020, LGVATT20040, LGVATT20060.                    */
/*    Khoang chan: PREGNANT = WEEK25_DATE ~ ket thuc,                         */
/*                 CHILD_CARE = ngay bat dau ~ ket thuc.                      */
/*  Chay bang schema                                                   */
/*============================================================================*/

/*============================================================================*/
/* 1. Table                                                                   */
/*============================================================================*/
CREATE TABLE TB_ATT_PREGNANT_EMP_M
(
    SUBSIDIARY_CODE        VARCHAR2(10)            NOT NULL,
    EMPLOYEE_NO            VARCHAR2(30)            NOT NULL,
    EFFECTIVE_START_DATE   DATE                    NOT NULL,
    EFFECTIVE_END_DATE     DATE,                                     -- Khong bat buoc. Trong = khong gioi han (chan OT vo thoi han)
    OT_ALLOW_FLAG          VARCHAR2(1) DEFAULT 'N' NOT NULL,
    EMP_CATEGORY_CODE      VARCHAR2(20) DEFAULT 'PREGNANT' NOT NULL, -- Phan loai: PREGNANT (Bau) / CHILD_CARE (Nuoi con nho).
    WEEK25_DATE            DATE,                                     -- Ngay bat dau tuan thai thu 25 (bat buoc khi PREGNANT). PREGNANT: chan OT tu WEEK25_DATE ~ EFFECTIVE_END_DATE
    REMARK                 VARCHAR2(1000),
    CREATION_USER_ID       VARCHAR2(40)            NOT NULL,
    CREATION_DATE          DATE                    NOT NULL,
    LAST_UPDATE_USER_ID    VARCHAR2(40),
    LAST_UPDATE_DATE       DATE,
    CONSTRAINT TB_ATT_PREGNANT_EMP_M_PK PRIMARY KEY (SUBSIDIARY_CODE, EMPLOYEE_NO, EFFECTIVE_START_DATE),
    CONSTRAINT TB_ATT_PREGNANT_EMP_M_C1 CHECK (OT_ALLOW_FLAG IN ('Y', 'N')),
    CONSTRAINT TB_ATT_PREGNANT_EMP_M_C2 CHECK (EFFECTIVE_END_DATE >= EFFECTIVE_START_DATE),
    CONSTRAINT TB_ATT_PREGNANT_EMP_M_C3 CHECK (EMP_CATEGORY_CODE IN ('PREGNANT', 'CHILD_CARE'))
);

/* Neu bang da duoc tao truoc do (chua co cot EMP_CATEGORY_CODE), chay doan sau thay cho CREATE TABLE:
ALTER TABLE TB_ATT_PREGNANT_EMP_M ADD (EMP_CATEGORY_CODE VARCHAR2(20) DEFAULT 'PREGNANT' NOT NULL);
ALTER TABLE TB_ATT_PREGNANT_EMP_M ADD CONSTRAINT TB_ATT_PREGNANT_EMP_M_C3 CHECK (EMP_CATEGORY_CODE IN ('PREGNANT', 'CHILD_CARE'));
*/

/* Neu bang da duoc tao truoc do (chua co cot WEEK25_DATE), chay lenh sau:
ALTER TABLE TB_ATT_PREGNANT_EMP_M ADD (WEEK25_DATE DATE);
*/

/* Neu bang da duoc tao truoc do (EFFECTIVE_END_DATE dang NOT NULL), chay lenh sau:
ALTER TABLE TB_ATT_PREGNANT_EMP_M MODIFY (EFFECTIVE_END_DATE NULL);
*/

/*============================================================================*/
/* 2. Program / Menu (ngang hang LGVATT00030 - Employee Shift Group Info,      */
/*    menu cha M_LGVATT_1003 T&A Management)                                  */
/*============================================================================*/
INSERT INTO LGCOM_PROGRAM_M
      (PROGRAM_ID, PROGRAM_NAME, SYSTEM_CODE, MODULE_CODE, PROGRAM_TYPE_CODE, BUSINESS_EFFECT_CODE, DIFFICULTY_CODE,
       USE_FLAG, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, EXCEL_DOWNLOAD_AUTHORITY_FLAG)
SELECT 'LGVATT00031', 'Pregnant EMP Management', p.SYSTEM_CODE, p.MODULE_CODE, p.PROGRAM_TYPE_CODE, p.BUSINESS_EFFECT_CODE, p.DIFFICULTY_CODE,
       'Y', -1, SYSDATE, -1, SYSDATE, p.EXCEL_DOWNLOAD_AUTHORITY_FLAG
FROM   LGCOM_PROGRAM_M p
WHERE  p.PROGRAM_ID = 'LGVATT00030';

INSERT INTO LGCOM_MENU_M
      (MENU_ID, SYSTEM_CODE, MODULE_CODE, HIGH_MENU_ID, MENU_NAME, MENU_DESC, PROGRAM_ID, URL_ADDR,
       MENU_LEVEL_NO, SORT_ORDER_NO, DISPLAY_FLAG, POP_UP_SCREEN_FLAG, POP_UP_EXECUTION_MENU_FLAG, USE_FLAG,
       CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, MENU_SEQ_NO)
SELECT 'M_LGVATT_1090', m.SYSTEM_CODE, m.MODULE_CODE, m.HIGH_MENU_ID, 'Pregnant EMP Management', 'Pregnant EMP Management', 'LGVATT00031', NULL,
       m.MENU_LEVEL_NO, m.SORT_ORDER_NO + 1, 'Y', 'N', NULL, 'Y',
       -1, SYSDATE, -1, SYSDATE, (SELECT MAX(MENU_SEQ_NO) + 1 FROM LGCOM_MENU_M)
FROM   LGCOM_MENU_M m
WHERE  m.MENU_ID = 'M_LGVATT_1070';

-- Ten menu da ngon ngu: copy cac ngon ngu dang co cua menu LGVATT00030
INSERT INTO LGCOM_MENU_MULTI_LANG_N (MENU_ID, LANGUAGE_CODE, MENU_NAME, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
SELECT 'M_LGVATT_1090', l.LANGUAGE_CODE, 'Pregnant EMP Management', -1, SYSDATE, -1, SYSDATE
FROM   LGCOM_MENU_MULTI_LANG_N l
WHERE  l.MENU_ID = 'M_LGVATT_1070';

-- Quyen menu: cap cho cac role dang co quyen menu LGVATT00030 (dieu chinh lai trong LGSYSC neu can)
INSERT INTO LGCOM_ROLE_MENU_N (ROLE_CODE, MENU_ID, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
SELECT r.ROLE_CODE, 'M_LGVATT_1090', -1, SYSDATE, -1, SYSDATE
FROM   LGCOM_ROLE_MENU_N r
WHERE  r.MENU_ID = 'M_LGVATT_1070';

COMMIT;

/* Sau khi chay: xoa cache menu (Ehcache) hoac restart WAS de menu moi hien thi. */
