var SystemDateSupport = function() {
	var timer = setInterval(refreshTime, 1000);
	var _this = this;
	var current;

	function refreshTime() {
		current = moment( current ).add(1, 'seconds');
		var gmtText = Number( SESSION_USER.serverTimeDifferenceSeqs );
		if( gmtText > 0 ) {
			gmtText = "+" + Math.abs( gmtText );
		} else {
			gmtText = "-" + Math.abs( gmtText );
		}
		$("main ._globalStatusBar ._currentTime").text( moment( current ).format("YYYY-MM-DD HH:mm:ss") + " (GMT "+ gmtText +")" );
	}

	this.setServerTime = function( serverTimeText ) {
		current = moment( serverTimeText, "YYYYMMDD HH:mm:ss");
	}

	this.getTime = function() {
		return current;
	}

	SystemDateSupport.getTime = function() {
		return current;
	}

	SystemDateSupport.setServerTime = function(serverTimeText) {
		this.setServerTime( serverTimeText ) ;
	}

	$("aside ._menu ._currentTime").click( function(){
		trace(  moment( _this.getTime() ).format("YYYY-MM-DD HH:mm:ss") );
	});
}

/* User Menu 등과 같은 Main 화면에서 호출하는 side App 들을 관리하기 위한 클래스 
 * open 의 파라미터 menuItem 은 다음과 같은 형식이어야 한다.
 * 
 * 	menuItem = { systemCode : "lgcom", name : "User Menu",  programId : "LGSYSC00050", menuId : "userMenu"  };
 * */
var SideApp = function(){
	var plate = $( "._upperSideAppPlate" );
	var currentMenuItem;
	
	// { systemCode : CONTEXT_PATH, name : "User Menu",  programId : "LGSYSC00050", menuId : "userMenu"  };
	this.open = function( menuItem , options ) {
		$( "._shortCutMenu" ).removeClass("_show");
		
		if( options == undefined ) {
			options = { width : 750, height : 660 };
		}
		
		plate.find(".modal-content, .modal-dialog").css( { width : options.width + "px",  height : options.height + "px"} );
		
		currentMenuItem = menuItem;
		menuItem["id"] = uuid();
		plate.find("._contentWrapper").attr("data-id", menuItem["id"] );
		plate.find("._content").attr("data-id", menuItem["id"] );
		plate.find("._content").attr("id", menuItem["id"]);
		plate.find(".modal-title").text( menuItem["name"]);
		LayoutManager.getMenuItems().put( menuItem["id"], menuItem );
		plate.modal("show");
	}	
	
	var closeCallback;
	this.onClose = function( callback ) {
		closeCallback = callback;
	}
	
	plate.on("shown.bs.modal", function(){
		var pageUrl = SERVER_URL + "/" + currentMenuItem.systemCode.toLowerCase() + "/service/" + currentMenuItem.menuId;
		plate.find("._content").load( pageUrl, { bizFormId  : currentMenuItem["id"]  } );
	});
	
	plate.on("hidden.bs.modal", function(){
		LayoutManager.removeForm(currentMenuItem["id"]);
		plate.find("._content").off("." + currentMenuItem["id"]);
		plate.find("._content").empty();
		LayoutManager.getMenuItems().remove(currentMenuItem["id"]);	
		
		try {
			closeCallback.call( this );
		}catch(e){}
	});
}

