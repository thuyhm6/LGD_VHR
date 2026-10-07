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
    파일명 : LGVATT50020.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : 공휴일 관리
    작성자 : bakderia
    2021/03/23   HMT_20210323      Setup work hours to public holiday (Add public_hours column)
    2025/12/01   HMT_20251201      Update calendar type when update holiday (Add shift_type_codes column)
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script type="text/javascript">
var LGVATT50020 = function() {
	var myForm = this;
	var date = new Date();
	var year = date.getFullYear();
	var month = date.getMonth()+1;
	var day = date.getDate();
	
	if(("" + month).length == 1){month = "0" + month;}
	if(("" + day).length == 1){day = "0" + day;}
	
	var dateVal = day+"/"+month+"/"+year;
	
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	var gridContent = new FormUtil(myForm,'.gridContent form');
	
	myForm.setLayout( [ 
		{ name : "searchBlock", left : 0, right : 0, top : 0 },
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
	]);
	
	// 그리드 선언
	var grid = buildGrid('.holidayManageGrid');
	
	// Selection Mode 변경
    //grid.setSelectMode(RealGrid.SELECTION_BLOCKLINE);

	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	search();
	
	this.addEvent('change',"select[name='timeAndAttendanceYyyy']",function(event) {
		search();
	});
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ) {
			case 'search':
				search();
				
				break;
			case 'insert':
				var grid1 = grid.getGridBase();
				grid1.commit();
				var subsidiaryCode = '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}';
				var currIdx = grid1.getCurrent().itemIndex;
				var itemCnt = grid1.getItemCount();
				var dataRowIdx = grid1.getCurrent().dataRow;
				var provider = grid1.getDataProvider();

				if(grid.getGridBase().getCurrent().itemIndex < 0) {
					grid1.beginAppendRow();
					grid1.setValue(0, 'creationUserId',$.trim(SESSION_USER.fullNameLocal));
					grid1.setValue(0, 'creationDate',dateVal);
				} else {
					grid1.beginInsertRow(currIdx);
					grid1.setValue(currIdx, 'creationUserId',$.trim(SESSION_USER.fullNameLocal));
					grid1.setValue(currIdx, 'creationDate',dateVal);
				}
				grid1.setFocus();
				
				break;
			case 'save':
				var grid1 = grid.getGridBase();
				var year = $.trim(myForm.select(".searchBlock select[name='timeAndAttendanceYyyy']").val());
				
				try {
					grid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				if( grid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				if(!grid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				
				var cgrid = grid.getGridBase();
				var tocnt = 0;
				var recpmap = new Map();
				var isDupFlag = false;
				
				
				
				
				for(var i=0; i < cgrid.getItemCount(); i++) {
					// 삭제건은 제외
					if(cgrid.getDataProvider().getRowState(cgrid.getDataRow(i)) == 'deleted') continue;
					
					//입력년도가 다를경우 alert
					if(year != cgrid.getValue(i,'holidayDate').substr(6,4)) {
						var otherYear = cgrid.getValue(i,'holidayDate');
						Message.alert('<lgcom:message code="error.noSameYear" arguments="'+otherYear+'"/>');
						return;
					}
					//HMT_20210323 Start
					if (!isNull(cgrid.getValue(i,'publicHours')) && cgrid.getValue(i,'timeAndAttendanceCode') == 'WH') {
						Message.alert('<lgcom:message code="note.att.WeeklyHolidayNotPublicHours"/>');
						cgrid.setValue(i,'publicHours', null);
						return;
					}
					//HMT_20210323 End
					//동일일자 입력체크 alert
					if(recpmap.containsKey(cgrid.getValue(i,'holidayDate'))) {
						dupHolidayDate = cgrid.getValue(i,'holidayDate');
						isDupFlag = true;
						continue;
					}
					recpmap.put(cgrid.getValue(i,'holidayDate'),1);
				}
				if(isDupFlag) {
					Message.alert('<lgcom:message code="error.dupHoliday" arguments="'+dupHolidayDate+'"/>');
					return;
				}
				
				Message.confirm('<lgcom:message code="question.save"/>', function() {
						
					grid.useProgress(true);
					grid.saveChanges('lgvhr','lgvatt/LGVATT50020/saveHolidayManage', function(data, gridData ) {
						Message.alert('<lgcom:message code="note.completed"/>');
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
				break;
			case 'delete':
				grid.getGridBase().deleteSelection(true);
				break;
			case 'calculate':
				fncCalculate();
				break;
		}
	});
	
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	/***  내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var holidayCodeList = new Array();
        var holidayNameList = new Array();
		var holidayAttendanceCodeList = new Array();
        var holidayAttendanceNameList = new Array();
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		
		//필드 설정
		grid.setFields([
		    { fieldName: 'timeAndAttendanceYyyy'    , dataType:'text'},
		    { fieldName: 'holidayDate'         		, dataType:'text'},
		    { fieldName: 'beforeHolidayDate'        , dataType:'text'},
		    { fieldName: 'holidayCode'         		, dataType:'text'},
		    { fieldName: 'holidayName'         		, dataType:'text'},
		    { fieldName: 'timeAndAttendanceCode'    , dataType:'text'},
		    { fieldName: 'timeAndAttendanceName'    , dataType:'text'},
		    { fieldName: 'publicHours'              , dataType:'number'}, //HMT_20210323
		    { fieldName: 'shiftTypeCodes'           , dataType:'text'}, //HMT_20251201
		    { fieldName: 'creationDate'         	, dataType:'text'},
		    { fieldName: 'creationUserId'         	, dataType:'text'}
		]);
		// Lookup 설정
		grid.setLookupsMultiLvl({
	    	//"timeAndAttendanceName" : holidayAttendanceList
		});
		
		//Holiday Combo조회
		transaction_sync("lgvhr", "lgvatt/LGVATT50020/retrieveHolidayNameList", {languageCode:SESSION_USER.languageCode}, function(data){
			var holidayList = data.result;	
			$(holidayList).each( function(){
				holidayCodeList.push(this.code);
				holidayNameList.push(this.name);
			});
		});
		//Attendance Combo조회
		transaction_sync("lgvhr", "lgvatt/LGVATT50020/retrieveHolidayAttendance", {subsidiaryCode:"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}"}, function(data){
			var attendanceList = data.result;	
			$(attendanceList).each( function(){
				holidayAttendanceCodeList.push(this.code);
				holidayAttendanceNameList.push(this.name);
			});
		});
		
		//컬럼 설정
		grid.setColumns([
 				{
					name:'holidayDate',
					fieldName:'holidayDate',
					width:100,
					header: {text:'<lgcom:message code="label.att.date" />'},
					styles: {textAlignment:'center'},
					editor: {type:'date',textReadOnly : true, datetimeFormat:'dd/MM/yyyy'}
				},
				{
					name:'beforeHolidayDate',
					fieldName:'beforeHolidayDate',
					width:0,
					header: {text:'<lgcom:message code="label.att.date" />'},
					styles: {textAlignment:'center'},
					editor: {type:'date',datetimeFormat:'yyyy-mm-dd'}
				},
				{
					name:'holidayCode',
					fieldName:'holidayCode',
					width:250,
					header: {text:'<lgcom:message code="label.att.holidayName" />'},
					styles: {textAlignment:'near'},
					lookupDisplay: true,
					values:holidayCodeList,
					labels:holidayNameList,
					editor: {type:'dropDown', textReadOnly : true,editable: true}
				},
				{
					name:'timeAndAttendanceCode',
					fieldName:'timeAndAttendanceCode',
					width:300,
					header: {text:'<lgcom:message code="label.att.attendance"/>'},
					styles: {textAlignment:'near'},
					lookupDisplay: true,
					values:holidayAttendanceCodeList,
					labels:holidayAttendanceNameList,
					editor: {type:'dropDown', textReadOnly : true,editable: true}
				},
				//HMT_20210323 Start
				{	name:'publicHours',
					fieldName:'publicHours',
					width:100,
					header: {text:'<lgcom:message code="label.att.publicHours"/>'},
					styles: {textAlignment:'far', numberFormat: '#0.0'},
					editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#0.#'}
				},
				//HMT_20210323 End
				//HMT_20251201 Start
				{	name:'shiftTypeCodes',
					fieldName:'shiftTypeCodes',
					width:100,
					header: {text:'<lgcom:message code="label.att.shiftCode"/>'},
					styles: {textAlignment:'center'}
				},
				//HMT_20251201 End
				{
					name:'creationDate',
					fieldName:'creationDate',
					width:200,
					header: {text:'<lgcom:message code="label.att.creationDate" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'creationUserId',
					fieldName:'creationUserId',
					width:200,
					header: {text:'<lgcom:message code="label.att.createBy" />'},
					styles: {textAlignment:'near'},
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
				checkBar: {visible:true},
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

		grid.setValidations([
			 					{criteria: "value['holidayDate'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.date'/>"/>',mode:'always',level:'error'},
			 					{criteria: "value['holidayCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.holidayName'/>"/>',mode:'always',level:'error'},
			 					{criteria: "value['timeAndAttendanceCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.attendance'/>"/>',mode:'always',level:'error'}
			 				]);
		return grid;
	}
	
	function search() {
		grid.getGridBase().cancel();
		var param = formUtil.getValue();
		grid.loadData('lgvhr','lgvatt/LGVATT50020/retrieveHoliday', param);

		transaction_sync("lgvhr", "lgvatt/LGVATT50020/retrieveHolidayNameList", {languageCode:SESSION_USER.languageCode}, function(data){
			holidayNmList = data.result;
		});
		transaction_sync("lgvhr", "lgvatt/LGVATT50020/retrieveHolidayAttendance", {subsidiaryCode:"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}"}, function(data){
			holidayAttendanceList = data.result;
		});
		
		grid.setLookupsMultiLvl({
	    	'holidayName' : holidayNmList,
	    	'timeAndAttendanceName' : holidayAttendanceList
	    });
	}
	
	//Calculate company attendance
	function fncCalculate() {
		var cMsg = '<lgcom:message code="question.pay.calculate"/>';
		
		try {
			grid.getGridBase().commit();
		} catch(e) {
			Message.alert(e.message);
			return;
		}
			
		var checkedRows = grid.getGridBase().getCheckedRows(true);
		
		if( checkedRows.length > 0 ) {
			
			var param = {};
			var arr = [];
			
			for(var i=0; i<checkedRows.length; i++) {
				arr.push(grid.getDataProvider().getJsonRow(checkedRows[i]));
			}
			
			param["modifyList"] = arr;
			
		} else {
			Message.alert('<lgcom:message code="error.noChangedData"/>');
			return;
		}
		
		Message.confirm(cMsg, function() {
			myForm.showProgress();
			myForm.transaction("lgvhr", "lgvatt/LGVATT50020/calculateAttendance", param, function( data ){

				Message.alert( '<lgcom:message code="note.completed" />' );
				myForm.select(".search-wrap button[data-action='search']").trigger('click');
				myForm.hideProgress();
			});
		});	
	}
}
LGVATT50020.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVATT50020();
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
		                    <th><label class="required"><lgcom:message code="label.att.attendanceYear"/></label></th>
		                    <td>
		                        <div class="form-inline ">
                                	<select class="form-control input-sm input-require" name="timeAndAttendanceYyyy" id="timeAndAttendanceYyyy">
                                		<c:forEach begin="0" end="2" var="idx" step="1">
                                		<option value="<c:out value="${currentYear+idx}"/>"><c:out value="${currentYear+idx}"/></option>
                                		</c:forEach>
                                	</select>
                            	</div>
		                    </td>
		                </tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- 그리드 버튼 영역 --%>
	<div class="gridControls module-group text-right">
		<div class="btn-toolbar">
			<div class="btn-group">
				<button class="btn btn-gray btn-sm" type="button" data-action="calculate" ><lgcom:message code="button.pay.calculate"/></button>
			</div>
			<div class="btn-group">
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-remove" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
			</div>
			<div class="btn-group">					      
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="save"/></button>
			</div>
		</div>
	</div>
		<div class="gridContent grid-wrap">
			<div class="grid holidayManageGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
