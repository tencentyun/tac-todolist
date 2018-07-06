package com.tencent.qcloud.todolist

import android.os.Bundle
import android.text.TextUtils
import android.view.*
import android.widget.CheckBox
import android.widget.CompoundButton
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.ActionBarDrawerToggle
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import androidx.core.view.GravityCompat
import androidx.core.widget.toast
import androidx.drawerlayout.widget.DrawerLayout
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.google.android.material.floatingactionbutton.FloatingActionButton
import com.google.android.material.navigation.NavigationView
import com.tencent.qcloud.core.logger.QCloudLogger
import com.tencent.qcloud.todolist.model.PayOrder
import com.tencent.qcloud.todolist.model.TodoItem
import com.tencent.qcloud.todolist.vm.TodoViewModel
import com.tencent.qcloud.todolist.vm.UserViewModel
import com.tencent.tac.payment.PaymentRequest
import com.tencent.tac.payment.PaymentResult
import com.tencent.tac.payment.TACPaymentService
import kotlinx.android.synthetic.main.app_bar_main.*
import kotlinx.android.synthetic.main.nav_header_main.view.*
import java.util.*

const val LOG_TAG =  "TACTodoList"

class TodoListAdapter(private val todoList: ArrayList<TodoItem>,
                      private val todoViewModel: TodoViewModel,
                      private val activity: AppCompatActivity) :
        RecyclerView.Adapter<TodoListAdapter.ViewHolder>(),
        CompoundButton.OnCheckedChangeListener,
        View.OnClickListener {

    // Provide a reference to the views for each data item
    // Complex data items may need more than one view per item, and
    // you provide access to all the views for a data item in a view holder.
    // Each data item is just a string in this case that is shown in a TextView.
    class ViewHolder constructor(view: View) : RecyclerView.ViewHolder(view) {
        val taskView = view.findViewById<TextView>(R.id.text_task)!!
        val checkView = view.findViewById<CheckBox>(R.id.todo_checked)!!
        val attachView = view.findViewById<ImageView>(R.id.img_attachment)!!
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        // create a new view
        val childView = LayoutInflater.from(parent.context)
                .inflate(R.layout.layout_todo_item, parent, false)
        return ViewHolder(childView)
    }

    // Replace the contents of a view (invoked by the layout manager)
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = todoList[position]
        holder.taskView.text = item.task

        holder.checkView.tag = item
        holder.itemView.tag = item.taskId

        holder.checkView.setOnCheckedChangeListener(this)
        holder.checkView.isChecked = false
        holder.attachView.visibility = if (TextUtils.isEmpty(item.attachment)) View.GONE else View.VISIBLE

        holder.itemView.setOnClickListener(this)
    }

    override fun onCheckedChanged(button: CompoundButton?, checked: Boolean) {
        if (checked) {
            todoViewModel.markDone(button?.tag as TodoItem).observe(activity, Observer {
                val message = it?.getExceptionMessage()
                if (message != null) {
                    activity.toast(message)
                }
            })
        }
    }

    override fun onClick(view: View?) {
        val taskId: String? = view?.tag as String
        if (taskId != null) {
            activity.launchActivity<DetailActivity> {
                putExtra("taskId", taskId)
            }
        }
    }

    // Return the size of your dataset (invoked by the layout manager)
    override fun getItemCount() = todoList.size
}

class ItemDiffCallback(private val oldList: List<TodoItem>, private val newList: MutableList<TodoItem>) : DiffUtil.Callback() {

    override fun areContentsTheSame(oldItemPosition: Int, newItemPosition: Int): Boolean {
        return oldList[oldItemPosition] == newList[newItemPosition]
    }

    override fun areItemsTheSame(oldItemPosition: Int, newItemPosition: Int): Boolean {
        return oldList[oldItemPosition].taskId == newList[newItemPosition].taskId
    }

    override fun getOldListSize(): Int {
        return oldList.size
    }

    override fun getNewListSize(): Int {
        return newList.size
    }
}

