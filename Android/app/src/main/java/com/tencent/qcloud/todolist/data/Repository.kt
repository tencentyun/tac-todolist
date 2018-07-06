package com.tencent.qcloud.todolist.data

import android.content.Context
import android.net.Uri
import android.text.TextUtils
import androidx.core.content.edit
import androidx.lifecycle.MutableLiveData
import com.google.gson.Gson
import com.tencent.qcloud.core.auth.OAuth2Credentials
import com.tencent.qcloud.core.common.QCloudClientException
import com.tencent.qcloud.core.common.QCloudResultListener
import com.tencent.qcloud.core.common.QCloudServiceException
import com.tencent.qcloud.core.http.HttpRequest
import com.tencent.qcloud.core.http.HttpResult
import com.tencent.qcloud.core.http.QCloudHttpClient
import com.tencent.qcloud.todolist.model.DataHolder
import com.tencent.qcloud.todolist.model.TodoItem
import com.tencent.qcloud.todolist.model.User
import com.tencent.tac.TACApplication
import com.tencent.tac.authorization.TACAuthorizationService
import com.tencent.tac.social.auth.QQAuthProvider
import com.tencent.tac.social.auth.TACOpenUserInfo
import com.tencent.tac.social.auth.WeChatAuthProvider
import com.tencent.tac.storage.StorageResultListener
import com.tencent.tac.storage.TACStorageOptions
import com.tencent.tac.storage.TACStorageService
import com.tencent.tac.storage.TACStorageTaskSnapshot
import org.json.JSONObject
import java.net.URL
import java.net.URLEncoder


internal class API {
    companion object {
        const val listTodo = "http://tac.cloud.tencent.com/client/todo/list?user_id=%s"
        const val addTodo = "http://tac.cloud.tencent.com/client/todo/add?user_id=%s&content=%s&url=%s"
        const val updateTodo = "http://tac.cloud.tencent.com/client/todo/update?user_id=%s&content=%s&id=%d"
        const val removeTodo = "http://tac.cloud.tencent.com/client/todo/remove?user_id=%s&id=%s"
    }
}

fun <T> postError(liveData: MutableLiveData<DataHolder<T>>, clientException: QCloudClientException? = null,
                  serviceException: QCloudServiceException? = null) {
    val dataHolder = liveData.value
    if (dataHolder == null) {
        liveData.postValue(DataHolder(clientException = clientException, serviceException = serviceException))
    } else {
        dataHolder.clientException = clientException
        dataHolder.serviceException = serviceException
        liveData.postValue(dataHolder)
    }
}

inline fun <R, T> doRequest(request: HttpRequest<String>, clazz: Class<R>, liveData: MutableLiveData<DataHolder<T>>,
                            crossinline onSuccess: (R) -> Unit) {
    val client = QCloudHttpClient.getDefault()
    client.resolveRequest(request)
            .schedule()
            .addResultListener(object : QCloudResultListener<HttpResult<String>> {
                override fun onFailure(clientException: QCloudClientException?, serviceException: QCloudServiceException?) {
                    postError(liveData, serviceException = serviceException, clientException = clientException)
                }

                override fun onSuccess(result: HttpResult<String>?) {
                    if (result != null && result.isSuccessful) {
                        try {
                            val contentResult = Gson().fromJson(result.content(), clazz)
                            if (contentResult != null) {
                                onSuccess.invoke(contentResult)
                            } else {
                                postError(liveData, serviceException = QCloudServiceException("Gson error : $result"))
                            }
                        } catch (e: Exception) {
                            e.printStackTrace()
                            postError(liveData, clientException = QCloudClientException(e))
                        }
                    } else {
                        postError(liveData, serviceException = QCloudServiceException("Http error : $result"))
                    }
                }
            })
}


/**
 * <p>
 * </p>
 * Created by wjielai on 2018/6/6.
 * Copyright 2010-2017 Tencent Cloud. All Rights Reserved.
 */
class Repository {

    companion object AppSharePreference {
        private const val preferenceName = "todo"
        private const val KEY_USER_OPEN_ID = "userOpenId"
        private const val KEY_USER_NICK_NAME = "userNickName"
        private const val KEY_USER_AVATAR = "userAvatar"
        private const val KEY_IS_PAYING = "isPayingUser"
        private const val KEY_USER_ACCESS_TOKEN = "userAccessToken"
        private const val KEY_USER_REFRESH_TOKEN = "userRefreshToken"
        private const val KEY_USER_TOKEN_VALID_DATE = "uerTokenValidDate"
        private const val KEY_USER_PLATFORM = "userPlatform"

        val instance: Repository = Repository()
    }

    private var myUser: MutableLiveData<DataHolder<User>>? = null
    private val todo: MutableLiveData<DataHolder<MutableList<TodoItem>>> = MutableLiveData()

