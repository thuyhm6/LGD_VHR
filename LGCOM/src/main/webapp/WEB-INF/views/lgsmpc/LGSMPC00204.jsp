<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00204.jsp
    프로젝트명 : LGD WCFW
    
    Copyright(c) 2016 LG CNS,  All rights reserved.

    설 명 : Calendar Example
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Summary</title>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp"%>
<script type="text/javascript">

var LGUTLC00204 = function(){
    var myForm = this;
    /*
    myForm.setManagedLayout({
        taskItems  :{ left:0, top:0 , width : 150 , bottom : 0 },
        calendarBase  :{ left: 160, top:0 , right : 0 , bottom : 0 }
    });
    */
    
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name : "taskItems",  left : 0, right : 0, top : 0, width : 150, bottom : 0 },		
		{ name : "calendarBase", left : "taskItems", right : 0, top : 0, bottom : 0}		
    ]);    

    myForm.select('.taskItems .fc-event').each(function() {
    	var item = this;
        // store data so the calendar knows to render an event upon drop
        $(item).data('event', {
            title: $.trim($(item).text()), // use the element's text as the event title
            stick: true // maintain when user navigates (see docs on the renderEvent method)
        });

        // make the event draggable using jQuery UI
        $(item).draggable({
            zIndex: 999, 
            revert: true,      // will cause the event to go back to its
            revertDuration: 0  //  original position after the drag
        });

    });
    
    
    var eventForm = new FormUtil(myForm, '.eventForm');

    //var test = eventForm.getValue;
   // trace(eventForm);
   
    //eventForm.setData({ startDate : "2016-11-02", endDate : ""});
    
    //var eventFormData = eventForm.getData();
  
     
    //myForm.select(".eventForm").data("eventid");  // -> aa
     
	 var startDate ;
	 var endDate;

	//날짜 설정
    var $dateFrom = myForm.select(".scheduleDate input[id='dateFrom']"),
		$dateTo   = myForm.select(".scheduleDate input[id='dateTo']"),
		$button   = myForm.select('.scheduleDate ._datePicker');
	
	uxp.datepicker.fromTo( $button, $dateFrom, $dateTo  );  	
	
    /* draggable schedulingHandler */
    $( function() {
        $( ".pop" ).draggable();
      }) ;
	
    var calendar = myForm.select('.calendarBase .calendar').fullCalendar({
    	
        height: "parent",
        width: "parent",
        customButtons: {
            myPrev: {
                icon: 'left-single-arrow',
                click: function() {
                	calendar.fullCalendar( 'prev' );
                	customButtonAction();
                }       
            },
            
            myNext: {
                icon: 'right-single-arrow',
                click: function() {
                	calendar.fullCalendar( 'next'  );
                	customButtonAction();    	
                }
            },
            
            myToday: {
                text: 'today',
                click: function() {
                	calendar.fullCalendar( 'today' );
                	//date = moment(calendar.fullCalendar('getDate')).format("YYYY-MM");
                	customButtonAction();
                }
            }
    	},
    	header: {
            left: 'myPrev,myNext,myoday',
            center: 'title',
            right: 'month,agendaWeek,agendaDay'
        },
        timeFormat: 'YYYY-MM-DD \n HH:mm',
        locale: 'ko',
        editable: true,
        droppable: true, // this allows things to be dropped onto the calendar
        drop: function() {
            // is the "remove after drop" checkbox checked?
            if( myForm.select('.taskItems .drop-remove').is(':checked') ) {
                // if so, remove the element from the "Draggable Events" list
                $(this).remove();
            }
        },

        eventLimit: true,
        
        //events: getCalendarEventList(),
        
        eventDrop: function(event) {
        	deleteCalendarEventList(calendar);
			saveCalendarEventList(calendar);
			schedulingHandler(event)

        },
        
        eventResize: function(event) {
        	deleteCalendarEventList(calendar);
			saveCalendarEventList(calendar);
        	schedulingHandler(event);
        },
        
        eventReceive: function(event){
        	deleteCalendarEventList(calendar);
			saveCalendarEventList(calendar);
        	schedulingHandler(event);        	
        },
          
        eventClick: function(event, element) {
        	schedulingHandler(event);
        }, 
        
    	/* event를 드래그해서 삭제하는 기능  **http://codepen.io/subodhghulaxe/pen/qEXLLr?editors=0010 */
        dragRevertDuration: 0,
        
        eventDragStop: function( event, jsEvent, ui, view ) {
            
            if(isEventOverDiv(jsEvent.clientX, jsEvent.clientY)) {
                calendar.fullCalendar('removeEvents', event._id);
                deleteCalendarEventList(calendar);
				saveCalendarEventList(calendar);
				
                var el = $( "<div class='fc-event'>" ).appendTo( '.taskItems-listing' ).text( event.title );
                el.draggable({
                  zIndex: 999,
                  revert: true, 
                  revertDuration: 0 
                });
                el.data('event', { title: event.title, id :event.id, stick: true });
            }
        }
     
        
    });
	
    /* initiating view */
    startDate = moment (calendar.fullCalendar('getView').start._d ).format('YYYYMMDD');
	endDate = moment (calendar.fullCalendar('getView').end._d ).subtract(1, "days").format('YYYYMMDD');
	getCalendarEventList();
    
    /* event deleting with dragging  **http://codepen.io/subodhghulaxe/pen/qEXLLr?editors=0010 */
  		var isEventOverDiv = function(x, y) {

        var external_events = $( '.taskItems' );
        var offset = external_events.offset();
        offset.right = external_events.width() + offset.left;
        offset.bottom = external_events.height() + offset.top;

        // Compare
        if (x >= offset.left
            && y >= offset.top
            && x <= offset.right
            && y <= offset .bottom) { return true; }
        return false;

    }
    
    /* save & load action control : 삭제예정 */
    myForm.addEvent("click", ".taskItems button", function( event) {
    	var action = $(event.target).data("action");
    	
    	switch( action ) {
    	
    	/* 
    	case "save" :
    		//변경된 이벤트 존재시 저장
    		//if ( changedSchedule.length != 0 ){
    		if ( true ){
    			//DB 데이터와 같은 지 확인
    		
    			Message.confirm('<lgcom:message code="The schedule already exists. Would you overwrite?"/>', function() {
    				
    				deleteCalendarEventList(calendar);
    				saveCalendarEventList(calendar);
  					
  					//changedSchedule = [];
    				Message.notify('<lgcom:message code="The schedule successfully saved!"/>');

    			});
    		}
    		else{ 		
    			Message.alert('<lgcom:message code="The schedule has not been changed."/>');
    		}
    		break;
    		
    	case "load" :
   			//로드시 변경된 이벤트 존재할 경우 확인 
   			if( true ){
   			//if( true ){
   				Message.confirm('<lgcom:message code="The unsaved changes are working in a document that details may be lost. Would you load?"/>', function() {
	
   					calendar.fullCalendar('removeEvents');
   					//changedSchedule = [];
    				getCalendarEventList();
    				
    				
       				Message.alert('<lgcom:message code="The schedule successfully loaded!"/>');
       			});
   			}
   			
   			else{
   				Message.alert("The schedule has not been changed.");
   			}
   			break;
   		
   		*/
    	case "clear" :
    		Message.confirm('<lgcom:message code="Would you delete all your schedule?"/>', function() {
    			
    			calendar.fullCalendar('removeEvents');
        		deleteCalendarEventList(calendar);
        		//saveCalendarEventList(calendar);
				Message.alert('<lgcom:message code="The schedule successfully cleared!"/>');
    		});
    		
    		break; 
    		
    		
		case "test" :
		    
    		break;
    	
    	}
    });
    
    /* custom buttons action control */
    function customButtonAction() {
    	startDate = moment (calendar.fullCalendar('getView').start._d ).format('YYYYMMDD');
    	endDate = moment (calendar.fullCalendar('getView').end._d ).subtract(1, "days").format('YYYYMMDD');
    	getCalendarEventList();
    	$('.pop').css({opacity: 1, visibility: "hidden"}).animate({opacity: 0}, 0);
    }
    
    /* schedulingHandler action control */
    myForm.addEvent("click", ".pop button", function( event) {
    	
    	var action = $(event.target).data("action");
    	
    	switch( action ) {

		case "confirm" :
			
			var id = eventForm.getValue().eventId,
			 	startDate = eventForm.getValue().startDate,
			 	endDate = eventForm.getValue().endDate,
			 	title = eventForm.getValue().title,
			 	allDay = $('.allDayFlag input').is(':checked');
				
			var event = calendar.fullCalendar("clientEvents", id);
			
			event.title = title;
			event.start = moment( startDate ).format("YYYY-MM-DD HH:mm");
			event.end = moment( endDate ).add(1, 'days').format("YYYY-MM-DD HH:mm");
			event.allDay = allDay;

			calendar.fullCalendar( 'removeEvents', id );
			calendar.fullCalendar( 'renderEvent', event , true  );
			deleteCalendarEventList(calendar);
			saveCalendarEventList(calendar);

			$('.pop').css({opacity: 1, visibility: "hidden"}).animate({opacity: 0}, 0);

			break;
			
		case "delete":
			id = eventForm.getValue().eventId
			calendar.fullCalendar('removeEvents', id);
            deleteCalendarEventList(calendar);
            saveCalendarEventList(calendar);
            $('.pop').css({opacity: 1, visibility: "hidden"}).animate({opacity: 0}, 0);
			break;
		
		case "close":
			
			$('.pop').css({opacity: 1, visibility: "hidden"}).animate({opacity: 0}, 0);
			break;
    		
    	}
    	
    });
  
    /* transferring event data to schedulingHandler */
    function schedulingHandler(event){
    	
    	$('.pop').css({opacity: 0, visibility: "visible"}).animate({opacity: 1.0}, 0);

    	eventForm.setValue({
    		"eventId"	:	event._id,
    		"startDate"	  :	moment( event.start ).format("YYYY-MM-DD HH:mm"), 
			"endDate"	  :	( event.end == null ? moment( event.start ).format("YYYY-MM-DD HH:mm") : moment( event.end ).subtract(1, 'days').format("YYYY-MM-DD HH:mm") ), 
			"title"  	  :	event.title
		});   
    	
		$('.allDayFlag input').prop("checked", event.allDay);
		

    }
	
    /* saving schedule in DB */
 	function saveCalendarEventList(calendar) {
 		
    	var info = [];
		var events = calendar.fullCalendar("clientEvents");
		
    	$(events).each( function(){
    		
    		info.push({"allDay"	:	( this.allDay == true ? "Y" : "N" ),
    				   "start"	:	moment( this.start ).format("YYYY-MM-DD HH:mm"), 
    				   "end"	:	( this.end == null ? moment( this.start ).format("YYYY-MM-DD HH:mm") : moment( this.end ).format("YYYY-MM-DD HH:mm") ), 
    				   "title"	:	this.title});
    	});
    
    	var param = { events : info };
    	
    	transaction('lgcom','lgsmpc/LGSMPC00204/insertCalendarEventList', param, function(data){

    	});
    }
    
 	/* loading schedule from DB */
    function getCalendarEventList() {

    	 //startDate =  moment (calendar.fullCalendar('getView').start._d ).format('YYYYMMDD');
    	 //endDate = moment (calendar.fullCalendar('getView').end._d ).format('YYYYMMDD');
    	 
    	  /* var startDate = moment(date).startOf('month').startOf('week').format("YYYYMMDD"),
      		endDate =  moment(date).endOf('month').endOf('week').format("YYYYMMDD");  */
 
        var param = { currentDate : {"startDate" : startDate, "endDate" : endDate } } 
      	//var param = { currentDate : date }
        


    	transaction('lgcom','lgsmpc/LGSMPC00204/retrieveCalendarEventList', param, function(data){
    		
    		var list = data["result"];
			var array = [];	

    		$(list).each(function(){

                var allDayFlag = ( this["calendarScheduleTypeCode"]=="Y" ) ? true : false;
    			array.push({allDay:allDayFlag, start:this["scheduleStartDate"], end:this["scheduleCompletionDate"], title:this["scheduleDesc"]});
    		});

    		calendar.fullCalendar('removeEvents');
   			calendar.fullCalendar('addEventSource', {events: array});

    		//calendar.fullCalendar('addEventSource', {events: schedule});
    		
    	});
    }
    
    /* deleting schedule in DB */
    function deleteCalendarEventList(calendar) {
    	
    	/* var startDate = moment(date).startOf('month').startOf('week').format("YYYYMMDD"),
  			endDate =  moment(date).endOf('month').endOf('week').format("YYYYMMDD"); */
    	
    	var param = { currentDate : {"startDate" : startDate, "endDate" : endDate } };       	
      	//var param = {currentDate : date};
    	//var events = calendar.fullCalendar("clientEvents");
    	//var param = { events : events };
    	transaction('lgcom','lgsmpc/LGSMPC00204/deleteCalendarEventList', param, function(data){

    	});
    }
}

	LGUTLC00204.prototype = new BizForm("${param.bizFormId}");

	$(document).ready(function() {
		launch(function() {
			var form = new LGUTLC00204();
			form.init();
		});
	});