var InstantMessaging = function( quiteMode ) {
	
	// quiteMode == true : 기본 메세징을 사용하지 않고, 수동으로 데이터를 인출해 정리하는 방식으로 운용 
	// quiteMode == false : Web 소켓 사용하는 기본 방식 
	if( quiteMode == undefined ) {
		quiteMode = false;
	}
	
	//초기화 수행 내역
	$("._globalStatusBar").addClass( "_messagingOn" );

	var messageArea = $("._globalStatusBar ._instantMessage");
	var socket = null;
	var messageCount = 0;
	var messageButtonInitText = "Connected";
	
	if( !quiteMode ){
		connect();
	} else {
		messageArea.find("._status").addClass("_online");
		$("._globalStatusBar ._messageText").text( messageButtonInitText );
	}
	
	// quiteMode == true 일 때, refresh 호출하면, 서버로 가서 데이터를 가져오는 작업을 수행한다. 
	this.refresh = function(){
		if( !quiteMode ) return;
		
		getCachedNotificationList();
	}
	
	getUnreadNotificationList();
	/*
	var timer = setInterval( function(){
		sendMessage({text : "[CLIENT] Ping" });
	}, 1000 * 10 );
	*/
	/* 일반함수 */
	
	/* 업무 화면이 열리는 상황에서 이미 추가된 메세지 말고 신규 메세지가 추가 된 것을 가져와 목록에 반영한다 . 알림 있음 */
    function getCachedNotificationList() {
		transaction( "lgcom", "common/concurrent/retrieveCachedRequestList", {} , function( data ) {
			var list = data["result"];
			$(list).each( function(){
				addMessageOnMessageContainer( this.programName +  " is finished on . <br/>" + this.requestDate + "( "+ this.requestId +" )" , "CONCURRENT_NOTIFICATION", this.requestId, true );
			});
		});
	} 
	
	
	//메세지를 수신하는 함수
	function receiveMessage( event ) {
		var sent = JSON.parse( event.data );

		if( sent.status == "SUCCESS" ) {
			if( sent.message == "CONNECTED" ) {
				trace("WebSocket connection successfully established!");
				updateMessageText();
			} else {
				//서버에서 내려오는 메세지에 대한 처리 : Concurrent Job
				switch( sent.message.type ){
					case "CONCURRENT_NOTIFICATION" :
						addMessageOnMessageContainer(this.programName +  " is finished on. <br/>" + this.requestDate + "( "+ this.requestId +" )" , "CONCURRENT_NOTIFICATION", sent.message.requestId , true );
						break;

					case "NOTIFY_TO_ALL" :
						addMessageOnMessageContainer( sent.message.text , "NOTIFY_TO_ALL", sent.message.notificationId , true );
						break;

					case "READ_MESSAGE_ITEM" :
						$("._messageContainer ._messageItem[data-id='"+ sent.message.id +"']").remove();
						messageCount--;
						updateMessageText();

						//메세지 확인 함수가 호출 된 것이므로, 이때 관계된 화면을 호출한다.
						openRelatedForm( sent.message.source, sent.message.id );
						break;

					case "DELETE_ALL_MESSAGES" :
						$("._messageContainer ._messageItem[data-id]").remove();
						messageCount = messageCount - sent.message.itemCount ;
						updateMessageText();
						break;
				}
			}
		}
	}

	var concurrentViewerFormId;

	function openRelatedForm( source, id ) {

		if( concurrentViewerFormId == undefined ) {
			concurrentViewerFormId = uuid();
		} else {
			if(  $( "._contentWrapper[data-id='"+ concurrentViewerFormId +"']").exists()  ) {
				var form = LayoutManager.getForm( concurrentViewerFormId );
				form.search( id );
			} else {
				LayoutManager.addTab( concurrentViewerFormId , { requestId : id } );
			}
		}

		var menuItem = LayoutManager.getMenuItem( concurrentViewerFormId );

		if( menuItem == undefined ) {
			menuItem = {
				bizFormId : concurrentViewerFormId,
				menuId : "M_LGUTLC_1200",
				name : "Batch Log Viewer",
				programId  : "LGUTLC00140",
				systemCode : "LGCOM",
				moduleCode : "LGUTLC"
			};
			LayoutManager.getMenuItems().put( menuItem["bizFormId"], menuItem );
			LayoutManager.addTab( concurrentViewerFormId , { requestId : id } );
		}
	}

	function addMessageOnMessageContainer( text, source, id , nofify ) {
		if( $("._messageItem [data-source='"+ source +"'][data-id='"+id+"']").exists() ) {
			return;
		}
		
        if( nofify ) {
    		Message.instantMessage( "<span class='_messageItem' data-source='"+source+"' data-id='"+id+"' >"+ text +"</span>" );
        }
		
        messageCount++;
		updateMessageText();
		
		var messageItem =  $("<li class='_messageItem' data-source='"+source+"' data-id='"+id+"' ><a href='#'>"+ text + "</a></li>");
		$(messageItem).insertBefore("._messageContainer .divider");
	}

	function updateMessageText() {
		$( "._messageContainer ._messageItem._noMesage").hide();
		if( messageCount == 1 ) {
			messageText =  messageCount + " New message";
		} else if( messageCount > 1 ) {
			messageText =  messageCount + " New messages";
		} else if ( messageCount == 0 ) {
			messageText = messageButtonInitText;
			$( "._messageContainer ._messageItem._noMesage").show();
		}
		$("._globalStatusBar ._messageText").text( messageText );
	}

	//메세지를 발신하는 함수
	function sendMessage( message ) {
		if( socket == null ) {
			return;
		}
		try {
			socket.send( JSON.stringify( message ) );
		} catch( e ) { }
	}

	//연결을 생성하는 함수
	function connect() {
		try {
			socket = new WebSocket( WS_URL + "/lgcom/websocket/" + SESSION_USER.applicationUserId  );
			socket.onmessage = receiveMessage;
			//  socket.onclose = reconnect;
			socket.onerror = errorHandler;
			messageArea.find("._status").addClass("_online");
		} catch( e ) {
			socket = null;
			messageArea.find("._status").removeClass("_online");
			$("._globalStatusBar ._messageText").text( "Not Connected" );
		}
	}

	function reconnect() {
		if( socket == null ) {
			setInterval( connect, 1000 * 10 );
		}
	}

	function errorHandler() {
		if(  socket.readyState == "3" ) {  //Error in connection establishment: net::ERR_CONNECTION_REFUSED
			messageArea.find("._status").removeClass("_online");
			$("._globalStatusBar ._messageText").text( "Not Connected" );
		}
	}

	/* 메인 화면이 완전히 갱신될 때, '사용자가 확인하지 않고 놔둔 메세지' 를 가져와 목록에 반영한다 . 알림 없음*/
	function getUnreadNotificationList() {
		transaction( "lgcom", "common/concurrent/retrieveUnReadRequestList", {} , function( data ) {
			var list = data["result"];
			$(list).each( function(){
				addMessageOnMessageContainer(this.programName +  " is finished. <br/>" + this.requestDate + "( "+ this.requestId +" )", "CONCURRENT_NOTIFICATION", this.requestId, false );
			});
		});
	}

	/* 이벤트 핸들러 */
	//브라우저 윈도우가 갱신되기 직전에 socket 을 닫는 목적으로 이벤트 핸들러를 설정함
	$(window).bind('beforeunload',function() {
		if( socket != null ) {
			socket.close();
		}
	});

	$(document).on("click.main", "._messageContainer ._messageItem a", function() {
		var item = $(event.target).closest("._messageItem");
		var source = $(item).data("source");
		var id = $(item).data("id");

		transaction("lgcom", "common/concurrent/updateRequestAsRead", { requestId : id } , function() {
			if( quiteMode ) {
				item.remove();
				messageCount = messageCount - 1 ;
				updateMessageText();
			} else {
				var message = {"type" : "READ_MESSAGE_ITEM", "id" : id, "userId" : SESSION_USER.applicationUserId , source : source };
				sendMessage( message );
			}
		});
		event.preventDefault();
	});

	$(document).on("click.main", "._messageContainer .deleteAllNotifications", function() {
		var requestIdList = [];
		$("._messageContainer ._messageItem").each( function(){
			if( $(this).data("source") == "CONCURRENT_NOTIFICATION" ) {
				requestIdList.push( { requestId : $(this).data("id") } );
			}
		});

		if( requestIdList.length > 0 ) {
			transaction("lgcom", "common/concurrent/updateRequestAsRead", { requestIdList : requestIdList } , function() {
				if( quiteMode ) {
					messageCount = 0 ;
					updateMessageText();
					$("._messageContainer").find("._messageItem").not("._noMesage").remove();
				} else {
					var message = {"type" : "DELETE_ALL_MESSAGES", "userId" : SESSION_USER.applicationUserId , itemCount : requestIdList.length };
					sendMessage( message );
				}
			});
		}
		
		event.preventDefault();
    });
	
	$(document).on("click.main", "._messageContainer .goConcurrentViewer", function() {
		openRelatedForm();
		event.preventDefault();
	});
}

