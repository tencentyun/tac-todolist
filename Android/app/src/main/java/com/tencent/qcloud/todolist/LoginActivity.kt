package com.tencent.qcloud.todolist

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.widget.toast
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import com.tencent.qcloud.core.common.QCloudClientException
import com.tencent.qcloud.core.common.QCloudServiceException
import com.tencent.qcloud.todolist.vm.UserViewModel
import com.tencent.tac.social.auth.QQAuthProvider
import com.tencent.tac.social.auth.WeChatAuthProvider
import kotlinx.android.synthetic.main.activity_login.*

inline fun <reified T : Any> Activity.launchActivity(
        requestCode: Int = -1,
        options: Bundle? = null,
        noinline init: Intent.() -> Unit = {}) {
    val intent = newIntent<T>(this)
    intent.init()
    if (requestCode >= 0) {
        startActivityForResult(intent, requestCode, options)
    } else {
        startActivity(intent, options)
    }
}

inline fun <reified T : Any> newIntent(context: Context): Intent =
        Intent(context, T::class.java)


/**
 * A login screen that offers login via email/password.
 */
class LoginActivity : AppCompatActivity() {

    private lateinit var userViewModel : UserViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        userViewModel = ViewModelProviders.of(this).get(UserViewModel::class.java)
        if (!userViewModel.needSignIn()) {
            launchActivity<MainActivity>()
            finish()
            return
        }

        setContentView(R.layout.activity_login)

        userViewModel.user.observe(this, Observer { dataHolder ->
            if (dataHolder?.data != null) {
                launchActivity<MainActivity>()
                finish()
            } else if (dataHolder?.clientException != null || dataHolder?.serviceException != null){
                onFailure(dataHolder.clientException, dataHolder.serviceException)
            }
        })

        signIn_qq.setOnClickListener {
            userViewModel.signIn(this, QQAuthProvider.PLATFORM)
        }

        signIn_wechat.setOnClickListener {
            userViewModel.signIn(this, WeChatAuthProvider.PLATFORM)
        }

    }

    private fun onFailure(clientException: QCloudClientException?,
                           serviceException: QCloudServiceException?) {
        toast(R.string.signIn_failure, Toast.LENGTH_LONG)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        userViewModel.handleQQSignInResult(requestCode, resultCode, data)
    }
}
