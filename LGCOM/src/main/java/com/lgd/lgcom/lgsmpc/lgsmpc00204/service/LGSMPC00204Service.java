/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00203Service.java
 * @Desc    : 
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2016. 8. 31.  	jhpark23  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgcom.lgsmpc.lgsmpc00204.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;


/**
 * <PRE>
 * com.lgd.lgcom.lgsmpc.lgsmpc00204.service.LGUTLC00204Service.java
 * </PRE>
 *
 * @Author    jhpark23
 * @Date	   2016. 8. 31. 오전 9:50:46
 * @Version   
 */
public interface LGSMPC00204Service {
    
    /**
     * Desc : Calendar Schedule 목록을 조회한다.
     * @Method Name : retrieveCalendarEventList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public List<LGCOMData> retrieveCalendarEventList(LGCOMData param);
    
    /**
     * Desc : Calendar Schedule 목록를 저장한다
     * @Method Name : insertCalendarEventList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public void insertCalendarEventList(LGCOMData param);
    
    /**
     * Desc : Calendar Schedule 목록를 삭제한다
     * @Method Name : deleteCalendarEventList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public void deleteCalendarEventList(LGCOMData param);
    
    
    
    
 

}