var ShortcutMenuTree = function( selector ) {
	var _this = this;
	var menuTree = $(selector);
	var searchForm =  $("._shortCutMenu .searchBlock .form");
	var userMenuTree = new JsTree( null, "._shortCutMenu .uxpTree", { search : "Y" } );
	var userMenuData = new Map();
	
	userMenuTree.onClick( function( e, data ){
		var menuItem = userMenuData.get( data.node.id );

		if( nvl( menuItem["programId"] ) == "" ) { return; }

		var menuId = menuItem["id"];

		LayoutManager.getMenuItems().put( menuItem["bizFormId"], { systemCode : menuItem["systemCode"], name : menuItem["menuName"],  programId : menuItem["programId"], menuId : menuItem["menuId"] , urlAddr : menuItem["urlAddr"] } );
		LayoutManager.addTab( menuItem["bizFormId"] );

		if( $("._intro").css('display') != "none" ) {
			$("header ._menu._level1 ._menuItem:first").trigger("click");
		}

		$( "._shortCutMenu" ).removeClass("_show");

		e.stopPropagation();
	});
	
	this.loadData = function(){
		getUserMenuData();
	}
	
	this.refresh = function(){
		getUserMenuData();
	}
	
	initCombo();
	
	function initCombo() {
		var code = new CommonCode(CONTEXT_PATH);
		code.add(  "LGCOM_SYSTEM_CODE" , { codeTypeCode : "LGCOM_SYSTEM_CODE" } );
		code.execute();

		var combo = searchForm.find("select");
		$( code.get("LGCOM_SYSTEM_CODE") ).each(function() {
			combo.append("<option value='"+ this["code"] +"' >" + this["name"] + "</option>");
		});
		combo.find("option:first").prop('selected', true);
	}
	
	function getUserMenuData(){
		transaction( "lgcom", "lgsysc/LGSYSC00220/retrieveMyMenuListByRole", { systemCode : searchForm.find("select").val() } , function(data){
			userMenuData.clear();
			var list = data["result"];

			$(list).each( function( inx ){
				var state = { opened : false, disabled : false, selected : false };
				this["state"] = state;
				this["bizFormId"] = uuid();
				userMenuData.put( this["menuId"], this );
			});
			refreshTree( userMenuTree, userMenuData );
		});
	}
    
	function refreshTree( tree, mapData ) {
		if( mapData.size() == 0 ) return;
		var treeData = [];

		$(mapData.keys()).each(function(){
			var menuItem = mapData.get( this );

			if( menuItem["highMenuId"] == undefined ) {
				menuItem["highMenuId"] = "#"; //jsTree 는 root메뉴의 parent 가 # 이어야 한다.
			} else {
				var parent = mapData.get( menuItem["highMenuId"] );
			}

			menuItem["status"] = "N";

			//각 레벨에 따라 type 을 지정한다.
			if( menuItem["menuLevelNo"] == "0" ) {
				menuItem["menuLevelType"] = "root";
			} else if( menuItem["menuLevelNo"] == "1" ) {
				menuItem["menuLevelType"] = "child";
			} else if( menuItem["menuLevelNo"] == "2" ) {
				menuItem["menuLevelType"] = "branch";
			} else if( menuItem["menuLevelNo"] == "3" ) {
				menuItem["menuLevelType"] = "leaf";
			}

			var state = menuItem.state;

			if( menuItem.state == undefined ) {
				state = { opened : true, disabled : true, selected : false };
			}

			treeData.push({
				id : menuItem["menuId"],
				parent : menuItem["highMenuId"],
				text : menuItem["menuName"],
				type : menuItem["menuLevelType"],
				state : state
			});
		});

		tree.setData( treeData  );
	}	
	
	$(document).on( "change._main", "._shortCutMenu .searchBlock select[name='systemCode']" , function( event ) {
		_this.loadData();
	});
	
	$(document).on( "click._main", "._shortCutMenu ._shortCutCloseButton", function( event ) {
		$( "._shortCutMenu" ).removeClass("_show");
		$("#_div_global_background_").hide();
		// 201.07.11. forain. Popup에서 Popup이 open 된 경우 BIMATRIX 처리 안함.
		if(LayoutManager.getPopups() && LayoutManager.getPopups().size() == 0) {
			LayoutManager.toggleIframeOnActiveTab(true);
		}
	});
	
	$(document).on( "keyup._main", "._shortCutMenu .searchBlock input[name='menuName']" , function( event ) {
		var to = setTimeout(function() {
			var text = $(event.target).val();
			menuTree.jstree(true).search( text );
			clearTimeout(to);
		}, 250);
	});
}

