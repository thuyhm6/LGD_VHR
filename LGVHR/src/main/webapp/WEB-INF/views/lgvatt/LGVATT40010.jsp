<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT40010.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 결재자가이 사무직 일근태 계획 및 실적을 결재하는 화면입니다.
    작성자 : 임수진
    HMT_20210319     Add Popup - Alarming working hours
-------------------------------------------------------------%>

<c:set var="flg_vn_org_manager" value="N"/>
<c:forEach var="roles" items="${sessionScope.USER_SESSION.roleList}">
    <c:if test="${roles.systemCode=='LGVHR' && roles.moduleCode=='LGVATT' && fn:indexOf(roles.roleCode,'VN_ORG_MANAGER')>=0 }">
        <c:set var="flg_vn_org_manager" value="Y"/>
    </c:if>
</c:forEach>

<html lang="ko">
<head>
<title><lgcom:message code="label.att.dailyApproval"/></title>
<style type="text/css">
._approvalPopupWindow ._commentWindowBack {
	background-color : black;
	opacity : 0.3;
	position : fixed;
	top:0px;
	bottom : 0px;
	rifht : 0px;
	left : 0px;
	z-index : 500;
	display :none;
}

._approvalPopupWindow  ._commentWindow  {
	width : 493px;
	height : 156px;
	position : fixed;
	top : 100px;
	left : calc( 50% - 246px);
	overflow : hidden;
	box-shadow: 2px 2px 4px rgba(0,0,0,.5);
	z-index : 510;
	border: 0px solid transparent;
	display:none;
}

._approvalPopupWindow  ._commentWindow .panel-heading {
	padding : 5px 10px;
	cursor : move;
	background-color : #474751;
	color : #FFFFFF;
}

._approvalPopupWindow  ._commentWindow .panel-footer {
	padding : 5px 10px;
	background-color : #FFFFFF;
}

._approvalPopupWindow  ._commentWindow .panel-footer .btn {
	width : 50px;
}

._approvalPopupWindow  ._commentWindow .panel-heading h3 {
	font-size : 12px;
	font-weight : bold;
}

._approvalPopupWindow  ._commentWindow .panel-body {
	padding : 5px 5px 1px 5px;
}