</script>

<style>
.taskItems {
	float: left;
	width: 150px;
	height: 100%;
	padding: 0 10px;
	border: 1px solid #ccc;
	background: #eee;
	text-align: left;
}

.taskItems h4 {
	font-size: 16px;
	margin-top: 0;
	padding-top: 1em;
}

.taskItems .fc-event {
	margin: 5px 0;
	cursor: pointer;
	border-radius: 0px;
	padding: 5px;
}

.taskItems p {
	margin: 1.5em 0;
	font-size: 11px;
	color: #666;
}

.taskItems p input {
	margin: 0;
	vertical-align: middle;
}

.calendar .fc-day-top.fc-sun .fc-day-number {
	color: #F20000;
}

.pop { position: absolute; top: 50%; right: 0px; width: 600px; height: 300px; text-align:center; z-index:1 }



</style>
</head>
<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Calendar</h2>
	</div>
	<div class="taskItems">
		<h4>Draggable Events</h4>
		<div class='fc-event'>My Event 1</div>
		<div class='fc-event'>My Event 2</div>
		<div class='fc-event'>My Event 3</div>
		<div class='fc-event'>My Event 4</div>
		<div class='fc-event'>My Event 5</div>
		<p>
			<input type='checkbox' class='drop-remove' /> <label
				for='drop-remove'>remove after drop</label>
		</p>

		<!-- 
		<button class="btn btn-default btn-xs" data-action="save">Save</button>
		<button class="btn btn-default btn-xs" data-action="load">Load</button> 
		-->
		<button class="btn btn-default btn-xs" data-action="clear">Clear</button>
		<p />
		<button class="btn btn-default btn-xs" data-action="test">Test</button>
	</div>

	<div class="calendarBase">
		<div class="calendar">
		</div>
		
		<div class="pop" id="pop" style="visibility: hidden">
			<div>
				<form class="pop-content form eventForm" data-eventid="aa" >
					<table class="table">
						<colgroup>
							<col width="180">
							<col width="210">
							<col width="120">
							<col width="*">
						</colgroup>
						<tbody>
							
										<input type="hidden" name="eventId" placeholder="" />
									
							<tr>
								<th scope="row"><label><lgcom:message code="eventName" /></label></th>
								<td colspan="3">
									<div class="form-inline">
										<input type="text" name="title" class="form-control input-sm size_80" placeholder="" />
									</div>
								</td>
							</tr>
							<tr>
								<th scope="row"><label><lgcom:message code="scheduleDate" /></label></th>
								<td colspan="3">
									<div class="form-inline scheduleDate" >
										<input type="text" id="dateFrom" name="startDate" class="form-control input-sm size_120" placeholder="YYYY-MM-DD HH:mm" />
										~ 
										<input type="text" id="dateTo" name="endDate" class="form-control input-sm size_120" placeholder="YYYY-MM-DD HH:mm" />
										<button type="button" id="setDate" class="btn btn-ico _datePicker" aria-label="calendar">
											<span class="ico ico-calendar" aria-hidden="true"></span>
										</button>
									</div>
								</td>
							</tr>
							<tr>
								<th scope="row"><label><lgcom:message code="allDayFlag" /></label></th>
								<td colspan="3">
									<div class="form-inline">
										<div class="checkbox checkbox-uxp checkbox-inline allDayFlag">
											<input type="checkbox" name="allDayFlag" id="inlineCheckbox1" value="Y">
											<label for="inlineCheckbox1">allDayFlag</label>
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<td colspan="3">
									<div class="form-inline">
										<button class="btn btn-default btn-xs" data-action="confirm">Confirm</button>
										<button class="btn btn-default btn-xs" data-action="delete">Delete</button>
										<button class="btn btn-default btn-xs" data-action="close">Close</button>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</form>
			</div>
		</div>
	</div>
	
</section>
</div>
</body>
</html>