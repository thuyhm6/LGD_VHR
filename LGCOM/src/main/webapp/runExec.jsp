<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.Map"%>
<%@ page import="com.lgd.lgcom.framework.log.LGCOMLogger"%>
<%@ page import="com.lgd.lgcom.framework.log.LGCOMLoggerFactory"%>
<%@ page import="com.lgd.lgcom.framework.exception.LGCOMException"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Shell Execution</title>
</head>
<body>
<%
LGCOMLogger logger = LGCOMLoggerFactory.getLogger(this.getClass());

String batShell = "/sorc001/juscom01/LGCOM/war/WEB-INF/classes/batch_call.sh";
String logFile = "/sorc001/juscom01/LGCOM/war/WEB-INF/classes/bat.log";
String arrParam = "param1" + " " + "param2" + " " + "param3";

InputStream inputStream = null;
BufferedReader bufferedReader = null;

try {
	String[] exec = new String[3];
	exec[0] = "/bin/sh";
	exec[1] = batShell + " >> " + logFile + " 2>&1";
	exec[2] = arrParam;
	
	Process proc = Runtime.getRuntime().exec(exec);
	proc.getInputStream();
    inputStream = proc.getInputStream();
    bufferedReader = new BufferedReader(new InputStreamReader(inputStream));
    
    while(true) {
    	String info = bufferedReader.readLine(); 
    	if(info == null || "".equals(info)) {
    		break; 
    	}
    	out.print(info);
    	logger.debug(info); 
    }
    
	proc.destroy();

} catch(Exception e) {
    Throwable cause = e.getCause();
    if(cause == null) {
        throw new LGCOMException(e.getMessage(), e);
    } else  {
        throw new LGCOMException(cause.getMessage(), cause);
    }

} finally {
	try {
		if(inputStream != null) inputStream.close();
	} catch(Exception e){}
	
	try {
		if(bufferedReader!=null) bufferedReader.close();
	} catch(Exception e){}
}
%>
</body>
</html>