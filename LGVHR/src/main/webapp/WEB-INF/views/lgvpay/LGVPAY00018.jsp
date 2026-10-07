<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00018.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : User Defined Table Row 관리하는 화면입니다.
    작성자 : 임수진
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.userDefinedTableRow"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY00018 = function() {
	var grid;
	var myForm = this;
	var srchForm = '.searchBlock form';
	/* Form Util 선언 */ 
	var formUtil = new FormUtil( myForm, srchForm );

    // 화면 레이아웃 정의
	myForm.setLayout( [ 
    	{ name : "searchBlock",       left : 0, right : 0, top : 0 },
    	{ name : "buttonBlock", left : 0, right : 0, top : "searchBlock",  bottom : "gridBlock"},
    	{ name : "gridBlock",   left : 0, right : 0, top : "buttonBlock", bottom : 0}
    ]);

    // 개인화조건
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의
	myForm.popupInfo = {
		detailPopup : { row:'', col:'', detailData:[] }
	};

    // 그리드형 테이블 TR 
    
    // 코드 데이터 조회
	var valueset = new ValueSet("lgcom");
    valueset.add("udtTableList", {valueSetId : "LGVPAY_UDT_TABLE_LIST", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}", languageCode:SESSION_USER.languageCode} );//UDT Table List
    valueset.add("udtTableRowList", {valueSetId : "LGVPAY_UDT_TABLE_ROW_LIST", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}", languageCode:SESSION_USER.languageCode} );//UDT Table Row List
	valueset.execute();
    
    //콤보값 셋팅
    formUtil.initCombo("tableSeqNo", valueset.get("udtTableList"), {selectEmpty:true});
    formUtil.initCombo("sortOrderNo", valueset.get("udtTableRowList"), {selectAll:true, filter:"tableSeqNo"});
    
    // 그리드선언
	var listGrid = buildGrid(".listGrid");

    // 날짜 팝업창
    
    // 필수항목 체크
   	var validator = new Validator( myForm, srchForm );

    validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	 	    tableSeqNo: {required:true}
	    },
	    messages: {
	    	tableSeqNo: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.tableName'/>" />'}
	    }
    });

    // 일반함수

    // Event 처리
	/*** 이벤트 핸들러  ***/
	this.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
			case "search" :
				if ( validator.isValid() ) {
					listGrid.getGridBase().cancel();
					listGrid.loadData("lgvhr", "lgvpay/LGVPAY00018/retrieveUserDefineTableRowList", formUtil.getValue(), function (data) {
						if ( data.result ) {
							$(myForm.select("button[data-action]")).each(function() {
								$(this).removeAttr("disabled");
							});
						}	
					});
				}
				break;
				
			case "add" :
				if ( validator.isValid() ) {
					var gridBase = listGrid.getGridBase();
					try {
						gridBase.commit();
					} catch(e) {
						Message.alert(e.message);
						return;
					}
					
					if(gridBase.getCurrent().itemIndex < 0) {
						gridBase.beginAppendRow();
					} else {
						gridBase.beginInsertRow(gridBase.getCurrent().itemIndex);
					}
					var currCell = gridBase.getCurrent();
					var itemIndex = currCell.itemIndex;
					gridBase.setValue(itemIndex, "tableSeqNo", formUtil.getValue("tableSeqNo"));
					gridBase.setValue(itemIndex, "tableName", myForm.select("select[name='tableSeqNo'] option:selected").text());
					gridBase.setValue(itemIndex, "effectiveEndYyyymmdd", DateUtil.format(DateUtil.parse("47121231", "YYYYMMDD"), "DD/MM/YYYY"));//종료일은 4712/12/31 기본값 셋팅
					gridBase.setCurrent({itemIndex:itemIndex, column:'sortOrderNo'});
					gridBase.setFocus();
				}
				break;
				
			case "delete" :
				var mGrid = listGrid.getGridBase();
				var itemIndex = mGrid.getCurrent().itemIndex;
				
				mGrid.deleteSelection(true);
				mGrid.setSelectOptions( {style : "rows"});
				break;

			case "save" :
				try {
					listGrid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				
				if( listGrid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};

				// 변경건이 있는지 체크
				if(!listGrid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				
				//저장 전 체크
				if ( !fncValidateSaveTable() ) return ;
				
				Message.confirm( '<lgcom:message code="question.save"/>' , function() {
					listGrid.useProgress(true);
					listGrid.saveChanges( "lgvhr", 'lgvpay/LGVPAY00018/saveUserDefineTableRowList', function(data) {
						Message.alert('<lgcom:message code="note.saved"/>');
						
						//Row Seq Combo 갱신
					    formUtil.initCombo("sortOrderNo"
					    		         , valueset.execute("udtTableRowList", {valueSetId : "LGVPAY_UDT_TABLE_ROW_LIST", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}", languageCode:SESSION_USER.languageCode})
					    		         , {selectAll:true, filter:"tableSeqNo"});
						
						// 저장 완료후 목록 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
				break;
		}
		event.stopPropagation();
	});
    
    //UDT Table명 변경 시 그리드 컬럼 조정
	myForm.addEvent( "change", ".searchBlock .form select" , function(event) {
		var item = $(event.target);
		
		switch ($.trim(item.attr("name"))) {
			case "tableSeqNo":
				if ( isNull(formUtil.getValue("tableSeqNo")) ) {//UDT Table Name없는 경우 그리드 지우기.
					listGrid.getDataProvider().clearRows();
					
				} else {

					//Match Type=M(Match) 인 경우 lowerBound header Title 변경, upperBound 비활성화
					if ( valueset.get("udtTableList").findIndex(function(item) {return (item.code == formUtil.getValue("tableSeqNo") && item.dataManagementWayCode == "M") }) > -1 ) {
						listGrid.getGridBase().setColumnProperty("lowerLimitCriticalValue", "header", "<lgcom:message code="label.pay.exact"/>");
						listGrid.getGridBase().setColumnProperty("upperLimitCriticalValue", "header", {text:" ", subText:""});
						listGrid.getGridBase().setColumnProperty("upperLimitCriticalValue", "editable", false);
						listGrid.getGridBase().setColumnProperty("upperLimitCriticalValue", "styles", {background:"#e9e9e9"});
					} else {
						listGrid.getGridBase().setColumnProperty("lowerLimitCriticalValue", "header", "<lgcom:message code="label.pay.lowerBound"/>");
						listGrid.getGridBase().setColumnProperty("upperLimitCriticalValue", "header", {text:"<lgcom:message code="label.pay.upperBound"/>", subText:"*"});
						listGrid.getGridBase().setColumnProperty("upperLimitCriticalValue", "editable", true);
						listGrid.getGridBase().setColumnProperty("upperLimitCriticalValue", "styles", {background:"#ffffff"});
					}
					
					//클릭이벤트 호출
					myForm.select(".searchBlock button[data-action='search']").trigger('click');
				}
				break;
			case "sortOrderNo":
				
				//클릭이벤트 호출
				myForm.select(".searchBlock button[data-action='search']").trigger('click');
				break;
		
		}
		event.stopPropagation();
	});
    
	/*** 내부 함수  ***/    
	//User Define Table 저장 전 체크
	function fncValidateSaveTable() {
		var cgrid = listGrid.getGridBase();
		var provider = cgrid.getDataProvider();
		var sMsg = "";
		
		return true;
	}
	
	//그리드 초기화
	function buildGrid(gridId) {
		var grid;
		switch ( gridId ) {
			case ".listGrid" :
				grid = new RealGrid(myForm, gridId);
				grid.setPagingMode(true);
				//옵션 설정
				grid.setOptions({
					grid: {
						softDeleting: true,
						deleteCreated: true,
						hideDeletedRows:false,
						indicator: {visible:false},
						panel: {visible:false},
						checkBar: {visible:false},
						stateBar: {visible:true},
						footer: {visible:false},
						select: 'block',
						paste    : { enabled: false }, /*paste 기능막기 */
						sorting  : { enabled: false }, /*Sorting 기능을 막는다.*/
		                sortMode : "explicit",
						edit: {
							insertable: true,
							appendable: true,
							updatable: true,
							deletable: true
						},
						header: {
							height: 30
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
		
				//필드 설정
				grid.setFields([
					{ fieldName:'tableSeqNo'                , dataType:'number'},
					{ fieldName:'tableName'                 , dataType:'text'  },
					{ fieldName:'rowNo'                     , dataType:'number'},
					{ fieldName:'sortOrderNo'               , dataType:'number'},
					{ fieldName:'oriSortOrderNo'            , dataType:'number'},
					{ fieldName:'lowerLimitCriticalValue'   , dataType:'text'  },
					{ fieldName:'upperLimitCriticalValue'   , dataType:'text'  },
					{ fieldName:'effectiveStartYyyymmdd'    , dataType:'text'  },
					{ fieldName:'oriEffectiveStartYyyymmdd' , dataType:'text'  },
					{ fieldName:'effectiveEndYyyymmdd'      , dataType:'text'  }
				]);
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
				//컬럼 콤보 셋팅
				grid.setLookups({ });
		
				//컬럼 설정
				grid.setColumns([
					{
						name:'tableName',
						fieldName:'tableName',
						width:220,
						header: {text:'<lgcom:message code="label.pay.tableName"/>'},
						editable: false
					},
					{
						name:'sortOrderNo',
						fieldName:'sortOrderNo',
						width:80,
						header: {text:'<lgcom:message code="label.pay.rowSeq"/>', required: true},
						styles: {textAlignment:'center'},
						editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#,##0'}
					},
					{
						name:'lowerLimitCriticalValue',
						fieldName:'lowerLimitCriticalValue',
						width:220,
						header: {text:'<lgcom:message code="label.pay.lowerBound"/>', required: true}
					},
					{
						name:'upperLimitCriticalValue',
						fieldName:'upperLimitCriticalValue',
						width:220,
						header: {text:'<lgcom:message code="label.pay.upperBound"/>', required: true}
					},
					{
						name:'effectiveStartYyyymmdd',
						fieldName:'effectiveStartYyyymmdd',
						width:140,
						header: {text:'<lgcom:message code="EffectiveStartDate"/>', required: true},
						styles: {textAlignment:'center'},
						editor: {type:'date', datetimeFormat:'dd/MM/yyyy', maxLength:10},
						editButtonVisibility: 'visible' /* 포커스 있는 경우만 날짜 버튼 보임 */
					},
					{
						name:'effectiveEndYyyymmdd',
						fieldName:'effectiveEndYyyymmdd',
						width:140,
						header: {text:'<lgcom:message code="EffectEndDate"/>', required: true},
						styles: {textAlignment:'center'},
						editor: {type:'date', datetimeFormat:'dd/MM/yyyy', maxLength:10},
						editButtonVisibility: 'visible' /* 포커스 있는 경우만 날짜 버튼 보임 */
					}
				]);
		
				grid.setValidations([
					{criteria: "value['sortOrderNo'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.rowSeq'/>"/>',mode:'always',level:'error'},
					{criteria: "value['lowerLimitCriticalValue'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.lowerBound'/>"/>',mode:'always',level:'error'},
					{criteria: "value['effectiveStartYyyymmdd'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='EffectiveStartDate'/>"/>',mode:'always',level:'error'},
					{criteria: "value['effectiveEndYyyymmdd'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='EffectEndDate'/>"/>',mode:'always',level:'error'}
				]);
				
				break;
		}
		return grid;
	}
	/* 그리드 이벤트 처리 */
	// 샐의 dataRow가 바뀔때(행 추가 이벤트 시)
	listGrid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		<%--[PARAMETER]
		    - cgrid : grid.getGridBase()
		    - oldRow : 변경 전 데이터행의 dataRow
		    - newRow : 변경 후 데이터행의 dataRow
		    
		    *dataRow : 최초 조회한 데이터셋의 row index
		--%>
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';

	};
	listGrid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
}

LGVPAY00018.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY00018();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.userDefinedTableRow"/></h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<table class="table" >
					<colgroup>
						<col width="120">
						<col width="220">
						<col width="100">
						<col width="070">
						<col width="*">
					</colgroup>
					<tbody>
						<tr>
							<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.tableName"/></label></th>
		                	<td><select class="form-control input-sm input-require" name="tableSeqNo" ></select></td>
							<th><label><lgcom:message code="label.pay.rowSeq"/></label></th>
		                	<td><select class="form-control input-sm" name="sortOrderNo" ></select></td>
							<td></td>
						</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- 그리드 버튼 --%>
		<div class="module-group text-right buttonBlock" >
			<div class="btn-toolbar">
				<div class="btn-group">
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="add" disabled><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete" disabled><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save" disabled><lgcom:message code="save"/></button>
				</div>
			</div>
		</div>
		<%-- 그리드 --%>
		<div class="gridBlock grid-wrap">
			<div class="grid listGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