var SystemNoticePopup = function() {
	var container   = $("div._system_notice_popup");
	var noticeList = $("div._system_notice_popup .noticeList ul");
	var content     = $("div._system_notice_popup .noticeContent");
	var currentItemId ;
	var systemNoticeList = new Map();
	var position;
	retrieveSystemNoticeList();

	function retrieveSystemNoticeList( callback ) {
		transaction("lgcom", "common/uiCommon/retrievePopupNoticeList", { targetRow : 1, rowSize : 20 } , function(data){
			var list = data["result"]["resultList"];
			noticeList.empty();

			if( list.length > 0 ) {
				container.show();
				container.draggable({
					handle: ".noticeHeader"
				}).resizable({
					minWidth : 400,
					minHeight: 300
				});

				position = { status : "default",
					left   : $(container).offset().left,
					top    : $(container).offset().top ,
					bottom : $(container).offset().top  + $(container).height() ,
					right  : $(container).offset().left + $(container).width()
				};
			}

			$(list).each( function(){
				var id = uuid();
				systemNoticeList.put( id, this );
				noticeList.append("<li data-id='"+ id +"' class='_noticeItem list-group-item'>"+ this["bulletinBoardTitle"]+"</li>");

			});

			try {
				callback.call(this);
			}catch(e){}

			noticeList.find("._noticeItem:first-child").click();
		});
	}

	$(document).on("click.main_notice", "div._system_notice_popup .noticeList ._noticeItem", function( event ) {
		currentItemId = $(event.target).data("id");
		var _content = $.trim( systemNoticeList.get( currentItemId )["bbBodyContent"] ).replace(/<style[^>]*>(.*?)\<\/style>/i,'')
		content.html( _content );
		content.animate({ scrollTop: 0 }, "fast");

		$(event.target).addClass("active").siblings().removeClass("active");
	});

	$(document).on("click.main_notice", "div._system_notice_popup .noticeHeader .close", function( event ) {
		$(document).off(".main_notice");
		container.html("").hide();
	});

	$(document).on("change.main_notice", "div._system_notice_popup .userCheckFlag", function( event ) {
		var currentItem = systemNoticeList.get( currentItemId );
		var data = { "bulletinBoardNo" : currentItem["bulletinBoardNo"] };
		var action = "lgsysc/LGSYSC00210/insertUserPopupHistory";

		if( !$(event.target).is( ":checked" ) ) {
			action = "lgsysc/LGSYSC00210/deleteUserPopupHistory";
		}

		transaction( "lgcom", action , data, function( data ) {
			Message.notify("Completed.");
		});
	});

	$(document).on("dblclick.main_notice", "div._system_notice_popup .noticeHeader", function( event ) {
		if( position["status"] == "default" ) {
			position = {
				status : "default",
				left   : $(container).offset().left,
				top    : $(container).offset().top ,
				bottom : $(container).offset().top  + $(container).height() ,
				right  : $(container).offset().left + $(container).width()
			};
			$(container).css("top", "50px").css("left", "10px").css("right", "10px").css("bottom", "10px");
			$(container).trigger("resize");
			position["status"] = "max";
		} else {
			$(container).css("top",  position.top + "px").css("left", position.left + "px").css("right",  position.right + "px").css("bottom", position.bottom + "px");
			$(container).trigger("resize");
		}
	});

	this.refresh = function( callback ) {
		retrieveSystemNoticeList( callback );
	}

	this.show = function() {
		this.refresh( function(){
			container.show();
		});
	}
}


