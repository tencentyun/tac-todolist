package com.tencent.qcloud.todolist.data

import com.tencent.qcloud.todolist.model.TodoItem

/**
 * <p>
 * </p>
 * Created by wjielai on 2018/6/13.
 * Copyright 2010-2017 Tencent Cloud. All Rights Reserved.
 */

data class AddTodoResult(val code: Int, val message: String, val id: String, val url: String?)

data class RemoveTodoResult(val code: Int, val message: String)

data class ListTodoResult(val code: Int, val message: String, val data: MutableList<TodoItem>?)