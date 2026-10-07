<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00010.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 로깅 정보를 관리하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Logging</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">

var LGUTLC00010 = function(){
    var grid;
    var myForm = this;
    
    var formUtil = new FormUtil( myForm, ".searchBlock form" );
    
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock", bottom : "gridContent"},
		{ name : "gridContent",  left : 0, right : 0, top : "gridControls", bottom : 0 }		
    ]);		
	
	// 그리드 선언    
   	grid = buildGrid(".grid");

   	var validator = new Validator( myForm, ".searchBlock .form" );
    validator.setRule( {
	    rules : {
	 	   dateFrom : { required: true, date : true },
	 	   dateTo : { required: true, date : true }
	    },
	    messages : {
	    	dateFrom : { date : "<lgcom:message code="error.incorrectFormat" />" },
	    	dateTo : { date : "<lgcom:message code="error.incorrectFormat" />" }
	    }
    });
   	   	
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
    		case "search" :
    			if(validator.isValid()){    		
    				grid.getGridBase().cancel();
					grid.loadData('lgcom','lgutlc/LGUTLC00010/retrieveLoggingList', formUtil.getValue() );
					if(grid.getDataProvider().getRowCount() > 0){
			    		var index = {itemIndex: 0};				
						grid.getGridBase().setCurrent(index);
			    	}
    			}
				break;		
		}
	});

	//날짜 설정
	var $dateFrom = myForm.select(".searchBlock input[name='dateFrom']"),
		$dateTo   = myForm.select(".searchBlock input[name='dateTo']"),
		$button   = myForm.select('.searchBlock ._datePicker');
	
	/*

	myForm.select('._datePicker').dateRangePicker({
		    autoClose: true,
		    language : SESSION_USER.languageCode ,
		    maxDays : 7,
		    minDays : 1,
			setValue: function(s, s1, s2) {
			$dateFrom.val(s1);
			$dateTo.val(s2);
		}
	});
	
	$dateFrom.dateRangePicker({
		singleDate : true,
		showShortcuts: false,
	    autoClose: true,
	    language : SESSION_USER.languageCode ,
	    maxDays : 7,
	    minDays : 1,
		setValue: function(s, s1, s2) {
		$dateFrom.val(s1);
	}
	});
	
	$dateTo.dateRangePicker({
		singleDate : true,
		showShortcuts: false,
	    autoClose: true,
	    language : SESSION_USER.languageCode ,
	    maxDays : 7,
	    minDays : 1,
		setValue: function(s, s1, s2) {
		$dateTo.val(s1);
	}
	});
	
	$dateFrom.addClass("_datePicker");
	$dateTo.addClass("_datePicker");
	
	//현재 날짜 가져오기
	var date = DateUtil.today("yyyy-MM-dd");

	$dateFrom.val(date);
	$dateTo.val(date);
	*/
	var date = DateUtil.today("YYYY-MM-DD");
	uxp.datepicker.fromTo( $button, $dateFrom, $dateTo  ); 
    formUtil.setValue({ dateFrom : date, dateTo: date });	
	
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	/*** 내부 함수  ***/
    //그리드 초기화 
	function buildGrid(gridId, lookupList) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode( true );
		
		//옵션 설정 
		grid.setOptions({
			grid: {
				softDeleting: true,
				deleteCreated: true,
				hideDeletedRows:false,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:false},
				footer: {visible:false},
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
			},	
			display: { fitStyle: 'none' }
		});	
		
	 	//마우스 오른쪽 클릭시 메뉴
		grid.setContextMenu();
	 	
		//컬럼 설정
		grid.setFields(
				[
					{ fieldName: 'accessDate'          		, dataType:'text'},
					{ fieldName: 'applicationUserId'        , dataType:'text'},
					{ fieldName: 'employeeName'            	, dataType:'text'},
					{ fieldName: 'menuId'             		, dataType:'text'},
					{ fieldName: 'menuName'             	, dataType:'text'},
					{ fieldName: 'loginIpAddr'             	, dataType:'text'}
				]	
		);
		
		grid.setColumns(
				[
					{
						name:'loggingDate',
						fieldName:'accessDate',
						width:200,
						header: {text:'<lgcom:message code="LoggingDate" />'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'userId',
						fieldName:'applicationUserId',
						width:90,
						type: 'data',
						header: {text:'<lgcom:message code="UserID" />'},
						styles: {textAlignment:'center'},
						editable: false
					},				
					{
						name:'employeeName',
						fieldName:'employeeName',
						width:180,
						header: {text:'<lgcom:message code="EmployeeName" />'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'menuId',
						fieldName:'menuId',
						width:180,
						header: {text:'<lgcom:message code="MenuId" />'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'menuName',
						fieldName:'menuName',
						width:180,
						header: {text:'<lgcom:message code="MenuName" />'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'loginIpAddr',
						fieldName:'loginIpAddr',
						width:180,
						header: {text:'<lgcom:message code="LoginIpAddr" />'},
						styles: {textAlignment:'center'},
						editable: false
					}
				]	
			);
			return grid;
	}

	this.search = function( param ){
		if(validator.isValid()){    		
			grid.getGridBase().cancel();
			grid.loadData('lgcom','lgutlc/LGUTLC00010/retrieveLoggingList', param );
			if(grid.getDataProvider().getRowCount() > 0){
	    		var index = {itemIndex: 0};				
				grid.getGridBase().setCurrent(index);
	    	}
		}
	}
	
	this.active = function( param ){
		trace( "LGUTLC00010 activated ");
	}	
	
};

/*
function changeDateFr(sDate) {
	var strDate = sDate.substr(0,4) + "-" + sDate.substr(4,2) + "-" + sDate.substr(6,2);  
	
	$('#dateFrom').val(strDate);
	return strDate;
}

function initFr(sDate){
	
	if(sDate.length >= 10){
		var strDate = sDate.substr(0,4) + sDate.substr(5,2) + sDate.substr(8,2); 
	}else{
		var strDate = sDate.substr(0,4) + sDate.substr(4,2) + sDate.substr(6,2);
	}
	//$('#dateFrom').val(strDate);
	$('#dateFrom').val("");

}
*/
/*
function changeDateTo(sDate) {
	var strDate = sDate.substr(0,4) + "-" + sDate.substr(4,2) + "-" + sDate.substr(6,2);  
	
	$('#dateTo').val(strDate);
	return strDate;
}

function initTo(sDate){
	$('#dateTo').val("");
}
*/
     
LGUTLC00010.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGUTLC00010();
		form.init();		
	});
});
</script>
</head>
<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Logging</h2>
	</div>
	
	<div class="searchBlock">
		<form class="form search-wrap">
		        <table class="table" >
		            <colgroup>
		                <col width="90">
		                <col width="270">
		                <col width="120">
		                <col width="180">
		                <col width="120">
		                <col width="120">
		            </colgroup>
		            <tbody>
		                <tr>
		                    <th><label class="required"><lgcom:message code="LoggingDate" /></label></th>
		                    <td>
								<div class="form-inline">
									<div class="form-group">
										<input type="text" class="form-control input-sm" name="dateFrom" placeholder="yyyy-mm-dd" style="width: 90px;" placeholder="yyyy-mm-dd" >
									</div> ~
									<div class="form-group">
										<input type="text" class="form-control input-sm" name="dateTo" placeholder="yyyy-mm-dd" style="width: 90px;" placeholder="yyyy-mm-dd">
									</div>
									<button type="button" class="btn btn-ico _datePicker" aria-label="calendar">
										<span class="ico ico-calendar" aria-hidden="true"></span>
									</button>
								</div>                      
		                    </td>		                    
		                    <th><label><lgcom:message code="UserID" /></label></th>
		                    <td><input type="text" class="form-control input-sm" name="userId"></td>
		                    
		                    <th><label><lgcom:message code="EmployeeName" /></label></th>
		                    <td><input type="text" class="form-control input-sm" name="employeeName"></td>
		                </tr>		
		                <tr>
		                    <th><label><lgcom:message code="MenuId" /></label></th>
		                    <td><input type="text" class="form-control input-sm" name="menuId"></td>
		                    
		                    <th><label><lgcom:message code="MenuName" /></label></th>
		                    <td><input type="text" class="form-control input-sm" name="menuName"></td>
		                    
		                    <th><label><lgcom:message code="LoginIpAddr" /></label></th>
		                    <td><input type="text" class="form-control input-sm" name="loginIpAddr"></td>	
		                </tr>
		            </tbody>
		        </table>
		        <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search" ><lgcom:message code="search" /></button>
		</form>	
	</div>
	
	<div class="gridControls module-group text-right" >
	
    </div>
    
	<div class="gridContent grid-wrap" >
	    <div class="grid"></div>
	</div>
	
	<div class="controls" >

    </div>	
    </section>	    
</div>
</body>
</html>