<%@ page import="java.util.Comparator"%>
<%@ page import="java.util.List"%>
<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn"    uri="http://java.sun.com/jsp/jstl/functions"%>

<jsp:useBean id="date" class="java.util.Date" />
<fmt:formatDate value="${date}" pattern="yyyy" var="currentYear" />

<%---------------------------------------------------------
    파일명 : LGVATT30094.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2024 LG CNS,  All rights reserved..

    설 명 : Shift Change History
    작성자 : Kim Biho
-------------------------------------------------------------%>
<c:set var="ui_bizform_id" value="${param.bizFormId}" />
<c:set var="flg_vn_att_master" value="N"/>
<c:forEach var="roles" items="${sessionScope.USER_SESSION.roleList}">
    <c:if test="${roles.systemCode=='LGVHR' && roles.moduleCode=='LGVATT' && fn:indexOf(roles.roleCode,'VN_ATT_MASTER_USER')>=0 }">
        <c:set var="flg_vn_att_master" value="Y"/>
    </c:if>   
</c:forEach>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script type="text/javascript">
var LGVATT30094 = function() {
	var myForm = this;
	var _this = this;
	
	// Form Util 선언
	var searchForm = new FormUtil(myForm, '.search-wrap');
	var gridContent = new FormUtil(myForm,'.gridContent form');
	
	/*팝업관련*/
	myForm.popupInfo = {
        userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', attDate:'', userData:[]},
        returnPopup : {returnComment:''}
    };
	
	myForm.popupInfoOrg = {
	        orgPopup   : {searchMode:'single', popupKind:'', confirmKind:'', orgName:'',orgCode:'', orgData:[]},
	        returnPopup : {returnComment:''}
	};
	
	myForm.setLayout( [ 
		{ name : "searchBlock", left : 0, right : 0, top : 0 },
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
	]);
	
	// 그리드 선언
	var grid = buildGrid('.shiftChangeHistory');

	//날짜 설정
	var $date = myForm.select(".searchBlock input[name='attDate']");
	$date.val(setYesterday(DateUtil.today("DD/MM/YYYY")));
	
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	formUtil.setCalendar( { from : "attDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
	
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	search();

	function processUserPopup() {
    	var _popup = _this.popupInfo.userPopup;
        
    	var grid1 = grid.getGridBase();
    	
    	_popup.searchMode   = "single";
        _popup.popupKind    = "";
        _popup.confirmKind  = "";
        _popup.employeeNo = '';
        _popup.employeeName = '';
        _popup.attDate = '';

        var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
        popup.setSize(800,494);
        popup.open( function(){
        
	        grid1.setValue(grid1.getCurrent().itemIndex,'employeeNumber',_popup.userData[0].employeeNo);
	        grid1.setValue(grid1.getCurrent().itemIndex,'fullNameLocal',_popup.userData[0].employeeName);
	        grid1.commit();
	        
        });
        _popup.userData = [];
    }
    
    
    function processOrgPopup() {
    	var _popup = _this.popupInfoOrg.orgPopup;
        
    	var grid1 = grid.getGridBase();
    	
    	_popup.searchMode   = "single";
        _popup.popupKind    = "";
        _popup.confirmKind  = "";
        _popup.orgName = "";
        
        var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1014', 'Search Org' );
        popup.setSize(800,494);
        popup.open( function(){
        	grid1.setValue(grid1.getCurrent().itemIndex,'organizationId',_popup.orgData[0].organizationId);
            grid1.setValue(grid1.getCurrent().itemIndex,'organizationCode',_popup.orgData[0].organizationCode);
            grid1.setValue(grid1.getCurrent().itemIndex,'orgNameLocal',_popup.orgData[0].organizationName);
            grid1.commit();
            
        });
        _popup.orgData = [];
    }
	
	myForm.addEvent('submit', searchForm, function(event) {
        event.preventDefault();
    });
	
	myForm.addEvent('click','button[data-action]',function(event) {
		var action = $(this).data("action");	
		switch(action) {
			//검색
			case 'search' :
				search();
				break;
			//조직 검색 팝업
		    case "openPopupOrg" :
                var _popup = _this.popupInfoOrg.orgPopup;
                _popup.searchMode   = "single";
                _popup.popupKind    = "";
                _popup.confirmKind  = "";
                _popup.orgName = formUtil.getValue("orgName");
                
                var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1014', 'Search Org' );
                popup.setSize(800,494);
                popup.open( function(){
                    formUtil.setValue({orgName  :_popup.orgData[0].organizationName});
                    formUtil.setValue({orgCode  :_popup.orgData[0].organizationCode});
                    formUtil.setValue({orgId  :_popup.orgData[0].organizationId});
                });
                _popup.orgData = [];
                break;
			//유저 검색 팝업
		    case "openPopupApprover" :
                var _popup = _this.popupInfo.userPopup;
                _popup.searchMode   = "single";
                _popup.popupKind    = "PIC";
                _popup.confirmKind  = "";
                _popup.employeeNo = formUtil.getValue("employeeNo");
                _popup.employeeName = formUtil.getValue("employeeName");
                _popup.attDate = formUtil.getValue("attDate");

                var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
                popup.setSize(800,494);
                popup.open( function(){
                    formUtil.setValue({employeeNo  :_popup.userData[0].employeeNo});
                    formUtil.setValue({employeeName   :_popup.userData[0].employeeName});
                });
                _popup.userData = [];
                break;
		}
	});
	/***  내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		
		//필드 설정
		grid.setFields([
		    { fieldName: 'employeeNo'					, dataType:'text'},
		    { fieldName: 'fullNameEnglish'  			, dataType:'text'},
		    { fieldName: 'orgNameEng'  					, dataType:'text'},
		    { fieldName: 'timeAndAttendanceDate'		, dataType:'text'},
		    { fieldName: 'shiftTypeCode'				, dataType:'text'},
		    { fieldName: 'aDayOfTheWeekCode'			, dataType:'text'},
		    { fieldName: 'resNightShiftFlag'			, dataType:'text'},
		    { fieldName: 'checkInDate'					, dataType:'text'},
		    { fieldName: 'checkOutDate'					, dataType:'text'},
		    { fieldName: 'timeAndAttendanceCode'		, dataType:'text'},
		    { fieldName: 'resTimeAndAttendanceCode'		, dataType:'text'},
		    { fieldName: 'workStartTime'				, dataType:'text'},
		    { fieldName: 'workStartDatetime'			, dataType:'text'},
		    { fieldName: 'inTimeOverYn'					, dataType:'text'},
		    { fieldName: 'workEndDatetime'				, dataType:'text'}
		]);
		// Lookup 설정
		grid.setLookupsMultiLvl({
		});

		//컬럼 설정
		grid.setColumns([
				{
					name:'employeeNo',
					fieldName:'employeeNo',
					width:100,
					header: {text:'<lgcom:message code="label.att.employeeNo" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'fullNameEnglish',
					fieldName:'fullNameEnglish',
					width:130,
					header: {text:'<lgcom:message code="label.att.employeeEngName"/>'},
					styles: {textAlignment:'near'},
					editable : false
				},
				{
					name:'orgNameEng',
					fieldName:'orgNameEng',
					width:180,
					header: {text:'<lgcom:message code="label.att.orgNameEng" />'},
					styles: {textAlignment:'near'},
					editable : false
				},
				{
					name:'timeAndAttendanceDate',
					fieldName:'timeAndAttendanceDate',
					width:170,
					header: {text:'<lgcom:message code="label.att.timeAndAttendanceDate" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'shiftTypeCode',
					fieldName:'shiftTypeCode',
					width:40,
					header: {text:'<lgcom:message code="label.att.shiftTypeCode" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'aDayOfTheWeekCode',
					fieldName:'aDayOfTheWeekCode',
					width:80,
					header: {text:'<lgcom:message code="label.att.aDayOfTheWeekCode" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'resNightShiftFlag',
					fieldName:'resNightShiftFlag',
					width:100,
					header: {text:'<lgcom:message code="label.att.resNightShiftFlag" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'checkInDate',
					fieldName:'checkInDate',
					width:140,
					header: {text:'<lgcom:message code="label.att.checkInDate" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'checkOutDate',
					fieldName:'checkOutDate',
					width:140,
					header: {text:'<lgcom:message code="label.att.checkOutDate" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'timeAndAttendanceCode',
					fieldName:'timeAndAttendanceCode',
					width:150,
					header: {text:'<lgcom:message code="label.att.TimeAndAttendanceCode" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'resTimeAndAttendanceCode',
					fieldName:'resTimeAndAttendanceCode',
					width:150,
					header: {text:'<lgcom:message code="label.att.resTimeAndAttendanceCode" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'workStartTime',
					fieldName:'workStartTime',
					width:100,
					header: {text:'<lgcom:message code="label.att.workStartTime" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'workStartDatetime',
					fieldName:'workStartDatetime',
					width:170,
					header: {text:'<lgcom:message code="label.att.workStartDatetime" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'inTimeOverYn',
					fieldName:'inTimeOverYn',
					width:80,
					header: {text:'<lgcom:message code="label.att.inTimeOverYn" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'workEndDatetime',
					fieldName:'workEndDatetime',
					width:170,
					header: {text:'<lgcom:message code="label.att.workEndDatetime" />'},
					styles: {textAlignment:'center'},
					editable : false
				}
		]);
		//옵션 설정
		grid.setOptions({
			grid: {
				softDeleting: true,
				deleteCreated: true,
				hideDeletedRows:true,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:false},
				footer: {visible:false},
				paste: {enabled:false}, /*paste 기능막기 */
				sorting  : {enabled:false}, /*Sorting 기능을 막는다.*/
                sortMode : "explicit",
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
				}
			},
			dataProvider: {
				insertable: true,
				updatable: true,
				deletable: true,
				softDeleting: true,
				deleteCreated: true
			}
		});
		
		// Context Menu Set
		grid.setContextMenu();

		return grid;
	}
	
	//내일 날짜 구하기
	function setTomorrow(date){
		var selectDate = date.split("/");
		var changeDate = new Date();
		
		changeDate.setFullYear(selectDate[2], selectDate[1]-1, selectDate[0]-1+2);
		
		var y = changeDate.getFullYear();
		var m = changeDate.getMonth() + 1;
		var d = changeDate.getDate();
		if(m < 10)    { m = "0" + m; }
		if(d < 10)    { d = "0" + d; }
		
		var resultDate = d + '/' + m + '/' + y;
		return resultDate;
	}
	
	//어제 날짜 구하기
	function setYesterday(date){
		var selectDate = date.split("/");
		var changeDate = new Date();
		
		changeDate.setFullYear(selectDate[2], selectDate[1]-1, selectDate[0]-1);
		
		var y = changeDate.getFullYear();
		var m = changeDate.getMonth() + 1;
		var d = changeDate.getDate();
		if(m < 10)    { m = "0" + m; }
		if(d < 10)    { d = "0" + d; }
		
		var resultDate = d + '/' + m + '/' + y;
		return resultDate;
	}
	
	function search() {
		var param = searchForm.getValue();
		
		if(formUtil.getValue('employeeNo') == ''){
			param.employeeNo = '';
			
            formUtil.setValue({employeeName   :''});
		}
		if(formUtil.getValue('orgName') == ''){
			param.orgId = '';
		}
		
		grid.loadData('lgvhr','lgvatt/LGVATT30094/retrieveShiftChangeHistory', param);

	}
}
LGVATT30094.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVATT30094();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2></h2> 
		</div>
		<div class="searchBlock">
			<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="90"/>
						<col width="220"/>
						<col width="60"/>
						<col width="*"/>
					</colgroup>
					<tbody>
						<tr>
		                    <th><label><i class="asterisk">*</i><lgcom:message code="label.att.date" /></label></th>
		                    <td>
								<span class="form-inline">
								    <input type="text" class="form-control input-sm input-require" name="attDate" placeholder="dd/mm/yyyy" readonly>
								    <button type="button" id="setSingleDateSample" class="btn btn-ico" aria-label="calendar">
								        <span class="ico ico-calendar" aria-hidden="true"></span>
								    </button>
								</span>
							</td>
							<input class="form-control input-sm _find_origin_" name="orgCode" type="hidden">
							<input class="form-control input-sm _find_origin_" name="orgId" type="hidden">
							
							<th><label><lgcom:message code="label.att.organization" /></label></th>
		                    <td>
		                         <div class="input-group input-group-sm input-search">
	                                <input class="form-control input-sm _find_origin_" name="orgName" type="text" data-action="emptyAndPopup">
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupOrg">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
		                    </td>
							
							<th><label><lgcom:message code="label.att.employeeNo2" /></label></th>
							<td>
		                		<div class="input-group input-group-sm input-search">
	                                <input class="form-control input-sm _find_origin_" name="employeeNo" type="text" data-action="emptyAndPopup">
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupApprover">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
		                	</td>
		                	
		                	<th><label><lgcom:message code="label.att.employeeName" /></label></th>
							<td><input type="text" class="form-control input-sm" name="employeeName"></td>
		                	
		                </tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>

		<div class="gridContent grid-wrap">
			<div class="grid shiftChangeHistory"></div>
		</div>
	</section>
</div>
</body>
</html>
