<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%---------------------------------------------------------
    파일명 : fileManager.jsp
    프로젝트명 : LGD WCFW 프로젝트

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : File Manager
    작성자 : WCFW
-------------------------------------------------------------%>
<style>
._fileName {
    cursor : pointer;
}
</style>
<div id="_file_manager_" class="modal fileManagerPopup" role="dialog" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header dark">
                <button type="button" class="btn btn-ico close" data-dismiss="modal" aria-label="Close">
                    <span class="ico ico-popup-close" aria-hidden="true"></span>
                </button>
                <h1 class="modal-title">File Manager</h1>
            </div>
            <!-- /modal-header -->
            <div class="modal-body" >
                <form action="" class="search-wrap well text-right">
                    <span class="_button_upload_text_ pull-left"></span>
                    <input class="fileList" type="file"  name='files[]' multiple style="display:none"/>
                    <input class="_fileupload_" type="file"  style="display:none" />          
                    <button class="btn btn-darkgray btn-sm _button_upload_" type="button"><lgcom:message code="FileSelect"/></button>
                    <button type="button" class="btn btn-default btn-sm ico-lgd"  data-action="upload" disabled ><lgcom:message code="Upload" /></button>
                    <!-- /partFoldingBtn -->
                </form>
                <!-- /search-wrap -->
                <table class="table table-bordered table-condensed _editable  _fileList">
                    <colgroup>
                        <col width="5%">
                        <col width="40%">
                        <col width="*">
                        <col width="15%">
                    </colgroup>
                    <thead>
                        <tr>
                            <th></th>
                            <th><lgcom:message code="AttachFileName"/></th>
                            <th><lgcom:message code="FileDesc"/></th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
                
                <table class="table table-bordered table-condensed _readonly _fileList">
                    <colgroup>
                        <col width="45%">
                        <col width="*">
                        <col width="15%">
                    </colgroup>
                    <thead>
                        <tr>
                            <th><lgcom:message code="AttachFileName"/></th>
                            <th><lgcom:message code="FileDesc"/></th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>      
            </div>
            <!-- /modal-body -->
            <div class="modal-footer">
                <span class="_fileupload_server_message_ pull-left"></span>
                <button type="button" class="btn btn-darkgray btn-sm" data-action="saveAttachFileDescription" >저장</button>
                <button type="button" class="btn btn-gray btn-sm" data-dismiss="modal">닫기</button>
            </div>
            <!-- /modal-footer -->
        </div>
        <!-- /modal-content -->
    </div>
    <!-- /modal-dialog -->
</div>
<!-- /modal -->

<script id="_fileNamager_row_template" type="text/template">
<tr>
    <td class="text-center align-middle">
        <div class="checkbox checkbox-uxp checkbox-inline">
            <input type="checkbox" id="inlineCheckbox2" value="option1">
            <label for="inlineCheckbox2"></label>
        </div>
    </td>
    <td class="align-middle"><span class=" _fileName" data-action="download"></span><span class="fileIndex" style="display:none;"></span></td>
    <td><input type="text" class="form-control input-sm _description"/></td>
    <td class="text-center align-middle">
        <button class="btn btn-sm btn-link" aria-label="삭제" data-action="delete" >
            <span class="ico ico-trace" aria-hidden="true"></span>
        </button>
        <button class="btn btn-sm btn-link" aria-label="다운로드" data-action="download" >
            <span class="ico ico-attach-down" aria-hidden="true"></span>
        </button>
    </td>
</tr>
</script>

<script id="_fileNamager_row_template_readonly" type="text/template">
<tr>
    <td class="align-middle"><span class=" _fileName"></span><span class="fileIndex" style="display:none;"></span></td>
    <td class="_description"></td>
    <td class="text-center align-middle">
        <button class="btn btn-sm btn-link" aria-label="다운로드" data-action="download" >
            <span class="ico ico-attach-down" aria-hidden="true"></span>
        </button>
    </td>
</tr>
</script>

