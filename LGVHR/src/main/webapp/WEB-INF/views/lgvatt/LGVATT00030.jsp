<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="devonframe.util.DateUtil" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%---------------------------------------------------------
    파일명 : LGVATT00030.jsp
    프로젝트명 : VHR LGD

    설 명 : Employee Shift Group Info
    작성자 : HMT_20221108 Add Employee Shift Group Info Interface
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Employee Shift Group Info</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<style type="text/css">
</style>
<script type="text/javascript">

var LGVATT00030 = function(){
    var grid;
    var _this = this;
    var myForm = this;
    var srchForm = '.searchBlock form';
    var formUtil = new FormUtil(myForm,'.searchBlock form');
    var validator = new Validator( myForm, srchForm );
    
    /* Layout Setting 하측 고정, 상측 Flexible*/
	myForm.setLayout( [ 
		{ name  : "searchBlock", left : 0, right : 0, top : 0 },		
		{ name  : "gridControls", left : 0, right : 0, top : "searchBlock"},
		{ name  : "content1", left : 0, right : 0, top : "gridControls", bottom : 0 }
	]);

  	//검색조건에 값을 입력하고 조회하면 방금 입력한 값을 저장하여 화면에 고정값으로 셋팅 
    myForm.searchConditionControl( true );
    transaction_sync( "lgvhr","lgvatt/LGVATT50030/retrieveAttendanceYyyymm", {}, function(data) {
    	if ( data.result ) {
    		yyyymmList = data.result.yyyymmList;
    		
    		formUtil.initCombo("attendanceYm", data.result.yyyymmList,   {selectAll:false});
    		formUtil.setValue({attendanceYm: data.result.currentYyyymmData.attendanceYyyymm});
    	}
    });
    
	// grid & serachBlock combo
	var code = new CommonCode('lgcom');
	code.add('shiftGroup',{codeTypeCode:'LGVHR_SHIFT_GROUP'});
	code.add('shiftCode', {codeTypeCode:'LGVHR_SHIFT_TYPE_CODE'});
	code.add('gradeTitle', {codeTypeCode:'IF_VIETNAM_GRADE_TITLE'});
	code.execute();
	
	var valueSet = new ValueSet("lgcom");
	valueSet.add('attCode', {valueSetId : 'LGVATT_ATTEND_DETAIL'});
	valueSet.add('attTypeName', {valueSetId : 'LGVATT_ATTEND_TYPE_UPDATE_ENABLE'});
	valueSet.add("attendanceDetailCodeList", {valueSetId : "LGVATT_ATTEND_DETAIL_CODE", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}"} );
	valueSet.execute();
	
	// 전체 조직 리스트를 ValueSet으로 사용하기위한 조회
	var allOrgList = {};
	myForm.transaction_sync("lgvhr", "lgvatt/LGVATTCOMM/retrieveAllOrgList", {}, function(data) { 
		if ( data.result.length > 0 ) {
			allOrgList = data.result;
		}
	});
	
	formUtil.initCombo('shiftCode', code.get('shiftCode'), { selectAll: true });
	formUtil.initCombo('shiftGroup', code.get('shiftGroup'), { selectAll: true });
	
   	grid = buildGrid("LGVATT00030_grid");
	
	myForm.popupInfo = {
        userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', attDate:'', userData:[]},
        returnPopup : {returnComment:''}
    };
	
	myForm.popupInfoOrg = {
	        orgPopup   : {searchMode:'single', popupKind:'', confirmKind:'', orgName:'', orgData:[]},
	        returnPopup : {returnComment:''}
	};
	
	/*** 이벤트 핸들러  ***/
	
	this.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
		    case "search" :
		    	grid.getGridBase().cancel();
				var param =  myForm.select(".searchBlock form").toJSON();
				
				myForm.showProgress();
				grid.loadData('lgvhr','lgvatt/LGVATT00030/retrieveMonthlyEmpGroupList', param, function(data){
					if( data.result.length > 0 ) {
						var index = {itemIndex: 0};
						grid.getGridBase().setCurrent(index);
					} else {
						Message.alert('<lgcom:message code="note.nodata"/>');
					}
					myForm.hideProgress();
				} );
				
				break;
			// 유저 검색 팝업
		    case "openPopupUser" :
                var _popup = _this.popupInfo.userPopup;
                _popup.searchMode   = "single";
                _popup.popupKind    = "";
                _popup.confirmKind  = "";
                _popup.employeeNo = formUtil.getValue("empNo");
                _popup.employeeName = formUtil.getValue("empName");

                var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
                popup.setSize(800,494);
                popup.open( function(){
                    formUtil.setValue({empNo   :_popup.userData[0].employeeNo});
                    formUtil.setValue({empName :_popup.userData[0].employeeName});
                    formUtil.setValue({orgId   :_popup.userData[0].organizationId});
                    formUtil.setValue({orgName :_popup.userData[0].organizationName});
                });
                _popup.userData = [];
                break;
            // 조직 검색 팝업
		    case "openPopupOrg" :
                var _popup = _this.popupInfoOrg.orgPopup;
                _popup.searchMode   = "single";
                _popup.popupKind    = "";
                _popup.confirmKind  = "";
                _popup.orgName = formUtil.getValue("orgName");
                
                var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1014', 'Org Search' );
                popup.setSize(800,494);
                popup.open( function(){
                    formUtil.setValue({orgId   :_popup.orgData[0].organizationId});
                    formUtil.setValue({orgName :_popup.orgData[0].organizationName});
                });
                _popup.orgData = [];
                break;
            
            // excel download monthly report
		    case "excelDown" :
		    	if(validator.isValid()) {
					Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
						var param = formUtil.getValue();
						var downloader = new Downloader( myForm );
						downloader.excel( "lgvhr", "lgvatt/LGVATT00030/createExcelExportData", param );
					});
				}
				break;
		}
	});
	myForm.addEvent ( "change", ".searchBlock form input[name]", function(event) {
		var item = $(event.target);
		switch ( $.trim(item.attr("name")) ) {
			case "empNo" :
				//사번이 변경된 경우 성명 삭제
				if ( nvl(formUtil.getValue("empNo")) != nvl(formUtil.getPreviousValue("empNo")) ) {
					formUtil.setValue("empName", "");
				}
				break;
		}			
		event.stopPropagation();
	});
	
	
	/*** 내부 함수  ***/
	
    /*** 그리드 초기 셋업  ***/
	function buildGrid(gridId) {
		var grid;
		switch(gridId){
			case 'LGVATT00030_grid':
				grid = new RealGrid(myForm, gridId, true);
				grid.setPagingMode(true, {rowSize:3000});
				
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
						paste: { enabled: false},
						sortMode: "explicit",
						edit: {
							insertable: false,
							appendable: false,
							updatable: false,
							deletable: false
						},
						header:{
					         height: 35,
					         heightFill: 'fixed',
					         showTooltip: true
					    }
					},
					dataProvider: {
						insertable: false,
						updatable: false,
						deletable: false,
						softDeleting: false,
						deleteCreated: false
					}
				});

				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();

				//필드 설정
				grid.setFields(
						[
							{ fieldName:'employee'     					, dataType:'text'},
							{ fieldName:'employeeOrg'	        		, dataType:'text'},
							{ fieldName:'employeeNo'	        		, dataType:'text'},
							{ fieldName:'employeeName' 	        		, dataType:'text'},
							{ fieldName:'employeeGrade' 	        	, dataType:'text'},
							
							{ fieldName:'attendanceYm'      			, dataType:'text'},
							{ fieldName:'actualShiftCode'         		, dataType:'text'},
							{ fieldName:'dateHireSubsidiary'         	, dataType:'text'},
							
							{ fieldName:'workingDay'	        		, dataType:'text'},
							{ fieldName:'workingDayShiftTypeCode'    	, dataType:'text'},
							{ fieldName:'weeklyHoliday' 	     		, dataType:'text'},
							{ fieldName:'weeklyHolidayShiftTypeCode' 	, dataType:'text'},
							{ fieldName:'weekCode'						, dataType:'text'},
							{ fieldName:'shiftGroup'    				, dataType:'text'}
						]
				);

				grid.setLookupsMultiLvl({
					 			'employeeGrade': code.get("gradeTitle"),
					 			'attendanceType': valueSet.get("attTypeName"),
					 			'orgList': {data: allOrgList}
					 		}); 
				
				//컬럼 설정
				grid.setColumns(
						[
							{	name:'employeeNo',    
								fieldName:'employeeNo',    
								width:70,  
								header: {text:'<lgcom:message code="label.att.id" />'},	 
								editable: false, 
								styles: {textAlignment:'near'}
							},
							{	name:'employeeName',  
								fieldName:'employeeName',  
								width:150, 
								header: {text:'<lgcom:message code="label.att.employeeName" />'},	 
								editable: false, 
								styles: {textAlignment:'near'}
							},
							{	name:'employeeGrade', 
								fieldName:'employeeGrade', 
								width:80,  
								lookupDisplay: true,
								lookupSourceId: 'employeeGrade',
								lookupKeyFields: ['employeeGrade'], 
								header: {text:'<lgcom:message code="label.att.jobTitle" />'},
								editable: false,
								styles: {textAlignment:'near'}
							},
							{	name:'actualShiftCode',
								fieldName:'actualShiftCode',
								width:80,
								header: {text:'<lgcom:message code="label.att.actualShiftCode" />'},
								editable: false,
								styles: {textAlignment:'near' }
							},
							{	name:'employeeOrg',
								fieldName:'employeeOrg',
								width:250,
								header: {text:'<lgcom:message code="label.att.organization"/>'},
								lookupDisplay: true,
								lookupSourceId: 'orgList',
								lookupKeyFields: ['employeeOrg'], 
								editable:false,
								styles: {textAlignment:'near'},
							},
							{
								name:'dateHireSubsidiary',
								fieldName:'dateHireSubsidiary',
								width:120,
								type: 'data',
								header: {text:'<lgcom:message code="label.pay.hireDate" />'},
								styles: {textAlignment:'center'},
								editable : false
							},
							{
								name:'weeklyHoliday',
								fieldName:'weeklyHoliday',
								width:120,
								type: 'data',
								header: {text:'<lgcom:message code="label.att.weeklyHoliday" />'},
								styles: {textAlignment:'center'},
								editable : false
							},
							{	name:'weeklyHolidayShiftTypeCode',
								fieldName:'weeklyHolidayShiftTypeCode',
								width:80,
								header: {text:'<lgcom:message code="label.att.weeklyHolidayShiftType"/>'},
								styles: {textAlignment:'center'},
								editable: false
							},
							{
								name:'workingDay',
								fieldName:'workingDay',
								width:120,
								type: 'data',
								header: {text:'<lgcom:message code="label.att.workingDay" />'},
								styles: {textAlignment:'center'},
								editable : false
							},
							{	name:'workingDayShiftTypeCode',
								fieldName:'workingDayShiftTypeCode',
								width:80,
								header: {text:'<lgcom:message code="label.att.workingDayShiftType"/>'},
								styles: {textAlignment:'center'},
								editable: false
							},
							{
								name:'weekCode',
								fieldName:'weekCode',
								width:80,
								type: 'data',
								header: {text:'<lgcom:message code="label.att.dayOfWeek" />'},
								styles: {textAlignment:'center'},
								editable : false
							},
							{
								name:'shiftGroup',
								fieldName:'shiftGroup',
								width:180,
								type: 'data',
								header: {text:'<lgcom:message code="label.att.groupName" />'},
								styles: {textAlignment:'center'},
								editable : false
							}
							
						]
				);
				break;
		}
		return grid;
	}
}

