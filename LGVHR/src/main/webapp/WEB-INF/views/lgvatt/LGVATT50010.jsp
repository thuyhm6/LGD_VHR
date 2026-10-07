<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT50010.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : 근태마감일 관리
    작성자 : bakderia
    2021/07/17         HMT_20210720      Setup date for update attendance date (Add Unpaid_Period_Date and Unpaid_Apply_Date column)
    2022/07/05         HMT_20220705      Can save if unpaidPeriodDate is null
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script type="text/javascript">
var LGVATT50010 = function() {
	var myForm = this;
	var result;
	// Form Util 선언
	var srchForm = '.searchBlock form';
	var srchFormUtil = new FormUtil( myForm, srchForm );
	var gridContent = new FormUtil(myForm,'.gridContent form');
	
	var code = new CommonCode('lgcom');
	code.add('flag',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_CONFIRM_YN_FLAG'});
	code.execute();
	
    transaction_sync( "lgvhr","lgvatt/LGVATT50010/retrieveAttendanceYyyymm", {}, function(data) {
    	if ( data.result ) {
    		var yyyymmList = data.result.yyyymmList;
    		
    		srchFormUtil.initCombo("timeAndAttendanceYyyymm", data.result.yyyymmList,   {selectAll:false});
    		srchFormUtil.setValue({timeAndAttendanceYyyymm: data.result.currentYyyymmData.attendanceYyyymm});
    	}
    	//myForm.select("select[name='timeAndAttendanceYyyymm']").append("<option value='201802'>02/2018</option>");
    });
    
 	//필수항목 체크
   	var validator = new Validator( myForm, srchForm );

    validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	 	    attendanceYyyymm: {required:true}
	    },
	    messages: {
	    	attendanceYyyymm: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='month'/>" />'}
	    }
    });
    
	myForm.setLayout( [ 
		{ name : "searchBlock", left : 0, right : 0, top : 0 },
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
	]);
	
	// 그리드 선언
	var grid = buildGrid('.attendanceCloseGrid');
	
	// Selection Mode 변경
    grid.setSelectMode(RealGrid.SELECTION_BLOCKLINE);

	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ) {
			case 'search':
				grid.getGridBase().cancel();
				searchList();
				break;
			case 'insert':
				var grid1 = grid.getGridBase();
				var attendanceYYYY = $.trim(myForm.select(".searchBlock select[name='timeAndAttendanceYyyymm']").val()).substr(0,2);
				var attendanceMM = $.trim(myForm.select(".searchBlock select[name='timeAndAttendanceYyyymm']").val()).substr(5,7);
				var year = $.trim(myForm.select(".searchBlock select[name='timeAndAttendanceYyyymm']").val()).substr(0,4);
				var month = $.trim(myForm.select(".searchBlock select[name='timeAndAttendanceYyyymm']").val()).substr(4,6);
				var now = (new Date(year, month, 0)).getDate();
				var subsidiaryCode = '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}';
				var searchFrmDt = "01"+month+year;
				var searchToDt = now+month+year;
				var workDay;
				
				//근태년월에 따른 총 근무일수 조회
				myForm.transaction_sync("lgvhr", "lgvatt/LGVATT20450/retrieveWorkDay", {subsidiaryCode:subsidiaryCode, planStartDate:searchFrmDt, planEndDate:searchToDt}, function( data ){
					workDay = data.result.workDay;
				}); 
				
				var gridCount = grid.getDataProvider().getRowCount();
				if(gridCount < 1) {
					grid1.beginAppendRow();
					
					grid1.setValue(0,'timeAndAttendanceYyyymm', month + "/"+ year);
					grid1.setValue(0,'periodFromDate', "01/"+ month + "/"+ year);
					grid1.setValue(0,'periodToDate', now + "/"+ month + "/"+ year);
					grid1.setValue(0,'perfectAttendanceDays', workDay);
					grid1.setValue(0,'unpaidApplyDate', "03"); //HMT_20210720
					grid1.setValue(0,'confirmFlag', "N");
				}
				
				break;
			case 'save':
				var grid1 = grid.getGridBase();
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
				
				if(isNull(grid1.getValue(0,'periodCloseDate'))) {
					Message.alert("<lgcom:message code="note.att.checkPeriodCloseDate"/>");
					return;
				}
				//HMT_20210720 Start
				var now = DateUtil.format(DateUtil.today().set('date', 1), 'DD/MM/YYYY');
				var now_str = now.substring(10,6) + now.substring(5,3)+ now.substring(2,0)
				if (!isNull(grid1.getValue(0,'unpaidApplyDate'))) {
					var applyDate = grid1.getValue(0,'unpaidApplyDate').substring(10,6) + grid1.getValue(0,'unpaidApplyDate').substring(5,3) + grid1.getValue(0,'unpaidApplyDate').substring(2,0);
					if (applyDate <= now_str) {
						grid1.setValue(0, 'unpaidApplyDate', null);
						Message.alert("<lgcom:message code='note.att.unpaidApplyDateGreaterCurrentDate'/>");
						return;
					}
				}
				if (!isNull(grid1.getValue(0,'periodFromDate')) && !isNull(grid1.getValue(0,'unpaidPeriodDate'))) {
					if (grid1.getValue(0,'periodFromDate').substring(10,3) != grid1.getValue(0,'unpaidPeriodDate').substring(10,3)) {
						grid1.setValue(0, 'unpaidPeriodDate', null);
						Message.alert("<lgcom:message code='label.att.mustChooseSameMonth'/>");
						return;
					}
				}
				//HMT_20210720 End
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					var periodToDate = grid1.getValue(0,'periodToDate').replaceAll("/","");
					var periodCloseDate = grid1.getValue(0,'periodCloseDate').replaceAll("-","");
					if (!isNull(grid1.getValue(0,'periodFromDate')) && !isNull(grid1.getValue(0,'periodFromDate')) && !isNull(grid1.getValue(0,'unpaidPeriodDate'))) { //HMT_20220705
						if (grid1.getValue(0,'periodFromDate').substring(10,3) != grid1.getValue(0,'unpaidPeriodDate').substring(10,3)) {
							grid1.setValue(0, 'unpaidPeriodDate', null);
							Message.alert("<lgcom:message code='label.att.mustChooseSameMonth'/>");
							return;
						}
					}
					if(!isValidDateBetween(grid1.getValue(0,'periodToDate'), grid1.getValue(0,'periodCloseDate').substr(0,10))) {
						Message.alert("<lgcom:message code="note.att.checkPeriodCloseDate"/>");
						return;
					}else{ 
						
						grid.useProgress(true);
						grid.saveChanges('lgvhr','lgvatt/LGVATT50010/saveAttendanceClose', function(data, gridData ) {
							Message.alert('<lgcom:message code="note.completed"/>');
							myForm.select(".searchBlock button[data-action='search']").trigger('click');
						});
					 } 
				});
				break;
				case 'confirm':
					var grid1 = grid.getGridBase();
					var confirmFlag = grid1.getValue(0,'confirmFlag');
					var timeAndAttendanceYyyymm = grid1.getValue(0,'timeAndAttendanceYyyymm');
					if( grid.getRowCount() == 0 ) {
						Message.alert('<lgcom:message code="note.nodata"/>');
						return;
					};
					if(confirmFlag == "N") {
						Message.confirm('<lgcom:message code="question.confirm"/>', function() {
							if(!isValidDateBetween(grid1.getValue(0,'periodToDate'), grid1.getValue(0,'periodCloseDate').substr(0,10))) {
								Message.alert("<lgcom:message code="note.att.checkPeriodCloseDate"/>");
								return;
							}else{ 
								grid.useProgress(true);
								var parameter = {timeAndAttendanceYyyymm : timeAndAttendanceYyyymm};
								
								myForm.transaction("lgvhr", "lgvatt/LGVATT50010/saveConfirmAttendanceClose", parameter, function( data ){
									Message.alert('<lgcom:message code="note.completed"/>');
									myForm.select(".searchBlock button[data-action='search']").trigger('click');
								}); 
							}
						});
					}
					
				break;
				case 'reportDown':
					
					Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
						
						var options = {
								multiSheet: true
						};
						var downloader = new Downloader( myForm, options );
						// 임시로 처리 하는거임
						var param = {
								timeAndAttendancdYyyymm : srchFormUtil.getValue('timeAndAttendanceYyyymm'),
								report : [
									{
										sheetName : 'Working Time Sheet'
									},
									{
										sheetName : 'OT15'
									},
									{
										sheetName : 'OT20'
									},
									{
										sheetName : 'OT30'
									},
									{
										sheetName : 'Night20'
									},
									{
										sheetName : 'Night21'
									},
									{
										sheetName : 'Night27'
									},
									{
										sheetName : 'Night39'
									},
									{
										sheetName : '2S-Night30+'
									}
								]
								
						};
						
						downloader.excel("lgvhr", "lgvatt/LGVATTCOMM/createExcelMonthReport", param );
					}, function(){
						
					});
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
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		//필드 설정
		grid.setFields([
		    { fieldName: 'timeAndAttendanceYyyymm'  , dataType:'text'},
		    { fieldName: 'periodFromDate'         	, dataType:'text'},
		    { fieldName: 'periodToDate'         	, dataType:'text'},
		    { fieldName: 'perfectAttendanceDays'    , dataType:'text'},
		    { fieldName: 'unpaidPeriodDate'         , dataType:'text'}, //HMT_20210720
		    { fieldName: 'unpaidApplyDate'          , dataType:'text'}, //HMT_20210720
		    { fieldName: 'periodCloseDate'         	, dataType:'text'},
		    { fieldName: 'periodCloseTime'         	, dataType:'text'},
		    { fieldName: 'confirmFlag'         		, dataType:'text'}
		]);
		// Lookup 설정
		grid.setLookups({
			cfmflag:code.get('flag')
		});
		//컬럼 설정
		grid.setColumns([
 				{
					name:'timeAndAttendanceYyyymm',
					fieldName:'timeAndAttendanceYyyymm',
					width:150,
					header: {text:'<lgcom:message code="label.att.month" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'periodFromDate',
					fieldName:'periodFromDate',
					width:200,
					header: {text:'<lgcom:message code="label.att.startDate" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'periodToDate',
					fieldName:'periodToDate',
					width:200,
					header: {text:'<lgcom:message code="label.att.endDate"/>'},
					styles: {textAlignment:'center'},
					editable : false
				},	
				{
					name:'perfectAttendanceDays',
					fieldName:'perfectAttendanceDays',
					width:200,
					header: {text:'<lgcom:message code="label.att.attendanceDays" />'},
					styles: {textAlignment:'center'},
					editable : false
				},	
				{
					name:'periodCloseDate',
					fieldName:'periodCloseDate',
					width:200,
					header: {text:'<lgcom:message code="label.att.attendanceCloseDate" />'},
					styles: {textAlignment:'center'},
					editor: {type:'date',datetimeFormat:'dd/MM/yyyy hh:mm'}
				},	
				//HMT_20210720 Start
				{
					name:'unpaidPeriodDate',
					fieldName:'unpaidPeriodDate',
					width:200,
					header: {text:'<lgcom:message code="label.att.unpaidPeriodDate" />'},
					styles: {textAlignment:'center'},
					editor: {type:'date',datetimeFormat:'dd/MM/yyyy'}
				},
				{
					name:'unpaidApplyDate',
					fieldName:'unpaidApplyDate',
					width:200,
					header: {text:'<lgcom:message code="label.att.unpaidApplyDate" />'},
					styles: {textAlignment:'center'},
					editor: {type:'date',datetimeFormat:'dd/MM/yyyy'}
				},
				//HMT_20210720 End
				{
					name:'confirmFlag',
					fieldName:'confirmFlag',
					width:80,
					type: 'data',
					header: {text:'<lgcom:message code="label.att.confirmFlag" />'},
					styles: {textAlignment:'center'},
					lookupDisplay: true,
					lookupSourceId: 'cfmflag',
					lookupKeyFields: ['confirmFlag']
					//editor: {type:'dropDown', textReadOnly : true,editable: true}
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
	
	function searchList() {
		var param = srchFormUtil.getValue();
		grid.loadData('lgvhr','lgvatt/LGVATT50010/retrieveAttendanceClose', param);
	}
	function isValidDateBetween(dateFrom, dateTo) {

		var startDateArr = dateFrom.split('/');
		var endDateArr = dateTo.split('/');
		var isValid = false;
		
		var startDateCompare = new Date(startDateArr[2], parseInt(startDateArr[1])-1, startDateArr[0]);
		var endDateCompare = new Date(endDateArr[2], parseInt(endDateArr[1])-1, endDateArr[0]);
		
		if(startDateCompare.getTime() < endDateCompare.getTime()) {
			isValid = true;
		}
		return isValid;
	}
}

LGVATT50010.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVATT50010();
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
		                    <th><label class="required"><lgcom:message code="label.att.month"/></label></th>
		                    <td>
		                        <div class="form-inline ">
                                <select class="form-control input-sm input-require" name="timeAndAttendanceYyyymm" id="timeAndAttendanceYyyymm"></select>
								    <!-- <button type="button" id="setSingleDateSample" class="btn btn-ico" aria-label="calendar">
								        <span class="ico ico-calendar" aria-hidden="true"></span>
								    </button> -->
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
			<div class="btn-group">					      
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="save"/></button>
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="confirm"><lgcom:message code="button.att.confirm"/></button>
				<button class="btn btn-default btn-sm" type="button" data-action="reportDown"><span class="ico ico-excel-down"></span> <lgcom:message code="Report"/></button>
			</div>
	</div>
		<div class="gridContent grid-wrap">
			<div class="grid attendanceCloseGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
