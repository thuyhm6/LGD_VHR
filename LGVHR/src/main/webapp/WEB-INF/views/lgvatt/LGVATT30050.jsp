<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="devonframe.util.DateUtil" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%---------------------------------------------------------
    파일명 : LGVATT30050.jsp
    프로젝트명 : VHR LGD

    설 명 : Employee Monthly OT Level Report
    작성자 : HMT
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Employee Monthly OT Level Report</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<style type="text/css">
</style>
<script type="text/javascript">

var LGVATT30050 = function(){
    var grid;
    var _this = this;
    var myForm = this;
    var formUtil = new FormUtil(myForm,'.searchBlock form');
    
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
	code.add('otLevelCheck',{codeTypeCode:'LGVHR_OT_LEVEL_CHECK'});
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
	formUtil.initCombo('otLevelCheck', code.get('otLevelCheck'), { selectAll: true });
	
   	grid = buildGrid("LGVATT30050_grid");
	
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
				
				if( isNull(formUtil.getValue("orgId")) ) {
					Message.alert('<lgcom:message code="note.att.essentialOrg"/>');
					return;
				}
				
				myForm.showProgress();
				grid.loadData('lgvhr','lgvatt/LGVATT30050/retrieveMonthlyEmpLevelList', param, function(data){
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
		    	grid.getGridBase().exportGrid({
	    			target: "local",
	    			lookupDisplay: true,
		    		showProgress: true,
		    		done: function() {
		    			Message.alert("Excel exporting completed!!");
		    		}
		    	});
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
			case 'LGVATT30050_grid':
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
					         height: 25,
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
							{ fieldName:'employee'     					, dataType:'text'  },
							{ fieldName:'employeeOrg'	        		, dataType:'text'  },
							{ fieldName:'employeeNo'	        		, dataType:'text'  },
							{ fieldName:'employeeName' 	        		, dataType:'text'  },
							{ fieldName:'employeeGrade' 	        	, dataType:'text'  },
							
							{ fieldName:'attendanceYm'      			, dataType:'text'  },
							{ fieldName:'actualShiftCode'         		, dataType:'text'  },
							{ fieldName:'dateHireSubsidiary'         	, dataType:'text'  },
							
							{ fieldName:'level0'	        			, dataType:'number'},
							{ fieldName:'level1' 	     				, dataType:'number'},
							{ fieldName:'level2'						, dataType:'number'},
							{ fieldName:'level3'    					, dataType:'number'},
							{ fieldName:'level4'	 		      		, dataType:'text'},
							
							{ fieldName:'levelRequested'                , dataType:'text'},
							{ fieldName:'levelActual'                   , dataType:'text'},
							{ fieldName:'totalOvertime'                 , dataType:'number'},
							
							{ fieldName:'otCheck'     					, dataType:'text'  },
							{ fieldName:'baseAttFlag'     				, dataType:'text'}
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
								width:150,
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
								width:100,
								type: 'data',
								header: {text:'<lgcom:message code="label.pay.hireDate" />'},
								styles: {textAlignment:'center'},
								editable : false
							},
							{
								name:'attendanceYm',
								fieldName:'attendanceYm',
								width:80,
								type: 'data',
								header: {text:'<lgcom:message code="label.att.month" />'},
								styles: {textAlignment:'center'},
								editable : false
							},
							{
								name:'level0',
								fieldName:'level0',
								width:80,
								type: 'data',
								header: {text:'<lgcom:message code="label.att.level0" />'},
								styles: {textAlignment:'center'},
								editable : false
							},
							{
								name:'level1',
								fieldName:'level1',
								width:80,
								type: 'data',
								header: {text:'<lgcom:message code="label.att.level1" />'},
								styles: {textAlignment:'center'},
								editable : false
							},
							{
								name:'level2',
								fieldName:'level2',
								width:80,
								type: 'data',
								header: {text:'<lgcom:message code="label.att.level2" />'},
								styles: {textAlignment:'center'},
								editable : false
							},
							{
								name:'level3',
								fieldName:'level3',
								width:80,
								type: 'data',
								header: {text:'<lgcom:message code="label.att.level3" />'},
								styles: {textAlignment:'center'},
								editable : false
							},
							{
								name:'level4',
								fieldName:'level4',
								width:80,
								type: 'data',
								header: {text:'<lgcom:message code="label.att.level4" />'},
								styles: {textAlignment:'center'},
								editable : false
							},
							{
								name:'levelRequested',
								fieldName:'levelRequested',
								width:120,
								type: 'data',
								header: {text:'<lgcom:message code="label.att.levelRequested" />'},
								styles: {textAlignment:'center'},
								editable : false
							},
							{
								name:'levelActual',
								fieldName:'levelActual',
								width:120,
								type: 'data',
								header: {text:'<lgcom:message code="label.att.levelActual" />'},
								styles: {textAlignment:'center'},
								editable : false
							},
							{
								name:'totalOvertime',
								fieldName:'totalOvertime',
								width:120,
								type: 'data',
								header: {text:'<lgcom:message code="label.att.totalOvertime" />'},
								styles: {textAlignment:'center'},
								editable : false
							},
							{
								name:'otCheck',
								fieldName:'otCheck',
								width:120,
								type: 'data',
								header: {text:'<lgcom:message code="label.att.otCheck" />'},
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

LGVATT30050.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT30050();
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
								
								<th><label><lgcom:message code="label.att.shiftCode" /></label></th>
								<td><select class="form-control input-sm" name="shiftCode"></select></td>
								
								<th><label><lgcom:message code="label.att.otCheck" /></label></th>
								<td><select class="form-control input-sm size_80" name="otLevelCheck"></select></td>
								
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
		    <div id="LGVATT30050_grid" class="grid"></div>
		</div>
	</section>
</div>
</body>
</html>
