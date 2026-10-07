<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT20010.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 임직원이 월근태 실적을 조회하는 캘린더 화면입니다.
    작성자 : 임수진	
    HMT_20211018     Add year ot total and special ot detail
    HMT_20210319     Add Popup - Alarming working hours
-------------------------------------------------------------%>

<c:set var="flg_vn_line_worker_pic_user" value="N"/>
<c:forEach var="roles" items="${sessionScope.USER_SESSION.roleList}">
    <c:if test="${roles.systemCode=='LGVHR' && roles.moduleCode=='LGVATT' && fn:indexOf(roles.roleCode,'VN_LINE_WORK_PIC_USER')>=0 }">
        <c:set var="flg_vn_line_worker_pic_user" value="Y"/>
    </c:if>
</c:forEach>

<html lang="ko">
<head>
<title><lgcom:message code="label.att.monthlyAttendanceCalendar"/></title>
<style type="text/css">
.calendarTable > tbody > tr > td                  { height:80px; vertical-align:top; }
.calendarTable > tbody > tr > td span:first-child { font-weight:bold;; }
.calendarTable > tbody > tr > td:hover            { background-color: #f5f5f5; }
.calendarTable > thead > tr > th:first-child,
.calendarTable > tbody > tr > td:first-child span:first-child,
.calendarTable > tbody > tr > td.holidayTd,
.calendarTable > tbody > tr > td.holidayTd span:first-child { 
	color: #F34D78; /* 일요일, 공휴일, 휴무일 */
}
.calendarTable > thead > tr > th:last-child/*,
.calendarTable > tbody > tr > td:last-child span:first-child*/ { 
	color: #57C3D0; /*토요일 */
}
.deductionTable > tbody > tr > td,
.paymentTable > tbody > tr > td { 
	text-align:right; 
}
.buttonControls {vertical-align:bottom;}
.resultAttDayInfo {font-size: 14px;}
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVATT20010 = function() {
	var myForm = this;
	var srchForm = '.searchBlock form';
	// Form Util 선언
	var srchFormUtil = new FormUtil( myForm, srchForm );
	var employeeInfoFormUtil = new FormUtil( myForm, ".employeeInfoBlock form" );
	var summaryFormUtil = new FormUtil( myForm, ".summaryBlock" );
	var anualLeaveFormUtil = new FormUtil( myForm, ".anualLeaveBlock" );
	
	var isPicUser = ('<c:out value="${flg_vn_line_worker_pic_user}"/>' == 'Y')?true:false;  // 근태 담당자 여부 pic

    var employeeData = {};
    if(isPicUser) {
    	srchFormUtil.setValue({
    		isPicFlag : 'Y'
    	});
    }
    
    var popupAlarm = new Popup(myForm,'lgvhr','M_LGVATT_1062','<lgcom:message code="label.att.workingHourCompliance"/>' ); //HMT_20210319
    popupAlarm.setSize( 800, 300 );
    popupAlarm.open( function(){
    }, function(){
    });
	//2018.03.12 [베트남 급여근태 고도화] Let's 직접 호출 허용되는지 여부 처리
	<c:choose>
	<c:when test="${ param.container eq 'Y' and param.letsFg eq 'Y' }">
		<%-- 2018.03.12 [베트남 급여근태 고도화] container 변수 있는 경우는 직접 호출된 화면이므로 장기근태입력 버튼 보여주지 않는다 --%>
		myForm.select("button[data-action='movePage']").hide();

		fncRetireveDirectOpenData();

		<%-- 2018.03.12 [베트남 급여근태 고도화] 근태실적 미입력 여부 조회. Let's에서 직접 호출되는 경우 실적 미입력된 경우만 팝업 띄워주기 위함 --%>
		function fncRetireveDirectOpenData() {
			myForm.transaction("lgvhr", "lgvatt/LGVATT20010/retireveDirectOpenData", { container:"<c:out value="${param.container}"/>", letsFg:"<c:out value="${param.letsFg}"/>" }, function(data) {
				//팝업호출 불가능한 상태인 경우 창 닫기 
				if ( data.result && nvl(data.result.popupOpenFlag) == "Y" ) {
			         
		            var popup = new Popup( myForm, "lgcom", "<c:out value="${menuId}"/>", $("._pageTitle").text() );
		            popup.setSize( 1600, 900 );
		            popup.openWindow( function(){
		            }, function(){
				    });
				}
			});
		}

	</c:when>
	<c:otherwise>
		<c:if test="${param.container eq 'Y'}">
		<%-- 2018.03.12 [베트남 급여근태 고도화] container 변수 있는 경우는 직접 호출된 화면이므로 장기근태입력 버튼 보여주지 않는다 --%>
		myForm.select("button[data-action='movePage']").hide();
		document.title = $("._pageTitle").text();
		</c:if>
	
    // 화면 레이아웃 정의(최초 로딩 시 summary영역, 연차 영역 위치를 캘린더 행 6개로 pixel로 고정하여 위치시킨다.)
	myForm.setLayout( [ 
		{ name : "searchBlock",       left : 0, right : 0, top : 0 },
		{ name : "employeeInfoBlock", left : 0, right : 0, top : "searchBlock",       bottom : "buttonControls" },
	    { name : "buttonControls",    left : 0, right : 0, top : "employeeInfoBlock", bottom : "calendarBlock" },
	    { name : "calendarBlock",     left : 0, right : 0, top : "buttonControls",    bottom : "summaryBlock" },
	    { name : "summaryBlock",      left : 0, right : 0, top : 610,  bottom : "anualLeaveBlock" },
	    { name : "anualLeaveBlock",   left : 0, right : 0, top : 701,  bottom : 0 }
	    //{ name : "summaryBlock",      left : 0, right : 0, top : 695,  bottom : "anualLeaveBlock" },
	    //{ name : "anualLeaveBlock",   left : 0, right : 0, top : 786,  bottom : 0 }
	]);	

    // 그리드선언

    // 개인화조건
    
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)
    /* 팝업용 변수 선언 */
	myForm.popupInfo = {
		dailyAttendancePopup: { searchMode:'single', employeeNo:'', attendanceYyyymmdd:'', popupWidth:'', popupData:[] }
	};

    // 그리드형 테이블 TR
    
    // 코드 데이터 조회
    //근태년월 목록 셋팅
    //2018.03.12 [베트남 급여근태 고도화] Let's 직접 호출 허용되는지 여부 처리로직 추가됨에 따라 Let's 직접 호출 아닌 경우만 처리되도록 한다.
    <c:if test="${ not (param.container eq 'Y' and param.letsFg eq 'Y') }">
    fncRetrieveAttendanceYyyymmNEmployeeList();
    </c:if>

    //day of week code
    var code = new CommonCode("lgcom");
    code.add("LGVHR_DAY_OF_WEEK", {codeTypeCode:"LGVHR_DAY_OF_WEEK"});
    code.execute();

    // 날짜 팝업창
    
    // 필수항목 체크
   	var validator = new Validator( myForm, srchForm );

    validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	 	    attendanceYyyymm: {required:true},
	 	    employeeNo:{required:true}
	    },
	    messages: {
	    	effectiveYyyymmdd: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='month'/>" />'},
	    	employeeNo: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='employeeNo'/>" />'}
	    }
    });

    // 일반함수	
    
    // Event 처리
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
					myForm.showProgress();
					//조회권한이 있는지 여부
					myForm.transaction("lgvhr", "lgvatt/LGVATT20010/retrieveEmployeeEnableFlag", srchFormUtil.getValue(), function(data) {
						myForm.hideProgress();
						if ( !data.result ) {
							Message.alert("<lgcom:message code="note.NoPermission"/>");
							return ;
						} else {

							//초기화
							fncClearSpan("summaryBlock");
							fncClearSpan("anualLeaveBlock");
							
							//사용자 조회
							fncRetrieveEmployeeInfo(srchFormUtil.getValue("employeeNo"));
							//근태일자 조회
					    	fncRetrieveAttendanceDateList();
						}
					});
				}
				break;
			case "movePage" :
				var nav = new Navigate( myForm, "lgvhr", "M_LGVATT_1019" );
				nav.goPageInNewTab();
				break;
		}
		event.stopPropagation();
	});
    
    //근태년월, 성명 변경 시 화면 재조회
	myForm.addEvent( "change", ".searchBlock .form select[name=attendanceYyyymm], select[name=employeeNo]" , function(event) {
		//사용자 정보 초기화
		employeeInfoFormUtil.clear();
		// 사번 text 란에 셋팅
		employeeInfoFormUtil.setValue({employeeNoText:srchFormUtil.getValue("employeeNo")});
		//클릭이벤트 호출
		myForm.select(".searchBlock button[data-action='search']").trigger('click');
		event.stopPropagation();
	});
    
    //달력 클릭 이벤트(토요일, 일요일 제외한 날짜에 클릭 이벤트 추가)
    //myForm.addEvent( "click", "td[data-val]:not(:first-child):not(:last-child) ", function(event) {
    myForm.addEvent( "click", "td[data-val] ", function(event) {
    	<%-- 본인 && FSE 아니고 && 단기파견자 아닌 경우 팝업 띄워줌. --%>
    	if ( ((nvl(srchFormUtil.getValue("employeeNo")) == '${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}') || isPicUser) && nvl(employeeData.fseYn) == "N" && nvl(employeeData.flsaYn) == "N" ) {
			//일근태 팝업호출
			processDailyAttendanceePopup($(this).attr("data-val"));
		}
    });
    
	/*** 내부 함수  ***/
    // 그리드 초기화

    //사용자 정보 조회
	function fncRetrieveEmployeeInfo(employeeNo) {
		myForm.showProgress();
		myForm.transaction( "lgvhr","lgvatt/LGVATTCOMM/retrieveEmployee", {employeeNo:employeeNo}, function(data) {
			myForm.hideProgress();
			if(data.result) {
				employeeData = data.result;
				//임직원 정보 셋팅
				employeeInfoFormUtil.setValue(employeeData);
			}
		});
	}
	
	//근태 캘린더 영역
	var calendarDiv = myForm.select(".calendarBlock");
	//근태캘린더 헤더 영역 드리기
	function fncDrawCalendarBox() {
		//근태 캘린더 테이블
		var calcTable = $("<table class='table table-bordered table-condensed calendarTable' summary='Attendance Calendar'></table>");
		calendarDiv.append(calcTable);
		calcTable.append("<colgroup><col width='14.2%'/><col width='14.2%'/><col width='14.2%'/><col width='14.2%'/><col width='14.2%'/><col width='14.2%'/><col width='*'/></colgroup>");
		//thead
		var calcThead = $("<thead></thead>");
		calcTable.append(calcThead);
		//head tr
		var hTr = $("<tr></tr>");
		calcThead.append(hTr);
		//근태 캘린더 헤더셋팅(일요일 ~ 토요일)
		$(code.get("LGVHR_DAY_OF_WEEK")).each(function() {
			hTr.append("<th scope='col'>"+this.name+"</th>");
		});
		//tbody
		calcTable.append("<tbody></tbody>");

	}
	
	//근태년월에 해당하는 근태일자 조회
	function fncRetrieveAttendanceDateList() {
		//캘린더 날짜 지우고 다시 그려야 함.
		var calendarRow = calendarDiv.find(">table>tbody>tr");
		$(calendarRow).each(function() {
			$(this).remove();
		});
		
		myForm.showProgress();
		//근태일자 조회
		myForm.transaction("lgvhr", "lgvatt/LGVATT20010/retrieveAttendanceDateList", srchFormUtil.getValue(), function(data) {
			myForm.hideProgress();
			if ( data.result ) {
				var calcTbody = calendarDiv.find(">table>tbody");
				var tr, td, spn1, spn2, attendanceYyyymmdd;
				$(data.result).each(function(inx) {
					//근태일자별 캘린더 그리기
					//첫번째 값이거나 일요일인 경우
					if ( inx == 0 || (inx > 0 && this["weekDay"] == 1) ) {
						tr = $("<tr></tr>");
						calcTbody.append(tr);
						//첫번째 주인 경우 시작일이 일요일이 아닌 경우 빈 칸 생성
						if ( inx == 0 && this["weekDay"] > 1 ) {
							//시작하는 요일까지 빈 td 생성
							for (var i=1; i<this["weekDay"]; i++) {
								tr.append("<td> </td>");
							}
						}
					}
					//근태일자
					attendanceYyyymmdd = $.trim(this["attendanceYyyymmdd"]).replaceAll("/","");
					
					//날짜 TD생성
					td = $("<td><span name='attDayName' title=''>"+$.trim(this["attendanceDay"])+"</span><span name='attDayInfo'></span></td>");
					td.attr("data-val", attendanceYyyymmdd);
					if ( $.trim(this["holidayFlag"] ) == "Y" ) {//휴일인 경우
						td.addClass("holidayTd");
					}
					tr.append(td);
					
					//마지막날이 토요일 이전인 경우 토요일까지 빈 칸 생성
				 	if ( this["lastDayFlag"] == "Y" && this["weekDay"] < 7 ) {
						//시작하는 요일까지 빈 td 생성
						for (var i=this["weekDay"]; i<7; i++) {
							tr.append("<td> </td>");
						}
					}
				});

				//계획/실적근태 및 근태 summary, 휴가 summary 조회
				fncRetrieveAttendancePlanNResultList();
			}

			//summary 영역 위치 조정(캘린더 날짜 TD 생성 후 table 높이 만큼 summary 영역 이동시킴)
			fncChangePosition();
		});
		
		//날짜 구성 후 테이블 높이로 캘린더 div 영역의 높이 지정. 근태년월 변경시 summary 영역 top 위치 조정하기 위해 필요한 값.
		myForm.select(".calendarBlock").css({height: Number(calendarDiv.find(">table").height())});
	}
	
	//계획/실적근태 및 근태 summary, 휴가 summary 조회
	function fncRetrieveAttendancePlanNResultList() {
		var isAuth = ( (srchFormUtil.getValue("employeeNo") == '${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}') || isPicUser );
		myForm.showProgress();
		myForm.transaction("lgvhr", "lgvatt/LGVATT20010/retrieveAttendancePlanNResultList", srchFormUtil.getValue(), function(data) {
			myForm.hideProgress();
			if ( data.result ) {
				/* 근태 캘린더에 일근태 셋팅 */
				var attDayInfo;
				$(data.result["attendPlanNResultList"]).each(function() {
					//계획:근태코드 / 정상근무시간 / overtime / 1차결재상태 / 2차결재상태
					//실적:근태코드 / 정상근무시간 / overtime / 1차결재상태 / 2차결재상태
					attDayInfo = "<br/>" +
					             "<br/>" + $.trim(this.attCodePlan) + " / " + $.trim(this.workHoursPlan) + " / " + $.trim(this.overtimeSumHoursPlan) + " / " + $.trim(this.specialOtN) + " / " + $.trim(this["1stApprovalStatusPlan"]) + " / " + $.trim(this.finalApprovalStatusPlan) + // HMT_20211018
					             "<span class='resultAttDayInfo'>"+"<br/>" + $.trim(this.attCodeRslt) + " / " + $.trim(this.workHoursRslt) + " / " + $.trim(this.overtimeSumHoursRslt) + " / " + $.trim(this.specialOtY) + " / " + $.trim(this["1stApprovalStatusRslt"]) + " / " + $.trim(this.finalApprovalStatusRslt) + "</span>" +
					             "";
					calendarDiv.find("td[data-val='"+$.trim(this.attendanceYyyymmdd)+"']>span[name='attDayInfo']").html(attDayInfo);
					calendarDiv.find("td[data-val='"+$.trim(this.attendanceYyyymmdd)+"']").css("cursor", (isAuth)?"pointer":"default");//본인인 경우 커서 스타일 변경
					//근태명 tooltip 으로 표기
					calendarDiv.find("td[data-val='"+$.trim(this.attendanceYyyymmdd)+"']").attr("title", "<lgcom:message code="label.att.plan"/> : "+$.trim(this.attNamePlan) + "\n" + "<lgcom:message code="label.att.actual"/> : "+$.trim(this.attNameRslt));
				});
				
				//payment block, deduction block 셋팅
				summaryFormUtil.setValue(data.result["attendSummaryData"]);
				anualLeaveFormUtil.setValue(data.result["attendSummaryData"]);
			}

			//summary 영역 위치 조정(캘린더 TD에 텍스트 셋팅 후 캘린더 영역 크기 변경될 수 있으므로 재호출함.)
			fncChangePosition();
		});
	}

	// 일근태 Popup 처리
	function processDailyAttendanceePopup(attendanceYyyymmdd) {	
		// 팝업에 전달할 파라메터를 세팅한다.
		myForm.popupInfo.dailyAttendancePopup['employeeNo'] = srchFormUtil.getValue("employeeNo");
		myForm.popupInfo.dailyAttendancePopup['attendanceYyyymmdd'] = attendanceYyyymmdd;
		myForm.popupInfo.dailyAttendancePopup['popupWidth'] = "1570";
		// 팝업을 호출한다.
		var popup = new Popup(myForm,'lgvhr','M_LGVATT_1029','<lgcom:message code="label.att.dailyRegistration"/>');
		popup.setSize(myForm.popupInfo.dailyAttendancePopup['popupWidth'],800);	// searchMode 'Single'
		popup.open(function() {
			//팝업 닫는 경우 화면 재조회
			myForm.select(".searchBlock button[data-action='search']").trigger('click');
			
			myForm.popupInfo.dailyAttendancePopup.popupData = [];
		});
	}
	//summary 영역 높이 조정
	function fncChangePosition() {
		var summaryBlock = myForm.select(".summaryBlock");
		var anualLeaveBlock = myForm.select(".anualLeaveBlock");
		var calendarBlock = myForm.select(".calendarBlock");
		
		summaryBlock.css("top", Number(calendarBlock.position().top) + 
				                Number(calendarBlock.find(">table").height()) + 10 );

		anualLeaveBlock.css("top", Number(summaryBlock.position().top) + 
				                   Number(summaryBlock.find(".paymentBlock").height()) );
	}
	
	//2018.03.12 [베트남 급여근태 고도화] span 값 초기화
	function fncClearSpan( sClassName ){ 
		myForm.select("."+sClassName).find("span").each(function(inx) {
			$(this).text("");
		});
	}
	//2018.03.12 [베트남 급여근태 고도화] 근태년월, 로그인 사용자 정보 조회 (데이터 조회 전 체크 로직 추가하기 위해 함수로 분리)
	function fncRetrieveAttendanceYyyymmNEmployeeList() {

	    //로딩 이미지 보여주기 위해 transaction_sync 를 transaction으로 변경
	    myForm.showProgress();
	    myForm.transaction( "lgvhr","lgvatt/LGVATT20010/retrieveAttendanceYyyymmNEmployeeList", { isPicFlag: srchFormUtil.getValue("isPicFlag") }, function(data) {
	        myForm.hideProgress();
			if ( data.result ) {
				srchFormUtil.initCombo("attendanceYyyymm", data.result["yyyymmList"],   {selectAll:false});
				srchFormUtil.initCombo("organizationId",   data.result["orgList"],      {selectAll:false});
				srchFormUtil.initCombo("employeeNo",       data.result["employeeList"], {selectEmpty:true, filter:'organizationId'});

				//현재 근태년월, 로그인 사용자 사번 기본값 셋팅			
				srchFormUtil.setValue({attendanceYyyymm: data.result["currentYyyymmData"].attendanceYyyymm
					                 , organizationId  : "${sessionScope.LGVHR_PROJECT_SESSION.organizationId}"
					                 , employeeNo      : "${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}"});
				employeeInfoFormUtil.setValue({employeeNoText:"${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}"});
				//사용자정보 셋팅
				employeeData = data.result["employeeData"];
				employeeInfoFormUtil.setValue(employeeData);
				
				<%-- 2018.03.12 [베트남 급여근태 고도화] container 변수 있는 경우는 직접 호출된 화면이므로 장기근태입력 버튼 보여주지 않는다 --%>
				<c:if test="${empty param.container}">
				<%-- fse 아니고, 단기파견자 아닌 경우만 장기근태 화면 이동 버튼 보여줌 --%>
				if ( nvl(employeeData.fseYn) == "N" && nvl(employeeData.flsaYn) == "N" ) {
					myForm.select("button[data-action='movePage']").show();
				<%-- fse 이거나, 단기파견자 인 경우 장기근태 화면 이동 버튼 숨김 --%>
				} else {
					myForm.select("button[data-action='movePage']").hide();
				}
				</c:if>
			}
			
			//근태캘린더 영역 그리기
			fncDrawCalendarBox();

			//근태년월별 근태일자 조회
			fncRetrieveAttendanceDateList();
		});
	}
	
	</c:otherwise>
	</c:choose>

}

