<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"     uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn"    uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00300.jsp
    프로젝트명 : LGD WCFW 프로젝트

    Copyright(c) 2016 LG CNS,  All rights reserved.

    설 명 : 본 화면은 결재승인 목록 조회화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<c:set var="g_program_id" value="${param.bizFormId}"/>

<html lang="ko">
<head>
<title>My Approval List</title>

<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>

<script type="text/javascript">

var <c:out value="${g_program_id}"/> = function(){
    var grid;
    var _this = this;
    var strForm = ".searchBlock form";
    var formUtil = new FormUtil(_this,strForm);    

    ////////////////////////////
    // 1. 화면 레이아웃 정의 
    ////////////////////////////
    /*
    _this.setManagedLayout({
        searchBlock :{ left:0, top:0, right:0 },
        gridControls:{ left:0, top:DOUBLE_LINE.top1, right:0, height:30 },
        gridContent :{ left:0, top:DOUBLE_LINE.top1, right:0, bottom:0 } 
    });
    */
    /* Layout Setting */
	_this.setLayout( [ 
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name : "gridContent",  left : 0, right : 0, top : "searchBlock", bottom : 0 }		
    ]);	

    ////////////////////////////
    // 2. 그리드선언
    ////////////////////////////
    grid = buildGrid("<c:out value="${g_program_id}"/>_grid");

    ////////////////////////////
    // 3. 개인화조건
    ////////////////////////////
    _this.searchConditionControl( true );
    
    ////////////////////////////
    // 4. Submit 방지
    ////////////////////////////
    _this.addEvent('submit',strForm,function(event) {
        event.preventDefault();
    });

    ////////////////////////////
    // 5. 팝업 데이터 정의 searchMode:single(단수),multi(복수) / popupKind:purchaser(구매담당자),그외(전체사용자) / confirmKind:reassign(구매담당자변경confirm창)
    ////////////////////////////
    _this.popupInfo = { 
        userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', userId:'', employeeNo:'', employeeName:'', userData:[]}, 
        returnPopup : {returnComment:''} 
    };

    ////////////////////////////
    // 6. 그리드형 테이블 TR (clone)
    ////////////////////////////
    
    ////////////////////////////
    // 7. 코드 데이터 조회
    ////////////////////////////     

    ////////////////////////////
    // 8. 날짜 팝업창 
    ////////////////////////////
    
    var $dateFrom = _this.select(".searchBlock input[name='dateFrom']"),
	    $dateTo   = _this.select(".searchBlock input[name='dateTo']"),
	    $button   = _this.select('.searchBlock ._datePicker');
    
    var dateTo   = DateUtil.today("YYYY-MM-DD");
    var dateFrom = moment(dateTo).add(-1,"months").format('YYYY-MM-DD');
    
    uxp.datepicker.fromTo( $button, $dateFrom, $dateTo  ); 
	formUtil.setValue({ dateFrom : dateFrom, dateTo: dateTo });
    
	//uxp.datepicker.fromTo(_this.selector("button[name=setDate]"), _this.selector("input[name=dateFrom]"), _this.selector("input[name=dateTo]")); 

    ////////////////////////////
    // 9. 필수항목 체크 : hidden값은 required체크안됨 
    ////////////////////////////
    var validator = new Validator( _this, strForm );
    validator.setRule({
        option: {placement: 'right'},
        rules: {
            dateFrom:            {required:true},
            dateTo:              {required:true}
            
        },
        messages: {
            dateFrom:            {required:'<lgcom:message code="error.requiredTooltip"/>'},
            dateTo:              {required:'<lgcom:message code="error.requiredTooltip"/>'}            
        }
    });
    
    ////////////////////////////
    // 10. 일반함수
    ////////////////////////////    
    
    ////////////////////////////
    // 11. Event 처리 
    ////////////////////////////
    _this.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
        var userPopup = _this.popupInfo.userPopup;
        var cgrid = grid.getGridBase();
        switch( action ){
            case "search" :
                cgrid.cancel();
                var param = _this.select(strForm).toJSON();
                
                if(validator.isValid()) {
                    grid.loadData('lgcom','lgutlc/LGUTLC00300/retrieveApprovalList', param );
                }
                break;            
            case "openPopupRequestor" :
                console.log("openPopupRequestor");
                var _popup = _this.popupInfo.userPopup;
                _popup.searchMode   = "single";
                _popup.popupKind    = "requestor";
                _popup.confirmKind  = "";
                _popup.employeeName = formUtil.getValue("requestorName");
                
                var popup = new Popup( _this,'lgcom', 'M_LGUTLC_1142', '<lgcom:message code="UserSearch"/>' );
                popup.setSize(800,494);
                popup.open( function(){
                    formUtil.setValue({requestorApplUserId  :_popup.userData[0].userId});
                    formUtil.setValue({requestorName        :_popup.userData[0].employeeName});
                }); 
                _popup.userData = [];
                break;
        }
    });
    
    _this.addEvent( "change", "input[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
        switch( action ){
            case "emptyAndPopup" :
                $(event.target).prev("input[type=hidden]").val(""); // 코드값 비우기
                if($(event.target).val() != ""){
                    $("body").one("focusout", function(e){
                        $(event.target).next("span").children("button").trigger('click');
                    });
                }
                break;
        }
    });
    
    ////////////////////////////
    // 12. 그리드 초기화
    ////////////////////////////
    function buildGrid(gridId, lookupList) {
        var grid = new RealGrid(_this, gridId);
        grid.setOptions({
            grid: {
                softDeleting   : true,
                deleteCreated  : true,
                hideDeletedRows: false,
                paste    : {enabled : false},
                indicator: {visible : false},
                panel    : {visible : false},
                checkBar : {visible : false},
                stateBar : {visible : false},
                footer   : {visible : false},
                edit: {
                    insertable: false,
                    appendable: false,
                    updatable : false,
                    deletable : false
                }
            },
            dataProvider: {
                insertable   : false,
                updatable    : false,
                deletable    : false,
                softDeleting : false,
                deleteCreated: false
            },
            
        });    
        grid.setContextMenu();
        grid.setFields(
            [                
                { fieldName:'orgId',                   dataType:'text'},                
                { fieldName:'ouShortName',             dataType:'text'},
                { fieldName:'submissionNo',            dataType:'text'},                
                { fieldName:'requestMasterId',         dataType:'text'},                
                { fieldName:'requestCode',             dataType:'text'},
                { fieldName:'systemCode',              dataType:'text'},               
                { fieldName:'moduleCode',              dataType:'text'},
                { fieldName:'title',                   dataType:'text'},                
                { fieldName:'requestDate',             dataType:'text'},
                { fieldName:'requestorEmpName',        dataType:'text'},
                { fieldName:'statusName',              dataType:'text'},
                { fieldName:'allPassDay',              dataType:'text'},
                { fieldName:'myPassDay',               dataType:'text'}

            ]    
        );
        grid.setColumns(
            [                
                { name:'submissionNo',            fieldName:'submissionNo',            width:140, header: {text:'<lgcom:message code="submissionNo"/>'},            styles: {textAlignment:'near'}, editable: false},
                { name:'orgId',                   fieldName:'orgId',                   visible:false},
                { name:'requestMasterId',         fieldName:'requestMasterId',         visible:false},
                { name:'requestCode',             fieldName:'requestCode',             visible:false},               
                { name:'systemCode',              fieldName:'systemCode',              width:100, header: {text:'<lgcom:message code="SystemCode"/>'},                   styles: {textAlignment:'near'}, editable: false},                
                { name:'moduleCode',              fieldName:'moduleCode',              width:135, header: {text:'<lgcom:message code="ModuleCode"/>'},                   styles: {textAlignment:'near'}, editable: false},
                { name:'title',                   fieldName:'title',                   width:340, header: {text:'<lgcom:message code="Title"/>'},                    styles: {textAlignment:'near', fontUnderline: true, foreground:'#37a0ac'}, cursor:'pointer', editable: false},
                { name:'requestDate',             fieldName:'requestDate',             width:110, header: {text:'<lgcom:message code="requestDate"/>'},             styles: {textAlignment:'center'}, editable: false},                
                { name:'requestorEmpName',        fieldName:'requestorEmpName',        width:200, header: {text:'<lgcom:message code="Requestor"/>'},                styles: {textAlignment:'center'}, editable: false},
                { name:'statusName',              fieldName:'statusName',              width:120, header: {text:'<lgcom:message code="Status"/>'},                  styles: {textAlignment:'center'}, editable: false},
                { name:'allPassDay',              fieldName:'allPassDay',              width:90,  header: {text:'<lgcom:message code="allPassDay"/>'},            styles: {textAlignment:'far'}, editable: false},
                { name:'myPassDay',               fieldName:'myPassDay',               width:90,  header: {text:'<lgcom:message code="myPassDay"/>'},             styles: {textAlignment:'far'}, editable: false}
            ]    
        );
        return grid;
    }
    
    ////////////////////////////
    // 13-2. 그리드 Event 처리
    ////////////////////////////
    var gridMain = grid.getGridBase();
    gridMain.onDataCellClicked = function (gridbase, index) {      
    	// 12-1. Title 클릭 시 상세화면으로 이동.
        if ( index.column == 'title' ) {
            var requestMasterId = gridbase.getValue( index.itemIndex, "requestMasterId" );
            var requestCode = gridbase.getValue( index.itemIndex, "requestCode" );
         
             var popup = new Popup( _this, "lgcom", "approval?jobKeyId="+ requestMasterId +"&jobRequestCode=" + requestCode , "Approval" );
             popup.setSize( 1200, 700 );
             popup.openWindow( function(){}, function(){} );
        }
    }
};

