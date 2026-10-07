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
 *    VER   DATE          AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 10. 14. forain      최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.common.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

/**
 * <PRE>
 * com.lgd.lgcom.common.controller.SampleController.java
 * </PRE>
 *
 * @Author    forain
 * @Date	  2016. 10. 14. 오전 10:49:37
 * @Version
 */
@Controller
public class SampleController extends BaseLGCOMController {
	@RequestMapping(value = "/service/sample",method=RequestMethod.GET)
	public String serviceSample() {
		return "sample/index";
	}

	@RequestMapping(value = "/service/sample/{programName}")
	public String serviceSamplePage(@PathVariable String programName) {
		return "sample/"+programName;
	}
}
