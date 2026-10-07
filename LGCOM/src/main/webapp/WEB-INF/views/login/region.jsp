<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"     uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="devonframe.util.NullUtil" %>
<%@ page import="java.util.*" %>
<%@ page import="com.lgd.lgcom.framework.model.LGCOMMap" %>

<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : new_region.jsp
	프로젝트명 : LGD WCFW 프로젝트

	Copyright(c) 2017 LG CNS,  All rights reserved.

	설 명 : 본 화면은 sso 로그인 이후 Region, OU 정보를 입력받는 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<!DOCTYPE html>
<html lang="ko">
<head>
<c:set var="version" value="1.0.1"/>
<meta http-equiv="x-ua-compatible" content="IE=edge"/>
<title>Select Region &amp; OU</title>

<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/ext/jquery-ui-1.12.1/jquery-ui.min.css?version=${version}"/>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/ext/bootstrap-3.3.6-dist/css/bootstrap.min.css?version=${version}"/>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/ext/font-awesome-4.6.3/css/font-awesome.min.css?version=${version}"/>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/ext/lgduxp/css/lgd-uxp-common.css?version=${version}"/>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/ext/lgduxp/css/lgd-uxp-style.css?version=${version}"/>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/ext/lgduxp/css/lgd-uxp-helper.css?version=${version}"/>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/css/framework_main_small.css?version=${version}"/>
<style type="text/css">
html, body {
    position : static;
}

.pageContent {
	width:100%;
	display:none;
}
.pageContent>table.layout {
	margin: 100px auto 0;
	padding: 0px;
	border-spacing: 0px;
	border-collapse: collapse;
}
.pageContent>table.layout>tbody>tr>td {
	vertical-align:top;
}
.pageContent>table.layout>tbody>tr>td.btnLaout {
	padding-top:10px;
	text-align:right;
}
.default_rgn, .default_ou {
	margin-top: 10px;
	background-color: #f2f2f2;
	padding: 6px 5px 4px 5px;
}
.pageContent .dataBlock1 #regionFlagShow {
	margin-top:5px;
	padding-left:30px;
	display:block;
}
.pageContent .dataBlock2 #orgUnitFlagShow {
	margin-top:5px;
	padding-left:30px;
	display:block;
}
</style>

<%
	String url = request.getRequestURL().toString().split("/")[2];

	/* scs Reverse Proxy 대응 코드 */
	String scsHost = request.getHeader("x-forwarded-host");
	boolean scs = false;
	if( scsHost != null && scsHost.trim().startsWith("scs") ){ 
		   scs = true;
	}

    String debugMode = "N";
    if( "Y".equals( request.getParameter("debug") ) ) {
    	debugMode = "Y";
    }	
	
	String securityCode = (String)request.getAttribute("PAGE_SECURITY_CODE");
	out.println("<script>");
	out.println("\tvar CONTEXT_PATH       = \""+ request.getContextPath().replaceAll("/", "") +"\";");
	out.println("\tvar PAGE_SECURITY_CODE = \"" + securityCode + "\";" );
	out.println("\tvar SSL_SUPPORT        =  'N'; ");

    if( scs ) {
    	out.println("    var SERVER_URL  =  'http://" + scsHost + ":3001'; ");
    } else {
    	out.println("    var SERVER_URL  =  'http://" + url + "'; ");
    }	
	
	out.println("\tvar SYSTEM_ENV         = '" + NullUtil.nvl(System.getProperty("env"),"") + "';");
	out.println("    var DEBUG_MODE = '" + debugMode  + "';");
	out.println("</script>");

	String ssoId = NullUtil.nvl(request.getHeader("iv-user"),"").trim();
	if(NullUtil.isNone(ssoId)) {
		ssoId = request.getParameter("ssoId");
	}

	Map user = (Map)session.getAttribute("USER_SESSION");
	boolean isAdminFlag = false;
	if( user != null ) {
		List<Map<String, Object>> list = ( List<Map<String, Object>>)user.get("roleList");
		for( Map<String,Object> item : list ) {
			if( item.containsValue("BIZWEB_SYSTEM_ADMINISTRATOR") ) {
				isAdminFlag = true;
				break;
			}
		}

		if( "prod".equals(System.getProperty("env") ) && isAdminFlag ) {
			ssoId = request.getParameter("ssoId");
		}
	}
