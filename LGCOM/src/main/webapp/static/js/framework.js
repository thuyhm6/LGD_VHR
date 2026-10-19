/************************************************************
 * BizForm Class : 업무용 Application 의 부모 클래스
 ************************************************************/
var BizForm = function(bizFormId) {
	var _this = this;

	var formId = bizFormId;
	var container = $("div#" + bizFormId); // 개별 bizForm 의 container는 ._contentWrapper 가 아니라 _content 이다.

	// 이 폼이 보유한 그리드 오브젝트를 모두 등록하는 목록
	var gridList = [];
	//이 폼이 보유한 charts 리스트를 모드 등록하는 목록
	var chartList = [];

	// 요청서 정보를 보관하는 항목
	var request;

	// 전자결재 정보를 보관하는 항목
	var approval;

	// LayoutManager 이 폼을 새로 등록한다.
	this.init = function() {
		//trace("### BizForm Init Start for " + bizFormId + "###");
		LayoutManager.addForm(bizFormId, this);
		/* BizForm 공통 메소드 : 이 메소드는 상속되어, 모든 Form 에 대하여 사용할 수 있다 */
		//trace("### BizForm Init End for " + bizFormId + "###");
	};

	// User Access 체크와 처리
	var userAccessListcount = $(document).data("USER_ACCESS_LIST_COUNT").get( bizFormId);
	var userAccessList = $(document).data("USER_ACCESS_LIST").get(bizFormId);
	if (userAccessListcount > 0 && userAccessList != undefined) {
		// 특정 태그를 달고있는 모든 아이템을 화면에서 감춘다.
		container.find("*[data-access]").hide();
		$(userAccessList).each( function() {
			container.find( "*[data-access='" + this["progServId"] + "']") .show();
		});
	}

	// 초기상태로서, searchToggle 은 꺼져있고, managedLayout은 사용하지 않는 상태이다.
	var managedLayout = {
		_search_toggle_flag_ : false,
		_manage_ : false
	};

	var closeCallback;

	this.onClose = function( func ) {
		closeCallback = func;
	}

	var parentForm ;

	this.setParentForm = function( form ) {
		parentForm = form;
	}

	this.getParentForm = function() {
		return parentForm;
	}

	var initialLayoutInfo;
	
	this.resetLayout = function(){
		trace( "resetLayout" );
		if( initialLayoutInfo == undefined ) return;
		
		trace( initialLayoutInfo );
		trace( "resetLayout end " );
		
		this.setLayout( initialLayoutInfo );
	};
	
	this.setLayout = function( list ) {
		initialLayoutInfo = list;
		
		/* Managed Layout 을 사용하는 경우에 대한 처리 */
		$(container).addClass("_managed_layout_"); 
		var layout = {};
		
		$(list).each( function(){
			layout[ this["name"] ] = this;
			this["_styles_"] = {};
		});
		
		managedLayout = layout;
		managedLayout["_manage_"] = true;
		
		//각 항목들에 대한 여백을 계산한다.
		$(list).each( function( inx ){
			var value = this;
			var styles = value["_styles_"];
			
			var name = value["name"];
			if( name == "searchBlock") {
				name = "searchBlock .search-wrap";
			}
		
			var item = container.find("." + name );
			var margin = item.outerHeight( true ) - item.outerHeight();
			
			if( item.is(":visible") ) {
				value["_dimension_"]  = { margin : margin,
                        top    : item.position().top,
                        left   : item.position().left,
                        height : item.outerHeight(),
                        width  : item.outerWidth() };
			} else {
				value["_dimension_"]  = { margin : 0,
                        top    : 0,
                        left   : 0,
                        height : 0,
                        width  : 0 };
			}

			if( value["height"] != undefined ) {
				value["_dimension_"]["height"] = value["height"];
			}
			
			if( value["width"] != undefined ) {
				value["_dimension_"]["width"] = value["width"];
			}
			
			styles["position"] = "absolute";
			
			if( value["left"] != undefined  ) { styles["left"]   = value["left"]  + "px"; }
			if( value["right"] != undefined  ) { styles["right"]  = value["right"] + "px"; }
			if( value["width"] != undefined  ) { styles["width"]  = value["width"] + "px"; }
			if( value["height"] != undefined  ) { styles["height"] = value["height"] + "px"; }
			
			if( value["top"] != undefined  && $.isNumeric( value["top"] )  ) { styles["top"] = value["top"] + "px"; }	
			if( value["bottom"] != undefined   && $.isNumeric( value["bottom"] )  ) { styles["bottom"] = value["bottom"] + "px"; }
			
			//각 아이템들에서 parent 항목이 있고, 이 항목이 layout 정의에 항목으로 정해지지 않았다면, 
			//이 항목을 position : relative 로 지정한다.
			if( value["parent"] != undefined && layout[ value["parent"] ] == undefined ) {
				var parent = container.find("." + value["parent"] );
				parent.css({"position" : "relative"});
			}
		});
		
		//다시 돌면서 각 항목들에 대한 Top 값을 세팅한다 
		$(list).each( function( inx ){
			var value = this;
			var styles = value["_styles_"];
			
			var item = container.find("." + value["name"] );
			var top = value["top"];
			
			if( top != undefined && !$.isNumeric( top ) ){
				//이 항목의 top 에 적힌 상대 오브젝트의 정보를 담고있는 내용 추출
				var dimension = layout[top]["_dimension_"];
				var myDimemsion = value["_dimension_"];
				
				value["top"] = Number( nvl( dimension["top"], 0 ) ) +
						       Number( nvl( dimension["height"], 0 ) ) + 
						       Number( nvl( dimension["margin"], 0 ) );
				
				myDimemsion["top"] = value["top"];
				styles["top"] = value["top"] + "px";
			} 
			
			var left = value["left"];
			if( left != undefined && !$.isNumeric( left ) ){
				//이 항목의 top 에 적힌 상대 오브젝트의 정보를 담고있는 내용 추출
				var dimension = layout[left]["_dimension_"];
				var myDimemsion = value["_dimension_"];
				
				value["left"] = Number( nvl( dimension["left"], 0 ) ) +
						        Number( nvl( dimension["width"], 0 ) ) + 
						        Number( nvl( dimension["margin"], 0 ) );
				
				myDimemsion["left"] = value["left"];
				styles["left"] = value["left"] + "px";
			} 
		});
		
		list.reverse();
		
		//다시 돌면서 각 항목들에 대한 Bottom 값을 세팅한다 
		$(list).each( function( inx ){
			var value = this;
			var styles = value["_styles_"];
			
			var item = container.find("." + value["name"] );
			var bottom = value["bottom"];

			if( bottom != undefined &&  !$.isNumeric( bottom ) ){
				//이 항목의 top 에 적힌 상대 오브젝트의 정보를 담고있는 내용 추출
				var dimension = layout[bottom]["_dimension_"];
				var myDimemsion = value["_dimension_"];
				//여기서는 상대의 bottom + 상대의 높이 + 나의 마진 이렇게 된다. 
				value["bottom"] = Number( nvl( dimension["bottom"], 0 ) ) + 
				                  Number( nvl( dimension["height"], 0 ) ) + 
				                  Number( nvl( myDimemsion["margin"], 0 ) );
				
				myDimemsion["bottom"] = value["bottom"];
				styles["bottom"] = value["bottom"] + "px";
			} 
			
			var right = value["right"];

			if( right != undefined &&  !$.isNumeric( right ) ){
				//이 항목의 top 에 적힌 상대 오브젝트의 정보를 담고있는 내용 추출
				var dimension = layout[right]["_dimension_"];
				var myDimemsion = value["_dimension_"];
				//여기서는 상대의 bottom + 상대의 높이 + 나의 마진 이렇게 된다. 
				value["right"] = Number( nvl( dimension["right"], 0 ) ) + 
				                 Number( nvl( dimension["width"], 0 ) ) + 
				                 Number( nvl( myDimemsion["margin"], 0 ) );
				
				myDimemsion["right"] = value["right"];
				styles["right"] = value["right"] + "px";
			} 		
			
			item.addClass("nomargin");
			item.find(".search-wrap").addClass("nomargin");
		    item.css( styles );
		});
	}
	
	this.setManagedLayout = function( normalLayout , smallSizedLayout ) {
		/* 이 화면의 레이아웃이 큰 것 인지 작은 것인지 저장한다. */
		var smFlag = $("body").hasClass("page-sm");
		var layouts = normalLayout;
		
		if( smFlag && smallSizedLayout != undefined  ) {
		    layouts = smallSizedLayout;
		    trace("[Layout] LayoutManager activated : Small Mode.");
		} else {
			trace("[Layout] LayoutManager activated : Default Mode.");
		}
		
		var searchBlock = "searchBlock";
			
		if (layouts == undefined) {
			return;
		} else {
			$.each( layouts , function( key, value ) {
				managedLayout[key] = value;
				
				if( value["search"] ) {
					searchBlock = key;
				}
			});
		}
		
		/* Managed Layout 을 사용하는 경우에 대한 처리 */
		$(container).addClass("_managed_layout_"); 
		managedLayout["_manage_"] = true;
		
		/* 레이아웃 타입에 따라서, line 의 기본 top 값을 지정해 둔다. */ 
		if( smFlag ) { // small 타입
			managedLayout["_smFlag_"] = true;
			managedLayout["lines"] = { line1 : 0 , line2 : 70 , line3 : 100 };
			managedLayout["searchLineHeight"] = 24;
		} else {  // large 타입
			managedLayout["_smFlag_"] = false;
			managedLayout["lines"] = { line1 : 0 , line2 : 102 , line3 : 140 };
			managedLayout["searchLineHeight"] = 34;
		}
		
		//searchBlock 을 분석하여, 사이즈 조정에 필요한 정보를 저장한다. 
		if( $(container).find( "." + searchBlock + " table tbody tr").length == 1 ) {
			$.each( managedLayout["lines"], function(key, value) {
				if( value > 0 ) {
			       managedLayout["lines"][key] = value - managedLayout["searchLineHeight"];	
				}
			});
		}
		
		$.each(managedLayout, function(key, values) {
			var target = $("div#" + bizFormId + " ." + key);
			
			//target.addClass("nomargin");
			//target.find(".search-wrap").addClass("nomargin");
			
			if (typeof (values) != "object" || key == "lines" ) {
				return true;
			}

			// 들어온 아이템들을 모두 absolute 로 만든다.
			var oldStyle = target.attr('style');
			
			if (!oldStyle) {
				oldStyle = "";
			}

			var style = "position:absolute;" + oldStyle + _cssItem(managedLayout,  values);
			target.css("width", "auto").attr("style", style);
		});
		this.refreshGrid();
	}

	this.addChart = function( chart ) {
		chartList.push( chart );
	}

	var editorList = [];
	this.addEditor = function( editor ) {
		editorList.push( editor );
	}

	var crossEditorList = [];
	this.addCrossEditor = function( crossEditor ) {
		crossEditorList.push( crossEditor );
	}

	//MultiForm Class에 의해서 추가되는 자식 폼들을 MultiForm 을 포함하고 있는 BizForm 에 연동하기 위한 메소드 부분으로,
	//화면에서 Main 의 Tab 이 닫힐 때, 리소스를 연동하여 해제 하기 위해 사용된다
	var innerFormList = [];
	this.addInnerForm = function( innerForm ) {
		innerFormList.push( innerForm );
	}

	function _cssItem( managedLayout, values) {
		var str = "";
		var items = {
			top : false,
			left : false,
			right : false,
			bottom : false,
			width : false,
			height : false
		};

		$.each(values, function(key, value) {
			if (key == "top") {
				items.top = true;
			}
			if (key == "left") {
				items.left = true;
			}
			if (key == "right") {
				items.right = true;
			}
			if (key == "bottom") {
				items.bottom = true;
			}
			if (key == "width") {
				items.width = true;
			}
			if (key == "height") {
				items.height = true;
			}
			if (key == "line"  ) {  // 항목에 line 이 들어가면, 항목은 반드시 top 을 갖게 된다. 
				items.top = true; 
				values["top"] = managedLayout["lines"][ key + value];
			}			
		});
		
		$.each(values, function(key, value) {
			// 만약, left, right, width 가 동시에 모두 들어오면, 그중 right 는 무시한다.
			if (items.width && items.left && items.right) {
				items.right = false;
			}

			// 만약, top, bottom, height 가 동시에 모두 들어오면, 그중 bottom 을 무시한다.
			if (items.height && items.top && items.bottom) {
				items.bottom = false;
			}

			//width, height가 key마다 중복으로 추가되어 제거함
			if (str.indexOf('width') == -1) {
				if (!items.width) {
					str += "width:auto;";
				}
			}

			if (str.indexOf('height') == -1) {
				if (!items.height) {
					str += "height:auto;";
				}
			}
			
			str += key + ":" + value + "px;"
		});
		
		return str;
	}

	this.refreshGrid = function() {
		$(gridList).each(function(inx) {
			this.resetSize();
		});

		$(chartList).each(function(inx) {
			this.redraw();
		});

		$(editorList).each( function(inx){
			this.resetSize();
		});

		$(crossEditorList).each( function(inx){
			this.resetSize();
		});

		$(innerFormList).each( function(inx){
			this.refreshGrid();
		});
	}

	//Window의 resize 이벤트에 맞춰동작하는 컴포넌트 사이즈 조정이 필요한 아이템을 resize 한다.
	this.resizeComponent = function(){
		$(editorList).each( function(inx){
			this.resetSize();
		});

		$(crossEditorList).each( function(inx){
			this.resetSize();
		});
	}

	this.getManagedLayout = function() {
		return managedLayout;
	}

	/* 팝업형태로 호출된 폼이라면, 부모가 있으므로 부모 폼이 리턴된다. */
	this.getParent = function() {
		return LayoutManager.getParent(bizFormId);
	}

	this.getBizFormId = function() {
		return bizFormId;
	}

	this.select = function(selector) {
		var selectorArr = selector.split(",");
		selector = "";
		$(selectorArr).each( function(){
			selector += "div#" + bizFormId + " " + this + ",";
		});
		selector = selector.slice(0, -1);
		return $(selector);
	}

	this.selector = function(selector) {
		return "div#" + bizFormId + " " + selector;
	}

	// 이 함수에서 bizFormId 를 모든 이벤트의 namespace 로 걸어두었기 때문에, 폼이 닫힐 때, 이 namespace 에
	// 해당하는 모든 이벤트를 .off() 하게 된다.
	// 따라서 개발자는 개별 폼 안에서 이벤트를 선언할 때는 반드시 이 메소드만을 사용해야 이벤트의 중복호출을 막을 수 있다.
	this.addEvent = function(eventName, selector, callback) {
		var eventNameArr = eventName.split(",");
		$(eventNameArr).each( function(){
			eventName += "." + bizFormId + ",";
		});
		eventName = eventName.slice(0, -1);

		$("#" + bizFormId ).on( eventName, selector, function(event) {
			try {
				var action = $(event.target).data("action");
				callback.call(this, event, { selector : selector, event : event });
			} catch (e) {
				trace(e);
				Message.error(Message.APPLICATION_ERROR + " : <br> Event : " + eventName + "<br> For : " + selector + "<br> Message : " + e.message);
			}
		});
	}

	// jQuery Data 를 모방한 메소드로, 각 폼에서 전역변수로 저장할 정보를 저장 / 인출하기 위한 메소드이다.
	// 이 전역변수가 Form 바깥으로 나가지 않도록 하기 위해서, 이와 같이 정리한다.
	this.data = function(key, value) {
		if (value == undefined) {
			return container.data(key);
		} else {
			container.data(key, value);
		}

	}

	this.setRequestInfo = function(info) {
		this.request = info;
	}

	this.getRequestInfo = function() {
		return this.request;
	}

	this.setApprovalInfo = function(info) {
		this.approval = info;
	}

	this.getApprovalInfo = function() {
		return this.approval;
	}

	/* BizForm 공통 함수 */
	function processComponents() {
		container.find(".searchBlock .heightAdjControl").hide();
		// 표준 가이드에 따른 리사이즈 오브젝트는 일괄 제거한다.
		container.find(".searchBlock .partFoldingBtn").remove();

		var flag = false;
		container.find(".searchBlock").each( function(){
			var searchBlock = $(this);
			// 1. .searchBlock 의 line 의 갯수가 2개보다 많으면 2개만 남기고 .line 을 숨김처리 한다.
			var count = searchBlock.find("tbody tr").length;

			if (count > 2) {
				//var adjControl = $('<button type="button" class="heightAdjControl btn btn-default btn-sm" data-status="CLOSED" data-toggle="tooltip" aria-label="Detail Toggle"><i class="fa fa-plus" aria-hidden="true"></i></button>');
				var adjControl = $("<button type='button' data-status='CLOSED' class='partFoldingBtn btn btn-default btn-sm' data-toggle='tooltip' aria-label='Detail Toggle'><span class='fa fa-plus' aria-hidden='true'></span></button>");
				searchBlock.find(".search-wrap").append(adjControl);
				searchBlock.find("tbody tr:gt(1)").hide(); // gt 는 zero based index
			}
			
			// 2. 화면이 small 모드일때, searchBlock 내 table 태그에 추가 class 를 넣는다.
			if( $("body").hasClass("page-sm") && nvl( Profile.SEARCH_BLOCK_THEME ) == "LINE" ) {
				$(searchBlock).find(".table").addClass("input-line");
			}
		});

		// 페이지를 로딩하고 나서, 각 페이지 안의 설정에 대해 기본 값을 정리해주는 부분이다.
		// 1. tooltip 을 설정하는 부분
		$('div#' + bizFormId + ' *[data-toggle="tooltip"]').tooltip({ container : 'body' });

		// 2. 조회 조건 저장여부가 체크 된 form 이라면, 서버에서 조회조건을 인출해서, 화면 조회영역에 뿌려주도록 한다.
		if (searchConditionFlag) {
			getSearchCondition();
		}

		// 3. 모든 form 에 대하여, submit() 이벤트를 무력화 한다.
		$(container).find("form").each(function() {
			this.onsubmit = function() {
				return false;
			}
		});

		// 4. pageHeader 지워버리기
		$(container).find(".pageHeader").remove();

		// zpastable 아이템에 대한 처리
		$('div#' + bizFormId + ' input[pastable]').pastable();

		// 6. 모든 form 에대해서 autocomplte 속성을 끈다.
		$('div#' + bizFormId + ' form').attr("autocomplete", "off");

		$("#" + bizFormId ).on("keydown." + bizFormId, '.searchBlock form:not([noenter])', function(event) {
			if (event.keyCode == "13") { // Enter press
				var triggerFlag = true;
				//조회 영역의 조회 버튼
				if( $(event.target).hasClass("btn-lgd") ) {
					triggerFlag = false;
				}
					
				//조회 영역의 팝업 아이콘이 있는 Input Box
				if( $(event.target).parent().hasClass("input-search") || $(event.target).parent().parent().hasClass("input-search") ) {
					triggerFlag = false;
				}
					
			    if( triggerFlag ) {
					$(this).find("button.btn-lgd").trigger("click");
				}
			}
			event.stopPropagation();
		});

		// 7. multiselect 아이템에 대한 처리
		$('div#' + bizFormId + ' select[multiselect]').each(function() {
			$(this).prop("multiple", true);

			var userOption = $(this).attr("multiselect");

			//필터는 기본적으로 켜는 것이고, 사용자가 filter:off 를 주었다면, 필터를 끈다.
			var filter = true;
			if( userOption.indexOf("filter:off") > -1 ) {
				filter = false;
			}

			var menuWidth = 160; //기본 최소크기를 적용
			//사용자가 width 항목을 입력하였다면, 이 값을 추출하여 menuWidth 에 적용한다.
			$.each( userOption.split(","), function( inx, item ){
				if( item.indexOf("width") > -1 ) {
					menuWidth = Number( item.replaceAll("width:", "") );
					return false;
				}
			} );

			var option = {
				classes : "_multiselect",
				height : "auto",
				minWidth : 160,
				menuWidth : menuWidth,
				noneSelectedText : Message.MULTISELECT_NONE_SELECTED_TEXT,
				selectedText : Message.MULTISELECT_SELECTED_TEXT,
				optgrouptoggle : function(event, ui) {
					var checkAll = $(ui.inputs[0]).closest("._multiselect").find(".selectAllContol a");
					if( ui.checked == false && $(checkAll).hasClass("ui-multiselect-none") ) {
						$(checkAll).removeClass("ui-multiselect-none").addClass("ui-multiselect-all");
					}
				},
				beforeopen : function(event, ui){
					LayoutManager.toggleIframeOnActiveTab(false);
				}, 
				close : function(event, ui){
					LayoutManager.toggleIframeOnActiveTab(true);
				}
			};

			if( filter ) {
				$(this).multiselect(option).multiselectfilter( {label : "<span>Filter</span>", placeholder : "" } );
			} else {
				$(this).multiselect(option);
			}

			$(this).multiselect("uncheckAll");

			//이 아이템의 태그에 disabled 있는지 봐서, multiselect의 disable 처리를 수행한다.
			if( $(this).is(":disabled") ) {
				$(this).multiselect("disable");
			}
		});

		//singleselect 또는 multiselect 속성이 없는 모든 select 태그에 대해 multiselect() 을 적용하도록 함 : 필터는 적용하지 않는다.
		/*
		$('div#' + bizFormId + ' select:visible:not( [multiselect], [singleselect] )' ).each( function(){
			var menuWidth = "auto";

			var option = {
				classes : "_singleselect",
				height : "auto",
				multiple: false,
				minWidth : "auto",
				noneSelectedText : Message.MULTISELECT_NONE_SELECTED_TEXT,
				selectedText : function(){ return $(_this).find("option:selected").html(); }
			};

			$(this).multiselect( option );

			//이 아이템의 태그에 disabled 있는지 봐서, multiselect의 disable 처리를 수행한다.
			if( $(this).is(":disabled") ) {
				$(this).multiselect("disable");
			}
		});
		*/

		//singleselect 속성을 가지고 있는 select 태그에 대해서 multiselect() 을 적용하도록 함 : 필터사용의 옵션을 줄 수 있다.
		$('div#' + bizFormId + ' select[singleselect]:visible' ).each( function(){
			var item = this;
			var userOption = $(this).attr("singleselect") + "";

			//필터는 기본적으로 끄는 것이고, 사용자가 filter:on 를 주었다면, 필터를 켠다 <---- multiselect 와 옵션이 반대임에 주의할 것 !!
			var filter = false;
			var minWidth = "auto";
			if( userOption.indexOf("filter:on") > -1 ) {
				filter = true;
				minWidth = 160;
			}

			var menuWidth = $(this).outerWidth(); //기본 최소크기를 적용
			//사용자가 width 항목을 입력하였다면, 이 값을 추출하여 menuWidth 에 적용한다.
			$.each( userOption.split(","), function( inx, item ){
				if( item.indexOf("width") > -1 ) {
					menuWidth = Number( item.replaceAll("width:", "") );
					return false;
				}
			} );

			var option = {
				classes : "_singleselect",
				height : "auto",
				multiple: false,
				minWidth : minWidth,
				menuWidth : menuWidth,
				noneSelectedText : Message.MULTISELECT_NONE_SELECTED_TEXT,
				selectedText : function(){ return $(item).find("option:selected").html(); },
				beforeopen : function(event, ui){
					LayoutManager.toggleIframeOnActiveTab(false);
				}, 
				close : function(event, ui){
					LayoutManager.toggleIframeOnActiveTab(true);
				}
			};

			if( filter ) {
				$(this).multiselect( option ).multiselectfilter( { label : "<span>Filter</span>", placeholder : "" });
			} else {
				$(this).multiselect( option );
			}

			//이 아이템의 태그에 disabled 있는지 봐서, multiselect의 disable 처리를 수행한다.
			if( $(this).is(":disabled") ) {
				$(this).multiselect("disable");
			}
		});

		// 7-1. monthpicker
		/*
		var monthpickerWrapper = $("<div class='form-inline'></div>");
		monthpickerWrapper.insertAfter( $('div#' + bizFormId + ' input[monthpicker]') );
		$('div#' + bizFormId + ' input[monthpicker]').detach().appendTo( monthpickerWrapper );

		$('div#' + bizFormId + ' input[monthpicker]').MonthPicker({ Button : function( opts){
			return '<button type="button" class="btn btn-ico _datePicker" aria-label="calendar"><span class="ico ico-calendar" aria-hidden="true"></span></button>';
		}, MonthFormat : "yy-mm" });
		*/
		$('div#' + bizFormId + ' input[monthpicker]').MonthPicker({
			Button : false,
			MonthFormat : "yy-mm",
			OnBeforeMenuOpen : function(event){
				// 201.07.11. forain. Popup에서 Popup이 open 된 경우 BIMATRIX 처리 안함.
				if(LayoutManager.getPopups() && LayoutManager.getPopups().size() == 0) {
					LayoutManager.toggleIframeOnActiveTab(false);
				}
			},
			OnAfterMenuClose : function(event){
				// 201.07.11. forain. Popup에서 Popup이 open 된 경우 BIMATRIX 처리 안함.
				if(LayoutManager.getPopups() && LayoutManager.getPopups().size() == 0) {
					LayoutManager.toggleIframeOnActiveTab(true);
				}
			}});

		// 8. 모든 select 에 대해서, form-control 클래스를 추가하기
		$('div#' + bizFormId + ' select').addClass("form-control");

		// 9. 화면 입력포맷 설정 : Cleave.js
		// 숫자포맷
		container.find('[data-numeral]').each(function(i, el) {
			$(el).addClass("text-right");
			/*
			if( nvl( $(el).val() ) == "" ) {
				$(el).val(0);
			}
			*/
			// Format -> "PREC:5"
			var numeral = $(el).data("numeral");
			var precision = 0;

			if (numeral == undefined) {
				precision = 0;
			} else {
				var type = numeral.split(":")[0];
				if (type == "PREC") {
					precision = Number(numeral.split(":")[1]);
				}
			}

			var cleaveNumeral = new Cleave(el, {
				numeral : true,
				numeralDecimalScale : precision,
				numeralThousandsGroupStyle : 'thousand'
			});
			$(el).data("_cleave_", cleaveNumeral);
		});

		// 통화포맷
		container.find('[data-currency]').each(function(i, el) {
			// Format -> "USD:EXT" 또는 "USD"
			var currency = $(el).data("currency");
			var precision = 0;

			if (currency.indexOf(":") > 0) {
				precision = _getPrecision(currency.split(":")[0], "EXT");
			} else {
				precision = _getPrecision(currency);
			}
			var cleaveCurrency = new Cleave(el, {
				numeral : true,
				numeralDecimalScale : precision,
				numeralThousandsGroupStyle : 'thousand'
			});
			$(el).data("_cleave_", cleaveCurrency);
		});

		// 년-월 포맷
		container.find('[data-yearmonth]').each(function(i, el) {
			var cleaveDate = new Cleave(el, {
				delimiter : '-',
				date : true,
				datePattern : [ 'Y', 'm' ]
			});
			$(el).data("_cleave_", cleaveDate);
		});

		// 날짜포맷
		container.find('[data-date]').each(function(i, el) {
			// LOCALE_INFO.dateFormat
			var datePatterm = [ 'Y', 'm', 'd' ];
			var delemeter = "-";
			var cleaveDate = new Cleave(el, {
				delimiter : delemeter,
				date : true,
				datePattern : datePatterm
			});
			$(el).data("_cleave_", cleaveDate);
		});

		// 전화번호 포맷
		container.find('[data-phone]').each(function(i, el) {
			var cleavePhone = new Cleave(el, {
				phone : true,
				delimiter : '-',
				phoneRegionCode : 'KR'
			});
			$(el).data("_cleave_", cleavePhone);
		});

		// 날짜포맷
		container.find('[data-datetime]').each(function(i, el) {
			var datetime = new Cleave(el, {
				delimiter : [ '-', '-', ' ', ':' ],
				blocks : [ 4, 2, 2, 2, 2 ]
			});
			$(el).data("_cleave_", datetime);
		});

		//Keyword로 지정된 항목일 경우, 이 항목에 적힌 키 값을 저장해 둔다
		$('div#' + bizFormId + ' [keyword]:input').each(function( event ) {
			var element = this;

			//keyword list 표출용 Panel
			var plate = $("#_keyword_items_plate_");
			if( !$("#_keyword_items_plate_").exists() ) {
				plate = $("<div id='_keyword_items_plate_'><ul><ul></div>");
				$("body").append( plate );

				$(element).on( "click", function(){
					$("#_keyword_items_plate_").offset({top: 0, left : 0 }).hide();
				});

				$(plate).on("click", "li" ,function( event ){
					$(element).val( $(event.target).text() );
					$("#_keyword_items_plate_").offset({top: 0, left : 0 }).hide();
				});

			} else {
				plate.offset({top: 0, left : 0 })
			}

			var labelForThis = $("div#" + bizFormId + " label[keyword]")
			$("<i class='fa fa-key' aria-hidden='true' style='color:#CE4844; font-size:12px;margin-right:2px;margin-top:2px;'></i>").insertBefore( labelForThis );

			$(element).on("keyup", function( event ){
				var keyCode = event.keyCode ? event.keyCode : event.which;
				//Space Bar
				if( keyCode == 32 ) {
					$(element).val("");
					
					if( $(element).parent().hasClass("input-group") ) {
						$(plate).css({"min-width" : $(element).parent().outerWidth() });
					} else {
						$(plate).css({"min-width" : $(element).outerWidth() });
					}
					
					$(plate).offset( { "top" : $(element).offset().top + $(element).outerHeight() + 1 , "left" : $(element).offset().left });
					buildKeywordItemsList( $(element).attr("keyword").replaceAll("O:", "") );
				}
			});
		});

		function buildKeywordItemsList( keyword ){
			var holder = $("#_keyword_items_plate_").find("ul");
			transaction( "lgcom", "common/uiCommon/retrieveKeywordList", { keyword : keyword }, function( data ){
				holder.empty();
				var list = data["result"];
				$(list).each(function() {
					holder.append( $( "<li>" + this["content"] + "</li>" ) );
				});

				if( list != undefined && list.length > 0 ) {
					$("#_keyword_items_plate_").show();
				}
			});
		}
	}

	this.applyFormatManually = function( selector ) {
		var container = $('div#' + bizFormId + ' ' + selector );
		container.find('[data-numeral]').each(function(i, el) {
			try {
				$(el).data("_cleave_").destroy();
			} catch( e ) {}

			// Format -> "PREC:5"
			var numeral = $(el).data("numeral");
			var precision = 0;

			if (numeral == undefined) {
				precision = 0;
			} else {
				var type = numeral.split(":")[0];

				if (type == "PREC") {
					precision = Number(numeral.split(":")[1]);
				}
			}

			//해당 엘리먼트에 있는 값을 미리 확보한다.
			var value = $(el).val();
			var cleaveNumeral = new Cleave(el, {
				numeral : true,
				numeralDecimalScale : precision,
				numeralThousandsGroupStyle : 'thousand'
			});

			//Cleave 객체가 제정비 되고 나서, 해당 값을 다시 정밀도에 맞게 조정하여 Assign 한다.
			if( value != 0 ) {
				value = Number( value ).toFixed(precision);
				$(el).val( value + "" );
			} else {
				if( precision == 0 ) {
					$(el).val( "0" );
				} else {
					$(el).val( "0.".rpad( "0", precision ) );
				}
			}
			$(el).data("_cleave_", cleaveNumeral);
		});

		// 통화포맷
		container.find('[data-currency]').each(function(i, el) {
			try {
				$(el).data("_cleave_").destroy();
			} catch( e ) {}

			// Format -> "USD:EXT" 또는 "USD"
			var currency = $(el).data("currency");
			var precision = 0;
			if (currency.indexOf(":") > 0) {
				precision = _getPrecision(currency.split(":")[0], "EXT");
			} else {
				precision = _getPrecision(currency);
			}

			var cleaveCurrency = new Cleave(el, {
				numeral : true,
				numeralDecimalScale : precision,
				numeralThousandsGroupStyle : 'thousand'
			});
			$(el).data("_cleave_", cleaveCurrency);
		});

		// 년-월 포맷
		container.find('[data-yearmonth]').each(function(i, el) {
			try {
				$(el).data("_cleave_").destroy();
			} catch( e ) {}

			var cleaveDate = new Cleave(el, {
				delimiter : '-',
				date : true,
				datePattern : [ 'Y', 'm' ]
			});
			$(el).data("_cleave_", cleaveDate);
		});

		// 날짜포맷
		container.find('[data-date]').each(function(i, el) {
			try {
				$(el).data("_cleave_").destroy();
			} catch( e ) {}

			// LOCALE_INFO.dateFormat
			var datePatterm = [ 'Y', 'm', 'd' ];
			var delemeter = "-";

			var cleaveDate = new Cleave(el, {
				delimiter : delemeter,
				date : true,
				datePattern : datePatterm
			});
			$(el).data("_cleave_", cleaveDate);
		});

		// 전화번호 포맷
		container.find('[data-phone]').each(function(i, el) {
			try {
				$(el).data("_cleave_").destroy();
			} catch( e ) {}

			var cleavePhone = new Cleave(el, {
				phone : true,
				delimiter : '-',
				phoneRegionCode : 'KR'
			});
			$(el).data("_cleave_", cleavePhone);
		});

		// 날짜포맷
		container.find('[data-datetime]').each(function(i, el) {
			try {
				$(el).data("_cleave_").destroy();
			} catch( e ) {}

			var datetime = new Cleave(el, {
				delimiter : [ '-', '-', ' ', ':' ],
				blocks : [ 4, 2, 2, 2, 2 ]
			});
			$(el).data("_cleave_", datetime);
		});
	}

	/* BizForm 공통 이벤트 */
	this.addEvent( "click", ".searchBlock .partFoldingBtn, .searchBlock .partFoldingBtn i", function(event) {
		var item = $(event.target);
		if (!item.hasClass("partFoldingBtn")) {
			item = item.parent();
		}

		var searchBlock = $(item).closest(".searchBlock");
		var gap = 0;
		// 연장한다.
		if ( $(item).data("status") == "CLOSED") {
			gap = searchBlock.height();
			
			searchBlock.find("tbody tr:gt(1)").slideDown( 0, function() {
				item.find(".fa").removeClass("fa-plus").addClass("fa-minus");
				if( managedLayout["_manage_"] ) {
					$.each( managedLayout, function(key, value) {
						if (key != "searchBlock") {
							if (value["top"] != undefined) {
								container.find("."+ key).css( "top", value["top"]+ ( searchBlock.height() - gap )  + "px" );
							}
						}
					});
					
					$(gridList).each(function() {
						this.resetSize();
					});
				}
			});

			$(item).data("status", "OPEN");
		} else { // 축소한다.
			searchBlock.find("tbody tr:gt(1)").slideUp( 0, function() {
				item.find(".fa").removeClass("fa-minus").addClass("fa-plus");
				if( managedLayout["_manage_"] ) {
					$.each( managedLayout, function(key, value) {
						if (key != "searchBlock") {
							if (value["top"] != undefined) {
								container.find("."+ key).css( "top", value["top"] + "px" );
							}
						}
					});
					
					$(gridList).each(function() {
						this.resetSize();
					});
				}
			});
/*
			$.each(managedLayout, function(key, value) {
				if (key != "searchBlock") {
					if (value["top"] != undefined) {
						container.find("." + key).css("top", value["top"]);
					}
				}
			});
			*/

			$(gridList).each(function() {
				this.resetSize();
			});
			$(item).data("status", "CLOSED");
		}
		event.stopPropagation();
	});

	/************* 조회 조건 저장기능 Start *************/
	// 조회 조건 저장을 위한 form flag
	var searchConditionFlag = false;
	var searchCondition;
	var searchConditionTargetForm;

	this.saveSearchCondition = function(){
		var programId = LayoutManager.getMenuItem(bizFormId)["programId"];
		searchCondition = { programId : programId, elements : [] };
		var values = searchConditionTargetForm.getValue();
		$.each( values, function( key, value){
			var item = {
				programId : programId,
				elementName : key,
				tagName : $("div#" + bizFormId + " .searchBlock [name='"+key+"']")[0].tagName,
				value : ( typeof value == "object")?JSON.stringify(value):value
			};
			searchCondition.elements.push(item);
		} );
		
		transaction( "lgcom", "common/uiCommon/insertSearchCondition", searchCondition, function(data) {
			Message.notify("Search condition saved !");
		});
	}
	
	this.deleteSearchCondition = function(){
		var programId = LayoutManager.getMenuItem(bizFormId)["programId"];
		var parameter = { programId : programId };

		transaction( "lgcom", "common/uiCommon/deleteSearchCondition", parameter, function(data) {
			Message.notify("Search condition deleted !");
		});
	}
	
	this.searchConditionControl = function(flag) {
		searchConditionFlag = flag;
		searchConditionTargetForm = new FormUtil( this, ".searchBlock form");
	    getSearchCondition();
	}

	function getSearchCondition() {
		var menuItem = LayoutManager.getMenuItem(bizFormId);
		if (menuItem == undefined) {
			return;
		}

		var programId = menuItem["programId"];
		var parameter = {
			programId : programId
		};

		transaction("lgcom", "common/uiCommon/retrieveSearchCondition", parameter, function(data) {
			var result = data["result"];

			if (result != undefined && result.length > 0) {
				container.find( ".searchBlock ._searchControlButton i[data-action=delete]").fadeIn();
			}

			var conditionData = {};
			$.each( result, function( inx ){
				conditionData[this.elementName] = ( nvl(this.value).indexOf("[") == 0 )? eval( nvl(this.value) ) : nvl(this.value);
			});

			searchConditionTargetForm.setValue( conditionData );
		});
	}
	/************* 조회 조건 저장기능 End *************/

	BizForm.getFormId = function() {
		return formId;
	}

	BizForm.getForm = function() {
		return this;
	}

	BizForm.offGridProgress = function() {
		$(gridList).each(function(inx) {
			_this.hideProgress();
		});
	}

	var progressOn = false;

	this.showProgress = function(selector) {
		progressOn = true;
		if( selector != undefined ) {
			if (!container.find(selector + " .spinnerBack").exists()) {
				var contentLoader = $("<div class='spinnerBack'></div><div class='spinner'><span>Loading...</span></div>");
				container.find(selector).append(contentLoader);
			}
			container.find(selector + " .spinnerBack", selector + " .spinner").show();
		} else {
			if ( !container.find(".spinnerBack").exists()) {
				$(container).append( "<div class='spinnerBack'></div><div class='spinner'><span>Loading...</span></div>" );
			}
			$(container).find(".spinnerBack, .spinner").show();
		}
	}

	this.hideProgress = function() {
		container.find(".spinnerBack , .spinner").hide( 0, function(){
			progressOn = false;
		});
	}

	this.toggleSearch = function() {
		// managedLayout 지정돼 있고, 사용하는 상태
		if (managedLayout["_manage_"] == true) {
			// Search 블럭을 펼쳐진 상태에서 닫도록 한다.
			if (managedLayout["_search_toggle_flag_"] == false) {
				managedLayout["_search_ext_height_"] = container.find(".searchBlock").height();

				if( managedLayout["_smFlag_"] ) {
					managedLayout["_search_ext_height_"] += 10;
				} else {
					managedLayout["_search_ext_height_"] += 20;
				}
				
				container.find(".searchBlock").hide();
				$.each( managedLayout, function(key, value) {
					if (key != "searchBlock") {
						if (value["top"] != undefined) {
							container.find("." + key).css( "top", ( container.find("." + key).position().top - managedLayout["_search_ext_height_"] ) + "px");
							managedLayout["_search_toggle_flag_"] = true;
						}
					}
				});
				$("main ._toolBox ._button._toggleSearch").addClass("_toggle");
			} else {
				$.each( managedLayout, function(key, value) {
					if (key != "searchBlock") {
						if (value["top"] != undefined) {
							container.find("." + key).css("top", ( container.find("." + key).position().top + managedLayout["_search_ext_height_"] ) + "px" );
						}
					}
				});

				container.find(".searchBlock").show();
				managedLayout["_search_toggle_flag_"] = false;
			}
		} else { // managedLayout 사용 안하는 상태
			if (managedLayout["_search_toggle_flag_"] == false) {
				container.find(".searchBlock").hide();
				managedLayout["_search_toggle_flag_"] = true;
			} else {
				container.find(".searchBlock").show();
				managedLayout["_search_toggle_flag_"] = false;
			}
		}

		$(gridList).each(function() {
			this.resetSize();
		});
	}
	
	this.getContainer = function(){
		return container;
	}

	/*
	 * 폼 간의 데이터를 주고 받을 수 있는 Data API 1. 폼 간의 데이터를 주고 받을 때에는 초기에 데이터를 set 하는 쪽이
	 * Master가 되고, 이 폼의 programId 가 공유 키가 된다. 2. Slave 폼은 Master 폼의 programId 를
	 * 알아야 데이터 공유를 할 수가 있다. ( 모르면 get 을 할 수가 없음 )
	 */
	this.setData = function(key, value) {
		var programId = LayoutManager.getMenuItem(bizFormId)["programId"];
		var dataHolder = $("main ._contents");
		var data = dataHolder.data(programId);
		if (data == undefined) {
			data = new Map();
			dataHolder.data(programId, data);
		}
		data.put(key, value);
	}

	this.getData = function(programId, dataKey) {
		var dataHolder = $("main ._contents");
		var data = dataHolder.data(programId);
		if (data != undefined) {
			return data.get(dataKey);
		} else {
			return null;
		}
	}

	this.clearData = function(programId) {
		var dataHolder = $("main ._contents");
		if (programId == undefined) {
			programId = LayoutManager.getMenuItem(bizFormId)["programId"];
		}
		dataHolder.removeData(programId);
	}

	/* BizForm 의 Static Methods */
	BizForm.addGrid = function(grid) {
		gridList.push(grid);
	}

	this.popups = new Map();

	this.addPopup = function(popupId, popupObject) {
		this.popups.put(popupId, popupObject);
	}

	this.getPopup = function(popupId) {
		return this.popups.get(popupId);
	}

	this.removePopup = function(popupId) {
		this.popups.remove(popupId);
	}

	this.isDestroyable = function(){
		//화면이 닫힐 때 수행할 close callback
		var destroyable = true;
		try {
			destroyable = closeCallback.call( this );
			if( destroyable == undefined ) {
				destroyable = true;
			}
		} catch( e ) {
			destroyable = true;
		}
		return destroyable;
	}

	this.destroy = function() {
		/**
		 * 2017.04.04. forain 추가
		 * BizForm 닫을시 하위에 IFrame 이 있을 경우 IFrame 에서 생성된 객체를 먼저 초기화 한다.
		 */
		$(container).find('iframe').each(function() {
			var src = parseIframeSource(this);
			if(src.indexOf('/lgcom/container') != -1) {
				var lmng = $(this).get(0).contentWindow.LayoutManager;
				var form = $(this).get(0).contentWindow.BizForm;
				if(lmng != undefined && form != undefined) {
					lmng.closeTab(form.getFormId());
				} else {
					if(form != undefined) {
						form.destroy();
					}
				}
			}
			// IFrame의 src 속성 초기화
			clearIframeSource(this);
		});

		$(gridList).each(function( inx ) {
			this.destroy();
			gridList[inx] = null;
		});
		gridList = null;

		$(editorList).each(function( inx ) {
			this.destroy();
			editorList[inx] = null;
		});
		editorList = null;

		$(crossEditorList).each(function( inx ) {
			this.destroy();
			crossEditorList[inx] = null;
		});
		crossEditorList = null;

		$(innerFormList).each(function( inx ) {
			LayoutManager.removeForm( this.getBizFormId() );
			innerFormList[inx] = null;
		});

		$("#_keyword_items_plate_").offset({top: 0, left : 0 }).hide();
		
		//범용 component List 에서의 destroy 호출 
		$( componentList.values() ).each( function(){
			$(this).each( function(){
				this.destroy();
			});
		});
	}

	var componentList = new Map();
	this.addComponent = function( type, component ) {
		var list;
		
		if( !componentList.containsKey(type) ) {
			list = [];
			componentList.put(type, list);
		} else {
			list = componentList.get(type);
		}
			
		list.push( component );
	}
	
	this.transaction = function( context, action, data, callback, errorCallback ) {
		if ( data == undefined ) {
			data = {};
		}
		data["_programMeta"] = {};

		var menuItem = LayoutManager.getMenuItem(bizFormId);
		data._programMeta["menuId"] = menuItem["menuId"];
		data._programMeta["programId"] = menuItem["programId"];

		_transaction( true, context, action, data, callback, errorCallback );
	}

	this.transaction_sync = function( context, action, data, callback, errorCallback ) {
		if ( data == undefined ) {
			data = {};
		}
		data["_programMeta"] = {};

		var menuItem = LayoutManager.getMenuItem(bizFormId);
		data._programMeta["menuId"] = menuItem["menuId"];
		data._programMeta["programId"] = menuItem["programId"];

		if( progressOn ) {
			setTimeout( function(){
				_transaction( false, context, action, data, callback, errorCallback );
			}, 100 );
		} else {
			_transaction( false, context, action, data, callback, errorCallback );
		}
	}

	this.sendKeyword = function( keyword, name, data ){
		//Keyword 처리
		var searchString = JSON.stringify(data);
		var keywordItems = {};

		var pattern = new RegExp( '"'+ name +'":"\\w*"', 'g' );
		var matchArray = searchString.match( pattern );

		if( matchArray == null || matchArray.length == 0 ) {
			return true; //continue
		}

		keywordItems[keyword] = [];

		$(matchArray).each( function(){
			var value = this.replaceAll("\"","").replaceAll( name + ":", "" );
			if( value != "" ) {
				keywordItems[keyword].push({ keyword : keyword , content : value });
			}
		});


		if( Object.keys(keywordItems).length > 0 ) {
			var param = { keywordItems : keywordItems };
			var url = SERVER_URL + "/lgcom/action/common/uiCommon/saveKeywordList";
			transaction("lgcom", "common/uiCommon/saveKeywordList", param , function( data ) {
			});
		}
	}
	processComponents();
}