var DeveloperSupport = function(){
	var _this = this;
	var devTools = $("#devTools");
	var gridOn = false;
	var gridGap = 15;
	var contents = $("._contents");
 	var margin = {left : 5, top : 5 };
	
	this.gridToggle = function(){
		if( gridOn ) {
			_this.gridOff();
			gridOn = false;
		} else {
			_this.gridOn();
			gridOn = true;
		}
	}
	
	this.gridOff = function(){
		contents.find("._lines_").remove();
	}
	
	this.gridOn = function(){
		var width = contents.width();
		var height = contents.height();
		var left = margin.left;
		
		while( true ) {
			contents.append( getVLine( left ) );
			left = left + gridGap;
			
			if( left > width ) {
				break;
			}
		}
		
		var top = margin.top;
		while( true ) {
			contents.append( getHLine( top ) );
			top = top + gridGap;
			
			if( top > height ) {
				break;
			}
		}
	}
	
	var linesMap = new Map();
	localStorage.setItem("lastname", "Smith");
	
	function addGuideLine(){
		var guideLine = $("<div class='_guideLine_' style='position:absolute;width:5px;border:0px;background:transparent;top:0px;bottom:0px;left:50%;cursor:w-resize;z-index:3010;'></div>");
		var centerLine = $("<div style='position:absolute;top:0px;bottom:0px;left:2px;width:1px;background:red;'></div>");
		guideLine.append(centerLine);
		guideLine.draggable({ axis: "x", 
			                  containment :"parent" 
			                 }); 
		contents.append( guideLine );
	}
	
	function getVLine( left ){
		return $("<div class='_lines_' style='position:absolute;width:1px;border:0px;border-left:1px solid #e1dcff;top:0px;bottom:0px;left:"+ left +"px;z-index:3000;'></div>");
	}
	
	function getHLine( top ){
		return $("<div class='_lines_' style='position:absolute;height:1px;border:0px;border-top:1px solid #e1dcff;top:"+top+"px;right:0px;left:0px;z-index:3000;'></div>");
	}
	
	$(contents).on( "mouseenter", "._guideLine_", function(){
		var target = $(event.target);
		if( target.hasClass("_guideLine_") ) {
			$(target).css( { "width":"7px" }); 
		}
		event.stopPropagation();
	});
	
	$(contents).on( "mouseleave", "._guideLine_", function(){
		var target = $(event.target);
		if( target.hasClass("_guideLine_") ) {
			$(target).css( { "width":"5px" }); 
		}
		
		event.stopPropagation();
	});
	
	
	//$(document).on(  "contextmenu.main", "main ._header ._contentName", function( event ){
	
	
	$(devTools).on( "click", "[data-action]", function(event){
		var item = $(event.target);
        var action = item.data("action");
        
        switch(action){
        case "gridToggle" :
        	_this.gridToggle();
        	break;
        case "addGuideLine" :
        	addGuideLine();
        	break;	
        }
	});
	
	$(document).data("DEV_SUPPORT", this );
}