    private val storageService: TACStorageService by lazy {
        val storageOptions = TACApplication.options()?.sub<TACStorageOptions>("storage")
        storageOptions?.setCredentialProvider(HttpRequest.Builder<String>()
                .scheme("https")
                .host("tac.cloud.tencent.com")
                .path("/client/sts")
                .method("GET")
                .query("bucket", storageOptions.defaultBucket)
                .build())

        TACStorageService.getInstance()
    }

    fun getUser(context: Context): MutableLiveData<DataHolder<User>> {
        if (myUser == null) {
            myUser = MutableLiveData()
            val user = getUserFromPreference(context)
            if (user != null) {
                myUser!!.value = DataHolder(data = user)
            }
        }

        return myUser!!
    }

    fun loadUser(context: Context, credentials: OAuth2Credentials) {
        val liveUser = getUser(context)
        val listener = object : QCloudResultListener<TACOpenUserInfo> {
            override fun onSuccess(result: TACOpenUserInfo?) {
                val user = User(
                        userInfo = result,
                        credentials = credentials,
                        isPayingUser = false
                )
                if (result != null) {
                    saveUserToPreference(context, user)
                }

                liveUser.postValue(DataHolder(data = user))
            }

            override fun onFailure(clientException: QCloudClientException?, serviceException: QCloudServiceException?) {
                postError(liveUser, clientException = clientException, serviceException = serviceException)
            }
        }

        val service = TACAuthorizationService.getInstance()
        if (credentials.platform == QQAuthProvider.PLATFORM) {
            service.getQQAuthProvider(context).getUserInfo(credentials, listener)
        } else if (credentials.platform == WeChatAuthProvider.PLATFORM) {
            service.getWeChatAuthProvider(context).getUserInfo(credentials, listener)
        }
    }

    fun updateUserPayingState(context: Context, user: User): MutableLiveData<DataHolder<User>> {
        val newUser = User(userInfo = user.userInfo, credentials = user.credentials,
                isPayingUser = true)
        if (myUser == null) {
            myUser = MutableLiveData()
        }
        saveUserToPreference(context, newUser)
        myUser!!.postValue(DataHolder(data = newUser))

        return myUser!!
    }


    fun getTodoList(forceReload: Boolean = false): MutableLiveData<DataHolder<MutableList<TodoItem>>> {
        if (forceReload) {
            loadTodoList()
        }
        return todo
    }

    fun insertTodo(content: String, attachmentUri: Uri?, userId: String? = getUserId()): MutableLiveData<DataHolder<TodoItem>> {
        val liveItem = MutableLiveData<DataHolder<TodoItem>>()

        if (userId != null) {
            val newItem = TodoItem(task = content,
                    userId = userId)
            liveItem.value = DataHolder(data = newItem)

            val insert: (String?) -> Unit = { cosUri ->
                val encodeUrl = if (cosUri != null) URLEncoder.encode(cosUri, "UTF-8") else ""

                val request = HttpRequest.Builder<String>()
                        .method("GET")
                        .url(URL(String.format(API.addTodo, userId, content, encodeUrl)))
                        .build()
                doRequest(request, AddTodoResult::class.java, liveItem) { addTodoResult ->
                    var dataHolder = todo.value
                    if (dataHolder == null) {
                        dataHolder = DataHolder(data = ArrayList())
                    }

                    newItem.taskId = addTodoResult.id
                    dataHolder.data?.add(newItem)

                    todo.postValue(dataHolder)
                    liveItem.postValue(liveItem.value)
                }
            }

            if (attachmentUri != null) {
                uploadToCos(attachmentUri, userId, newItem, liveItem, insert)
            } else {
                insert.invoke(null)
            }
        } else {
            postError(liveItem, clientException = QCloudClientException("use not login"))
        }

        return liveItem
    }

    fun removeTodo(liveItem: MutableLiveData<DataHolder<TodoItem>>, userId: String? = getUserId()) {
        val todoItem = liveItem.value?.data ?: throw IllegalArgumentException("item is null!")

        if (userId != null) {
            val delete = {
                val request = HttpRequest.Builder<String>()
                        .method("GET")
                        .url(URL(String.format(API.removeTodo, userId, todoItem.taskId)))
                        .build()
                doRequest(request, RemoveTodoResult::class.java, liveItem) {
                    if (todo.value?.data?.remove(todoItem) == true) {
                        todo.postValue(todo.value)
                    }
                    todoItem.taskId = null
                    liveItem.postValue(liveItem.value)
                }
            }
            if (!TextUtils.isEmpty(todoItem.attachment)) {
                removeFromCos(Uri.parse(todoItem.attachment!!), liveItem, delete)
            } else {
                delete.invoke()
            }
        } else {
            postError(liveItem, clientException = QCloudClientException("use not login"))
        }
    }

