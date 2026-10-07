<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="devonframe.util.*" %>
<%@ page import="com.lgd.lgcom.common.util.*" %>
<%@ page import="com.lgd.lgcom.framework.model.*" %>
<%@ page import="org.springframework.util.*" %>
<%---------------------------------------------------------
    파일명 : fileDwonlad.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : file download
    작성자 : wcfw
-------------------------------------------------------------%>
<%!
private LGCOMMap getFileInfo(String fileId) throws Exception {
	String env = System.getProperty("env","local");
	System.out.println("env = " + env);
	// 파일 ID로 파일 정보를 조회한다.
	LGCOMMap fileData = this.retriveFileInfo(env, fileId);
	LGCOMMap result = null;
	if(fileData != null) {
		result = new LowerCamelCaseMap();
		if("prod".equalsIgnoreCase(env)) {
			result.setString("baseDir","/data001/jussvc10/HRM/upload/");
		} else if("dev".equalsIgnoreCase(env)) {
			result.setString("baseDir","/data001/jussvc05/HRM/upload/");
		} else {
			result.setString("baseDir","C:/LGDWork/workspace/LGCOM/fileupload/HRM/");
		}
		result.setString("serverFileName",fileData.getString("fileId"));
		result.setString("clientFileName",fileData.getString("fileName"));
	}
	return result;
}

private LGCOMMap retriveFileInfo(String env, String fileId) throws Exception {
	Context ctx = new InitialContext();
	DataSource ds = null;
	if(!"local".equalsIgnoreCase(env)) {
		ds = (DataSource)ctx.lookup("DEV5");
	} else {
		ds = (DataSource)ctx.lookup("java:comp/env/jdbc/lgcom");
	}
	Connection conn = ds.getConnection();
	PreparedStatement psmt = null;
	ResultSet rslt = null;
	ResultSetMetaData meta = null;
	LGCOMMap result = null;
	StringBuffer sqlBuff = new StringBuffer();
	sqlBuff.append("SELECT /* Common.retrieveAttachFileInfoHRM */ \n");
	sqlBuff.append("       attach_file_name AS file_id \n");
	sqlBuff.append("     , 'HRM' AS module_code \n");
	sqlBuff.append("     , request_id AS req_number \n");
	sqlBuff.append("     , client_file_name AS file_name \n");
	sqlBuff.append("  FROM XXEVF_EXP_PRE_REQ_FILE_N \n");
	sqlBuff.append(" WHERE file_seq_no = ? \n");
	try {
		psmt = conn.prepareStatement(sqlBuff.toString());
		psmt.setString(1,fileId);
		rslt = psmt.executeQuery();
		meta = rslt.getMetaData();
		if(rslt.next()) {
			result = new LowerCamelCaseMap();
			for(int i=1; i <= meta.getColumnCount(); i++) {
				String columnName = meta.getColumnName(i);
				result.set(columnName, rslt.getObject(columnName));
			}
		}
	} catch(Exception sqle) {
		throw sqle;
	} finally {
		try {if(rslt != null) rslt.close();rslt=null;}catch(Exception e){};
		try {if(psmt != null) psmt.close();psmt=null;}catch(Exception e){};
		try {if(conn != null) conn.close();conn=null;}catch(Exception e){};
	}
	return result;
}
%>
<%
	String viewMode = LGCOMUtils.nvl(request.getParameter("viewMode"));
	if(org.apache.commons.lang3.StringUtils.isEmpty(viewMode)) {
		viewMode = "R";
	}
	String fileId = LGCOMUtils.nvl(request.getParameter("fileId"));
	LGCOMMap fileInfo = null;
	// 파일 ID가 존재하면 해당 파일을 조회해서 다운로드한다.
	if("R".equals(viewMode)) {
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<title>file download</title>
<meta charset="utf-8" />
<meta http-equiv="Cache-Control" content="no-cache"/>
<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
<style type="text/css">
* {font-family:Consolas;font-size:12pt;color:#666;}
.info {display:block;padding:5px 3px;}
.info.first {margin-top:10px;}
.lblTitle {display:inline-block;width:100px;text-align:right;}
.dispLabel {margin-left:10px;}
</style>
</head>

<body>
<form method="post">
	<input type="hidden" name="viewMode" value="D"/>
	<label>HRM 파일ID :</label>
	<input type="text" name="fileId" size="9" maxlength="10" style="margin-left:10px;" value="<%=fileId%>"/>
	<button type="submit">다운로드</button>
</form>
</body>
</html>
<%
	} else {
		try {
			fileInfo = getFileInfo(fileId);
			if(fileInfo == null) {
				throw new Exception("[SYSTEM] File meta data is not exist. file id is " + fileId);
			}
			// 파일을 다운로드한다.
			String fileName = LGCOMUtils.nvl(fileInfo.getString("clientFileName"));
			String physicalName = new String(LGCOMUtils.nvl(fileInfo.getString("serverFileName")).getBytes("UTF-8"),"8859_1");
			File destFile = new File(fileInfo.getString("baseDir"),physicalName);
			if(destFile == null || destFile.exists() || !destFile.isFile()) {
				throw new Exception("[SYSTEM] File not found. file name is " + fileName + ", physical name is " + physicalName);
			}

			// page의 ContentType등을 동적으로 바꾸기 위해 초기화시킴
			response.reset();
			response.setContentType("application/octet-stream");
			// 다운로드 파일명 처리
			fileName = java.net.URLEncoder.encode(fileName, "UTF-8");
			fileName = fileName.replaceAll("\\+", "%20");
			// 파일 링크를 클릭했을 때 다운로드 저장 화면이 출력되게 처리하는 부분
			response.setHeader("Content-Disposition", "attachment; filename = " + fileName);

			// 파일의 세부 정보를 읽어오기 위해서 선언
			FileInputStream in = new FileInputStream(destFile);
			FileCopyUtils.copy(in,response.getOutputStream());
			in.close();
		} catch(Exception e) {
			e.printStackTrace();

			response.reset();
			response.setContentType("text/html; charset=UTF-8");
			response.setCharacterEncoding("UTF-8");

			StringBuffer buffer = new StringBuffer();
			buffer.append("<p><a href=\"javascript:location.href='").append(request.getContextPath()).append("/fileDownload.jsp?viewMode=R&fileId=").append(fileId).append("';\">다시시도</a></p>\n");
			buffer.append("<p>").append(e.getMessage()).append(" : \n");
			out.println(buffer.toString());
		}
	}
%>
