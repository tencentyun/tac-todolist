package com.tencent.qcloud.todolist.vm

import android.net.Uri
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.tencent.qcloud.todolist.data.Repository
import com.tencent.qcloud.todolist.model.DataHolder
import com.tencent.qcloud.todolist.model.TodoItem

/**
 * <p>
 * </p>
 * Created by wjielai on 2018/6/5.
 * Copyright 2010-2017 Tencent Cloud. All Rights Reserved.
 */
class TodoViewModel : ViewModel() {

    private val repository = Repository.instance

    fun item(taskId : String) : MutableLiveData<DataHolder<TodoItem>>? {
        return repository.getItem(taskId)
    }

    fun list():MutableLiveData<DataHolder<MutableList<TodoItem>>> {
        return repository.getTodoList()
    }

    fun reloadList() {
        repository.getTodoList(forceReload = true)
    }

    fun insert(content: String, attachmentUri: Uri?): MutableLiveData<DataHolder<TodoItem>> {
        return repository.insertTodo(content, attachmentUri)
    }

    fun markDone(item: TodoItem): MutableLiveData<DataHolder<TodoItem>> {
        val livaItem = MutableLiveData<DataHolder<TodoItem>>()
        livaItem.value = DataHolder(data = item)
        repository.removeTodo(livaItem)
        return livaItem
    }

    fun markDone(item: MutableLiveData<DataHolder<TodoItem>>): MutableLiveData<DataHolder<TodoItem>> {
        repository.removeTodo(item)
        return item
    }
}