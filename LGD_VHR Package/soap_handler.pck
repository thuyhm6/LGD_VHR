CREATE OR REPLACE PACKAGE VHR_MGR.soap_handler
AS
/******************************************************************************
   PACKAGE NAME : soap_handler_test (SPEC)
   PURPOSE : SOAP Message 를 생성하여 Web Service 를 호출하고, Web Service 로
             부터 받은 SOAP Message 를 분석한다.

   REVISIONS:
   Ver     Date        Author   Description
   ------  ----------  -------  -----------------------------------------------
   1.0     2006-12-18  한정훈   -최초 작성
   1.1     2007-02-15  한정훈   -Request 에 CLOB 적용
   2.0     2007-03-19  이경철   -Mixed Request 지원
   2.1     2007-04-07  이남경   -check fault 수정
                                -invoke() spec 수정
   2.2     2007-04-09  이남경   -get_custom_error_msg() 추가
   2.3     2007-04-23  이남경   -errCode 가 NULL 인 경우 check_fault() 수정
                                -set_transfer_timeout() 추가
   2.4     2007-05-10  이남경   -get_date_val() EXCEPTION 수정
   2.5     2007-06-13  이남경   -get_string_val() 에 decoding option 추가
   2.6     2007-06-20  이남경   -get_string_val() 의 default decoding 을
                                 ESC_REPLACE 로 교체
                                -Version 9 인 경우 transform 추가실행
   2.7     2007-06-27  이남경   -add_parameter() 에 escape char 처리
   2.8     2007-07-13  이남경   -ws server ip customizing 지원
   2.9     2007-07-27  서혁준   -add_parameter() 에 escape char 처리 수정
   2.10    2007-08-16  이남경   -invoke() 에서 null문자(#0;) 처리
   2.11    2007-09-06  서혁준   -wsdl base 변경 (156.147.51.4:7777)
   2.12    2007-09-21  이남경   -기본 transfer_timeout 을 600 초로 변경
   2.13    2007-10-18  이남경   -response 의 'xsi:nil="true"' 강제 삭제
   3.0     2007-10-25  이남경   -delimiter 처리 지원
                                -timestamp log 지원
                                -object type 자동생성 관련 proc 삭제
   3.1     2007-11-02  이남경   -procedure call 서비스의 delimiter 지원
   3.2     2007-11-13  이남경   -get_element_tag_name 버그 수정
   3.3     2007-11-20  이남경   -ws_addr 운영서버 연결 (165.243.166.90)
   3.4     2008-01-16  이남경   -add_parameter() 에 escape char 처리 수정
                                 <(&lt;) 추가
   3.5     2008-01-25  이남경   -Soap Header 에 정보 추가
   3.5.1   2008-08-14  이남경   -신규개발서버(172.19.69.81) 로 IP 변경
   3.5.2   2008-08-28  이남경   -운영서버(172.19.70.97) 로 IP 변경   
   3.6.2   2008-09-12  이남경   -Soap Header 정보에 DB_NAME, CURRENT_USER 추가
******************************************************************************/
   ORACLE_ERROR         EXCEPTION;                           /* ORACLE ERROR */
   UNDEFIND_ERROR       EXCEPTION; /* BIND/REMOTE ERROR (BUT, NOT SPECIFIED) */
   UNKNOWN_ERROR        EXCEPTION;                      /* WEB SERVICE ERROR */
   PRAGMA EXCEPTION_INIT (ORACLE_ERROR, -20100);
   PRAGMA EXCEPTION_INIT (UNDEFIND_ERROR, -20200);
   PRAGMA EXCEPTION_INIT (UNKNOWN_ERROR, -20300);

   ESC_NONE             NUMBER        := 0;
   ESC_DECODE           NUMBER        := 1;
   ESC_REPLACE          NUMBER        := 2;

   g_version            VARCHAR2 (80) := '10.0';
   g_user_timeout_set   BOOLEAN       := FALSE;
   g_debugging_mode     BOOLEAN       := FALSE;
   g_colspec_tag_name   VARCHAR2 (13) := 'BPEL_COL_SPEC';

   /* A type to represent a SOAP RPC request */
   TYPE request IS RECORD (
      endpoint_url    VARCHAR2 (255),
      soapaction      VARCHAR2 (255),
      charset         VARCHAR2 (255),
      req_message     VARCHAR2 (255),
      req_namespace   VARCHAR2 (255),
      res_message     VARCHAR2 (255),
      res_namespace   VARCHAR2 (255),
      soap_length     NUMBER,
      soap_message    CLOB,
      istest          BOOLEAN
   );

   /* A type to represent a SOAP RPC response */
   TYPE response IS RECORD (
      doc   XMLTYPE
   );

   TYPE tbl_string IS TABLE OF VARCHAR2(255) INDEX BY PLS_INTEGER;   