var MDIUtil = function(){
	trace("###MDIUtil ###");
	var wrap ,target, active;

	/* 탭 정리 규칙
	 * 1. 이 메소드가 호출되면 활성화된 탭이 보이는 영역에 있을때는 아무 동작을 하지 않는다.
	 * 2. 왼쪽 바깥에 있으면 플레이트가 이동하여 활성 탭의 왼쪽이 영역 왼쪽에 정렬한다. 
	 * 3. 오른쪽 바깥에 있으면 플레이트가 이동하여 활성 탭이 오른쪽으로 정렬한다. 
	 * 4. 어정쩡하게 걸린 경우에도 2, 3 의 규칙에 따라 가장 가까운 면으로 이동 정렬한다.
	 **/
    this.adjustActiveTab = function(){
    	trace("adjustActiveTab method");
    	var status = getStatus();
    	// 탭이 어디에 있는지 확인한다. 
    	// 오른쪽에 걸쳐있거나 바깥으로 나가 있으면 +1
    	// 보이는 영역에 있으면 0
    	trace("status : " + status );
    	
    	if( status == -1 ) { // 왼쪽에 걸치거나 바깥
    		matchLeft();
    	}
   
    	if( status == 1 ) { // 오른쪽에 걸치거나 바깥
    		
    	}    	
    }
    
    this.moveLeft = function(){
    	
    }
    
    this.moveRight = function(){
    	
    }
    
    this.resize = function(){
    	
    }
    
    function matchLeft() {
    	// a를 w 좌측에 맞추기 위해 a 를 움직일 양
    	var d =  dim.w_left - dim.a_left; 
    	// 최종으로 t 가 가져야 할 left 값
    	var left = dim.t_left + d;  // 우측 방향으로의 이동이므로, left 는 증가해야 한다.
    
        var param = { left: "-" + left + "px"  };
        if( left < 10 ) {
        	param = { left: "0px" };
        }
    	
        target.stop().animate( param , {
        	complete : function(){
        		mdiTabMovmentControl();	
        	}
        });	
    }
    
    function getStatus() {
    	var dim = buildDimension();
    	trace(dim);
     	//왼쪽에 걸쳐있거나 바깥으로 나가 있는 경우
    	if( dim.a_left  < dim.w_left ) { 
    		return -1;
    	} 
    	
    	//오른쪽에 걸쳐있거나 바깥으로 나가 있는 경우
    	if( dim.w_right < dim.a_right ) { 
    		return 1;
    	}
    	//
    	if( dim.w_left  <= dim.a_left && dim.w_right >= dim.a_right) {
    		return 0;
    	}
    }
    
	function buildDimension(){
	    wrap = $('.mdi-tabs .scroll-wrap');
		target = wrap.children('ul');
		active = target.find(".active");
		
		trace("active : ")	
		trace( wrap.length );
		trace( target.length );
		trace( active.length );
		
		var dim = { 
	    		w_left : wrap.offset().left,
	    		w_right : wrap.offset().left + wrap.width(),
	    		a_left : active.offset().left,
	    		a_right : active.offset().left + active.width(),
	    		t_left : target.offset().left,
	    		t_right : target.offset().left + active.width()
	    }
		
		return dim;
	}
	
	function mdiTabMovmentControl() { 
		if( $('.scroll-wrap .nav-tabs').width() < $('.scroll-wrap').width()) {
		    $('.scroll-wrap').removeClass('movable');
		} else {
		    $('.scroll-wrap').addClass('movable');
		}
		
		//왼쪽 희미한 부분은 왼쪽으로 밀려난 부분이 있을 때만 활성화 된다. 
	    if( $('.scroll-wrap .nav-tabs').offset().left <  $(".scroll-wrap").offset().left  ) {
	    	$('.scroll-wrap').addClass('moved');
		} else {
			$('.scroll-wrap').removeClass('moved');
		}
	}
		
}