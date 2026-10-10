CREATE OR REPLACE PACKAGE VHR_MGR.lgcom_error_log_pkg IS
/******************************************************************************/
/*                  Copyright (c) 2008 LG CNS Inc.
/*                           All rights reserved.
/******************************************************************************/
/* Project      : LPL ERP Project
/* Module       : XXINVS
/* Program Name : lgcom_error_log_pkg.pls
/* Reference by :
/* Description  : Error Log및 Debug처리를 위한 Proc
/* Program History
/*------------------------------------------------------------------------------
/*   Date       In Charge          Description
/*------------------------------------------------------------------------------
/* 2008-02-20   KDK
/******************************************************************************/

-- Setting comment
PROCEDURE set_comment_text(p_comment_text in varchar2);

-- Setting Error Code : SQLCODE
PROCEDURE set_error_code(p_error_code in varchar2);

-- Setting Error Message : SQLERRM
PROCEDURE set_error_explanation_text(p_error_explanation_text in varchar2);

-- Setting Parameter
PROCEDURE set_parameter(p_parameter_name  in varchar2
                       ,p_parameter_text  in varchar2);
-- Error Logging
PROCEDURE error_prc
        (  p_module_code       in varchar2
          ,p_program_id        in varchar2);
-- Debug Logging
PROCEDURE debug_prc
        (  p_module_code       in varchar2
          ,p_program_id        in varchar2);

END lgcom_error_log_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgcom_error_log_pkg IS
/******************************************************************************/
/*                  Copyright (c) 2008 LG CNS Inc.
/*                           All rights reserved.
/******************************************************************************/
/* Project      : LPL ERP Project
/* Module       : XXINVS
/* Program Name : lgcom_error_log_pkg.pls
/* Reference by :
/* Description  : Error Log및 Debug처리를 위한 Proc

   ** 입력변수 설명.

   p_module_code             : Module code ( XXINVS )
   p_program_id              : Program ID  ( XXINVS0001 )
   p_error_code              : Error code  ( 보통넣는값 -> to_char(SQLCODE) )
   p_error_explanation_text  : Error Desc  ( 보통넣는값 -> Sqlerrm )
   p_comment_text            : Debug Step  ( '어디어디위치의 Error표시' )
                               varchar2(2000)으로 충분한설명 가능함..
   p_parameter01_name        : 진행되고있는 code01값 ( 'organizaiton_code' )
   p_parameter01_text        : parameter01_name의 실제 data값 ( 'L01' )
   p_parameter02_name        : 진행되고있는 code02값 ( 'organizaiton_code' )
   p_parameter02_text        : parameter02_name의 실제 data값 ( 'L02' )
   ...
   ...                       : 필요시 code10번까지 진행변수및 변수값지정할수있다.

  -- Test statements
BEGIN
  g_step := 'Setting Transaction';
  BEGIN
   UPDATE xxinvs_test
   SET    col1 = p_param1
     ,    col2 = p_param2
   WHERE  pk   = p_pk;
   EXCEPTION WHEN OTHERS THEN
      Alert message...
      lgcom_error_log_pkg.set_comment_text(g_step);
      lgcom_error_log_pkg.set_error_code(to_char(SQLCODE));
      lgcom_error_log_pkg.set_error_explanation_text(SQLERRM);
      lgcom_error_log_pkg.set_parameter('pk','p_pk');
      lgcom_error_log_pkg.set_parameter('col1','p_param1');
      lgcom_error_log_pkg.set_parameter('col2','p_param2');
      RAISE fnd_api.g_exc_unexpected_error;
  END;
  BEGIN
   .....
  END;
  EXCEPTION WHEN OTHERS THEN
      lgcom_error_log_pkg.error_prc
       (  p_module_code       => g_module_code
          ,p_program_id       => g_program_id
       );
END;
/* Program History
/*------------------------------------------------------------------------------
/*   Date       In Charge          Description
/*------------------------------------------------------------------------------
/* 2008-02-20   KDK
/* 2008-05-07   Song Sung Keun
/******************************************************************************/
TYPE error_rec_type IS RECORD
(
  module_code                   lgcom_error_log.module_code%type
 ,program_id                    lgcom_error_log.program_id%type
 ,error_type_code               lgcom_error_log.error_type_code%type
 ,comment_text                  lgcom_error_log.comment_text%type
 ,error_code                    lgcom_error_log.error_code%type
 ,error_explanation_text        lgcom_error_log.error_explanation_text%type
 ,parameter01_name              lgcom_error_log.parameter01_name%type
 ,parameter01_text              lgcom_error_log.parameter01_text%type
 ,parameter02_name              lgcom_error_log.parameter02_name%type
 ,parameter02_text              lgcom_error_log.parameter02_text%type
 ,parameter03_name              lgcom_error_log.parameter03_name%type
 ,parameter03_text              lgcom_error_log.parameter03_text%type
 ,parameter04_name              lgcom_error_log.parameter04_name%type
 ,parameter04_text              lgcom_error_log.parameter04_text%type
 ,parameter05_name              lgcom_error_log.parameter05_name%type
 ,parameter05_text              lgcom_error_log.parameter05_text%type
 ,parameter06_name              lgcom_error_log.parameter06_name%type
 ,parameter06_text              lgcom_error_log.parameter06_text%type
 ,parameter07_name              lgcom_error_log.parameter07_name%type
 ,parameter07_text              lgcom_error_log.parameter07_text%type
 ,parameter08_name              lgcom_error_log.parameter08_name%type
 ,parameter08_text              lgcom_error_log.parameter08_text%type
 ,parameter09_name              lgcom_error_log.parameter09_name%type
 ,parameter09_text              lgcom_error_log.parameter09_text%type
 ,parameter10_name              lgcom_error_log.parameter10_name%type
 ,parameter10_text              lgcom_error_log.parameter10_text%type
 ,last_update_date              lgcom_error_log.last_update_date%type
 ,last_updated_by               lgcom_error_log.last_updated_by%type
 ,creation_date                 lgcom_error_log.creation_date%type
 ,created_by                    lgcom_error_log.created_by%type
 ,last_update_login             lgcom_error_log.last_update_login%type
 ,attribute1                    lgcom_error_log.attribute1%type
 ,attribute2                    lgcom_error_log.attribute2%type
 ,attribute3                    lgcom_error_log.attribute3%type
 ,attribute4                    lgcom_error_log.attribute4%type
 ,attribute5                    lgcom_error_log.attribute5%type
 ,attribute6                    lgcom_error_log.attribute6%type
 ,attribute7                    lgcom_error_log.attribute7%type
 ,attribute8                    lgcom_error_log.attribute8%type
 ,attribute9                    lgcom_error_log.attribute9%type
 ,attribute10                   lgcom_error_log.attribute10%type
);

