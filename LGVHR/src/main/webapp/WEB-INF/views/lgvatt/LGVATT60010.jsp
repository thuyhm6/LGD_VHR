<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="devonframe.util.DateUtil" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT60010.jsp
    프로젝트명 : LGD BizWeb

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 기능직 근태 weekly Report
    작성자 : 장호웅D
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Line Worker Attendance Registration</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<style type="text/css">
</style>
<script type="text/javascript">

var LGVATT60010 = function(){
    var grid1;
    var _this = this;
    var myForm = this;
    var srchForm = '.searchBlock form';

    var formUtil = new FormUtil(myForm,'.searchBlock form');
    
    
    
    /* Layout Setting 하측 고정, 상측 Flexible*/
	myForm.setLayout( [ 
		{ name  : "searchBlock", left : 0, right : 0, top : 0 },		
		{ name  : "gridControls", left : 0, right : 0, top : "searchBlock"},
		{ name  : "content1", left : 0, right : 0, top : "gridControls", bottom : 0 }
	]);
    
  	//검색조건에 값을 입력하고 조회하면 방금 입력한 값을 저장하여 화면에 고정값으로 셋팅 
    myForm.searchConditionControl( true );
    
 	
 	
	
	// grid combo
	
	var code = new CommonCode('lgcom');
	code.add('shiftCode', {codeTypeCode:'LGVHR_SHIFT_TYPE_CODE'});
	code.execute();
	
	// Search Block combo
	var valueSet = new ValueSet("lgcom");
	valueSet.add('weekly',  {valueSetId : 'LGVATT_WEEK_MON_TO_SUN'});
	valueSet.execute(); 
	
	formUtil.initCombo('shiftCode',code.get('shiftCode'),{selectAll:true});
	formUtil.initCombo('weekly'   ,valueSet.get('weekly'),{selectAll:true});
	
	var orgList = null;
	
	transaction_sync( "lgvhr","lgvatt/LGVATT60010/retrieveOrgList",{employeeNum : '${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}',subsidiaryCode : '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}',organizationId : '${sessionScope.LGVHR_PROJECT_SESSION.organizationId}'}, function(data) {
		if ( data.result ) {
			orgList = data.result;
			formUtil.initCombo('orgName',data.result,{selectAll:false});
        }
	});
	
	
	
   	grid1 = buildGrid("LGVATT60010_grid1");
    
    grid1.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	
	// 필수항목 체크
   	var validator = new Validator( myForm, srchForm );
	
   	validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	    	weekly: {required:true},
	    	orgName:{required:true}
	    },
	    messages: {
	    	weekly: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='Week'/>" />'},
	    	orgName: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.organization'/>" />'}
	    }
    });
	
	/*** 콤보박스 체인지 이벤트  ***/
	this.addEvent('change',"select[data-action='weekly']",function(event) {
	  if(formUtil.getValue("weekly")!= ''){	
		transaction_sync("lgvhr", "lgvatt/LGVATT60010/retrieveWeekDateFromTo", {msWeek1jan:formUtil.getValue("weekly")}, function(data){
			formUtil.setValue({dateFrom : data.result["msStartDate"], dateTo : data.result["msEndDate"]});
		});
	  }
	});
	
	/*** 조직 콤보 박스 체인지 이벤트  ***/
	myForm.addEvent( "change", ".searchBlock .form select[name=orgName]" , function(event) {
		myForm.select(".searchBlock button[data-action='search']").trigger('click');
	});
	
	/*** 이벤트 핸들러  ***/
	this.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
		    case "search" :
		    if ( validator.isValid() ){ 	
		    	grid1.getGridBase().cancel();
				var param =  myForm.select(".searchBlock form").toJSON();
				grid1.loadData('lgvhr','lgvatt/LGVATT60010/retrieveWeekAttSummary', param, function( ){
	                //키워드를 저장하는 함수를 호출하였다
	                if(grid1.getDataProvider().getRowCount() > 0){
	                    //myForm.sendKeyword( "commonCodeType", "codeType", param );
	                }
				} );
				if(grid1.getDataProvider().getRowCount() > 0){
		    		var index = {itemIndex: 0};
					grid1.getGridBase().setCurrent(index);
		    	}
		    }	
			    break;
		    case "reportOpen":
			    if ( validator.isValid() ){
			       reportPopUpPost();
			    }
	            break;   
		}
	});
	
	//검색조건에 값을 입력하고 조회하면 방금 입력한 값을 저장하여 화면에 고정값으로 셋팅 
    myForm.searchConditionControl( true );
	
    
	
	
	
	/*** 내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid;
		switch(gridId){
			case 'LGVATT60010_grid1':
				grid = new RealGrid(myForm, gridId, true);
				grid.setPagingMode(true);
				
				//옵션 설정
				grid.setOptions({
					grid: {
						softDeleting: true,
						deleteCreated: true,
						hideDeletedRows:false,
						indicator: {visible:false},
						panel: {visible:false},
						checkBar: {visible:true},
						stateBar: {visible:false},
						footer: {visible:false},
						edit: {
							insertable: false,
							appendable: false,
							updatable: false,
							deletable: false
						},
						header: {
		                    height: 60,
		                    heightFill: 'fixed'
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

				/* grid.setValidations([
				         			{criteria: "value['employeeNo'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.employeeNo'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['employeeName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.employeeName'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['planDate'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.planDate'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['planDayOfWeek'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.planDayOfWeek'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['planAttendanceType'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.planAttendanceType'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['planAttendanceDetail'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.planAttendanceDetail'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['planShiftCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.planShiftCode'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['planDayNight'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.planDayNight'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['planOT'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.planOT'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['actualDate'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualDate'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['actualDayOfWeek'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualDayOfWeek'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['actualAttendanceType'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualAttendanceType'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['actualAttendanceDetail'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualAttendanceDetail'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['actualShiftCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualShiftCode'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['actualDayNight'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualDayNight'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['actualDinnerChk'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualDinnerChk'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['actualStartTm'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualStartTm'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['actualOT'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualOT'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['actualOTWeekDay'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualOTWeekDay'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['actualOTWeekDayHoliday'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualOTWeekDayHoliday'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['actualOTPublicHoliday'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualOTPublicHoliday'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['actualOTNightWeekDay'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualOTNightWeekDay'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['actualOTNightWeekDayAfterOT'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualOTNightWeekDayAfterOT'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['actualOTNightWeekDayHoliday'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualOTNightWeekDayHoliday'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['actualOTNightPublicHoliday'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.actualOTNightPublicHoliday'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['nightNormal'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.nightNormal'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['deductionLateness'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.deductionLateness'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['deductionLeavingEarly'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.deductionLeavingEarly'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['deductionGoingOut'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.deductionGoingOut'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['specialFull'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.specialFull'/>"/>',mode:'always',level:'info'},
				        			{criteria: "value['bonusHalf'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.bonusHalf'/>"/>',mode:'always',level:'info'}
				 				]); */

				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();

				//필드 설정
				grid.setFields(
						[
							{ fieldName:'empCat'	        		, dataType:'text'  },
							{ fieldName:'employeeNumber'     		, dataType:'text'  },
							{ fieldName:'fullNameLocal'     		, dataType:'text'  },
							{ fieldName:'gradeTitle'	            , dataType:'text'  },
							{ fieldName:'shiftCode' 	            , dataType:'text'  },
							
							{ fieldName:'weeklyResult'     			    , dataType:'text'  },
							{ fieldName:'mon'        		            , dataType:'text'  },
							{ fieldName:'monAttCode'    		        , dataType:'text'  },
							{ fieldName:'monNomalTime' 			        , dataType:'number'},
							{ fieldName:'monNightTime'         		    , dataType:'number'},
							{ fieldName:'monOtTime'         			, dataType:'number'},
							{ fieldName:'monOtAtNight'         		    , dataType:'number'},
							{ fieldName:'monDeduction'         		    , dataType:'number'},
							{ fieldName:'tue'        		            , dataType:'text'  },
							{ fieldName:'tueAttCode'    		        , dataType:'text'  },
							{ fieldName:'tueNomalTime' 			        , dataType:'number'},
							{ fieldName:'tueNightTime'         		    , dataType:'number'},
							{ fieldName:'tueOtTime'         			, dataType:'number'},
							{ fieldName:'tueOtAtNight'         		    , dataType:'number'},
							{ fieldName:'tueDeduction'         		    , dataType:'number'},
							{ fieldName:'wed'        		            , dataType:'text'  },
							{ fieldName:'wedAttCode'    		        , dataType:'text'  },
							{ fieldName:'wedNomalTime' 			        , dataType:'number'},
							{ fieldName:'wedNightTime'         		    , dataType:'number'},
							{ fieldName:'wedOtTime'         			, dataType:'number'},
							{ fieldName:'wedOtAtNight'         		    , dataType:'number'},
							{ fieldName:'wedDeduction'         		    , dataType:'number'},
							{ fieldName:'thu'        		            , dataType:'text'  },
							{ fieldName:'thuAttCode'    		        , dataType:'text'  },
							{ fieldName:'thuNomalTime' 			        , dataType:'number'},
							{ fieldName:'thuNightTime'         		    , dataType:'number'},
							{ fieldName:'thuOtTime'         			, dataType:'number'},
							{ fieldName:'thuOtAtNight'         		    , dataType:'number'},
							{ fieldName:'thuDeduction'         		    , dataType:'number'},
							{ fieldName:'fri'        		            , dataType:'text'  },
							{ fieldName:'friAttCode'    		        , dataType:'text'  },
							{ fieldName:'friNomalTime' 			        , dataType:'number'},
							{ fieldName:'friNightTime'         		    , dataType:'number'},
							{ fieldName:'friOtTime'         			, dataType:'number'},
							{ fieldName:'friOtAtNight'         		    , dataType:'number'},
							{ fieldName:'friDeduction'         		    , dataType:'number'},
							{ fieldName:'sat'        		            , dataType:'text'  },
							{ fieldName:'satAttCode'    		        , dataType:'text'  },
							{ fieldName:'satNomalTime' 			        , dataType:'number'},
							{ fieldName:'satNightTime'         		    , dataType:'number'},
							{ fieldName:'satOtTime'         		    , dataType:'number'},
							{ fieldName:'satOtAtNight'         		    , dataType:'number'},
							{ fieldName:'satDeduction'         		    , dataType:'number'},
							{ fieldName:'sun'        		            , dataType:'text'  },
							{ fieldName:'sunAttCode'    		        , dataType:'text'  },
							{ fieldName:'sunNomalTime' 			        , dataType:'number'},
							{ fieldName:'sunNightTime'         		    , dataType:'number'},
							{ fieldName:'sunOtTime'         			, dataType:'number'},
							{ fieldName:'sunOtAtNight'         		    , dataType:'number'},
							{ fieldName:'sunDeduction'         		    , dataType:'number'},
							
						]
				);

				
				
				//컬럼 설정
				grid.setColumns(
						[
							
							
				            { name:'empCat',        fieldName:'empCat',        width:80,  header: {text:'<lgcom:message code="label.att.empCat" />'}, 	editable: false, styles: {textAlignment:'center' },   renderer: {showTooltip:true}},
				            { name:'employeeNumber',fieldName:'employeeNumber',width:100, header: {text:'<lgcom:message code="label.att.employeeNo2" />'}, 	editable: false, styles: {textAlignment:'center' },   renderer: {showTooltip:true}},
				            { name:'fullNameLocal', fieldName:'fullNameLocal', width:100, header: {text:'<lgcom:message code="EmployeeName" />'}, 	    editable: false, styles: {textAlignment:'near' },   renderer: {showTooltip:true}},
				            { name:'gradeTitle',    fieldName:'gradeTitle',    width:120, header: {text:'<lgcom:message code="Grade1" />'}, 	    editable: false, styles: {textAlignment:'near' },   renderer: {showTooltip:true}},
				            { name:'shiftCode',     fieldName:'shiftCode',     width:100, header: {text:'<lgcom:message code="label.att.shiftType" />'}, editable: false, styles: {textAlignment:'near' },   renderer: {showTooltip:true}},
							
							
							{
								type:'group',
								name:'weeklyResult',
								fieldName:'weeklyResult',
								width:3010,
								header:{
							         text:'<lgcom:message code="label.att.weeklyResult" />',
							         fixedHeight : 15
							    },
								orientation:'horizontal',
								columns: [
								            {
												type:'group',
												name:'mon',
												fieldName:'mon',
												width:430,
												header:{
											         text:'<lgcom:message code="MON" />',
											         fixedHeight : 15
											    },
												orientation:'horizontal',
												columns: [
												            { name:'monAttCode',        fieldName:'monAttCode',    width:100, header: {text:'<lgcom:message code="label.att.planAttendance" />'}}, 
												            { name:'monNomalTime',      fieldName:'monNomalTime',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.NomalTime" />'}}, 
												            { name:'monNightTime',      fieldName:'monNightTime',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.nightTime" />'}}, 
													        { name:'monOtTime',         fieldName:'monOtTime',     width:50, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.ot" />'}},
												            { name:'monOtAtNight',      fieldName:'monOtAtNight',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.otAtNight" />'}}, 
													        { name:'monDeduction',      fieldName:'monDeduction',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.Deduction" />'}},
													     ]
											},
											{
												type:'group',
												name:'tue',
												fieldName:'tue',
												width:430,
												header:{
											         text:'<lgcom:message code="TUE" />',
											         fixedHeight : 15
											    },
												orientation:'horizontal',
												columns: [
												            { name:'tueAttCode',        fieldName:'tueAttCode',    width:100,  header: {text:'<lgcom:message code="label.att.planAttendance" />'}}, 
												            { name:'tueNomalTime',      fieldName:'tueNomalTime',  width:70, styles: {textAlignment:'far'}, header: {text:'<lgcom:message code="label.att.NomalTime" />'}}, 
												            { name:'tueNightTime',      fieldName:'tueNightTime',  width:70, styles: {textAlignment:'far'}, header: {text:'<lgcom:message code="label.att.nightTime" />'}}, 
													        { name:'tueOtTime',         fieldName:'tueOtTime',     width:50, styles: {textAlignment:'far'}, header: {text:'<lgcom:message code="label.att.ot" />'}},
												            { name:'tueOtAtNight',      fieldName:'tueOtAtNight',  width:70, styles: {textAlignment:'far'}, header: {text:'<lgcom:message code="label.att.otAtNight" />'}}, 
													        { name:'tueDeduction',      fieldName:'tueDeduction',  width:70, styles: {textAlignment:'far'}, header: {text:'<lgcom:message code="label.att.Deduction" />'}}
													     ]
											},
											{
												type:'group',
												name:'wed',
												fieldName:'wed',
												width:430,
												header:{
											         text:'<lgcom:message code="WED" />',
											         fixedHeight : 15
											    },
												orientation:'horizontal',
												columns: [
												            { name:'wedAttCode',        fieldName:'wedAttCode',    width:100,  header: {text:'<lgcom:message code="label.att.planAttendance" />'}}, 
												            { name:'wedNomalTime',      fieldName:'wedNomalTime',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.NomalTime" />'}}, 
												            { name:'wedNightTime',      fieldName:'wedNightTime',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.nightTime" />'}}, 
													        { name:'wedOtTime',         fieldName:'wedOtTime',     width:50, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.ot" />'}},
												            { name:'wedOtAtNight',      fieldName:'wedOtAtNight',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.otAtNight" />'}}, 
													        { name:'wedDeduction',      fieldName:'wedDeduction',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.Deduction" />'}}
													     ]
											},
								            {
												type:'group',
												name:'thu',
												fieldName:'thu',
												width:430,
												header:{
											         text:'<lgcom:message code="THU" />',
											         fixedHeight : 15
											    },
												orientation:'horizontal',
												columns: [
												            { name:'thuAttCode',        fieldName:'thuAttCode',    width:100,  header: {text:'<lgcom:message code="label.att.planAttendance" />'}}, 
												            { name:'thuNomalTime',      fieldName:'thuNomalTime',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.NomalTime" />'}}, 
												            { name:'thuNightTime',      fieldName:'thuNightTime',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.nightTime" />'}}, 
													        { name:'thuOtTime',         fieldName:'thuOtTime',     width:50, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.ot" />'}},
												            { name:'thuOtAtNight',      fieldName:'thuOtAtNight',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.otAtNight" />'}}, 
													        { name:'thuDeduction',      fieldName:'thuDeduction',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.Deduction" />'}}
													     ]
											},
											 {
												type:'group',
												name:'fri',
												fieldName:'fri',
												width:430,
												header:{
											         text:'<lgcom:message code="FRI" />',
											         fixedHeight : 15
											    },
												orientation:'horizontal',
												columns: [
												            { name:'friAttCode',        fieldName:'friAttCode',    width:100,  header: {text:'<lgcom:message code="label.att.planAttendance" />'}}, 
												            { name:'friNomalTime',      fieldName:'friNomalTime',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.NomalTime" />'}}, 
												            { name:'friNightTime',      fieldName:'friNightTime',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.nightTime" />'}}, 
													        { name:'friOtTime',         fieldName:'friOtTime',     width:50, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.ot" />'}},
												            { name:'friOtAtNight',      fieldName:'friOtAtNight',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.otAtNight" />'}}, 
													        { name:'friDeduction',      fieldName:'friDeduction',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.Deduction" />'}}
													     ]
											},
								            {
												type:'group',
												name:'sat',
												fieldName:'sat',
												width:430,
												header:{
											         text:'<lgcom:message code="SAT" />',
											         fixedHeight : 15
											    },
												orientation:'horizontal',
												columns: [
												            { name:'satAttCode',        fieldName:'satAttCode',    width:100,  header: {text:'<lgcom:message code="label.att.planAttendance" />'}}, 
												            { name:'satNomalTime',      fieldName:'satNomalTime',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.NomalTime" />'}}, 
												            { name:'satNightTime',      fieldName:'satNightTime',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.nightTime" />'}}, 
													        { name:'satOtTime',         fieldName:'satOtTime',     width:50, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.ot" />'}},
												            { name:'satOtAtNight',      fieldName:'satOtAtNight',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.otAtNight" />'}}, 
													        { name:'satDeduction',      fieldName:'satDeduction',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.Deduction" />'}}
													     ]
											},
								            {
												type:'group',
												name:'sun',
												fieldName:'sun',
												width:430,
												header:{
											         text:'<lgcom:message code="SUN" />',
											         fixedHeight : 15
											    },
												orientation:'horizontal',
												columns: [
												            { name:'sunAttCode',        fieldName:'sunAttCode',    width:100,  header: {text:'<lgcom:message code="label.att.planAttendance" />'}}, 
												            { name:'sunNomalTime',      fieldName:'sunNomalTime',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.NomalTime" />'}}, 
												            { name:'sunNightTime',      fieldName:'sunNightTime',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.nightTime" />'}}, 
													        { name:'sunOtTime',         fieldName:'sunOtTime',     width:50, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.ot" />'}},
												            { name:'sunOtAtNight',      fieldName:'sunOtAtNight',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.otAtNight" />'}}, 
													        { name:'sunDeduction',      fieldName:'sunDeduction',  width:70, styles: {textAlignment:'far'},  header: {text:'<lgcom:message code="label.att.Deduction" />'}}
													     ]
											}
												
											
								         ]
							    
							}
				            
							
						]
				);
				break;
		}
		return grid;
	}
	
	//그리드에 값 세팅하는 함수
	function setValue(grid, field, val) {
	    var row = 0;
	    var current = grid.getGridBase().getCurrent();
	    if (current) {
	        row = Math.max(0, current.dataRow);
	    }
	    grid.getDataProvider().setValue(row,field,val);
	}

	/*** add row시 조직코드 및 조직명 자동 셋팅 ***/
	var getCodeValue = function(obj,key){
		
		var value;
		obj.forEach(function(v){
			if(v.code == key){
				value = v.name;
			}
		});
		
		return value;
		
	}
	
	
	var reportPopUpPost = function(){
	    
	    var winUrl = SERVER_URL+'/aireport/report/WeeklyAttendanceReport.jsp';
	    var windowoption='resizable=yes,height='+ 800 +',width='+ 1280 +',location=0,menubar=0,scrollbars=1, top=50, left=50';
	    var form = $("#_open_report_temp_form_");

	    if( !form.exists() ) {
	        $("body").append("<form id='_open_report_temp_form_' method='POST'></form>");
	        form = $("#_open_report_temp_form_");
	    }
	    
	    
	    
	    
	    $(form).empty();
	    $(form).attr("action", winUrl);
	    $(form).attr("target",'aiReport');
	    
	    
	    //파라미터 셋팅
	    var chkCnt = grid1.getGridBase().getCheckedItems();
	    var selectList;
	    if(chkCnt.length > 0){
	        for(i=0; i<chkCnt.length; i++){
	        	if(i==0){
	        		selectList = grid1.getGridBase().getValue(chkCnt[i], 'employeeNumber');	
	        	}else{
	        		selectList = selectList +'<>'+ grid1.getGridBase().getValue(chkCnt[i], 'employeeNumber');
	        	}
	        	
	        }
	    }
	    $(form).append("<input type='hidden' name='orgName' value='' />");
	    $(form).append("<input type='hidden' name='dateFrom' value='' />");
	    $(form).append("<input type='hidden' name='dateTo' value='' />");
	    $(form).append("<input type='hidden' name='orgId' value='' />");
	    $(form).append("<input type='hidden' name='shiftCode' value='' />");
	    $(form).append("<input type='hidden' name='parentOrgName' value='' />");
	    //$(form).append("<input type='hidden' name='reportParams' value='useReportFile:true,reportFileSave:true,skip_decimal_point:true' />");
	    $(form).append("<input type='hidden' name='AIReportLangScCd' value='en' />");
	    
	    
	    trace(selectList);
	    if(selectList != null){
	    	$(form).append("<input type='hidden' name='selectList' value='' />");
	    	$(form).find("input[name='selectList']").val(selectList);
	    }
	    
	    trace(JSON.stringify(orgList));
	    var OrgVal = getCodeValue(orgList, formUtil.getValue('orgName'));
	    
	    $(form).find("input[name='orgName']").val(OrgVal);
	    $(form).find("input[name='orgId']").val( formUtil.getValue("orgName"));
	    $(form).find("input[name='dateFrom']").val( formUtil.getValue("dateFrom"));
	    $(form).find("input[name='dateTo']").val( formUtil.getValue("dateTo"));
	    $(form).find("input[name='shiftCode']").val( formUtil.getValue("shiftCode"));
	    
	    
	    window.open('', 'aiReport',windowoption);
	    $(form).submit();
	}
	

}



LGVATT60010.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT60010();
		form.init();
		//form.loadCompleted();
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
		    <h2>Line Worker Attendance Registration</h2>
		</div>
	
		<div class="searchBlock">
		    <form class="form search-wrap">
				<fieldset>
					<table class="table">
						<colgroup>
							<col width="90" />
							<col width="90"/>
							<col width="100" />
							<col width="200"/>
							<col width="90" />
							<col width="100" />
							<col width="90" />
							<col width="120" />
							<col width="90" />
							<col width="150" />
							<col width="*"  />
						</colgroup>
						<tbody>
			                <tr>
			                    <th><label class="required"><lgcom:message code="Week"/></label></th>
			                    <td>
			                        <div class="form-inline ">
	                                <select class="form-control input-sm input-require" name="weekly" data-action="weekly"></select>
	                                <input type="text" class="form-control input-sm input-require" name="dateFrom" placeholder="dd/mm/yyyy" style="width: 85px;" data-date readonly>
	                                ~
	                                <input type="text" class="form-control input-sm input-require" name="dateTo" placeholder="dd/mm/yyyy" style="width: 85px;" data-date readonly>
	                            </div>
			                    </td>
			                    
										
								<th><label><lgcom:message code="label.att.organization" /></label></th>
								<td><select class="form-control input-sm input-require" name="orgName"></select></td>
								
								<th><label><lgcom:message code="label.att.shiftCode" /></label></th>
								<td><select class="form-control input-sm" name="shiftCode"></select></td>
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
				 <button type="button" class="btn btn-default btn-sm" data-action="reportOpen"><span class="ico ico-excel-down"  aria-hidden="true"></span> Report</button>
				</div>
	        </div>	
	    </div>
		
		<div class="content content1 grid-wrap" >
		    <div id="LGVATT60010_grid1" class="grid"></div>
		</div>
	</section>
</div>
</body>
</html>
