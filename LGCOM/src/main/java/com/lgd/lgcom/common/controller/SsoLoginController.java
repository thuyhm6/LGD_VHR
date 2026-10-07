/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : SsoLoginController.java
 * @Desc    : 
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 6. 13.    jhpark23    최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgcom.common.controller;

import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.LocaleResolver;

import com.lgd.lgcom.common.service.UserService;
import com.lgd.lgcom.common.service.UserSessionService;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.AuthorizationException;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgcom.common.controller.SsoLoginController.java
 * </PRE>
 *
 * @Author    jhpark23
 * @Date       2016. 5. 10. 오후 3:20:58
 * @Version   
 */
@Controller
public class SsoLoginController extends BaseLGCOMController {

    @Autowired
    private UserService userService;
    
    @Autowired
    private UserSessionService userSessionService;

    @Autowired
    private LocaleResolver localeResolver;

    @Value("#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
    private String env = null;
    
    @Value("domain_#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
    private String domain = null;

    private static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(SsoLoginController.class);

    /**
     * Desc : 
     * @Method Name : login
     * @param req
     * @param res
     * @param model
     * @return
     * @throws LGCOMException
     */
    @RequestMapping(value = "/login")
    public String login(HttpServletRequest req, HttpServletResponse res, Model model) throws LGCOMException{

        //1. req.getHeader SSO ID 찾기
        // 신규 SSO 시스템에서 사용자 ID 를 아래와 같은 방법으로 사용할 수 있다.
        String ssoId = req.getHeader("iv-user");
        // 사번을 사용하는 경우는 system_id = req.getHeader("employeenumber");
        String systemId = req.getHeader("employeenumber");
        LOGGER.debug("iv-user : " + ssoId);
        LOGGER.debug("employeenumber : " + systemId);

        // 테스트를 위해 운영환경이 아니면 파라미터로 해당 정보를 받는다
        String password = null;
        
        if (!env.equals("prod")) {
            ssoId = req.getParameter("iv-user");
            password = req.getParameter("password");
        }
        
        /**
         * 로그인시 기존에 Set 한 Attribute를 모두 삭제 : 단, targetSystemCode 항목만은 살려두어야 한다. ( 2017.07.24 jhlee )
         */
        HttpSession session = req.getSession();
        Enumeration<String> names = session.getAttributeNames();
        String targetSystemCode = (String)session.getAttribute("targetSystemCode");
        
        while(names.hasMoreElements()){
        	String key = names.nextElement();
            if( !"_external_parameter_".equals( key) ) {
            	session.removeAttribute( key );	
            }
        }
        
        session.setAttribute("targetSystemCode", targetSystemCode);

        //2. 사용자 Session 생성
        LGCOMData inParam = new LGCOMData();
        inParam.set("ssoId", ssoId);
        
        List<LGCOMData> userTemp = userService.retrieveSsoUserList( inParam );
        LGCOMData user = null;
        
        //3. region, org 선택 화면 redirect 여부 판단
        //3-1. 사용자가 존재하지 않으면 권한에러
        //3-2. 사용자가 1명이면 orgId, regionCode 존재여부 확인하여 판단
        //3-2-1. /service/main redirect 대상     
        //3-2-1-1. OU_USE_FLAG is 'Y'
        //       DEFAULT_ORG_ID not null
        //       REQUEST_REGION_CODE not null
        //       DEFAULT_ORG_ID_USE_FLAG is 'Y'
        //       REQUEST_REGION_CODE_USE_FLAG is 'Y'
        //3-2-1-2. OU_USE_FLAG is 'N'
        //       REQUEST_REGION_CODE not null
        //       REQUEST_REGION_CODE_USE_FLAG is 'Y'
        //3-3. 사용자가 2명이상이면 /service/region redirect 대상
        //     해당 경우에는 세션생성(로그인처리를) /service/region에서 수행한다.
        boolean redirectMain = true;

        if (userTemp.size() == 0) {
            throw new AuthorizationException();
        } else if (userTemp.size() > 1) {
            // Default System이 Null 인 사용자의 경우 Default System을 찾아서 update한다.
            user = userTemp.get(0);
            List<String> sysParam = new ArrayList<String>();
            for(LGCOMData item: userTemp) {
                sysParam.add(item.getString("userName"));
            }
            user.set("userNames", sysParam);
            userService.updateDefaultSystem(user);
            redirectMain = false;
        } else {
            user = userTemp.get(0);
            // systemCode가 Null인 경우 Default System을 설정한다.
            if (NullUtil.isNone(user.getString("systemCode"))) {
                List<String> sysParam = new ArrayList<String>();
                sysParam.add(user.getString("userName"));
                user.set("userNames", sysParam);
                userService.updateDefaultSystem(user);
                user = userService.retrieveSsoUserList(inParam).get(0);
            }

            boolean ouUseFlag = user.getString("ouUseFlag").toUpperCase().equals("Y");
            boolean defaultOrgIdUseFlag = user.getString("defaultOrgIdUseFlag").toUpperCase().equals("Y");
            boolean requestRegionCodeUseFlag = user.getString("requestRegionCodeUseFlag").toUpperCase().equals("Y");
            String defaultOrgId = user.getString("defaultOrgId");
            String requestRegionCode = user.getString("requestRegionCode");
            
            // Operation Unit 을 사용하는 시스템의 권한을 가진 사용자일 경우
            redirectMain = false;
            if(ouUseFlag) {
                if( NullUtil.notNone(defaultOrgId) && NullUtil.notNone(requestRegionCode) && defaultOrgIdUseFlag && requestRegionCodeUseFlag ) {
                    redirectMain = true;
                }
            } else {
                if( NullUtil.notNone(requestRegionCode) && requestRegionCodeUseFlag ) {
                    redirectMain = true;
                }
            }
            if(redirectMain) {
                user.set("roleList", userService.retrieveUserRoleList(user));
                userSessionService.setSession(req, user);
                localeResolver.setLocale(req, res, new Locale(user.get("languageCode").toString()));
            }
        }
        
        // Password validate Check
        if(NullUtil.notNone(password)){
            String resultCode = "E";
            String resultMsg = null;
            boolean successFlag = false;
            for(int inx = 0; inx < userTemp.size() ; inx++){
                user = userTemp.get(inx);
                user.set("password", password);
                
                userService.validateLoginProc(user);
                resultCode = user.get("resultCode").toString();
                resultMsg = (String)user.get("resultMsg");
                if(resultCode.equals("S")){
                    successFlag = true;
                }
            }
            
            if(!successFlag){
                localeResolver.setLocale(req, res, new Locale("en"));
                req.setAttribute("resultMsg", resultMsg);
                throw new AuthorizationException(resultMsg);
            }
        }
        
        //4. Redirect URL 생성
        StringBuilder redirectUrl = new StringBuilder();
        String forwardUrl = null;
        
        redirectUrl.append("http://");
        redirectUrl.append(LGCOMUtils.getValueFromProjectProperties(domain));
        redirectUrl.append("/");
        // Default System
        // redirectUrl.append(user.getString("systemCode").toLowerCase());
        // Main은 LGCOM에서 제공한다.
        redirectUrl.append("lgcom");

        if (redirectMain) {  
        	/**
        	 * container.jsp 를 호출하는 과정에서 로그인이 필요지 않다고 판단한 경우로, 파라미터만 정상적으로 세팅하여 전달하면 된다. 
        	 * */
        	LGCOMData param = (LGCOMData)session.getAttribute( "_external_parameter_");
       	
        	//이 항목은 /container 로 경로를 보냈을 때만 작성된다. 파라미터가 없을 때에도 null 이 나오지 않으므로, null 로써 main 으로 갈지 말지 판단이 된다. 
        	if( param == null ) {
        		redirectUrl.append("/service/main");
        	} else {
        		String target = param.getString("target");
        		StringBuilder extParam = new StringBuilder();
        		extParam.append("?");
        		Iterator<String> it = param.keySet().iterator();
        		while( it.hasNext() ) {
        			String key = it.next();
        			extParam.append("&" + key + "=" + param.getString(key) );
        		}
        		//여기서 Session 정보를 지우지 않으면, 정상적인 로그인 직후에도 계속 이 영향을 받아서 
        		//container 로만 이동하게 된다.
        		req.getSession().removeAttribute( "_external_parameter_");
        		
        		redirectUrl.append( target + extParam.toString() );        		
        	}
        } else {
            redirectUrl.append("/service/region");
            if (!env.equals("prod")) {
                redirectUrl.append("?ssoId="+ssoId);
            }
        }
        
        LOGGER.debug("Redirect URL is " + redirectUrl.toString());
        LOGGER.debug("Forward  URL is " + forwardUrl );
        if( forwardUrl != null ) {
            return getReturnUrl("", redirectUrl.toString(), forwardUrl);
        } else {
        	return getReturnUrl("", redirectUrl.toString() );
        }
    }
}
