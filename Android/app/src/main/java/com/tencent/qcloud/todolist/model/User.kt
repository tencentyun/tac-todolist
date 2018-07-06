package com.tencent.qcloud.todolist.model

import com.tencent.qcloud.core.auth.OAuth2Credentials
import com.tencent.tac.social.auth.TACOpenUserInfo

/**
 * <p>
 * </p>
 * Created by wjielai on 2018/6/5.
 * Copyright 2010-2017 Tencent Cloud. All Rights Reserved.
 */
data class User(val userInfo : TACOpenUserInfo?,
           val credentials: OAuth2Credentials,
           val isPayingUser: Boolean = false)