<c:out value="${g_program_id}"/>.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
    var form = new <c:out value="${g_program_id}"/>();
    form.init();
});
</script>
</head>
<body>
<div class="mdi-container">
   <section class="page-content">
    <div class="pageHeader">
        <h2>My Approval List</h2>
    </div>
    
    <div class="searchBlock">
        <form class="form search-wrap ">
            <table class="table">
                <colgroup>
                    <col width="100">
                    <col width="210">
                    <col width="80">
                    <col width="120"> 
                    <col width="80">
                    <col width="100">
                    <col width="80">
                    <col width="*">                    
                </colgroup>
                <tbody>
                    <tr>
                        <th scope="row"><label class="required" for="<c:out value="${g_program_id}"/>_requestDate" ><i class="asterisk">*</i><lgcom:message code="requestDate" /></label></th>                        
                        <td>
                            <div class="form-inline ">
                                <input type="text" class="form-control input-sm input-require" name="dateFrom" placeholder="yyyy-mm-dd" style="width: 85px;" data-date>
                                ~
                                <input type="text" class="form-control input-sm input-require" name="dateTo" placeholder="yyyy-mm-dd" style="width: 85px;" data-date>
                                <button type="button" name="setDate" class="btn btn-ico _datePicker" aria-label="calendar" >
                                    <span class="ico ico-calendar" aria-hidden="true"></span>
                                </button>
                            </div>
                        </td>
                                                
                        <th scope="row"><label for="<c:out value="${g_program_id}"/>_requestorName" ><lgcom:message code="Requestor"/></label></th>
                        <td>
                            <div class="input-group input-group-sm input-search">
                                <input name="requestorApplUserId" type="hidden" />
                                <input class="form-control input-sm _find_origin_" name="requestorName" type="text" id="<c:out value="${g_program_id}"/>_requestorName" data-action="emptyAndPopup">
                                <span class="input-group-btn">
                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupRequestor">
                                        <span class="fa fa-search" aria-hidden="true"></span>
                                    </button>
                                </span>
                            </div>
                        </td>  
                                                                      
                        <th scope="row"><label for="<c:out value="${g_program_id}"/>_title" ><lgcom:message code="Title" /></label></th>
                        <td><input name="title" type="text" class="form-control input-sm" id="<c:out value="${g_program_id}"/>_title" /></td>
                                                
                        <th scope="row"><label for="<c:out value="${g_program_id}"/>_status" ><lgcom:message code="Status"/></label></th>
                        <td>
                            <select name="status" class="form-control input-sm" id="<c:out value="${g_program_id}"/>_status" >
                                <option value="P">Pre Approval</option>
                                <option value="C">Completed</option>
                            </select>
                        </td>    
                    </tr>
                </tbody>
            </table>
            <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
        </form>
    </div>

    <div class="gridContent grid-wrap" >
        <div id="<c:out value="${g_program_id}"/>_grid" class="grid" ></div>
    </div>
    </section>
</div>
</body>
</html>