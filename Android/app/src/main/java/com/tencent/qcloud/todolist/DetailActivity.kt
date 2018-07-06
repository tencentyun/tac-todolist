package com.tencent.qcloud.todolist

import android.content.Intent
import android.graphics.PorterDuff
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.text.TextUtils
import android.view.Menu
import android.view.MenuItem
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.widget.toast
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import com.squareup.picasso.Picasso
import com.tencent.qcloud.core.logger.QCloudLogger
import com.tencent.qcloud.todolist.model.DataHolder
import com.tencent.qcloud.todolist.model.TodoItem
import com.tencent.qcloud.todolist.vm.TodoViewModel
import com.tencent.tac.social.share.PlainTextObject
import com.tencent.tac.social.share.TACShareDialog
import kotlinx.android.synthetic.main.activity_item_detail.*


/**
 * <p>
 * </p>
 * Created by wjielai on 2018/6/6.
 * Copyright 2010-2017 Tencent Cloud. All Rights Reserved.
 */
class DetailActivity : AppCompatActivity() {

    private lateinit var todoViewModel: TodoViewModel
    private lateinit var todo: MutableLiveData<DataHolder<TodoItem>>
    private var shareDialog: TACShareDialog? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_item_detail)

        // add back arrow to toolbar
        if (supportActionBar != null) {
            supportActionBar?.setDisplayHomeAsUpEnabled(true)
            supportActionBar?.setDisplayShowHomeEnabled(true)
        }

        todoViewModel = ViewModelProviders.of(this).get(TodoViewModel::class.java)

        val taskId = intent.extras?.getString("taskId") ?: return finish()
        todo = todoViewModel.item(taskId) ?: return finish()
        val todoItem = todo.value?.data?: return finish()

        todo_content.text = todoItem.task
        val errorDrawable = ColorDrawable(ContextCompat.getColor(this, R.color.attachment_placeholder))
        val progressDrawable = ColorDrawable(ContextCompat.getColor(this, R.color.attachment_placeholder))
        if (!TextUtils.isEmpty(todoItem.attachment)) {
            Picasso.get().load(todoItem.attachment)
                    .placeholder(progressDrawable)
                    .error(errorDrawable)
                    .into(img_attachment)
        } else {
            img_attachment.visibility = View.GONE
        }

    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        // Inflate the menu; this adds items to the action bar if it is present.
        menuInflater.inflate(R.menu.detail, menu)
        val iconDrawable = menu.getItem(0).icon
        iconDrawable.mutate()
        iconDrawable.setColorFilter(ContextCompat.getColor(this, android.R.color.white), PorterDuff.Mode.SRC_IN)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        val id = item.itemId


        return when (id) {
            R.id.action_share -> {
                share()
                true
            }
            android.R.id.home -> {
                finish()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        val shareResult = shareDialog?.getQQShareResult(requestCode, resultCode, data)
        QCloudLogger.i(LOG_TAG, "qq share result : " + shareResult?.result)
    }

    private fun share() {
        shareDialog = TACShareDialog(ShareDialogFragment())
        shareDialog?.share(this, PlainTextObject(todo.value?.data?.task))
    }

    fun markDone(view: View) {
        todoViewModel.markDone(todo).observe(this, Observer {
            loading.visibility = View.GONE
            val todoItem = it?.data
            if (todoItem != null && todoItem.taskId == null) {
                finish()
            } else {
                val message = it?.getExceptionMessage()
                if (message != null) {
                    toast(message)
                }
            }
        })
        loading.visibility = View.VISIBLE
    }
}