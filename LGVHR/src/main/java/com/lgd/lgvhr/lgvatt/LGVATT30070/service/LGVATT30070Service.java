package com.lgd.lgvhr.lgvatt.LGVATT30070.service;

import java.util.List;

import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.model.LGCOMData;

public interface LGVATT30070Service {
	
	/**
	 * Special OT 요청 리스트 조회
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public List<LGCOMData> retrieveSpecialOtRequestList(LGCOMData param) throws LGCOMException;

}
