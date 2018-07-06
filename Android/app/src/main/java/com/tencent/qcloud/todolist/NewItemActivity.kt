package com.tencent.qcloud.todolist

import android.content.Intent
import android.graphics.drawable.ColorDrawable
import android.net.Uri
import android.os.Bundle
import android.text.TextUtils
import android.view.MenuItem
import android.view.View
import android.widget.ImageView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.widget.toast
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import com.google.android.material.snackbar.Snackbar
import com.squareup.picasso.Picasso
import com.tencent.qcloud.todolist.vm.TodoViewModel
import com.tencent.qcloud.todolist.vm.UserViewModel
import kotlinx.android.synthetic.main.activity_new_item.*

/**
 * <p>
 * </p>
 * Created by wjielai on 2018/6/5.
 * Copyright 2010-2017 Tencent Cloud. All Rights Reserved.
 */
class NewItemActivity : AppCompatActivity() {

    private var attachmentUri : Uri? = null

    private lateinit var todoViewModel: TodoViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_new_item)

        // add back arrow to toolbar
        if (supportActionBar != null) {
            supportActionBar?.setDisplayHomeAsUpEnabled(true)
            supportActionBar?.setDisplayShowHomeEnabled(true)
        }

        val userViewModel = ViewModelProviders.of(this).get(UserViewModel::class.java)
        userViewModel.user.observe(this, Observer { user ->
            if (user?.data?.isPayingUser == true) {
                img_attachment.visibility =  View.VISIBLE
            } else {
                img_attachment.visibility =  View.GONE
            }
        })

        todoViewModel = ViewModelProviders.of(this).get(TodoViewModel::class.java)

        img_attachment.setOnClickListener {
            addAttachment(it)
        }
    }

    private fun addAttachment(view: View) {
        val intent = Intent(Intent.ACTION_GET_CONTENT)
        intent.type = "image/*"
        startActivityForResult(intent, 0)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 0) {
            attachmentUri = data?.data ?: return

            img_attachment.scaleType = ImageView.ScaleType.CENTER_CROP
            val placeholder = ColorDrawable(ContextCompat.getColor(this, R.color.attachment_placeholder))
            Picasso.get().load(attachmentUri)
                    .placeholder(placeholder)
                    .error(placeholder)
                    .into(img_attachment)
        }
    }

    fun commitItem(view : View) {
        val content = edit_content.text?.toString()
        if (content != null && !TextUtils.isEmpty(content)) {
            todoViewModel.insert(content, attachmentUri).observe(this, Observer {
                loading.visibility = View.GONE
                if (it?.data?.taskId != null) {
                    finish()
                } else {
                    val message = it?.getExceptionMessage()
                    if (message != null) {
                        toast(message)
                    }
                }
            })
            loading.visibility = View.VISIBLE
        }  else {
            Snackbar.make(edit_content, R.string.new_item_commit_empty, Snackbar.LENGTH_SHORT).show()
        }

    }

    override fun onOptionsItemSelected(item: MenuItem?): Boolean {
        if (item?.itemId == android.R.id.home) {
            finish()
        }

        return super.onOptionsItemSelected(item)
    }
}