    fun getItem(taskId: String): MutableLiveData<DataHolder<TodoItem>>? {
        val todoList = getTodoList().value?.data
        val item = todoList?.firstOrNull {
            it.taskId == taskId
        }
        if (item != null) {
            val livaItem = MutableLiveData<DataHolder<TodoItem>>()
            livaItem.value = DataHolder(data = item)
            return livaItem
        }
        return null
    }

    private fun loadTodoList(userId: String? = getUserId()) {
        if (userId != null) {
            val request = HttpRequest.Builder<String>()
                    .method("GET")
                    .url(URL(String.format(API.listTodo, userId)))
                    .build()
            doRequest(request, ListTodoResult::class.java, todo) { listTodoResult ->
                if (listTodoResult.data != null) {
                    todo.postValue(DataHolder(data = listTodoResult.data))
                }
            }
        } else {
            postError(todo, clientException = QCloudClientException("use not login"))
        }
    }

    private fun uploadToCos(attachmentUri: Uri, userId: String, todoItem: TodoItem, item: MutableLiveData<DataHolder<TodoItem>>, insert: (String?) -> Unit) {
        val name = System.currentTimeMillis()
        val reference = storageService.referenceWithPath("/todo/$userId/$name")
        reference.putFile(attachmentUri, null).addResultListener(object : StorageResultListener<TACStorageTaskSnapshot> {
            override fun onSuccess(snapshot: TACStorageTaskSnapshot?) {
                todoItem.attachment = snapshot?.remoteUrl
                insert.invoke(todoItem.attachment)
            }

            override fun onFailure(snapshot: TACStorageTaskSnapshot?) {
                if (snapshot?.error is QCloudClientException) {
                    postError(item, clientException = snapshot.error as QCloudClientException)
                } else if (snapshot?.error is QCloudServiceException) {
                    postError(item, serviceException = snapshot?.error as QCloudServiceException)
                }
            }
        })
    }

    private fun removeFromCos(attachmentUri: Uri, item: MutableLiveData<DataHolder<TodoItem>>, delete: () -> Unit) {
        val reference = storageService.referenceWithPath(attachmentUri.path)
        reference.delete().addResultListener(object : StorageResultListener<TACStorageTaskSnapshot> {
            override fun onSuccess(snapshot: TACStorageTaskSnapshot?) {
                delete.invoke()
            }

            override fun onFailure(snapshot: TACStorageTaskSnapshot?) {
                if (snapshot?.error is QCloudClientException) {
                    postError(item, clientException = snapshot.error as QCloudClientException)
                } else if (snapshot?.error is QCloudServiceException) {
                    postError(item, serviceException = snapshot.error as QCloudServiceException)
                }
            }
        })
    }

    private fun getUserId(): String? {
        return myUser?.value?.data?.userInfo?.openId
    }

    private fun getUserFromPreference(context: Context): User? {
        val sharedPreferences = context.getSharedPreferences(preferenceName, Context.MODE_PRIVATE)

        return sharedPreferences.run {
            if (getString(KEY_USER_ACCESS_TOKEN, null) == null) {
                return null
            }
            val credentials = OAuth2Credentials.Builder()
                    .openId(getString(KEY_USER_OPEN_ID, null))
                    .platform(getString(KEY_USER_PLATFORM, null))
                    .accessToken(getString(KEY_USER_ACCESS_TOKEN, null))
                    .refreshToken(getString(KEY_USER_REFRESH_TOKEN, null))
                    .expiresInSeconds(getLong(KEY_USER_TOKEN_VALID_DATE, 0))
                    .build()
            val userInfo = TACOpenUserInfo(
                    getString(KEY_USER_OPEN_ID, null),
                    getString(KEY_USER_NICK_NAME, null),
                    getString(KEY_USER_AVATAR, null),
                    JSONObject()
            )
            User(userInfo, credentials, getBoolean(KEY_IS_PAYING, false))
        }
    }

    private fun saveUserToPreference(context: Context, user: User) {
        val sharedPreferences = context.getSharedPreferences(preferenceName, Context.MODE_PRIVATE)

        with(user) {
            sharedPreferences.edit {
                putString(KEY_USER_OPEN_ID, credentials.openId)
                putString(KEY_USER_PLATFORM, credentials.platform)
                putString(KEY_USER_ACCESS_TOKEN, credentials.accessToken)
                putString(KEY_USER_REFRESH_TOKEN, credentials.refreshToken)
                putLong(KEY_USER_TOKEN_VALID_DATE, credentials.validFromDate?.time ?: 0)
                putString(KEY_USER_NICK_NAME, userInfo?.nickName)
                putString(KEY_USER_AVATAR, userInfo?.avatar)
                putBoolean(KEY_IS_PAYING, isPayingUser)
            }
        }
    }
}