<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSETC00070.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 레이블 정보를 관리하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Label Master</title>
<style type="text/css">
  .ui-autocomplete-loading {
    background: white url("https://jqueryui.com/resources/demos/autocomplete/images/ui-anim_basic_16x16.gif") right center no-repeat;
  }

</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">

var LGSETC00070 = function(){
    var grid;
    var myForm = this;

 	// 조회조건 Combo 초기화
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	var code = new CommonCode("lgcom");

	var combo1 = code.execute('retrieveCommonCodeList',{codeTypeCode:'LGCOM_LABEL_TYPE_CODE'});
	formUtil.initCombo('labelTypeCode',combo1,{selectAll:true});

	var combo2 = code.execute('retrieveCommonCodeList',{codeTypeCode:'LGCOM_LANGUAGE_CODE'});
	formUtil.initCombo('languageCode',combo2,{selectAll:true});

    /* Layout Setting */
	myForm.setLayout( [
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock", bottom : "gridContent"},
		{ name : "gridContent",  left : 0, right : 0, top : "gridControls", bottom : 0 }
    ]);

	// 그리드 선언
   	grid = buildGrid(".labelGrid");


    // 조회조건 저장 처리
	myForm.searchConditionControl(true);

	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		var cgrid = grid.getGridBase();
		switch( action ){
	    	case "search" :
	    		cgrid.cancel();
				var param = myForm.select(".searchBlock form").toJSON();
				grid.loadData('lgcom', 'lgsetc/LGSETC00070/retrieveLabelList', param );
				if(grid.getDataProvider().getRowCount() > 0){
		    		var index = {itemIndex: 0};
					grid.getGridBase().setCurrent(index);
		    	}
				break;
			case 'insert':
				cgrid.commit();
				if(cgrid.getCurrent().itemIndex < 0) {
					cgrid.beginAppendRow();
				} else {
					cgrid.beginInsertRow(cgrid.getCurrent().itemIndex);
				}
				cgrid.setCurrent({column:'labelTypeCode'});
				cgrid.setFocus();
				break;
			case 'delete':
				cgrid.deleteSelection(true);
				break;
		    case "save" :
				try {
					grid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				if( grid.getRowCount() == 0 ) {
					Message.notify('<lgcom:message code="note.nodata" />');
					return;
				};
				// 변경건이 있는지 체크
				if(!grid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				Message.confirm( "<lgcom:message code="question.save" />" , function(){
					grid.useProgress(true);
					grid.saveChanges('lgcom', 'lgsetc/LGSETC00070/saveLabelList',function(data) {
						Message.notify('<lgcom:message code="note.completed" />');
						// 저장 완료후 목록 재조회
						myForm.select("button[data-action='search']").trigger('click');
						//window.open("http://localhost:8080/lgcom/refresh");
					});
				});
				break;
		}
	});

	/* 그리드 이벤트 처리 && 중복 데이터 체크 */
	grid.getGridBase().onCurrentChanging = function(cgrid, oldIndex, newIndex) {
		var editRow = oldIndex.dataRow;
		var editable = editRow < 0 || cgrid.getDataProvider().getRowState(editRow) === 'created';

		if(editable){

			if(oldIndex.column == "labelId"){

				var labelId = cgrid.getValue(cgrid.getCurrent().itemIndex,"labelId");
				var languageCode = cgrid.getValue(cgrid.getCurrent().itemIndex,"languageCode");
				var labelTypeCode = cgrid.getValue(cgrid.getCurrent().itemIndex,"labelTypeCode");
				var param = {labelId : labelId, languageCode : languageCode, labelTypeCode: labelTypeCode};

				transaction_sync( 'lgcom','lgsetc/LGSETC00070/retrieveLabelIdChk', param, function(data){
			    	var result = data["result"][0];

			    	if(result["cnt"] == 0){
			    	}else{
						Message.alert('<lgcom:message code="error.duplicateValue"/>');
			    	}
				});
			}
		}
	};

	/* 그리드 이벤트 처리 */
	/*onCurrentRowChanged은 dataRow의 위치가 변경된 후 호출되는 callback 이다.*/
	grid.getGridBase().onCurrentRowChanged = function(grid1, oldRow, newRow) {
		var provider = grid1.getDataProvider();
		//var columns = grid1.getColumnNames();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';

		// add버튼 클릭시 신규행에 필수입력값으로 들어가야할 row 위치에 backgroud 변환.
		grid1.addCellStyle("addStyle",{background:"#ffffffaa"}, true);
		// 신규행이 아니면 Label ID 컬럼 편집 불가
		if(!editable) {
			grid1.setColumnProperty('labelId','editable',false);
			grid1.setColumnProperty('languageCode','editable',false);
		} else {
			grid1.setColumnProperty('labelId','editable',true);
			grid1.setColumnProperty('languageCode','editable',true);

			// add버튼 클릭시 신규행에 필수입력값으로 들어가야할 row 위치에 backgroud 변환.
			grid1.setCellStyles(newRow,'labelTypeCode',"addStyle");
			grid1.setCellStyles(newRow,'languageCode',"addStyle");
			grid1.setCellStyles(newRow,'labelId',"addStyle");
			grid1.setCellStyles(newRow,'labelName',"addStyle");
		}
	};
	/*onCellEdited은 수정이나 추가 중인 편집 아이템의 한 필드값이 편집 완료되었을때 호출된다.*/
	grid.getGridBase().onCellEdited = function(grid1, itemIndex, dataRow, colIndex) {
		if(colIndex == 0) {
		}
	}

    myForm.select("#labelId").autocomplete({
        source: function (request, response) {
            transaction('lgcom', 'lgsetc/LGSETC00070/retrieveLabelIdList', {labelId: $.trim($('#labelId').val())}, function (data) {
                var result = data["result"];
                var arr = new Array();

                if (result.length) {
                    $.each(result, function (inx, obj) {
                        arr.push(obj.labelId);
                    });

                    return response(arr);
                } else {
                    return response([{label: 'No results found.', val: -1}]);
                }
            });
        },
        minLength: 1,
        //자동완성이 선택되었을 때, 이벤트 콜백 함수
        //event(Event)
        //ui(Object)=>item(object)는 label과 value 속성으로 구성됨.
        select: function (event, ui) {
            if (ui.item.val == -1) {
                return false;
            }
        },
        open: function () {
            $(this).autocomplete('widget').css('z-index', 600);
            return false;
        }
    }).focus(function(){
        $(this).autocomplete("search");
    });

	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});

	grid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
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
				stateBar: {visible:true},
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

		//룩업코드 설정 //
	    var code = new CommonCode("lgcom");
	    code.add(  "labelType" , { codeTypeCode : "LGCOM_LABEL_TYPE_CODE" } );
	    code.add(  "language" , { codeTypeCode : "LGCOM_LANGUAGE_CODE" } );
	    code.execute();

	    var lookup1 = code.get('labelType');
	    var lookup2 = code.get('language');
		grid.setLookups({
			'labelType':code.get('labelType'),
			'language':code.get('language')
		});

	 	//마우스 오른쪽 클릭시 메뉴
		grid.setContextMenu();

		// Validation Set
		grid.setValidations([
			{criteria: "value['labelTypeCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='LabelTypeCode'/>"/>',mode:'always',level:'error'},
			{criteria: "value['languageCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='LanguageCode'/>"/>',mode:'always',level:'error'},
			{criteria: "value['labelId'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='LabelId'/>"/>',mode:'always',level:'error'},
			{criteria: "value['labelName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='LabelName'/>"/>',mode:'always',level:'error'}
		]);

		//컬럼 설정
		grid.setFields(
				[
					{ fieldName: 'labelTypeCode'            , dataType:'text'},
					{ fieldName: 'languageCode'             , dataType:'text'},
					{ fieldName: 'labelId'            	    , dataType:'text'},
					{ fieldName: 'labelName'             	, dataType:'text'},
					{ fieldName: 'useColumnName'       		, dataType:'text'}
				]
		);

		grid.setColumns(

			[
				{
					name:'labelTypeCode',
					fieldName:'labelTypeCode',
					width:80,
					header: {text:'<lgcom:message code="LabelType" />', required: true},
					styles: {textAlignment:'center'},
					lookupDisplay: true,
					lookupSourceId: 'labelType',
					lookupKeyFields: ['labelTypeCode'],
					editor: {type:'dropDown', textReadOnly : true}
				},
				{
					name:'languageCode',
					fieldName:'languageCode',
					width:80,
					type: 'data',
					header: {text:'<lgcom:message code="Language" />', required: true},
					styles: {textAlignment:'center'},
					lookupDisplay: true,
					lookupSourceId: "language",
					lookupKeyFields: ['languageCode'],
					editor: {type:'dropDown', textReadOnly : true}
				},
				{
					name:'labelId',
					fieldName:'labelId',
					width:200,
					header: {text:'<lgcom:message code="LabelId" />', required: true},
					styles: {textAlignment:'center'}
				},
				{
					name:'labelName',
					fieldName:'labelName',
					width:400,
					header: {text:'<lgcom:message code="LabelName" />', required: true},
					styles: {textAlignment:'center'}
				},
				{
					name:'useColumnName',
					fieldName:'useColumnName',
					width:300,
					header: {text:'<lgcom:message code="DBColumnName" />'},
					styles: {textAlignment:'near'}
				}
			]
		);
		return grid;
	}
};

LGSETC00070.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGSETC00070();
		form.init();
	});
});
</script>
</head>
<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Label</h2>
	</div>

	<div class="searchBlock">
		<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="50" />
						<col width="100" />
						<col width="50" />
						<col width="100" />
						<col width="100" />
						<col width="180" />
						<col width="100" />
						<col width="*" />
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label for="labelType"><lgcom:message code="LabelType" /></label></th>
							<td>
								<select id="labelType" name="labelTypeCode" class="form-control input-sm size_90">
									<option value="">All</option>
								</select>
							</td>
							<th scope="col"><label for="languageCd"><lgcom:message code="Language" /></label></th>
							<td>
								<select id="languageCd" name="languageCode" class="form-control input-sm size_80">
									<option value="">All</option>
								</select>
							</td>
							<th scope="col"><label for="labelId"><lgcom:message code="LabelId" /></label></th>
							<td><input id="labelId" name="labelId" type="text" class="form-control input-sm" placeholder="Enter 1 or more characters." /></td>
							<th scope="col"><label for="labelName"><lgcom:message code="LabelName" /></label></th>
							<td><input id="labelName" name="labelName" type="text" class="form-control input-sm"/></td>
						</tr>
					</tbody>
				</table>
				<button type="button" class="btn btn-lgd btn-sm btn-search"" data-action="search"><lgcom:message code="Search" /></button>
		</form>
	</div>

	<div class="gridControls module-group text-right" >
	  	<div class="btn-toolbar">
			<div class="btn-group">
				<button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span><lgcom:message code="Add" /></button>
				<button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="delete"><span class="fa fa-remove" aria-hidden="true"></span><lgcom:message code="Delete" /></button>
			</div>
        	<div class="btn-group">
		    	<button class="btn btn-gray btn-sm" type="submit" data-action="save" ><lgcom:message code="Save" /></button>
			</div>
		</div>
	</div>

	<div class="gridContent grid-wrap" >
	    <div class="grid labelGrid"></div>
	</div>

	<div class="controls" >
    </div>
    </section>
</div>
</body>
</html>