G_ERROR_LOG_REC			error_rec_type;

-- Clear
PROCEDURE clear IS
BEGIN
  G_ERROR_LOG_REC.module_code                   := NULL;
  G_ERROR_LOG_REC.program_id                    := NULL;
  G_ERROR_LOG_REC.error_type_code               := NULL;
  G_ERROR_LOG_REC.comment_text                  := NULL;
  G_ERROR_LOG_REC.error_code                    := NULL;
  G_ERROR_LOG_REC.error_explanation_text        := NULL;
  G_ERROR_LOG_REC.parameter01_name              := NULL;
  G_ERROR_LOG_REC.parameter01_text              := NULL;
  G_ERROR_LOG_REC.parameter02_name              := NULL;
  G_ERROR_LOG_REC.parameter02_text              := NULL;
  G_ERROR_LOG_REC.parameter03_name              := NULL;
  G_ERROR_LOG_REC.parameter03_text              := NULL;
  G_ERROR_LOG_REC.parameter04_name              := NULL;
  G_ERROR_LOG_REC.parameter04_text              := NULL;
  G_ERROR_LOG_REC.parameter05_name              := NULL;
  G_ERROR_LOG_REC.parameter05_text              := NULL;
  G_ERROR_LOG_REC.parameter06_name              := NULL;
  G_ERROR_LOG_REC.parameter06_text              := NULL;
  G_ERROR_LOG_REC.parameter07_name              := NULL;
  G_ERROR_LOG_REC.parameter07_text              := NULL;
  G_ERROR_LOG_REC.parameter08_name              := NULL;
  G_ERROR_LOG_REC.parameter08_text              := NULL;
  G_ERROR_LOG_REC.parameter09_name              := NULL;
  G_ERROR_LOG_REC.parameter09_text              := NULL;
  G_ERROR_LOG_REC.parameter10_name              := NULL;
  G_ERROR_LOG_REC.parameter10_text              := NULL;
  G_ERROR_LOG_REC.last_update_date              := NULL;
  G_ERROR_LOG_REC.last_updated_by               := NULL;
  G_ERROR_LOG_REC.creation_date                 := NULL;
  G_ERROR_LOG_REC.created_by                    := NULL;
  G_ERROR_LOG_REC.last_update_login             := NULL;
  G_ERROR_LOG_REC.attribute1                    := NULL;
  G_ERROR_LOG_REC.attribute2                    := NULL;
  G_ERROR_LOG_REC.attribute3                    := NULL;
  G_ERROR_LOG_REC.attribute4                    := NULL;
  G_ERROR_LOG_REC.attribute5                    := NULL;
  G_ERROR_LOG_REC.attribute6                    := NULL;
  G_ERROR_LOG_REC.attribute7                    := NULL;
  G_ERROR_LOG_REC.attribute8                    := NULL;
  G_ERROR_LOG_REC.attribute9                    := NULL;
  G_ERROR_LOG_REC.attribute10                   := NULL;

