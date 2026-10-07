<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT50030.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : 연간휴가 조회
    작성자 : bakderia
    2021/04/24 HMT_20210424 Add dateHireSubsidiary
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script type="text/javascript">
var LGVATT50030 = function() {
	var myForm = this;
    var _this = this;
	var result;
	// Form Util 선언
	var srchForm = '.searchBlock form';
	var srchFormUtil = new FormUtil( myForm, srchForm );
	var gridContent = new FormUtil(myForm,'.gridContent form');
	
	// Search Block combo
	var valueSet = new ValueSet("lgcom");
	valueSet.add('orgName', {valueSetId : 'LGVATT_LW_ADMIN_ORG_NAME', employeeNum : '${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}', subsidiaryCode : '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}'});
	valueSet.execute(); 
	
	srchFormUtil.initCombo('orgName',valueSet.get('orgName'),{selectAll: true});
	
	//HMT_20210424 Start
	//var dateFrom = DateUtil.format(DateUtil.today().add(-1,'month').set('date',1), 'DD/MM/YYYY');
	var dateFrom = DateUtil.format('01/01/2016', 'DD/MM/YYYY');
	srchFormUtil.setValue( {
    	hireStartDate : dateFrom,
        hireEndDate : DateUtil.today("DD/MM/YYYY"),
        confirmFlag : 'N'
    });
	srchFormUtil.setCalendar( { from : "hireStartDate", to : "hireEndDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
	//HMT_20210424 End
    transaction_sync( "lgvhr","lgvatt/LGVATT50030/retrieveAttendanceYyyymm", {}, function(data) {
    	if ( data.result ) {
    		var yyyymmList = data.result.yyyymmList;
    		
    		srchFormUtil.initCombo("timeAndAttendanceYyyymm", data.result.yyyymmList,   {selectAll:false});
    		srchFormUtil.setValue({timeAndAttendanceYyyymm: data.result.currentYyyymmData.attendanceYyyymm});
    	}
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
	var grid = buildGrid('.attendanceLeaveGrid');

	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	myForm.popupInfo = {
		userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', userData:[]},
        returnPopup : {returnComment:''}
    };
	
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
				// 유저 검색 팝업
		    case "openPopupApprover" :
                console.log("openPopupApprover");
                var _popup = _this.popupInfo.userPopup;
                _popup.searchMode   = "single";
                _popup.popupKind    = "";
                _popup.confirmKind  = "";
                _popup.employeeNo = srchFormUtil.getValue("employeeNo");
                _popup.employeeName = srchFormUtil.getValue("employeeName");

                var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
                popup.setSize(800,494);
                popup.open( function(){
                	srchFormUtil.setValue({employeeNo  :_popup.userData[0].employeeNo});
                	srchFormUtil.setValue({employeeName   :_popup.userData[0].employeeName});
                	srchFormUtil.setValue({orgName   :_popup.userData[0].organizationId});
                });
                _popup.userData = [];
            break;
		    case "excelDown" :
		    	var param =  myForm.select(".searchBlock form").toJSON();
				Message.confirm( "<lgcom:message code='question.excelDownload' />", function(){

					var downloader = new Downloader( myForm );
				    downloader.excel( "lgvhr", "lgvatt/LGVATT50030/excelDownData", param );

				});
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
		    { fieldName: 'employeeNo'         		, dataType:'text'},
		    { fieldName: 'employeeName'         	, dataType:'text'},
		    { fieldName: 'employeeGrade'    		, dataType:'text'},
		    { fieldName: 'orgNameLocal'      		, dataType:'text'},
		    { fieldName: 'dateHireSubsidiary'       , dataType:'text'}, //HMT20210424
		    { fieldName: 'prevYearCarrFwdDays'      , dataType:'text'},
		    { fieldName: 'currYearAccuCreationDays' , dataType:'text'},
		    { fieldName: 'totalCreationDays'        , dataType:'text'},
		    { fieldName: 'currMonthUseDays'         , dataType:'text'},
		    { fieldName: 'totalUseDays'        		, dataType:'text'},
		    { fieldName: 'totalResidualDays'        , dataType:'text'}
		]);
		// Lookup 설정
		grid.setLookups({
			//cfmflag:code.get('flag')
		});
		//컬럼 설정
		grid.setColumns([
 							{
								type:'group',
								name:'employee',
								fieldName:'employee',
								width:520,
								header:{
							         text:'<lgcom:message code="label.att.employee" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
								            {	name:'employeeNo',   
								            	fieldName:'employeeNo',  
								            	width:80, 
								            	header: {text:'<lgcom:message code="label.att.id" />'}, 
								            	editable: false,
								            	styles: {textAlignment:'center'}
								            },
								            {	name:'employeeName', 
								            	fieldName:'employeeName',
								            	width:130,
								            	header: {text:'<lgcom:message code="label.att.employeeName" />'},  
								            	editable: false,
								            	styles: {textAlignment:'near'}
								            },
								            {	name:'employeeGrade',
								            	fieldName:'employeeGrade',
								            	width:100,  
												header: {text:'<lgcom:message code="label.att.jobTitle" />'}, 
								            	editable: false,
								            	styles: {textAlignment:'near'}
											},
								            {	name:'orgNameLocal',
								            	fieldName:'orgNameLocal',
								            	width:220,  
												header: {text:'<lgcom:message code="label.att.organization" />'}, 
								            	editable: false,
								            	styles: {textAlignment:'near'}
											},
											//HMT20210424 Start
											{	name:'dateHireSubsidiary',
								            	fieldName:'dateHireSubsidiary',
								            	width:150,  
												header: {text:'<lgcom:message code="label.pay.hireDate" />'}, 
								            	editable: false,
								            	styles: {textAlignment:'center'}
											}
											//HMT20210424 End
								         ]
							},
							{
								type:'group',
								name:'annualLeave',
								fieldName:'annualLeave',
								width:810,
								header:{
							         text:'<lgcom:message code="label.att.leave" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
								            {	name:'prevYearCarrFwdDays',   
								            	fieldName:'prevYearCarrFwdDays',  
								            	width:120, 
								            	header: {text:'<lgcom:message code="label.att.accmulationFromLastYear" />'}, 
								            	editable: false,
								            	styles: {textAlignment:'far'}
								            },
								            {	name:'currYearAccuCreationDays', 
								            	fieldName:'currYearAccuCreationDays',
								            	width:130,
								            	header: {text:'<lgcom:message code="label.att.createAtThisYear" />'},  
								            	editable: false,
								            	styles: {textAlignment:'far'}
								            },
								            {	name:'totalCreationDays',
								            	fieldName:'totalCreationDays',
								            	width:140,  
												header: {text:'<lgcom:message code="label.att.totalAnnualLeaveOfThisYear" />'}, 
								            	editable: false,
								            	styles: {textAlignment:'far'}
											},
											{	name:'currMonthUseDays',   
								            	fieldName:'currMonthUseDays',  
								            	width:150, 
								            	header: {text:'<lgcom:message code="label.att.usedAnnualLeaveAtThisMonth" />'}, 
								            	editable: false,
								            	styles: {textAlignment:'far'}
								            },
								            {	name:'totalUseDays',
								            	fieldName:'totalUseDays',
								            	width:160,  
												header: {text:'<lgcom:message code="label.att.totalUsedAnnualLeaveOfThisYear" />'}, 
								            	editable: false,
								            	styles: {textAlignment:'far'}
											},
											{	name:'totalResidualDays',   
								            	fieldName:'totalResidualDays',  
								            	width:110, 
								            	header: {text:'<lgcom:message code="label.att.remainedAnnualLeave" />'}, 
								            	editable: false,
								            	styles: {textAlignment:'far'}
								            }
								         ]
							}
		]);
		//옵션 설정
		grid.setOptions({
					grid: {
						softDeleting: false,
						deleteCreated: false,
						hideDeletedRows: false,
						indicator: {visible: false},
						panel: {visible: false},
						checkBar: {visible: false},
						stateBar: {visible: false},
						footer: {visible: false},
						paste: {enabled:false}, /*paste 기능막기 */
						sorting  : {enabled:false}, /*Sorting 기능을 막는다.*/
		                sortMode : "explicit",
						edit: {
							insertable: false,
							appendable: false,
							updatable: false,
							deletable: false
						},
						header:{
							heightFill: 'fixed',
					        height: 50
					    }
					},
					dataProvider: {
						insertable: false,
						updatable: false,
						deletable: false,
						softDeleting: false,
						deleteCreated: false
					},
					display: { fitStyle: 'none' }
				});

		// Context Menu Set
		grid.setContextMenu();

		return grid;
	}
	
	function searchList() {
		var param = srchFormUtil.getValue();
		grid.loadData('lgvhr','lgvatt/LGVATT50030/retrieveAttendanceLeave', param, function(data){
			if( grid.getDataProvider().getRowCount() == 0 ) {
				Message.alert('<lgcom:message code="note.nodata"/>');
			} else {
				if(grid.getDataProvider().getRowCount() > 0){
		    		var index = {itemIndex: 0};
					grid.getGridBase().setCurrent(index);
		    	}
			}
			
		} );
	}
}

LGVATT50030.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVATT50030();
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
                            	</div>
		                    </td>
		                    <th><label><lgcom:message code="label.att.organization" /></label></th>
							<td><select class="form-control input-sm input-require" name="orgName"></select></td>
							<th><label><lgcom:message code="label.pay.hireDate"/></label></th>
							<td>
		                        <div class="form-inline">
                                <input type="text" class="form-control input-sm input-require" name="hireStartDate" id="<c:out value="${ui_bizform_id}"/>_hireStartDate" placeholder="dd/mm/yyyy" style="width: 85px;" maxlength="10" onkeyup="return auto_date_format(event, this)" onkeypress="auto_date_format(event, this)">
                                ~
                                <input type="text" class="form-control input-sm input-require" name="hireEndDate" id="<c:out value="${ui_bizform_id}"/>_hireEndDate" placeholder="dd/mm/yyyy" style="width: 85px;" maxlength="10" onkeyup="return auto_date_format(event, this)" onkeypress="auto_date_format(event, this)">
                                <button type="button" id="setSingleDateSample" class="btn btn-ico" aria-label="calendar">
							        <span class="ico ico-calendar" aria-hidden="true"></span>
							    </button>
                            	</div>
		                    </td>
		                </tr>
		                <tr>
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
		<%-- 그리드 버튼 영역 --%>
	<div class="gridControls module-group text-right">
		<div class="btn-toolbar">
			<div class="btn-group">
				<button class="btn btn-default btn-sm" type="button" data-action="excelDown"><span class="ico ico-excel-down"></span> <lgcom:message code="Download"/></button>
			</div>
		</div>
	</div>
		<div class="gridContent grid-wrap">
			<div class="grid attendanceLeaveGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
