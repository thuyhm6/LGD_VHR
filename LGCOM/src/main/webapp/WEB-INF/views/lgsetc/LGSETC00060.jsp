<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSETC00060.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 메세지 정보를 관리하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Message</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">

var LGSETC00060 = function(){
    var grid;
    var myForm = this;

	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	// 조회조건 Combo 초기화
	var code = new CommonCode("lgcom");
	var combo1 = code.execute('retrieveCommonCodeList',{codeTypeCode:'LGCOM_MESSAGE_TYPE_CODE'});
	formUtil.initCombo('messageType',combo1,{selectAll:true});

	var combo2 = code.execute('retrieveCommonCodeList',{codeTypeCode:'LGCOM_LANGUAGE_CODE'});
	formUtil.initCombo('languageCode',combo2,{selectAll:true});

    /* Layout Setting */
	myForm.setLayout( [
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock", bottom : "gridContent"},
		{ name : "gridContent",  left : 0, right : 0, top : "gridControls", bottom : 0 }
    ]);


	// 그리드 선언
    grid = buildGrid("LGSETC00060_grid");


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
				grid.loadData('lgcom', 'lgsetc/LGSETC00060/retrieveMsgList', param );
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
				cgrid.setCurrent({column:'messageTypeCode'});
				cgrid.setFocus();
				break;
			case 'delete':
				cgrid.deleteSelection(true);
				//grid.getDataProvider().removeRows(grid.getGridBase().getCheckedRows(true,false),false);
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
					grid.saveChanges('lgcom', 'lgsetc/LGSETC00060/saveMsgList',function(data) {
						Message.notify('<lgcom:message code="note.completed" />');
						// 저장 완료후 목록 재조회
						myForm.select("button[data-action='search']").trigger('click');
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

			if(oldIndex.column == "systemMessageId"){

				var systemMessageId = cgrid.getValue(cgrid.getCurrent().itemIndex,"systemMessageId");
				var languageCode = cgrid.getValue(cgrid.getCurrent().itemIndex,"languageCode");
				var param = {systemMessageId : systemMessageId, languageCode : languageCode};

				transaction_sync( 'lgcom','lgsetc/LGSETC00060/retrieveMessageIdChk', param, function(data){
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
		grid1.addCellStyle("required",{background: "#ffffffaa"}, true);
		// 신규행이 아니면 Program ID 컬럼 편집 불가
		if(!editable) {
			grid1.setColumnProperty('systemMessageId','editable',false);
			grid1.setColumnProperty('languageCode','editable',false);
		} else {
			grid1.setColumnProperty('systemMessageId','editable',true);
			grid1.setColumnProperty('languageCode','editable',true);

			// add버튼 클릭시 신규행에 필수입력값으로 들어가야할 row 위치에 backgroud 변환.
			grid1.setCellStyles(newRow,'messageTypeCode',"required");
			grid1.setCellStyles(newRow,'languageCode',"required");
			grid1.setCellStyles(newRow,'systemMessageId',"required");
			grid1.setCellStyles(newRow,'messageDesc',"required");
			grid1.setCellStyles(newRow,'messageDetailContent',"required");
		}
	};

    myForm.select("#messageId").autocomplete({
        source: function (request, response) {
            transaction('lgcom', 'lgsetc/LGSETC00060/retrieveMsgIdList', {messageId: $.trim($('#messageId').val())}, function (data) {
                var result = data["result"];
                var arr = new Array();

                if (result.length) {
                    $.each(result, function (inx, obj) {
                        arr.push(obj.messageId);
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
	function buildGrid(gridId) {
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
	    code.add(  "messageType" , { codeTypeCode : "LGCOM_MESSAGE_TYPE_CODE" } );
	    code.add(  "language" , { codeTypeCode : "LGCOM_LANGUAGE_CODE" } );
	    code.execute();

		grid.setLookups({
			'messageType':code.get('messageType'),
			'language':code.get('language')
			});

	 	//마우스 오른쪽 클릭시 메뉴
		grid.setContextMenu();

		// Validation Set
		grid.setValidations([
			{criteria: "value['messageTypeCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='MessageTypeCode'/>"/>',mode:'always',level:'error'},
			{criteria: "value['languageCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='LanguageCode'/>"/>',mode:'always',level:'error'},
			{criteria: "value['systemMessageId'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='SystemMessageId'/>"/>',mode:'always',level:'error'},
			{criteria: "value['messageDesc'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='MessageName'/>"/>',mode:'always',level:'error'},
			{criteria: "value['messageDetailContent'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='MessageDetailContent'/>"/>',mode:'always',level:'error'}
		]);

		//컬럼 설정
		grid.setFields(
				[
					{ fieldName: 'messageTypeCode'            , dataType:'text'},
					{ fieldName: 'languageCode'               , dataType:'text'},
					{ fieldName: 'systemMessageId'            , dataType:'text'},
					{ fieldName: 'messageDesc'             	  , dataType:'text'},
					{ fieldName: 'messageDetailContent'       , dataType:'text'}
				]
		);

		grid.setColumns(
				[
					{
						name:'messageTypeCode',
						fieldName:'messageTypeCode',
						width:80,
						header: {text:'<lgcom:message code="MessageType" />', required: true},
						styles: {textAlignment:'center'},
						lookupDisplay: true,
						lookupSourceId: "messageType",
						lookupKeyFields: ['messageTypeCode'],
						editor: {type:'dropDown', textReadOnly : true}
					},
					{
						name:'languageCode',
						fieldName:'languageCode',
						width:90,
						type: 'data',
						header: {text:'<lgcom:message code="Language" />', required: true},
						styles: {textAlignment:'center'},
						lookupDisplay: true,
						lookupSourceId: "language",
						lookupKeyFields: ['languageCode'],
						editor: {type:'dropDown', textReadOnly : true}
					},
					{
						name:'systemMessageId',
						fieldName:'systemMessageId',
						width:200,
						header: {text:'<lgcom:message code="MessageId" />', required: true},
						styles: {textAlignment:'center'}
					},
					{
						name:'messageDesc',
						fieldName:'messageDesc',
						width:400,
						header: {text:'<lgcom:message code="MessageName" />', required: true},
						styles: {textAlignment:'center'}
					},
					{
						name:'messageDetailContent',
						fieldName:'messageDetailContent',
						width:600,
						editor:{type:'multiline',c:'upper'},
						header: {text:'<lgcom:message code="MessageDetail" />', required: true},
						styles: {textAlignment:'near',textWrap:'explicit'}
					}
				]
		);

		return grid;
	}
};

LGSETC00060.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGSETC00060();
		form.init();
	});
});

</script>
</head>
<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Message</h2>
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
							<th scope="col"><label for="messageType"><lgcom:message code="MessageType" /></label></th>
							<td>
								<select id="messageType" name="messageType" class="form-control input-sm">
									<option value="">All</option>
								</select>
							</td>
							<th scope="col"><label for="languageCd"><lgcom:message code="Language" /></label></th>
							<td>
								<select id="languageCd" name="languageCode" class="form-control input-sm ">
									<option value="">All</option>
								</select>
							</td>
							<th scope="col"><label for="messageId"><lgcom:message code="MessageId" /></label></th>
							<td><input id="messageId" name="messageId" type="text" class="form-control input-sm" placeholder="Enter 1 or more characters." /></td>
							<th scope="col"><label for="messageName"><lgcom:message code="MessageName" /></label></th>
							<td><input id="messageName" name="messageName" type="text" class="form-control input-sm "/></td>
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
		<div id="LGSETC00060_grid" class="grid"></div>
	</div>

	<div class="controls" >
	</div>
	</section>
</div>
</body>
</html>