%>

<script src="<%=request.getContextPath()%>/static/ext/jquery-1.12.4.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/jquery-ui-1.12.1/jquery-ui.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/bootstrap-3.3.6-dist/js/bootstrap.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/bootbox.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/moment.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/validator/jquery.validate.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/lgduxp/js/lgd-uxp-ui.js?version=${version}"></script>

<% if( "prod".equals( request.getAttribute("env")+"" )  ){ %>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/prod/realgridjs-lic.js?version=${version}"></script> 
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/prod/realgridjs.1.1.20.min.js?version=${version}"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/prod/realgridjs-api.1.1.20.js?version=${version}"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/prod/jszip.min.js?version=${version}"></script>  
<% } else { 
       if( url.contains("bizweb") ) {
%>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/dev/realgridjs-lic.js?version=${version}"></script> 
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/dev/realgridjs_eval.1.1.21.min.js?version=${version}"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/dev/realgridjs-api.1.1.21.js?version=${version}"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/dev/jszip.min.js?version=${version}"></script>   
<%     } else { %>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/devip/realgridjs-lic.js?version=${version}"></script> 
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/devip/realgridjs_eval.1.1.20.min.js?version=${version}"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/devip/realgridjs-api.1.1.20.js?version=${version}"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/devip/jszip.min.js?version=${version}"></script>
 <% }
}%>

<script src="<%=request.getContextPath()%>/static/js/framework_lib.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/js/framework.js?version=${version}"></script>