/*   
   dequeue_options    DBMS_AQ.dequeue_options_t;
   dequeue_msg_prop   DBMS_AQ.message_properties_t;
   dequeue_msg_id     RAW(16);
*/   
   /*
    * Create a new SOAP RPC request.
    */
   FUNCTION new_request (
      endpoint_url    VARCHAR2,
      soapaction      VARCHAR2,
      charset         VARCHAR2,
      req_message     VARCHAR2,
      req_namespace   VARCHAR2,
      res_message     VARCHAR2,
      res_namespace   VARCHAR2,
      ws_addr_ip      VARCHAR2 DEFAULT NULL
   )
      RETURN request;

   /*
    * Add a parameter to a SOAP RPC request
    */
   PROCEDURE add_parameter (
      req       IN OUT NOCOPY   request,
      p_name    IN              VARCHAR2,
      p_value   IN              VARCHAR2
   );

   PROCEDURE add_parameter_tag_start (
      req      IN OUT NOCOPY   request,
      t_name   IN              VARCHAR2
   );

   PROCEDURE add_parameter_tag_end (
      req      IN OUT NOCOPY   request,
      t_name   IN              VARCHAR2
   );

   PROCEDURE show_envelope (env IN VARCHAR2);

   PROCEDURE check_fault (resp IN OUT NOCOPY response);

   PROCEDURE generate_envelope (
      req   IN OUT NOCOPY  request,
      env   IN OUT NOCOPY  CLOB,
      seq   IN             NUMBER
   );

   PROCEDURE invoke (
      req    IN OUT NOCOPY   request,
      resp   IN OUT NOCOPY   response,
      cf     IN              BOOLEAN DEFAULT TRUE
   );

   FUNCTION get_response_from_delim_result (
      xmldoc      XMLTYPE,
      res_message VARCHAR2,
      delim       VARCHAR2
   )
      RETURN XMLTYPE;

   PROCEDURE get_xml_from_delim (
      xmldoc  IN            XMLTYPE,
      delim   IN            VARCHAR2,
      clobdoc IN OUT NOCOPY CLOB
   );