END;

-- Setting comment
PROCEDURE set_comment_text(p_comment_text in varchar2) IS
BEGIN
  clear();
  G_ERROR_LOG_REC.comment_text := p_comment_text;
END;

-- Setting Error Code : SQLCODE
PROCEDURE set_error_code(p_error_code in varchar2) IS
BEGIN
  G_ERROR_LOG_REC.error_code := p_error_code;
END;

-- Setting Error Message : SQLERRM
PROCEDURE set_error_explanation_text(p_error_explanation_text in varchar2) IS
BEGIN
  G_ERROR_LOG_REC.error_explanation_text := p_error_explanation_text;
END;

-- Setting Parameter
PROCEDURE set_parameter(p_parameter_name  in varchar2
                       ,p_parameter_text  in varchar2) IS
BEGIN
  IF G_ERROR_LOG_REC.parameter01_name IS NULL THEN
     G_ERROR_LOG_REC.parameter01_name := p_parameter_name;
     G_ERROR_LOG_REC.parameter01_text := p_parameter_text;
  ELSIF G_ERROR_LOG_REC.parameter02_name IS NULL THEN
     G_ERROR_LOG_REC.parameter02_name := p_parameter_name;
     G_ERROR_LOG_REC.parameter02_text := p_parameter_text;
  ELSIF G_ERROR_LOG_REC.parameter03_name IS NULL THEN
     G_ERROR_LOG_REC.parameter03_name := p_parameter_name;
     G_ERROR_LOG_REC.parameter03_text := p_parameter_text;
  ELSIF G_ERROR_LOG_REC.parameter04_name IS NULL THEN
     G_ERROR_LOG_REC.parameter04_name := p_parameter_name;
     G_ERROR_LOG_REC.parameter04_text := p_parameter_text;
  ELSIF G_ERROR_LOG_REC.parameter05_name IS NULL THEN
     G_ERROR_LOG_REC.parameter05_name := p_parameter_name;
     G_ERROR_LOG_REC.parameter05_text := p_parameter_text;
  ELSIF G_ERROR_LOG_REC.parameter06_name IS NULL THEN
     G_ERROR_LOG_REC.parameter06_name := p_parameter_name;
     G_ERROR_LOG_REC.parameter06_text := p_parameter_text;
  ELSIF G_ERROR_LOG_REC.parameter07_name IS NULL THEN
     G_ERROR_LOG_REC.parameter07_name := p_parameter_name;
     G_ERROR_LOG_REC.parameter07_text := p_parameter_text;
  ELSIF G_ERROR_LOG_REC.parameter08_name IS NULL THEN
     G_ERROR_LOG_REC.parameter08_name := p_parameter_name;
     G_ERROR_LOG_REC.parameter08_text := p_parameter_text;
  ELSIF G_ERROR_LOG_REC.parameter09_name IS NULL THEN
     G_ERROR_LOG_REC.parameter09_name := p_parameter_name;
     G_ERROR_LOG_REC.parameter09_text := p_parameter_text;
  ELSIF G_ERROR_LOG_REC.parameter10_name IS NULL THEN
     G_ERROR_LOG_REC.parameter10_name := p_parameter_name;
     G_ERROR_LOG_REC.parameter10_text := p_parameter_text;
  END IF;