._approvalPopupWindow  ._commentWindow  ._comment {
	width : 480px;
	height : 84px;
	resize: none;
}
.holidayOption { 
	color: #F34D78; /* 일요일, 공휴일, 휴무일 */
}
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVATT40010 = function() {
	var myForm = this;
	var srchForm = '.searchBlock form';
	// Form Util 선언
	var srchFormUtil = new FormUtil( myForm, ".searchBlock form" );
	var isOrgMng = ('<c:out value="${flg_vn_org_manager}"/>' == 'Y')?true:false;
	
	var popupAlarm = new Popup(myForm,'lgvhr','M_LGVATT_1062','<lgcom:message code="label.att.workingHourCompliance"/>' ); //HMT_20210319
	popupAlarm.setSize( 800, 300 );
	popupAlarm.open( function(){
    }, function(){
    });
	
	<%--2018.03.12 [베트남 급여근태 고도화] Let's 직접 호출 허용되는지 여부 처리--%>
	<c:choose>
	<c:when test="${ param.container eq 'Y' and param.letsFg eq 'Y' and not empty param.aprSt }">	
	<%-- 2018.03.12 [베트남 급여근태 고도화] 근태실적 결재건 유무 조회. Let's에서 직접 호출되는 경우 실적 결재건 있는 경우만 팝업 띄워주기 위함 --%>		
	myForm.transaction("lgvhr", "lgvatt/LGVATT40010/retireveDirectOpenData", { container:"<c:out value="${param.container}"/>", letsFg:"<c:out value="${param.letsFg}"/>", aprSt:"<c:out value="${param.aprSt}"/>"}, function(data) {
		//팝업호출 불가능한 상태인 경우 창 닫기 
		if ( data.result && nvl(data.result.popupOpenFlag) == "Y" ) {
             var popup = new Popup( myForm, "lgcom", "<c:out value="${menuId}"/>", $("._pageTitle").text() );
             popup.setSize( 1600, 920 );
             popup.openWindow( function(){}, function(){} );
		}
	});
	</c:when>
	<%--2018.03.12 [베트남 급여근태 고도화] Let's 직접 호출 허용되는지 여부 처리--%>
	<c:otherwise>

    // 화면 레이아웃 정의(달력 그린 후 레이아웃 지정하기 위해 마지막에 수행함.)
	myForm.setLayout( [ 
		{ name : "searchBlock"        , left : 0, right : 0, top : 0 },
	    { name : "buttonControls"     , left : 0, right : 0, top : "searchBlock", bottom : "gridContent1" },
	    { name : "requestorSubTitle"  , left : 0, right : 0, height: 20, top : "buttonControls", bottom : "gridContent1" },
	    { name : "gridContent1"       , left : 0, right : 0, top : "requestorSubTitle", bottom : "unRequestorSubTitle" }, 
	    { name : "unRequestorSubTitle", left : 0, right : 0, height: 20, bottom : "gridContent2" },
	    { name : "gridContent2"       , left : 0, right : 0, height: 300, bottom : 0 }
	]);

	$("._commentWindow").draggable();
	
	/* 팝업용 변수 선언 */
	myForm.popupInfo = {
		editAttendancePopup: { searchMode:'single', employeeNo:'', employeeName:'', attendanceDate:'', gridType:'', popupData:[] }
	};
	
	if(isOrgMng) {
		myForm.select("button[data-action=goList]").show();
	} else {
		myForm.select("button[data-action=goList]").hide();
	}
	
    //2018.03.12 [베트남 급여근태 고도화] Let's 직접 호출 허용되는지 여부 처리로직 추가됨에 따라 Let's 직접 호출 아닌 경우만 처리되도록 한다.
    <c:if test="${ not (param.container eq 'Y' and param.letsFg eq 'Y') }">
    //화면 초기데이터 조회
    fncRetrieveInitData();
    </c:if>

    // 그리드선언
	var grid = buildGrid(".approvalGrid"); // 요청자 그리드
	var grid2 = buildGrid(".unRequestorGrid"); // 비 요청자 그리드

    // 개인화조건
    
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)

    // 그리드형 테이블 TR
    
    // 코드 데이터 조회
    var code = new CommonCode("lgcom");
    code.add("approvalStatusList", {codeTypeCode:"LGVHR_ATT_APPROVAL_STATUS"});
    code.execute();

    //결재상태 콤보 셋팅
    srchFormUtil.initCombo("approvaStatusCode", code.get("approvalStatusList"), {selectAll:true});

    // 날짜 팝업창
    
    // 필수항목 체크
   	var validator = new Validator( myForm, srchForm );

    validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	    	planYyyymmdd: {required:true}
	    },
	    messages: {
	    	planYyyymmdd: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.planDate'/>" />'}
	    }
    });

    // 일반함수	
    
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}                                                                                                                                                                                                                                             
		var action = $.trim(item.data('action'));
		switch( action ){
			case "search" :
				if ( validator.isValid() ) {
					fncRetrieveApprovalList();
				}
				break;
			case 'goList' :
				var nav = new Navigate( myForm, "lgvhr", "M_LGVATT_1056" );
		        nav.addNavigationCallback( function( caller ){
		            myForm.select("button[data-action=search]").trigger('click');
		        });
		        nav.goPageInCurrentDiv(false);
				break;
			case "ok":
				//이 버튼 자체를 Disable 처리 한다.
				$(item).prop("disabled", true);

				//승인 버튼 구역의 모든 버튼을 잠금 처리한다.
				myForm.select(".buttonControls button" ).prop("disabled", true);

				var action = myForm.select("._commentWindow").data("action");
				var type = myForm.select("._commentWindow").data("type");
				var comment = myForm.select("._commentWindow ._comment").val();

				//comment 에 입력한 내용이 없을 때에는 자동으로 지정된 메세지를 추가한다.
				if( comment == "" ) {
					if( type == 'APPROVAL') {
						comment = "OK";
					} else if( type == 'REJECT') {
						comment = "Rejected";
					}
					myForm.select("._commentWindow ._comment").val( comment );
				}

				if( type == 'APPROVAL') {
					myForm.showProgress();
					fncSaveApproval();
				} else if( type == 'REJECT') {
					myForm.showProgress();
					fncSaveReject();
				}
				$(item).removeAttr("disabled");

				hideCommentWindow();
				$(".buttonControls button" ).removeAttr("disabled");
				break;
			case "cancel":
				//$("._commentWindow").modal("hide");
				hideCommentWindow();
				break;
			case "approval" :
				if( grid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				
				//선택된 행이 있는지 체크
				var checkeds = grid.getGridBase().getCheckedItems();
				if ( !checkeds || checkeds.length == 0 ) {
					Message.alert("<lgcom:message code="note.noselected"/>");
					return ;
				}				
				
				var action = $(event.target).data("action");
				myForm.select("._commentWindow").data("action", action);
				myForm.select("._commentWindow").data("type", action.toUpperCase());
				myForm.select("._commentWindow .actionName").text("Approval");
				myForm.select("._commentWindow ._comment").val("");
				
				showCommentWindow();
				break;
			case "reject" :
				if( grid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				
				//선택된 행이 있는지 체크
				var checkeds = grid.getGridBase().getCheckedItems();
				if ( !checkeds || checkeds.length == 0 ) {
					Message.alert("<lgcom:message code="note.noselected"/>");
					return ;
				}
				
				var action = $(event.target).data("action");
				myForm.select("._commentWindow").data("action", action);
				myForm.select("._commentWindow").data("type", action.toUpperCase());
				myForm.select("._commentWindow .actionName").text("Reject");
				myForm.select("._commentWindow ._comment").val("");

				showCommentWindow();
				break;
		}
		event.stopPropagation();
	});
    //계획일자 또는 결재상태 변경인 경우
	myForm.addEvent( "change", ".searchBlock .form select[name=planYyyymmdd], select[name=approvaStatusCode]" , function(event) {
		//클릭이벤트 호출
		myForm.select(".searchBlock button[data-action='search']").trigger('click');
		event.stopPropagation();
	});
    
	/*** 내부 함수  ***/
	// 결재목록 조회
	function fncRetrieveApprovalList() {
		var borderColor = '#474751,3';
		grid.getGridBase().addCellStyle("borderStyle", {
			borderBottom: borderColor
		});
		grid2.getGridBase().addCellStyle("borderStyle", {
			borderBottom: borderColor
		});
		var controlColumns = {	                      
           	 bottomColumn : ["attendanceCodePlan","overtimeHoursPlan","inputReasonPlan", "inTimeResult", "outTimeResult","attendanceCodeResult", 
           	               "workHoursResult", "overtimeHoursResult", "nightOvertimeHoursResult", "nightHoursResult", "inputReasonResult"] /* borderBottom 디자인될 컬럼명 */
            };
		
		grid.getGridBase().cancel();
		grid2.getGridBase().cancel();
		
		var planYyyymmdd = srchFormUtil.getValue("planYyyymmdd");
		var resultYyyymmdd = DateUtil.addDays(DateUtil.parse(planYyyymmdd, "DDMMYYYY"), -1, "DDMMYYYY");
		//헤더명 변경(실적/계획 날짜 (요일명))
		grid.getGridBase().setColumnProperty("result", "header", { text: "<lgcom:message code='label.att.actual'/> " + DateUtil.format(DateUtil.parse(resultYyyymmdd, "DDMMYYYY"), "DD/MM/YYYY") + " ("+ DateUtil.format(DateUtil.parse(resultYyyymmdd, "DDMMYYYY"), "ddd")+")" });
		grid.getGridBase().setColumnProperty("plan",   "header", { text: "<lgcom:message code='label.att.plan'/> " + DateUtil.format(DateUtil.parse(planYyyymmdd, "DDMMYYYY"), "DD/MM/YYYY") + " ("+ DateUtil.format(DateUtil.parse(planYyyymmdd, "DDMMYYYY"), "ddd")+")" });
		grid2.getGridBase().setColumnProperty("result", "header", { text: "<lgcom:message code='label.att.actual'/> " + DateUtil.format(DateUtil.parse(resultYyyymmdd, "DDMMYYYY"), "DD/MM/YYYY") + " ("+ DateUtil.format(DateUtil.parse(resultYyyymmdd, "DDMMYYYY"), "ddd")+")" });
		grid2.getGridBase().setColumnProperty("plan",   "header", { text: "<lgcom:message code='label.att.plan'/> " + DateUtil.format(DateUtil.parse(planYyyymmdd, "DDMMYYYY"), "DD/MM/YYYY") + " ("+ DateUtil.format(DateUtil.parse(planYyyymmdd, "DDMMYYYY"), "ddd")+")" });
		
		var totalCnt = 0;
		var reqCnt = 0;
		var unReqCnt = 0;
		var apprvFirstCnt = 0;
		var apprvFinalCnt = 0;
		
		grid.loadData("lgvhr", "lgvatt/LGVATT40010/retrieveDailyAttendanceApprovalList", srchFormUtil.getValue(), function(data) {
			//결재가능 여부 조회
			fncRetrieveApprovalEnableTimeCheck();
			// 2017.12.13 LHJ // 데이터 있을 경우 result, plan 구분을 위한 border style 지정 
			if( data.result.length > 0 ) {
				grid.getGridBase().setColumnProperty("result", "header", {styles: { borderLeft: borderColor, borderTop: borderColor, borderRight: borderColor } });
				grid.getGridBase().setColumnProperty("plan", "header", {styles: { borderTop: borderColor, borderRight: borderColor } });
				grid.getGridBase().setColumnProperty("inTimeResult", "header", {styles: { borderLeft: borderColor } });
				grid.getGridBase().setColumnProperty("inTimeResult", "styles", { borderLeft: borderColor });
				grid.getGridBase().setColumnProperty("inputReasonPlan", "header", {styles: { borderRight: borderColor } });
				grid.getGridBase().setColumnProperty("inputReasonPlan", "styles", { borderRight: borderColor });
				grid.getGridBase().setColumnProperty("inputReasonResult", "header", {styles: { borderRight: borderColor } });
				grid.getGridBase().setColumnProperty("inputReasonResult", "styles", { borderRight: borderColor });
				grid.getGridBase().setCellStyles(data.result.length-1, controlColumns.bottomColumn, "borderStyle", true);
			}
			
			for(var i=0; i<data.result.length; i++) {
				if(data.result[i]["approvalStatus"].indexOf("1st") > -1) {
					apprvFirstCnt++;
				} else if(data.result[i]["approvalStatus"].indexOf("Final") > -1) {
					apprvFinalCnt++;
				}
			}
			
			reqCnt = data.result.length;
			
			grid2.loadData("lgvhr", "lgvatt/LGVATT40010/retrieveDailyAttendanceUnRequestorList", srchFormUtil.getValue(), function(data) {
				// 2017.12.13 LHJ // 데이터 있을 경우 result, plan 구분을 위한 border style 지정 
				if( data.result.length > 0 ) {
					grid2.getGridBase().setColumnProperty("result", "header", {styles: { borderLeft: borderColor, borderTop: borderColor, borderRight: borderColor } });
					grid2.getGridBase().setColumnProperty("plan", "header", {styles: { borderTop: borderColor, borderRight: borderColor } });
					grid2.getGridBase().setColumnProperty("inTimeResult", "header", {styles: { borderLeft: borderColor } });
					grid2.getGridBase().setColumnProperty("inTimeResult", "styles", { borderLeft: borderColor });
					grid2.getGridBase().setColumnProperty("inputReasonPlan", "header", {styles: { borderRight: borderColor } });
					grid2.getGridBase().setColumnProperty("inputReasonPlan", "styles", { borderRight: borderColor });
					grid2.getGridBase().setColumnProperty("inputReasonResult", "header", {styles: { borderRight: borderColor } });
					grid2.getGridBase().setColumnProperty("inputReasonResult", "styles", { borderRight: borderColor });
					grid2.getGridBase().setCellStyles(data.result.length-1, controlColumns.bottomColumn, "borderStyle", true);
				}
				
				unReqCnt = data.result.length;
				totalCnt = reqCnt + unReqCnt;
				
				var requestorCntDiv = myForm.select(".requestorSubTitle");
				var unRequestorCntDiv = myForm.select(".unRequestorSubTitle");
				
				if(isNull(srchFormUtil.getValue("approvaStatusCode"))) {
					$(".requestorSubTitle *").remove();
					$(requestorCntDiv).append("<span style='font-weight: bold; font-size: 12pt;'>" + "<lgcom:message code='Total'/>" + " : " + totalCnt + 
											", " + "<lgcom:message code='Requested'/>" + " : " + reqCnt + 
											", 1st " + "<lgcom:message code='label.att.Approved'/>" + " : " + apprvFirstCnt + 
											", " + "<lgcom:message code='Final'/>" + " " + "<lgcom:message code='label.att.Approved'/>" + " : " + apprvFinalCnt + 
										  "</span>");
				} else {
					$(".requestorSubTitle *").remove();
					$(requestorCntDiv).append("<h3>" + "<lgcom:message code='label.att.requestor'/>" + "</h3>");
				}
				
				$(".unRequestorSubTitle *").remove();
				$(unRequestorCntDiv).append("<span style='font-weight: bold; font-size: 12pt;'>" + "<lgcom:message code='label.att.nonRequested'/>" + " : " + unReqCnt + "</span>");
				
			});
		});

	}
	// 결재가능 일자 및 시간인지 조회
	function fncRetrieveApprovalEnableTimeCheck() {
		var planYyyymmdd = srchFormUtil.getValue("planYyyymmdd");
		myForm.transaction("lgvhr", "lgvatt/LGVATT40010/retrieveApprovalEnableTimeCheck", { yyyymmdd : planYyyymmdd }, function(data) {
			if ( data.result ) {
				if ( nvl(data.result.approvalEnableFlag) == "Y" ) {//결재가능 인 경우만 버튼 활성화
					myForm.select(".buttonControls button[data-action]" ).prop("disabled", false);
				}
			}
		});
	}
	
    // 그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);

		//필드 설정
		grid.setFields([
			{ fieldName:'employeeNo',                 dataType:'text'},
			{ fieldName:'employeeName',               dataType:'text'},
			{ fieldName:'organizationName',           dataType:'text'},
			{ fieldName:'gradeTitle',                 dataType:'text'},
			{ fieldName:'gradeTitleName',             dataType:'text'},
			{ fieldName:'attendanceYyyymmddPlan',     dataType:'text'},
			{ fieldName:'attendanceCodePlan',         dataType:'text'},
			{ fieldName:'overtimeHoursPlan',          dataType:'number'},
			{ fieldName:'eveningMealFlagPlan',        dataType:'text'},
			{ fieldName:'inputReasonPlan',            dataType:'text'},
			{ fieldName:'attendanceNamePlan',         dataType:'text'},
			{ fieldName:'attendanceDetailCodePlan',   dataType:'text'},
			{ fieldName:'attendanceDetailNamePlan',   dataType:'text'},
			{ fieldName:'attendanceYyyymmddResult',   dataType:'text'},
			{ fieldName:'inTimeResult',               dataType:'text'},
			{ fieldName:'outTimeResult',              dataType:'text'},
			{ fieldName:'attendanceCodeResult',       dataType:'text'},
			{ fieldName:'attendanceNameResult',       dataType:'text'},
			{ fieldName:'attendanceDetailCodeResult', dataType:'text'},
			{ fieldName:'attendanceDetailNameResult', dataType:'text'},
			{ fieldName:'workHoursResult',            dataType:'text'},
			{ fieldName:'overtimeHoursResult',        dataType:'number'},
			{ fieldName:'nightOvertimeHoursResult',   dataType:'number'},
			{ fieldName:'nightHoursResult',           dataType:'number'},
			{ fieldName:'inputReasonResult',          dataType:'text'},
			{ fieldName:'attendanceNameResult',       dataType:'text'},
			{ fieldName:'attendanceDetailCodeResult', dataType:'text'},
			{ fieldName:'attendanceDetailNameResult', dataType:'text'},
			{ fieldName:'eveningMealFlagResult',      dataType:'text'},

			{ fieldName:'tardyHoursResult',           dataType:'text'},
			{ fieldName:'earlyLeaveHoursResult',      dataType:'text'},
			{ fieldName:'goingOutHoursResult',        dataType:'text'},
			
			{ fieldName:'weekdayOvertimeHours',       dataType:'text'},
			{ fieldName:'holidayOvertimeHours',       dataType:'text'},
			{ fieldName:'publicHolidayOvertimeHours', dataType:'text'},
			
			{ fieldName:'weekdayNightOvertimeHours',  dataType:'text'},
			{ fieldName:'weekdayOtAfNightWorkHours',  dataType:'text'},
			{ fieldName:'holidayNightOvertimeHours',  dataType:'text'},
			{ fieldName:'publicHolidayNightOtHours',  dataType:'text'},
			
			{ fieldName:'waitFlagPlan',               dataType:'text'},
			{ fieldName:'waitFlagResult',             dataType:'text'},
			{ fieldName:'requestMasterIdPlan',        dataType:'text'},
			{ fieldName:'requestMasterIdResult',      dataType:'text'},
			{ fieldName:'requestCodePlan',            dataType:'text'},
			{ fieldName:'requestCodeResult',          dataType:'text'},
			{ fieldName:'approvalStatus',             dataType:'text'},
			{ fieldName:'lastUpdatedBy',              dataType:'text'},
			{ fieldName:'inOutTimeRedFlagResult',     dataType:'text'},
			{ fieldName:'approverCntPlan',            dataType:'text'},
			{ fieldName:'approvalComment1Plan',       dataType:'text'},
			{ fieldName:'approvalComment2Plan',       dataType:'text'},
			{ fieldName:'approverCntResult',          dataType:'text'},
			{ fieldName:'approvalComment1Result',     dataType:'text'},
			{ fieldName:'approvalComment2Result',     dataType:'text'}
		]);
		/* Grid 컬럼 생성 */
		
		if(gridId == ".approvalGrid") {
			grid.setColumns([
				{
					name:'employeeNo',
					fieldName:'employeeNo',
					width:70,
					header: {text:'<lgcom:message code="EmployeeNo"/>'},
					styles: {textAlignment:'center'},
					editable: false
				},
				{
					name:'employeeName',
					fieldName:'employeeName',
					width:100,
					header: {text:'<lgcom:message code="EmployeeName"/>'},
					styles: {textAlignment:'near'},
					editable: false
				},
				{
					name:'organizationName',
					fieldName:'organizationName',
					width:100,
					header: {text:'<lgcom:message code="label.att.organization"/>'},
					styles: {textAlignment:'near'},
					editable: false
				},
				{
					name:'gradeTitleName',
					fieldName:'gradeTitleName',
					width:80,
					header: {text:'<lgcom:message code="label.att.jobTitle"/>'},
					styles: {textAlignment:'near'},
					editable: false
				},
				{	type:'group',
					name:'result',
					fieldName:'result',
					width:470,
					header:{
				         text:'<lgcom:message code="label.att.actual" /> '
				    },
					orientation:'horizontal',
					columns: [
								{
									name:'inTimeResult',
									fieldName:'inTimeResult',
									width:50,
									header: {text:'<lgcom:message code="label.att.inTime"/>'},
									styles: {textAlignment:'center'},
									editable: false,
									dynamicStyles:[{criteria:"values['inOutTimeRedFlagResult']='Y'", styles:{foreground:"#f34d78"}}]
								},
								{
									name:'outTimeResult',
									fieldName:'outTimeResult',
									width:50,
									header: {text:'<lgcom:message code="label.att.outTime"/>'},
									styles: {textAlignment:'center'},
									editable: false,
									dynamicStyles:[{criteria:"values['inOutTimeRedFlagResult']='Y'", styles:{foreground:"#f34d78"}}]
								},
								{
									name:'attendanceCodeResult',
									fieldName:'attendanceCodeResult',
									width:60,
								    renderer: { showTooltip : true },
									header: {text:'<lgcom:message code="label.att.actualAttendance"/>'},
									styles: {textAlignment:'center'},
									editable: false
								},
								{
									name:'workHoursResult',
									fieldName:'workHoursResult',
									width:60,
								    renderer: {showTooltip: true},
									header: {text:'<lgcom:message code="label.att.normalTime"/>'},
									styles: {textAlignment:'far'},
									editable: false
								},
								{
									name:'nightHoursResult',
									fieldName:'nightHoursResult',
									width:60,
								    renderer: {showTooltip: true},
									header: {text:'<lgcom:message code="label.att.night"/>'},
									styles: {textAlignment:'far', numberFormat: '#0.0'},
									editable: false
								},
								{
									name:'overtimeHoursResult',
									fieldName:'overtimeHoursResult',
									width:60,
								    renderer: {showTooltip: true},
									header: {text:'<lgcom:message code="label.att.actualOT"/>'},
									styles: {textAlignment:'far', numberFormat: '#0.0'},
									editable: false
								},
								{
									name:'nightOvertimeHoursResult',
									fieldName:'nightOvertimeHoursResult',
									width:60,
								    renderer: {showTooltip: true},
									header: {text:'<lgcom:message code="label.att.actualOTNight"/>'},
									styles: {textAlignment:'far', numberFormat: '#0.0'},
									editable: false
								},
								{
									name:'inputReasonResult',
									fieldName:'inputReasonResult',
									width:70,
								    renderer: {showTooltip: true},
									header: {text:'<lgcom:message code="label.att.timeAttendInputReasonDesc"/>'},
									styles: {textAlignment:'near'},
									editable: false
								}
							]
				},
				{	type:'group',
					name:'plan',
					fieldName:'plan',
					width:190,
					header:{
				         text:'<lgcom:message code="label.att.plan" />'
				    },
					orientation:'horizontal',
					columns: [
								{
									name:'attendanceCodePlan',
									fieldName:'attendanceCodePlan',
									width:60,
								    renderer: {showTooltip: true},
									header: {text:'<lgcom:message code="label.att.planAttendance"/>'},
									styles: {textAlignment:'center'},
									editable: false
								},
								{
									name:'overtimeHoursPlan',
									fieldName:'overtimeHoursPlan',
									width:60,
								    renderer: {showTooltip: true},
									header: {text:'<lgcom:message code="label.att.planOT"/>'},
									styles: {textAlignment:'far', numberFormat: '#0.0'},
									editable: false
								},
								{
									name:'inputReasonPlan',
									fieldName:'inputReasonPlan',
									width:70,
								    renderer: {showTooltip: true},
									header: {text:'<lgcom:message code="label.att.timeAttendInputReasonDesc"/>'},
									styles: {textAlignment:'near'},
									editable: false
								}
							]
				},
				{
					name:'approvalStatus',
					fieldName:'approvalStatus',
					width:100,
				    renderer: {showTooltip: true},
					header: {text:'<lgcom:message code="label.att.approvalStatus"/>'},
					styles: {textAlignment:'center'},
					editable: false
				}
			]);
		} else if(gridId == ".unRequestorGrid") {
			grid.setColumns([
 				{
 					name:'employeeNo',
 					fieldName:'employeeNo',
 					width:70,
 					header: {text:'<lgcom:message code="EmployeeNo"/>'},
 					styles: {textAlignment:'center'},
 					editable: false
 				},
 				{
 					name:'employeeName',
 					fieldName:'employeeName',
 					width:100,
 					header: {text:'<lgcom:message code="EmployeeName"/>'},
 					styles: {textAlignment:'near'},
 					editable: false
 				},
 				{
 					name:'organizationName',
 					fieldName:'organizationName',
 					width:100,
 					header: {text:'<lgcom:message code="label.att.organization"/>'},
 					styles: {textAlignment:'near'},
 					editable: false
 				},
 				{
 					name:'gradeTitleName',
 					fieldName:'gradeTitleName',
 					width:80,
 					header: {text:'<lgcom:message code="label.att.jobTitle"/>'},
 					styles: {textAlignment:'near'},
 					editable: false
 				},
 				{	type:'group',
 					name:'result',
 					fieldName:'result',
 					width:470,
 					header:{
 				         text:'<lgcom:message code="label.att.actual" /> '
 				    },
 					orientation:'horizontal',
 					columns: [
 								{
 									name:'inTimeResult',
 									fieldName:'inTimeResult',
 									width:50,
 									header: {text:'<lgcom:message code="label.att.inTime"/>'},
 									styles: {textAlignment:'center'},
 									editable: false,
 									dynamicStyles:[{criteria:"values['inOutTimeRedFlagResult']='Y'", styles:{foreground:"#f34d78"}}]
 								},
 								{
 									name:'outTimeResult',
 									fieldName:'outTimeResult',
 									width:50,
 									header: {text:'<lgcom:message code="label.att.outTime"/>'},
 									styles: {textAlignment:'center'},
 									editable: false,
 									dynamicStyles:[{criteria:"values['inOutTimeRedFlagResult']='Y'", styles:{foreground:"#f34d78"}}]
 								},
 								{
 									name:'attendanceCodeResult',
 									fieldName:'attendanceCodeResult',
 									width:60,
 								    renderer: { showTooltip : true },
 									header: {text:'<lgcom:message code="label.att.actualAttendance"/>'},
 									styles: {textAlignment:'center'},
 									editable: false
 								},
 								{
 									name:'workHoursResult',
 									fieldName:'workHoursResult',
 									width:60,
 								    renderer: {showTooltip: true},
 									header: {text:'<lgcom:message code="label.att.normalTime"/>'},
 									styles: {textAlignment:'far'},
 									editable: false
 								},
 								{
 									name:'nightHoursResult',
 									fieldName:'nightHoursResult',
 									width:60,
 								    renderer: {showTooltip: true},
 									header: {text:'<lgcom:message code="label.att.night"/>'},
 									styles: {textAlignment:'far', numberFormat: '#0.0'},
 									editable: false
 								},
 								{
 									name:'overtimeHoursResult',
 									fieldName:'overtimeHoursResult',
 									width:60,
 								    renderer: {showTooltip: true},
 									header: {text:'<lgcom:message code="label.att.actualOT"/>'},
 									styles: {textAlignment:'far', numberFormat: '#0.0'},
 									editable: false
 								},
 								{
 									name:'nightOvertimeHoursResult',
 									fieldName:'nightOvertimeHoursResult',
 									width:60,
 								    renderer: {showTooltip: true},
 									header: {text:'<lgcom:message code="label.att.actualOTNight"/>'},
 									styles: {textAlignment:'far', numberFormat: '#0.0'},
 									editable: false
 								},
 								{
 									name:'inputReasonResult',
 									fieldName:'inputReasonResult',
 									width:70,
 								    renderer: {showTooltip: true},
 									header: {text:'<lgcom:message code="label.att.timeAttendInputReasonDesc"/>'},
 									styles: {textAlignment:'near'},
 									editable: false
 								}
 							]
 				},
 				{	type:'group',
 					name:'plan',
 					fieldName:'plan',
 					width:190,
 					header:{
 				         text:'<lgcom:message code="label.att.plan" />'
 				    },
 					orientation:'horizontal',
 					columns: [
 								{
 									name:'attendanceCodePlan',
 									fieldName:'attendanceCodePlan',
 									width:60,
 								    renderer: {showTooltip: true},
 									header: {text:'<lgcom:message code="label.att.planAttendance"/>'},
 									styles: {textAlignment:'center'},
 									editable: false
 								},
 								{
 									name:'overtimeHoursPlan',
 									fieldName:'overtimeHoursPlan',
 									width:60,
 								    renderer: {showTooltip: true},
 									header: {text:'<lgcom:message code="label.att.planOT"/>'},
 									styles: {textAlignment:'far', numberFormat: '#0.0'},
 									editable: false
 								},
 								{
 									name:'inputReasonPlan',
 									fieldName:'inputReasonPlan',
 									width:70,
 								    renderer: {showTooltip: true},
 									header: {text:'<lgcom:message code="label.att.timeAttendInputReasonDesc"/>'},
 									styles: {textAlignment:'near'},
 									editable: false
 								}
 							]
 				},
 				{
 					name:'lastUpdatedBy',
 					fieldName:'lastUpdatedBy',
 					width:100,
 				    renderer: {showTooltip: true},
 					header: {text:'<lgcom:message code="LastUpdatedBy"/>'},
 					styles: {textAlignment:'near'},
 					editable: false
 				}
 			]);
		}
		
		/* Grid Option 설정 */
		if(gridId == ".approvalGrid") {
			grid.setOptions({
				grid: {
					hideDeletedRows: true,
					indicator: {visible:false},
					panel    : {visible:false},
					checkBar : {visible:true, checkableExpression: "(values['waitFlagPlan'] = 'Y') or (values['waitFlagResult'] = 'Y')"},
					stateBar : {visible:false},
					footer   : {visible:false},
					paste    : { enabled: false }, /*paste 기능막기 */
	                sortMode : "explicit",
					edit: {
						insertable: false, /* INSERT 키 또는 방향키로 행삽입 불가능 */
						appendable: false, /* INSERT 키 또는 방향키로 행추가 불가능 */
						updatable: true,
						deletable: true
					},
					header: {
						height: 60, showTooltip: true
					},
					sorting: {
						enabled: false
					}
				},
				dataProvider: {
					insertable: true,
					updatable: true,
					deletable: true,
					softDeleting: true,
					deleteCreated: true
				},
				display: { fitStyle: 'evenFill' }
			});
		} else if(gridId == ".unRequestorGrid") {
			grid.setOptions({
				grid: {
					hideDeletedRows: false,
					indicator: {visible:true},
					panel    : {visible:false},
					checkBar : {visible:false},
					stateBar : {visible:false},
					footer   : {visible:false},
					paste    : { enabled: false }, /*paste 기능막기 */
	                sortMode : "explicit",
					edit: {
						insertable: false, /* INSERT 키 또는 방향키로 행삽입 불가능 */
						appendable: false, /* INSERT 키 또는 방향키로 행추가 불가능 */
						updatable: false,
						deletable: false
					},
					header: {
						height: 60, showTooltip: true
					},
					sorting: {
						enabled: false
					}
				},
				dataProvider: {
					insertable: false,
					updatable: false,
					deletable: false,
					softDeleting: false,
					deleteCreated: false
				},
				display: { fitStyle: 'evenFill' }
			});
		}	
			
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
    
    // 요청자 리스트 더블클릭 이벤트
    grid.getGridBase().onDataCellDblClicked = function(cgrid, index) {
    	if(cgrid.isCheckable(index.itemIndex)) {
	    	var _popup = myForm.popupInfo.editAttendancePopup;
	    	
	    	// 팝업에 전달할 파라메터를 세팅한다.
	    	_popup.searchMode   	= "single";
	    	_popup.gridType			= "requested";
	    	_popup.employeeNo   	= cgrid.getValue(index.itemIndex, "employeeNo");
	    	_popup.employeeName   	= cgrid.getValue(index.itemIndex, "employeeName");
	    	_popup.attendanceDate   = srchFormUtil.getValue("planYyyymmdd");
	    	
			// 팝업을 호출한다.
			var popup = new Popup(myForm,'lgvhr','M_LGVATT_1052','<lgcom:message code="label.att.dailyRegistration"/>');
			popup.setSize(1600, 400);
			popup.open(function() {
				//팝업 닫는 경우 화면 재조회
				myForm.select(".searchBlock button[data-action='search']").trigger('click');
				
				myForm.popupInfo.editAttendancePopup.popupData = [];
			}); 
    	}
    };

    // 비요청자 리스트 더블클릭 이벤트
	grid2.getGridBase().onDataCellDblClicked = function(cgrid, index) {
		var _popup = myForm.popupInfo.editAttendancePopup;
    	
    	// 팝업에 전달할 파라메터를 세팅한다.
    	_popup.searchMode   	= "single";
    	_popup.gridType			= "nonrequested";
    	_popup.employeeNo   	= cgrid.getValue(index.itemIndex, "employeeNo");
    	_popup.employeeName   	= cgrid.getValue(index.itemIndex, "employeeName");
    	_popup.attendanceDate   = srchFormUtil.getValue("planYyyymmdd");
    	
		// 팝업을 호출한다.
		var popup = new Popup(myForm,'lgvhr','M_LGVATT_1052','<lgcom:message code="label.att.dailyRegistration"/>');
		popup.setSize(1600, 400);
		popup.open(function() {
			//팝업 닫는 경우 화면 재조회
			myForm.select(".searchBlock button[data-action='search']").trigger('click');
			
			myForm.popupInfo.editAttendancePopup.popupData = [];
		});
    };
    
    //데이터셀의 툴팁이 표시될때 발생하는 콜백 함수
	grid.getGridBase().onShowTooltip = function (cgrid, index, value) {
	    var column = index.column;
	    var itemIndex = index.itemIndex;
	     
	    var tooltip = value;
	    if (column == "attendanceCodeResult") {<%-- 실적근태코드 : Attendance : 근태명 <br/> Attendance Detail : 세부근태명 <br/> Reason : 사유 --%>
	        tooltip  = isNull(cgrid.getValue(itemIndex, "attendanceNameResult"))?"":("<lgcom:message code="label.att.actualAttendance"/> : "           + nvl(cgrid.getValue(itemIndex, "attendanceNameResult")));
	        
	        tooltip += (!isNull(tooltip) && !isNull(cgrid.getValue(itemIndex, "attendanceDetailCodeResult")))?"<br/>":"";//다음 내용이 있는 경우 개행처리
	        tooltip += isNull(cgrid.getValue(itemIndex, "attendanceDetailCodeResult"))?"":("<lgcom:message code="label.att.timeAttendDetailCode"/> : " + nvl(cgrid.getValue(itemIndex, "attendanceDetailNameResult")));
	        
	        tooltip += (!isNull(tooltip) && !isNull(cgrid.getValue(itemIndex, "inputReasonResult")))?"<br/>":"";//다음 내용이 있는 경우 개행처리
	        tooltip += isNull(cgrid.getValue(itemIndex, "inputReasonResult"))?"":("<lgcom:message code="label.att.timeAttendInputReasonDesc"/> : "     + nvl(cgrid.getValue(itemIndex, "inputReasonResult")));
	        
	    } else if (column == "workHoursResult") {<%-- 근무시간 : Lateness : 지각시간 <br/> Early Leave : 조퇴시간 <br/> Going Out : 외출시간 --%>
	        tooltip  = isNull(cgrid.getValue(itemIndex, "tardyHoursResult"))?"":("<lgcom:message code="label.att.deductionLateness"/> : "          + nvl(cgrid.getValue(itemIndex, "tardyHoursResult")));
	        
	        tooltip += (!isNull(tooltip) && !isNull(cgrid.getValue(itemIndex, "earlyLeaveHoursResult")))?"<br/>":"";//다음 내용이 있는 경우 개행처리
	        tooltip += isNull(cgrid.getValue(itemIndex, "earlyLeaveHoursResult"))?"":("<lgcom:message code="label.att.deductionLeavingEarly"/> : " + nvl(cgrid.getValue(itemIndex, "earlyLeaveHoursResult")));
	        
	        tooltip += (!isNull(tooltip) && !isNull(cgrid.getValue(itemIndex, "goingOutHoursResult")))?"<br/>":"";//다음 내용이 있는 경우 개행처리
	        tooltip += isNull(cgrid.getValue(itemIndex, "goingOutHoursResult"))?"":("<lgcom:message code="label.att.deductionGoingOut"/> : "       + nvl(cgrid.getValue(itemIndex, "goingOutHoursResult")));
	        
	    } else if (column == "overtimeHoursResult") {<%-- OT : Dinner 여부 <br/> 150% : 150% OT시간 <br/> 200% : 200% OT시간 <br/> 300% : 300% OT시간 --%>
	        tooltip  = nvl(cgrid.getValue(itemIndex, "eveningMealFlagResult")) == "Y"?"<lgcom:message code="label.att.dinner"/>":""; 

	        tooltip += (!isNull(tooltip))?"<br/>":"";//다음 내용이 있는 경우 개행처리
	        tooltip += "<lgcom:message code="label.att.actualOTWeekDay2" /> : "        + nvl(cgrid.getValue(itemIndex, "weekdayOvertimeHours")) + "<br/>" +
	                   "<lgcom:message code="label.att.actualOTWeekDayHoliday2" /> : " + nvl(cgrid.getValue(itemIndex, "holidayOvertimeHours")) + "<br/>" +
	                   "<lgcom:message code="label.att.actualOTPublicHoliday2" /> : "  + nvl(cgrid.getValue(itemIndex, "publicHolidayOvertimeHours")) ;
	                  
	    } else if (column == "nightOvertimeHoursResult") {<%-- OT at Night : Dinner 여부 <br/> 200% : 200% OT시간 <br/> 210% : 210% OT시간 <br/> 270% : 270% OT시간 <br/> 390% : 390% OT시간 --%>
	        tooltip  = nvl(cgrid.getValue(itemIndex, "eveningMealFlagResult")) == "Y"?"<lgcom:message code="label.att.dinner"/>":"";

	        tooltip += (!isNull(tooltip))?"<br/>":"";//다음 내용이 있는 경우 개행처리
	        tooltip += "<lgcom:message code="label.att.actualOTNightWeekDay2" /> : "        + nvl(cgrid.getValue(itemIndex, "weekdayNightOvertimeHours")) + "<br/>" +
                       "<lgcom:message code="label.att.actualOTNightWeekDayAfterOT2" /> : " + nvl(cgrid.getValue(itemIndex, "weekdayOtAfNightWorkHours")) + "<br/>" +
                       "<lgcom:message code="label.att.actualOTNightWeekDayHoliday2" /> : " + nvl(cgrid.getValue(itemIndex, "holidayNightOvertimeHours")) + "<br/>" +
                       "<lgcom:message code="label.att.actualOTNightPublicHoliday2" /> : "  + nvl(cgrid.getValue(itemIndex, "publicHolidayNightOtHours")) ;
                      
		}  else if (column == "nightHoursResult") {<%-- Night : Dinner 여부 <br/> 30% : 30% OT시간 --%>
	        tooltip  = nvl(cgrid.getValue(itemIndex, "eveningMealFlagResult")) == "Y"?"<lgcom:message code="label.att.dinner"/>":"";
	        
	        tooltip += (!isNull(tooltip))?"<br/>":"";//다음 내용이 있는 경우 개행처리
	        tooltip += isNull(value)?"":("<lgcom:message code="label.att.nightNormal2" /> : " + nvl(value));
	        
		} else if (column == "attendanceCodePlan") {<%-- 계획근태코드 : Attendance : 근태명 <br/> Attendance Detail : 세부근태명 --%>
	        tooltip  = isNull(cgrid.getValue(itemIndex, "attendanceNamePlan"))?"":("<lgcom:message code="label.att.planAttendance"/> : " + nvl(cgrid.getValue(itemIndex, "attendanceNamePlan")));

	        tooltip += (!isNull(tooltip) && !isNull(cgrid.getValue(itemIndex, "attendanceDetailCodePlan")))?"<br/>":"";//다음 내용이 있는 경우 개행처리
	        tooltip += isNull(cgrid.getValue(itemIndex, "attendanceDetailCodePlan"))?"":("<lgcom:message code="label.att.timeAttendDetailCode"/> : " + nvl(cgrid.getValue(itemIndex, "attendanceDetailNamePlan"))) ;

	    } else if (column == "overtimeHoursPlan") {<%-- OT : Dinner 여부 <br/> OT : OT시간 --%>
	        tooltip  = nvl(cgrid.getValue(itemIndex, "eveningMealFlagPlan")) == "Y"?"<lgcom:message code="label.att.dinner"/>":"";

	        tooltip += (!isNull(tooltip))?"<br/>":"";//다음 내용이 있는 경우 개행처리
	        tooltip += isNull(value)?"":("<lgcom:message code="label.att.planOT" /> : " + nvl(value));
	        
		} else if (column == "approvalStatus") {<%-- 결재상태 : 결재상태 <br/> 결재의견 --%>
			tooltip  = nvl(cgrid.getValue(itemIndex, "approvalStatus"));
			var reasonText = "";

	        if ( Number(nvl(cgrid.getValue(itemIndex, "approverCntResult"))) < 2 ) {//결재자가 한명인 경우
	        	reasonText = nvl(cgrid.getValue(itemIndex, "approvalComment1Result"),  cgrid.getValue(itemIndex, "approvalComment2Result"));
	        
	        } else if ( Number(nvl(cgrid.getValue(itemIndex, "approverCntResult"))) >= 2 ) {//결재자가 한명인 경우
	        	if ( !isNull(cgrid.getValue(itemIndex, "approvalComment1Result")) ) {
	        		reasonText = '-' + nvl(cgrid.getValue(itemIndex, "approvalComment1Result"));
	        	}

	        	if ( !isNull(cgrid.getValue(itemIndex, "approvalComment2Result")) ) {
	        		reasonText += (!isNull(reasonText))?"<br/>":"";
	        		reasonText += '-' + nvl(cgrid.getValue(itemIndex, "approvalComment2Result"));
	        	}
	        }
	        
	        if ( !isNull(reasonText) ) {
		        tooltip += (!isNull(tooltip))?"<br/>":"";//다음 내용이 있는 경우 개행처리
	        	tooltip += "<lgcom:message code="Comment" /><br/>" + reasonText;
	        }
		}
	    return tooltip;
	}	
    //승인
    function fncSaveApproval( ) {
		/* 복수 레코드 정리 */
		var approvalList = [];
		var dataProvider = grid.getDataProvider();
		try{
			var checkeds = grid.getGridBase().getCheckedRows(false);//정렬된 순서로 index 가져오기
			for ( var i=0; i< checkeds.length; i++ ) {
				approvalList.push(dataProvider.getJsonRow(checkeds[i]));
			}
		} catch( e ) {
			trace( e );
		}
		
		if ( approvalList.length == 0 ) {
			Message.alert('<lgcom:message code="note.nodata"/>');
			return ;
		}
		
		//최종 저장소에 데이터 보내기
		var param = {};
		var infoData = {};
		infoData = $.extend(infoData, srchFormUtil.getValue());
		infoData = $.extend(infoData, { comment : myForm.select("._commentWindow ._comment").val() });

		param["infoData"] = infoData;
		param["approvalList"] = approvalList;
		
		myForm.showProgress();
		myForm.transaction("lgvhr", "lgvatt/LGVATT40010/saveApproval", param, function( data ){
			myForm.hideProgress();
			Message.alert( "<lgcom:message code="note.com.successfullyApproved"/>" );
			grid.getGridBase().setAllCheck(false);//헤더의 체크표시 비활성화 처리
			//클릭이벤트 호출
			myForm.select(".searchBlock button[data-action='search']").trigger('click');
		});
    }
    
    //반려
    function fncSaveReject() {
		/* 복수 레코드 정리 */
		var approvalList = [];
		var dataProvider = grid.getDataProvider();
		try{
			var checkeds = grid.getGridBase().getCheckedRows(false);//정렬된 순서로 index 가져오기
			for ( var i=0; i< checkeds.length; i++ ) {
				approvalList.push(dataProvider.getJsonRow(checkeds[i]));
			}
		} catch( e ) {
			trace( e );
		}
		
		if ( approvalList.length == 0 ) {
			Message.alert('<lgcom:message code="note.nodata"/>');
			return ;
		}

		//최종 저장소에 데이터 보내기
		var param = {};
		var infoData = {};
		infoData = $.extend(infoData, srchFormUtil.getValue());
		infoData = $.extend(infoData, { comment : myForm.select("._commentWindow ._comment").val() });
		
		param["infoData"] = infoData;
		param["approvalList"] = approvalList;
		
		myForm.showProgress();
		myForm.transaction("lgvhr", "lgvatt/LGVATT40010/saveReject", param, function( data ){
			myForm.hideProgress();
			Message.alert( "<lgcom:message code="note.com.rejected"/>" );
			grid.getGridBase().setAllCheck(false);//헤더의 체크표시 비활성화 처리
			//클릭이벤트 호출
			myForm.select(".searchBlock button[data-action='search']").trigger('click');
		});
    }
    
	//결재의견 레이어 팝업 보여주기
    function showCommentWindow() {
    	myForm.select(".buttonControls button[data-action]" ).prop("disabled", true);
    	$("._approvalPopupWindow ._commentWindow button[action='ok']").removeAttr("disabled");
    	$("._approvalPopupWindow ._commentWindowBack").show();
    	$("._approvalPopupWindow ._commentWindow").show();
    }
	
	//결재의견 레이어 팝업 숨기기
    function hideCommentWindow() {
    	myForm.select(".buttonControls button[data-action]" ).prop("disabled", false);
    	$("._approvalPopupWindow ._commentWindow button[action='ok']").removeAttr("disabled");
    	$("._approvalPopupWindow ._commentWindowBack").hide();
    	$("._approvalPopupWindow ._commentWindow").hide();
    }
	
	//2018.03.12 [베트남 급여근태 고도화] 화면 초기데이터 조회 (데이터 조회 전 체크 로직 추가하기 위해 함수로 분리)
	function fncRetrieveInitData() {

	    // 화면에 필요한 초기데이터 조회
	    var oCombo = myForm.select("select[name=planYyyymmdd]");
	    myForm.transaction("lgvhr", "lgvatt/LGVATT40010/retrieveInitData", {}, function(data) {
	    	var planDateList = data.result.planDateList;
	        //계획근태일자 콤보 셋팅(휴일인 경우 글자 색상 변경하기 위해 공통 initCombo 사용하지 않고 option생성하여 셋팅함)
			$(planDateList).each( function(){
				var optClassName = "", resultText = "", planText = "", spaceText = "";
				
				if ( this["holidayFlagResult"] == "Y" || this["holidayFlagPlan"] == "Y" ) {//실적 또는 계획일자가  휴일인 경우
					//optClassName = "holidayOption";//휴일이 아닌 일자까지 색상 적용되므로, 색깔 지정한 부분 주석 처리 함.
					optClassName = "";
				}
				
				resultText = "<lgcom:message code="label.att.actual"/> " + this["resultYmd"] + " " + "(" + this["resultDy"] + ")" ;
				planText = "<lgcom:message code="label.att.plan"/> " + this["planYmd"] + " " + "(" + this["planDy"] + ")";
				
				//요일명에 따라 공백이 다르기 때문에 강제 공백 추가
				switch ( nvl(this["resultDy"],"").toUpperCase() ) {
					case "FRI" : spaceText = "&nbsp;&nbsp;&nbsp;";break;
					case "SAT" : spaceText = "&nbsp;&nbsp;"; break;
					case "SUN" : spaceText = "&nbsp;"; break;
					case "TUE" : spaceText = "&nbsp;"; break;
					case "THU" : spaceText = "&nbsp;"; break;
					default : spaceText = ""; break;
				}
				
				$(oCombo).append("<option value='"+ this["code"] +"' class='"+optClassName+"' >"+ resultText + ", " + spaceText + planText +"</option>");
			});
	        
			if ( data.result.planDateList && data.result.planDateList.length > 0 ) {
				//계획근태일자 목록 중 첫번째(오늘날짜)를 기본값으로 셋팅한다.
	        	srchFormUtil.setValue({ planYyyymmdd:DateUtil.today("DDMMYYYY") });
	            
	            //결재목록 조회
	        	fncRetrieveApprovalList();
			}
	    });
	}
	
	//화면로딩 시 결재의견 레이어 팝업 숨김
    hideCommentWindow();
	</c:otherwise>
	</c:choose>
}