/*   
   PROCEDURE dequeue (
      resp       IN  response,
      queue_name IN  VARCHAR2,
      qtype_name IN  VARCHAR2,
      message    OUT ANYDATA
   );
*/
   FUNCTION get_string_val (
      xmldoc       XMLTYPE,
      tag_name     VARCHAR2,
      opt_decode   NUMBER
   )
      RETURN VARCHAR2;

   FUNCTION get_string_val (
      xmldoc       XMLTYPE,
      tag_name     VARCHAR2,
      opt_decode   BOOLEAN DEFAULT FALSE
   )
      RETURN VARCHAR2;

   FUNCTION get_number_val (xmldoc XMLTYPE, tag_name VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_date_val (xmldoc XMLTYPE, tag_name VARCHAR2)
      RETURN DATE;

   PROCEDURE validate_xml (req IN OUT NOCOPY request, b IN BOOLEAN DEFAULT TRUE);

   FUNCTION get_custom_error_msg (xmldoc XMLTYPE)
      RETURN XMLTYPE;

   PROCEDURE set_transfer_timeout (sec IN PLS_INTEGER DEFAULT 60);

   PROCEDURE split_into_table (
      str    IN  VARCHAR2,
      delim  IN  VARCHAR2,
      tokens OUT tbl_string
   );

   FUNCTION get_token (
      str    IN VARCHAR2,
      delim  IN VARCHAR2,
      i      IN NUMBER
   )
      RETURN VARCHAR2;

   PROCEDURE timestamp_log_on (
      b IN BOOLEAN DEFAULT TRUE
   );

   PROCEDURE timestamp_log (
      p_msg   IN VARCHAR2
   );

   FUNCTION get_element_tag_name (
      xml       IN XMLTYPE,
      child_idx IN NUMBER DEFAULT 0
   )
      RETURN VARCHAR2;
/*      
   PROCEDURE set_aq_property (
      corrid   IN VARCHAR2,
      wait_sec IN NUMBER DEFAULT 30
   );
*/
END; 
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.soap_handler
AS
/******************************************************************************
   PACKAGE NAME : soap_handler_test (BODY)
   PURPOSE : SOAP Message 를 생성하여 Web Service 를 호출하고, Web Service 로
             부터 받은 SOAP Message 를 분석한다.

   REVISIONS:
   Ver     Date        Author   Description
   ------  ----------  -------  -----------------------------------------------
   1.0     2006-12-18  한정훈   -최초 작성
   1.1     2007-02-15  한정훈   -Request 에 CLOB 적용
   2.0     2007-03-19  이경철   -Mixed Request 지원
   2.1     2007-04-07  이남경   -check fault 수정
                                -invoke() spec 수정
   2.2     2007-04-09  이남경   -get_custom_error_msg() 추가
   2.3     2007-04-23  이남경   -errCode 가 NULL 인 경우 check_fault() 수정
                                -set_transfer_timeout() 추가
   2.4     2007-05-10  이남경   -get_date_val() EXCEPTION 수정
   2.5     2007-06-13  이남경   -get_string_val() 에 decoding option 추가
   2.6     2007-06-20  이남경   -get_string_val() 의 default decoding 을
                                 ESC_REPLACE 로 교체
                                -Version 9 인 경우 transform 추가실행
   2.7     2007-06-27  이남경   -add_parameter() 에 escape char 처리
   2.8     2007-07-13  이남경   -ws server ip customizing 지원
   2.9     2007-07-27  서혁준   -add_parameter() 에 escape char 처리 수정
   2.10    2007-08-16  이남경   -invoke() 에서 null문자(#0;) 처리
   2.11    2007-09-06  서혁준   -wsdl base 변경 (156.147.51.4:7777)
   2.12    2007-09-21  이남경   -기본 transfer_timeout 을 600 초로 변경
   2.13    2007-10-18  이남경   -response 의 'xsi:nil="true"' 강제 삭제
   3.0     2007-10-25  이남경   -delimiter 처리 지원
                                -timestamp log 지원
                                -object type 자동생성 관련 proc 삭제
   3.1     2007-11-02  이남경   -procedure call 서비스의 delimiter 지원
   3.2     2007-11-13  이남경   -get_element_tag_name 버그 수정
   3.3     2007-11-20  이남경   -ws_addr 운영서버 연결 (165.243.166.90)
   3.4     2008-01-16  이남경   -add_parameter() 에 escape char 처리 수정
                                 <(&lt;) 추가
   3.5     2008-01-25  이남경   -Soap Header 에 정보 추가
   3.5.1   2008-08-14  이남경   -신규개발서버(172.19.69.81) 로 IP 변경
   3.5.2   2008-08-28  이남경   -운영서버(172.19.70.97) 로 IP 변경  
   3.6.2   2008-09-12  이남경   -Soap Header 정보에 DB_NAME, CURRENT_USER 추가
******************************************************************************/

   /* BPEL PM Server Address */
   WS_ADDR   VARCHAR2 (100);

   FUNCTION new_request (
      endpoint_url    VARCHAR2,
      soapaction      VARCHAR2,
      charset         VARCHAR2,
      req_message     VARCHAR2,
      req_namespace   VARCHAR2,
      res_message     VARCHAR2,
      res_namespace   VARCHAR2,
      ws_addr_ip      VARCHAR2 DEFAULT NULL
   )
      RETURN request
   AS
      req   request;
   BEGIN
      BEGIN
         SELECT VALUE
           INTO g_version
           FROM nls_database_parameters
          WHERE parameter = 'NLS_RDBMS_VERSION';
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      IF ws_addr_ip IS NULL
      THEN
         req.endpoint_url := WS_ADDR || endpoint_url;
      ELSE
         req.endpoint_url :=
                  'http://' || ws_addr_ip || ':7777/orabpel/' || endpoint_url;
      END IF;

      req.soapaction := soapaction;
      req.charset := ';charset="' || charset || '"';
      req.req_message := req_message;
      req.req_namespace := req_namespace;
      req.res_message := res_message;
      req.res_namespace := res_namespace;
      req.soap_length := 0;
      req.istest := FALSE;
      DBMS_LOB.createtemporary (req.soap_message, TRUE, 2);
      RETURN req;
   END;

   PROCEDURE add_parameter (
      req       IN OUT NOCOPY   request,
      p_name    IN              VARCHAR2,
      p_value   IN              VARCHAR2
   )
   AS
      xmlstr   VARCHAR2 (32767);
   BEGIN
      xmlstr := '<' || p_name || '>'
             || REPLACE (
                REPLACE (p_value, '<', '&lt;')
                                , '&', '&amp;')
             || '</'|| p_name || '>'
             || CHR (10);
      req.soap_length := req.soap_length + LENGTHB (xmlstr);
      DBMS_LOB.writeappend (req.soap_message, LENGTH (xmlstr), xmlstr);
   END;

   PROCEDURE add_parameter_tag_start (
      req      IN OUT NOCOPY   request,
      t_name   IN              VARCHAR2
   )
   AS
      xmlstr   VARCHAR2 (32767);
   BEGIN
      xmlstr := '<' || t_name || '>' || CHR (10);
      req.soap_length := req.soap_length + LENGTHB (xmlstr);
      DBMS_LOB.writeappend (req.soap_message, LENGTH (xmlstr), xmlstr);
   END;

   PROCEDURE add_parameter_tag_end (
      req      IN OUT NOCOPY   request,
      t_name   IN              VARCHAR2
   )
   AS
      xmlstr   VARCHAR2 (32767);
   BEGIN
      xmlstr := '</' || t_name || '>' || CHR (10);
      req.soap_length := req.soap_length + LENGTHB (xmlstr);
      DBMS_LOB.writeappend (req.soap_message, LENGTH (xmlstr), xmlstr);
   END;

   PROCEDURE check_fault (resp IN OUT NOCOPY response)
   AS
      fault_node          XMLTYPE;
      fault_detail_node   XMLTYPE;
      fault_code_node     XMLTYPE;
      fault_string_node   XMLTYPE;
      fault_code          VARCHAR2 (256);
      fault_string        VARCHAR2 (32767);
   BEGIN
      --dbms_output.put_line(resp.doc.getstringval);
      fault_node := resp.doc.EXTRACT ('/Fault');

      IF (fault_node IS NOT NULL)
      THEN
         fault_detail_node := resp.doc.EXTRACT ('/Fault/detail');

         IF (fault_detail_node IS NOT NULL)
         THEN
            fault_code_node :=
               fault_node.EXTRACT
                                 ('/Fault/detail/error/errCode/child::node()');
            fault_string_node :=
               fault_node.EXTRACT ('/Fault/detail/error/errMsg/child::node()');

            IF fault_string_node IS NOT NULL
            THEN
               fault_string := fault_string_node.getstringval ();
            END IF;

            IF fault_code_node IS NOT NULL
            THEN
               fault_code := fault_code_node.getstringval ();

               IF fault_code <> '0'
               THEN
                  /* ORACLE ERROR */
                  BEGIN
                     raise_application_error (-20100, SUBSTR(fault_string,1,1024));
                  EXCEPTION
                     WHEN ORACLE_ERROR
                     THEN
                        EXECUTE IMMEDIATE '
DECLARE
  tmp_exp EXCEPTION;
  PRAGMA EXCEPTION_INIT(tmp_exp, -'||fault_code||');
BEGIN
  RAISE tmp_exp;
END;
';
                  END;
               ELSE
                  /* WEB SERVICE ERROR */
                  raise_application_error (-20300, SUBSTR(fault_string,1,1024));
               END IF;
            ELSE
               /* BIND/REMOTE ERROR (BUT, NOT SPECIFIED) */
               raise_application_error (-20200, SUBSTR(fault_string,1,1024));
            END IF;
         ELSE
            fault_string_node :=
                      fault_node.EXTRACT ('/Fault/faultstring/child::node()');

            IF fault_string_node IS NOT NULL
            THEN
               fault_string := fault_string_node.getstringval ();
               raise_application_error (-20300, SUBSTR(fault_string,1,1024));
            ELSE
               fault_string := fault_node.getstringval ();
               raise_application_error (-20300, SUBSTR(fault_string,1,1024));
            END IF;
         END IF;
      END IF;
   END;

   PROCEDURE generate_envelope (
      req   IN OUT NOCOPY  request,
      env   IN OUT NOCOPY  CLOB,
      seq   IN             NUMBER
   )
   AS
      msg   VARCHAR2 (32767);
   BEGIN
      msg := '<SOAP:Envelope'
 ||CHR(10)|| '  xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/"'
 ||CHR(10)|| '  xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance"'
 ||CHR(10)|| '  xmlns:xsd="http://www.w3.org/1999/XMLSchema">'
 ||CHR(10)|| '  <SOAP:Header>'
 ||CHR(10)|| '    <ci:consumerInfo xmlns:ci="http://lgdsoa.lgdisplay.com/eai/common/consumerInfoSchema">'
 --||CHR(10)|| '      <ci:CONSUMER_IP>'||SYS_CONTEXT('USERENV','IP_ADDRESS')||'</ci:CONSUMER_IP>'
 --||CHR(10)|| '      <ci:CONSUMER_NAME>'||SYS_CONTEXT('USERENV','HOST')||'</ci:CONSUMER_NAME>'
 --||CHR(10)|| '      <ci:DB_NAME>'||SYS_CONTEXT('USERENV','DB_NAME')||'</ci:DB_NAME>'
-- ||CHR(10)|| '      <ci:DB_NAME>'||'jdbc/LOCAL10G_DS'||'</ci:DB_NAME>'
 ||CHR(10)|| '      <ci:DB_NAME>'||SYS_CONTEXT('USERENV','DB_NAME')||'</ci:DB_NAME>'
 ||CHR(10)|| '      <ci:CURRENT_USER>'||SYS_CONTEXT('USERENV','CURRENT_USER')||'</ci:CURRENT_USER>'
 ||CHR(10)|| '    </ci:consumerInfo>'
 ||CHR(10)|| '  </SOAP:Header>'
 ||CHR(10)|| '  <SOAP:Body>'
 ||CHR(10)|| '    <' || req.req_message
 ||CHR(10)|| '      xmlns="' || req.req_namespace || '"  '
 ||CHR(10)|| '      SOAP:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' ||CHR(10);

      req.soap_length := req.soap_length + LENGTHB (msg);
      DBMS_LOB.writeappend (env, LENGTH (msg), msg);
      DBMS_LOB.append (env, req.soap_message);

      msg := '    </' || req.req_message || '>'
 ||CHR(10)|| '  </SOAP:Body>'
 ||CHR(10)|| '</SOAP:Envelope>';

      DBMS_LOB.writeappend (env, LENGTH (msg), msg);
      req.soap_length := req.soap_length + LENGTHB (msg);
   END;

   PROCEDURE invoke (
      req    IN OUT NOCOPY   request,
      resp   IN OUT NOCOPY   response,
      cf     IN              BOOLEAN DEFAULT TRUE
   )
   AS
      env          VARCHAR2 (32767);
      envclob      CLOB;
      http_req     UTL_HTTP.req;
      http_resp    UTL_HTTP.resp;
      num          BINARY_INTEGER;
      sno          BINARY_INTEGER;
      amt          BINARY_INTEGER;
      rmd          BINARY_INTEGER;
      reqxml       XMLTYPE;
      seq          NUMBER := 1;
      xsl_normal   XMLTYPE;
      isfault      BOOLEAN := FALSE;

   BEGIN

      xsl_normal := xmltype.createxml('<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
  <xsl:template match="/">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  <xsl:template match="*">
    <xsl:element name="{name(.)}">
    <xsl:apply-templates select="*|text()"/>
    </xsl:element>
  </xsl:template >
  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>
</xsl:stylesheet>');

      DBMS_LOB.CREATETEMPORARY (envclob, TRUE, 2);

      num := 0;
      sno := 0;
      amt := 16400;
      rmd := 0;

      DBMS_LOB.TRIM (envclob, 0);

      generate_envelope (req, envclob, seq);

      --show_envelope (DBMS_LOB.SUBSTR (envclob));

      num := DBMS_LOB.GETLENGTH (envclob);

      IF req.istest
      THEN
         reqxml := XMLTYPE (envclob);
         DBMS_OUTPUT.put_line ('Testing Mode');
         show_envelope (DBMS_LOB.SUBSTR (envclob));

         IF reqxml.isfragment <> 0
         THEN
            -- request message is not a well-formed.
            NULL;
         END IF;
      END IF;

      IF g_user_timeout_set = FALSE
      THEN
         UTL_HTTP.set_transfer_timeout (600);
      END IF;

      --UTL_HTTP.SET_RESPONSE_ERROR_CHECK(TRUE);

      http_req := UTL_HTTP.begin_request (req.endpoint_url, 'POST', 'HTTP/1.1');
      UTL_HTTP.set_header (http_req,
                           'Content-Type',
                           'text/xml' || req.CHARSET
                          );
      UTL_HTTP.set_header (http_req, 'Content-Length', req.soap_length);
      UTL_HTTP.set_header (http_req, 'SOAPAction', req.soapaction);

      sno := 1;
      rmd := num;
      env := '';

      LOOP
         IF (rmd < amt)
         THEN
            amt := rmd;
            DBMS_LOB.READ (envclob, amt, sno, env);
            UTL_HTTP.write_text (http_req, env);
            EXIT;
         ELSE
            DBMS_LOB.READ (envclob, amt, sno, env);
            UTL_HTTP.write_text (http_req, env);
            sno := sno + amt;
            rmd := rmd - amt;
         END IF;
      END LOOP;

      DBMS_LOB.TRIM (envclob, 0);

      timestamp_log('[01] start get_response() | SEQ = ' || seq);
      ----------------------------------------------
      http_resp := UTL_HTTP.get_response (http_req);
      ----------------------------------------------
      timestamp_log('[02] end get_response()');

      BEGIN
         LOOP
            UTL_HTTP.read_text (http_resp, env);
            env := REPLACE (env, CHR (0), ''); -- handling null charactor(#0;)
            env := REPLACE (env, 'xsi:nil="true"', '');
            DBMS_LOB.WRITEAPPEND (envclob, LENGTH (env), env);
            --show_envelope(env);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            UTL_HTTP.end_response (http_resp);
         WHEN OTHERS
         THEN
            UTL_HTTP.end_response (http_resp);
      END;

      timestamp_log('[03] end write in clob');

      IF DBMS_LOB.INSTR(envclob, '<env:Fault') > 0
      THEN
        isfault := TRUE;
      END IF;

      --show_envelope(DBMS_LOB.SUBSTR(envclob));

      timestamp_log('[04] start createxml()');

      resp.doc := XMLTYPE.createxml (envclob);
      timestamp_log('[05] end createxml() / start transform()');
      resp.doc :=
         resp.doc.EXTRACT
                  ('/soap:Envelope/soap:Body/child::node()',
                   'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/'
                  ).transform (xsl_normal);

      IF SUBSTR (g_version, 1, INSTR (g_version, '.') - 1) = '9'
      THEN
         resp.doc := resp.doc.transform (xsl_normal);
      END IF;

      timestamp_log('[06] end transform()');

      --show_envelope(resp.doc.getstringval);

      --IF resp.doc.EXTRACT('/'||req.res_message||'/BPEL_COL_SPEC') IS NOT NULL
      IF resp.doc.EXISTSNODE('//' || g_colspec_tag_name) > 0
      THEN
         resp.doc := get_response_from_delim_result(resp.doc, req.res_message, '|!F!|');
         timestamp_log('  [D7] end delim (createxml())');
      END IF;

      DBMS_LOB.FREETEMPORARY(envclob);

      IF isfault AND cf
      THEN
         check_fault (resp);
      END IF;

      timestamp_log('[07] end invoke()');

   END;

   FUNCTION get_response_from_delim_result (
      xmldoc      XMLTYPE,
      res_message VARCHAR2,
      delim       VARCHAR2
   )
      RETURN XMLTYPE
   AS

      TYPE ref_cursor IS REF CURSOR;

      v_cursor ref_cursor;
      v_doc    XMLTYPE;
      envclob  CLOB;

   BEGIN

      timestamp_log('  [D1] start delim / start extract col_spec');

      DBMS_LOB.CREATETEMPORARY (envclob, TRUE, 2);

      IF get_element_tag_name (xmldoc, 1) = g_colspec_tag_name
      THEN  -- select view

         get_xml_from_delim(xmldoc, delim, envclob);

      ELSE  -- procedure call

         DBMS_LOB.WRITEAPPEND (envclob, LENGTH ('<'||res_message||'>'||CHR(10)), '<'||res_message||'>'||CHR(10));

         OPEN  v_cursor
         FOR   'select value(p) from table(xmlsequence(extract(:1, :2))) p'
         USING xmldoc, '//'||res_message||'/child::node()';
         LOOP
            FETCH v_cursor INTO v_doc;
            EXIT WHEN v_cursor%NOTFOUND;

            IF v_doc.EXISTSNODE('//'||g_colspec_tag_name) > 0
            THEN  -- delimeter used element
               get_xml_from_delim(v_doc, delim, envclob);
            ELSE  -- normal element
               DBMS_LOB.WRITEAPPEND (envclob, LENGTH (v_doc.getstringval||CHR(10)), v_doc.getstringval||CHR(10));
            END IF;

         END LOOP;

         DBMS_LOB.WRITEAPPEND (envclob, LENGTH ('</'||res_message||'>'), '</'||res_message||'>');

      END IF;

      timestamp_log('  [D6] end make response clob / start createxml()');

      RETURN XMLTYPE.CREATEXML(envclob);

   END;

   PROCEDURE get_xml_from_delim (
      xmldoc  IN            XMLTYPE,
      delim   IN            VARCHAR2,
      clobdoc IN OUT NOCOPY CLOB
   )
   AS

      v_root_element    VARCHAR2(255) := '';
      v_row_element     VARCHAR2(255) := '';
      v_data_element    VARCHAR2(20)  := 'BPEL_DATA';

      v_column_str      VARCHAR2(32767) := '';
      v_column_array    tbl_string;

      v_one_row         VARCHAR2(32767);
      v_element         VARCHAR2(32767);

      envclob           CLOB;

      TYPE ref_cursor IS REF CURSOR;

      v_cursor ref_cursor;
      v_doc    XMLTYPE;

      row_index NUMBER := 1;

   BEGIN

      v_root_element := get_element_tag_name (xmldoc);     -- P_RESULTS_TBL
      v_row_element  := get_element_tag_name (xmldoc, 2);  -- P_RESULTS_TBL_ITEM

      v_column_str := xmldoc.EXTRACT('/'||v_root_element||'/'||g_colspec_tag_name||'/child::node()').getstringval;
      timestamp_log('  [D2] end extract col_spec / start split col_spec');
      split_into_table(v_column_str, delim, v_column_array);
      timestamp_log('  [D3] end split col_spec | COLS = ' || v_column_array.COUNT);

      DBMS_LOB.WRITEAPPEND (clobdoc, LENGTH ('<'||v_root_element||'>'||CHR(10)), '<'||v_root_element||'>'||CHR(10));

      IF v_row_element IS NOT NULL
      THEN

         OPEN  v_cursor
         FOR   'select value(p) from table(xmlsequence(extract(:1, :2))) p'
         USING xmldoc, '//'||v_row_element;
         LOOP
            FETCH v_cursor INTO v_doc;
            EXIT WHEN v_cursor%NOTFOUND;

            DBMS_LOB.WRITEAPPEND (clobdoc,
                                  LENGTH('<'||v_row_element||'>'||CHR(10)),
                                  '<'||v_row_element||'>'||CHR(10));

            v_one_row := get_string_val(v_doc, v_data_element);

            timestamp_log('  [D4] start make elements | ROW = ' || row_index);

            FOR i IN 1..v_column_array.COUNT
            LOOP
               v_element := '<'||v_column_array(i)||'>'||get_token(v_one_row, delim, i)||'</'||v_column_array(i)||'>'||CHR(10);
               DBMS_LOB.WRITEAPPEND (clobdoc, LENGTH (v_element), v_element);
            END LOOP;

            timestamp_log('  [D5] end make elements');

            DBMS_LOB.WRITEAPPEND (clobdoc,
                                  LENGTH('</'||v_row_element||'>'||CHR(10)),
                                  '</'||v_row_element||'>'||CHR(10));

            --IF row_index = 2 THEN  EXIT; END IF;
            row_index := row_index + 1;

         END LOOP;

      END IF;

      DBMS_LOB.WRITEAPPEND (clobdoc, LENGTH ('</'||v_root_element||'>'||CHR(10)), '</'||v_root_element||'>'||CHR(10));

   END;
/*
   PROCEDURE dequeue (
      resp       IN  response,
      queue_name IN  VARCHAR2,
      qtype_name IN  VARCHAR2,
      message    OUT ANYDATA
   )
   AS
      corrid VARCHAR2(128);
   BEGIN
      corrid := get_string_val(resp.doc, 'corrid');
      EXECUTE IMMEDIATE '
         DECLARE
            message '|| qtype_name ||';
            dequeue_options    DBMS_AQ.dequeue_options_t;
            message_properties DBMS_AQ.message_properties_t;
            message_handle     RAW(16);
         BEGIN
            dequeue_options.navigation   := DBMS_AQ.FIRST_MESSAGE;
            dequeue_options.correlation  := :2;
            dequeue_options.wait         := 30;
            dequeue_options.visibility   := DBMS_AQ.IMMEDIATE;
            dequeue_options.dequeue_mode := DBMS_AQ.BROWSE;

            DBMS_AQ.DEQUEUE(
               queue_name         => :1,
               dequeue_options    => dequeue_options,
               message_properties => message_properties,
               payload            => message,
               msgid              => message_handle );

            :3 := ANYDATA.ConvertObject(message);
         END;'
      USING queue_name, corrid, OUT message;
   END;
*/
   PROCEDURE validate_xml (req IN OUT NOCOPY request, b IN BOOLEAN DEFAULT TRUE)
   AS
   BEGIN
      req.istest := b;
   END;

   FUNCTION get_string_val (
      xmldoc       XMLTYPE,
      tag_name     VARCHAR2,
      opt_decode   NUMBER
   )
      RETURN VARCHAR2
   AS
      retval   VARCHAR2 (32766);
   BEGIN
      IF tag_name IS NULL
      THEN
         retval := NULL;
      END IF;

      BEGIN
         IF opt_decode = esc_decode
         THEN
            retval := DBMS_XMLGEN.CONVERT(xmldoc.EXTRACT ('//'|| tag_name || '/child::node()').getstringval,
                                          DBMS_XMLGEN.entity_decode);
         ELSIF opt_decode = esc_replace
         THEN
            retval := REPLACE(
                      REPLACE(
                      REPLACE(
                      REPLACE(
                      REPLACE(xmldoc.EXTRACT ('//' || tag_name || '/child::node()').getstringval, '&quot;', '"')
                                                                                                , '&lt;'  , '<')
                                                                                                , '&gt;'  , '>')
                                                                                                , '&apos;', '''')
                                                                                                , '&amp;' , '&');
         ELSE
            retval := xmldoc.EXTRACT ('//' || tag_name || '/child::node()').getstringval;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := NULL;
      END;

      RETURN retval;
   END;

   FUNCTION get_string_val (
      xmldoc       XMLTYPE,
      tag_name     VARCHAR2,
      opt_decode   BOOLEAN DEFAULT FALSE
   )
      RETURN VARCHAR2
   AS
   --retVal   VARCHAR2(32766);
   BEGIN
      IF opt_decode
      THEN
         RETURN get_string_val (xmldoc, tag_name, ESC_REPLACE);
      ELSE
         RETURN get_string_val (xmldoc, tag_name, ESC_NONE);
      END IF;
   END;

   FUNCTION get_number_val (xmldoc XMLTYPE, tag_name VARCHAR2)
      RETURN NUMBER
   AS
      retval   NUMBER;
   BEGIN
      IF tag_name IS NULL
      THEN
         retval := NULL;
      END IF;

      BEGIN
         retval :=
            xmldoc.EXTRACT ('//' || tag_name || '/child::node()').getnumberval;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := NULL;
      END;

      RETURN retval;
   END;

   FUNCTION get_date_val (xmldoc XMLTYPE, tag_name VARCHAR2)
      RETURN DATE
   AS
      retval   DATE;
   BEGIN
      IF tag_name IS NULL
      THEN
         retval := NULL;
      END IF;

      BEGIN
         retval :=
            TO_DATE
               (TO_CHAR
                   (TO_TIMESTAMP_TZ
                       (REPLACE(xmldoc.EXTRACT ('//' || tag_name || '/child::node()').getstringval, 'T', ' '),
                        'YYYY-MM-DD HH24:MI:SSXFFTZH:TZM'
                       ),
                    'YYYY-MM-DD HH24:MI:SS'
                   ),
                'YYYY-MM-DD HH24:MI:SS'
               );
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := NULL;
      END;

      RETURN retval;
   END;

   PROCEDURE show_envelope (env IN VARCHAR2)
   AS
      i     PLS_INTEGER;
      len   PLS_INTEGER;
   BEGIN
      i := 1;
      len := LENGTH (env);

      WHILE (i <= len)
      LOOP
         --dbms_output.put_line(env);
         DBMS_OUTPUT.put_line (SUBSTR (env, i, 120));
         i := i + 120;
      END LOOP;
   END;

   FUNCTION get_custom_error_msg (xmldoc XMLTYPE)
      RETURN XMLTYPE
   AS
   BEGIN
      RETURN xmldoc.EXTRACT ('/Fault/detail/error/customError/child::node()');
   END;

   PROCEDURE set_transfer_timeout (sec IN PLS_INTEGER DEFAULT 60)
   AS
   BEGIN
      g_user_timeout_set := TRUE;
      UTL_HTTP.set_transfer_timeout (sec);
   END;

   PROCEDURE split_into_table (
      str    IN VARCHAR2,
      delim  IN VARCHAR2,
      tokens OUT tbl_string
   )
   AS
      v_pos    PLS_INTEGER;
      v_list   VARCHAR2(32767) := str;
      v_value  VARCHAR2(32767);
      i        NUMBER := 1;
   BEGIN
      LOOP
         v_pos := INSTR(v_list, delim);
         IF v_pos > 0
         THEN
            tokens(i) := SUBSTR(v_list, 1, v_pos-1);
            v_list := SUBSTR(v_list, v_pos + LENGTH(delim));
         ELSE
            tokens(i) := v_list;
            EXIT;
         END IF;
         i := i + 1;
      END LOOP;
      RETURN;
   END;

   FUNCTION get_token (
      str    IN VARCHAR2,
      delim  IN VARCHAR2,
      i      IN NUMBER
   )
      RETURN VARCHAR2
   AS
      start_pos NUMBER;
      end_pos   NUMBER;
   BEGIN
      IF i = 1
      THEN
         start_pos := 1;
      ELSE
         start_pos := INSTR(str, delim, 1, i-1);
         IF start_pos = 0
         THEN
            RETURN NULL;
         ELSE
            start_pos := start_pos + LENGTH(delim);
         END IF;
      END IF;

      end_pos := INSTR(str, delim, start_pos, 1);

      IF end_pos = 0
      THEN
         RETURN SUBSTR(str, start_pos);
      ELSE
         RETURN SUBSTR(str, start_pos, end_pos - start_pos);
      END IF;
   END;

   PROCEDURE timestamp_log_on (
      b IN BOOLEAN DEFAULT TRUE
   )
   AS
   BEGIN
      g_debugging_mode := b;
   END;

   PROCEDURE timestamp_log (
      p_msg   IN VARCHAR2
   )
   AS
   BEGIN
      IF g_debugging_mode
      THEN
         dbms_output.PUT_LINE('['||to_char(CURRENT_TIMESTAMP,'HH24:MI:SS.ff3')||'] ' || SUBSTR(p_msg,1,240));
      END IF;
   END;

   FUNCTION get_element_tag_name (
      xml       IN XMLTYPE,
      child_idx IN NUMBER DEFAULT 0
   )
      RETURN VARCHAR2
   AS
      temp_clob CLOB;
      pos_1     NUMBER;
      pos_2     NUMBER;
   BEGIN

      DBMS_LOB.CREATETEMPORARY (temp_clob, TRUE, 2);

      IF child_idx = 0
      THEN
         DBMS_LOB.APPEND(temp_clob, xml.EXTRACT('/self::node()').getclobval);
         --RETURN LTRIM(REGEXP_SUBSTR(xml.EXTRACT('/self::node()').getclobval, '^<[([:alnum:]|_)]*'),'<');
      ELSE
         DBMS_LOB.APPEND(temp_clob, xml.EXTRACT('/*/child::node()['||child_idx||']').getclobval);
         --RETURN LTRIM(REGEXP_SUBSTR(xml.EXTRACT('/*/child::node()['||child_idx||']').getstringval, '^<[([:alnum:]|_)]*'),'<');
      END IF;

      pos_1 := DBMS_LOB.INSTR(temp_clob, '<');
      pos_2 := DBMS_LOB.INSTR(temp_clob, '>');

      RETURN DBMS_LOB.SUBSTR(temp_clob, pos_2-pos_1-1, pos_1+1);

      EXCEPTION WHEN OTHERS THEN
         RETURN NULL;

   END;
/*
   PROCEDURE set_aq_property (
      corrid   IN VARCHAR2,
      wait_sec IN NUMBER DEFAULT 30
   )
   AS
   BEGIN
      dequeue_options.navigation  := DBMS_AQ.FIRST_MESSAGE;
      dequeue_options.correlation := corrid;
      dequeue_options.wait        := wait_sec;
      dequeue_options.visibility  := DBMS_AQ.IMMEDIATE;
   END;
*/
BEGIN
    WS_ADDR :='http://172.19.69.81:3010/orabpel/';
END;
/
