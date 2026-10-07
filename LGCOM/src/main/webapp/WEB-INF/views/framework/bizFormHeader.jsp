<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"     uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn"    uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : bizFormHeader.jsp
    프로젝트명 : LGD WCFW 프로젝트

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 사용자 권한
    작성자 : wcfw
-------------------------------------------------------------%>
<%
    String userAccessString = (String)request.getAttribute("userAccessList");
    String userAccessCount  = (String)( request.getAttribute("userAccessCount") + "" );

    int count = 0;

    if( userAccessCount != null && !userAccessCount.equals("") && !userAccessCount.equals("null") ) {
        count = Integer.parseInt( userAccessCount );
    }

    if( userAccessString == null || userAccessString.equals("") ) {
        userAccessString = "[]";
    }

    response.setHeader("serverTime", (String)request.getAttribute("serverTime") );

%>
<script>
    $(document).data("USER_ACCESS_LIST").put( "${param.bizFormId}", <%=userAccessString%> );
    $(document).data("USER_ACCESS_LIST_COUNT").put( "${param.bizFormId}", <%=count%> );
</script>