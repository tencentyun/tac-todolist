package com.tencent.qcloud.todolist.vm

import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.MutableLiveData
import com.tencent.qcloud.core.auth.OAuth2Credentials
import com.tencent.qcloud.core.common.QCloudClientException
import com.tencent.qcloud.core.common.QCloudResultListener
import com.tencent.qcloud.core.common.QCloudServiceException
import com.tencent.qcloud.todolist.data.Payment
import com.tencent.qcloud.todolist.data.Repository
import com.tencent.qcloud.todolist.model.DataHolder
import com.tencent.qcloud.todolist.model.PayOrder
import com.tencent.qcloud.todolist.model.User
import com.tencent.tac.authorization.TACAuthorizationService
import com.tencent.tac.social.auth.QQAuthProvider
import com.tencent.tac.social.auth.WeChatAuthProvider

/**
 * <p>
 * </p>
 * Created by wjielai on 2018/6/5.
 * Copyright 2010-2017 Tencent Cloud. All Rights Reserved.
 */
class UserViewModel(application : Application) : AndroidViewModel(application), QCloudResultListener<OAuth2Credentials> {

    private var qqAuthProvider : QQAuthProvider? = null
    private var wechatAuthProvider : WeChatAuthProvider? = null
    private val handler = Handler(Looper.getMainLooper())

    val user : MutableLiveData<DataHolder<User>> by lazy {
        repository.getUser(application)
    }

    private val repository = Repository.instance

    fun needSignIn() : Boolean {
        return user.value?.data?.credentials == null
    }

    fun signIn(activity: Activity, platform: String) {
        val service = TACAuthorizationService.getInstance()
        if (platform == QQAuthProvider.PLATFORM) {
            qqAuthProvider = service.getQQAuthProvider(activity)
            qqAuthProvider?.signIn(activity, this)
        } else if (platform == WeChatAuthProvider.PLATFORM) {
            wechatAuthProvider = service.getWeChatAuthProvider(activity)
            wechatAuthProvider?.signIn(this)
        }
    }

    override fun onSuccess(result: OAuth2Credentials) {
        loadUser(getApplication(), result)
    }

    override fun onFailure(clientException: QCloudClientException?, serviceException: QCloudServiceException?) {
        user.postValue(DataHolder(clientException = clientException, serviceException = serviceException))
    }

    fun handleQQSignInResult(requestCode: Int, resultCode: Int, data: Intent?) {
        qqAuthProvider?.handleActivityResult(requestCode, resultCode, data)
    }

    private fun loadUser(context: Context, credentials: OAuth2Credentials) {
        if (TextUtils.isEmpty(credentials.accessToken)) {
            onFailure(null, serviceException = QCloudServiceException("access token is null"))
            return
        }

        repository.loadUser(context, credentials = credentials)
    }

    fun newPaymentOrder(method: String): MutableLiveData<DataHolder<PayOrder>> {
        val userId = user.value?.data?.userInfo?.openId
        if (userId != null) {
            return Payment.newOrder(method, userId)
        } else {
            throw IllegalStateException("user not signIn")
        }
    }

    fun checkUserState() {
        handler.post({
            // 支付成功认为是
            repository.updateUserPayingState(getApplication(), user.value!!.data!!)
        })
    }

    override fun onCleared() {
        super.onCleared()

        handler.removeCallbacksAndMessages(null)
    }
}