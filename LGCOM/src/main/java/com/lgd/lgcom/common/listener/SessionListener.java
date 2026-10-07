package com.lgd.lgcom.common.listener;

import java.sql.Timestamp;
import java.util.Date;

import javax.servlet.annotation.WebListener;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.framework.logmanager.AccessLogManager;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * Application Lifecycle Listener implementation class SessionListener
 *
 */
@WebListener
public class SessionListener implements HttpSessionListener {

    /**
     * Default constructor. 
     */
    public SessionListener() {
        // TODO Auto-generated constructor stub
    }

	/**
     * @see HttpSessionListener#sessionCreated(HttpSessionEvent)
     */
    public void sessionCreated(HttpSessionEvent event )  {
    	
         // TODO Auto-generated method stub
    }

	/**
     * @see HttpSessionListener#sessionDestroyed(HttpSessionEvent)
     */
    public void sessionDestroyed(HttpSessionEvent event)  { 
         HttpSession session = event.getSession();

         LGCOMData userSession = (LGCOMData)session.getAttribute(LGCOMConstants.HTTP_SESSION_KEY);         
         if( userSession != null ) {
        	 LGCOMData log = new LGCOMData();
	         log.set("applicationUserId", userSession.get("applicationUserId"));
	         log.set("menuId", "SYSTEM_LOGOUT");
	         log.set("accessDate", new Timestamp(new Date().getTime()));
	         log.set("loginIpAddr", userSession.get("loginIpAddr") );  //여기에는 Request 정보가 없기때문에 userSession  에 넣어두었던 정보를 활용한다.
	         log.set("createdBy", userSession.get("applicationUserId"));
	         log.set("lastUpdatedBy", userSession.get("applicationUserId"));
	         AccessLogManager.getInstance().add(log);
         }
    }
	
}
