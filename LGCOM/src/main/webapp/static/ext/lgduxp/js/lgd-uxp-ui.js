/**
 * UXP UI COMMON
 * 작성자: 노종민
 * 최초작성일: 16.05.16
 */

//ie console.log
var console = window.console || {log: function () {}};

//init uxp
var uxp = uxp || {};

(function($) {
    uxp = {
        funcCheck: function(func) {
            if (typeof func !== 'undefined' && typeof func !== 'function') {
                throw {
                    name: 'TypeError',
                    message: 'is not function'
                };
            }
        },
        log: function(key, value) {
            console.log(key + ' : ' + value);
        },
        jsonSort: function(data, prop, asc) {
            if (typeof data !== 'object') {
                return false;
            }
            data = data.sort(function(a, b) {
                if (asc) {
                    return (a[prop] > b[prop]) ? 1 : ((a[prop] < b[prop]) ? -1 : 0);
                } else {
                    return (b[prop] > a[prop]) ? 1 : ((b[prop] < a[prop]) ? -1 : 0);
                }
            });
        },
        // 쿠키 세팅 함수
        setCookie: function ( sName, sValue, nDays ) {
            var expires = "";
            if ( nDays ) {
                var d = new Date();
                d.setTime( d.getTime() + nDays * 24 * 60 * 60 * 1000 );
                expires = '; expires=' + d.toGMTString();
            }

            document.cookie = sName + '=' + sValue + expires + '; path=/';
        },
        // 쿠기 조회 함수
        getCookie: function (sName) {
            var re = new RegExp('(\;|^)[^;]*(' + sName + ')\=([^;]*)(;|$)');
            var res = re.exec( document.cookie );
            return res !== null ? res[3] : null;
        },
        // 쿠키 삭제 함수
        removeCookie: function ( name ) {
            setCookie( name, '', -1 );
        },
        messageBox: {
            setDefaults: function() {
                ko = {
                    OK      : '확인',
                    CANCEL  : '취소',
                    CONFIRM : '확인'
                };
                bootbox.addLocale('ko', ko);
                bootbox.setDefaults({
                    locale: 'ko',
                    closeButton: true,
                    className: 'uxp-modal'
                });
            },
            alert: function(options, callback) {
                try {
                    uxp.funcCheck(callback);
                    this.setDefaults();
                    bootbox.alert({
                        size: 'small',
                        buttons: {
                            'ok': {
                                className: 'btn-primary btn-darkgray btn-sm'
                            }
                        },
                        title: options.title || 'Information',
                        message: options.msg,
                        callback: callback
                    });
                } catch(e) {
                    console.log(e.name + ': ' + e.message);
                }
            },
            confirm: function(options, callback) {
                if (arguments.length == 2 && typeof title == 'function') {
                    callback = title;
                    title = 'Information';
                }
                try {
                    uxp.funcCheck(callback);
                    this.setDefaults();
                    bootbox.confirm({
                        buttons: {
                            'confirm': {
                                className: 'btn-primary btn-darkgray btn-sm'
                            },
                            'cancel': {
                                className: 'btn-gray btn-sm'
                            }
                        },
                        title: options.title || 'Information',
                        message: options.msg,
                        callback: callback
                    });
                } catch(e) {
                    console.log(e.name + ': ' + e.message);
                }
            },
            prompt: function(title, callback) {
                try {
                    uxp.funcCheck(callback);
                    this.setDefaults();
                    bootbox.prompt({
                        buttons: {
                            'cancel': {
                                className: 'btn-gray btn-sm'
                            },
                            'confirm': {
                                className: 'btn-primary btn-darkgray btn-sm'
                            }
                        },
                        title: title,
                        callback: callback
                    });
                } catch(e) {
                    console.log(e.name + ': ' + e.message);
                }
            }
        },
        openPop: function(url, name, popWidth, popHeight) {
            var scWidth = screen.availWidth,
                scHeight = screen.availHeight,
                left = (parseInt(scWidth)-popWidth)/2,
                top = (parseInt(scHeight)-popHeight)/2;

            name = name || "Popup";

            window.open(url, name, 'width=' + popWidth + ', height=' + popHeight + ', top=' + top + ', left=' + left);
        },
        getWinWidth: function () {
            return $(window).outerWidth(true);
        },
        getWinHeight: function () {
            return $(window).outerHeight(true);
        },
        getNextHeight: function(obj) {
            var nextHeight = 0;

            $(obj).nextAll().each(function(i, el) {
                nextHeight += $(el).outerHeight(true);
            });

            return nextHeight;
        },
        setHeight: function(obj, next, contain) {
            var offsetTop, bottom, scrollHeight, containHeight;

            if (contain) {
                containHeight = $(contain).offset().top + $(contain).outerHeight();
                bottom = parseInt($(contain).css('padding-bottom')) || 0;
            } else {
                containHeight = this.getWinHeight();
                bottom = parseInt($('.page-content').css('padding-bottom')) || 0;
            }

            offsetTop = obj.offset().top;
            next = next || 0;

            return (containHeight - offsetTop - bottom - next) + 'px';
        },
        autoHeight: function(obj, minHeight, contain) {
            var that, $target;

            that = this;
            $target = $(obj);
            $target.css('min-height', minHeight || 300);

            if ( $target.next().length) {
                if ($target.next().hasClass('ui-resizable-handle')) {
                    $target.css({
                        height: that.setHeight($target, '', contain)
                    });
                } else {
                    $target.css({
                        height: that.setHeight($target, uxp.getNextHeight($target), contain)
                    });
                }
            } else {
                $target.css({
                    height: that.setHeight($target, '', contain)
                });
            }

            if ($('.mdi-tabs').length === 0) {
                if ($('.frame-content').length > 0) {
                    $('body').css('overflow', 'hidden');
                } else {
                    $('body').css('overflow-y', 'auto');
                }
            } else {
                $('body').css('overflow', 'hidden');
            }
        },
        setMotionLeft: function(options, target, wrap) {
            var that = this;
            if (options.offset <= 0) {
                //that.messageBox.alert({msg: '메뉴에 처음 입니다.'});
                return false;
            } else {
                options.offset -= options.INTERVAL;
                target.stop().animate({
                    left: '-' + options.offset
                });
            }
        },
        setMotionRight: function(options, target, wrap) {
            var that = this;
            var offsetRight = target.outerWidth() - wrap.outerWidth();

            if (options.offset > offsetRight) {
                //that.messageBox.alert({msg: '메뉴에 끝 입니다.'});
                return false;
            } else {
                options.offset += options.INTERVAL;
                target.stop().animate({
                    left: '-' + options.offset
                });
            }
        },
        naviMotion: function(opts) {
            var that = this, options, defaults;

            if (!opts) opts = {};

            defaults = {
                offset: 0,
                INTERVAL: 100,
                type: null,
            };

            options = $.extend({}, defaults, opts);

            switch (options.type) {
                case 'gnb':
                    this.gnbMotionWrap = $('.navbar .scroll-wrap');
                    this.gnbMotionTarget = $('.gnb');
                    this.gnbMotionControl = $('.gnb-control');

                    this.gnbMotionControl.children('.grd-prev').on('click', function () {
                        that.setMotionLeft(options, that.gnbMotionTarget, that.gnbMotionWrap)
                    });

                    this.gnbMotionControl.children('.grd-next').on('click', function () {
                        that.setMotionRight(options, that.gnbMotionTarget, that.gnbMotionWrap)
                    });
                    break;
                case 'mdi':
                    this.mdiMotionWrap = $('.mdi-tabs .scroll-wrap');
                    this.mdiMotionTarget = this.mdiMotionWrap.children('ul');
                    this.mdiMotionControl = $('.mdi-control');

                    this.mdiMotionControl.children('.prev').on('click', function () {
                        that.setMotionLeft(options, that.mdiMotionTarget, that.mdiMotionWrap)
                    });

                    this.mdiMotionControl.children('.next').on('click', function () {
                        that.setMotionRight(options, that.mdiMotionTarget, that.mdiMotionWrap)
                    });
                    break;
            }
        },
        datepicker: {
            monthPicker: function(selector, opts) {
                var defaults, options;

                if (!opts) opts = {};

                defaults = {
                    Button: false,
                    MonthFormat : "yy-mm",
                }

                options = $.extend({}, defaults, opts);

                $(selector).MonthPicker(options);
            },
            single: function(selector, target, opts) {
                var defaults, options;

                if (!opts) opts = {};

                defaults = {
                    autoClose: true,
                    singleDate : true,
                    singleMonth: true,
                    showShortcuts: false,
                    getValue: function() {
                        if ($(target).val())
                            return $(target).val();
                        else
                            return '';
                    },
                    setValue: function(s)
                    {
                        $(target).val(s);
                    }
                };

                $.dateRangePickerLanguages.ko.shortcuts = '';

                options = $.extend({}, defaults, opts);

                $(selector).dateRangePicker(options);
            },
            fromTo: function(selector, targetFrom, targetTo, opts) {
                var defaults, options;

                if (!opts) opts = {};

                defaults = {
                    autoClose: false,
                    separator : ' ~ ',
                    getValue: function() {
                        if ($(targetFrom).val() && $(targetTo).val() )
                            return $(targetFrom).val() + ' ~ ' + $(targetTo).val();
                        else
                            return '';
                    },
                    setValue: function(s, s1, s2) {
                        $(targetFrom).val(s1);
                        $(targetTo).val(s2);
                    },
                    showShortcuts: true,
                    shortcuts:
                    {
                        'next-days': [3,5,7],
                        'next' : ['week','month']
                    }
                };

                $.dateRangePickerLanguages.ko.shortcuts = '';

                options = $.extend({}, defaults, opts);

                $(selector).dateRangePicker(options);
            }
        },
        moveTimeline: function(obj, msg1, msg2) {
            var $timeline, $schedule, $up, $down, tlHeight, intervalHeight, intervalTemp;

            $timeline = $(obj);
            $schedule = $timeline.closest('.schedule-wrap');
            $up = $schedule.find('.control-up');
            $down = $schedule.find('.control-down');
            tlHeight = $timeline.height();
            intervalHeight = $timeline.find('li').height();
            intervalTemp = 0;

            $up.on('click', function(e) {
                e.preventDefault();
                if (intervalTemp > 0) {
                    intervalTemp -= intervalHeight;
                } else {
                    uxp.messageBox.alert({msg: typeof msg1 != 'undefined' ? msg1 : '처음 입니다.'});
                }
                $timeline.stop().animate({
                    scrollTop: intervalTemp + 'px'
                }, 'fast');
            });

            $down.on('click', function(e) {
                e.preventDefault();

                var scrollbottom = $timeline.children('ul').height() - tlHeight;

                if (intervalTemp < scrollbottom) {
                    intervalTemp += intervalHeight;
                } else {
                    uxp.messageBox.alert({msg: typeof msg2 != 'undefined' ? msg2 : '마지막 입니다.'});
                }

                $timeline.stop().animate({
                    scrollTop: intervalTemp + 'px'
                }, 'fast');
            });
        },
        /**
         * LNB
         * LNB영역에 마우스 아웃시 메뉴가 초기화 된다.
         * 메뉴를 클릭하지 않았는데도 이벤트가 적용되기 때문에 bool 변수로 메뉴 클릭했을때만
         * 마우스 아웃 이벤트가 적용되게 한다.
         */

        lnb: function(bool) {
            var that = this,
                lnbFlag = false,
                tabTitle = null,
                tabInx = 0,
                tabUrl = null,
                len;

            this.lnb = $('.lnb');
            this.initLnb(this.lnb);

            $(document).on('click', '.lnb a', function (e) {
                var isUl = $(this).siblings('ul').length;

                if (isUl) {
                    e.preventDefault();
                    lnbFlag = true;
                    $(this).parent('li').siblings().removeClass('active').children('ul').slideUp('fast')
                    .end().children('a').children('.fa').removeClass('fa-angle-up').addClass('fa-angle-down');
                    $(this).children('.fa').toggleClass('fa-angle-up fa-angle-down');
                    $(this).parent('li').toggleClass('active').end().siblings('ul').slideToggle('fast');
                } else {
                    that.lnb.find('.current').removeClass('current');
                    $(this).parent().addClass('current');

                    if ($(this).data('mdi')) {
                        e.preventDefault();
                        tabTitle = $(this).text();
                        tabInx = $(this).data('index');
                        tabUrl = $(this).attr('href');
                        len = $('.ui-tabs-nav > li').length;

                        if (len >= 10) {
                            uxp.messageBox.alert({msg: '더이상 추가 할 수 없습니다.'});
                            return false;
                        }

                        that.mdi.addTab(tabTitle, tabUrl, tabInx);
                        $(this).data('mdi', false);
                    } else if ($(this).data('mdi') === false) {
                        e.preventDefault();
                        that.mdi.selecteTab(this);
                    }
                }
            });

            if (bool) {
                this.lnb.on('mouseleave', function() {
                    if (lnbFlag) {
                        $(this).find('.active').find('a > i').toggleClass('fa-angle-up fa-angle-down');
                        $(this).find('.active').removeClass('active').end().find('ul > li > ul').slideUp('fast');
                        that.initLnb(that.lnb);
                        lnbFlag = false;
                    }
                });
            }
        },
        initLnb: function(obj) {
            obj.find('.current').parents('li').addClass('active');
            obj.find('.active > ul').slideDown('fast');
            obj.find('.active > a > i').removeClass('fa-angle-down').addClass('fa-angle-up');

            //즐겨찾기 sort
            $('.favorite').find('ul').sortable({
                axis: 'Y',
                containment: 'parent'
            });
        },
        /**
         * 사이드바 토글 함수
         * @param  sidebar position
         * @param  sidebar toggle button position
         * @param  main container position
         */
        sidebarToggle: function(obj, sidebarPosition, buttonPosition, mainPosition) {
            var that = this;

            if (obj.hasClass('closed')) {
                $('.page-header').addClass('extended');

                if (obj.hasClass('left')) {
                    $('.page-content').addClass('extend-left');

                    if ($('.page-content').hasClass('frame-content')) {
                        $('iframe.frame-container').contents().find('.page-content').addClass('extend-left');
                    }

                    if (that.sidebarResizable) {
                        $('.sidebar.left').removeAttr('style');
                        if ($('.page-content').hasClass('mdi-content')) {
                            $('.mdi-content').removeAttr('style');
                        } else {
                            $('.page-content.extend-left').removeAttr('style');
                        }
                    }
                } else if (obj.hasClass('right')) {
                    $('.page-content').addClass('extend-right');
                }
            } else {
                $('.page-header').removeClass('extended');

                if (obj.hasClass('left')) {
                    if ($('.page-content').hasClass('frame-content')) {
                        $('iframe.frame-container').contents().find('.page-content').removeClass('extend-left');
                    }
                    $('.page-content').removeClass('extend-left');
                } else if (obj.hasClass('right')) {
                    $('.page-content').removeClass('extend-right');
                }
            }
        },
        sidebarWidth: null,
        sidebar: function(opt) {
            var that = this;

            this.sideBar = $('.sidebar');
            this.mainWrap = $('.page-content');

            if (opt && typeof opt === 'object' && opt.resizable) {
                $( opt.targetID ).resizable({
                    handles: 'e',
                    minWidth: 200,
                    maxWidth: opt.maxWidth ? opt.maxWidth : 400,
                    create: function(event, ui) {
                        that.sidebarResizable = true;
                    },
                    resize: function() {
                        var sideWidth = that.sideBar.outerWidth();
                        that.mainWrap.css('margin-left', sideWidth)
                    },
                    start: function(event, ui) {
                        //console.log('start');
                    },
                    stop: function(event, ui) {
                        //console.log('stop')
                        $('iframe').css('pointer-events', 'auto');
                    }
                });

                $(document).on('mousedown', '.ui-resizable-handle.ui-resizable-e', function() {
                    $('iframe').css('pointer-events', 'none');
                });
            }

            $('.btn-side-toggle').on('click', function (e) {
                that.sideToggleBtn = $(this);
                that.sidebarWidth = $('.sidebar.left').outerWidth();

                $(this).closest('.sidebar').toggleClass('closed');
                $(this).children().toggleClass('fa-angle-left fa-angle-right');
                that.sidebarToggle($(this).closest('.sidebar'));

                if (opt && typeof opt === 'object') {
                    if (typeof opt.callback === 'function') {
                        opt.callback.call(this);
                    }
                }
            });
        },
        /**
         * [searchBoxToggle description]
         * @param  {[type]} obj           [description]
         * @param  {[type]} target        [description]
         * @param  {[type]} class1        [description]
         * @param  {[type]} class2        [description]
         * @param  {[type]} scrollBoolean [윈도우 스크롤영역을 유지 할 필요가 있을경우 Boolean 값 'true'를 줄 경우 윈도우 스크롤에 영향을 주지 않는다.]
         * @return {[type]}               [description]
         */
        searchBoxToggle: function(obj, target, class1, class2, scrollBoolean) {
            if (typeof scrollBoolean == 'undefined') {
                $('body').css('overflow-y', 'hidden');
            }

            if (target.is(':visible')) {
                $(obj).children().toggleClass(class1 + ' ' + class2);
            } else {
                $(obj).children().toggleClass(class2 + ' ' + class1);
            }

            $.fx.off = true;

            target.toggle(function() {
                if (typeof uxp.mdi.mdiTabs === null || typeof uxp.mdi.mdiTabs === 'undefined') {
                    $(window).resize();
                } else {
                    var activeInx = uxp.mdi.mdiTabs.tabs().find('.ui-tabs-active').attr('aria-controls').replace(/[^0-9]/g, '');

                    if (target.siblings('.grid-wrap').is(':visible')) {
                        uxp.mdi.mdiTabs.find('#mdiFrame-' + activeInx, document)[0].contentWindow.resizeGrid('.grid-wrap');
                    }
                }
                $.fx.off = false;
            });
        },
        searchBox: function(scrollBoolean) {
            var that, $searchDetail, activeInx, currentInx;

            that = this;
            this.partFoldingBtn = $('.partFoldingBtn');
            this.fullFoldingBtn = $('#fullFoldingBtn');
            this.searchBox = $('.search-wrap');

            this.searchBox.each(function(i, el) {
                if ($(el).find('table tbody > tr').length > 2) {
                    $(el).find('table tbody > tr').each(function(i, el) {
                        if (i > 1) {
                            $(el).addClass('hidden-row');
                        }
                    })
                } else {
                    $(el).find('.partFoldingBtn').hide();
                }
            })

            //전체 검색영역 토글
            this.fullFoldingBtn.on('click', function(e) {
                isMDI = $('#tabs').find('.ui-tabs-nav').children().length ? true : false;

                if (isMDI) {
                    activeInx = that.mdi.mdiTabs.tabs().find('.ui-tabs-active').attr('aria-controls').replace(/[^0-9]/g, '');
                    that.searchBox = that.mdi.mdiTabs.find('#mdiFrame-' + activeInx, document).contents().find('.search-wrap');
                }
                that.searchBoxToggle(this, that.searchBox, 'ico-search-close', 'ico-search-open', scrollBoolean);
            });

            this.partFoldingBtn.on('click', function(e) {
                $searchDetail = $(this).closest('.search-wrap').find('.hidden-row');
                that.searchBoxToggle(this, $searchDetail, 'fa-plus', 'fa-minus', scrollBoolean);
            });
        },
        bsCollepse: function(e) {
            $(e.target).prev('.panel-heading').find('span.fa').toggleClass('fa-angle-down fa-angle-up');
        },
        changeTheme: function() {
            var that = uxp;

            $('.navbar').toggleClass('navbar-inverse');
            $('.sidebar').toggleClass('sidebar-inverse');
            that.setCookie('theme', 'inverse', 30);
        },
        changeSize: function() {
            var that = uxp;

            $('body').toggleClass('page-sm');
            if ($('.page-content').find('iframe').length) {
                $('iframe').contents().find('body').toggleClass('page-sm');
            }
            $(window).resize();
        },
        changeFont: function() {
            $('body').toggleClass('lg-smart');
            if ($('.page-content').find('iframe.mdiFrame').length) {
                $('iframe').contents().find('body').toggleClass('lg-smart');
            }
        },
        loading: function() {
            $(window).on('load', function() {
                $('.page-loading').hide();
            });
        },
        dataFormat: function() {
            //숫자포맷
            $('[data-numeral]', document).each(function(i, el) {
                var cleaveNumeral = new Cleave(el, {
                    numeral: true,
                    numeralDecimalScale: 5,
                    delimiter: '',
                    numeralThousandsGroupStyle: 'thousand'
                });
            });

            //통화포맷
            $('[data-currency]', document).each(function(i, el) {
                var cleaveCurrency = new Cleave(el, {
                    numeral: true,
                    numeralDecimalScale: 5,
                    numeralThousandsGroupStyle: 'thousand'
                });
            });

            //날짜포맷
            $('[data-date]', document).each(function(i, el) {
                var cleaveDate = new Cleave(el, {
                    delimiter: '-',
                    date: true,
                    datePattern: ['Y', 'm', 'd']
                });
            });

            //전화번호 포맷
            $('[data-phone]', document).each(function(i, el) {
                var cleavePhone = new Cleave(el, {
                    phone:true,
                    delimiter: '-',
                    phoneRegionCode: 'KR'
                });
            });
        },
        mdi: {
            closeTabs: function(obj) {
                var that = this,
                    inx = $(obj).closest('li').attr('aria-controls').replace(/[^0-9]/g, ''),
                    panelId = $(obj).closest('li').remove().attr('aria-controls');

                uxp.lnb.find('[data-index="' + inx + '"]').data('mdi', true);

                that.mdiTabs.find("#" + panelId ).children('iframe').attr('src', 'about:blank');
                setTimeout(function(){
                    that.mdiTabs.find("#" + panelId ).off().remove();
                }, 100);

                this.mdiList.find('[data-index="' + inx + '"]').closest('li').remove();
                that.mdiTabs.tabs('refresh');

                if (this.mdiTabs.find('.ui-tabs-nav').width() < $('.scroll-wrap').width()) {
                    $('.mdi-tabs .scroll-wrap').removeClass('movable');
                }
            },
            closeOtherTabs: function(obj) {
                var that = this;

                that.mdiTabs.find('.nav-tabs li').each(function(i, el) {
                    var inx, panelId;

                    if ($(el).attr('aria-labelledby') != obj.attr('id')) {
                        inx = $(el).attr('aria-controls').replace(/[^0-9]/g, '');
                        panelId = $(el).remove().attr('aria-controls');
                        uxp.lnb.find('[data-index="' + inx + '"]').data('mdi', true);
                        that.mdiTabs.find("#" + panelId ).children('iframe').attr('src', 'about:blank');
                        setTimeout(function(){
                            that.mdiTabs.find("#" + panelId ).off().remove();
                        }, 100);

                        that.mdiList.find('[data-index="' + inx + '"]').closest('li').remove();
                    }
                });

                that.mdiTabs.tabs('refresh');
            },
            closeAllTabs: function() {
                var that = this,
                    $tabs = that.mdiTabs.find('.ui-tabs-nav'),
                    $panels = $('.mdi-contents'),
                    iframe = $('iframe'),
                    inx = 0;

                if ($tabs.length === 0) {
                    uxp.messageBox.alert({msg: '닫을 탭이 없습니다.'});
                } else {
                    uxp.messageBox.confirm({msg: '전체 탭을 닫으시겠습니까?'}, function(result) {
                        if (result) {

                            for (inx; inx < iframe.length; inx++) {
                                $('iframe').eq(inx).attr('src', 'about:blank');
                            }

                            setTimeout(function(){
                                $tabs.off().empty();
                                $panels.off().empty();
                                that.mdiList.off().empty();
                                that.mdiList.hide();
                                $('#fullFoldingBtn').children().removeClass('ico-search-open').addClass('ico-search-close');
                                uxp.lnb.find("a").data('mdi', true).parent('li').removeClass('current');
                            }, 100);
                        }
                    });
                }
            },
            _dialogLeft: 0,
            _dialogtop: 0,
            _dialogMode: function() {
                var that = this;

                this.mdiTabs.find('.ui-tabs-nav').sortable( "disable" );

                var d = $('.ui-tabs-panel').dialog({
                    appendTo: ".mdi-contents",
                    create: function( event, ui ) {
                        that.mdiTabs.tabs( "disable" );
                    },
                    minWidth: 1080,
                    minHeight: 500,
                    open: function(event, ui) {
                        var vDlg = $(event.target).parent();
                        var vCont = $('.mdi-contents');
                        var opt = { my: "left top", at: "left+" + that._dialogLeft + " top+" + that._dialogtop, of: vCont };

                        vDlg.draggable("option","containment", vCont);
                        vDlg.draggable( "option", "scroll", true );
                        $(this).dialog( "option", "position", opt);

                        that._dialogLeft = that._dialogLeft + 100;
                        that._dialogtop = that._dialogtop + 30;
                    }
                }).dialogExtend({
                    "closable" : true,
                    "maximizable" : true,
                    "minimizable" : true,
                    "collapsable" : true,
                    "dblclick" : "collapse",
                    "titlebar" : "transparent",
                    "minimizeLocation" : "right",
                    "icons" : {
                        "close" : "fa fa-times",
                        "maximize" : "ui-icon-circle-plus",
                        "minimize" : "ui-icon-circle-minus",
                        "collapse" : "ui-icon-triangle-1-s",
                        "restore" : "ui-icon-bullet"
                    },
                    "load" : function(evt, dlg){ console.log(evt.type); },
                    "beforeCollapse" : function(evt, dlg){ console.log(evt.type); },
                    "beforeMaximize" : function(evt, dlg){ console.log(evt.type); },
                    "beforeMinimize" : function(evt, dlg){ console.log(evt.type); },
                    "beforeRestore" : function(evt, dlg){ console.log(evt.type); },
                    "collapse" : function(evt, dlg){ console.log(evt.type); },
                    "maximize" : function(evt, dlg){ console.log(evt.type); },
                    "minimize" : function(evt, dlg){ console.log(evt.type); },
                    "restore" : function(evt, dlg){ console.log(evt.type); }
                });
            },
            _tabMode: function() {
                var that = this;
                var ins = this.mdiTabs.tabs('instance');

                if(ins.options.disabled) {
                    this.mdiTabs.tabs('enable');
                    $('.ui-tabs-panel').dialog( "destroy" );

                    that._dialogLeft = 0;
                    that._dialogtop = 0;
                }
            },
            addTab: function (title, url, inx) {
                var that = this,
                    tabTitle = title,
                    tabUrl = url,
                    tabTemplate = '<li><a href="#{href}">#{label} <span class="close">×</span></a></li>';

                $('.page-loading').show();

                var label = tabTitle || 'Tab-' + inx,
                    id = 'tabs-' + inx,
                    li = $( tabTemplate.replace( /#\{href\}/g, '#' + id ).replace( /#\{label\}/g, label ) ),
                    tabContent = '<div id="' + id + '"><iframe id="mdiFrame-' + inx + '" src=' + url + ' width="100%" height="100%" class="mdiFrame"></iframe></div>';

                this.mdiList.append('<li><a href="#' + id + '" data-index="' + inx + '">' + label + '</a></li>');
                this.mdiTabs.find('.ui-tabs-nav').append( li );
                this.mdiTabs.find('.mdi-contents').append( tabContent );
                this.mdiTabs.tabs( "refresh" );
                this.selecteTab(this.mdiTabs.find('[aria-controls="tabs-' + inx + '"]').children());

                if (this.mdiTabs.find('.ui-tabs-nav').width() > $('.scroll-wrap').width()) {
                    $('.mdi-tabs .scroll-wrap').addClass('movable');
                }
            },
            selecteTab: function(obj) {
                var that = this,
                    targetInx = $(obj).data('index') || $(obj).attr('href').replace(/[^0-9]/g, ''),
                    tab = that.mdiTabs.find('.ui-tabs-nav').children('[aria-controls="tabs-' + targetInx + '"]'),
                    inx = that.mdiTabs.find('.ui-tabs-nav').children().index(tab);

                this.mdiTabs.tabs('option', 'active', inx);
            },
            resizeMdi: function(obj) {
                $(window).on('resize', $.proxy(function() {
                    this.autoHeight(obj);
                    if (uxp.mdi.mdiTabs.find('.ui-tabs-nav').outerWidth() < $('.scroll-wrap').outerWidth()) {
                        $('.mdi-tabs .scroll-wrap').removeClass('movable');
                    } else {
                        $('.mdi-tabs .scroll-wrap').addClass('movable');
                    }
                }, uxp));
            },
            mdiContextID: null,
            contextUse: true,
            init: function(obj) {
                var that = this;
                var active, collapsible, resizeTarget, isVisible;

                this.mdiList = $('#mdiList').find('.dropdown-menu');

                //create tabs
                this.mdiTabs = $( obj ).tabs({
                    activate: function(event, ui) {
                        //console.log('activate');

                        isVisible = ui.newPanel.find('iframe', document).contents().find('.search-wrap').is(':visible');

                        if (isVisible) {
                            $('#fullFoldingBtn').children().removeClass('ico-search-open').addClass('ico-search-close');
                        } else {
                            $('#fullFoldingBtn').children().removeClass('ico-search-close').addClass('ico-search-open');
                        }

                        ui.newPanel.find('iframe').on('load', function() {
                            $('.page-loading').hide();
                        });
                    },
                    beforeActivate: function(event, ui) {
                        //console.log('beforeActive');
                    },
                    beforeLoad: function(event, ui) {
                        //console.log('beforeLoad');
                    },
                    load: function(event, ui) {
                        //console.log('load');
                    },
                    create: function(event, ui) {
                        //console.log('create');
                    }
                });

                //resize MDI wrap
                that.resizeMdi(this.mdiTabs.find('.mdi-contents'));

                //sort tabs
                this.mdiTabs.find('.ui-tabs-nav').sortable({
                    axis: 'x',
                    placeholder: "ui-sortable-placeholder",
                    stop: function() {
                        that.mdiTabs.tabs('refresh');
                    }
                });

                //select tabs
                that.mdiList.on('click', 'a', function(e) {
                    e.preventDefault();
                    that.selecteTab(e.target);
                });

                //탭 더블 클릭 확장
                this.mdiTabs.on('dblclick', '.ui-state-default', function() {
                    uxp.sideBar.find('.btn-side-toggle').trigger('click');
                });

                //탭이 없으면 리스트를 표시하지 않는다.
                this.mdiTabs.on('click', '.dropdown-toggle', function() {
                    if ($(this).siblings('.dropdown-menu').find('li').length == 0) return false;
                });

                if (this.contextUse) {
                	this.mdiTabs.on('contextmenu', '.ui-state-default', function(event) {
                        console.log(event)
                        $('.mdi-context').css({
                            top: event.offsetY,
                            left: event.offsetX + 5
                        }).show();

                        $('.mdi-context').on('mouseleave', function() {
                            $(this).hide();
                        });

                        that.mdiContextID = $(this).attr('aria-labelledby');
                        return false;
                    });

                    this.mdiTabs.on('click', '.mdi-context ul li a', function() {
                        var className = this.className;
                        var item =that.mdiContextID;

                        switch (className) {
                            case 'close-this':
                                that.closeTabs($('#' + item));
                                break;
                            case 'close-other':
                                that.closeOtherTabs($('#' + item));
                                break;
                            case 'close-all':
                                that.closeAllTabs();
                                break;
                        }
                        return false;
                    });
                }

                //close tabs
                this.mdiTabs.on('click', 'span.close', function(e) {
                    that.closeTabs(e.target);
                });

                //close tabs all
                this.mdiTabs.on('click', '#closeAllMid', function() {
                    that.closeAllTabs();
                });

                //조회 조건 보이기
                this.mdiTabs.on('click', '.mdi-page-control .btn-conditaion', function() {
                    $(this).closest('.mdi-page-control').addClass('shift-left');
                });

                //조회 조건 숨기기
                this.mdiTabs.on('click', '.mdi-page-control .btn-shift-right', function() {
                    $(this).closest('.mdi-page-control').removeClass('shift-left');
                });

                uxp.naviMotion({
                    type: 'mdi'
                });
            }
        },
        ddi: function(opts) {
            var that = this;
            var options, defaults;
            if (!opts) opts = {};

            defaults = {
                minWidth: 1400,
                resiable: true,
                draggable: true
            };
            options = $.extend({}, defaults, opts);

            var $ddiContainer = $(options.target);
            var containerWidth = options.minWidth;
            var $closeButton = $(options.target).find('.row .col-left .btn-close');

            if (options.resiable) {
                $ddiContainer.resizable({
                    minHeight: options.minHeight || 500,
                    minWidth: options.minWidth,
                });
                $ddiContainer.width(containerWidth);
            } else {
                $(window).resize(function() {
                    containerWidth = that.getWinWidth() - 50;
                    $ddiContainer.width(containerWidth);
                }).resize();
            }

            if (options.draggable) {
                $($ddiContainer).draggable();
            }

            $closeButton.on('click', function() {
                $(this).children('.fa').toggleClass('fa-angle-right');

                if ($ddiContainer.find('.col-left').hasClass('col-xs-6')) {
                    $ddiContainer.width(containerWidth / 2);
                    $ddiContainer.find('.col-left').removeClass('col-xs-6');
                    $ddiContainer.find('.col-right').hide();
                } else {
                    $ddiContainer.width(containerWidth);
                    $ddiContainer.find('.col-left').addClass('col-xs-6');
                    $ddiContainer.find('.col-right').show();
                }
            });
        },
        gnbInit: function() {
            var that = this;
            var hoverFlag = false;

            $('header.navbar .navbar-nav').find('a').on('click mouseenter', function(e) {
                e.preventDefault();

                if (e.type == 'click' && $(this).parent().hasClass('level1')) {
                    $(this).closest('.nav').find('.active').removeClass('active');
                    $(this).parent().addClass('active');
                    hoverFlag = true;

                    if ($(this).siblings('ul').length) {
                        $(this).parent().siblings().children('ul').hide();
                        $(this).siblings('ul').show();
                    } else {
                        $(this).parent().siblings().children('ul').hide();
                        //console.log('level1 click');
                    }
                } else if (e.type == 'mouseenter' && $(this).parent().hasClass('level1') && hoverFlag) {
                    if ($(this).siblings('ul').length) {
                        $(this).parent().siblings().children('ul').hide();
                        $(this).siblings('ul').show();
                    } else {
                        $(this).parent().siblings().children('ul').hide();
                    }
                }

                if (e.type == 'mouseenter' && !$(this).parent().hasClass('level1')) {
                    if ($(this).siblings('ul').length) {
                        $(this).parent().siblings().children('ul').hide();
                        $(this).siblings('ul').show();
                    } else {
                        $(this).parent().siblings().children('ul').hide();
                    }
                } else if (e.type == 'click' && !$(this).parent().hasClass('level1')) {
                    if ($(this).siblings('ul').length == 0) {
                        //console.log('level2 click');
                    }
                }

                if (e.type == 'click' && $(this).parent().hasClass('level3')) {
                    //console.log('level3 click');
                }
            });

            $('header.navbar .navbar-nav').on('mouseleave', function() {
                $(this).find('ul').hide().end().find('.current').removeClass('current');
                hoverFlag = false;
            });

            $('header.navbar .navbar-form .navbar-search').on('mouseenter', function (e) {
                $(this).closest('.container').addClass('extended');
                $(window).resize();
            });

            $('header.navbar').on('mouseleave', function (e) {
                $(this).find('.container').removeClass('extended');
                $(window).resize();
            });

            this.naviMotion({
                type: 'gnb'
            });

            $(window).resize(function() {
                if ( that.gnbMotionWrap.width() < that.gnbMotionTarget.width() ) {
                    that.gnbMotionControl.fadeIn('fast');
                } else {
                    that.gnbMotionControl.fadeOut('fast');
                }
            }).resize();
        },
        sidebarInit: function(opt) {
            uxp.lnb();

            if (typeof opt == 'object') {
                uxp.sidebar(opt);
            } else {
                uxp.sidebar();
            }
        },
        pageInit: function(opts) {
            var that = this, defaults, options;

            console.log('UXP pageInit');

            if (!opts) opts = {};
            defaults = {
                gnbInit: true,
                lnbInit: true,
                pageScroll: false,
            };
            options = $.extend({}, defaults, opts);

            that.loading();

            if (options.gnbInit) {
                that.gnbInit();
            }
            if (options.lnbInit) {
                if (options.sidebar) {
                    that.sidebarInit(options.sidebar);
                } else {
                    that.sidebarInit();
                }
            }
            if (options.pageScroll) {
                this.searchBox(options.pageScroll);
            } else {
                this.searchBox();
            }
            if (options.mdiInit) {
            	if (options.mdiContext == false) {
            		that.mdi.contextUse = false;
            	}
            	that.mdi.init(options.mdiInit);
            }
            if (options.splittable) {
                var splitOption = options.splittable.options || {};
                var splitDefault = {
                    handles: 's',
                    minHeight: 200,
                    maxHeight: 400,
                    create: function(event, ui) {
                        //console.log('create');
                    },
                    resize: function(event, ui) {
                        //console.log('resize');
                        var handle = $(ui.element).resizable('option', 'handles');
                        if (handle === 'e') {
                            resizeSibling(ui);
                        }
                    },
                    start: function(event, ui) {
                        //console.log('start');
                    },
                    stop: function(event, ui) {
                        //console.log('stop');
                        var handle = $(ui.element).resizable('option', 'handles');
                        if (handle === 'e') {
                            resizeSibling(ui);
                        }
                    }
                }

                function resizeSibling(ui) {
                    $(window).resize(function() {
                        var rowWidth = ui.element.closest('.row').width();
                        var thisWidth = ui.element.outerWidth();
                        ui.element.next().outerWidth(rowWidth - thisWidth);
                    });
                }

                var resizableOption = $.extend({}, splitDefault, splitOption);
                $(options.splittable.target).resizable(resizableOption);
            }
            $(window).resize(function() {
                if (options.resizeWrap) {
                    if ($.isArray(options.resizeWrap)) {
                        $.each(options.resizeWrap, function(i, el) {
                            that.autoHeight(el, options.resizeMin ? options.resizeMin : 300, options.resizeContain ? options.resizeContain : '');
                        });
                    } else {
                        that.autoHeight(options.resizeWrap, options.resizeMin ? options.resizeMin : 300, options.resizeContain ? options.resizeContain : '');
                    }
                }
                if (options.resizeFrame) {
                    that.autoHeight(options.resizeFrame);
                }
            }).resize();
        },
        init: function() {
        try{	
        	var that = this;

            this.dataFormat();

	        if ($(parent.document).find('body').hasClass('page-sm')) {
	            $('body').addClass('page-sm');
	        }
	        if ($(parent.document).find('body').hasClass('lg-smart')) {
	            $('body').addClass('lg-smart');
	        }
            // 테마변경
            $('#changeTheme').on('click', that.changeTheme);
            // 크기 변경
            $('#changeSize').on('click', that.changeSize);

            $('#changeFont').on('click', that.changeFont);

            $('.btn-favorite, .btn-lnb').on('click', function() {
                var $sidebar = $(this).closest('.sidebar');
                var $lnb = $sidebar.children('.lnb');
                var $favoLnb = $sidebar.children('.favorite');

                if ($(this).closest('.sidebar-header').length === 0) {
                    if ($(this).hasClass('btn-lnb')) {
                        $lnb.show();
                        $favoLnb.addClass('sr-only');
                    } else {
                        $lnb.hide();
                        $favoLnb.removeClass('sr-only').show();
                    }
                } else {
                    if ($favoLnb.hasClass('sr-only')) {
                        $lnb.hide();
                        $favoLnb.removeClass('sr-only').show();
                        $(this).children().toggleClass('ico-menu-favorite ico-menu-favorite-s');
                    } else {
                        $lnb.show();
                        $favoLnb.addClass('sr-only');
                        $(this).children().toggleClass('ico-menu-favorite-s ico-menu-favorite');
                    }
                }
            });

            $('.quick-menu > .btn-group > .btn').on('click', function() {
                $(this).siblings().removeClass('active');
                $(this).addClass('active');

                if ($(this).find('.fa-star-o').length) {
                    $(this).find('.fa-star-o').removeClass('fa-star-o').addClass('fa-star');
                } else {
                    $(this).siblings().find('.fa-star').removeClass('fa-star').addClass('fa-star-o');
                }
            });
	     }catch(e){
	    	 console.log(e.message);
	     }
       }
    };

    $(function () {
        uxp.init();
    });

    // 파일첨부
    $(document).ready(function(){
        var fileTarget = $('.filebox .upload-hidden');

        fileTarget.on('change', function(){
            if(window.FileReader){
                var filename = $(this)[0].files[0].name;
            } else {
                var filename = $(this).val().split('/').pop().split('\\').pop();
            }

            $(this).siblings('.upload-name').val(filename);
        });
    });

})(jQuery);
