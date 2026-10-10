CREATE OR REPLACE PACKAGE VHR_MGR.lgcom_ws_pkg
/******************************************************************************/
/* Project      : LG Display ERP Project                                      */
/* Module       : XXLGE                                                       */
/* Program Name : lgcom_ws_pkg.pls                                            */
/* Description  : Web Service Pkg                                             */
/*                                                                            */
/* Program History                                                            */
/*----------------------------------------------------------------------------*/
/*   Date     In Charge         Version   Description                         */
/*----------------------------------------------------------------------------*/
/* 2017-09-06 Sungkeun Song      1.0        Initial Version                   */
/******************************************************************************/
 IS
    -- error log기록을 위해서 global변수 선언.
    g_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGCOM';
    g_program_id  CONSTANT lgcom_error_log.program_id%TYPE := 'LGSYSC00099';
    g_step        lgcom_error_log.error_explanation_text%TYPE := NULL;

    TYPE arm_out_tab IS TABLE OF XXAUTT_RETRIEVE_AUTH_MTRX_PK6 INDEX BY PLS_INTEGER;

    PROCEDURE  call_arm(p_in_rec XXAUTT_RETRIEVE_AUTH_MTRX_PK5, rtn_msg     OUT VARCHAR2);
 
    PROCEDURE  test(rtn_msg     OUT VARCHAR2);

END lgcom_ws_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgcom_ws_pkg IS

PROCEDURE test(rtn_msg     OUT VARCHAR2)
  IS
   p_in_rec XXAUTT_RETRIEVE_AUTH_MTRX_PK5;
  BEGIN
    p_in_rec := XXAUTT_RETRIEVE_AUTH_MTRX_PK5
                ('2409'       -- P_PGM_SEQ
                 ,89          -- P_ORG_ID
                 ,74773       -- P_REQUESTOR_USER_ID
                 ,''          -- P_REQUESTOR_EMP_NO
                 ,''          -- P_ADDITIONAL_TYPE_CODE
                 ,''          -- P_ADDITIONAL_CODE
                 ,''          -- P_RULE1_TYPE
                 ,''          -- P_RULE1_CODE
                 ,''          -- P_RULE2_TYPE
                 ,''          -- P_RULE2_CODE
                 ,''          -- P_RANGE_CODE
                 ,'AMOUNT'    -- P_UOM_CODE
                 ,0);         -- P_RANGE_VALUE
    call_arm(p_in_rec,
             rtn_msg);
  END;

PROCEDURE call_arm
  (
    p_in_rec    IN  XXAUTT_RETRIEVE_AUTH_MTRX_PK5,
    rtn_msg     OUT VARCHAR2
  )
  IS


    req  lgcom_soap_handler.request;
    resp lgcom_soap_handler.response;

  BEGIN

    req := lgcom_soap_handler.new_request
    (
      'LGD_GPS/callGetGpsAuthority',
      'process',
      'euc-kr',
      'InputParameters',
      'http://xmlns.oracle.com/pcbpel/adapter/db/APPS/BPEL_PROCGPSAUTHORITY/XXAUTT_RETRIEVE_AUTH_MTRX_PK5/',
      'OutputParameters',
      'http://xmlns.oracle.com/pcbpel/adapter/db/APPS/BPEL_PROCGPSAUTHORITY/XXAUTT_RETRIEVE_AUTH_MTRX_PK6/'
    );



    lgcom_soap_handler.add_parameter_tag_start(req, 'P_IN_REC');
    lgcom_soap_handler.add_parameter(req, 'P_PGM_SEQ'               ,p_in_rec.P_PGM_SEQ);
    lgcom_soap_handler.add_parameter(req, 'P_ORG_ID'                ,p_in_rec.P_ORG_ID);
    lgcom_soap_handler.add_parameter(req, 'P_REQUESTOR_USER_ID'     ,p_in_rec.P_REQUESTOR_USER_ID);
    lgcom_soap_handler.add_parameter(req, 'P_REQUESTOR_EMP_NO'      ,p_in_rec.P_REQUESTOR_EMP_NO);
    lgcom_soap_handler.add_parameter(req, 'P_ADDITIONAL_TYPE_CODE'  ,p_in_rec.P_ADDITIONAL_TYPE_CODE);
    lgcom_soap_handler.add_parameter(req, 'P_ADDITIONAL_CODE'       ,p_in_rec.P_ADDITIONAL_CODE);
    lgcom_soap_handler.add_parameter(req, 'P_RULE1_TYPE'            ,p_in_rec.P_RULE1_TYPE);
    lgcom_soap_handler.add_parameter(req, 'P_RULE1_CODE'            ,p_in_rec.P_RULE1_CODE);
    lgcom_soap_handler.add_parameter(req, 'P_RULE2_TYPE'            ,p_in_rec.P_RULE2_TYPE);
    lgcom_soap_handler.add_parameter(req, 'P_RULE2_CODE'            ,p_in_rec.P_RULE2_CODE);
    lgcom_soap_handler.add_parameter(req, 'P_RANGE_CODE'            ,p_in_rec.P_RANGE_CODE);
    lgcom_soap_handler.add_parameter(req, 'P_UOM_CODE'              ,p_in_rec.P_UOM_CODE);
    lgcom_soap_handler.add_parameter(req, 'P_RANGE_VALUE'           ,p_in_rec.P_RANGE_VALUE);
    lgcom_soap_handler.add_parameter_tag_end  (req, 'P_IN_REC');
    lgcom_soap_handler.invoke(req, resp);

    rtn_msg := lgcom_soap_handler.get_string_val(resp.doc, 'P_APPROVER_NAME');

  END;
END lgcom_ws_pkg;
/
