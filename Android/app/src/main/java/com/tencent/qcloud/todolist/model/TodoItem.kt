package com.tencent.qcloud.todolist.model

import com.google.gson.annotations.SerializedName

/**
 * <p>
 * </p>
 * Created by wjielai on 2018/6/5.
 * Copyright 2010-2017 Tencent Cloud. All Rights Reserved.
 */
data class TodoItem(
        @SerializedName("id")
        var taskId : String? = null,
        @SerializedName("content")
        val task: String,
        @SerializedName("url")
        var attachment: String? = null,
        @SerializedName("user_id")
        val userId: String,
        @SerializedName("update_time")
        val updateTime: String? = null)