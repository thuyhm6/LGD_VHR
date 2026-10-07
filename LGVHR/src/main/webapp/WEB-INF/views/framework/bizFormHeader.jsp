<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"     uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn"    uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
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
<c:set var="version" value="1.1.6"/>
<c:set var="contextPath" value="${pageContext.request.contextPath}"/>
<script>
    $(document).data("USER_ACCESS_LIST").put( "${param.bizFormId}", <%=userAccessString%> );
    $(document).data("USER_ACCESS_LIST_COUNT").put( "${param.bizFormId}", <%=count%> );   
    
</script>