LGVATT40010.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT40010();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.att.dailyApproval"/></h2>
		</div>
		<%-- 2018.03.12 [베트남 급여근태 고도화] Let's 링크 아닌 경우만 body 보여줌 --%>
		<c:if test="${ empty param.letsFg }">
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<table class="table" >
					<colgroup>
						<col width="10%"></col>
						<col width="32%"></col>
						<col width="15%"></col>
						<col width="15%"></col>
						<col width=*"></col>
					</colgroup>
					<tbody>
						<tr>
		                    <th scope="col"><label class="required" keyword><lgcom:message code="label.att.date" /></label></th>
		                    <td><select class="form-control input-sm input-require" name="planYyyymmdd" ></select></td>
							<th scope="col"><label><lgcom:message code="label.att.approvalStatus"/></label></th>
							<td><select class="form-control input-sm input-require" name="approvaStatusCode" ></select></td>
							<td></td>
						</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- 버튼 --%>
		<div class="buttonControls module-group text-right">
			<div class="btn-group">
			    <p class="form-control-static"><small class="text-gray approvalWarningMsg" style="display:none;"></small></p>
			</div>
			<div class="btn-group">
				<button class="btn btn-default btn-sm" type="submit" data-action="goList"><lgcom:message code="label.att.allMemList"/></button>
				<button class="btn btn-darkgray btn-sm" type="button" data-action="approval" disabled><lgcom:message code="Approval"/></button>
				<button class="btn btn-darkgray btn-sm" type="button" data-action="reject" disabled><lgcom:message code="Reject"/></button>
			</div>
		</div>
		
		<div class="sub-header requestorSubTitle"><h3><lgcom:message code="label.att.requestor"/></h3></div>
		<%-- 결재목록 --%>
		<div class="gridContent1 grid-wrap">
			<div class="grid approvalGrid"></div>
		</div>
		
		<div class="sub-header unRequestorSubTitle"><h3><lgcom:message code="label.att.nonRequested"/></h3></div>
		<%-- 비요청자목록 --%>
		<div class="gridContent2 grid-wrap">
			<div class="grid unRequestorGrid"></div>
		</div>

		<%-- Comment 입력 부분(approval.jsp 참고하여 작성함) --%>
		<div class="_approvalPopupWindow">
			<div class="_commentWindowBack"></div>
			<div class="panel panel-default _commentWindow" role="dialog" >
				<div class="panel-heading">
					<h3 class="panel-title"><span class="actionName"></span> <lgcom:message code="Comment" /></h3>
				</div>
				<div class="panel-body">
					<textarea class="_comment input-require form-control input-sm"></textarea>
				</div>
				<div class="panel-footer">
					<div class="gridControls" style="margin:0px;">
						<button class="btn btn-darkgray btn-xs" data-action="ok" ><lgcom:message code="Ok"/></button>
						<button class="btn btn-gray btn-xs"  data-action="cancel"><lgcom:message code="Cancel"/></button>
					</div>
				</div>
			</div>
		</div>
		</c:if>
		
	</section>
</div>
</body>
</html>
