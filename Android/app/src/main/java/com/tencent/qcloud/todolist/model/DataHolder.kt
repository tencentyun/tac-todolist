package com.tencent.qcloud.todolist.model

import com.tencent.qcloud.core.common.QCloudClientException
import com.tencent.qcloud.core.common.QCloudServiceException

/**
 * <p>
 * </p>
 * Created by wjielai on 2018/6/5.
 * Copyright 2010-2017 Tencent Cloud. All Rights Reserved.
 */
data class DataHolder<T> constructor(val data: T? = null, var clientException: QCloudClientException? = null,
                     var serviceException: QCloudServiceException? = null, val `val` : Int = 0) {

    fun getExceptionMessage(): String? {
        return clientException?.toString()?:serviceException?.toString()
    }
}