END;
PROCEDURE error_prc
        (  p_module_code       in varchar2
          ,p_program_id        in varchar2) is

 -- 자동session분리하여 본Package의 transaction만 Commit할수있게 선언..
 pragma AUTONOMOUS_TRANSACTION;


 v_local_sysdate DATE := sysdate;
 v_user_id NUMBER := -1;

 v_error_log_seq  NUMBER;

 begin

   begin
     select lgcom_error_log_seq.nextval
     into   v_error_log_seq
     from dual;
   end;


   insert into lgcom_error_log
    (  sequence_id
      ,module_code	--varchar2(30)
      ,program_id	--varchar2(40)
      ,error_type_code	--varchar2(5)
      ,comment_text	--varchar2(2000)
      ,error_code  --varchar2(40)
      ,error_explanation_text	--varchar2(2000)
      ,parameter01_name	--varchar2(30)
      ,parameter01_text	--varchar2(1000)
      ,parameter02_name	--varchar2(30)
      ,parameter02_text	--varchar2(1000)
      ,parameter03_name	--varchar2(30)
      ,parameter03_text	--varchar2(1000)
      ,parameter04_name	--varchar2(30)
      ,parameter04_text	--varchar2(1000)
      ,parameter05_name	--varchar2(30)
      ,parameter05_text	--varchar2(1000)
      ,parameter06_name	--varchar2(30)
      ,parameter06_text	--varchar2(1000)
      ,parameter07_name	--varchar2(30)
      ,parameter07_text  --varchar2(1000)
      ,parameter08_name  --varchar2(30)
      ,parameter08_text  --varchar2(1000)
      ,parameter09_name  --varchar2(30)
      ,parameter09_text  --varchar2(1000)
      ,parameter10_name  --varchar2(30)
      ,parameter10_text  --varchar2(1000)
      ,last_update_date	--date
      ,last_updated_by	--number
      ,creation_date	--date
      ,created_by	--number
      ,last_update_login	--number
      ,attribute1	--varchar2(250)
      ,attribute2	--varchar2(250)
      ,attribute3	--varchar2(250)
      ,attribute4	--varchar2(250)
      ,attribute5	--varchar2(250)
      ,attribute6	--varchar2(250)
      ,attribute7	--varchar2(250)
      ,attribute8	--varchar2(250)
      ,attribute9	--varchar2(250)
      ,attribute10	--varchar2(250)
     )
   values
      (  v_error_log_seq
        ,p_module_code
        ,p_program_id
        ,'ERROR'                                          -- Constant
        ,G_ERROR_LOG_REC.comment_text
        ,G_ERROR_LOG_REC.error_code
        ,G_ERROR_LOG_REC.error_explanation_text
        ,G_ERROR_LOG_REC.parameter01_name
        ,G_ERROR_LOG_REC.parameter01_text
        ,G_ERROR_LOG_REC.parameter02_name
        ,G_ERROR_LOG_REC.parameter02_text
        ,G_ERROR_LOG_REC.parameter03_name
        ,G_ERROR_LOG_REC.parameter03_text
        ,G_ERROR_LOG_REC.parameter04_name
        ,G_ERROR_LOG_REC.parameter04_text
        ,G_ERROR_LOG_REC.parameter05_name
        ,G_ERROR_LOG_REC.parameter05_text
        ,G_ERROR_LOG_REC.parameter06_name
        ,G_ERROR_LOG_REC.parameter06_text
        ,G_ERROR_LOG_REC.parameter07_name
        ,G_ERROR_LOG_REC.parameter07_text
        ,G_ERROR_LOG_REC.parameter08_name
        ,G_ERROR_LOG_REC.parameter08_text
        ,G_ERROR_LOG_REC.parameter09_name
        ,G_ERROR_LOG_REC.parameter09_text
        ,G_ERROR_LOG_REC.parameter10_name
        ,G_ERROR_LOG_REC.parameter10_text
        ,v_local_sysdate
        ,v_user_id
        ,v_local_sysdate
        ,v_user_id
        ,v_user_id
        ,G_ERROR_LOG_REC.attribute1
        ,G_ERROR_LOG_REC.attribute2
        ,G_ERROR_LOG_REC.attribute3
        ,G_ERROR_LOG_REC.attribute4
        ,G_ERROR_LOG_REC.attribute5
        ,G_ERROR_LOG_REC.attribute6
        ,G_ERROR_LOG_REC.attribute7
        ,G_ERROR_LOG_REC.attribute8
        ,G_ERROR_LOG_REC.attribute9
        ,G_ERROR_LOG_REC.attribute10);

   commit;

 exception
   when others then
     dbms_output.put_line('lgcom_error_log_pkg.error_prc error '||sqlerrm);
 end;