LGVATT00030.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT00030();
		form.init();
	});
});

</script>
<style>
</style>
</head>

<body>
<div class="mdi-container">
	<section class="page-content">
		<div class="pageHeader">
		    <h2>Inquiry Monthly Attendance</h2>
		</div>
	
		<div class="searchBlock">
		    <form class="form search-wrap">
		    	<input type="hidden" name="orgId"/>
				<fieldset>
					<table class="table">
						<colgroup>
							<col width="90"/>
							<col width="220"/>
							<col width="90" />
							<col width="100"/>
							<col width="90" />
							<col width="200" />
							<col width="*"  />
						</colgroup>
						<tbody>
			                <tr>
			                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.att.month"/></label></th>
			                    <td>
			                        <div class="form-inline ">
		                                <select class="form-control input-sm input-require" name="attendanceYm" id="attendanceYm"></select>
	                            	</div>
			                    </td>
								
								<th><label><lgcom:message code="label.att.groupName" /></label></th>
								<td><select class="form-control input-sm size_150" name="shiftGroup"></select></td>
								
			                </tr>
			                <tr>
								<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.att.organization" /></label></th>
								<td>
			                		<div class="input-group input-group-sm input-search">
		                                <input class="form-control input-sm _find_origin_" name="orgName" type="text">
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
		                                <input class="form-control input-sm _find_origin_" name="empNo" type="text">
		                                <span class="input-group-btn">
		                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupUser">
		                                        <span class="fa fa-search" aria-hidden="true"></span>
		                                    </button>
		                                </span>
		                            </div>
			                	</td>
								
								<th><label><lgcom:message code="label.att.employeeName" /></label></th>
								<td><input type="text" class="form-control input-sm" name="empName" readonly></td>
								
			                </tr>
						</tbody>
					</table>
				</fieldset>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search" ><lgcom:message code="search" /></button>
		    </form>
		</div>
		
		<%-- 그리드 버튼 영역 --%>
		<div class="gridControls gridControls1 module-group text-right">
			<div class="btn-toolbar">	
				<div class="btn-group">
					<button class="btn btn-default btn-sm" type="button" data-action="excelDown"><span class="ico ico-excel-down"></span> <lgcom:message code="Download"/></button>
		 		</div>
	        </div>	
	    </div>
		
		<div class="content content1 grid-wrap" >
		    <div id="LGVATT00030_grid" class="grid"></div>
		</div>
	</section>
</div>
</body>
</html>