<!-- LGD UXP UI 공통 스크립트 -->
<script src="<%=request.getContextPath()%>/static/ext/daterangepicker/js/jquery.daterangepicker.js?version=${version}"></script>
<script type="text/javascript">
Region = function() {
	var regionVisible = false;
	var ouVisible = false;
	var ouUseFlag = false;
	var userData;

	this.init = function() {
		var param = {ssoId:'<%=ssoId%>'};
		transaction('lgcom','region/retrieveRegionInitData',param,function(data) {
			// 초기 사용자 정보를 받는다.
			userData = data['result']['userData'];
			if(typeof(userData) == 'undefined') {
				Message.alert('<lgcom:message code="error.notFoundUser"/>');
				return;
			}
			// Region 목록 그리기
			var regionList = data['result']['regionList'];
			fncDrawRegionTable(regionList);
			// OU 목록 쓰기
			var orgUnitList = data['result']['orgUnitList'];
			fncDrawOrgUnitTable(orgUnitList);
			/* 모든 Panel이 보여지지 않으면 */
			if(!regionVisible && !ouVisible) {
				fncCreateUserSession();
				return;
			}
			// Default OU 사용여부가 Y일 경우 Region에 Default OU 정보 표시
			if($.trim(userData.defaultOrgIdUseFlag) == 'Y') {
				fncWriteDefaultOrg();
			}
			// Default Region 사용여부가 Y일 경우 OU 에 Default Region 정보 표시
			if($.trim(userData.requestRegionCodeUseFlag) == 'Y') {
				fncWriteDefaultRegion();
			}
			// 테이블 셀의 수를 계산해서 버튼 영역 조절
			fncProcessSaveButton();
			$('.pageContent').show();
		});
	};
	/*** 이벤트 핸들러  ***/
	$(document).on('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
		case 'save':
			// 저장을 수행한다.
			fncSaveRegionAndOu();
		}
	});
	/*** 이벤트 핸들러  ***/
	$(document).on('change',".dataBlock1 form input[name='requestRegionCode']",function(event) {
		var target = $(event.target);
		var userId = $.trim($(target).data('userid'));
		var ouUse = (($.trim($(target).data('ouUseFlag')) == '') ? 'N':$.trim($(target).data('ouUseFlag')));
		var orgUseFlag = $.trim($(target).data('userOrgUseFlag'));
		// 선택된 사번으로 조회된 정보를 갱신한다.
		var selUserData = {
			applicationUserId: userId,
			requestRegionCode: $.trim($(target).val()),
			requestRegionName: $.trim($(target).parent().next().find('>label').text()),
			serverTimeDifferenceSeqs: $.trim($(target).data('timezoneSeq'))
		};
		// 선택된 Region의 사번이 OU 사용여부가 N이면 Region 의 기본 OU 정보 세팅
		if(ouUse == 'N') {
			selUserData['defaultOrgId'] = $.trim($(target).data('defaultOuId'));
			selUserData['defaultOrgCode'] = $.trim($(target).data('defaultOuCode'));
			selUserData['defaultOrgName'] = $.trim($(target).data('defaultOuName'));
		} else {
			selUserData['defaultOrgId'] = $.trim($(target).data('userOuId'));
			selUserData['defaultOrgCode'] = $.trim($(target).data('userOuCode'));
			selUserData['defaultOrgName'] = $.trim($(target).data('userOuName'));
			if(orgUseFlag == 'Y') {
				// Default Org 정보 쓰기
				fncWriteDefaultOrg(selUserData);
				ouVisible = false;
			} else {
				// Default Org 정보 삭제
				$('.pageContent>table.layout>tbody>tr:nth-child(2)>td:nth-child(1)').empty();
				ouVisible = true;
			}
		}
		$.extend(userData,selUserData);
		// OU 처리
		var orgRow = $('.dataBlock2>form>table>tbody>tr');
		$(".dataBlock2 form div#regionFlagShow input[name='defaultOrgIdUseFlag']").prop('checked',false);
		$(orgRow).hide();
		if(ouUse == 'Y' && ouVisible) {
			$('.pageContent>table.layout>tbody>tr>td:nth-child(2)').show();
			$('.pageContent>table.layout>tbody>tr>td:nth-child(3)').show();
			// 테이블 셀의 수를 계산해서 버튼 영역 조절
			fncProcessSaveButton();
			$(orgRow).each(function(idx) {
				// 선택된 사번이 선택할 수 있는 OU일 경우
				if($.trim(userData.applicationUserId) == $.trim($(this).data('userId'))) {
					// OU 정보가 일치하면
					if($.trim(userData.defaultOrgId) == $.trim($(this).find(">td:first-child>input[name='defaultOrgId']").val())) {
						$(this).find(">td:first-child>input[name='defaultOrgId']").prop('checked',true);
					}
					$(this).show();
				} else {
					$(this).hide();
				}
			});
		} else {
			$('.pageContent>table.layout>tbody>tr>td:nth-child(2)').hide();
			$('.pageContent>table.layout>tbody>tr>td:nth-child(3)').hide();
			// 테이블 셀의 수를 계산해서 버튼 영역 조절
			fncProcessSaveButton();
		}
	});
	$(document).on('change',".dataBlock2 form input[name='defaultOrgId']",function(event) {
		var target = $(event.target);
		/* 선택된 UO 정보를 담는다. */
		var selUserData = {
			defaultOrgId: $.trim($(target).val()),
			defaultOrgCode: $.trim($(target).data('orgCode')),
			defaultOrgName: $.trim($(target).parent().next().find('>label').text())
		};
		$.extend(userData,selUserData);
	});
	/* Region 목록 작성 */
	function fncDrawRegionTable(list) {
		fncClearRegion();
		var panel = $('.dataBlock1 form table tbody');
		regionVisible = true;
		$('.pageContent>table.layout>tbody>tr>td:nth-child(1)').show();
		$('.pageContent>table.layout>tbody>tr>td:nth-child(2)').hide();
		$('.pageContent>table.layout>tbody>tr>td:nth-child(3)').hide();
		for(var i=0; i < list.length; i++) {
			if($.trim(userData['requestRegionCode']) == '') {
				if($.trim(userData['applicationUserId']) == $.trim(list[i].applicationUserId)) {
					ouUseFlag = (list[i].ouUseFlag == 'Y') ? true:false;
				}
			} else {
				if($.trim(userData['requestRegionCode']) == $.trim(list[i].requestRegionCode)) {
					ouUseFlag = (list[i].ouUseFlag == 'Y') ? true:false;
				}
			}
			var tr = $('<tr></tr>');
			panel.append(tr);
			var td1 = $('<td></td>');
			td1.addClass('text-center');
			tr.append(td1);
			var td2 = $('<td></td>');
			tr.append(td2);
			// Radio 버튼
			var rdo = $('<input type="radio"/>');
			rdo.attr('id','rgn_'+i);
			rdo.attr('name','requestRegionCode');
			rdo.val($.trim(list[i].requestRegionCode));
			rdo.data('userid',$.trim(list[i].applicationUserId));
			rdo.data('defaultOuId',$.trim(list[i].defaultOrgId));
			rdo.data('defaultOuCode',$.trim(list[i].defaultOrgCode));
			rdo.data('defaultOuName',$.trim(list[i].defaultOrgName));
			rdo.data('userOuId',$.trim(list[i].userOrgId));
			rdo.data('userOuCode',$.trim(list[i].userOrgCode));
			rdo.data('userOuName',$.trim(list[i].userOrgName));
			rdo.data('userOrgUseFlag',$.trim(list[i].userOrgUseFlag));
			rdo.data('ouUseFlag',$.trim(list[i].ouUseFlag));
			rdo.data('timezoneSeq',$.trim(list[i].serverTimeDifferenceSeqs));
			if($.trim(userData['requestRegionCode']) == $.trim(list[i].requestRegionCode)) {
				rdo.prop('checked',true);
				if($.trim(userData['requestRegionCodeUseFlag']) == '') {
					userData['requestRegionCodeUseFlag'] = 'N';
				}
				if($.trim(userData['serverTimeDifferenceSeqs']) == '') {
					userData['serverTimeDifferenceSeqs'] = $.trim(list[i].serverTimeDifferenceSeqs);
				}
				if($.trim(userData['defaultOrgId']) == '') {
					userData['defaultOrgId'] = $.trim(list[i].defaultOrgId);
				}
				if($.trim(userData['defaultOrgIdUseFlag']) == '') {
					userData['defaultOrgIdUseFlag'] = 'N';
				}
			}
			td1.append(rdo);
			// Region label
			var lbl = $('<label></label>');
			lbl.css('font-weight','normal');
			lbl.attr('for','rgn_'+i);
			lbl.text($.trim(list[i].requestRegionName));
			td2.append(lbl);
		}
		/* Default Region 사용여부가 Y 이면 */
		if($.trim(userData.requestRegionCode) != '' && $.trim(userData.requestRegionCodeUseFlag) == 'Y') {
			// Region 영역 숨기기
			$('.pageContent>table.layout>tbody>tr>td:nth-child(1)').hide();
			$('.pageContent>table.layout>tbody>tr>td:nth-child(2)').hide();
			regionVisible = false;
		}
	}
	/* Org Unit 목록 작성 */
	function fncDrawOrgUnitTable(list) {
		fncClearOrgUnit();
		var panel = $('.dataBlock2 form table tbody');
		ouVisible = true;
		if($('.pageContent>table.layout>tbody>tr:first-child>td:first-child').css('display') != 'none') {
			$('.pageContent>table.layout>tbody>tr>td:nth-child(2)').show();
		}
		$('.pageContent>table.layout>tbody>tr>td:nth-child(3)').show();
		for(var i=0; i < list.length; i++) {
			var tr = $('<tr></tr>');
			tr.data('userId',$.trim(list[i].applicationUserId));
			if($.trim(userData.applicationUserId) != $.trim(list[i].applicationUserId)) {
				tr.css('display','none');
			}
			panel.append(tr);
			var td1 = $('<td></td>');
			td1.addClass('text-center');
			tr.append(td1);
			var td2 = $('<td></td>');
			tr.append(td2);
			// Radio 버튼
			var rdo = $('<input type="radio"/>');
			rdo.attr('id','ou_'+i);
			rdo.attr('name','defaultOrgId');
			rdo.val($.trim(list[i].organizationId));
			rdo.data('orgCode',$.trim(list[i].organizationCode));
			if($.trim(userData['defaultOrgId']) == $.trim(list[i].organizationId)) {
				rdo.prop('checked',true);
				if($.trim(userData['defaultOrgIdUseFlag']) == '') {
					userData['defaultOrgIdUseFlag'] = 'N';
				}
			}
			td1.append(rdo);
			// Org Unit label
			var lbl = $('<label></label>');
			lbl.css('font-weight','normal');
			lbl.attr('for','ou_'+i);
			lbl.text($.trim(list[i].organizationName));
			td2.append(lbl);
		}
		/* Default OU 사용여부가 Y 이면 */
		if($.trim(userData.defaultOrgId) != '' && $.trim(userData.defaultOrgIdUseFlag) == 'Y') {
			// Org 영역 숨기기
			$('.pageContent>table.layout>tbody>tr>td:nth-child(2)').hide();
			$('.pageContent>table.layout>tbody>tr>td:nth-child(3)').hide();
			ouVisible = false;
		}
		/* OU 사용자가 아닐경우 */
		if(!ouUseFlag) {
			// Org 영역 숨기기
			$('.pageContent>table.layout>tbody>tr>td:nth-child(2)').hide();
			$('.pageContent>table.layout>tbody>tr>td:nth-child(3)').hide();
			ouVisible = false;
		}
	}
	// Region & OU 저장
	function fncSaveRegionAndOu() {
		if(regionVisible) {
			if($(".dataBlock1 form input[name='requestRegionCode']:visible:checked").length == 0) {
				Message.alert('<lgcom:message code="note.nocheckdata"/>');
				return;
			}
			// Region do not ask again 이 체크되었다면
			if($('input#requestRegionCodeUseFlag').is(':checked')) {
				userData['requestRegionCodeUseFlag'] = 'Y'
			} else {
				userData['requestRegionCodeUseFlag'] = 'N'
			}
		}
		if(ouVisible) {
			if($.trim($(".dataBlock1 form input[name='requestRegionCode']:visible:checked").data('ouUseFlag')) == 'Y') {
				if($(".dataBlock2 form input[name='defaultOrgId']:visible:checked").length == 0) {
					Message.alert('<lgcom:message code="note.nocheckdata"/>');
					return;
				}
			}
			if($('input#defaultOrgIdUseFlag').is(':checked')) {
				userData['defaultOrgIdUseFlag'] = 'Y'
			} else {
				userData['defaultOrgIdUseFlag'] = 'N'
			}
		}
		transaction_sync('lgcom','region/saveSelectedRegionAndOrgUnit', userData, function(data) {
			Message.notify('<lgcom:message code="note.completed"/>');
			/* session에  _external_parameter_ 이 있는 경우에는 이 정보를 바탕으로 url 을 새로 구성해서 그쪽으로 보내준다. */
			var targetUrl = "";

			<%
			    LGCOMMap param = (LGCOMMap)session.getAttribute("_external_parameter_");
			    if( param != null ) {
			    	StringBuilder extParam = new StringBuilder();
			    	extParam.append( param.getString("target") + "?" );

		    		Iterator<String> it = param.keySet().iterator();
		    		int inx = 0;
		    		while( it.hasNext() ) {
		    			String key = it.next();
		    			if( inx == 0 ) {
		    				extParam.append( key + "=" + param.getString(key) );
		    			} else {
		    				extParam.append("&" + key + "=" + param.getString(key) );
		    			}
		    			inx++;
		    		}

		    		out.println( " targetUrl = \"" + extParam.toString() + "\";");
		    		session.removeAttribute("_external_parameter_");
			    }
			%>

			if( targetUrl == "" ) {
				/* 그 이외의 모든 경우에는 메인 페이지로 이동한다. */
				var nav = new Navigate( "lgcom" , "main");
				nav.goGet();
			} else {
				document.location.href = "/lgcom" + targetUrl;
			}
		});
	}
	// 사용자 세션을 생성한다.
	function fncCreateUserSession() {
		transaction_sync('lgcom','region/createSSOUserSession',userData,function(data) {
			var nav = new Navigate('lgcom','main');
			nav.goGet();
		});
	}
	// Region 영역 초기화
	function fncClearRegion() {
		// Region 목록 삭제
		$('.dataBlock1 form table tbody').empty();
		// Check Box 체크 해제
		$(".dataBlock1 form div#regionFlagShow input[name='requestRegionCodeUseFlag']").prop('checked',false);
		// Default OU Label 삭제
		$('.pageContent>table.layout>tbody>tr:nth-child(2)>td:first-child').empty();
	}
	// OrgUnit 영역 초기화
	function fncClearOrgUnit() {
		// Region 목록 삭제
		$('.dataBlock2 form table tbody').empty();
		// Check Box 체크 해제
		$(".dataBlock2 form div#regionFlagShow input[name='defaultOrgIdUseFlag']").prop('checked',false);
		// Default OU Label 삭제
		$('.pageContent>table.layout>tbody>tr:nth-child(2)>td:nth-child(3)').empty();
	}
	// Default Org 영역 쓰기
	function fncWriteDefaultOrg(data) {
		if(typeof(data) == 'undefined') data = userData;
		var labelCell = $('.pageContent>table.layout>tbody>tr:nth-child(2)>td:nth-child(1)');
		labelCell.empty();
		if($.trim(data.defaultOrgCode) != '' || $.trim(data.defaultOrgName) != '') {
			var dispLabel = $('<div></div>');
			dispLabel.addClass('default_ou');
			var lblText = '<lgcom:message code="DefaultOrg"/> :';
			if($.trim(data.defaultOrgCode) != '' && $.trim(data.defaultOrgName) != '') {
				lblText += ' [' + $.trim(data.defaultOrgCode) + '] ' + $.trim(data.defaultOrgName);
			} else if($.trim(data.defaultOrgCode) == '' && $.trim(data.defaultOrgName) != '') {
				lblText += ' ' + $.trim(data.defaultOrgName);
			} else if($.trim(data.defaultOrgCode) != '' && $.trim(data.defaultOrgName) == '') {
				lblText += ' ' + $.trim(data.defaultOrgCode);
			}
			var lblObj = $('<label></label>');
			lblObj.text(lblText);
			dispLabel.append(lblObj);
			labelCell.append(dispLabel);
		}
	}
	// Default Region 영역 쓰기
	function fncWriteDefaultRegion(data) {
		if(typeof(data) == 'undefined') data = userData;
		var labelCell = $('.pageContent>table.layout>tbody>tr:nth-child(2)>td:nth-child(3)');
		labelCell.empty();
		if($.trim(data.requestRegionCode) != '' || $.trim(data.requestRegionName) != '') {
			var dispLabel = $('<div></div>');
			dispLabel.addClass('default_rgn');
			var lblText = '<lgcom:message code="DefaultRegion"/> :';
			if($.trim(data.requestRegionCode) != '' && $.trim(data.requestRegionName) != '') {
				lblText += ' [' + $.trim(data.requestRegionCode) + '] ' + $.trim(data.requestRegionName);
			} else if($.trim(data.requestRegionCode) == '' && $.trim(data.requestRegionName) != '') {
				lblText += ' ' + $.trim(data.requestRegionName);
			} else if($.trim(data.requestRegionCode) != '' && $.trim(data.requestRegionName) == '') {
				lblText += ' ' + $.trim(data.requestRegionCode);
			}
			var lblObj = $('<label></label>');
			lblObj.text(lblText);
			dispLabel.append(lblObj);
			labelCell.append(dispLabel);
		}
	}
	// 현재 보이는 테이블 셀의 개수를 계산해서 저장버튼 영역을 처라한다.
	function fncProcessSaveButton() {
		// 전체 테이블 셀의 수를 계산해서 버튼 영역 조절
		var cellLen = 0;
		$('.pageContent>table.layout>tbody>tr:first-child>td').each(function() {
			if($(this).css('display') != 'none') cellLen++;
		});
		if(cellLen == 1) {
			$('.pageContent>table.layout>tbody>tr:nth-child(3)>td:first-child').removeAttr('colspan');
		} else if(cellLen > 1) {
			$('.pageContent>table.layout>tbody>tr:nth-child(3)>td:first-child').attr('colspan',cellLen);
		}
		$('.pageContent>table.layout>tbody>tr:nth-child(3)>td:first-child').show();
	}
}