<script>
/**
 * File Manager 의 사용방법 예제
 * var fileManager = new FileManager( options );
 *
 * 여기에 options의 스펙은 아래와 같다.
 *
 * var fileManager = new FileManager({
 *     fileGroupId : attachmentId,
 *     moduleCode : "LGCOM",
 *     editable : true,
 *     attribute : [ "A","B" ],
 *     success : function( fileGroupId ) {
 *         grid.setValue( index.itemIndex, index.fieldIndex, fileGroupId );
 *     },
 *     fileCount : 3,
 *     error : function(){
 *         alert("error");
 *     }
 * });
 * fileManager.open();
 */
var FileManager = function( options ) {
    var _containerId = "_file_manager_";
    var _container = $("#" + _containerId );

    if( options == undefined ) {
        options = { editable : true, moduleCode : "LGCOM" };
    } else {
        if( options.editable == undefined ) {
            options.editable = true;
        }
        
        if( options.inline == undefined ) {
            options.inline = false;
        }

        if( options.moduleCode == undefined ) {
            options.moduleCode = "LGCOM";
        }
    }

    var plate;

    /*
    if( options.inline ) {
        _container = options.container;
        _containerId = uuid();

        //[중요!!!]이 라인의  #_file_manager_ 은 그대로 두어야 한다!!
        $("#_file_manager_ ._inlineButtonHolder").append( $("#_file_manager_ ._fileButtons").detach() );    
        
        plate = $("#_file_manager_ .modal-body").clone(false).removeClass("modal-body");
        plate.addClass("fileManagerInline");
        plate.find(".grid-wrap").css({ "overflow" : "hidden" });
        //plate.addClass("fileManagerMainPlate");
        plate.attr("id", _containerId );

        $(_container).find("button.inline[data-action='saveAttachFileDescription']").show();
        $(_container).append( plate );
    } else {
        $(_container).find("button.inline[data-action='saveAttachFileDescription']").hide();
    }
*/
    var fileUploader;
    var url = "/lgcom/attachment/upload/"+ options.moduleCode +"?fileGroupId=";
    var template = "_fileNamager_row_template";

    options["fileGroupId"] = nvl( options["fileGroupId"] );
    options["uploadUrl"] = url + options["fileGroupId"];
    options["fileData"] = [];

    //테이블의 헤더를 정리해준다.
    if( !options.editable ) { //읽기 전용일 때
        template = "_fileNamager_row_template_readonly";
        $(_container).find("table colgroup:last-child").remove();
        $(_container).find("table thead th:last-child").attr("colspan", "2" );
        $(_container).find(".uploadComponent").hide();
    } else {
        $(_container).find("table thead th:last-child").attr("colspan", "3" );
    }

    this.setEditable = function( flag ){
        options.editable = flag;
        if( !options.editable ) { //읽기 전용일 때
            $(_container).find("table colgroup:last-child").remove();
            $(_container).find("table thead th:last-child").attr("colspan", "2" );
            $(_container).find(".uploadComponent").hide();
        } else {
            $(_container).find("table thead th:last-child").attr("colspan", "3" );
        }
    }

    //fileCount 관련정보가 들어오면 해야 할 일
    if( options.fileCount != undefined  ) {
        $(_container).find("._fileCount_message").show();
        $(_container).find("._fileCount").text( options.fileCount + " <lgcom:message code="note.fileManagerFileCount" />");
    } else {
        $(_container).find("._fileCount_message").hide();
    }

    addEvent();
    
    this.open = function(){
        init();
        loadData();
        $(_container).modal('show');
    }

    /* 이 팝업을 인라인으로 만들 때 사용하는 초기화 메소드 : 팝업 모드일 때는 사용하지 않는다. */
    this.inline = function( ){
    	var id = uuid();
    	var container = $("<div id='"+ id + "' ></div>");
    	options.container.append(container);
    	
    	//inline ui 구성
    	var table;
    	if( options.editable ) {
    		table = $("#_file_manager_ ._fileList._editable" ).clone(true);
    	} else {
    		table = $("#_file_manager_ ._fileList._readonly" ).clone(true);
    	}
    	container.append(table);
        init();
        
        if( options["fileGroupId"] != undefined ) {
            loadData();
        }
    }

    /* 이 팝업을 인라인으로 만들 때 자원을 초기화 하는 메소드 : 팝업 모드일 때는 사용하지 않는다. */
    this.destroy = function(){
        trace("[SYSTEM] FileManager inline mode destroyed .");
        $(_container).removeData();
        $(document).off( "." + _containerId  );
        $(_container).empty();
    }

    /*인라인 모드의 데이터 로드 메소드 */
    this.loadData = function( fileGroupId ){
        options["fileGroupId"] = fileGroupId;
        loadData();
    }

    function loadData(){
        $(_container).find("table tbody").empty();

        transaction( "lgcom", "lgsysc/LGSYSC00210/selectAttachmentListByFileGroupId", { fileGroupId : options["fileGroupId"], moduleCode :  options["moduleCode"] }, function(data){
            var list = data["result"];
            var body;
            if( options.editable ) {
                body = $(_container).find("._fileList._editable tbody");
                body.empty();

                $(list).each( function( inx ) {
                    var row = $( $("#" + template ).html() );
                    row.find("._fileName").text( this["fileName"] ).data("id", this["fileId"] );
                    row.find("._description").val( this["fileDesc"] ).data("id", this["fileId"] );
                    
                    row.find("[data-action='download']").data( "module", this["moduleCode"]  );
                    row.find("[data-action='delete'], [data-action='download']").data( "id", this["fileId"] );
                    row.data("fileInfo", this );
                    body.append(row);

                    // 서버에서 보내준 파일 정보를 담는다.
                    options["fileData"].push({
                        fileGroupId: nvl( this["fileGroupId"] ),
                        fileId: nvl( this["fileId"] ),
                        fileName: nvl( this["fileName"] ),
                        moduleCode: nvl( this["moduleCode"] ),
                        downloadUrl: nvl( this["downloadUrl"] ),
                    });
                });
                
                if( list == undefined || list.length == 0 ) {
                    body.append("<tr><td colspan='4' class='noFiles'>No files</td></tr>");
                }
                
            }  else {
                body = $(_container).find("._fileList._readonly tbody");
                body.empty();
                $(list).each( function( inx ){
                    var row = $( $("#" + template ).html() );
                    row.find("._fileName").text( this["fileName"] );
                    row.find("._description").text( this["fileDesc"] );
                    row.data("fileInfo", this );
                    body.append(row);
                });
                
                if( list == undefined || list.length == 0 ) {
                    body.append("<tr><td colspan='3' class='noFiles'>No files</td></tr>");
                }
            }


            if( options.fileCount != undefined ) {
                if( $(body).find(".fileIndex").length < options.fileCount  ) {
                    $(_container).find("._button_upload_, [data-action='upload']" ).removeAttr("disabled");
                } else {
                    $(_container).find("._button_upload_, [data-action='upload']" ).prop("disabled", true);
                }
            } else {
                $(_container).find("._button_upload_, [data-action='upload']" ).removeAttr("disabled");
            }
        });
    }

    function init() {
        var body;
        //읽기 전용 모드일 때 수정 작업용 컴포넌트를 모두 가린다.
        if( !options.editable ) {
            $(_container).find("._fileList._editable" ).hide();
            
            body = $(_container).find("._fileList._editable tbody");

            if( options.fileCount != undefined ) {
                $(_container).find("._fileCount_message").show();
            } else {
                $(_container).find("._fileCount_message").hide();
            }

            $(_container).find(".uploadComponent").show();
        } else {
            $(_container).find("._fileList._readonly" ).hide();
            body = $(_container).find("._fileList._readonly tbody");

            $(_container).find("._fileCount_message").hide();
            $(_container).find(".uploadComponent").hide();
        }

        $(_container).find(".loader").hide();
        $(_container).find("._progress .bar").css( 'width', "0%" );
        showManagerMessage ("");

        if( $(_container).data("fileupload") != undefined ) {
            $(_container).fileupload('destroy');
        }

        $(_container).find(".fileList, ._fileupload_").each( function(){
            $(this).replaceWith( $(this).clone(true) );
        });

        $(_container).find("._button_upload_text_").text( "" );

        // 2017.06.21. forain 추가, 버튼 초기화
        if(options.editable) {
            $(_container).find("button._button_upload_" ).prop('disabled',false);
            $(_container).find("button[data-action='upload']" ).prop('disabled',true);
        }

        var option =  {
            url : options["uploadUrl"],
            dataType: 'json',
            done: onUploadFinished,
            progressall: function (e, data) {
                var progress = parseInt(data.loaded / data.total * 100, 10);
                $(_container).find("._progress .bar").css( 'width', progress + '%' );
            },
            fail : function (e, data) {
                trace( "upload fail ");
                trace( data );
                if(options.inline) {
                    document.location.href = "#";
                }
            }
        };

        var uploader = $(_container).find("._fileupload_").fileupload( option );

        uploader.error(function(jqXHR, textStatus, errorThrown) {
            trace( jqXHR );
        });

        $(_container).find("._fileupload_").data("fileupload", uploader );
    }

    function onUploadFinished(e, data) {
        if(options.inline) {
            document.location.href = "#";
        }

        var serverMessage = data.jqXHR.responseJSON._server_message_;

        //파라미터로 이 값이 전달 됐다면 -> 서버에서오는 값이 동일하다.
        //파라미터로 이 값이 전달 되지 않았다면 -> 서버에서 신규 생성해서 값을 보내준다.
        if( serverMessage.type == "SYSTEM_ERROR" ) {
            var errorMessage = "";
            if( data.files ) {
                $.each(data.files, function (index, file) {
                    errorMessage = serverMessage.text + "<br><strong> "+ file.name +" </strong> size : " + file.size + " bytes.";
                });
                Message.alert( errorMessage );
            } else {
                Message.alert( serverMessage.text );
            }
        } else {
            //서버에서 보내준 fileGroupId 를 다시 담는다.
            options["fileGroupId"] = nvl( data.jqXHR.responseJSON.fileGroupId );
            options["uploadUrl"] = url + options["fileGroupId"];
            showManagerMessage ("Successfully Uploaded.");
            loadData();
        }

        try {
            options.success.call( this, options["fileGroupId"] );
        } catch(e) {}

        $(_container).find(".loader").hide();
        init();
    }

    function saveFileDesc() {
        var data = [];
        $(_container).find("._fileList._editable ._description").each( function(){
            data.push( { fileId : $(this).data("id"), fileDesc : $(this).val() } );
        });

        transaction( "lgcom", "lgsysc/LGSYSC00210/updateAttachFileInfo", { data : data }, function(){
        	 showManagerMessage ("<lgcom:message code="note.saved" />" );
        });
    }

    FileManager.init = function() {
        init();
    }

    //이 함수는 fileGroupId 를 아는 상황에서 어디서나 해당 fileGroupId 로 저장된 첨부파일을 모두 삭제하는 기능을 가지고 있다.
    //이 함수는 fileManager.jsp 안에서는 사용되지 않는다.
    FileManager.deletAttachment = function( fileGroupId, callback ){
        transaction( "lgcom", "lgsysc/LGSYSC00210/deleteAttachFilesByFileGroupId", param, function(data){
            try {
                callback.call( this, fileGroupId );
            } catch( e ) {}

            var body = $(_container).find("._fileList._editable tbody");

            if( options.fileCount != undefined ) {
                if( $(body).find(".fileIndex").length < options.fileCount  ) {
                    $(_container).find("._button_upload_, [data-action='upload']" ).removeAttr("disabled");
                } else {
                    $(_container).find("._button_upload_, [data-action='upload']" ).prop("disabled", true);
                }
            } else {
                $(_container).find("._button_upload_, [data-action='upload']" ).removeAttr("disabled");
            }
        });
    }

    function downloadFile( id, moduleCode ) {
    	 showManagerMessage ( "<lgcom:message code="note.fileDownloadloading" />" );
        
        var downloader = new Downloader( {} , { } );
        downloader.attachment( id , function() {
        	showManagerMessage ( "<lgcom:message code="note.fileDownloadCompleted" />" );
        }, function() {
        	showManagerMessage ( "<lgcom:message code="note.fileDownloadFailed" />" );
        }, moduleCode );
    }

    // inline 모드일때는 _containerId 가 들어온다. 
    function addEvent() {

    }
    
    FileManager.showManagerMessage = function( message ) {
    	showManagerMessage(message);
    }
    
    function showManagerMessage( message ) {
        $(_container).find("._fileupload_server_message_").text( message );
        var timeout = setTimeout( function(){
            $(_container).find("._fileupload_server_message_").text( "" );
            clearTimeout( timeout )
        }, 5000 );
    }
}
 
 // FileManager 버튼들의 통합 이벤트 ( 객체가 전체 문서에 대해 단 한개 존재하므로, 여기에 이벤트 핸들러를 적는다.)