LGVATT20010.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT20010();
		form.init();
	});
});

</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.att.monthlyAttendanceCalendar"/></h2>
		</div>
		<%-- 2018.03.12 [베트남 급여근태 고도화] Let's 링크 아닌 경우만 body 보여줌 --%>
		<c:if test="${ empty param.letsFg }">
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<input type="hidden" name="isPicFlag"/>
				<table class="table" >
					<colgroup>
						<col width="100"></col>
						<col width="100"></col>
						<col width="120"></col>
						<col width="250"></col>
						<col width="150"></col>
						<col width="350"></col>
						<col width="*"></col>
					</colgroup>
					<tbody>
						<tr>
		                    <th scope="col"><label class="required" keyword><lgcom:message code="month" /></label></th>
		                    <td><select class="form-control input-sm input-require" name="attendanceYyyymm" ></select></td>
							<th scope="col"><label><lgcom:message code="label.att.organization"/></label></th>
							<td><select class="form-control input-sm input-require" name="organizationId" ></select></td>
							<th scope="col"><label><lgcom:message code="EmployeeName"/></label></th>
							<td><select class="form-control input-sm input-require" name="employeeNo" ></select></td>
							<td></td>
						</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- //searchBlock --%>
		<div class="employeeInfoBlock">
			<form class="form">
		    	<table class="table table-condensed table-bordered" summary="Employee Info">
		        	<caption class="sr-only-lgd">Employee Info</caption>
					<colgroup>
						<col width="14%"></col>
						<col width="14%"></col>
						<col width="14%"></col>
						<col width="*"></col>
						<col width="19%"></col>
						<col width="14%"></col>
					</colgroup>
					<thead>
						<tr>
							<th scope="row"><label><lgcom:message code="EmployeeNo"/></label></th>
							<th scope="row"><label><lgcom:message code="label.att.jobGrade"/></label></th>
							<th scope="row"><label><lgcom:message code="label.att.jobTitle"/></label></th>
							<th scope="row"><label><lgcom:message code="label.att.organization"/></label></th>
							<th scope="row"><label><lgcom:message code="label.att.employmentCategory"/></label></th>
							<th scope="row"><label><lgcom:message code="label.att.shiftType"/></label></th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td class="text-center"><span name="employeeNoText"></span></td>
							<td class="text-center"><span name="gradeCode"></span></td>
							<td class="text-center"><span name="gradeTitleName"></span></td>
							<td class="text-center"><span name="organizationName"></span></td>
							<td class="text-center"><span name="empCategoryName"></span></td>
							<td class="text-center"><span name="shiftTypeName"></span></td>
						</tr>
					</tbody>
				</table>
			</form>
		</div>
		<%-- //employeeInfoBlock --%>
		
		<div class="buttonControls module-group clearfix">
			<div class="pull-left" style="padding-top:10px;">
			    <small class="text-gray"><lgcom:message code="note.att.calendarPlanAttInfo"/><br/><lgcom:message code="note.att.calendarResultAttInfo"/></small>
			</div>
			<div class="pull-right" style="padding-top:30px;">
				<button class="btn btn-default btn-sm ico-lgd" type="button" data-action="movePage"><lgcom:message code="button.att.registerLongTermAttendance"/></button>
			</div>		
		</div>
		<%-- //buttonControls --%>
		
		<div class="calendarBlock"></div>
		<%-- //월근태 달력 --%>
		
		<%-- summary 정보 --%>
		<div class="row summaryBlock">
			<div class="col-xs-6 paymentBlock">
				<div class="sub-header"><h4><lgcom:message code="label.att.payment"/></h4></div>
				<table class="table table-condensed paymentTable" summary="Payment Info">
					<caption class="sr-only-lgd">Payment</caption>
					<colgroup>
						<col width="10%"></col>
						<col width="6%"></col>
						<col width="10%"></col>
						<col width="6%"></col>
						<col width="11%"></col>
						<col width="6%"></col>
					</colgroup>
					<tbody>
						<tr>
							<th scope="row"><label><lgcom:message code="label.att.nightTime"/></label></th>
							<td><span name="nightHours"></span> <lgcom:message code="label.att.unitHour"/></td>
							<th scope="row"><label><lgcom:message code="label.att.overTime"/></label></th>
							<td><span name="overtimeHours"></span> <lgcom:message code="label.att.unitHour"/></td>
							<th scope="row"><label><lgcom:message code="label.att.overTimeAtNight"/></label></th>
							<td><span name="nightOvertimeHours"></span> <lgcom:message code="label.att.unitHour"/></td>
						</tr>
						<tr>
							<th scope="row"><label><lgcom:message code="label.att.paidLeave"/></label></th>
							<td><span name="paidVacationDays"></span> <lgcom:message code="label.att.unitDay"/></td>
							<th scope="row"><label><lgcom:message code="label.att.yearTotalOT"/></label></th> <!-- HMT_20211018 -->
							<td><span name="yearOt"></span> <lgcom:message code="label.att.unitHour"/></td> <!-- HMT_20211018 -->
							<th scope="row"><label></label></th>
							<td><span></span></td>
						</tr>
					</tbody>
				</table>
			</div>
			<%-- //paymentBlock --%>
			<div class="col-xs-6 deductionBlock">
				<div class="sub-header"><h4><lgcom:message code="label.att.deduction"/></h4></div>
				<table class="table table-condensed deductionTable" summary="Deduction Info">
					<caption class="sr-only-lgd">Deduction</caption>
					<colgroup>
						<col width="11%"></col>
						<col width="6%"></col>
						<col width="10%"></col>
						<col width="6%"></col>
						<col width="10%"></col>
						<col width="6%"></col>
					</colgroup>
					<tbody>
						<tr>
							<th scope="row"><label><lgcom:message code="label.att.absence"/></label></th>
							<td><span name="absenceDays"></span> <lgcom:message code="label.att.unitDay"/></td>
							<th scope="row"><label><lgcom:message code="label.att.deductionLateness"/></label></th>
							<td><span name="tardyHours"></span> <lgcom:message code="label.att.unitHour"/></td>
							<th scope="row"><label><lgcom:message code="label.att.goingOut"/></label></th>
							<td><span name="goingOutHours"></span> <lgcom:message code="label.att.unitHour"/></td>
						</tr>
						
						<tr>
							<th scope="row"><label><lgcom:message code="label.att.leavingEarly"/></label></th>
							<td><span name="earlyLeaveHours"></span> <lgcom:message code="label.att.unitHour"/></td>
							<th scope="row"><label><lgcom:message code="label.att.unpaidLeave"/></label></th>
							<td><span name="unpaidVacationDays"></span> <lgcom:message code="label.att.unitDay"/></td>
							<th scope="row"><label><lgcom:message code="label.att.suspension"/></label></th>
							<td><span name="absenceLeaveDays"></span> <lgcom:message code="label.att.unitDay"/></td>
						</tr>
					</tbody>
				</table>
			</div>
			<%-- //deductionBlock --%>
		</div>
		<%-- //summaryBlock --%>
		
		<div class="anualLeaveBlock">
			<div class="sub-header"><h4><lgcom:message code="label.att.leave"/></h4></div>
			<table class="table table-condensed deductionTable" summary="Leave Info">
				<caption class="sr-only-lgd">Leave</caption>
				<colgroup>
					<col width="39%"></col>
					<col width="9%"></col>
					<col width="17%"></col>
					<col width="8%"></col>
					<col width="18%"></col>
					<col width="9%"></col>
				</colgroup>
				<tbody>
					<tr>
						<th scope="row"><label><lgcom:message code="label.att.totalAnnualLeave"/></label></th>
						<td>
							<span name="totalCreationDays"></span> <lgcom:message code="label.att.unitDay"/>&nbsp;
							(<span name="prevYearCarrFwdDays"></span>/<span name="currYearAccuCreationDays"></span>)
						</td>
						<th scope="row"><label><lgcom:message code="label.att.usedAnnualLeaveThisMonth"/></label></th>
						<td><span name="currMonthUseDays"></span> <lgcom:message code="label.att.unitDay"/></td>
						<th scope="row"><label><lgcom:message code="label.att.remainAnnualLeaveThisYear"/></label></th>
						<td>
							<span name="totalResidualDays"></span> <lgcom:message code="label.att.unitDay"/>&nbsp;
							(<span name="carrFwdResidualDays"></span>/<span name="currYearResidualDays"></span>)
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<%-- //anualLeaveBlock --%>
		</c:if>
	</section>
</div>
</body>
</html>