PROCEDURE debug_prc
        (  p_module_code       in varchar2
          ,p_program_id        in varchar2 ) is

 -- 자동session분리하여 본Package의 transaction만 Commit할수있게 선언..
 pragma AUTONOMOUS_TRANSACTION;

 v_local_sysdate  DATE := sysdate;
 v_user_id        NUMBER := -1;
 v_enabled_cnt    NUMBER := null;
 v_error_log_seq  NUMBER ;

 exit_exception  EXCEPTION;

 begin

    --sequence 따기..
   begin
     select lgcom_error_log_seq.nextval
     into   v_error_log_seq
     from dual;
   end;

   insert into lgcom_error_log
    (  sequence_id
      ,module_code	--varchar2(30)
      ,program_id	--varchar2(40)
      ,error_type_code	--varchar2(5)
      ,comment_text	--varchar2(2000)
      ,error_code  --varchar2(40)
      ,error_explanation_text	--varchar2(2000)
      ,parameter01_name	--varchar2(30)
      ,parameter01_text	--varchar2(1000)
      ,parameter02_name	--varchar2(30)
      ,parameter02_text	--varchar2(1000)
      ,parameter03_name	--varchar2(30)
      ,parameter03_text	--varchar2(1000)
      ,parameter04_name	--varchar2(30)
      ,parameter04_text	--varchar2(1000)
      ,parameter05_name	--varchar2(30)
      ,parameter05_text	--varchar2(1000)
      ,parameter06_name	--varchar2(30)
      ,parameter06_text	--varchar2(1000)
      ,parameter07_name	--varchar2(30)
      ,parameter07_text  --varchar2(1000)
      ,parameter08_name  --varchar2(30)
      ,parameter08_text  --varchar2(1000)
      ,parameter09_name  --varchar2(30)
      ,parameter09_text  --varchar2(1000)
      ,parameter10_name  --varchar2(30)
      ,parameter10_text  --varchar2(1000)
      ,last_update_date	--date
      ,last_updated_by	--number
      ,creation_date	--date
      ,created_by	--number
      ,last_update_login	--number
      ,attribute1	--varchar2(250)
      ,attribute2	--varchar2(250)
      ,attribute3	--varchar2(250)
      ,attribute4	--varchar2(250)
      ,attribute5	--varchar2(250)
      ,attribute6	--varchar2(250)
      ,attribute7	--varchar2(250)
      ,attribute8	--varchar2(250)
      ,attribute9	--varchar2(250)
      ,attribute10	--varchar2(250)
     )
   values
      (  v_error_log_seq
        ,p_module_code
        ,p_program_id
        ,'DEBUG'                                          -- Constant
        ,G_ERROR_LOG_REC.comment_text
        ,G_ERROR_LOG_REC.error_code
        ,G_ERROR_LOG_REC.error_explanation_text
        ,G_ERROR_LOG_REC.parameter01_name
        ,G_ERROR_LOG_REC.parameter01_text
        ,G_ERROR_LOG_REC.parameter02_name
        ,G_ERROR_LOG_REC.parameter02_text
        ,G_ERROR_LOG_REC.parameter03_name
        ,G_ERROR_LOG_REC.parameter03_text
        ,G_ERROR_LOG_REC.parameter04_name
        ,G_ERROR_LOG_REC.parameter04_text
        ,G_ERROR_LOG_REC.parameter05_name
        ,G_ERROR_LOG_REC.parameter05_text
        ,G_ERROR_LOG_REC.parameter06_name
        ,G_ERROR_LOG_REC.parameter06_text
        ,G_ERROR_LOG_REC.parameter07_name
        ,G_ERROR_LOG_REC.parameter07_text
        ,G_ERROR_LOG_REC.parameter08_name
        ,G_ERROR_LOG_REC.parameter08_text
        ,G_ERROR_LOG_REC.parameter09_name
        ,G_ERROR_LOG_REC.parameter09_text
        ,G_ERROR_LOG_REC.parameter10_name
        ,G_ERROR_LOG_REC.parameter10_text
        ,v_local_sysdate
        ,v_user_id
        ,v_local_sysdate
        ,v_user_id
        ,v_user_id
        ,G_ERROR_LOG_REC.attribute1
        ,G_ERROR_LOG_REC.attribute2
        ,G_ERROR_LOG_REC.attribute3
        ,G_ERROR_LOG_REC.attribute4
        ,G_ERROR_LOG_REC.attribute5
        ,G_ERROR_LOG_REC.attribute6
        ,G_ERROR_LOG_REC.attribute7
        ,G_ERROR_LOG_REC.attribute8
        ,G_ERROR_LOG_REC.attribute9
        ,G_ERROR_LOG_REC.attribute10);

   commit;

 exception
   when exit_exception then
     null;
   when others then
     dbms_output.put_line('lgcom_error_log_pkg.error_prc error '||sqlerrm);
 end;

END lgcom_error_log_pkg;
/