$("#_file_manager_ ._button_upload_").click( function(){
    if(options.inline) {
        document.location.href = "#_file_manager_";
    }

    $(_container).find(".fileList").click();

    setTimeout( function(){
        if(options.inline) {
            document.location.href = "#";
        }	
    }, 1000 );
});

$("#_file_manager_  .fileList").change( function(){
    $(_container).find("._button_upload_text_").text(  $(this).val()  );
    FileManager.showManagerMessage( "" );

    if( $(this).val() == "" ) {
        $(_container).find(".uploadComponent button[data-action='upload']").prop("disabled", true);
    } else {
        $(_container).find(".uploadComponent button[data-action='upload']").prop("disabled", false);
    }
});


//버튼들의 통합 이벤트 핸들러
$("#_file_manager_ ._fileList").on( "click", "[data-action]", function(event){
	trace("테이블의 버튼들 ");
});

$("#_file_manager_ [data-action]").click( function( event ){
	trace("버튼 클릭!!");
	/*
    var fileInfo = $(event.target).closest("tr").data("fileInfo");
    trace("fileInfo : " + fileInfo);
    trace(fileInfo);
    
    var action = $(this).data("action");
    switch( action ) {
        case "upload" :
            $(_container).find(".uploadComponent button[data-action='upload']").prop("disabled", true);
            $(_container).find(".loader").show();
            FileManager.showManagerMessage("");
            var filesList = $(_container).find(".fileList").prop('files');
            $(_container).find("._fileupload_").fileupload('send', {files: filesList});
            break;
        case "saveAttachFileDescription" :
            var data = [];
            $(_container).find("._fileList._editable ._description").each( function(){
                data.push( { fileId : $(this).data("id"), fileDesc : $(this).val() } );
            });

            transaction( "lgcom", "lgsysc/LGSYSC00210/updateAttachFileInfo", { data : data }, function(){
            	 showManagerMessage ("<lgcom:message code="note.saved" />" );
            });     	
        	
            break;
        case "close" :
            init();
            $(_container).modal('hide');
            try {
                if( $(_container).find("tbody .fileIndex").length > 0 ) {
                    options.success.call( this, options["fileGroupId"], options["fileData"] );
                } else {
                    options.success.call( this, null, null );
                }
            } catch( e ) {}
            break;
        case "download" :
            var fileInfo =  $(event.target).closest("tr").data("fileInfo");
            downloadFile( fileInfo["fileId"] , fileInfo["moduleCode"] );
            break;
    }
    
    */
});
 

$('#_file_manager_').on('hidden.bs.modal', function (e) {
    FileManager.init();
    $('#_file_manager_').removeData();
    $(document).off( "._file_manager_");
    document.location.href = "#";
});

$('#_file_manager_').on('shown.bs.modal', function (e) {
    FileManager.init();
    document.location.href = "#_file_manager_";
});

$("#_file_manager_ ._button_upload_").click( function(){
    $("#_file_manager_ .fileList").click();
});

$("#_file_manager_ .fileList").change( function(){
    $("#_file_manager_ ._button_upload_text_").text(  $(this).val()  );
    FileManager.showManagerMessage("");

    if( $(this).val() == "" ) {
        $("#_file_manager_ .uploadComponent button[data-action='upload']").prop("disabled", true);
    } else {
        $("#_file_manager_ .uploadComponent button[data-action='upload']").removeAttr("disabled");
    }
});
</script>