class MainActivity : AppCompatActivity(), NavigationView.OnNavigationItemSelectedListener,
        SwipeRefreshLayout.OnRefreshListener {

    private lateinit var viewAdapter: RecyclerView.Adapter<*>
    private lateinit var viewManager: LinearLayoutManager

    private val todoList = ArrayList<TodoItem>()

    private lateinit var userViewModel: UserViewModel
    private lateinit var todoViewModel: TodoViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val toolbar = findViewById<View>(R.id.toolbar) as Toolbar
        setSupportActionBar(toolbar)

        val fab = findViewById<View>(R.id.fab) as FloatingActionButton
        fab.setOnClickListener {
            launchActivity<NewItemActivity> { }
        }

        val drawer = findViewById<View>(R.id.drawer_layout) as DrawerLayout
        val toggle = ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close)
        drawer.addDrawerListener(toggle)
        toggle.syncState()

        val navigationView = findViewById<View>(R.id.nav_view) as NavigationView
        navigationView.setNavigationItemSelectedListener(this)

        swiperefresh.setOnRefreshListener(this)

        userViewModel = ViewModelProviders.of(this).get(UserViewModel::class.java)
        todoViewModel = ViewModelProviders.of(this).get(TodoViewModel::class.java)

        viewManager = LinearLayoutManager(this)
        viewAdapter = TodoListAdapter(todoList, todoViewModel, this)
        list_todo.apply {
            // use this setting to improve performance if you know that changes
            // in content do not change the layout size of the RecyclerView
            setHasFixedSize(true)

            // use a linear layout manager
            layoutManager = viewManager

            // specify an viewAdapter (see also next example)
            adapter = viewAdapter

            addItemDecoration(DividerItemDecoration(context, viewManager.orientation))

        }

        userViewModel.user.observe(this, Observer { userDataHolder ->
            navigationView.getHeaderView(0).tv_name.text = userDataHolder?.data?.userInfo?.nickName
            if (userDataHolder?.data?.isPayingUser == true) {
                navigationView.getHeaderView(0).tv_desc.setText(R.string.vip_desc)
                val menu = navigationView.menu.findItem(R.id.paying)
                menu.isVisible = false
                toast(R.string.vip_desc)
            }
        })

        todoViewModel.list().observe(this, Observer { newList ->
            val err = newList?.getExceptionMessage()
            if (err != null) {
                toast(err)
            } else if (newList?.data != null) {
                val diffResult = DiffUtil.calculateDiff(ItemDiffCallback(todoList, newList.data))
                todoList.clear()
                todoList.addAll(newList.data)
                diffResult.dispatchUpdatesTo(viewAdapter)
            }
            swiperefresh.isRefreshing = false
        })

        swiperefresh.post {
            swiperefresh.isRefreshing = true
            onRefresh()
        }
    }

    override fun onRefresh() {
        todoViewModel.reloadList()
    }

    override fun onBackPressed() {
        val drawer = findViewById<View>(R.id.drawer_layout) as DrawerLayout
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START)
        } else {
            super.onBackPressed()
        }
    }

    internal fun launchPay(method: Int) {
        val s = if (method == 0) "qqwallet" else "wechat"
        userViewModel.newPaymentOrder(s).observe(this, Observer { data ->
            val message = data?.getExceptionMessage()
            if (message != null) {
                toast(message)
            } else if (data?.data != null) {
                pay(data.data)
            }
        })
    }

    private fun pay(payOrder: PayOrder) {
        val paymentRequest = PaymentRequest(payOrder.userId, payOrder.payInfo)
        paymentRequest.addMetaData("name", payOrder.userId)

        TACPaymentService.getInstance().launchPayment(this, paymentRequest, {resultCode: Int, result: PaymentResult ->
            QCloudLogger.i(LOG_TAG, "payment return code $resultCode, and result is $result")
            if (resultCode == 0) {
                toast(R.string.pay_success)
                userViewModel.checkUserState()
            } else {
                toast(R.string.pay_failed)
            }
        })
    }

    private fun becomePayingUser() {
        val newFragment = BecomePayingUserDialog()
        val oldFragment = supportFragmentManager.findFragmentByTag("dialog")
        if (oldFragment != null) {
            supportFragmentManager.beginTransaction().remove(oldFragment).commit()
        }

        newFragment.show(supportFragmentManager, "dialog")
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        // Inflate the menu; this adds items to the action bar if it is present.
        menuInflater.inflate(R.menu.main, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        val id = item.itemId


        return if (id == R.id.action_settings) {
            becomePayingUser()
            true
        } else super.onOptionsItemSelected(item)

    }

    override fun onNavigationItemSelected(item: MenuItem): Boolean {
        // Handle navigation view item clicks here.
        val id = item.itemId

        if (id == R.id.paying) {
            becomePayingUser()
        }

        val drawer = findViewById<View>(R.id.drawer_layout) as DrawerLayout
        drawer.closeDrawer(GravityCompat.START)
        return true
    }
}
