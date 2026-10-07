<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"     uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT20450.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

    Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : Long Term Plan생성
    작성자 : bakderia
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Long Term 등록</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script src="/lgvhr/static/js/gibberish-aes.js"></script>
<style type="text/css">
input[type=text]::-ms-clear{
	display:none;
}
</style>
<script type="text/javascript">
var LGVATT20450 = function() {
	var grid;
	var myForm = this;
	var key = "abcdefghijklmnopqrstuvwxyz123456";
	
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'form.detailInfo');
	var approvalInfoFormUtil = new FormUtil(myForm, "form.approvalInfo");//결재자정보
	var subsidiaryCode = '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}';
	var employmentCategoryCode = '${sessionScope.LGVHR_PROJECT_SESSION.employmentCategoryCode}';
	var mode = "VIEW";
	var employeeSize = 0;
	
	// 조회조건 Combo 초기화
	var code = new CommonCode('lgvhr');
	code.add('attendanceMaster',{codeTypeCode:'LGVHR_ATTENDANCE_TYPE_CODE'});
	code.execute();
	
	//Attendance Type combo
	var valueSet = new ValueSet("lgcom");
	valueSet.add('attendanceType', {valueSetId : 'LGVATT_ATTEND_TYPE'});
	valueSet.execute(); 
	
	formUtil.initCombo("attendanceMaster",valueSet.get("attendanceType"));
	$("#attendanceMaster").prepend("<option value=''>Select</option>");
	$("#attendanceMaster option:eq(0)").prop("selected", true); 
	
	//Detail Reason disable
	myForm.select("select[name='attendanceDetailLower']").hide();
	//myForm.select("select[name='viewEmployeeNo']").hide();
	
	myForm.popupInfo = {
        userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', userId:'', employeeNo:'', employeeName:'', userData:[]},
        returnPopup : {returnComment:''}
	};
	
	//현재 날짜 가져오기
	//var date = new Date().toISOString().substr(0,10).replace('T',' ');
	var date = new Date();
	var year = date.getFullYear();
	var month = date.getMonth()+1;
	var day = date.getDate();
	
	if(("" + month).length == 1){month = "0" + month;}
	if(("" + day).length == 1){day = "0" + day;}
	
	var dateVal = day+"/"+month+"/"+year;
	
	formUtil.setValue({requestToDay : dateVal});	
	
	/************************************************************
	 화면 각 구역에 할당돼 있는 Form 에 대해서 Form Util을 선언
	************************************************************/
	var generalInfo  = new FormUtil(myForm, "form.generalInfo");
	
	//캘린더
	formUtil.setCalendar( { from : "planStartDate", to : "planEndDate", language:SESSION_USER.languageCode , format : "DD/MM/YYYY" } );
	
	myForm.setLayout( [ 
		{ name : "gridControls", left : 0, right : 10, top : 0 }
	]);
	
	/*** 콤보박스 체인지 이벤트  ***/
	this.addEvent('change',"select[data-action='attendanceMaster']",function(event) {
		$("#daylimit").val("");
		$("#attendanceDetailLower").val("0");
		myForm.select("select[name='attendanceDetailLower']").hide();
		transaction_sync("lgvhr", "lgvatt/LGVATT20450/retrieveAttendanceList", {timeAttendTypeName:formUtil.getValue("attendanceMaster")}, function(data){
			formUtil.initCombo("attendanceDetail", data.result);
			
			$("#attendanceDetail").prepend("<option value=''>Select</option>");
			$("#attendanceDetail option:eq(0)").prop("selected", true);
		});
	});
	
	this.addEvent('change',"select[data-action='attendanceDetail']",function(event) {
		transaction_sync("lgvhr", "lgvatt/LGVATT20450/retrieveAttendanceDetailList", {detailCode:formUtil.getValue("attendanceDetail")}, function(data){
			formUtil.initCombo("attendanceDetailLower", data.result);
			
			if(data.result != ""){
				myForm.select("select[name='attendanceDetailLower']").show();
				$("#attendanceDetailLower").prepend("<option value=''>Select</option>");
				$("#attendanceDetailLower option:eq(0)").prop("selected", true);
			}else{
				$("#attendanceDetailLower option:eq(0)").remove();
				myForm.select("select[name='attendanceDetailLower']").hide();
				myForm.select("select[name='attendanceDetailLower']").append("<option value=''></option>");
			}
			$("#thirdSize").val(Number($("#attendanceDetailLower option").size()));
		});
	});
	
	this.addEvent('change',"select[data-action='attendanceDetailLower']",function(event) {
		$("#daylimit").val("");
		var attendanceDetailLower = formUtil.getValue("attendanceDetailLower");
		if(!isNull(attendanceDetailLower)) {
			transaction_sync("lgvhr", "lgvatt/LGVATT20450/retrieveAttendanceDetailMessage", {commonCode:attendanceDetailLower}, function(data){
				//Detail Reason이 있을경우 등록된 메세지 보여줌.
				if(data.result.messageYn == "Y"){
					Message.alert(data.result.message);
					$("#daylimit").val(data.result.daylimit);
	        	}else{
	        		$("#daylimit").val("");
	        	} 
			});
		}
	});
	
	
	/*특정한 키를 중심으로 포도송이를 레코드 형태로 바꿔주는 함수 */
	function arrangeMultiLine( data, key ) {
		var arr = [];

		if( typeof data[key] == "string" ) {
			var result = {};
			$.each( data, function( key, value){
				result[key] = value;
			});
			arr.push( result );
		} else {
			$( data[key] ).each( function( inx ){
				var result = {};
				$.each( data, function( key, value){
					result[key] = value[inx];
				});
				arr.push( result );
			});
		}
		return arr;
	}
	
	myForm.addEvent( "click", "button[data-action]", function(event){
		var item = $(event.target);
		if( item.is("span") ) {
			item = $(item).closest("button");
		}
		var action = $(item).data("action");

		switch( action ) {
		
		case "save" :
			savePlan();
			break;
			
		case "goList" :
			var nav = new Navigate( myForm, "lgvhr", "M_LGVATT_1019" );
	        nav.addNavigationCallback( function( caller ){
	            myForm.select("button[data-action=search]").trigger('click');
	        });
	        nav.goPageInCurrentDiv(false);
		break;
		
		case "resetRows":
			var target = $(item).data("target");
			if( target == "approvalInfoTable" ) {
				myForm.select( "." + target + " tbody tr.ARM_N" ).remove();
				reFncRencRetrieveARMInfo();
			}
			manageButton();
			break;
			
		case "insertRowTop":
			if( $(item).data( "target" ) == "approvalInfoTable" ) {
				myForm.popupInfo.userPopup = { searchMode : "single"};
				var popup = new Popup( myForm, "lgcom", "M_LGUTLC_1142", "Approver" );
				popup.setSize( 1000, 528 );
				popup.open( function(){
					var result = myForm.popupInfo.userPopup.userData;
					if( result != undefined ) {
						if(  myForm.select( "." + $(item).data( "target" ) + " tbody tr" ).length == 0  ) {
							appendTableRow( $(item).data( "target" ), result[0] );
						} else {
							appendTableRow( $(item).data( "target" ), result[0], myForm.select( "." + $(item).data( "target" ) + " tbody tr:first-child"), -1 );
						}
					}
				});
			}
			break;
			case "addApprover" : 
				myForm.popupInfo.userPopup = { searchMode : "single"};
				var popup = new Popup( myForm, "lgcom", "M_LGUTLC_1142", "Approver" );
				popup.setSize( 1000, 528 );
				popup.open( function(){
					var result = myForm.popupInfo.userPopup.userData;
					if( result != undefined ) {
						appendTableRow( $(item).data( "target" ), result[0], $(item).closest("tr") );
					}
				});
				break;
	
			case "deleteApprover" :
				$(item).closest("tr").remove();
				manageButton();
			break;
			
			// 유저 검색 팝업
		    case "openPopupApprover" :
                console.log("openPopupApprover");
                var _popup = myForm.popupInfo.userPopup;
                _popup.searchMode   = "single";
                _popup.popupKind    = "PIC";
                _popup.confirmKind  = "";
                _popup.employeeNo = formUtil.getValue("employeeNo");

                var popup = new Popup( myForm,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
                popup.setSize(800,494);
                popup.open( function(){
                    formUtil.setValue({employeeNo  :_popup.userData[0].employeeNo});
                    formUtil.setValue({employeeName   :_popup.userData[0].employeeName});
                    
                    if(!isNull(_popup.userData[0].employeeNo)) {
                    	myForm.select(".approvalInfoTable tbody tr").remove();
                		
                		approvalInfoFormUtil.clear();
                		$("#employeeNo").val(_popup.userData[0].employeeNo);
                        fncRetrieveARMInfo(_popup.userData[0].employeeNo);
                    }
                });
                _popup.userData = [];
                break;
		}
	});
	function savePlan() {
		//셀렉트 박스 선택여부 확인
		var thirdSize = Number($("#attendanceDetailLower option").size());
		var dateFrom = $("#regPlanStartDate").val();
		var dateTo = $("#regPlanEndDate").val();
		var requestToDay = $("#requestToDay").val();
		var message = "";
		/*********************** 날짜 관련 체크 **************************/
		if(isNull(dateFrom)) {
			Message.alert("<lgcom:message code="note.att.checkPlanDate"/>");
			return;
		}else{
			if(!isValidDate(dateFrom)) {
				Message.alert("<lgcom:message code="note.att.checkPlanDate"/>");
				return;
			}
		}
		if(isNull(dateTo)) {
			Message.alert("<lgcom:message code="note.att.checkPlanDate"/>");
			return;
		}else{
			if(!isValidDate(dateTo)) {
				Message.alert("<lgcom:message code="note.att.checkPlanDate"/>");
				return;
			}
		}
		//계획시작일자가 오늘 이후 일 경우만 등록가능하게 처리
		if(!checkInputDate(dateFrom, requestToDay)) {
			Message.alert("<lgcom:message code="note.checkStartPlanDate"/>");
			return;
		}
		//계획시작일자가 종료일자 이후일때 체크
		if(!isValidDateBetween(dateFrom, dateTo)) {
			Message.alert("<lgcom:message code="note.att.checkPlanDate"/>.");
			return;
		}
		if($("#employeeSize") > 1) {
			if(isNull($("#employeeNo").val())) {
				Message.alert("<lgcom:message code="note.att.emptyEmployee"/>");
				return;
			}
		}
		/********************************************************************/
		if(isNull($("#attendanceMaster").val())) {
			Message.alert("<lgcom:message code="note.att.checkSelectAttendanceType"/>");
			return;
		}
		if(isNull($("#attendanceDetail").val())) {
			Message.alert("<lgcom:message code="note.att.emptyAttendance"/>");
			return;
		}
		if(isNull($("#attendanceDetailLower").val())) {
			if(thirdSize > 1) {
				$("#attendanceDetailLower").val(thirdSize);
				Message.alert("<lgcom:message code="note.att.emptyAttendanceDetailReason"/>");
				return;
			}
		}
		if(isNull($("#reason").val())) {
			Message.alert("<lgcom:message code="note.att.checkInputReason"/>");
			return;
		}
		
		//결재자 체크
		if( myForm.select(".approvalInfoTable tr.ARM_Y").length == 0 ) {
			Message.alert("<lgcom:message code="note.att.emptyApprover"/>");
			return;
		}
		Message.confirm( '<lgcom:message code="question.save"/>', function() {
			message = checkInputData();
			
			if(message != "") {
				Message.alert(message);
			}else{
				saveRequestInfo(true); 
			}
		});
	}
 	function regCheck() {
		var employeeNo = $("#employeeNo").val();
		var dateFrom = $("#regPlanStartDate").val();
		var dateTo = $("#regPlanEndDate").val();
		
		var result = true;
		//기등록된 일정이 있는지 체크
		myForm.transaction_sync("lgvhr", "lgvatt/LGVATT20450/retrievePlanChk", {planStartDate:dateFrom, planEndDate:dateTo, employeeNo:employeeNo, subsidiaryCode:'LGDVN'} , function( data ){
			if(data.result.cnt > 0) {
				Message.alert("<lgcom:message code="note.att.regPlanCheck" />");
				result = false;
			}
		});
		return result;
	} 
	//입력날짜 사이의 일수 계산
	function fncRetrieveWorkDay(dateFrom, dateTo) {
		myForm.transaction("lgvhr", "lgvatt/LGVATT20450/retrieveWorkDay", {planStartDate:dateFrom, planEndDate:dateTo}, function( data ){
			var workDay = data.result.workDay;
			
			$("#workDay").val(workDay);

		});
	}
		
	//계획시작일에 대한 계획종료일 조회
	function fncRetrieveTodate(dateFrom, dateTo, workDay) {
		var result = true;
		var employee = formUtil.getValue("employee");
		myForm.transaction_sync("lgvhr", "lgvatt/LGVATT20450/retrieveTodate", {planStartDate:dateFrom, workDay:workDay, employee:employee}, function( data ){
			var getDate = data.result.toDate;
			
			if(dateTo.replaceAll("/","") != getDate.replaceAll("-","")) {
				//alert("날짜가 같지 않음 : ");
				Message.alert("<lgcom:message code="note.att.checkPlanDate"/>");
				result = false;
			}
		});
		return result;
	}
			
	//하위 부서원 조회
	function fncRetrieveLowerEmployeeList() {
		myForm.transaction_sync("lgvhr", "lgvatt/LGVATT20450/retrieveLowerEmpolyeeList", {}, function( data ){
			var employeeList = data["result"];
			var empNo = "";
			
			//하위 부서원이 있을경우만 selectbox 
			if(data.result[0]["employeeSize"] > 0){
				$("#searchEmpNo").show();
				$("#showEmployeeName").hide();
				$("#showEmployeeNo").hide();
				$("#empList").show();
			}else{
				$("#empList").hide();
				$("#showEmployeeName").show();
				$("#showEmployeeNo").show();
				$("#searchEmpNo").hide();
				
				//하위부서원이 없을경우 사번은 세션값
				$("#employeeNo").val("${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}");
				//재량권 조회
				fncRetrieveARMInfo("${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}");
			}
			
			//$("#employeeSize").val(Number($("#employee option").size()));
			$("#employeeSize").val(data.result[0]["employeeSize"]);
			//$("#employee").prepend("<option value=''>Select</option>");
			//$("#employee option:eq(0)").prop("selected", true);
		});
		
	} 
	fncRetrieveLowerEmployeeList();	
	
	//하위부서원 선택에 따른 재량권 재조회
	this.addEvent('change',"select[data-action='employee']",function(event) {
		//Approval 영역의 초기상태를 두고, 모두 지운다.
		myForm.select(".approvalInfoTable tbody tr").remove();
		
		approvalInfoFormUtil.clear();
		$("#employeeNo").val(formUtil.getValue("employee"));

		//재량권 조회
		fncRetrieveARMInfo(formUtil.getValue("employee"));
	});
	
	//재량권 조회
	function fncRetrieveARMInfo(employeeNo) {
		var armNo = null;
		/* 재랑권 번호 추출 함수  */
		myForm.transaction_sync("lgvhr", "lgvatt/LGVATT20450/retrieveRequestDocBaseInfo", {} , function( data ){
			armNo = data.result.armNo;
		});
		if(isNull(armNo)) {
			return;
		}else{
			/* 재랑권 정보 조회. parameter[armNo:재량권번호]  */
			myForm.transaction("lgvhr", "lgvatt/LGVATTCOMM/retrieveARMInfo", {armNo:armNo, employeeNo:employeeNo} , function( data ){
				var list = data["result"];
				myForm.select(".approvalInfoTable tbody").empty();
				$(list).each( function(){
					this["settlementDeleteFlag"] = "Y";
					appendTableRow( "approvalInfoTable", this );
				});
			});
		}
	}
	//재량권 재조회
	function reFncRencRetrieveARMInfo() {
		fncRetrieveARMInfo($("#employeeNo").val());
	}
	//행추가
	function appendTableRow( target, item, appendTarget, direction ) {
		if( direction == undefined ) {
			direction = 1;
		}

		var disabled = "";
		if(mode == "VIEW") {
			disabled = "disabled";
		}

		var userName = item["employeeName"] + " / " + nvl(item["titleName"]) + " / " +item["departmentName"] ;
		var mendator = nvl( item["mendatorEmployeeName"] ) + " / " + nvl( nvl(item["mendatorTitleName"]) ) + " / " + nvl( item["mendatorDepartmentName"] ) ;

		if( mendator.trim() == "/  /" ) {
			mendator = "";
		}
		if( item["settlementDeleteFlag"] == undefined ) {
			item["settlementDeleteFlag"] = "N";
		}
		var employeeNo = AES_Encode(item["employeeNo"]);
		
		if( target == "approvalInfoTable" ) {
			var body = myForm.select(".approvalInfoTable tbody");
			//이미 이 안에 추가된 경우에는 추가하지 않고 끝
			if( body.find("input[name='applicationUserId'][value='" + item["userId"] + "']").exists() ) {
				Message.alert( item["employeeName"] + "<lgcom:message code="note.accountAlreadyExists"/>" );
				return;
			}
			
			var selectText = "<lgcom:message code="label.att.approval"/>";
			selectText    += "<input type='hidden' name='approvalActionCode' value='APPROVAL' />";

			var str = "<tr class='ARM_"+ item["settlementDeleteFlag"] +"'>"+
			          "<td class='text-center'>" + ( $(body).find("tr").length + 1 ) + "</td>"+
			          "<td class='text-center'>"+ selectText +"</td>"+
			          "<td>"+ userName +
			          "<input type='hidden' name='applicationUserId' value='"+ item["employeeId"] +"' />"+
			          "<input type='hidden' name='positionName' value='"+ nvl(item["positionName"]) +"' />"+
			          "<input type='hidden' name='lineType' value='APPROVER' />"+
			          //"<input type='hidden' name='employeeNo' value='"+ item["employeeNo"] +"' />"+
			          "<input type='hidden' name='employeeNo' value='"+ employeeNo +"' />"+
			          "<input type='hidden' name='settlementDeleteFlag' value='"+ item["settlementDeleteFlag"] +"' />"+
			          "</td>"+
			          "<td>"+ mendator + " <input type='hidden' name='menDatorApplicationUserId' value='"+ nvl(item["mandatorUserId"]) +"' /><input type='hidden' name='menDatorAemployeeNo' value='"+ nvl(item["mandatorEmployeeNo"]) +"' /></td>"+
			          "<td>"+
			          "<button class='icon-plus pointer' data-action='addApprover' data-target='approvalInfoTable'></button>";
			
			if(item["settlementDeleteFlag"] == 'N') {
				str += "<button class='icon-trash pointer' data-action='deleteApprover' data-target='approvalInfoTable'></button>"+
						"</td>"+
						"</tr>";
			} else {
				str += "</td>"+
						"</tr>";
			}

			if( appendTarget == undefined ) {
				body.append( str );
			} else {
				if( direction < 0 ) {
					$(str).insertBefore( appendTarget );
				} else {
					$(str).insertAfter( appendTarget );
				}
			}
		} 
		manageButton();
	}
	/* Delete 버튼 류는 필요한 시점이 아니면,  Disabled 돼야 하는 상황이라, table 에 기반한 이 버튼의 움직임을 */
	function manageButton() {
		myForm.select(".approvalInfoTable tbody tr:first-child .delete").hide();

		if( myForm.select(".approvalInfoTable tbody tr").length > 1 ) {
			myForm.select(".approvalInfoTable .delete").show();
		}
	}
	function checkInputData() {
		var param = {};
		var master = {};
		var message = "";
		
		/* 복수 레코드 정리 */
		try{
			var approvalArr =  arrangeMultiLine( approvalInfoFormUtil.getValue(), "applicationUserId");
		} catch( e ) {
			trace( e );
		}
		//단일레코드의 항목들을 모두 master 로 모아서 저장한다.
		master = $.extend( master, formUtil.getValue() );
		param["master"] = master;
		param["approval"] = approvalArr;

		myForm.transaction_sync("lgvhr", "lgvatt/LGVATT20450/checkInputData", param, function( data ){
			var result = data.result;
			message = data.result.message;
		});
		return message;
	}
	/* Request */
	function saveRequestInfo(requestFlag){
		var param = {};
		var master = {};
		var startMessage = "<lgcom:message code="question.att.requestSave" />";
		if( requestFlag ){
			startMessage = "<lgcom:message code="question.att.requestSubmit" />";
		}
		/* 복수 레코드 정리 */
		try{
			var approvalArr =  arrangeMultiLine( approvalInfoFormUtil.getValue(), "applicationUserId");
		} catch( e ) {
			trace( e );
		}
		
		//단일레코드의 항목들을 모두 master 로 모아서 저장한다.
		master = $.extend( master, formUtil.getValue() );
		param["master"] = master;
		param["approval"] = approvalArr;
		
		if( requestFlag ) {
			param["requestFlag"] = "Y";
		}
		
		myForm.showProgress();
		myForm.transaction_sync("lgvhr", "lgvatt/LGVATT20450/saveMutipleLongPlan", param, function( data ){
			myForm.hideProgress();
			var result = data.result;

			if( requestFlag ) {
				Message.alert( "<lgcom:message code="note.completed" />" );
			} else {
				Message.alert( "<lgcom:message code="note.saved" />" );
			}
			
			//Approval 영역의 초기상태를 두고, 모두 지운다.
			myForm.select(".approvalInfoTable tbody tr").remove();
			
			approvalInfoFormUtil.clear();
			
			var nav = new Navigate( myForm, "lgvhr", "M_LGVATT_1031" );
			nav.addParam("callType", "DETAIL");
			nav.addParam("approvalRequestId", data.result.requestMasterId);
			nav.addParam("requestCode", data.result.requestCode);
			nav.addParam("status", "20");
	        nav.goPageInCurrentDiv(false);
		});
	}
	function AES_Encode(plain_text)
	{
		GibberishAES.size(256);	
		return GibberishAES.aesEncrypt(plain_text, key);
	}
}