// 20181005 nomi add: RealGrid Excel - MultiExport
BizForm.prototype.exportMultiGrid = function (fileName, sheetInfo, exportOption) {
    this.showProgress();

    if (typeof fileName != 'string' && typeof sheet != 'object') {
        if (exportOption) {
            if (typeof exportOption != 'object') bootbox.alert('잘못된 인수 입니다.');
        }
    }
    var that = this;
    var options;
    var defaultOpt = {
        type: "excel",
        target: "local",
        fileName: fileName + ".xlsx",
        compatibility: false,
        indicator: 'hidden',
        done: function () {
            that.hideProgress();
        },
        exportGrids: sheetInfo
    }

    if (exportOption) {
        options = $.extend({}, defaultOpt, exportOption);
    } else {
        options = defaultOpt;
    }

    RealGridJS.exportGrid(options);
}

/************************************************************
 * Chart : 화면의 Chart 를 제공하는 컴포넌트로, 이 클래스는 주로 chart 를 wrapping 하여 화면 크기의 변동에 따른 resize 를 정리하기 위해 사용되었다.
 * 컴포넌트의 자세한정보 : http://www.highcharts.com/
************************************************************/
var Chart = function( form, selector, options ) {
	var formId = BizForm.getFormId();
	var container;
	var formContainer = $("div#" + formId );
	var chart = $("div#" + formId + " " + selector ).highcharts( options );

	this.redraw = function(){
		$("div#" + formId + " " + selector ).highcharts().setSize( null, null );
	}

	this.getChart = function() {
		return chart;
	}

	form.addChart( this );
	return chart;
}

