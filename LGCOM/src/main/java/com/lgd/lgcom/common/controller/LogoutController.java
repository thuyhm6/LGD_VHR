/**
 * -----------------------------------------------------------------------------
 * -
 *
 * @Project : LGDisplay LGCOM Project
 * @Source : LogoutController.java
 * @Desc : Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *       -----------------------------------------------------------------------
 *       ------- 변 경 사 항
 *       -----------------------------------------------------------------------
 *       ------- VER DATE AUTHOR DESCRIPTION
 *       -----------------------------------------------------------------------
 *       ------ 1. 0 2016. 5. 12. jhpark23 최초 프로그램 작성
 *       -----------------------------------------------------------------------
 *       -------
 */
package com.lgd.lgcom.common.controller;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.Map;

import javax.servlet.ServletContext;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * </PRE>
 *
 * @Author    jhpark23
 * @Date	   2016. 5. 12. 오후 3:17:48
 * @Version
 */
@Controller
public class LogoutController extends BaseLGCOMController {

    private static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LogoutController.class);

    @RequestMapping(value = "/service/logout")
    public String executeService(HttpServletRequest req, HttpServletResponse res, String redirect, String forward)
            throws LGCOMException, IOException, URISyntaxException{

        StringBuilder view = new StringBuilder();
        HttpSession session = req.getSession();

        ServletContext context = session.getServletContext().getContext("/lgcom");
        Map<String, String> users = (Map<String, String>)context.getAttribute("USERS");

        if(!NullUtil.isNull(users)){
            users.remove(session.getId());
        }

        session.invalidate();

        Cookie cookie = new Cookie("JSESSIONID","");
        cookie.setValue(null);
        cookie.setMaxAge(0);
        cookie.setPath("/");

        res.addCookie(cookie);

        redirect = "/service/login";

        return getReturnUrl(view.toString(), redirect, forward);
    }

}
