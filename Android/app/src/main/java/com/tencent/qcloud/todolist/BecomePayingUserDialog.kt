package com.tencent.qcloud.todolist

import android.app.AlertDialog
import android.app.Dialog
import android.os.Bundle
import androidx.fragment.app.DialogFragment
import androidx.lifecycle.ViewModelProviders
import com.tencent.qcloud.todolist.vm.UserViewModel

/**
 * <p>
 * </p>
 * Created by wjielai on 2018/6/13.
 * Copyright 2010-2017 Tencent Cloud. All Rights Reserved.
 */
class BecomePayingUserDialog : DialogFragment() {

    private lateinit var myActivity: MainActivity

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        myActivity = activity as MainActivity

        val userViewModel = ViewModelProviders.of(myActivity).get(UserViewModel::class.java)
        if (userViewModel.user.value?.data?.isPayingUser == true) {
            return AlertDialog.Builder(activity)
                    .setIcon(R.drawable.ic_launcher_background)
                    .setTitle(R.string.become_paying_user)
                    .setMessage(R.string.paying_user_already)
                    .setPositiveButton(android.R.string.ok, { _, _ ->
                        dismiss()
                    })
                    .create()
        } else {
            return AlertDialog.Builder(activity)
                    .setIcon(R.drawable.ic_launcher_background)
                    .setTitle(R.string.become_paying_user)
                    .setMessage(R.string.paying_user_privilege)
                    .setPositiveButton(android.R.string.ok, { dialog, whichButton ->
                        pickPayMethod()
                    })
                    .setNegativeButton(android.R.string.no, { dialog, whichButton ->
                        dismiss()
                    })
                    .create()
        }
    }

    private fun pickPayMethod() {
        val methods = arrayOf(getString(R.string.pay_by_qq), getString(R.string.pay_by_wechat))
        AlertDialog.Builder(activity)
                .setIcon(R.drawable.ic_launcher_background)
                .setTitle(R.string.become_paying_user)
                .setItems(methods) {dialog, method ->
                    myActivity.launchPay(method)
                    dismiss()
                }
                .create().show()
    }
}