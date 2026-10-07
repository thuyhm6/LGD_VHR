/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : RegionController.java
 * @Desc    : 
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 9. 2.    jhpark23    최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.common.controller;

import java.io.IOException;
import java.lang.reflect.Method;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.IOUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.context.support.WebApplicationContextUtils;
import org.springframework.web.servlet.LocaleResolver;

import com.lgd.lgcom.common.model.ServerMessage;
import com.lgd.lgcom.common.service.UserService;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgcom.common.controller.RegionController.java
 * </PRE>
 *
 * @Author    jhpark23
 * @Date       2016. 5. 12. 오후 3:54:19
 * @Version   
 */
@Controller
public class RegionController extends BaseLGCOMController {

	private static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(RegionController.class);

	@Autowired
	ServletContext context;

	@Autowired
	UserService userService;

	@Autowired
    LocaleResolver localeResolver;


    @RequestMapping(value = "/action/region/{serviceId}")
    public String actionRegion(HttpServletRequest req, HttpServletResponse res, Model model, @PathVariable String serviceId,
            @RequestHeader(required = false, value = "headerInfo") String headerInfo) throws LGCOMException, IOException{
    	
		String jsonBody = IOUtils.toString( req.getInputStream() );
		LGCOMData data = LGCOMData.parse( jsonBody );
        
    	/**
         * 인가받은 Ajax 요청인지 검증하는 로직이다.
         * LGCOMController.class 에서 화면 Open시 생성한 securityCode 와 
         * Ajax 호출시 전달된 Request Header-headerInfo로 전달된 코드가 존재하는지 확인한다.
         **/
        //Map<String,Object> headerInfoMap = null;
        if (!NullUtil.notNone(headerInfo)) {
            res.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return null;
        }
    	
    	 /**
         * 최종 전달될 데이터는 아래와 같다.
         * { _server_message_: { type: 'SUCCESS', text: 'SUCCESS' }, result: { } / [ ] }
         * { _server_message_: { type: 'ERROR', text: 'ERROR MESSAGE' }, result: { } / [ ] }
         * Error가 발생하는 경우와 정상처리되는 경우 UI에 전달되는 데이터의 형식은 동일해야한다.
         **/
        LGCOMData result = new LGCOMData();
        ServerMessage serverMessage = new ServerMessage(LGCOMConstants.RESULT_SUCCESS, LGCOMConstants.RESULT_SUCCESS);
        LGCOMData serverResult = null;
    	
    	/**
         * 전달받은 URI 기준으로 invoke 시킬 bean 정보를 가지고 온다.
         **/
        Object beanInstance = WebApplicationContextUtils.getWebApplicationContext(context).getBean("regionService");

        if (!NullUtil.isNull(beanInstance)) {
            Method method = getMethod(beanInstance, serviceId);

            /**
             * Ajax 호출시 Input Data는 Map 형태로 전달되며, 세션정보도 Input Data에 추가로 append 한다.
             **/
            try {
                serverResult = (LGCOMData)method.invoke(beanInstance, data);
            } catch (Exception e) {
                Throwable cause = e.getCause();
                if(cause == null) {
                    throw new LGCOMException(e.getMessage(),e);
                } else  {
                    throw new LGCOMException(cause.getMessage(),cause);
                }
            }
        }
        
        result.set(LGCOMConstants.SERVER_MESSAGE, serverMessage);
        result.set(LGCOMConstants.SERVER_RESULT, serverResult);

        model.addAttribute("result", result.toJson() );
        LOGGER.debug(result);
        
        return "action";
    }

}