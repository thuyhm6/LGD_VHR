/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT60050Service.java
 *
 * Copyright ⓒ 2024 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2024. 02. 20.    sangnv 
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt60050.service;
//
import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt60050.service.LGVATT60050Service.java
 * </PRE>
 * 
 * @author     sangnv
 * @Date	   2024. 02. 20
 * @Version
 *
 */
public interface LGVATT60050Service {
	

	public List<LGCOMData> retrieveHalfdayWorkingList(LGCOMData param);
	
    public LGCOMData saveAttendance(LGCOMData param);

;}
