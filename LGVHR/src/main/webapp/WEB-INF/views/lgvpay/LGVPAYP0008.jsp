<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAYP0008.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Payroll Item Use List를 조회 및 관리하는 팝업 화면입니다.
    작성자 : 임수진	
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.use"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAYP0008 = function() {
	var myForm = this;
	// Form Util 선언
	var srchFormUtil = new FormUtil( myForm, ".searchBlock form" );
	var usePopData = myForm.getParent().popupInfo.usePopup;
	
	//팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".contentBlock").parents("._div_popup_holder_").css({"width": "512px", "height":"400px"});
	
    // 화면 레이아웃 정의(달력 그린 후 레이아웃 지정하기 위해 마지막에 수행함.)
	myForm.setLayout( [
		{ name : "contentBlock", left : 0, right : 0, top : 0, bottom : "controlBlock" },
	    { name : "controlBlock", left : 0, right : 0, bottom : 0 }
	]);

    // 개인화조건
    
    // 조회조건 저장 처리
    //myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)

    // 그리드형 테이블 TR
    
    // 코드 데이터 조회
	var code = new CommonCode("lgcom");
    code.add( "runTypeList", {codeTypeCode:'LGVHR_PAY_RUN_TYPE'});
	code.execute();
	
	//수정/삭제 가능여부 조회하기 위해 급여항목ID로 데이터 조회함.
	var itemData = {};
	myForm.transaction_sync("lgvhr", "lgvpay/LGVPAY00013/retrievePayrollItemData", {payrollItemId:nvl(usePopData.payrollItemId)}, function (data) {
		itemData = data.result;
	});
	
    // 그리드선언
	var listGrid = buildGrid(".listGrid");
	
    // 날짜 팝업창
    
    // 필수항목 체크
    
    // 일반함수	
    
    // Event 처리
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}

		var cgrid = listGrid.getGridBase();
		var action = $.trim(item.data('action'));
		switch( action ){
			case "add" :
				try {
					cgrid.commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
					
				if(cgrid.getCurrent().itemIndex < 0) {
					cgrid.beginAppendRow();
				} else {
					cgrid.beginInsertRow(cgrid.getCurrent().itemIndex);
				}
				var currCell = cgrid.getCurrent();
				//	추가시에 start date 는 tb_pay_payroll_item_m 의 start date 와 end date를 기본으로 넣게 한다.
				cgrid.setValue(currCell.itemIndex, "effectiveStartYyyymmdd", nvl(itemData.startDate));
				cgrid.setValue(currCell.itemIndex, "effectiveEndYyyymmdd", nvl(itemData.endDate));
				cgrid.setCurrent({column:'payrollTypeCode'});
				cgrid.setFocus();
				break;
				
			case "delete" :
				cgrid.deleteSelection(true);
				cgrid.setSelectOptions( {style : "rows"});
				break;
	            
			// 저장
		    case "save" :
				try {
					cgrid.commit();
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
				if ( !fncValidateSave() )  return ;
				
				Message.confirm( "<lgcom:message code="question.save" />", function () {
					listGrid.useProgress(true);
					listGrid.saveChanges("lgvhr", "lgvpay/LGVPAYP0008/saveUse", function(data) {
						if ( data.result ) {
							if ( isNull(data.result.errCode) ) {//정상인 경우
								Message.alert("<lgcom:message code="note.saved"/>");
								//데이터 재조회
								fncRetrievePayrollItemUseList();
							} else {//실패인 경우
								Message.alert("<lgcom:message code="note.pay.failProcess"/>");
							}
						}
					});<%-- //listGrid.saveChanges --%>
					
				});<%-- //Message.confirm --%>
				break;
		}
		event.stopPropagation();
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	/*** 내부 함수  ***/
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		// Grid Field Set
		grid.setFields([
			{ fieldName:'payrollTypeCode'          , dataType:'text'  },
			{ fieldName:'oriPayrollTypeCode'       , dataType:'text'  },
			{ fieldName:'payrollTypeName'          , dataType:'text'  },
			{ fieldName:'effectiveStartYyyymmdd'   , dataType:'text'  },
			{ fieldName:'effectiveEndYyyymmdd'     , dataType:'text'  },
			{ fieldName:'oriEffectiveStartYyyymmdd', dataType:'text'  }
		]);
		// Grid Column Combo Setting
		grid.setLookups({
		    runTypeList : code.get("runTypeList")
		});
		// Grid Column Set
		grid.setColumns([
			{
				name:'payrollTypeCode',
				fieldName:'payrollTypeCode',
				width:220,
				header: {text:'<lgcom:message code="label.pay.use"/>', required: true},
				renderer: {showTooltip: true},
				lookupDisplay: true,
				lookupSourceId: 'runTypeList',
				lookupKeyFields: ['payrollTypeCode'],
				editor: {type:'dropdown', textReadOnly: true},
				editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
			},
			{
				name:'effectiveStartYyyymmdd',
				fieldName:'effectiveStartYyyymmdd',
				width:100,
				header: {text:'<lgcom:message code="StartDate"/>', required: true},
				styles: {textAlignment:'center'},
				editor: {type:'date',datetimeFormat:'dd/MM/yyyy', maxLength:10},
				editButtonVisibility: 'visible' /* 포커스 있는 경우만 날짜 버튼 보임 */
			},
			{
				name:'effectiveEndYyyymmdd',
				fieldName:'effectiveEndYyyymmdd',
				width:100,
				header: {text:'<lgcom:message code="EndDate"/>', required: true},
				styles: {textAlignment:'center'},
				editor: {type:'date',datetimeFormat:'dd/MM/yyyy', maxLength:10},
				editButtonVisibility: 'visible' /* 포커스 있는 경우만 날짜 버튼 보임 */
			}
		]);
		// Grid Option Set
		grid.setOptions({
			grid: {
				hideDeletedRows: true,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:false},
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
		//Validation Set
		grid.setValidations([
		    {criteria: "value['payrollTypeCode'] is not empty", message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.use'/>"/>',mode:'always',level:'error'}
		   ,{criteria: "value['effectiveStartYyyymmdd'] is not empty", message:'<lgcom:message code="error.required" arguments="<lgcom:message code='StartDate'/>"/>',mode:'always',level:'error'}
		   ,{criteria: "value['effectiveEndYyyymmdd'] is not empty", message:'<lgcom:message code="error.required" arguments="<lgcom:message code='EndDate'/>"/>',mode:'always',level:'error'}
		]);
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
	//입력값 validation
    listGrid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	}
	//저장 전 체크
	function fncValidateSave() {
		var cgrid = listGrid.getGridBase();
		var provider = cgrid.getDataProvider();
		var sMsg = "";
		
		//신규 또는 수정 건 체크
		var rowIdxs = provider.getStateRows("created").concat(provider.getStateRows("updated"));//dataRow배열값
		for ( var i=0; i<rowIdxs.length; i++ ) {
			var rowData = provider.getJsonRow(rowIdxs[i]);
			//PAY_VALUE 입력 불가 체크
			if ( rowData.detailName == "PAY_VALUE" ) {
				if ( provider.getRowState(rowIdxs[i]) == "updated" ) {//수정인 경우
					sMsg = "<lgcom:message code="note.pay.payValueCannotModify" />";
				} else {//신규인 경우
					sMsg = "<lgcom:message code="note.pay.payValueCannotRegister" />";
				}
				Message.alert(sMsg);
				cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:"detailName"});
				cgrid.setFocus();
				return false;
			}
			
			//시작일 체크
			if ( !fncValidateDateFormat(rowData.effectiveStartYyyymmdd) ) {
				Message.alert("<lgcom:message code="error.incorrectFormat" />");
				cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:"effectiveStartYyyymmdd"});
				cgrid.setFocus();
				return false;
			}
			
			//종료일 체크
			if ( !fncValidateDateFormat(rowData.effectiveEndYyyymmdd) ) {
				Message.alert("<lgcom:message code="error.incorrectFormat" />");
				cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:"effectiveEndYyyymmdd"});
				cgrid.setFocus();
				return false;
			}
			
			//시작일, 종료일 체크
			if ( DateUtil.parse(rowData.effectiveStartYyyymmdd, "DD/MM/YYYY") > DateUtil.parse(rowData.effectiveEndYyyymmdd, "DD/MM/YYYY") ) {
				Message.alert("<lgcom:message code="error.DataRangePickerFromDate" />");
				cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:"effectiveStartYyyymmdd"});
				cgrid.setFocus();
				return false;
			}
		}
		
		return true;
	}
	//데이터 조회
	function fncRetrievePayrollItemUseList() {
		var cgrid = listGrid.getGridBase();
		listGrid.getGridBase().cancel();
		listGrid.loadData("lgvhr", "lgvpay/LGVPAYP0008/retrievePayrollItemUseList", {payrollItemId:nvl(usePopData.payrollItemId)}, function(data) {
			//급여계산에서 사용된 항목인 경우라도 Use는 등록/수정/삭제 가능하도록 조건 삭제.
			myForm.select("button[data-action='add']").removeAttr("disabled");
			myForm.select("button[data-action='delete']").removeAttr("disabled");
			myForm.select("button[data-action='save']").removeAttr("disabled");
		});
	}
	
	//데이터 조회
	fncRetrievePayrollItemUseList();
}

LGVPAYP0008.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAYP0008();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.use"/></h2>
		</div>

		<div class="contentBlock grid-wrap">
			<div class="grid listGrid"></div>
		</div>

		<div class="controlBlock modal-footer module-group">
			<div class="btn-toolbar">
				<div class="btn-group">
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="add" disabled><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete" disabled><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save" disabled><lgcom:message code="Save"/></button>
				</div>
			</div>
		</div>
		
	</section>
</div>
</body>
</html>