/************************************************************
 * CKEditor Configuration : HTML Editor 클래스
 * 컴포넌트의 자세한정보 : http://docs.ckeditor.com/#!/guide
************************************************************/
var Editor = function( form, selector, options ) {
	var formId = BizForm.getFormId();
	var container = $("div#" + formId + " " + selector );
	var editorId = uuid();
	container.css( {"position": "relative" } );
	container.append("<div id='" + editorId + "' style='position:absolute; top:0px; left:0px; right:0px; bottom:0px;'></div>");

	if( options == undefined ) {
		options = { editable : true, inline : false };
	} else {
		if( options.editable == undefined ) {
			options.editable = true;
		}

		if( options.inline == undefined ) {
			options.inline = false;
		}
	}

	if( options.height != undefined ) {
		container.css({ "height" : options.height });
	}

	options["customConfig"] = '/lgcom/static/js/ckeditor_config.js'
	//options["removePlugins"] = 'resize';
	//options["extraPlugins"] = "uploadwidget,uploadimage";
	//options["skin"] = "bootstrapck";
	//options["forceCustomDomain"] = true;
	options["enterMode"] = CKEDITOR.ENTER_BR;
	options["shiftEnterMode"] = CKEDITOR.ENTER_BR;
	options["on"] = {
		instanceReady : function( evt ) {
			try {
				evt.editor.resetDirty();
				evt.editor.resize("100%", $(container).height());
			} catch( e ) {}
		}
	}

	var editor;
	if( options.inline ) {
		if( options.editable ) {
			$("#" + editorId ).attr("contenteditable", "true");
		} else {
			$("#" + editorId ).attr("contenteditable", "false");
		}
		editor = CKEDITOR.inline( editorId , options );

		if( !options.editable ) {
			editor.on("focus", function(){
				return false;
			});
		}
	} else {
		editor = CKEDITOR.replace( editorId , options );
	}

	this.setReadOnly = function() {
		editor.setReadOnly();
	}

	this.getEditor = function(){
		return editor;
	}

	this.getEditorId = function() {
		return editorId;
	}

	this.getData = function() {
		if( editor ) {
			return editor.getData();
		}
		return null;
	}

	this.getEncodedData = function() {
		if( editor ) {
			return Base64.encode( editor.getData() );
		}

		return null;
	}

	this.getBodyContent = function() {
		if( editor ) {
			var content = editor.getData();
			var bodyTags = content.match(/<\/*body[^>]*>/gim);
			return content.substring(content.indexOf(bodyTags[0])+6,content.indexOf(bodyTags[1])).replace(/[\&nbsp;]/gm,'');
		}
		return null;
	}

	this.setData = function(content) {
		if( editor ) {
			editor.setData(content);
		}
	}

	this.updateElement = function() {
		if( editor ) {
			editor.updateElement();
		}
	}

	this.destroy = function() {
		if( editor ) {
			editor.destroy();
			editor = null;
		}
	}

	this.clear = function(){
		if( editor ) {
			editor.setData("");
		}
	}

	this.resetSize = function() {
		try{
			editor.resize( "100%", $(container).height() );
		} catch(e){

		}
	}

	form.addEditor( this );
}

/************************************************************
 * RealGrid : 화면의 테이블을 대신한 Grid 요소로서 사용하는 컴포넌트
 * 컴포넌트의 자세한정보 : http://doc.realgrid.com/
************************************************************/
try {
    RealGridJS.setTrace(false);

    if( SYSTEM_ENV == "prod") {
	    RealGridJS.setRootContext("/" + CONTEXT_PATH + "/static/ext/realgrid/prod");
    } else {

	    RealGridJS.setRootContext("/" + CONTEXT_PATH + "/static/ext/realgrid/dev");
    }
}catch( e ){
	console.log("Please check include of RealGird.js or RealGrid License! ");
}

var RealGrid = function( arg1, arg2, arg3 ) {
	
	/**
	 * RealGrid의 Selection Mode를 Custom 하기 위한 Mode 상수
	 */
	RealGrid.SELECTION_ROWS = 'rows';
	RealGrid.SELECTION_BLOCK = 'block';
	RealGrid.SELECTION_BLOCKLINE = 'block_line';
	RealGrid.SELECTION_COLUMN = 'columns';

	
	// 모든 그리드에 대해 고유한 문자열을 부여한다.
	var _this = this;
	var gridUniqueId = uuid();
	var formId = BizForm.getFormId();
	var container;
	var formContainer = $("div#" + formId );
	var containerClassName = "";

	var bizForm;
	var containerId;
	var options;
	var filterScrollToBottomFlag = false; //Filter에 의해 ScrollToBottom 이벤트가 먹지 않도록 함 
	
	if( typeof arg1 == "string" ) {
		containerId = arg1;
		options = arg2;
	} else {
		bizForm = arg1;
		containerId = arg2;
		options = arg3;
		bizForm["GRID_" + gridUniqueId] = this;
	}

	//그리드 Container 에 class와 css를 동시에 사용가능하도록 정리 하였다.
	if (containerId.substr(0, 1) == ".") {
		container = $("div#" + formId + " " + containerId);
		containerClassName = containerId.replaceAll(".", "");
	} else {
		container = $("#" + containerId);
		containerClassName = container.attr("class").replaceAll("grid", "").trim();
	}

	if( options == undefined ) {
		options = { gridType : "normal", statusBar : "Y", gridControl : true, fitToRowCount : false, fitMaxRows : 20 };
	} else if( options == true ) {
		options = { gridType : "normal", statusBar : "Y", gridControl : true, fitToRowCount : false, fitMaxRows : 20 };
	} else {
		if( typeof options == "string" ) {
			options = { gridType : options };
		}
		if( !options.statusBar ) {
			options.statusBar = "Y";
		}
		if( options.gridType == "treeview") {
			options.statusBar = "N";
		}
		if( options.gridControl == undefined ) {
			options.gridControl = true;
		}
		if( options.fitToRowCount == undefined ) {
			options.fitToRowCount = false;
		}
		if( options.fitMaxRows == undefined ) {
			options.fitMaxRows = 20;
		}
	}

	// Grid 의 scroll parameter를 조절하여, 클라우드에서의 성능을 높이기 위한 설정
	// Merged Row Grouping 또는 Cell Merging상태에서 셀 편집시 편집중인 행의 분리 여부를 지정 옵션 추가
	// Merged Cell에서 개별 cell 영역 표시 여부를 지정 옵션 추가
	var displayOption = { liveScroll : false, horizLiveScroll : false, scrollDuration : 150, hscrollDuration : 150, editItemMerging: true, showInnerFocus: false, rowFocusVisible: false, rowFocusBackground: '#3088e6e6', rowFocusMask: 'fill' };

	// 행 편집 완료 요청 시 실제 변경된 셀이 하나라도 있어야 완료된다.
	// 셀 편집 완료 요청 시 실제 변경 값이 있어야 완료된다.
	var editOption = {editable: true, checkDiff: true, checkCellDiff: true };

	var pasteOption = {checkReadOnly: true};

	// RealGrid 용 이미지 라이브러리 추가
	var imgs = new RealGridJS.ImageList("images", "/" + CONTEXT_PATH + "/static/img/realgrid/");
	//20160907 수정
	imgs.addUrls([
		"icon_empty.png",
		"icon_attachment.png", //디스켓 아이콘
		"icon_popup.png", //돋보기 아이콘
		"icon_trash.png", //휴지통 아이콘
		"icon_attachment2.png", //파일첨부 아이콘
		"icon_fileDown.png", //다운로드 아이콘
		"icon_file_attachment.png", //클립아이콘
		"icon_key.png", //열쇠아이콘
		"ico_plus.png", //팝업용 plus 아이콘
		"ico_plus_02.png", //plus 아이콘
		"ico_minus.png", //팝업용 minus 아이콘
		"ico_minus_02.png", //minus 아이콘
		"ico_human.png", //사람 아이콘
		"ico_open.png" //Detail open 아이콘
	]);

	// 이 객체를 에 등록한다.
	BizForm.addGrid(this);

	this.getId = function() {
		return gridUniqueId;
	}

	/* 페이지 설정 부분 (상수) */
	var pageConstants = {
		targetRow : 1,
		rowSize : 200
	};
	/* 페이지 설정 부분 (변수) : 매 트랜잭션의 파라미터로 추가로 보내야 하는 부분 */
	var pageParameter = {
		pageMode : false,
		pagingType : "scroll"
	};
	var statusBar;
	var defaultRowHeight = 30;
	var defaultHeaderHeight = 30;
	
	if( $("body").hasClass("page-sm") ){
		defaultRowHeight = 24;
		defaultHeaderHeight = 24;
	}

	//이 그리드가 팝업 안에서 초기화 됐는지 확인 하는 표지 : 이 변수는 addPagingBar 안에서 초기화 됨에 주의할 것 !!
	var gridInPopup = false;
	addPagingBar(gridUniqueId );

	var useProgress = true;

	var gridMain;
	var dataProvider;
	var gridCreateType;
	
	if ( options.gridType == "treeview") {
		gridMain = new RealGridJS.TreeView(gridUniqueId);
		dataProvider = new RealGridJS.LocalTreeDataProvider();
		gridCreateType = options.gridType;
	} else {
		gridMain = new RealGridJS.GridView(gridUniqueId);
		dataProvider = new RealGridJS.LocalDataProvider();
		gridCreateType = options.gridType;
	}

	fitContainerWithSiblings();
	
	gridMain.resetSize();

	//Image 라이브러리를 추가함
	gridMain.registerImageList(imgs);

	//Grid display Option 설정
	gridMain.setDisplayOptions( displayOption );

	//Grid edit Option 설정
	gridMain.setEditOptions( editOption );

	//Grid editor Option 설정
	var editorOptions = {
			useCssStyleDropDownList: true,
			useCssStyleDatePicker: false,
			useCssStylePopupMenu: true
		};
	
	if( SESSION_USER.languageCode != "ko" ) {
		editorOptions["yearDisplayFormat"] = "{Y} Year";
		editorOptions["monthDisplayFormat"] = "{M}" ;
		editorOptions["months"] =  ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];  
		editorOptions["weekDays"] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] ;
	}
	
	gridMain.setEditorOptions( editorOptions );
	
	//Cell readOnly 일 경우 Paste 불가
	gridMain.setPasteOptions( pasteOption );
	
	
	//Default 로 Selection Mode 를 block_line 으로 설정하는 부분이다.
	{
		gridMain.setDisplayOptions({ "rowFocusVisible" : true });
		gridMain.setSelectOptions({ "style" : "block" });
		toggleItem( 'selection_blockline' );
	}
	

	// fetchAll 의 진행을 결정하는 Flag
	var fetchAllFlag = false;

	$(window).on("keyup." + gridUniqueId , function(event) {
		if (event.keyCode == 27) {
			Message.notify(Message.FETCH_ALL_OPERATION_CANCELED);
			fetchAllFlag = false;
		}
	});

	// 데이터소스를 지정한다.
	gridMain.setDataSource(dataProvider);
	setStyle();
 
	var loaded = false;
	
	/* 이 그리드에 이벤트 핸들러를 부착한다. */
	this.addEvent = function( eventName, eventHandler ) {
		gridMain[eventName] = eventHandler;
	} 

	this.fitContainerHeight = function(){
		fitContainerHeightByRowCount();
	}

	this.insertRow = function(){
		if(gridMain.getCurrent().itemIndex < 0) {
			gridMain.beginAppendRow();
		} else {
			gridMain.beginInsertRow(gridMain.getCurrent().itemIndex);
		}
		if( options.fitToRowCount ) {
			fitContainerHeightByRowCount();
		}
	}

	this.deleteRow = function() {
		gridMain.deleteSelection(true);
		if( options.fitToRowCount ) {
			fitContainerHeightByRowCount();
		}
	}

	function fitContainerHeightByRowCount() {
		if( !options.fitToRowCount ) {
			return;
		}

		var headerHight = gridMain.getHeader().height;
		var itemCount = gridMain.getItemCount();

		if( headerHight == 0 ) {
			headerHight = defaultHeaderHeight;
		}

		if( options.fitMaxRows < itemCount ) {
			itemCount = options.fitMaxRows ;
		}

		var targetHeight = 	headerHight + defaultRowHeight * itemCount + 3;
		$( container ).css( { "height" : targetHeight + "px" });

		gridMain.resetSize();
	}
	
	function fitContainerWithSiblings() {
		var height = 0;
		if( container.siblings().length > 0 ) {
			$( container.siblings() ).each( function(){
				height += $(this).outerHeight( true );
			});
		}
		$( container ).css( { "height" : "calc( 100% - " + height + "px )" });
	}

	function addPagingBar(gridUniqueId ) {
		var wrapper;
		statusBar = $("<div class='gridStatusBar' data-id='"+ gridUniqueId +"'><span class='recordCounter'></span><span class='selectionSummary'></span></div>");

		if( options.statusBar == "Y" ) {
			wrapper = $("<div id='" + gridUniqueId + "' class='_grid_wrapper_' style='width:100%; height:calc( 100% - 20px );'></div>");
			statusBar.show();
		} else {
			wrapper = $("<div id='" + gridUniqueId + "' class='_grid_wrapper_' style='width:100%; height:100%;'></div>");
			statusBar.hide();
		}
		container.append(wrapper);

		//Wrapper 가 Container 에 들어와 있어야, 이것이 팝업의 구성품인지 알 수 있기 때문에, 이곳에서 gridInPopup 변수가 초기화 된다.
		gridInPopup = $("div#" + gridUniqueId ).closest("._popupBody").exists();

		if( !gridInPopup ) {
			/* <div class='btn-group dropup configButton' style='position:absolute; right:0px;'> */
			statusBar.append( "<div class='btn-group dropup configButton'>"+
			                  "<button class='btn btn-default btn-xs dropdown-toggle' type='button' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'><i class='fa fa-cog' aria-hidden='true'></i></button>" +
			                  "<ul class='dropdown-menu dropdown-menu-right'> "+
			                  "<li><a href='#' data-action='saveconfig'>Save grid config</a></li>"+
			                  "<li><a href='#' data-action='deleteconfig'>Delete grid config</a></li>"+
			                  "</ul></div>");
		}

		container.append(statusBar);

		$("#"+ formId ).on( "click."+ formId, ".gridStatusBar[data-id='"+ gridUniqueId +"'] .configButton [data-action]", function( event ) {
			var action = $(event.target).data("action");
			switch( action ) {
				case "saveconfig" :
					saveGridUserConfig();
					break;
				case "deleteconfig" :
					deleteGridUserConfig();
					break;
			}
			event.preventDefault();
		});

		if( !options.gridControl ) {
			statusBar.find(".configButton").hide();
		}
	}

	function refreshStatusBar() {
		if( dataProvider == null ) {
			return;
		}
		var text = Number(dataProvider.getRowCount() + "").toLocaleString("kr") + " rows retrieved in " + Number(pageParameter.rows + "").toLocaleString("kr") + " rows.";
		$(statusBar).find(".recordCounter").text(text);
		$(statusBar).find(".recordCounter").attr('title',text);
		$(statusBar).find(".selectionSummary").text('');
		$(statusBar).find(".selectionSummary").removeAttr('title');
	}

	function findColumnVisibleIndex(column) {
		function includeColumn(colGroup, colName) {
			if (colGroup.columns.indexOf(colName) >= 0) {
				return true;
			}

			for (var i = 0, size = colGroup.columns.length; i < size; i++) {
				if (typeof colGroup.columns[i] === "object") {
					if (includeColumn(colGroup.columns[i], colName)) {
						return true;
					}
				}
			}
			return false;
		}
		var vCols = gridMain.getDisplayColumns();

		if (vCols.indexOf(column) >= 0) {
			return vCols.indexOf(column);
		}

		for (var i = 0, size = vCols.length; i < size; i++) {
			if (typeof vCols[i] === "object") {
				if (includeColumn(vCols[i], column)) {
					return i;
				}
			}
		}
	}

	
	gridMain.onColumnPropertyChanged = function (grid, column, property, value) {
		$(statusBar).find(".selectionSummary").text(" [ column '" + column.name + "' "+ property + " : " + value + " ]");
		setTimeout( function(){
			 $(statusBar).find(".selectionSummary").text("");
		}, 5000 );
	}
	
	/**
	 * 그리드 Cell 선택시 선택된 영역의 Row 수, 합계, 평균을 산출한다.
	 * 2017.03.27. forain 추가
	 */
	gridMain.onSelectionAdded = function( cgrid, selection ) {
		// Cell 선택모드가 Block 일 경우에만 동작
		var option = cgrid.getSelectOptions();
		if($.trim(option['style']) == 'block' || $.trim(option['style']) == 'columns') {
			if ( !selection ) {
				return;
			}
			// Summary 값 초기화
			$(statusBar).find(".selectionSummary").text('');
			$(statusBar).find(".selectionSummary").removeAttr('title');
		}
	};

	gridMain.onSelectionEnded = function( cgrid ) {
		// Cell 선택모드가 Block 일 경우에만 동작
		var option = cgrid.getSelectOptions();
		if($.trim(option['style']) == 'block' || $.trim(option['style']) == 'columns') {
			var selection = cgrid.getSelection();
			var seldata;
			try { seldata = cgrid.getSelectionData(); } catch(e) { trace(e); }
			if ( !selection ) {
				return;
			}
			// 선택된 행이 1 Cell 이면 선택된 값 초기화
			if((selection['startItem'] == selection['endItem']) && (selection['startColumn'] == selection['endColumn'])) {
				// Summary 값 초기화
				$(statusBar).find(".selectionSummary").text('');
				$(statusBar).find(".selectionSummary").removeAttr('title');
				return;
			}
			var cellCount = 0, cellSum = 0, cellAvg = 0, cellAvgCnt = 0;
			$(seldata).each(function() {
				var item = this;
				$.each(this, function(key,val) {
					cellCount++;
					if($.isNumeric(val)) {
						cellSum += (val - 0);
						cellAvgCnt++;
					}
				});
			});
			// 합계가 0이고 숫자필드 개수가 0이면 문자만 선택
			if(cellSum == 0 && cellAvgCnt == 0) {
				$(statusBar).find(".selectionSummary").text(Message.TRAY_CNT_LABEL + ' : ' + cellCount);
				$(statusBar).find(".selectionSummary").attr('title',Message.TRAY_CNT_LABEL + ' : ' + cellCount);
			} else {
				var summary = '';
				summary += Message.TRAY_CNT_LABEL + ' : ' + cellCount + ', ';				// 건수
				summary += Message.TRAY_SUM_LABEL + ' : ' + cellSum + ', ';				// 합계
				summary += Message.TRAY_AVG_LABEL + ' : ' + (cellSum/cellAvgCnt) + ' ';		// 평균
				$(statusBar).find(".selectionSummary").text(summary);
				$(statusBar).find(".selectionSummary").attr('title',summary);
			}
		}
	};

	// 그리드 스크롤이 맨 마지막에 도달하면, append 를 호출한다. ( 단 page 모드일 때만 적용함 )
	gridMain.onScrollToBottom = function(grid) {
		if( dataProvider == null ) {
			return;
		}		
		// 2017.07.25. forain. Fetch All 진행중이면 조회하지 않는다.
		if( fetchAllFlag ) {
			return;
		}
		
		//2018.10.10 sskeun. Filter를 적용시 ScrollToBottom Event가 적용되지 않도록 함.
		if(filterScrollToBottomFlag){
			return;
		}
		
		if( loaded && dataProvider.getRowCount() > 0) {
			// 2017.07.25. forain. 현재 페이지가 마지막 페이지인지 체크해서 마지막 페이지라면 종료
			if(Math.ceil(pageParameter['lastRow'] / pageConstants['rowSize']) < pageParameter['pages']) {
				appendData();
			}
		}
	}

	/*
	gridMain.onCurrentRowChanged = function(grid, oldRow, newRow) {
		if( fetchAllFlag ) {
			return;
		}

		if( dataProvider == null ) {
			return;
		}

		if (dataProvider.getRowCount() - pageConstants.rowSize * 0.8 <= 0) {
			return;
		}

		if (newRow >= (dataProvider.getRowCount() - pageConstants.rowSize * 0.8) && !window.startAjaxSendData) {
			fetchAllFlag = true;
			appendData();
		}
	}
	*/

    // 20181004 nomi : 리얼그리드(1.1.29) 정렬 순서 적용
	// sorting이미지 변경
	gridMain.setSortingOptions({
		handleColor : "#1bcbb7",
		handleNoneColor : "#1bcbb7",
		handleBorderColor : "#1bcbb7",
		hoveredHandleColor : "#1bcbb7",
		hoveredHandleNoneColor : "#1bcbb7",
        showSortOrder: true,
        sortOrderStyles: {
            font: "굴림체",
            fontSize: 10,
            fontBold: true,
            foreground: "#f34d78",
            textAlignment: "far"
        }
	// imageHandle: true, 이미지로 지정
	/*
	 * handleImages:{ ascending: "/scripts/assets/down.png",
	 * //hoveredNone:"/scripts/assets/down.png", hoveredAscending:
	 * "/scripts/assets/down.png", hoveredDescending: "/scripts/assets/up.png",
	 * descending: "/scripts/assets/up.png", //none: "/scripts/assets/down.png" }
	 */
	})

	/**
	 * Grid 의 컬럼폭이 데이터에 의해서 자동으로 조절되도록 하는 설정을 추가하는 부분
	 * http://help.realgrid.com/api/GridBase/fitColumnWidth/
	 *
	 * 2016.05.26 jhlee 추가 [ { column : userName, maxWidth : 0, minWidth : 0,
	 * visibleOnly : false } , ..... ]
	 */
	this.setFitColumnWidth = function(fitColumnInfo) {
		if (fitColumnInf == undefined) {
			gridMain.fitColumnWidth(null, 0, 0, false);
		} else {
			$(fitColumnInfo).each( function() {
				if (fitColumnInfo.maxWidth == undefined)
					fitColumnInfo.maxWidth = 0;

				if (fitColumnInfo.minWidth == undefined)
					fitColumnInfo.minWidth = 0;

				if (fitColumnInfo.visibleOnly == undefined)
					fitColumnInfo.visibleOnly = false;

				gridMain.fitColumnWidth(fitColumnInfo.column, fitColumnInfo.maxWidth, fitColumnInfo.minWidth, fitColumnInfo.visibleOnly);
			});
		}
	}

	this.clear = function(){
		dataProvider.clearRows();
		$(statusBar).find(".recordCounter").text('');
		$(statusBar).find(".recordCounter").removeAttr('title');
		$(statusBar).find(".selectionSummary").text('');
		$(statusBar).find(".selectionSummary").removeAttr('title');
	}

	this.setPagingMode = function(flag, pagingOption) {
		pageParameter.pageMode = flag;
		if (pagingOption != undefined) {
			if (pagingOption.rowSize) {
				// 2017.06.14. forain. 삭제. 페이지 사이즈가 1000 건 이상이어도 1000 건으로 제약한다.(?)
				// 3000 건으로 제약하기로 sskeun 협의후 결정
				if (pagingOption.rowSize > 3000) {
					pagingOption.rowSize = 3000;
				}
				pageConstants.rowSize = pagingOption.rowSize;
			}
		}

	}

	this.resetSize = function() {
		gridMain.resetSize();
	}

	//마우스로 그리드 wrapper 높이를 조절한다.
	this.resizableGrid = function(min) {
		container.resizable({
			handles: "s",
			minHeight: min ? min : 150,
			resize: function( event, ui ) {
				gridMain.resetSize();
			}
		});
	}

	/* 이 컴포넌트의 여러 요소를 Clear 하고 객체를 정리 한다. */
	this.destroy = function() {
		fetchAllFlag = false;
		gridMain.cancel();

		try {
			gridMain.destroy();
			dataProvider.destroy();
		} catch(e) {
			trace("[DEBUG] gridMain.destroy() Method is not defined!" );
		}

		gridMain = null;
		dataProvider = null;
		formContainer = null;
		container = null;

		$(window).off("." + gridUniqueId);
		//trace("[SYSTEM] window event removed for " + gridUniqueId);
	}

	/**
	 * Grid 변경 데이터의 갯수를 모아서, 변경여부를 체크하여 리턴한다. 2016.06.21 jhlee 추가
	 */
	this.isChanged = function() {
		if (dataProvider.getStateRows('created').length + dataProvider.getStateRows('updated').length + dataProvider.getStateRows('deleted').length > 0) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Grid 이벤트 처리를 위해서 Grid Base 객체를 반환한다. 2016.05.23 csseo 추가
	 */
	this.getGridBase = function() {
		return gridMain;
	}


	this.getJsonRow = function( rowIndex ) {
		if( rowIndex == undefined ) {
			rowIndex = gridMain.getCurrent().dataRow;
		}
		if( rowIndex > -1 ) {
			return dataProvider.getJsonRow( rowIndex );
		}
	}

	this.getJsonRows = function( from, to ) {
		if( from  == undefined ) {
			from = 0 ;
		}
		
		if( to  == undefined ) {
			to = -1 ;
		}
		
	    return dataProvider.getJsonRows( from, to );
	}	
	
	this.cancel = function() {
		gridMain.cancel();
	}
	
	this.commit = function() {
		gridMain.commit();
	}
	/**
	 * Grid 이벤트 처리를 위해서 Grid DataProvider 객체를 반환한다. 2016.05.23 csseo 추가
	 */
	this.getDataProvider = function() {
		return dataProvider;
	}

	this.setOptions = function(options) {
		if (options["grid"] != undefined) {
			if (options.grid.edit != undefined && (options.grid.edit.insertable || options.grid.edit.appendable || options.grid.edit.updatable || options.grid.edit.deletable)) {
				options.grid.indicator.visible = true;
			}
			// 그리드의 기본 row height 를 결정한다 : 개발자가 특정하지 않으면, 기본 값으로 들어간다.
			if (options.grid.display == undefined) {
				options.grid.display = {
					rowHeight : defaultRowHeight
				};
			} else {
				if (options.grid.display.rowHeight == undefined) {
					options.grid.display.rowHeight = defaultRowHeight;
				}
			}
			if (options.grid.header == undefined) {
				options.grid.header = {
					height : defaultHeaderHeight
				};
			} else {
				if (options.grid.header.height == undefined) {
					options.grid.header.height = defaultHeaderHeight;
				}
			}
			// 그리드의 기본 선택을 개발자가 특정하지 않으면 Cell 선택이 아니라, Row 선택으로 지정함
			if (options.grid.select == undefined) {
				options.grid.select = {
					style : "rows"
				};
			} else {
				if (options.grid.select.style == undefined) {
					options.grid.select.style = "rows";
				}
			}
			// 그리드 row resizable
			options.grid.display.rowResizable = true;
			gridMain.setOptions(options["grid"]);
		}
		if (options["dataProvider"] != undefined) {
			dataProvider.setOptions(options["dataProvider"]);
		}
		if (options["display"] != undefined) {
			gridMain.setDisplayOptions(options["display"]);
		}
		if (options["fixed"] != undefined) {
			/* Fixed Column */
			var fixedOptions = new RealGridJS.FixedOptions();

			$(options["fixed"]).each(function(key, value) {
				fixedOptions[key] = value;
			});
			gridMain.setFixedOptions(options);
		}
		//treeview가 아닌 경우 자동 sorting 방지
		if(gridCreateType != "treeview"){
			if (options["sortMode"] == undefined) {
			    gridMain.setOptions( {sortMode: "explicit" });
			}
			if (options["filterMode"] == undefined) {
			    gridMain.setOptions( {filterMode: "explicit" });
			}
			//trace(JSON.stringify(gridMain.getOptions()));
		}			
	}

	this.setFields = function(fieldInfo) {
		dataProvider.setFields(fieldInfo);
	}


	var showenCount = 0;
	//개발자가 지정한 Column 목록 ( 헤더의 단이 모두 표시 )
	var columnInfo;
    // columnInfo 에서 가장 아랫단의 실제 컬럼만 모은 목록
    var columnNamesInfo = [];

	this.setColumns = function( colInfo) {
		columnInfo = colInfo;


		//그리드 컬럼의 그룹이 하위 컬럼을 숨기는 옵션을 적용한다.
		$(columnInfo).each( function(){
			if( this["hideChildHeaders"] ) {
				gridMain.setColumnProperty( this["name"], "hideChildHeaders", true );
			}
		});

		getColumnFromColumnName( columnNamesInfo, columnInfo );

		$(columnNamesInfo).each( function(){
			setColumnRequired( this );

			this['visible'] = nvl( this['visible'], true );

			if( this['visible'] ) {
				showenCount++;
			}
		});

		// final setColumns
		gridMain.setColumns(colInfo);
	}

	/* 특정 컬럼의 정의에 Reqired 속성이 있을때, 이것을 RealGrid 의 subText 로 변경하여 치환하는 코드이다.*/
	function setColumnRequired( info ) {
		//단일 컬럼에 대해서
		if( info.required && info.required == true ) {
			info.header.subText = "*";
			info.header.subTextGap = 4;
			info.header.subTextLocation = "left";
			info.header.subStyles = { foreground: "#f34d78", selectedForeground: "#f34d78", fontBold: "true" };
		}

		if( info.name && info.header == undefined ) {
			info.header = { text : info.name };
			delete info.name;
		}

		if( info.header.required && info.header.required == true ) {
			info.header.subText = "*";
			info.header.subTextGap = 4;
			info.header.subTextLocation = "left";
			info.header.subStyles = { foreground: "#f34d78", selectedForeground: "#f34d78", fontBold: "true" };

			delete info.header.required;
		}

		if( info.columns ) {
			$( info.columns ).each( function(){
				setColumnRequired( this );
			});
		}
	}

	this.setLookups = function(lookupInfo, lookups) {
		// lookupInfo 를 json 형태로 가공하였다.
		var data = {};
		if (typeof (lookupInfo) == "object") {
			data = lookupInfo;
		} else if (typeof (lookupInfo) == "string") {
			data[lookupInfo] = lookups;
		}

		// 이 변수가 최종적으로 realGrid 에 할당될 Lookup 정보이다.
		var lookupArr = [];

		$.each(data, function(key, value) {
			var item = { id : key, levels : 1, keys : [], values : [], ordered : true };
			$(value).each(function(inx) {
				item.keys.push(this.code);
				item.values.push(this.name);
			});
			lookupArr.push(item);
		});
		gridMain.setLookups(lookupArr);
	}

	this.setLookupsMultiLvl = function(lookupInfo, lookups) {
		// lookupInfo 를 json 형태로 가공하였다.
		var data = {};
		if (typeof (lookupInfo) == "object") {
			data = lookupInfo;
		} else if (typeof (lookupInfo) == "string") {
			data[lookupInfo] = lookups;
		}
		// 이 변수가 최종적으로 realGrid 에 할당될 Lookup 정보이다.
		var lookupArr = [];
		$.each(data, function(key, value) {
			var item = { id : key, levels : 1, keys : [], values : [], ordered : true };
			if (value.data) {
				if (value.keyField) {
					item.levels = value.keyField.length;
				}
				$(value.data).each(function(inx) {
					if (item.levels == 1) {
						item.keys.push(this.code);
						item.values.push(this.name);
					} else {
						var keyArr = [];
						for (var i = 0; i < item.levels; i++) {
							keyArr[i] = this[value.keyField[i]];
						}
						item.keys.push(keyArr);
						item.values.push(this.name);
					}
				});
			} else {
				item.levels = 1;
				$(value).each(function(inx) {
					item.keys.push(this.code);
					item.values.push(this.name);
				});
			}
			lookupArr.push(item);
		});
		gridMain.setLookups(lookupArr);
	}

	var systemContextMenu = [
		{ label : Message.FREEZE_PANES     , type : 'normal'   , tag : 'fp_on'            , enable : true },
		{ label : Message.UNFREEZE_PANES   , type : 'normal'   , tag : 'fp_off'           , enable : false},
		{ label : Message.MULTI_COL_SORT   , type : 'normal'   , tag : 'inclusive'        , enable : true },
		{ label : Message.HIDE_COLUMN      , type : 'normal'   , tag : 'cv'               , enable : true },
		{ label : Message.SHOW_ALL         , type : 'normal'   , tag : 'show'             , enable : true },
		/**
		 * 2017.04.03. forain. 선택모드 변경
		 */
		{ label : Message.SELECTION_MODE + '&nbsp;▶', type : 'normal', tag : 'selection', enable : true, children : [
			{ label : '<img src="/lgcom/static/img/realgrid/icon_check_off.png" width="16" height="16" border="0"/>&nbsp;'+Message.CELL_ROWS      , type : 'normal', tag : 'selection_rows'     , enable : true },
			{ label : '<img src="/lgcom/static/img/realgrid/icon_check_off.png" width="16" height="16" border="0"\/>&nbsp;'+Message.CELL_BLOCK    , type : 'normal', tag : 'selection_block'    , enable : true },
			{ label : '<img src="/lgcom/static/img/realgrid/icon_check_off.png" width="16" height="16" border="0"\/>&nbsp;'+Message.CELL_BLOCKLINE, type : 'normal', tag : 'selection_blockline', enable : true },
			{ label : '<img src="/lgcom/static/img/realgrid/icon_check_off.png" width="16" height="16" border="0"\/>&nbsp;'+Message.CELL_COLUMNS  , type : 'normal', tag : 'selection_columns'  , enable : true }
		]},
		/**
		 * 2017.03.30. forain. 컬럼 모드 추가
		 * 2017.04.03  forain. 선택모드 변경으로 주석 처리
		 */
		/*
		{ label : Message.CELL_BLOCK       , type : 'normal'   , tag : 'selection_block'  , enable : true },
		{ label : Message.CELL_ROWS        , type : 'normal'   , tag : 'selection_rows'   , enable : false},
		{ label : Message.CELL_COLUMNS     , type : 'normal'   , tag : 'selection_columns', enable : true },
		*/
		{ label : Message.PANEL_ON         , type : 'normal'   , tag : 'panel_on'         , enable : true },
		{ label : Message.PANEL_OFF        , type : 'normal'   , tag : 'panel_off'        , enable : false},
		{ label : Message.COLUMN_FILTER_ON , type : 'normal'   , tag : 'columnfilter_on'  , enable : true },
		{ label : Message.COLUMN_FILTER_OFF, type : 'normal'   , tag : 'columnfilter_off' , enable : false},
		{ label : Message.FILTER_ON        , type : 'normal'   , tag : 'filter_on'        , enable : true },
		{ label : Message.FILTER_OFF       , type : 'normal'   , tag : 'filter_off'       , enable : false},
		{ label : '-'                      , type : 'separator', enable : true  },
		{ label : Message.FIT_TO_DATA      , type : 'normal'   , tag : 'fit_to_data'      , enable : true },
		{ label : Message.EXPORT_EXCEL     , type : 'normal'   , tag : 'export'           , enable : true },
		{ label : Message.EXPORT_EXCEL2    , type : 'normal'   , tag : 'export2'          , enable : true },
        // 20181004 nomi : 리얼그리드(1.1.29) CSV 다운로드 추가
		{ label : Message.EXPORT_CSV       , type : 'normal'   , tag : 'exportToCsv'      , enable : true },
		{ label : '-'                      , type : 'separator', enable : true },
		{ label : Message.FETCH_ALL        , type : 'normal'   , tag : 'fetchall'         , enable : true }
	];

	var contextMenu = [];
	var hideColumnList = new Map();

	/**
	 * RealGrid 에 Context Menu를 세팅한다.
	 * contextMenuInfo - 사용자 정의 Context Menu Array. 형식은 RealGrid의 ContentMenuItem을 따른다.
	 *                   [Bizweb 정의 속성]
	 *                    enable - Context Menu에 표시할 지 여부(true: 표시, false: 미표시)
	 *                    handler - Context Menu를 클릭시 수행할 함수. 인자는 반드시 gridView, label, index 로 구성되어야 한다.
	 * handler         - Context Menu를 클릭시 수행할 사용자 함수. 인자는 반드시 gridView, label, index 로 구성되어야 한다.
	 * replace         - 사용자 정의 Context 메뉴로 대체할지 여부(true: 대체, false: 기본 Context Menu 아래에 추가된다.)
	 */
	var contextHandler;
	this.setContextMenu = function(contextMenuInfo, handler, replace) {
		if(typeof(contextMenuInfo) == 'undefined') contextMenuInfo = [];
		if(typeof(replace) == 'undefined') replace = false;
		contextHandler = handler;
		if(replace) {
			contextMenu = contextMenuInfo;
		} else {
			contextMenu = systemContextMenu;
			// 기본 메뉴에 구분자 추가
			contextMenu.push( { label : '-', type : 'separator' } );
			$(contextMenuInfo).each(function() {
				contextMenu.push(this);
			});
		}
		// 선택 모드의 경우 최초 동기화한다.
		this.setSelectMode($.trim(gridMain.getSelectOptions()['style']));
		refreshContextMenu();
	}

	gridMain.onContextMenuPopup = function (cgrid,xPos,yPos,elementName) {
		//필터가 돼 있는지 확인하기 위한 로직 columnInfo 대신 columnNamesInfo 를 사용한다.
		var filteredCount = 0;
		$(columnNamesInfo).each(function() {
			var visible = true;
			if( this['visible'] ) {
				visible = this['visible'];
			}
			if( visible && this["filtered"]) {
				filteredCount++;
			}
		});
		// 보이는 컬럼이 모두 필터가 되었다면
		if(filteredCount > 0) {
			toggleItem("filter_on");
		} else {
			toggleItem("filter_off");
		}

		// 특정 컬럼에 대하여 컬럼 필터를 확인 하는 부분
		var columnName = cgrid.getCurrent().column;
		var filtered = false;
		$(columnNamesInfo).each(function() {
			if( columnName == this["name"] ) {
				if( this["filtered"] ) {
					filtered = true;
				} else {
					filtered = false;
				}
				return false;
			}
		});
		// filter에 대한 context 메뉴의 on / off 를 지정한다.
		if( filtered ) {
			toggleItem("columnfilter_on");
		} else {
			toggleItem("columnfilter_off");
		}
		// 다시 그린다.
		refreshContextMenu();
	}

	function getCurrentDispSelectMode() {
		var mode = '';
		$(contextMenu).each(function() {
			if($.trim(this.tag) == 'selection') {
				$(this.children).each(function() {
					if($.trim(this.label).indexOf('icon_check_on.png') != -1) {
						mode = $.trim(this.tag);
						return false;
					}
				});
			}
		});
		return mode;
	}

    // 컬럼이 1단 이상으로 구성 돼 있을때, type : "group" 인 항목으로 묶인다.
    // 묶인 가장 아랫단의 실제 컬럼이름만 모아서 따로 array 를 만들어 놓고 사용한다.
    function getColumnFromColumnName(targetArr, columnInfo, groupFlag ) {
        $(columnInfo).each( function() {
            var col = this;
            if( groupFlag ) {
                col["group"] = true;
            }

            if( col["type"] == "group" ||  col["columns"] != undefined ) {

                $(col["columns"]).each( function(){
                    this["parent"] = col["name"];
                });

                getColumnFromColumnName( targetArr, col["columns"], true );
            } else {
                if( col["imageList"] == undefined ) {
                    targetArr.push( this );
                }
            }
        });
    }

	gridMain.onContextMenuItemClicked = function(cgrid, label, index) {
		var menuItem = LayoutManager.getMenuItem( formId );
		var tag = $.trim(label.tag).toLowerCase();
		var provider = cgrid.getDataProvider();

		switch ( tag ) {
			// 필터 on
			case 'filter_on':
				//컬럼 필터가 적용됐다는 정보를 columnInfo 에 지정한다.
				$(columnNamesInfo).each( function() {
                        if(this["visible"]) {
                            var filters = [];
                            var distinctValues = dataProvider.getDistinctValues(this['fieldName']); // 중복제거
                            for(var i = 0; i < distinctValues.length; i++){
                                var tmpFilter = {
                                    name: distinctValues[i],
                                    criteria: "value ="+ "'" + distinctValues[i] + "'"
                                };
                                filters.push(tmpFilter);
                            }
                            cgrid.setColumnFilters(this['name'],filters, true );
						this["filtered"] = true;
                        }
				});
                filterScrollToBottomFlag = true; //filter에 의해 ScrollToBottomFlag가 적용되지 않도록 함
				break;
			// 필터 off
			case 'filter_off':
				$(columnNamesInfo).each( function() {
					if(this["visible"]) {
						cgrid.clearColumnFilters( this['name'] );
						this["filtered"] = false;
                    }
                });
                filterScrollToBottomFlag = false; //filter에 의해 ScrollToBottomFlag가 적용되지 않도록 함
				break;				
			// 컬럼필터 on
			case 'columnfilter_on':
				var filters = [];
				var distinctValues = dataProvider.getDistinctValues(index.fieldName); // 중복제거

				for(var i = 0; i < distinctValues.length; i++){
					var tmpFilter = {
						name: distinctValues[i],
						criteria: "value ="+ "'" + distinctValues[i] + "'"
					};
					filters.push(tmpFilter);
				}
			/*
				var parent = cgrid.columnByName( index.column )["parent"];

				if( cgrid.getColumnProperty( parent, "hideChildHeaders") ) {
					cgrid.setColumnProperty(parent, "hideChildHeaders", false);
				}
				trace( parent );
					*/
				cgrid.setColumnFilters(index.column,filters, true );

				//컬럼 필터가 적용됐다는 정보를 columnInfo 에 지정한다.
				$(columnNamesInfo).each( function(){
					if( index.column == this["name"] ){
						this["filtered"] = true;
						return false;
					}
				});
				filterScrollToBottomFlag = true; //filter에 의해 ScrollToBottomFlag가 적용되지 않도록 함
				break;
			// 컬럼필터 off
			case 'columnfilter_off':
			    var isFilter = false;
				cgrid.clearColumnFilters( index.column );

				var parent = cgrid.columnByName( index.column )["parent"];

				if( !cgrid.getColumnProperty( parent, "hideChildHeaders") ) {
					cgrid.setColumnProperty(parent, "hideChildHeaders", true);
				}

				//컬럼 필터가 적용해제 됐다는 정보를 columnInfo 에 지정한다.
                $(columnNamesInfo).each( function(){
					if( index.column == this["name"] ){
						this["filtered"] = false;
						return false;
					}
				});

				//컬럼 필터가 하나라도 있으면 재조회를 할 수 없다.
                $(columnNamesInfo).each( function(i, el){
                    if (el['filtered'] && el['filtered'] == true) {
                        isFilter = true;
                        return false;
                    }
                });
				if (isFilter) {
                    filterScrollToBottomFlag = true;
                } else {
                    filterScrollToBottomFlag = false;
                }
				break; // Column Fix
			case 'fp_on':
				cgrid.setFixedOptions({ colCount : findColumnVisibleIndex(index.column) , rowCount : index.dataRow });
				toggleItem( tag );
				break;
			// Delete Row
			case 'fp_off':
				cgrid.setFixedOptions({ colCount : 0, rowCount : 0 });
				toggleItem( tag );
				break;
			// SortStyle Inclusive
			case 'inclusive':
				var options = {};
				options.style = RealGridJS.SortStyle.INCLUSIVE;
				cgrid.setSortingOptions(options);
				cgrid.orderBy([], []);
				break;
			// column visible
			case 'cv':
				if (index.column) {
					cgrid.setColumnProperty(index.column, "visible", false);
					hideColumnList.put(index.column, index.column);
				}
				break;
			// Show All
			case 'show':
				//개발자의 설정에 의한 것이 아닌, 사용자가 숨긴 필드들에 대해서 모두 보이기를 수행하는 부분
				//사용자가 컬럼을 숨길 때, hideColumnList 변수에 적어놓은 내용을 모두 풀어놓는 방법을 사용하고 있다.
				$(hideColumnList.keys()).each(function() {
				var column = cgrid.columnByName(this);
				cgrid.setColumnProperty(column, "visible", true);
				});
				hideColumnList.clear();
				break;
			// Selection Rows
			case 'selection_rows':
				cgrid.setDisplayOptions({ "rowFocusVisible" : false });
				cgrid.setSelectOptions({ "style" : "rows" });
				toggleItem( tag );
				break;
			// Selection Block
			case 'selection_block':
				cgrid.setDisplayOptions({ "rowFocusVisible" : false });
				cgrid.setSelectOptions({ "style" : "block" });
				toggleItem( tag );
				break;
			// Selection Line
			case 'selection_blockline':
				cgrid.setDisplayOptions({ "rowFocusVisible" : true });
				cgrid.setSelectOptions({ "style" : "block" });
				toggleItem( tag );
				break;
			// Selection Column
			case 'selection_columns':
				cgrid.setDisplayOptions({ "rowFocusVisible" : false });
				cgrid.setSelectOptions({ "style" : "columns" });
				toggleItem( tag );
				break;
			// On Panel
			case 'panel_on':
				cgrid.setOptions({ panel : { visible : true } });
				toggleItem( tag );
				break;
			// Off Panel
			case 'panel_off':
				cgrid.setOptions({ panel : { visible : false } });
				toggleItem( tag );
				break;
			// Fit To Data
			case 'fit_to_data':
				cgrid.fitColumnWidth (null, 300, 50, true); //Column(Null일 경우 전체 컬럼), MaxWidth, MinWidth, Visible Only
				break;
			// Excel Export
			case 'export':
				setTimeout(function() {
					cgrid.exportGrid({
						type : 'excelx',
						target : 'local',
						fileName : menuItem["name"] + "_" + DateUtil.today("YYYYMMDD_HHmmss") + '.xlsx',
						indicator : 'default',
						header : 'default',
						footer : 'default',
						lookupDisplay : true,
						applyDynamicStyles : true,
						showProgress : true
					});
				}, 100);
				break;
			case 'export2':
				setTimeout(function() {
					cgrid.exportGrid({
						type : 'excelx',
						target : 'local',
						fileName : menuItem["name"] + "_" + DateUtil.today("YYYYMMDD_HHmmss") + '.xlsx',
						indicator : 'default',
						header : 'default',
						footer : 'default',
						lookupDisplay : false,
						showProgress : true
					});
				}, 100);
				break;
            // 20181004 nomi : 리얼그리드(1.1.29) CSV 다운로드 추가
            case 'exporttocsv':
                setTimeout(function() {
                    provider.exportToCsv({
                        target : 'local',
                        fileName : menuItem["name"] + "_" + DateUtil.today("YYYYMMDD_HHmmss") + '.csv',
                        indicator : 'default',
                        header : 'default',
                        footer : 'default',
                        lookupDisplay : false,
                        showProgress : true,
                        includeFieldNames:true
                    });
                }, 100);
                break;
			case "fetchall":
				if( !loaded ) {
					Message.notify("Please search first.");
					return;
				}

				fetchAllFlag = true;

				fetchAll();
				break;
			default:
				if(contextHandler != undefined) {
					contextHandler.call(this, cgrid, label, index);
				} else {
					if(label['handler'] != undefined) {
						label.handler.call(this, cgrid, label, index);
					}
				}
				break;
		}
	}

	function refreshContextMenu() {
		var contextMenuData = new Array();
		$(contextMenu).each( function(){
			if( this.enable ) {
				contextMenuData.push( this );
			}
		});
		gridMain.setContextMenu(contextMenuData);
	}

	//동일한 prefix 로 시작하는 아이템들을 모두 활성화 하고, 같은 이름의 항목을 disable 한다.
	function toggleItem( tag ) {
		var prefix = tag.split("_")[0];
		//on off 설정을 수행한다.
		$(contextMenu).each( function(){
			if( (this.tag + "").indexOf( prefix ) == 0 ) {
				this.enable = true;
			}
			if( (this.tag + "") == tag ) {
				this.enable = false;
			}
			if(prefix == 'selection' && $.trim(this.tag).indexOf( prefix ) > -1) {
				var subMenu = this['children'];
				$(subMenu).each(function() {
					if($.trim(this.tag) == tag) {
						this.label = $.trim(this.label).replace(/(<img src="\/lgcom\/static\/img\/realgrid\/icon_check_off.png" width="16" height="16" border="0"\/>&nbsp;)/g,'<img src="/lgcom/static/img/realgrid/icon_check_on.png" width="16" height="16" border="0"/>&nbsp;');
					} else {
						this.label = $.trim(this.label).replace(/(<img src="\/lgcom\/static\/img\/realgrid\/icon_check_on.png" width="16" height="16" border="0"\/>&nbsp;)+/gi,'<img src="/lgcom/static/img/realgrid/icon_check_off.png" width="16" height="16" border="0"\/>&nbsp;');
					}
				});
			}
		});
		refreshContextMenu();
	}

	this.setValidations = function(validations) {
		gridMain.setValidations(validations);
	}

	/**
	 * 그리드의 사용자 Validation 을 설정한다. // Validation Set grid.setCustomValidations([
	 * {key:'userId', message:'User ID는 필수입력 항목입니다.'}, {key:'roleCode',
	 * message:'Role은 필수입력 항목입니다.', dest_field:'roleName'} ]); 단, GridView의
	 * Column name과 Field 명이 같다는 전재하에 진행한다. 2016.06.24 csseo 추가
	 */
	var customValidations;
	this.setCustomValidations = function(validations) {
		if (typeof (validations) == 'undefined')
			return;
		if (!Array.isArray(validations))
			return;
		customValidations = validations;
	}

	/**
	 * 그리드의 사용자 Validation을 체크하고 결과를 반환한다. 2016.06.24 csseo 추가
	 */
	this.isCustomValidation = function() {
		if (typeof (customValidations) == 'undefined')
			return true;
		var curr = gridMain.getCurrent();
		for (var i = 0; i < gridMain.getItemCount(); i++) {
			var row = gridMain.getValues(i);
			for (var j = 0; j < customValidations.length; j++) {
				if (typeof (row[customValidations[j].key]) == 'undefined' || $.trim(row[customValidations[j].key]) == '') {
					// 메세지가 있다면 메시지 출력
					if (customValidations[j].message) {
						Message.alert(customValidations[j].message);
					}
					// Focus Field 가 존재하면
					if (customValidations[j].dest_field) {
						// 편집가능하다면
						var editable = gridMain.getColumnProperty( customValidations[j].dest_field, 'editable');

						if (editable) {
							var index = {
								itemIndex : i,
								column : customValidations[j].dest_field,
								dataRow : gridMain.getDataRow(i),
								fieldName : customValidations[j].dest_field
							};
							gridMain.setCurrent(index);
							gridMain.showEditor();
						}
					} else {
						var editable = gridMain.getColumnProperty( customValidations[j].key, 'editable');

						if (editable) {
							var index = {
								itemIndex : i,
								column : customValidations[j].key,
								dataRow : gridMain.getDataRow(i),
								fieldName : customValidations[j].key
							};
							gridMain.setCurrent(index);
							gridMain.showEditor();
						}
					}
					return false;
				}
			}
		}
		return true;
	}

	var loadParameter;

	this.loadData = function(context, action, parameter, callback) {
		if( bizForm == undefined ) {
			bizForm = LayoutManager.getForm( formId );
		}
		
		//filter ScrollToBottom 이벤트 먹도록 하고, 재 조회시 filter 제거
        filterScrollToBottomFlag = false;

		$(columnNamesInfo).each( function() {
			if( this["visible"] && this["filtered"] ) {
                gridMain.clearColumnFilters( this['name'] );
                this["filtered"] = false;
            }
        });

		loaded = true;
		loadParameter = parameter;
		/*
		 * 페이지 파라미터 가공부분
		 *
		 * var pageConstants = { targetRow : 1 , rowSize : 10 }; var
		 * pageParameter = {};
		 *
		 */
		if (pageParameter.pageMode) {

			parameter.targetRow = pageConstants.targetRow;
			parameter.rowSize = pageConstants.rowSize;

			showGridProgress();
			if( bizForm == undefined ) {
				transaction(context, action, parameter, function(data) {
					if( dataProvider == null ) {
						return;
					}

					// 최초 조회시 속도를 위해 조회를 2페이지까지 조회한다. 전체 페이지가 1이면 loaded = false 로 바꾼다.
					if(data["result"].pages == 1) {
						loaded = false;
					}

					// 초기 설정으로 서버로 부터 가져온 페이지 메타를 설정한다.
					pageParameter.lastRow = data["result"].lastRow;
					pageParameter.pages = data["result"].pages;
					pageParameter.rows = data["result"].rows;
					pageParameter.targetRow = pageParameter.lastRow + 1; // 중요!!

					// 새로운
					// TargetRow로
					// 바꿔
					// 지정해준다.

					// append 에서 쓰기 위하여, 조회에 필수적으로 필요한 정보를 저장해 둔다.
					pageParameter.context = context;
					pageParameter.action = action;
					pageParameter.parameter = parameter;

					if ( options.gridType == "treeview") {
						dataProvider.fillJsonData(data["result"]["resultList"], {
							rows : "rows"
						});
					} else {
						dataProvider.fillJsonData(data["result"]["resultList"], {
							fillMode : "set"
						});
					}

					try {
						callback.call(this, {
							"result" : data["result"]["resultList"]
						});
					} catch (e) {
					}

					refreshStatusBar();
					hideGridProgress();
				}, function(error) { // error callback
					hideGridProgress();
					Message.alert(error.text);
				});
			} else {
				bizForm.transaction(context, action, parameter, function(data) {
					if( dataProvider == null ) {
						return;
					}

					// 최초 조회시 속도를 위해 조회를 2페이지까지 조회한다. 전체 페이지가 1이면 loaded = false 로 바꾼다.
					if(data["result"].pages == 1) {
						loaded = false;
					}

					// 초기 설정으로 서버로 부터 가져온 페이지 메타를 설정한다.
					pageParameter.lastRow = data["result"].lastRow;
					pageParameter.pages = data["result"].pages;
					pageParameter.rows = data["result"].rows;
					pageParameter.targetRow = pageParameter.lastRow + 1; // 중요!!

					// 새로운
					// TargetRow로
					// 바꿔
					// 지정해준다.

					// append 에서 쓰기 위하여, 조회에 필수적으로 필요한 정보를 저장해 둔다.
					pageParameter.context = context;
					pageParameter.action = action;
					pageParameter.parameter = parameter;

					if ( options.gridType == "treeview") {
						dataProvider.fillJsonData(data["result"]["resultList"], {
							rows : "rows"
						});
					} else {
						dataProvider.fillJsonData(data["result"]["resultList"], {
							fillMode : "set"
						});
					}

					try {
						callback.call(this, {
							"result" : data["result"]["resultList"]
						});
					} catch (e) {
					}

					refreshStatusBar();
					hideGridProgress();
				}, function(error) { // error callback
					hideGridProgress();
					Message.alert(error.text);
				});
			}
		} else {
			parameter.targetRow = 0;
			parameter.rowSize = 1000;

			showGridProgress();

			if( bizForm == undefined ) {
				transaction(context, action, parameter, function(data) {
					if ( options.gridType == "treeview") {
						dataProvider.fillJsonData(data["result"]["resultList"][0], {rows : "rows"} );
					} else {
						dataProvider.fillJsonData(data["result"]["resultList"], { fillMode : "set" });
					}

					try {
						callback.call(this, { "result" : data["result"]["resultList"] });
					} catch (e) { }

					hideGridProgress();
				}, function(error) { // error callback
					hideGridProgress();
					Message.alert(error.text);
				});
			} else {
				bizForm.transaction(context, action, parameter, function(data) {
					if ( options.gridType == "treeview") {
						dataProvider.fillJsonData(data["result"]["resultList"][0], {rows : "rows"} );
					} else {
						dataProvider.fillJsonData(data["result"]["resultList"], { fillMode : "set" });
					}

					try {
						callback.call(this, { "result" : data["result"]["resultList"] });
					} catch (e) { }

					hideGridProgress();
				}, function(error) { // error callback
					hideGridProgress();
					Message.alert(error.text);
				});
			}
		}
		if( gridMain ) {
			gridMain.resetCurrent();
		}
		fitContainerHeightByRowCount();
	}

	/* Grid Body 의 Dynamic Style 을 설정하는 메소드 */
	this.setDynamicStyles = function(dStyles) {
		gridMain.setStyles({ body : { cellDynamicStyles : dStyles } });
	}

	/* 그리드의 스크롤 다운 이벤트에서 수행하는 추가 데이터 붙이기용 함수 */
	function appendData(callback) {
		// 2017.06.14. forain. 추가, callback 함수가 주어지면 fetchAll 함수에서 호출된 거라 판단함.
		if( typeof(callback) == 'function' && fetchAllFlag == false ) {
			return; //이 체크로, 메소드의 단독수행을 보장한다.
		}

		if( bizForm == undefined ) {
			bizForm = LayoutManager.getForm( formId );
		}

		if (!pageParameter.pageMode) {
			trace("[SYSTEM] Page mode is off for current grid.");
			return;
		}

		pageParameter.parameter.targetRow = pageParameter.targetRow;
		pageParameter.parameter.rowSize = pageConstants.rowSize; // 이것은 매번append 할 때마다, 미리 정해진 상수 값을 넣도록 한다.

		showGridProgress();
		if( bizForm == undefined ) {
			transaction(pageParameter.context, pageParameter.action, pageParameter.parameter, function(data) {
				if( dataProvider == null ) {
					return;
				}

				// 초기 설정으로 서버로 부터 가져온 페이지 메타를 설정한다.
				pageParameter.lastRow = data["result"].lastRow;
				pageParameter.pages = data["result"].pages;
				pageParameter.rows = data["result"].rows;
				pageParameter.targetRow = pageParameter.lastRow + 1; // 중요!!

				// 새로운 TargetRow로 바꿔 지정해준다.
				pageParameter.resultData = data["result"]["resultList"];
				dataProvider.setOptions({ checkStates : false });
				// 2017.06.14. forain 삭제, rowSize 와 관계없이 무조건 1000 row 까지만 append 되므로 오류.
				// dataProvider.fillJsonData(pageParameter.resultData, { count : 1000, fillMode : "append" });
				dataProvider.fillJsonData(pageParameter.resultData, { count : pageParameter.parameter.rowSize, fillMode : "append" });
				dataProvider.setOptions({ checkStates : true });

				try {
					callback.call(this);
				} catch (e) { }

				refreshStatusBar();
				hideGridProgress();
			}, function(error) { // error callback
				hideGridProgress();
			});
		} else {
			bizForm.transaction(pageParameter.context, pageParameter.action, pageParameter.parameter, function(data) {
				if( dataProvider == null ) {
					return;
				}

				//첫번째 appendData 를 해 온 결과를 확인해서, loadData() 에서 가지고 왔던 전체 레코드 수와 비교하고,
				//이 숫자가 서로 일치하지 않으면, appendData 를 일단 멈추고 종료한다.
				if( pageParameter.rows != data["result"].rows ) {
					Message.alert( Message.FETCH_ALL_ALERT );
				} else {
					// 초기 설정으로 서버로 부터 가져온 페이지 메타를 설정한다.
					pageParameter.lastRow = data["result"].lastRow;
					pageParameter.pages = data["result"].pages;
					pageParameter.rows = data["result"].rows;
					pageParameter.targetRow = pageParameter.lastRow + 1; // 중요!!

					// 새로운 TargetRow로 바꿔 지정해준다.
					pageParameter.resultData = data["result"]["resultList"];
					dataProvider.setOptions({ checkStates : false });
					// 2017.06.14. forain 삭제, rowSize 와 관계없이 무조건 1000 row 까지만 append 되므로 오류.
					// dataProvider.fillJsonData(pageParameter.resultData, { count : 1000, fillMode : "append" });
					dataProvider.fillJsonData(pageParameter.resultData, { count : pageParameter.parameter.rowSize, fillMode : "append" });
					dataProvider.setOptions({ checkStates : true });

					try {
						callback.call(this);
					} catch (e) { }

					refreshStatusBar();
					hideGridProgress();
				}
			}, function(error) { // error callback
				hideGridProgress();
			});
		}
	}

	function fetchAll() {
		var currentPage = Math.floor( pageParameter.lastRow / ( pageConstants.rowSize||200 ) );

		if( dataProvider == null ) {
			return;
		}

		// 2017.06.14. forain 수정, Fetch 건수가 10000 건 이상이면
		if( dataProvider.getRowCount() >= 10000 ) {
			// 2017.06.14. forain 추가, 전체건수가 10000 건 이상일 경우 Fetch All 중단
			fetchAllFlag = false;
			Message.notify("Reached to fetch limit!! 10,000 Rows.");
			return;
		}

		// 2017.06.14. forain 수정, ESC 키가 입력이 되면 fetchAllFlag 값을 false 로 변경하므로
		// fetchAllFlag 여부를 먼저 판단한다.
		if( fetchAllFlag ) {
			// 전체 페이지수 보다 현재 페이지가 적은 경우 계속 조회를 진행한다.
			if ( currentPage <= pageParameter.pages ) {
				Message.notify(Message.FETCH_ALL_OPERATION_PROCESSING);
				appendData(function() {
					fetchAll();
				});
			}
			// 전체 페이지수 보다 현재 페이지가 큰 경우에는 Fetch를 종료한다.
			else {
				// fetchAllFlag 을 끈다.
				fetchAllFlag = false;
				Message.notify( Message.FETCH_ALL_FINISHED );
			}
		} else {
			Message.notify( Message.FETCH_ALL_FINISHED );
		}
	}

	this.setData = function(data) {
		dataProvider.clearRows();
		dataProvider.fillJsonData(data);
	}

	this.useProgress = function(flag) {
		useProgress = flag;
	}

	this.removeCheckedRows = function() {
		dataProvider.removeRows(gridMain.getCheckedRows(true, false), false);
	}

	this.getRowCount = function() {
		return dataProvider.getRowCount();
	}

	this.saveChanges = function(context, action, arg3, arg4, arg5) {
		var callback;
		var errorCallback;
		var param = {};

		if (arg3 == undefined) {
			param = loadParameter;
		} else {
			if (typeof arg3 == "function") {
				callback = arg3;
				errorCallback = arg4;
				param = loadParameter;
			} else if (typeof arg3 == "object") {
				param = arg3;
				callback = arg4;
				errorCallback = arg5;
			}
		}

		gridMain.commit(true);

		/* 행의 상태에 따른 Data를 조합한다. */
		var gridData = {
			"created" : new Array(),
			"updated" : new Array(),
			"deleted" : new Array()
		};
		/*
		 * $( dataProvider.getStateRows('created') ).each( function(inx){
		 * gridData["created"].push( dataProvider.getJsonRow(inx) ); }); $(
		 * dataProvider.getStateRows('updated') ).each( function(inx){
		 * gridData["updated"].push( dataProvider.getJsonRow(inx) ); }); $(
		 * dataProvider.getStateRows('deleted') ).each( function(inx){
		 * gridData["deleted"].push( dataProvider.getJsonRow(inx) ); });
		 */
		var createdRowIdxs = dataProvider.getStateRows('created');
		var updatedRowIdxs = dataProvider.getStateRows('updated');
		var deletedRowIdxs = dataProvider.getStateRows('deleted');
		if (createdRowIdxs) {
			for (var a = 0; a < createdRowIdxs.length; a++) {
				gridData["created"].push(dataProvider.getJsonRow(createdRowIdxs[a]));
			}
		}
		if (updatedRowIdxs) {
			for (var a = 0; a < updatedRowIdxs.length; a++) {
				gridData["updated"].push(dataProvider.getJsonRow(updatedRowIdxs[a]));
			}
		}
		if (deletedRowIdxs) {
			for (var a = 0; a < deletedRowIdxs.length; a++) {
				gridData["deleted"].push(dataProvider.getJsonRow(deletedRowIdxs[a]));
			}
		}
		gridData["parameter"] = param;

		if (useProgress) {
			showGridProgress();
		}

		transaction(context, action, gridData, function(data) {
			if (useProgress) {
				hideGridProgress();
			}

			try {
				callback.call(this, data, gridData );
			} catch (e) {
			}

		}, function(error) {
			hideGridProgress();

			try {
				errorCallback.call(this, data);
			} catch (e) {
			}
		});
	}

	this.exportGrid = function(fileName) {
		showGridProgress();

		gridMain.exportGrid({
			type : 'excel',
			target : 'local',
			fileName : fileName + '.xlsx',
			indicator : 'default',
			header : 'default',
			footer : 'default',
			compatibility : false
		});

		hideGridProgress();
	}

	this.hideGridProgress = function() {
		hideGridProgress();
	}

	this.getChangedRows = function() {
		/* 행의 상태에 따른 Data를 조합한다. */
		var changedRows = {
			"created" : [],
			"updated" : [],
			"deleted" : []
		};
		var createdRowIdxs = dataProvider.getStateRows('created');
		var updatedRowIdxs = dataProvider.getStateRows('updated');
		var deletedRowIdxs = dataProvider.getStateRows('deleted');
		if (createdRowIdxs) {
			for (var a = 0; a < createdRowIdxs.length; a++) {
				changedRows["created"].push(dataProvider.getJsonRow(createdRowIdxs[a]));
			}
		}
		if (updatedRowIdxs) {
			for (var b = 0; b < updatedRowIdxs.length; b++) {
				changedRows["updated"].push(dataProvider.getJsonRow(updatedRowIdxs[b]));
			}
		}
		if (deletedRowIdxs) {
			for (var c = 0; c < deletedRowIdxs.length; c++) {
				changedRows["deleted"].push(dataProvider.getJsonRow(deletedRowIdxs[c]));
			}
		}
		return changedRows;
	}

	/**
	 * RealGrid의 Selection Mode를 Custom 하게 설정한다.
	 * mode - rows       : Rows 선택 모드
	 *        block      : Block 선택 모드
	 *        block_line : Block 선택 모드에 현재행 표시
	 *        columns    : Columns 선택 모드
	 */
	this.setSelectMode = function(mode) {
		mode = $.trim(mode).toLowerCase();
		switch(mode) {
			case RealGrid.SELECTION_ROWS :
				gridMain.setDisplayOptions({ "rowFocusVisible" : false });
				gridMain.setSelectOptions({ "style" : "rows" });
				toggleItem( 'selection_rows' );
				break;
			case RealGrid.SELECTION_BLOCK :
				gridMain.setDisplayOptions({ "rowFocusVisible" : false });
				gridMain.setSelectOptions({ "style" : "block" });
				toggleItem( 'selection_block' );
				break;
			case RealGrid.SELECTION_BLOCKLINE :
				gridMain.setDisplayOptions({ "rowFocusVisible" : true });
				gridMain.setSelectOptions({ "style" : "block" });
				toggleItem( 'selection_blockline' );
				break;
			case RealGrid.SELECTION_COLUMN :
				gridMain.setDisplayOptions({ "rowFocusVisible" : false });
				gridMain.setSelectOptions({ "style" : "columns" });
				toggleItem( 'selection_columns' );
				break;
		}
	};

	function showGridProgress() {
		if (useProgress) {
			if ( !$(formContainer).find(".spinnerBack").exists()) {
				var contentLoader = $("<div class='spinnerBack'></div><div class='spinner'><span>Loading...</span></div>");
				$(formContainer).append(contentLoader);
				$(contentLoader).find(".spinnerBack").css("z-index", "2000");
				$(contentLoader).find(".spinner").css("z-index", "2001");
			}
			$(formContainer).find(".spinnerBack, .spinner").show();
		}
	}

	function hideGridProgress() {
		if (useProgress) {
			//$(container).parent().find(".spinnerBack, .spinner").hide();
			$(formContainer).find(".spinnerBack,.spinner").hide();
		}
	}

	/*  */
	if( options.fitToRowCount ) {
		fitContainerHeightByRowCount();
	}

	/******** 그리드 사용자 설정 기능 지원 ********/
	/* 그리드의 사용자 설정을 저장하고 사용하기 위해 그리드의 현재 설정 정보를 획득하는 함수 */
	function buildGridUserConfig() {
		var config = {};

		//1. colum 정보를 수집한다.
		var columnNames = gridMain.getColumnNames(false);
		$(columnNames).each( function(){
			config[this] = this;
		});

		return config;
	}

	/* 그리드의 사용자 설정을 받아 현재 그리드에 적용하는 함수 */
	function setGridUserConfig() {
		var menuItem = LayoutManager.getMenuItem( formId );
		var param = { programId : menuItem.programId, componentId : containerClassName };

		transaction( "lgcom", "common/uiCommon/retrieveGridConfig", param, function( data ){
			if( data == undefined ) return;
			
			var data = data["result"];
			if( data == undefined ) return;

			var layout = JSON.parse( data["content"] );

			if( layout != undefined ) {
				$(statusBar).find(".configButton").addClass("active");
			} else {
				$(statusBar).find(".configButton").removeClass("active");
			}

			//1. 사용자가 숨긴 컬럼 목록
			var userToggleCols = layout["userToggleCols"];
			if( userToggleCols != undefined ) {
				hideColumnList.clear();
				$.each( userToggleCols, function( key , value ) {
					gridMain.setColumnProperty( key, "visible", false);
					hideColumnList.put(key, key );
				});
			}
			//2. fixedOption
			var fixedOptions = layout["fixedOptions"];
			if( fixedOptions != undefined ) {
				gridMain.setFixedOptions( fixedOptions );
			}

			//3. 컬럼 폭
			var columnList = layout["columnList"];
			var columnLayout = []; //컬럼 순서에 의한 컬럼 이름의 목록
			if( columnList != undefined ) {
				$(columnList).each( function(inx){
					columnLayout.push( this["name"] );
					gridMain.setColumnProperty( this["name"], "width", this["width"]);
				});
			}
			gridMain.setColumnLayout(columnLayout);
		});
	}

	function deleteGridUserConfig() {
		var menuItem = LayoutManager.getMenuItem( formId );
		var param = { programId : menuItem.programId, componentId : containerClassName };
		transaction( "lgcom", "common/uiCommon/deleteGridConfig", param, function( data ){
			Message.notify("Grid config deleted.");
			$(statusBar).find(".configButton").removeClass("active");
		});
	}

	function saveGridUserConfig() {
		var menuItem = LayoutManager.getMenuItem( formId );
		//그리드 컨테이너가 가지는 클래스 이름으로 변경
		if( containerClassName == undefined || containerClassName == "" ) {
			return;
		}

		var param = { programId : menuItem.programId, componentId : containerClassName };

		//1. 사용자가 숨긴 컬럼 목록
		var userToggleCols = {};
		$.each( hideColumnList.keys() , function( key, value ) {
			userToggleCols[value] = value;
		});

		//2. fixedOption
		var fixedOptions = gridMain.getFixedOptions();
		fixedOptions = { colCount : fixedOptions.colCount, rowCount : fixedOptions.rowCount };

		//3. 컬럼 폭, 순서
		var gridColumns = gridMain.getDisplayColumns(); //진짜 컬럼들만 (컬럼 그룹 제외 )

		var columnList = [];
		$(gridColumns).each( function( inx ){
			var column = gridMain.columnByName(this);
			columnList.push( { name : this , width : gridMain.getColumnProperty( column, "width"), seq : inx } );
		});

		//전체 데이터 저장
		var config = { userToggleCols : userToggleCols , fixedOptions : fixedOptions , columnList : columnList };

		param.screenLayout = JSON.stringify( config );
		transaction( "lgcom", "common/uiCommon/saveGridConfig", param, function( data ){
			Message.notify("Grid config saved.");
			$(statusBar).find(".configButton").addClass("active");
		});
	}

	/******* 그리드 Style 적용 함수 *********/
	function setStyle() {
		defaultStyles = {
			grid : {
				border : "#c8c8c8, 0",
				fontSize : 12,
				font : "맑은 고딕"
			},
			panel : {
				background : "#d4d4d4",
				fontSize : 12
			},
			footer : {
				background : "#e9e9e9",
				fontSize : 12,
				borderLeft : "#dfdfdf,1",
				borderRight : "#dfdfdf,1",
				borderTop : "#dfdfdf,1"
			},
			indicator : {
				background : "#f2f2f2",
				borderRight : "#dfdfdf,1",
				borderBottom : "#dfdfdf,1"
			},
			header : {
				background : "#f2f2f2",
				borderRight : "#dfdfdf, 1",
				borderBottom : "#d0d0d0,1",
				foreground : "#333333",
				selectedBackground : "#ffdcf6f5",
				selectedForeground : "#000000",
				fontSize : 12,
				fontBold : "true",
				hoveredBackground : "#dcf6f5",
				group : {
					background : "#f2f2f2",
					fontSize : 12,
					fontBold : "true",
					borderRight : "#dfdfdf,1",
					borderBottom : "#dfdfdf,1"
				}
			},
			body : {
				line : "#cccccc,1",
				borderRight : "#f4f4f4, 1",
				borderBottom : "#dddddd, 1",
				paddingLeft : 5,
				paddingRight : 5
			},
			rowGroup : {
				header : {
					borderBottom : "#dfdfdf,1",
					background : "#f2f2f2",
					foreground : "#000000",
					fontSize : 10
				},
				headerBar : {
					background : "#f2f2f2",
					figureBackground : "#000000",
				},
				bar : {
					borderRight : "#dfdfdf,1",
					background : "#f2f2f2"
				},
				footer : {
					borderBottom : "#dfdfdf,1",
					borderRight : "#dfdfdf,1",
					background : "#e9e9e9"
				}
			},
			selection : {
				background : "#3088e6e6",
				border:"#5f1e90ff,2"
			},
			stateBar : {
				borderRight : "#dfdfdf,1",
				borderBottom : "#dfdfdf,1"
			},
			checkBar : {
				borderRight : "#dfdfdf,1",
				borderBottom : "#dfdfdf,1"
			},
			fixed : {
				borderRight : "#f4f4f4, 1",
				borderBottom : "#dddddd, 1",
				background:"#ffffffff",
				colBar: {
					border:"#ffd4d4d4,1"
				},
				rowBar: {
					border:"#ffd4d4d4,1"
				}
			}
		};

		gridMain.setStyles(defaultStyles);

		gridMain.addCellStyle("addStyle", {
			background : "#30fe082b",
			borderRight : "#f4f4f4, 1",
			borderBottom : "#f4f4f4, 1"
		}, true);
		
		// 20181004 nomi : 리얼그리드(1.1.29) 필터 인풋 적용
        gridMain.setFilteringOptions({
            clearWhenSearchCheck: true,
            HandleVisibility: "visible",
            selector: {
                showSearchInput: true,
                showButtons: true,
                acceptText: Message.select,
                cancelText: Message.cancel,
                minWidth: "200px",
                useCssStyle: true
            }
        })
        
		/* 그리드의 사용자 설정이 적용되는 부분 : 그리드의 모든 초기화가 끝난 뒤에 추가로 수행해야 하므로 가장 마지막에 적었다 */
		//이 그리드가 팝업 안에서 뜬 것일 때는 그리드 설정을 생략한다.
		if( !gridInPopup ) {
			setGridUserConfig();
		}
	}
}


var Form = function( bizForm,formSelector) {
	
}


/*********************************************************
 * Form Util 클래스 : 화면의 <form> 태그를 대상으로 각종 유틸리티 기능을 제공하는 목적의 클래스이다.
 *********************************************************/
var FormUtil = function(bizForm, formSelector) {
	var _this = this;
	var form = bizForm.select(formSelector);
	var bizFormId = bizForm.getBizFormId();
	var selectAll = { "code" : "", name : "ALL" };
	var selectEmpty = { "code" : "", name : "" };

	bizForm["FORM_UTIL_" + uuid()] = this;

	var fullId = "div#"+ bizFormId + " "+ formSelector;

	// 이 form 의 데이터를 모아놓은 객체 : 폼의 변경시, 화면 컴포넌트에 담긴 값과 밖으로 부터 받아들인 값을 비교하기 위해	// 사용한다.
	var formData = form.toJSON(); // 초기 데이터 설정
	var formChagneEventHandler;

	this.addChangeEvent = function(handler) {
		$("div#" + bizFormId ).on("change." + bizFormId, formSelector + " *:input", function() {
			try {
				formChagneEventHandler.call(this, _this.getValue(), formData, _this.isChanged());
			} catch (e) {}
		});

		formChagneEventHandler = handler;
	}

	//달력 팝업을 구성한다. 
    this.setCalendar = function( options ) {
    	if( options == undefined ) {
    		return;
    	}
    	if( options["from"] == undefined ) {
    		Message.alert("[FormUtils.setCalendar()] from 항목은 필수입니다.");
    		return;
    	}

    	var _dateFrom = $( fullId + " input[name='"+ options["from"] +"']");
		var _dateTo   = $( fullId + " input[name='"+ options["to"] +"']");
		var _button   = $(_dateFrom).closest(".form-inline").find("button[aria-label='calendar']"); 

		if( options["to"] == undefined ) {
			picker = uxp.datepicker.single( _button, _dateFrom, options ); 
    	} else {
    		picker = uxp.datepicker.fromTo( _button, _dateFrom, _dateTo, options  ); 
    	}
	
    }
	
	var currencyInfo = {};

	this.setCurrencyInfo = function(info) {
		currencyInfo = info;
		var element = form.find("[name='" + currencyInfo["currency"] + "']");

		// 통화 항목이 Combo 일 경우에 한하여 이 정보를 초기화 한다.
		if (element[0].tagName == "SELECT") {
			$(_getCurrencyData()).each( function() {
				$(element).append( "<option value='" + this["code"] + "'>" + this["name"] + "</option>");
			});

			if (currencyInfo["defaultCurrency"] != undefined) {
				$(element).val(currencyInfo["defaultCurrency"]);
			}

			// 통화 코드가 바뀌는 상황에서의 처리에 대한 이벤트 핸들러
			$(element).change( function() { // target 들에 대한 처리
				$.each(currencyInfo["target"], function(key, value) {
					var target = form.find("[name='" + key + "']");
					setCurrencyFormatter(target, _getPrecision($(element).val(), value["precisionType"]));
				});
			});
		}

		// target 들에 대한 처리
		$.each(currencyInfo["target"], function(key, value) {
			var target = form.find("[name='" + key + "']");
			setCurrencyFormatter(target, _getPrecision($(element).val(), value["precisionType"]));
		});
	}

	function setCurrencyFormatter(input, precision, value) {
		if (value == undefined) {
			value = 0;
		}

		if (input.is(":input")) {
			if ($(input).data("_cleave_") != undefined) {
				value = $(input).data("_cleave_").getRawValue();
				$(input).data("_cleave_").destroy();
				$(input).data("_cleave_", null);
			}
			var cleaveCurrency = new Cleave(input, {
				numeral : true,
				numeralDecimalScale : precision,
				numeralThousandsGroupStyle : 'thousand'
			});
			cleaveCurrency.setRawValue(value);
			$(input).data("_cleave_", cleaveCurrency);
		} else {
			value = formData[input.attr("name")];
			var formatter = new Cleave.NumeralFormatter(".", precision, ",", "");
			$(input).text(formatter.format(value + ""));
		}
	}

	function setCurrencyFormatterAll(currencyCode, rawData) {
		$.each(currencyInfo["target"], function(key, value) {
			var target = form.find("[name='" + key + "']");
			var itemValue = target.val();

			if (!target.is(":input")) {
				itemValue = target.text();
			}

			if (rawData != undefined && rawData[key] != undefined) {
				itemValue = rawData[key];
			}

			setCurrencyFormatter(target, _getPrecision(currencyCode,
					value["precisionType"]), itemValue);
		});
	}

	// UXP에서의 팝업 찾기 버튼을 적용한 항목이 발견된 경우, 이것에 대한 처리를 수행한다.
	$(form).find(".ico-lgd.find").each( function() {
		$(this).closest(".input-search").children("input.form-control").addClass("_find_origin_");
		var action = $(this).data("action");

		$(this).find("span").attr("data-action", action);
	});

	// form 에 .find 클래스가 적혀있는 경우, 이것에 대한 처리를 수행한다.
	$(form).find("input.find").each( function() {
		var action = $(this).data("action");
		$(this).removeClass("find").removeAttr("data-action").addClass( "_find_origin_");
		$(this).wrap("<span style='position:relative;'></span>");
		$("<i class='find fa fa-search' data-action='" + action+ "' for='" + $(this).attr("name") + "' ></i>").insertAfter(this);
	});

	$(form).find("select[data-type='yes_no']").each(function(inx) {
		var combo = $(this);
		combo.empty();
		combo.append("<option value='Y' selected>Yes</option>");
		combo.append("<option value='N'>No</option>");
	});

	// Data 는 [{code: "1", name : "AAAA"}, {code: "2", name : "BBBB"}, {code:
	// "3", name : "CCCC"}] 형태임
	this.initCombo = function(name, data, option) {

		var combo = form.find("select[name=" + name + "]");
		combo.empty();

		if (option != undefined) {
			if (option.selectAll) {
				combo.append("<option value='" + selectAll.code + "' class='all'>" + selectAll.name + "</option>");
			}

			if (option.selectEmpty) {
				combo.append("<option value='" + selectEmpty.code + "' class='all' >" + selectEmpty.name + "</option>");
			}
		} else {
			option = {};
		}

		// Option Group 을 지정하는 플래그가 들어왔는지에 따라, Group 을 지정하는 코드로 분기처리 한다.
		if (option != undefined && option.group != undefined
				&& option.group == true) {
			var groupName = "";
			var group;

			$(data).each( function() {
				if (this.groupName == undefined) {
					return false; // groupName 이라는 필드가 모든 레코드에 같이 오지
					// 않으면, 이 즉시 loop 를 중단한다.
				}

				if (groupName != this.groupName) {
					groupName = this.groupName;
					group = $("<optgroup label='" + this.groupName + "'></optgroup>");
					combo.append(group);
				}

				$(group).append( "<option value='" + this.code + "' data-parent='" + this.pCode	+ "' >" + this.name + "</option>");
			});
		} else {
			$(data).each( function() {
				combo.append("<option value='" + this.code + "' data-parent='" + this.pCode + "' >"+ this.name + "</option>");
			});
		}

		//combo.find("option:first").prop('selected', true);

		//모든 select 가 .multiselect() 를 사용하고 있기 때문에, option 리스트가 변경된 직후에 refresh 를 기동하여 화면을 갱신해준다.
		if( $(combo).length > 0 && $(combo)[0].tagName!= undefined && $(combo)[0].tagName == "SELECT" ) {
			try {
				$(combo).multiselect("refresh");
			} catch( e) { }
		}

		// initCombo 하는 시점에 form 의 모든 정보를 모아서 별도로 저장한다.
		formData = form.toJSON();

		// option 에 filter 지정이 들어오면, 이 오브젝트에 change 이벤트를 추가해준다.
		if (option != undefined && option.filter != undefined) {

			// 이 항목이 filtered 되고 있음을 적고, source항목도 같이 표기한다.
			combo.addClass("_filtered_").data("filterOption", option);
			combo.addClass("_filtered_").data("filterData", data );

			var filterValue = form.find("select[name=" + option.filter + "]").val();
			combo.empty();

			// option 에 지정된 selectAll / selectEmpty 속성에 따라 태그를 추가한다.
			if(option.selectAll) {
				$(combo).append("<option value='' class='all'>ALL</option>");
			}

			if(option.selectEmpty) {
				$(combo).append("<option value='' class='all'></option>");
			}

			$(data).each( function(){
				if( this["pCode"] == filterValue ) {
					$(combo).append("<option value='"+ this["code"] +"'>"+ this["name"] +"</option>");
				}
			});

			//bizForm.addEvent("change", formSelector + " select[name=" + option.filter + "]", function(event) {
			$("div#" + bizFormId ).on("change." + bizFormId, "select[name=" + option.filter + "]" , function(event) {
				var comboOption = $(combo).data("filterOption");
				var filterSource = $(event.target);
				var filterData = $(combo).data("filterData");

				// options tag를 모두 비운다.
				$(combo).empty();

				// option 에 지정된 selectAll / selectEmpty 속성에 따라 태그를 추가한다.
				if(option.selectAll) {
					$(combo).append("<option value='' class='all'>ALL</option>");
				}

				if(option.selectEmpty) {
					$(combo).append("<option value='' class='all'></option>");
				}

				var filterSourceVal = data[ option.filter ];

				if( filterSourceVal == undefined) {
					var filterSourceVal = $(filterSource).val();
				}

				$(filterData).each( function() {
					if( this["pCode"] == filterSourceVal ) {
						$(combo).append("<option value='"+ this["code"] +"'>"+ this["name"] +"</option>");
					}
				});


				$(combo).val( data[ $(combo).attr("name") ] );
			});

		}

		//추가 옵션으로 이 select 의 기본 값을 code 로 지정하거나 name 으로 지정할 수 있다.
		if( option["defalut"] != undefined ) {
			if( option["defalut"].code != undefined ){
				$(combo).find("option").removeAttr("selected");
				$( $(combo).find("option") ).each( function(){
					if( $(this).attr("value") == option["defalut"].code ) {
						$(this).prop("selected", true);
						return false;
					}
				});
			}

			if( option["defalut"].name != undefined ){
				$(combo).find("option").removeAttr("selected");
				$( $(combo).find("option") ).each( function(){
					if( $(this).text() == option["defalut"].name ) {
						$(this).prop("selected", true);
						return false;
					}
				});
			}
		}


		try {
			// multiselect 에 대한 refresh 를 추진한다.
			if ($(combo).is("[multiselect]")) {
				$(combo).multiselect('refresh');
			}
		} catch (e) {

		}

		try {
			option.complete.call(this);
		} catch (e) {

		}
	}

	this.revert = function(name) {
		if (name != undefined) {
			$(form).find("*[name='" + name + "']").val(formData[name]);
		} else {
			$.each(formData, function(key, value) {
				$(form).find("*[name='" + key + "']").val(value);
			});
		}
	}

	/* json 객체 한개를 Form의 아이템에게 뿌리기 위한 메소드 */
	var setValueKey;

 	this.setValue = function(data1, data2, tz) {
		var tzOption = tz||"rtz";
		
		var jsonData = {};

		
		if (typeof (data1) == "string") {
			//주어진 키 값으로 찾은 input 이 여러 항목인 경우 이때의 data2 가 json 인지 확인하여 이 값을
			// data-code 로 매핑하여 찾은 input 에 배정한다. 
			if( $( fullId + " [name=" + data1 + "]").length > 0 && typeof (data2) == "object" ) {
				jsonData[data1] = data2;
				formData[data1] = data2;
				$.each(data2, function(key, value){
					$( fullId + " [name=" + data1 + "][data-code='"+ key +"']").val( value );
				});
				
				return true;
			}
			
			jsonData[data1] = data2;

			var key = data1;
			var value = data2;
			var element = $( fullId + " [name=" + key + "]");

			formData[key] = nvl(value);
			$(element).val(nvl(value));

			//이 항목이 data-numeral 일때 들어온 값을 숫자 포맷으로 변경하여 세팅하도록 한다.
			$( fullId + " [name=" + key + "][data-numeral]" ).each( function(){
				var item = this;
				var precision = $(item).attr("data-numeral");

				if( nvl( precision ) == "" ) {
					precision = 0;
				} else {
					precision = Number( precision.split(":")[1] );
				}

				var val = nvl( value );

				
				//20171108 이준성 prettyFormat --> Calc.format 변경
				if( val != "" ) {
					if( $(item).is(":input") ) {
						$(item).val( Calc.format( Number( val ), precision, tzOption ));
					} else {
						$(item).text( Calc.format( Number( val ), precision, tzOption ));
					}
				}
			});


			if( $(element).is("[type='radio'], [type='checkbox']") ) {
				 //해당 아이템이 radio / ckeckbox 일 때는 들어온 값에 맞는 항목을 체크 처리함 ( radio 는 동일 이름의 항목에서 checked 를 모두 빼주어야 함 )
				$( fullId + " [name=" + key + "][type='radio']" ).removeAttr("checked");
				$( fullId + " [name=" + key + "][type='radio'][value='"+ value +"']" ).prop("checked", true );

				if( $( fullId + " [name='" + key + "'][type='checkbox']" ).exists() ){
					if( typeof value == "string" ) {
						$( fullId + " [name='" + key + "'][type='checkbox'][value='"+ value +"']" ).prop("checked", true );
					} else {
						$(value).each( function(){
							$( fullId + " [name='" + key + "'][type='checkbox'][value='"+ this +"']" ).prop("checked", true );
						});
					}
				}
			}

			//팝업 블러 때문에 해놨다
			$(element).data( "_previous_data_" , $(element).val() );

		} else {
			jsonData = data1;

			$.each( jsonData, function(key, value) {
				// 통화 설정에 적용되는 필드의 이름 값이 key 에 포함 돼 있으면, 이것에 대한 precision 을 미리
				// 설정 해 주고 값이 들어가야 한다.
				formData[key] = nvl(value);
				var element = $( fullId + " [name=" + key + "]");
				if ($(element).is(":input")) {
					$(element).filter(":not([type='radio'], [type='checkbox'])").val(nvl(value));
				} else {
					$(element).text(nvl(value));
				}

				if( $(element).is("[type='radio'], [type='checkbox']") ) {
					// 해당 아이템이 radio / ckeckbox 일 때는 들어온 값에 맞는 항목을 체크 처리함 ( radio 는 동일 이름의 항목에서 checked 를 모두 빼주어야 함 )
					if( $( fullId + " [name='" + key + "'][type='radio'][value='"+ value +"']" ).exists() ){
						$( fullId + " [name='" + key + "'][type='radio']" ).removeAttr("checked");
						$( fullId + " [name='" + key + "'][type='radio'][value='"+ value +"']" ).prop("checked", true );
					}
					//checkbox 인 경우, 값이 array 로 들어올 수 있다. string 인 경우는 해당 항목만 그대로 체크해주면 되지만 array 인 경우는 loop 를 돌려 모두 처리해 주어야 한다.
					if( $( fullId + " [name='" + key + "'][type='checkbox']" ).exists() ){
						if( typeof value == "string" ) {
							$( fullId + " [name='" + key + "'][type='checkbox'][value='"+ value +"']" ).prop("checked", true );
						} else {
							$(value).each( function(){
								$( fullId + " [name='" + key + "'][type='checkbox'][value='"+ this +"']" ).prop("checked", true );
							});
						}
					}
				}

				//해당 아이템이 multiSelect 이라면
				if( $( fullId + " [name='" + key + "'][multiselect]" ).exists() ){

					//이때의 value 는 [{"key":"5136"},{"key":"19165"}] 형식의 array 이다.
					var arr = [];
					$(value).each( function(){
						arr.push( this[key] );
					});

					$( fullId + " [name='" + key + "'][multiselect]" ).val( arr );
					$( fullId + " [name='" + key + "'][multiselect]" ).multiselect("refresh");
				}

				//팝업 블러 때문에 해놨다
				$(element).data( "_previous_data_" , $(element).val() );
			});

			// 데이터 중에 currencyCode 를 가지고 있는 항목의 이름값
			if( currencyInfo["currency"] != undefined ) {
				var currencyCode = data1[ currencyInfo["currency"] ];

				if (currencyCode != undefined) {
					setCurrencyFormatterAll(currencyCode, data1);
				}
			}

			//이 항목이 data-numeral 일때 들어온 값을 숫자 포맷으로 변경하여 세팅하도록 한다.
			$( fullId + " [name][data-numeral]" ).each( function(){
				var item = this;
				var precision = $(item).attr("data-numeral");

				if( nvl( precision ) == "" ) {
					precision = 0;
				} else {
					precision = Number( precision.split(":")[1] );
				}

				var val = nvl( data1[ $(item).attr("name") ] );

				if( val != "" ) {
					if( $(item).is(":input") ) {
						$(item).val( prettyFloat( Number( val ), precision, true) );

						//팝업 블러 때문에 해놨다
						$(item).data( "_previous_data_" , $(item).val() );
					} else {
						$(item).text( prettyFloat( Number( val ), precision, true) );
					}
				}
			});
		}

		//전체 데이터가 세팅 된 다음, 이 폼 안에 _filtered_ 클래스가 있는 아이템이 있는 경우에는 다음과 같이 처리한다.
		$( fullId + " [name]._filtered_" ).each( function(){
			var _element = this;
			var name = $(_element).attr("name");

			if( jsonData[name] != undefined ) {
				var option = $(_element).data("filterOption");
				var filterSource = $( fullId + " [name='" + option.filter + "']" );
				var filterData = $(_element).data("filterData");

				// options tag를 모두 비운다.
				$(_element).empty();

				// option 에 지정된 selectAll / selectEmpty 속성에 따라 태그를 추가한다.
				if(option.selectAll) {
					$(_element).append("<option value='' class='all'>ALL</option>");
				}

				if(option.selectEmpty) {
					$(_element).append("<option value='' class='all'></option>");
				}

				var filterSourceVal = jsonData[ option.filter ];

				if( filterSourceVal == undefined) {
					var filterSourceVal = $(filterSource).val();
				}

				$(filterData).each( function(){
					if( this["pCode"] == filterSourceVal ) {
						$(_element).append("<option value='"+ this["code"] +"'>"+ this["name"] +"</option>");
					}
				});

				$(_element).val( jsonData[ $(_element).attr("name") ] );
				//팝업 블러 때문에 해놨다
				$(_element).data( "_previous_data_" , $(_element).val() );
			} else {
				var option = $(_element).data("filterOption");
				var filterSource = $( fullId + " [name='" + option.filter + "']" );
				var filterData = $(_element).data("filterData");
				var filterSourceVal = jsonData[ option.filter ];

				//이때는 자신은 값이 들어오지 않고, option.filter 에만 값이 들어온 상황에 대한 처리이다.
				if( filterSourceVal != undefined ) {

					// options tag를 모두 비운다.
					$(_element).empty();

					// option 에 지정된 selectAll / selectEmpty 속성에 따라 태그를 추가한다.
					if(option.selectAll) {
						$(_element).append("<option value='' class='all'>ALL</option>");
					}

					if(option.selectEmpty) {
						$(_element).append("<option value='' class='all'></option>");
					}

					var filterSourceVal = jsonData[ option.filter ];

					if( filterSourceVal == undefined) {
						var filterSourceVal = $(filterSource).val();
					}

					$(filterData).each( function(){
						if( this["pCode"] == filterSourceVal ) {
							$(_element).append("<option value='"+ this["code"] +"'>"+ this["name"] +"</option>");
						}
					});
				}
			}
		});
		return this;
	}

	this.getPreviousValue = function( key ) {
		return $.trim( $(form).find("[name='"+key+"']").data("_previous_data_") );
	}

	this.getValue = function(key) {
		var result = {};
		/*
		//주어진 키 값으로 찾은 input 이 여러 항목인 경우 이때의 data2 가 json 인지 확인하여 이 값을
		// data-code 로 매핑하여 찾은 input 에 배정한다. 
		if( $( fullId + " [name=" + key + "]").length > 0  ) {
			$( fullId + " [name=" + key + "][data-code]").each( function(){
				var code = $(this).data("code");
				result["code"] = $(this).val();
			});
			
			return result;
		}
		*/

		if (key == undefined) {
			result = $(form).toJSON();
		} else {
			result[key] = $(form).toJSON()[key];
		}

		//result 의 key 를 근거로 하여, 각종 특별한 component 에 대해 데이터 정리를 수행한다.
		$.each( result, function( key, value ) {
			if( $( fullId + " [name='"+key+"'][data-numeral]:first" ).exists() ) {
				if( typeof value == "object" ) {
					$(value).each( function( inx ){
						value[inx] = ( this + "" ).replace(/\,/g,'');
					});
				} else {
					result[key] = ( result[key] + "" ).replace(/\,/g,'');
				}
			} else if( $( fullId + " [name='"+key+"'][data-numeral]:first" ).exists() ) {

			}
		});

		// pastable 에 대한 처리를 수행한다.
		$( fullId + " input[type='hidden'][pastable] ," + fullId + " input[type='hidden'][multi]" ).each(function(index) {

			var name = $(this).attr("name");
			var value = result[name];

			if (value != undefined && value != "") {
				var arr = [];
				$(value.split(",")).each(function() {
					var json = {};
					json[name] = this;
					arr.push(json);
				});

				result[name] = arr;
			} else {
				result[name] = "";
			}
		});

		// multiSelect 에 대한 처리를 수행한다.
		$( fullId + " select[multiselect]").each(function(index) {

			var name = $(this).attr("name");
			var valueList = $(this).multiselect("getChecked").map(function() {
				return this.value;
			}).get();

			if (valueList.length == 0) {
				result[name] = "";
			} else {
				var arr = [];

				$(valueList).each(function() {
					var json = {};
					json[name] = this;
					arr.push(json);
				});

				result[name] = arr;
			}
		});

		if (key == undefined) {
			return result;
		} else {
			return result[key];
		}
	}

	this.getNumber = function( name ) {
		var value = nvl( this.getValue( name ) );
		value = Number( (value + "").replaceAll("," , "" ) );

		if( value == "" ) {
			value = 0;
		} else {
			value = Number( value );
		}

		return value;
	}

	this.disable = function(name) {
		var nameArray = new Array();

		if (typeof (name) == 'string') {
			nameArray.push(name);
		} else {
			nameArray = name;
		}

		$(nameArray).each( function() {
			var target = $(form).find("*[name=" + this + "]");

			if( !target.exists() ) {
				return true; // continue
			}

			target.prop("disabled", true);

			if (target.hasClass("_find_origin_")) {
				target.next().prop("disabled", true).addClass("disable");
				// UXP 적용시 찾기 버튼이 버튼으로 붙은경우에 대한 처리
				target.parent().find(".find").prop("disabled", true).addClass("disable");
			}

			//target 이 select 라면, 다음과 같은 동작을 추가로 한다.
			if( $(target)[0].tagName == "SELECT" ) {
				try {
					$(target).multiselect("disable");
				} catch( e ){}
			}

			if( $(target).is("[pastable]") ) {
				$(target).prev().addClass("disabled");
			}
		});

		return this;
	}

	this.enable = function(name) {
		var nameArray = new Array();

		if (typeof (name) == 'string') {
			nameArray.push(name);
		} else {
			nameArray = name;
		}

		$(nameArray).each( function() {
			var target = $(form).find("*[name=" + this + "]");

			if( !target.exists() ) {
				return true; // continue
			}

			target.removeAttr("disabled");
			if (target.hasClass("_find_origin_")) {
				target.next().removeAttr("disabled").removeClass("disable");
				// UXP 적용시 찾기 버튼이 버튼으로 붙은경우에 대한 처리
				target.parent().find(".find").removeAttr("disabled").removeClass("disable");
			}

			if( $(target)[0].tagName == "SELECT" ) {
				try {
					$(target).multiselect("enable");
				} catch( e ){}
			}

			if( $(target).is("[pastable]") ) {
				$(target).prev().removeClass("disabled");
			}

			target= null;
		});

		return this;
	}

	this.focus = function(name) {
		if (name == undefined) {
			name = setValueKey;
		}

		$(form).find("*[name=" + name + "]").focus();

		return this;
	}

	this.isChanged = function() {
		if( $(form).find("[data-code]").length > 0 ) {
			var changed = false;
			$( $(form).find("[data-code]") ).each( function(){
				var code = $(this).data("code");
				var name = $(this).attr("name");
				
				if( $(this).val() != formData[name][code] ) {
					changed = true;
				}
			});
			
			return changed;
			
		} else {
			// form 요소에 맞춰서 formData 를 비교할 수 있도록 앞에 적어주었다. ( 순서가 중요함 )
			return !compare($(form).toJSON(), formData);
		}
	}

	function compare(obj1, obj2) {
		var flag = true;
		$.each(obj1, function(key, value) {

			if (obj2[key] != value) {
				flag = false;
			}
		});

		return flag;
	}

	/*
	 * form 의 toJSON 은 low level api 이므로 수정하지 않고, 여기에서 multiSelect 관련 처리를 수행하여,
	 * 값을 리턴하도록 조정한다.
	 */
	function getFormValue() {

	}

	this.clear = function() {
		var elements = $(form).find("*:input");
		$(elements).each(function(inx) {
			if (this.tagName.toUpperCase() == "SELECT") {
				$(this).find("option:first").prop("selected", true);
			} else {
				if($.trim($(this).attr('type')).toUpperCase() == 'CHECKBOX' || $.trim($(this).attr('type')).toUpperCase() == 'RADIO') {
					$(this).removeAttr("checked");
				} else {
					$(this).val("");
				}
			}
		});
		elements = null;
	}

	FormUtil.clear = function(targetForm) {
		var elements = $(targetForm).find("*:input");

		$(elements).each(function(inx) {
			if (this.tagName == "SELECT") {
				$(this).val($(this).find("option:first").val());
			} else {
				$(this).val("");
			}
		});

		elements = null;
	}

	var validator;

	this.addValidator = function( rules ) {
		validator = new Validator( bizForm, formSelector, rules );
	}

	this.isValid = function() {
		if( validator == undefined ) {
			alert("[DEV] call addValidator() first!!");
			return;
		}
		return validator.isValid();
	}

	this.valid = function( name ) {
		if( validator ) {
			validator.valid( name );
		}
	}
}


/************************************************************
 * jstree 컴포넌트 + LGD UX 를 결합한 Tree Component 이다.
 * 컴포넌트의 자세한 정보 : https://www.jstree.com/
************************************************************/
var JsTree = function( myForm, selector , options ){
	var bizFormId  = uuid();
	var treeObj = $(selector);
	if( myForm != null ) {
		bizFormId = myForm.getBizFormId();
		treeObj = myForm.select( selector );
	} 

	var treeData;

	if( options == undefined ) {
		options = {};
	}
	var plugins = [ "types" ];

	if( options.checkbox == "Y" ) {
		plugins.push("checkbox");
	}
	
	if( options.search == "Y" ) {
		plugins.push("search");
	}

	
	var initOptions = {
			"core": {
				"check_callback" : true, /*이걸 false 로 하면, move_node 가 되지 않는다.*/
				"themes":{ "icons":false },
				"animation" : 100
			},
			"plugins" : plugins,
			"types" : {
				"root" : { // the root node can have only "branch" children
					"valid_children" : ["branch"]
				},
				"branch" : { // any "branch" can only have "leaf" children
					"valid_children" : ["leaf"]
				},
				"leaf" : { // "leaf" typed nodes can not have any children
					"valid_children" : []
				}
			}
		};
	
	if( options.search == "Y" ) {
		initOptions["search"] = { "show_only_matches" : true, "search_leaves_only" : true };
	}

	treeObj.jstree(initOptions);

	var tree = treeObj.jstree( true );

	this.expandAll = function(){
		treeObj.jstree('open_all');
	}

	this.collapseAll = function(){
		treeObj.jstree('close_all');
	}

	this.expandHalf = function() {
		treeObj.jstree('close_all');
		var rootNodes = tree.get_json('#', {flat:false});
		$(rootNodes).each( function() {
			treeObj.jstree("open_node", this );
		});
	}

	this.selectNode = function( id ) {
		treeObj.jstree('deselect_all');
		treeObj.jstree('select_node', '#' + id);
	}

	this.setData = function( data, callback ) {
		if( data.length == 0 ) {
			treeObj.jstree("init");
			return;
		}
		tree.settings.core.data = data;
		treeData = data;

		tree.refresh( false, function(){
			try {
				callback.call( this );
			}catch( e ) {}
		});
	}

	this.getPrevNode = function( node ){
		return tree.get_prev_dom( node, true );
	}

	this.getParent = function( node ){
		return tree.get_parent( node );
	}

	this.getNextNode = function( node ){
		return tree.get_next_dom( node, true );
	}

	this.getSelectedNode = function(){
		return tree.get_selected();
	}

	this.getSelectedTopLevelNode = function(){
		return tree.get_top_selected();
	}

	this.getNode = function( id ) {
		return tree.get_node(id);
	}

	this.deleteNode = function( node ) {
		tree.delete_node( node );
	}

	this.disableNode = function( id ) {
		tree.disable_node( tree.get_node(id) );
	}

	this.enableNode = function( id ) {
		tree.enable_node( tree.get_node(id) );
	}

	this.getAllNodes = function() {
		return tree.get_json('#', {'flat': true});
	}

	this.getCheckedNodes = function() {
		return tree.get_checked(true);
	}

	this.changeCurrentNodeName = function( name ){
		var node = tree.get_selected();
		treeObj.jstree('set_text', node , name );
	}

	this.moveNode = function( nodeToMove, newParent, newPosition , callback ){
		tree.move_node( nodeToMove, newParent, newPosition , callback );
	}

	this.clear = function() {
		treeObj.jstree("init");
	}
	
	
	this.getChildNodes = function(){  
		var parent = tree.get_selected();
		return tree.get_children_dom( parent );
	}
	

	// data = { id : 'A' , text : "New Menu" };
	this.addChildNode = function( data, callback ){
		var parent = tree.get_selected();
		treeObj.jstree("open_node", parent );

		tree.create_node( parent[0] , data , "last", function(){
			var newNode = tree.get_node( data.id );
			var parent = tree.get_node( newNode.parent );

			try {
				callback.call( this , newNode, parent.children.length );
			} catch( e ) {}
		});
	}

	this.addRootNode = function( data, callback ) {
		tree.create_node( "#" , data , "last", function(){
			var newNode = tree.get_node( data.id );
			var rootNode = tree.get_node( "#" );
			try {
				callback.call( this, newNode, rootNode.children.length );
			} catch( e ) {}
		});
	}

	this.getOpenNodes = function() {
		var openNodes = [];
		var nodes = tree.get_json('#', {'flat': true});
		$(nodes).each( function(){
			if( this.state.opened ) {
				openNodes.push( this.id );
			}
		});
		return openNodes;
	}

	this.changeCheckboxStatus = function(id , status ) {
		var node = tree.get_node(id);
		if( status ) {
			tree.enable_checkbox( node );
		} else {
			tree.disable_checkbox(node);
		}
	}
	
	this.openNodes = function( level ) {
		if( level == undefined ) {
			tree.openAll();
		}
	}

	/* Event */
	this.onClick = function( handler ) {
		treeObj.on( "activate_node.jstree" , function( e, data ) {
			handler.call( this, e, data );
		});
	}

	this.onItemMove = function( handler ) {
		treeObj.on("move_node.jstree", function (e, data) {
			handler.call( this, e, data );
		});
	}

	this.onDeleteNode = function( handler ) {
		treeObj.on("delete_node.jstree", function (e, data) {
			handler.call( this, e, data );
		});
	}

	this.onSelectNode = function( handler ) {
		treeObj.on("select_node.jstree", function (e, data) {
			return handler.call( this, e, data );
		});
	}

	this.onDeselectNode = function( handler ) {
		treeObj.on("deselect_node.jstree", function (e, data) {
			return handler.call( this, e, data );
		});
	}

	this.onOpenNode = function( handler ) {
		treeObj.on("open_node.jstree", function (e, data) {
			return handler.call( this, e, data );
		});
	}

	this.onCloseNode = function( handler ) {
		treeObj.on("close_node.jstree", function (e, data) {
			return handler.call( this, e, data );
		});
	}

	this.onMoveNode = function( handler) {
		treeObj.on("move_node.jstree", function (e, data) {
			return handler.call( this, e, data );
		});
	}

	this.onNodeCheckChanged = function( handler ) {
		treeObj.on("check_node.jstree uncheck_node.jstree", function(e, data) {
			handler.call( this, e, data );
		});
	}
	return this;
}

/************************************************************
 * Namo CrossEditor 관리 객체
************************************************************/
var CrossEditor = function(bizForm,containerId,option) {
	var defaults = {
		Width: '100%',
		Height: 300,
		BlankSpanRemove: true,
		CheckNbspInPTag: false,
		FullScreen: false,
		ParentEditor: '',
		DisplayNoneTarget: '',
		PluginTopPosition: true,
		SetDebug: true,
		UploadFileExecutePath: '/lgcom/upload/crosseditor',
		UploadFileSizeLimit: 'image:1048576',
		UserLang: 'enu',
		language: 'en',
		WebLanguage: 'JSP'
	};
	// 주어진 Option을 확장한다.
	option = $.extend(defaults,option);
	// 그리드 Container 에 class와 css를 동시에 사용가능하도록 정리 하였다.
	if (containerId.substr(0, 1) == ".") {
		container = bizForm.select(containerId);
		// 주어진 Container에 ID Attr 이 없을 경우
		if($.trim(container.attr('id')) == '') {
			editorId = 'namoEditor_' + bizForm.getBizFormId();
			container.attr('id',editorId);
		}
		if($.trim(container.parent().attr('id')) == '') {
			var parentId = 'blockDiv_' + bizForm.getBizFormId();
			container.parent().attr('id',parentId);
			option.ParentEditor = bizForm.select("#"+parentId)[0];
			//option.DisplayNoneTarget = bizForm.select("#"+parentId)[0];
		}
	}
	// 언어코드를 세팅한다.
	if(option.language == 'ko') {
		option.UserLang = 'kor';
	} else {
		option.UserLang = 'enu';
	}
	// Image Upload Path 설정
	option.UploadFileExecutePath = '/lgcom/upload/crosseditor?frameId='+editorId;
	// Namo 객체 생성
	var editor = new NamoSE(editorId);
	editor.params = option;
	editor.OnInitCompleted = function(e) {
		e.editorTarget.SetBodyValue(bizForm.select("#"+parentId+">#"+editorId).val());
	};
	editor.EditorStart();
	bizForm.addCrossEditor( this );
	this.resetSize = function() {
		if(editor.params.DisplayNoneTarget) {
			editorHeight = $(editor.params.DisplayNoneTarget).height() - 10;
		} else if(editor.params.ParentEditor) {
			editorHeight = $(editor.params.ParentEditor).height() - 10;
		} else {
			editorHeight = bizForm.select("#"+editorId).parent().height() - 10;
		}
		if(editorHeight > 0) {
			editor.SetUISize("",editorHeight);
		}
	};
	/* SetFocusEditor Override */
	this.setFocusEditor = function(pos) {
		if(typeof(pos) == 'undefined') pos = -1;
		editor.SetFocusEditor(pos);
	};
	/* GetValue Override */
	this.getValue = function(type) {
		if(typeof(type) == 'undefined') type = 'HTML';
		return editor.GetValue(type);
	};
	/* SetValue Override */
	this.setValue = function(content) {
		if(typeof(content) == 'undefined') content = '';
		editor.SetValue(content);
	};
	/* GetBodyValue Override */
	this.getBodyValue = function(type) {
		if(typeof(type) == 'undefined') type = 'HTML';
		return editor.GetBodyValue();
	};
	/* SetBodyValue Override */
	this.setBodyValue = function(val) {
		return editor.SetBodyValue(val);
	};
	/* IsDirty Override */
	this.isDirty = function() {
		return editor.IsDirty();
	};
	/* Resource Released */
	this.destroy = function() {
		if( editor ) {
			editor = null;
		}
	}
}

/**************************************
 * AI Report 관련 클래스
 **************************************/
var Report = function( form, context, url, param ){

	this.open = function( reportId, options, callback ){
		form.transaction( context, url, param , function(data){
			// {result : { programList : 234242342.json, programList2 : 34234324513.json } }
			showReport( reportId, data, options );
		} );
	}

	/* 레포트 자체가 가져야 할 파라미터들은 아래 항목에 기술하면 된다.
	 * 각 항목의 설명은 http://solbitech.com/AIManual/html/ManualFrameset.html 를 참조
	 * options.reportParam = {
	 *
	 * }
	 */
	function showReport( reportId, data, options ) {
		var fileListJson = data["result"];
		var size = { width : 1036, height : 700 };

		if( options != undefined ) {
			if( options.width != undefined ) {
				size.width = options.width;
			}

			if( options.height != undefined ) {
				size.height = options.height;
			}
		} else {
			options = {};
		}

		var winName= "_report_manual_";
		//var winURL= SERVER_URL + "/report/viewer/" + system + "/" + module +"/" + reportId ;
		// http://bizweb-local.lgdisplay.com:8080/lgrpt/viewer/lgcom/sample/testSample?jsonData={%22programList%22:%2225263307.json%22}
		var winURL= SERVER_URL + "/lgrpt/viewer/" + reportId ;
		var windowoption='resizable=yes,height='+ size.height +',width='+ size.width +',location=0,menubar=0,scrollbars=1, top=50, left=50';
		var form = $("#_open_report_temp_form_");

		if( !form.exists() ) {
			$("body").append("<form id='_open_report_temp_form_' method='POST'></form>");
			form = $("#_open_report_temp_form_");
		}
		$(form).empty();
		$(form).attr("action", winURL);
		$(form).attr("target",winName);
		$(form).append("<input type='hidden' name='jsonData' value='' />");
		$(form).append("<input type='hidden' name='menu' value='old' />");

		var reportParams = ""

		if( options.reportParam ){
			$.each( options.reportParam, function( key, value ){
				reportParams += key + ":" + value + ",";
			});

			reportParams = reportParams.slice(0, -1);

			$(form).append("<input type='hidden' name='reportParams' value='"+ reportParams +"' />");
		}

		var languageCode = SESSION_USER.languageCode;
		if( ["ko", "en", "cn", ].indexOf( languageCode ) < 0 ) {
			languageCode = "en";
		}

		if( languageCode == "cn" ) {
			languageCode = "zh";
		}

		$(form).append("<input type='hidden' name='AIReportLangScCd' value='"+ languageCode +"' />");
		$(form).find("input[name='jsonData']").val( JSON.stringify(fileListJson) );

		window.open('', winName,windowoption);
		$(form).submit();
	}
}

/*********************************************
  업무 Form 내부에 위치한 다수 폼을 초기화 하고 관리하기 위한 클래스

    var formInfo =  { forms : [ { menuId  : "M_LGUTLC_1135", container : myForm.select(".formA") },
                                { menuId  : "M_LGUTLC_1171", container : myForm.select(".formB") },
                                { menuId  : "M_LGUTLC_1171", container : myForm.select(".formC") } ],
                      initParam : formUtil.getValue(),
                      initIndex : 0 };

    var multiForm = new MultiForm( myForm, formInfo );
**********************************************/
var MultiForm = function( bizForm, info ) {
	var forms = info.forms ;

	init();

	function init() {
		var menuIdList = [];
		$(forms).each( function(){
			menuIdList.push( this["menuId"] );
		});

		//초기화 정보에 적힌 메뉴 정보를 토대로 서버로 부터 추가적인 정보를 인출해 온다.
		var map = new Map();
		transaction_sync("lgcom", "common/uiCommon/retriveMenuItemFromCache", { menuIdList : menuIdList }, function( data ){
			$( data["result"] ).each( function(){
				map.put( this["menuId"], this );
			});
		});

		//메인 메뉴에 있는 메뉴 목록에 서버로 부터 온 정보를 추가한다.
		var menuItems = LayoutManager.getMenuItems();
		$(forms).each( function(){
			var form = this;
			var menuItem = map.get( form["menuId"] );

			form["id"] = uuid();
			menuItems.put( form["id"], { systemCode : menuItem["systemCode"], name : menuItem["menuName"], programId : menuItem["programId"], menuId : form["menuId"] , urlAddr : menuItem["urlAddr"] } );

			var content = $("<div class='_content' id='"+ form["id"] +"' data-menuId='"+ form["menuId"] +"'><div class='spinner _loader'><span>Loading...</span></div></div>");
			form["container"].css({ "position" : "absolute", "top" : "0px", "left" : "0px", "left" : "0px", "right" : "0px", "bottom" : "0px" } ).append( content );

			//formId 를 container 에 세팅함
			form["container"].data( "formId", form["id"] );
			form["pageUrl"] = SERVER_URL + "/" + menuItem["systemCode"].toLowerCase() + "/service/" + form["menuId"];

		});

		if( info.initIndex != undefined ) {
			loadContent( forms[ info.initIndex ], function( form ){
				//이 탭에 들어있는 bizForm 을 가져와 active 를 호출한다.
				var bizForm = LayoutManager.getForm( form["id"] );
				if( bizForm == undefined ) return;
				try {
					bizForm.active( info.initParam );
				} catch( e ){ }
			});
		} else {
			$(forms).each( function( inx ){
				loadContent( this, function( form ){
					//이 탭에 들어있는 bizForm 을 가져와 active 를 호출한다.
					var bizForm = LayoutManager.getForm( form["id"] );
					if( bizForm == undefined ) return;
					try {
						bizForm.active( info.initParam );
					} catch( e ){ }
				});
			});
		}
	}

	function loadContent( form , callback ){
		if( form["loaded"] ) return;

		form["loaded"] = true;

		//최초 파라미터를 페이지 URL 파라미터로 전달한다( POST 방식 )
		var param  = info.initParam;
		param["bizFormId"] = form["id"];
		param["innerForm"] = 'Y';

		$( "#" + form["id"] ).load( form["pageUrl"] , param , function(responseText, statusText, xhr) {
			var innerForm = LayoutManager.getForm( form["id"] );
			//이 마스터 폼에 자식 폼을 추가 하여, 마스터폼이 삭제될 때, 자식폼의 자원도 삭제되도록 한다.
			bizForm.addInnerForm( innerForm );
			//마스터 폼을 새로 만들어지는 자식폼에 등록해서, 자식폼에서 마스터폼의 메소드를 수행가능하도록 한다.
			innerForm.setParentForm( bizForm );
			form["loaded"] = true;
			form["innerForm"] = innerForm;

			try {
				callback.call( this, form );
			} catch(e) {}
		});
	}

	//menuId 를 통해서 innerForm 을 호출하는 메소드
	this.getInnerForm = function( menuId ) {
		var innerForm;

		$(forms).each( function(){
			if( this["menuId"] == menuId && this["loaded"] == true ) {
				innerForm = this["innerForm"];
				return false;
			}
		});

		return innerForm;
	}


	/* 특정한 form 에 대해서 조회를 수행하는 함수 */
	this.search = function( formId, param ){
		if( param == undefined ) {
			param = {};
		}

		var form = LayoutManager.getForm( formId );
		if( form == undefined ) return;

		try {
			form.search( param );
		} catch( e ){ }
	}

	/* 등록된 모든 화면들에 대해서 전체 조회를 실시하는 함수 */
	this.searchAll = function( param ){
		if( param == undefined ) {
			param = {};
		}

		$(forms).each( function(){
			var form = LayoutManager.getForm( this["id"] );
			try {
				form.search( param );
			} catch( e ){ }
		});
	}

	/* 특정 화면이 활성화 ( 선택 ) 되는 때에 수행할 내용 을 담은 함수 */
	this.active = function( formId, param ){
		var form;
		$(forms).each( function(){
			if( this["id"] == formId ) {
				form = this;
				return;
			}
		});

		if( param == undefined ) {
			if( info["initParam"] ) {
				param = info["initParam"];
			} else {
				param = {};
			}
		}

		if( form["loaded"] ) {
			//이 탭에 들어있는 bizForm 을 가져와 active 를 호출한다.
			var bizForm = LayoutManager.getForm( formId );
			if( bizForm == undefined ) return;

			try {
				bizForm.active( param );
			} catch( e ){ }
		} else {
			loadContent( form, function(){
				//이 탭에 들어있는 bizForm 을 가져와 active 를 호출한다.
				var bizForm = LayoutManager.getForm( formId );
				if( bizForm == undefined ) return;
				try {
					bizForm.active( param );
				} catch( e ){ }
			});
		}
	}
}
