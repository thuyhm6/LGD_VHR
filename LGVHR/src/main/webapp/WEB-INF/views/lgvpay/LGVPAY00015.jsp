<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00015.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 급상여를 계산할 때 합계(누계)값을 관리하는 항목을 등록/수정/삭제하고 누계의 상세 값을 관리하는 화면입니다.
    작성자 : 임수진
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.aggregateManagement"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY00015 = function() {
	var grid;
	var myForm = this;
	var srchForm = '.searchBlock form';
	/* Form Util 선언 */ 
	var formUtil = new FormUtil( myForm, srchForm );

    // 화면 레이아웃 정의
	myForm.setLayout( [ 
    	{ name : "searchBlock",       left : 0, right : 0, top : 0 },
    	{ name : "masterButtonBlock", left : 0, right : 0, top : "searchBlock",  width : 850, bottom : "detailGridBlock"},
    	{ name : "masterGridBlock",   left : 0, right : 0, top : "masterButtonBlock", width : 850, bottom : 0},
    	{ name : "detailButtonBlock", left : "masterButtonBlock", right : 0, top : "searchBlock",  bottom : "detailGridBlock"},
    	{ name : "detailGridBlock",   left : "masterButtonBlock", right : 0, top : "detailButtonBlock", bottom : 0}
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
	var code = new CommonCode("lgcom");
    code.add( "aggregateTypeList", {codeTypeCode:'LGDVHR_PAY_AGGR_TYPE_CODE'});
    code.add( "classTypeList"    , {codeTypeCode:'LGDVHR_PAY_CLASS_TYPE_CODE'});
    code.add( "itemMethodList"   , {codeTypeCode:'LGDVH_PAY_ITEM_METHOD_CODE'});
	code.add( "ynList"           , {codeTypeCode:'LGCOM_YN_FLAG'} );
	code.execute();
    
    // 그리드선언
	var masterGrid = buildGrid(".masterGrid");
	var detailGrid = buildGrid(".detailGrid");

    // 날짜 팝업창
    
    // 필수항목 체크

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
				masterGrid.getGridBase().cancel();
				masterGrid.loadData("lgvhr", "lgvpay/LGVPAY00015/retrieveAggregateList", formUtil.getValue(), function(data) {
					if ( data.result ) {
						// Master Grid 수정 여부 셋팅
						fncSetEditableControlMasterAll(masterGrid.getGridBase(), masterGrid.getDataProvider());	
					} else {
						// detail grid 초기화
						detailGrid.getDataProvider().clearRows();
					}
				});
				break;
				
			case "add1" :
				var mgrid = masterGrid.getGridBase();
				detailGrid.getGridBase().cancel();
				try {
					mgrid.commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				
				if ( mgrid.getCurrent().itemIndex < 0 ) {
					mgrid.beginAppendRow();
				} else {
					mgrid.beginInsertRow(mgrid.getCurrent().itemIndex);
				}

				var currCell = mgrid.getCurrent();
				var itemIndex = currCell.itemIndex;
				mgrid.setCurrent({column:'payrollItemAggregateName'});
				mgrid.setFocus();

				// detail grid 초기화
				detailGrid.getDataProvider().clearRows();

				// detail 목록 조회
				if ( itemIndex > -1 && !isNull(mgrid.getValue(itemIndex, "payrollItemAggregateId")) ) {
					fncRetrieveAggregateDetailList(mgrid.getValue(itemIndex, "payrollItemAggregateId"), mgrid.getValue(itemIndex, "payrollAggregateTypeCode"), mgrid.getValue(itemIndex, "usedFlag"));
				}
				break;
				
			case "delete1" :
				var mGrid = masterGrid.getGridBase();
				var itemIndex = mGrid.getCurrent().itemIndex;
				if ( nvl(mGrid.getValue(itemIndex, "usedFlag"), "N") == "N" ) {//급여항목에 이미 등록된 경우 삭제 불가
					Message.alert("<lgcom:message code="note.pay.deleteAlreadyExistsPayrollItem" />");
					return ;
				} else {
					mGrid.deleteSelection(true);
					mGrid.setSelectOptions( {style : "rows"});
				}
				break;

			case "save1" :
				try {
					masterGrid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				
				if( masterGrid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};

				// 변경건이 있는지 체크
				if(!masterGrid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				
				//저장 전 체크
				if ( !fncValidateSaveAggregate() ) return ;
				
				Message.confirm( '<lgcom:message code="question.save"/>' , function() {
					masterGrid.useProgress(true);
					masterGrid.saveChanges( "lgvhr", 'lgvpay/LGVPAY00015/saveAggregateList', function(data) {
						Message.alert('<lgcom:message code="note.saved"/>');
						// 저장 완료후 목록 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
				break;

			case "add2" :
				var dgrid = detailGrid.getGridBase();
				var payrollItemAggregateId = fncRetrieveMasterData().payrollItemAggregateId;
				var payrollAggregateTypeCode = fncRetrieveMasterData().payrollAggregateTypeCode;

				//Aggregate 가 없는 경우 행 추가 불가
				if($.trim(payrollItemAggregateId) == '') {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.aggregateName'/>"/>');
					return;
				}
				
				try {
					dgrid.commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}

				if(dgrid.getCurrent().itemIndex < 0) {
					dgrid.beginAppendRow();
				} else {
					dgrid.beginInsertRow(dgrid.getCurrent().itemIndex);
				} 
				var currCell = dgrid.getCurrent();
				var itemIndex = currCell.itemIndex;
				dgrid.setValue(itemIndex, "effectiveEndYyyymmdd", DateUtil.format(DateUtil.parse("47121231", "YYYYMMDD"), "DD/MM/YYYY"));//종료일은 4712/12/31 기본값 셋팅
				if ( payrollAggregateTypeCode == "CLASS" ) {
					dgrid.setCurrent({itemIndex: itemIndex, column:"classTypeCode"});
				} else if ( payrollAggregateTypeCode == "METHOD" ) {
					dgrid.setCurrent({itemIndex: itemIndex, column:"itemMethodCode"});
				} else if ( payrollAggregateTypeCode == "ITEM" ) {
					dgrid.setCurrent({itemIndex: itemIndex, column:"payrollItemDetailName"});
				}
				dgrid.setFocus();
				break;
				
			case "delete2" :
				detailGrid.getGridBase().deleteSelection(true);
				detailGrid.getGridBase().setSelectOptions( {style : "rows"});
				break;

			case "save2" :
				try {
					detailGrid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				
				if( detailGrid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};

				// 변경건이 있는지 체크
				if(!detailGrid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				
				//저장전 체크
				if ( !fncValidateSaveAggregateDetail() ) return ;
				
				Message.confirm( '<lgcom:message code="question.save"/>' , function() {
					detailGrid.useProgress(true);
					detailGrid.saveChanges( "lgvhr", 'lgvpay/LGVPAY00015/saveAggregateDetailList', function(data) {
						Message.alert('<lgcom:message code="note.saved"/>');
						// 저장 완료후 목록 재조회
						fncRetrieveAggregateDetailList(fncRetrieveMasterData().payrollItemAggregateId, fncRetrieveMasterData().payrollAggregateTypeCode, fncRetrieveMasterData().usedFlag);
					});
				});
				break;
		}
		event.stopPropagation();
	});
    
	/*** 내부 함수  ***/
	// Aggregate Detail 목록 조회
	function fncRetrieveAggregateDetailList(payrollItemAggregateId, payrollAggregateTypeCode, usedFlag) {
		//Aggregate Type에 따라 detail 컬럼 visible 속성변경.
		fncSetVisibleControlDetail(payrollAggregateTypeCode);
		
		detailGrid.loadData("lgvhr","lgvpay/LGVPAY00015/retrieveAggregateDetailList", { payrollItemAggregateId: $.trim(payrollItemAggregateId) }, function(data) {
			if ( data.result ) {
				var cgrid = detailGrid.getGridBase();
				var provider = detailGrid.getDataProvider();
				
				for ( var i=0; i<data.result.length; i++ ) {
					//detail grid 수정가능 여부 스타일 셋팅
					fncSetEditableControlDetail(cgrid, provider, i, (nvl(usedFlag) == "Y")?"N":"Y");
				}
			}
		});<%-- //detailGrid.loadData --%>
	}
	
	//Master Grid 전체 행 수정 가능여부 셋팅
	function fncSetEditableControlMasterAll(cgrid, provider) {
		<%-- [PARAMETER]
		     - cgrid : grid.getGridBase()
		     - provider : grid.getGridBase().getDataProvider()
		     - editFlag
		       - Y : 수정 가능. 행 추가시 수정 가능 여부 셋팅. 그외는 행별 수정/삭제가능여부 컬럼 값에 따라 수정 여부 셋팅
		       - N : 수정 불가능.
		--%>
		for ( var j=0; j<provider.getRowCount(); j++ ) {
			fncSetEditableControlMaster(cgrid, provider, j, (nvl(provider.getValue(j, "usedFlag"), "N") == "N")?"Y":"N");
		}
	}

	//Master 그리드 행별 수정 가능여부 셋팅
	function fncSetEditableControlMaster(cgrid, provider, dataRow, editFlag) {
		<%-- [PARAMETER]
		     - cgrid : grid.getGridBase()
		     - provider : grid.getGridBase().getDataProvider()
		     - dataRow : 데이터셋 row index(dataRow)
		     - editFlag
		       - Y : 수정 가능. 행 추가시 수정 가능 여부 셋팅. 그외는 행별 수정/삭제가능여부 컬럼 값에 따라 수정 여부 셋팅
		       - N : 수정 불가능.
		--%>
		var fieldNames = provider.getOrgFieldNames();
		
		if ( dataRow > -1 && dataRow < provider.getRowCount() ) {			
			//수정, 삭제 가능여부에 따라 수정 또는 조회 스타일 셋팅
			editFlag = (nvl(editFlag, "N") == "Y" || nvl(cgrid.getValue(cgrid.getItemIndex(dataRow), "usedFlag"), "N") == "N")?"Y":"N";
			
			for ( var i=0; i<fieldNames.length; i++ ) {
				//수정 가능여부에 따라 셀 스타일 적용
				cgrid.setCellStyle(dataRow, fieldNames[i], (editFlag == "Y")?"editableStyle":"readOnlyStyle", true);
			}<%-- //for --%>
		}<%-- //if --%>
	}
	
	//Detail 그리드 visible 설정
	function fncSetVisibleControlDetail(payrollAggregateTypeCode) {
		<%-- Aggregate Type에 따라 detail 컬럼 visible 속성변경.
		     - CLASS
		       - visible column name : classTypeCode
		       - hide column name : aggregateDetailValue, itemMethodCode, payrollItemName, payrollItemDetailName
		     - METHOD
		       - visible column name : itemMethodCode
		       - hide column name : aggregateDetailValue, classTypeCode, payrollItemName, payrollItemDetailName
		     - ITEM
		       - visible column name 
                 - editable : payrollItemDetailName
                 - disable : payrollItemName
		       - hide column name : classTypeCode, itemMethodCode, aggregateDetailValue
		--%>
		var cgrid = detailGrid.getGridBase();
		var provider = detailGrid.getDataProvider();
		
		switch ( payrollAggregateTypeCode ) {
			case "CLASS" : 
				cgrid.setColumnProperty("classTypeCode"        , "visible" , true);
				cgrid.setColumnProperty("classTypeCode"        , "editable", true);
				cgrid.setColumnProperty("itemMethodCode"       , "visible" , false);
				cgrid.setColumnProperty("aggregateDetailValue" , "visible" , true);
				cgrid.setColumnProperty("payrollItemName"      , "visible" , false);
				cgrid.setColumnProperty("payrollItemDetailName", "visible" , false);
				break;
			case "METHOD" :
				cgrid.setColumnProperty("classTypeCode"        , "visible" , false);
				cgrid.setColumnProperty("itemMethodCode"       , "visible" , true);
				cgrid.setColumnProperty("itemMethodCode"       , "editable", true);
				cgrid.setColumnProperty("aggregateDetailValue" , "visible" , true);
				cgrid.setColumnProperty("payrollItemName"      , "visible" , false);
				cgrid.setColumnProperty("payrollItemDetailName", "visible" , false);
				break;
			case "ITEM" :
				cgrid.setColumnProperty("classTypeCode"        , "visible" , false);
				cgrid.setColumnProperty("itemMethodCode"       , "visible" , false);
				cgrid.setColumnProperty("aggregateDetailValue" , "visible" , false);
				cgrid.setColumnProperty("payrollItemName"      , "visible" , true);
				cgrid.setColumnProperty("payrollItemDetailName", "visible" , true);
				cgrid.setColumnProperty("payrollItemDetailName", "editable", true);
				break;
		}<%-- //switch --%>
	}

	//Detail 그리드 행별 수정 가능여부 셋팅
	function fncSetEditableControlDetail(cgrid, provider, dataRow, editFlag) {
		<%-- [PARAMETER]
		     - cgrid : grid.getGridBase()
		     - provider : grid.getGridBase().getDataProvider()
		     - dataRow : 데이터셋 row index(dataRow)
		     - editFlag
		       - Y : 수정 가능. 행 추가시 수정 가능 여부 셋팅. 그외는 행별 수정/삭제가능여부 컬럼 값에 따라 수정 여부 셋팅
		       - N : 수정 불가능.
		--%>
		var columns = cgrid.getColumns();
		var masterData = fncRetrieveMasterData();
		
		if ( dataRow > -1 && dataRow < provider.getRowCount() ) {
			//수정, 삭제 가능여부에 따라 수정 또는 조회 스타일 셋팅
			for ( var i=0; i<columns.length; i++ ) {
				
				//종료일 항상 수정가능
				if ( columns[i].fieldName == "effectiveEndYyyymmdd" ) {
					cgrid.setCellStyle(dataRow, columns[i].fieldName, "editableStyle", true);
					
				//Aggregate Type = CLASS or METHOD 인 경우 Aggregate Detail Value 비활성화
				} else if ( columns[i].fieldName == "aggregateDetailValue" && (masterData.payrollAggregateTypeCode == "CLASS" || masterData.payrollAggregateTypeCode == "METHOD") ) {
					cgrid.setCellStyle(dataRow, columns[i].fieldName, "readOnlyStyle", true);
					
				//Aggregate Type = ITEM 인 경우 Aggregate Detail Name 비활성화
				} else if ( columns[i].fieldName == "aggregateDetailName" && masterData.payrollAggregateTypeCode == "ITEM" ) {
					cgrid.setCellStyle(dataRow, columns[i].fieldName, "readOnlyStyle", true);
					
				//수정 가능한 경우
				} else if ( editFlag == "Y" ) {
					cgrid.setCellStyle(dataRow, columns[i].fieldName, "editableStyle", true);
				
				} else {
					cgrid.setCellStyle(dataRow, columns[i].fieldName, "readOnlyStyle", true);
					
				}
			}<%-- //for --%>
		}<%-- //if --%>
	}
	
	//마스터 그리드의 현재행 데이터 조회
	function fncRetrieveMasterData() {
		return masterGrid.getGridBase().getValues(masterGrid.getGridBase().getCurrent().itemIndex);
	}
    
	//Aggregate 저장 전 체크
	function fncValidateSaveAggregate() {
		var cgrid = masterGrid.getGridBase();
		var provider = cgrid.getDataProvider();
		var sMsg = "";
		
		//신규 건 또는 수정건 체크
		var rowIdxs = provider.getStateRows("created").concat(provider.getStateRows("updated"));//dataRow배열값
		for ( var i=0; i<rowIdxs.length; i++ ) {
			var rowData = provider.getJsonRow(rowIdxs[i]);

			//usage(run, month, year) 중 하나는 Y여야 함.
			if ( nvl(rowData.runFlag) != "Y" && nvl(rowData.monthFlag) != "Y" && nvl(rowData.yearFlag) != "Y" ) {
				Message.alert("<lgcom:message code="note.pay.selectUsageValue" />");
				cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:"runFlag"});
				cgrid.setFocus();
				return false;
			}
		}	
		
		return true;
	}
    
	//Aggregate Detail 저장 전 체크
	function fncValidateSaveAggregateDetail() {
		var cgrid = detailGrid.getGridBase();
		var provider = cgrid.getDataProvider();
		var masterData = fncRetrieveMasterData();
		var payrollItemAggregateId = masterData.payrollItemAggregateId;
		var sMsg = "";
		
		//Master 그리드의 payrollAggregateTypeCode 값이 ITEM 인 경우 Aggregate Detail Value 필수값 체크
		//신규 건 또는 수정건 체크
		var rowIdxs = provider.getStateRows("created").concat(provider.getStateRows("updated"));//dataRow배열값
		for ( var i=0; i<rowIdxs.length; i++ ) {
			var rowData = provider.getJsonRow(rowIdxs[i]);
			
			//Master 그리드의 payrollAggregateTypeCode 값이 CLASS 인 경우 Aggregate Detail Name 필수값 체크
			if ( nvl(masterData.payrollAggregateTypeCode) == "CLASS" && isNull(rowData.payItemClassificationCode) ) {
				Message.alert("<lgcom:message code="error.required" arguments='<lgcom:message code="label.pay.aggregateDetailName" />'/>");
				cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:"classTypeCode"});
				cgrid.setFocus();
				return false;
			}

			//Master 그리드의 payrollAggregateTypeCode 값이 METHOD 인 경우 Aggregate Detail Name 필수값 체크
			if ( nvl(masterData.payrollAggregateTypeCode) == "METHOD" && isNull(rowData.payItemClassificationCode) ) {
				Message.alert("<lgcom:message code="error.required" arguments='<lgcom:message code="label.pay.aggregateDetailName" />'/>");
				cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:"itemMethodCode"});
				cgrid.setFocus();
				return false;
			}
			
			//Master 그리드의 payrollAggregateTypeCode 값이 ITEM 인 경우 Aggregate Detail Value 필수값 체크
			if ( nvl(masterData.payrollAggregateTypeCode) == "ITEM" 
					&& (isNull(rowData.payrollItemId) || isNull(rowData.payrollItemDetailDetailId)) ) {
				Message.alert("<lgcom:message code="error.required" arguments='<lgcom:message code="label.pay.aggregateDetailValue" />'/>");
				cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:"payrollItemDetailName"});
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
			
			//시작일이 종료일 이후인지 체크
			if ( DateUtil.parse(rowData.effectiveStartYyyymmdd, "DD/MM/YYYY") > DateUtil.parse(rowData.effectiveEndYyyymmdd, "DD/MM/YYYY") ) {
				Message.alert("<lgcom:message code="error.DataRangePickerFromDate" />");
				cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:"effectiveStartYyyymmdd"});
				cgrid.setFocus();
				return false;
			}
		}	
		
		return true;
	}

	//parent payroll item Detail popup호출
	function fncPopupPayrollItemDetail(itemIndex, colName) {
		var popupData = myForm.popupInfo.detailPopup;
		popupData.row        = itemIndex;
		popupData.col        = colName;
		popupData.detailData = [];

		var popup = new Popup(myForm, "lgvhr", 'M_LGVPAY_1038','<lgcom:message code="label.pay.payrollItemDetail"/>');
		popup.setSize(812, 512);
		popup.open(function() {
			if ( popupData.detailData != undefined && popupData.detailData.length > 0 ) {
				var selectData = popupData.detailData[0];

				detailGrid.getGridBase().setValue(popupData.row, "payrollItemId"            , selectData.payrollItemId);
				detailGrid.getGridBase().setValue(popupData.row, "aggregateDetailName"      , selectData.inquiryName);//payrollItemName
				detailGrid.getGridBase().setValue(popupData.row, "payrollItemDetailDetailId", selectData.payrollItemDetailDetailId);
				detailGrid.getGridBase().setValue(popupData.row, "aggregateDetailValue"     , selectData.additionalInputValue);//payrollItemDetailName
				detailGrid.getGridBase().commit();
			}
		});
	}
	
	//그리드 초기화
	function buildGrid(gridId) {
		var grid;
		switch ( gridId ) {
			case ".masterGrid" :
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
							height: 50
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
					{ fieldName:'payrollItemAggregateId'  , dataType:'number'},
					{ fieldName:'payrollItemAggregateName', dataType:'text'  },
					{ fieldName:'detailDesc'              , dataType:'text'  },
					{ fieldName:'payrollAggregateTypeCode', dataType:'text'  },
					{ fieldName:'payrollAggregateTypeName', dataType:'text'  },
					{ fieldName:'runFlag'                 , dataType:'text'  },
					{ fieldName:'monthFlag'               , dataType:'text'  },
					{ fieldName:'yearFlag'                , dataType:'text'  },
					{ fieldName:'usedFlag'                , dataType:'text'  }
				]);
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
				//컬럼 콤보 셋팅
				grid.setLookups({
					aggregateTypeList : code.get("aggregateTypeList")
				  , ynList            : code.get("ynList")
				});
		
				//컬럼 설정
				grid.setColumns([
					{
						name:'payrollItemAggregateName',
						fieldName:'payrollItemAggregateName',
						width:200,
						header: {text:'<lgcom:message code="label.pay.aggregateName"/>', required: true},
						renderer: {showTooltip: true},
					},
					{
						name:'detailDesc',
						fieldName:'detailDesc',
						width:200,
						header: {text:'<lgcom:message code="Description"/>'},
						renderer: {showTooltip: true},
					},
					{
						name:'payrollAggregateTypeCode',
						fieldName:'payrollAggregateTypeCode',
						width:150,
						header: {text:'<lgcom:message code="label.pay.aggregateType"/>', required: true},
						styles: {textAlignment:'near'},
						renderer: {showTooltip: true},
						lookupDisplay: true,
						lookupSourceId: 'aggregateTypeList',
						lookupKeyFields: ['payrollAggregateTypeCode'],
						editor: {type:'dropDown',textReadOnly:true},
						editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
					},
					{	type:'group',
						name:'usage',
						fieldName:'usage',
						width:210,
						header:{
					         text:'<lgcom:message code="label.pay.usage" />'
					    },
						orientation:'horizontal',
						columns: [
									{	name:'runFlag',
										fieldName:'runFlag',
										width:70,
										header: {text:'<lgcom:message code="label.pay.run"/>', required:true},
										styles: {textAlignment:'center'},
										defaultValue: 'N',
										lookupDisplay: true,
										lookupSourceId: 'ynList',
										lookupKeyFields: ['runFlag'],
										editor: {type:'dropDown',textReadOnly:true},
										editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
									},
									{	name:'monthFlag',
										fieldName:'monthFlag',
										width:70,
										header: {text:'<lgcom:message code="month"/>', required:true},
										styles: {textAlignment:'center'},
										defaultValue: 'N',
										lookupDisplay: true,
										lookupSourceId: 'ynList',
										lookupKeyFields: ['monthFlag'],
										editor: {type:'dropDown',textReadOnly:true},
										editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
									},
									{	name:'yearFlag',
										fieldName:'yearFlag',
										width:70,
										header: {text:'<lgcom:message code="Year"/>', required:true},
										styles: {textAlignment:'center'},
										defaultValue: 'N',
										lookupDisplay: true,
										lookupSourceId: 'ynList',
										lookupKeyFields: ['yearFlag'],
										editor: {type:'dropDown',textReadOnly:true},
										editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
									}
								]
					}
				]);
		
				grid.setValidations([
					{criteria: "value['payrollItemAggregateName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.aggregateName'/>"/>',mode:'always',level:'error'},
					{criteria: "value['payrollAggregateTypeCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.aggregateType'/>"/>',mode:'always',level:'error'},
					{criteria: "value['runFlag'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.run'/>"/>',mode:'always',level:'error'},
					{criteria: "value['monthFlag'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='month'/>"/>',mode:'always',level:'error'},
					{criteria: "value['yearFlag'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='Year'/>"/>',mode:'always',level:'error'}
				]);
				
				break;
			case ".detailGrid" :
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
					{ fieldName:'payrollItemAggregateId'   , dataType:'number'},
					{ fieldName:'oriPayrollItemDetailId'   , dataType:'number'},
					{ fieldName:'payrollItemDetailDetailId', dataType:'number'},
					{ fieldName:'payrollItemId'            , dataType:'number'},
					{ fieldName:'payItemClassificationCode', dataType:'text'  },
					{ fieldName:'aggregateDetailName'      , dataType:'text'  },
					{ fieldName:'aggregateDetailValue'     , dataType:'text'  },
					{ fieldName:'oriEffectiveStartYyyymmdd', dataType:'text'  },
					{ fieldName:'effectiveStartYyyymmdd'   , dataType:'text'  },
					{ fieldName:'effectiveEndYyyymmdd'     , dataType:'text'  }
				]);
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
				//컬럼 콤보 셋팅
				grid.setLookups({
					classTypeList : code.get("classTypeList")
				  , itemMethodList : code.get("itemMethodList")
				});
				//컬럼 설정
				grid.setColumns([
					{
						name:'classTypeCode',
						fieldName:'payItemClassificationCode',
						width:200,
						header: {text:'<lgcom:message code="label.pay.aggregateDetailName"/>', required: true},
						styles: {textAlignment:'near'},
						renderer: {showTooltip: true},
						lookupDisplay: true,
						lookupSourceId: 'classTypeList',
						lookupKeyFields: ['payItemClassificationCode'],
						editor: {type:'dropDown',textReadOnly:true},
						editButtonVisibility: 'visible', /* 포커스 있는 경우만 dropdown 버튼 보임 */
						editable: true,
						visible: true
					},
					{
						name:'itemMethodCode',
						fieldName:'payItemClassificationCode',
						width:200,
						header: {text:'<lgcom:message code="label.pay.aggregateDetailName"/>', required: true},
						styles: {textAlignment:'near'},
						renderer: {showTooltip: true},
						lookupDisplay: true,
						lookupSourceId: 'itemMethodList',
						lookupKeyFields: ['payItemClassificationCode'],
						editor: {type:'dropDown',textReadOnly:true},
						editButtonVisibility: 'visible', /* 포커스 있는 경우만 dropdown 버튼 보임 */
						editable: false,
						visible: false
					},
					{
						name:'payrollItemName',
						fieldName:'aggregateDetailName',
						width:200,
						header: {text:'<lgcom:message code="label.pay.aggregateDetailName"/>', required: true},
						styles: {background:"#e9e9e9"},
						renderer: {showTooltip: true},
						editable: false,
						visible: false
					},
					{
						name:'aggregateDetailValue',
						fieldName:'aggregateDetailValue',
						width:200,
						header: {text:'<lgcom:message code="label.pay.aggregateDetailValue"/>'},
						styles: {background:"#e9e9e9"},
						editable: false,
						visible: true
					},
					{
						name:'payrollItemDetailName',
						fieldName:'aggregateDetailValue',
						width:200,
						header: {text:'<lgcom:message code="label.pay.aggregateDetailValue"/>', required: true},
						button: 'action',
						buttonVisibility: 'visible', /* 포커스 있는 경우만 검색 버튼 보임 */
						editable: false,
						visible: false
					},
					{
						name:'effectiveStartYyyymmdd',
						fieldName:'effectiveStartYyyymmdd',
						width:130,
						header: {text:'<lgcom:message code="EffectiveStartDate"/>', required: true},
						styles: {textAlignment:'center'},
						editor: {type:'date', datetimeFormat:'dd/MM/yyyy', maxLength:10},
						editButtonVisibility: 'visible' /* 포커스 있는 경우만 날짜 버튼 보임 */
					},
					{
						name:'effectiveEndYyyymmdd',
						fieldName:'effectiveEndYyyymmdd',
						width:130,
						header: {text:'<lgcom:message code="EffectEndDate"/>', required: true},
						styles: {textAlignment:'center'},
						editor: {type:'date', datetimeFormat:'dd/MM/yyyy', maxLength:10},
						editButtonVisibility: 'visible' /* 포커스 있는 경우만 날짜 버튼 보임 */
					}
				]);

				// Validation Set		
				grid.setValidations([
					{criteria: "value['effectiveStartYyyymmdd'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='EffectiveStartDate'/>"/>',mode:'always',level:'error'},
					{criteria: "value['effectiveEndYyyymmdd'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='EffectEndDate'/>"/>',mode:'always',level:'error'}
				]);				
				break;
		}
		return grid;
	}
	masterGrid.getGridBase().addCellStyle("readOnlyStyle", {editable:false, background:"#e9e9e9"}, true);/* 수정불가능한 경우 배경색을 구분해서 보여줘야 함 */
	masterGrid.getGridBase().addCellStyle("editableStyle", {editable:true, background:"#FFFFFF"}, true);/* 사용자가 입력하는 경우 사용할 스타일. 수정 가능해야하고, 배경색도 수정 가능한 상태로 보여줘야 함 */
	detailGrid.getGridBase().addCellStyle("readOnlyStyle", {editable:false, background:"#e9e9e9"}, true);/* 수정불가능한 경우 배경색을 구분해서 보여줘야 함 */
	detailGrid.getGridBase().addCellStyle("editableStyle", {editable:true, background:"#FFFFFF"}, true);/* 사용자가 입력하는 경우 사용할 스타일. 수정 가능해야하고, 배경색도 수정 가능한 상태로 보여줘야 함 */
	/* 그리드 이벤트 처리 */
	// 샐의 dataRow가 바뀔때(행 추가 이벤트 시)
	masterGrid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		<%--[PARAMETER]
		    - cgrid : grid.getGridBase()
		    - oldRow : 변경 전 데이터행의 dataRow
		    - newRow : 변경 후 데이터행의 dataRow
		    
		    *dataRow : 최초 조회한 데이터셋의 row index
		--%>
		detailGrid.getGridBase().cancel();
		detailGrid.getDataProvider().clearRows();
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created' || nvl(provider.getValue(newRow, "usedFlag"), "N") === "N";
				
		//master grid 셀 수정 여부 셋팅
		fncSetEditableControlMaster(cgrid, provider, newRow, (editable?"Y":""));
		
		//삭제버튼 활성화 처리
		if ( editable ) {
			myForm.select("button[data-action='delete1']").removeAttr("disabled");//삭제버튼 활성화
			myForm.select("button[data-action='delete2']").removeAttr("disabled");//삭제버튼 활성화
		} else {
			myForm.select("button[data-action='delete1']").attr("disabled", "disabled");//삭제버튼 비활성화
			//myForm.select("button[data-action='delete2']").attr("disabled", "disabled");//삭제버튼 비활성화
			myForm.select("button[data-action='delete2']").removeAttr("disabled");//삭제버튼 활성화(master 항목 수정불가인 경우라도 detail에 추가는 가능하기 때문에, 추가한 경우 삭제할 방법이 없으므로 삭제 가능하도록 제약 풀기)
		}
		
		// detail 목록 조회
		var rowData = cgrid.getValues(cgrid.getCurrent().itemIndex);
		if ( cgrid.getCurrent().itemIndex > -1 && !isNull(rowData.payrollItemAggregateId) ) {
			fncRetrieveAggregateDetailList(rowData.payrollItemAggregateId, rowData.payrollAggregateTypeCode, rowData.usedFlag);
		}
	};
	// 샐의 dataRow가 바뀔때(행 추가 이벤트 시)
	detailGrid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		<%--[PARAMETER]
		    - cgrid : grid.getGridBase()
		    - oldRow : 변경 전 데이터행의 dataRow
		    - newRow : 변경 후 데이터행의 dataRow
		    
		    *dataRow : 최초 조회한 데이터셋의 row index
		--%>
		var provider = cgrid.getDataProvider();
		var masterData = fncRetrieveMasterData();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created' || nvl(masterData.usedFlag, "N") === "N";
		
		//detail grid 셀 수정 여부 셋팅
		fncSetEditableControlDetail(cgrid, provider, newRow, (editable)?"Y":"N");

		//Aggregate Detail Value button 보여줌 
		if ( nvl(masterData.payrollAggregateTypeCode) == "ITEM" ) {
			cgrid.setColumnProperty("payrollItemDetailName", "buttonVisibility", (editable)?'visible':'hidden');
		}
		
		//삭제버튼 활성화 처리
		if ( editable ) {
			myForm.select("button[data-action='delete2']").removeAttr("disabled");//삭제버튼 활성화
		} else {
			//myForm.select("button[data-action='delete2']").attr("disabled", "disabled");//삭제버튼 비활성화
			myForm.select("button[data-action='delete2']").removeAttr("disabled");//삭제버튼 활성화(master 항목 수정불가인 경우라도 detail에 추가는 가능하기 때문에, 추가한 경우 삭제할 방법이 없으므로 삭제 가능하도록 제약 풀기)
		}
	};
	//그리드 팝업버튼 클릭시 이벤트
	detailGrid.getGridBase().onCellButtonClicked = function(cgrid, itemIndex, column) {
		cgrid.commitEditor();
		var currRow = cgrid.getCurrent();
		var gridRow = cgrid.getValues(currRow.itemIndex);
		
		fncPopupPayrollItemDetail(itemIndex, column.name);
	};
	//입력값이 셀에 반영될 때 이벤트
	detailGrid.getGridBase().onEditCommit = function(cgrid, index, oldValue, newValue) {
		//급여항목Detail명 삭제 또는 변경 시 급여항목Detail ID, 급여항목명, 급여항목ID 값 모두 삭제 처리함.
		if ( index.column == "payrollItemDetailName" 
				&& (isNull(newValue) || nvl(oldValue) != nvl(newValue) ) ) {
			cgrid.setValue(index.itemIndex, "payrollItemId", null);
			cgrid.setValue(index.itemIndex, "aggregateDetailName", "");//payrollItemName
			cgrid.setValue(index.itemIndex, "payrollItemDetailDetailId", null);
			cgrid.setValue(index.itemIndex, "aggregateDetailValue", newValue);//payrollItemDetailName
			cgrid.commit();
		}
	};
	masterGrid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	detailGrid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	
}

LGVPAY00015.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY00015();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.aggregateManagement"/></h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<table class="table" >
					<colgroup>
						<col width="120">
						<col width="200">
						<col width="*">
					</colgroup>
					<tbody>
						<tr>
							<th><label><lgcom:message code="label.pay.aggregateName"/></label></th>
							<td><input type="text" class="form-control input-sm" name="payrollItemAggregateName"/></td>
							<td></td>
						</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- 마스터 그리드 버튼 --%>
		<div class="module-group text-right masterButtonBlock" >
			<div class="btn-toolbar">
				<div class="btn-group">
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="add1"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete1"><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save1"><lgcom:message code="save"/></button>
				</div>
			</div>
		</div>
		<%-- 마스터 그리드 --%>
		<div class="masterGridBlock grid-wrap">
			<div class="grid masterGrid"></div>
		</div>
		<%-- 디테일 그리드 버튼 --%>
		<div class="module-group text-right detailButtonBlock" >
			<div class="btn-toolbar">
				<div class="btn-group">
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="add2"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete2"><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save2"><lgcom:message code="save"/></button>
				</div>
			</div>
		</div>
		<%-- 디테일 그리드 --%>
		<div class="detailGridBlock grid-wrap">
			<div class="grid detailGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
