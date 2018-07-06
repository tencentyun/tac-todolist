package com.tencent.qcloud.todolist

import android.app.Activity
import android.app.AlertDialog
import android.app.Dialog
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.FragmentActivity
import com.tencent.tac.social.R
import com.tencent.tac.social.share.ShareChannel
import com.tencent.tac.social.share.ShareUIRenderer
import com.tencent.tac.social.share.TACShareDialog

/**
 * <p>
 * </p>
 * Created by wjielai on 2018/6/15.
 * Copyright 2010-2017 Tencent Cloud. All Rights Reserved.
 */
class ShareDialogFragment: DialogFragment(), ShareUIRenderer {
    private var channels: IntArray? = null
    private var callback: TACShareDialog.Callback? = null

    override fun showChooser(activity: Activity, channels: IntArray, callback: TACShareDialog.Callback) {
        this.callback = callback
        activity as FragmentActivity
        val ft = activity.supportFragmentManager.beginTransaction()
        val prev = activity.supportFragmentManager.findFragmentByTag("dialog")
        if (prev != null) {
            ft.remove(prev)
        }
        ft.addToBackStack(null)

        // Create and show the dialog.
        val args = Bundle()
        args.putIntArray("channels", channels)
        arguments = args
        show(ft, "dialog")
    }

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val builder = AlertDialog.Builder(activity, R.style.TACShareBottomDialogStyle)
        val inflater = activity?.layoutInflater
        val view = inflater?.inflate(com.tencent.qcloud.todolist.R.layout.custom_dialog_share, null)
        if (view != null) {
            initChannels(view)
            builder.setView(view)
        }

        val dialog = builder.create()
        dialog.setCanceledOnTouchOutside(true)

        return dialog
    }

    override fun onStart() {
        super.onStart()
        val dialog = dialog

        if (dialog != null && dialog.window != null) {
            dialog.window!!.setGravity(Gravity.BOTTOM)
            dialog.window!!.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        }
    }

    private fun initChannels(view: View) {
        channels = arguments?.getIntArray("channels")
        val VIEW_SIZE = 6
        val COLUMN_COUNT = 4

        if (channels != null) {
            val iconIds = IntArray(VIEW_SIZE)
            iconIds[0] = R.id.btn_share1
            iconIds[1] = R.id.btn_share2
            iconIds[2] = R.id.btn_share3
            iconIds[3] = R.id.btn_share4
            iconIds[4] = R.id.btn_share5
            iconIds[5] = R.id.btn_share6

            val labelIds = IntArray(VIEW_SIZE)
            labelIds[0] = R.id.label_share1
            labelIds[1] = R.id.label_share2
            labelIds[2] = R.id.label_share3
            labelIds[3] = R.id.label_share4
            labelIds[4] = R.id.label_share5
            labelIds[5] = R.id.label_share6

            var channelIdx = 0
            for (i in 0 until VIEW_SIZE) {
                val iconAndLabelIds = IntArray(2)
                while (channelIdx < channels!!.size) {
                    getIconAndLabel(channels!![channelIdx++], iconAndLabelIds)
                    if (iconAndLabelIds[0] > 0 && iconAndLabelIds[1] > 0) {
                        break
                    }
                }
                val iconView = view.findViewById<ImageView>(iconIds[i])
                val labelView = view.findViewById<TextView>(labelIds[i])
                if (iconAndLabelIds[0] > 0 && iconAndLabelIds[1] > 0) {
                    iconView.setImageResource(iconAndLabelIds[0])
                    iconView.tag = channels!![channelIdx - 1]
                    labelView.setText(iconAndLabelIds[1])
                    iconView.setOnClickListener { v ->
                        onChannelSelected(activity, v.tag as Int, callback)
                        dismiss()
                    }
                } else if (i < COLUMN_COUNT) {
                    iconView.visibility = View.INVISIBLE
                    labelView.visibility = View.INVISIBLE
                } else {
                    iconView.visibility = View.GONE
                    labelView.visibility = View.GONE
                }
            }
        }

        view.findViewById<View>(R.id.btn_cancel).setOnClickListener { dismiss() }
    }

    private fun getIconAndLabel(channel: Int, ids: IntArray) {
        var iconId = 0
        var labelId = 0
        when (channel) {
            ShareChannel.WECHAT_SESSION -> {
                iconId = R.drawable.ic_tac_share_wechat_session
                labelId = R.string.tac_share_wechat_session
            }
            ShareChannel.WECHAT_TIMELINE -> {
                iconId = R.drawable.ic_tac_share_wechat_timeline
                labelId = R.string.tac_share_wechat_timeline
            }
            ShareChannel.WECHAT_FAVORITE -> {
            }
            ShareChannel.QQ -> {
                iconId = R.drawable.ic_tac_share_qq
                labelId = R.string.tac_share_qq
            }
            ShareChannel.QZONE -> {
                iconId = R.drawable.ic_tac_share_qzone
                labelId = R.string.tac_share_qzone
            }
            ShareChannel.WEIBO -> {
                iconId = R.drawable.ic_tac_share_weibo
                labelId = R.string.tac_share_weibo
            }
            ShareChannel.SYSTEM -> {
                iconId = R.drawable.ic_tac_share_others
                labelId = R.string.tac_share_others
            }
            else -> {
            }
        }

        ids[0] = iconId
        ids[1] = labelId
    }

    /**
     * 选择要分享的渠道，默认行为是直接调用 [com.tencent.tac.social.share.TACShareDialog.Callback.onChannelSelected]
     * 方法，进行分享。
     *
     * @param activity Activity 上下文
     * @param channel 分享渠道
     * @param callback 回调执行器
     */
    private fun onChannelSelected(activity: Activity?, channel: Int, callback: TACShareDialog.Callback?) {
        callback!!.onChannelSelected(activity, channel)
    }
}