LGVATT20450.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGVATT20450();
		form.init();
	});
});

</script>
</head>

<body>
<div class="mdi-container">
	<section class="page-content">
	<div class="pageHeader">
		<h2>Long Term Plan Request</h2>
	</div>
	<div class="controls module-group text-right">	
		<div class="btn-toolbar">	
			<div class="btn-group">				
				<button name="list" class="btn btn-default btn-sm" type="submit" data-action="goList"><lgcom:message code="List"/></button>
				<button name="request" class="btn btn-gray btn-sm" type="button" data-action="save"><lgcom:message code="button.att.submitRequest"/></button>
			</div>
		</div>		
	</div>
	
	<div class="sub-header">
		<h3>Detail Info</h3>
	</div>
	<div class="gridContent grid-wrap">
		<form class="form detailInfo">
			<input type="hidden" name="approvalMenuId" value="M_LGVATT_1031"/>
			<input type="hidden" name="daylimit" id="daylimit"/>
			<input type="hidden" name="workDay" id="workDay"/>
			<input type="hidden" name="thirdSize" id="thirdSize"/>
			<input type="hidden" name="employeeSize" id="employeeSize"/>
			<table class="table table-condensed" > 
				<colgroup>
					<col width="130" /> <!-- th -->
					<col width="150" />
					<col width="130" /> <!-- th -->
					<col width="150" />
					<col width="130" /> <!-- th -->
					<col width="150" />
				</colgroup>
				<tbody>
					<tr>
						<th><lgcom:message code="label.att.requestDate" /></th>
						<td colspan="5">
							<div class="form-inline">
								<div class="form-group">
									<input type="text" id="requestToDay" name="requestToDay" class="form-control input-sm" style="border:none"/>
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th><lgcom:message code="label.att.planDate" /></th>
						<td>
							<div class="form-inline">
	                            <input class="form-control input-sm" id="regPlanStartDate" name="planStartDate" style="width: 90px;" type="text" placeholder="dd/mm/yyyy" onkeyup="return auto_date_format(event, this)" onkeypress="auto_date_format(event, this)">
                                ~
                                <input class="form-control input-sm" id="regPlanEndDate" name="planEndDate" style="width: 90px;" type="text" placeholder="dd/mm/yyyy" onkeyup="return auto_date_format(event, this)" onkeypress="auto_date_format(event, this)">
                                <button type="button" class="btn btn-ico _datePicker" aria-label="calendar">
					            <span class="ico ico-calendar" aria-hidden="true"></span>
				                </button>	
				            </div>
						</td>
						<th><lgcom:message code="label.att.id" /></th>
						<td colspan="2">
				            <div id="searchEmpNo" class="input-group input-group-sm input-search">
                                <input class="form-control input-sm _find_origin_" id="employeeNo" name="employeeNo" type="text" data-action="emptyAndPopup">
                                <span class="input-group-btn">
                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupApprover">
                                        <span class="fa fa-search" aria-hidden="true"></span>
                                    </button>
                                </span>
                            </div>
				            <div id="showEmployeeNo"><c:out value="${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}"/></div>
						</td>
					</tr>
					<tr>
						<th><lgcom:message code="label.att.attendanceType" /></th>
						<td>
							<select id="attendanceMaster" name="attendanceMaster" class="form-control input-sm" style="width: 180px;" data-action="attendanceMaster"></select>
						</td>
						<th><lgcom:message code="EmployeeName" /></th>
						<td colspan="2">
							<div id="empList" class="form-inline">
								<input type="text" class="form-control input-sm" name="employeeName" style="border:none">
				            </div>
				            <div id="showEmployeeName"><c:out value="${sessionScope.USER_SESSION.fullNameLocal}"/></div>
						</td>
					</tr>
					<tr>
						<th><lgcom:message code="label.att.attendanceCode" /></th>
						<td>
							<select id="attendanceDetail" name="attendanceDetail" style="width: 180px;" class="form-control input-sm" data-action="attendanceDetail"></select>
						</td>
						<th rowspan="2"><lgcom:message code="label.att.timeAttendInputReasonDesc" /></th>
						<td rowspan="2">
							<input type="text" name="reason" id="reason" class="form-control input-sm" maxlength="300"/>
						</td>
					</tr>
					<tr>
						<th><lgcom:message code="label.att.attendanceDetailReason" /></th>
						<td>
							<select id="attendanceDetailLower" name="attendanceDetailLower" class="form-control input-sm" style="width: 180px;" data-action="attendanceDetailLower"></select>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
	</div>

	<%-- 결재자 Sub Title 및 버튼 --%>
		<div class="content content2 sub-header _approvals" >
			<h3>Approval Information</h3>
			<div class="" style="position:absolute; top:0px; right:0px; width:200px; height : 25px;" >
				<button type="button" class="btn btn-default btn-sm ico-lgd" data-action="resetRows" data-target="approvalInfoTable" ><lgcom:message code="Reset1"/></button>
				<button type="button" class="btn btn-default btn-sm ico-lgd" data-action="insertRowTop"  data-target="approvalInfoTable" ><span class="fa fa-plus"></span> <lgcom:message code="AddRowAtFirst1"/></button>
			</div>
		</div>

	<%-- 결재자 --%>
		<div class="content content3 approvalArea _approvals">
			<form class="form approvalInfo" >
				<table class="approvalInfoTable table table-bordered table-condensed">
					<colgroup>
						<col width="50" />
						<col width="150" />
						<col width="400" />
						<col width="400" />
						<col width="*" />
					</colgroup>
					<thead>
						<tr>
							<th>Seq</th>
							<th>Approval Type</th>
							<th>Approver</th>
							<th>Mandator</th>
							<th></th>
						</tr>
					</thead>
					<tbody></tbody>
				</table>
			</form>
		</div>
	</section>
</div>
</body>
</html>