$(document).ready(function() {
	var form = new Region();
	form.init();
});
</script>
</head>

<body>
<header class="navbar navbar-fixed-top navbar-default navbar-inverse">
	<div class="container">
		<div class="navbar-header _logo">
			<h1><a class="navbar-brand"><span class="site">WCFW</span></a></h1>
		</div>
	</div>
</header>
<div class="pageContent">
	<table class="layout">
		<tbody>
			<tr>
				<td>
					<div class="dataBlock1">
						<div class="sub-header">
							<h4><lgcom:message code="TimezoneSetting"/></h4>
						</div>
						<form class="form" method="post">
							<table class="table table-bordered table-condensed">
								<colgroup>
									<col width="34"/>
									<col width="400"/>
								</colgroup>
								<thead>
									<tr>
										<th colspan="2"><lgcom:message code="Region"/></th>
									</tr>
								</thead>
								<tbody>
								</tbody>
							</table>
							<div id="regionFlagShow" class="checkbox checkbox-uxp checkbox-inline">
								<input type="checkbox" id="requestRegionCodeUseFlag" name="requestRegionCodeUseFlag"/>
								<label for="requestRegionCodeUseFlag"><lgcom:message code="DoNotAskAgn"/></label>
							</div>
						</form>
					</div>
				</td>
				<td width="50">&nbsp;</td>
				<td>
					<div class="dataBlock2">
						<div class="sub-header">
							<h4><lgcom:message code="DefaultOUSetting"/></h4>
						</div>
						<form class="form" method="post">
							<table class="table table-bordered table-condensed">
								<colgroup>
									<col width="34"/>
									<col width="220"/>
								</colgroup>
								<thead>
									<tr>
										<th colspan="2"><lgcom:message code="OperatingUnit"/></th>
									</tr>
								</thead>
								<tbody>
								</tbody>
							</table>
							<div id="orgUnitFlagShow" class="checkbox checkbox-uxp checkbox-inline">
								<input type="checkbox" id="defaultOrgIdUseFlag" name="defaultOrgIdUseFlag"/>
								<label for="defaultOrgIdUseFlag"><lgcom:message code="DoNotAskAgn"/></label>
							</div>
						</form>
					</div>
				</td>
			</tr>
			<tr>
				<td></td>
				<td></td>
				<td></td>
			</tr>
			<tr>
				<td colspan="3" class="btnLaout"><button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="ok"/></button></td>
			</tr>
		</tbody>
	</table>
</div>
</body>
</html>