package com.tencent.cloud.todolist.wxapi

import com.tencent.qcloud.core.logger.QCloudLogger
import com.tencent.qcloud.todolist.LOG_TAG
import com.tencent.tac.social.WeChatBaseHandlerActivity
import com.tencent.tac.social.share.ShareResult


/**
 * <p>
 * </p>
 * Created by wjielai on 2018/6/4.
 * Copyright 2010-2017 Tencent Cloud. All Rights Reserved.
 */
class WXEntryActivity : WeChatBaseHandlerActivity() {

    override fun onWeChatShareResult(shareResult: ShareResult?) {
        super.onWeChatShareResult(shareResult)
        QCloudLogger.i(LOG_TAG, "wechat share result : " + shareResult?.result)
    }
}