/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LoginController.java
 * @Desc    : 
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 10.    jhpark23    최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgcom.common.controller;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.io.IOUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.LocaleResolver;

import com.lgd.lgcom.common.model.ServerMessage;
import com.lgd.lgcom.common.service.UserService;
import com.lgd.lgcom.common.service.UserSessionService;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.AuthenticationActionException;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgcom.common.controller.LoginController.java
 * </PRE>
 *
 * @Author    jhpark23
 * @Date	   2016. 5. 10. 오후 3:20:58
 * @Version   
 */
@Controller
public class LoginController extends BaseLGCOMController {

    @Value("#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
    private String env = null;
    
    @Resource(name="userService")
    private UserService userService;
    
    @Autowired
    private UserSessionService userSessionService;    
    
    @Autowired
    private LocaleResolver localeResolver;

    private static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LoginController.class);

    /**
     * Desc : 
     * @Method Name : login
     * @param req
     * @param res
     * @param model
     * @return
     * @throws Exception
     */
    @SuppressWarnings({ "unchecked", "rawtypes" })
    @RequestMapping(value = "/action/login")
    public String login(HttpServletRequest req, HttpServletResponse res, Model model ) throws LGCOMException, IOException{

    	HttpSession session = req.getSession();
		String jsonBody = IOUtils.toString( req.getInputStream() );
		LGCOMData data = LGCOMData.parse( jsonBody );
		LOGGER.debug( "AAAAAA jsonBody : " + jsonBody );
		LOGGER.debug( "AAAAAA : " + data );
		
		
        userService.validateLoginProc(data);
        if("E".equals(data.get("resultCode").toString())){
            localeResolver.setLocale(req, res, new Locale("en"));
            throw new AuthenticationActionException(data.getString("resultMsg"));
        }
        
        LGCOMData userSession = userService.retrieveUserInfo(data);
        userSession.set("roleList", userService.retrieveUserRoleList(userSession));
        /**
         * 로그인 시에는 Database에 있는 SYSTEM_CODE를 DEFAULT SYSTEM으로 설정한다.
         */
        /*String[] uris = req.getRequestURI().split("/");
        userSession.set(LGCOMConstants.DEFAULT_SYSTEM_CODE, uris[1]);*/
        
        /**
         * 로그인시 기존에 Set 한 Attribute를 모두 삭제 : 단, targetSystemCode 항목만은 살려두어야 한다. ( 2017.07.24 jhlee )
         */
        //List<String> names = Arrays.asList( session.getAttributeNames() );
        List<String> names = Collections.list( session.getAttributeNames() );
        
        String targetSystemCode = (String)session.getAttribute("targetSystemCode");

        for( String name : LGCOMUtils.emptyIfNull(names) ){
            session.removeAttribute( name );
        }
        session.setAttribute("targetSystemCode", targetSystemCode);

        userSessionService.setSession(req, userSession );

        if(env.equals("local")){
            ServletContext context = session.getServletContext().getContext("/lgcom");
            Map<String, String> users = (Map<String, String>)context.getAttribute("USERS");
            
            if(NullUtil.isNull(users)){
                users = new HashMap<String, String> ();
            }
            users.put(session.getId(), userSession.toJson() );
            context.setAttribute("USERS", users ); 
        }        
        
        localeResolver.setLocale(req, res, new Locale(userSession.getString("languageCode") ));
        
        LGCOMData result = new LGCOMData();
        ServerMessage serverMessage = new ServerMessage(LGCOMConstants.RESULT_SUCCESS, LGCOMConstants.RESULT_SUCCESS);
        
        result.set(LGCOMConstants.SERVER_MESSAGE, serverMessage);
        result.set(LGCOMConstants.SERVER_RESULT, userSession);

        model.addAttribute("result", result.toJson() );
        LOGGER.debug(result);
        
        return "action";
    }

}
