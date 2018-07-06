package com.tencent.qcloud.todolist.data

import androidx.lifecycle.MutableLiveData
import com.tencent.qcloud.core.common.QCloudClientException
import com.tencent.qcloud.core.common.QCloudResultListener
import com.tencent.qcloud.core.common.QCloudServiceException
import com.tencent.qcloud.core.http.HttpRequest
import com.tencent.qcloud.core.http.HttpResult
import com.tencent.qcloud.core.http.QCloudHttpClient
import com.tencent.qcloud.todolist.model.DataHolder
import com.tencent.qcloud.todolist.model.PayOrder
import com.tencent.tac.TACApplication
import com.tencent.tac.option.TACApplicationOptions
import com.tencent.tac.payment.TACPaymentOptions
import org.json.JSONObject
import java.io.UnsupportedEncodingException
import java.net.URL
import java.security.InvalidKeyException
import java.security.KeyFactory
import java.security.NoSuchAlgorithmException
import java.security.SignatureException
import java.security.spec.InvalidKeySpecException
import java.security.spec.PKCS8EncodedKeySpec
import java.util.*

/**
 * <p>
 * </p>
 * Created by wjielai on 2018/6/21.
 * Copyright 2010-2017 Tencent Cloud. All Rights Reserved.
 */
object Payment {

    private const val MIDAS_SK_SANDBOX = "xxx"
    private const val MIDAS_SK_PUBLISH = "xxx"
    private const val MIDAS_SECRET_KEY = MIDAS_SK_PUBLISH

    // 使用本地下单，不建议这么做，应该将密钥配置在后台服务器
    private const val RSA_PRIVATE_KEY = "xxx"

    fun newOrder(method: String, userId: String): MutableLiveData<DataHolder<PayOrder>> {
        val applicationOptions: TACApplicationOptions = TACApplication.options()
                ?: throw IllegalStateException("no appId to pay")

        val tacPaymentOptions = applicationOptions.sub<TACPaymentOptions>("payment")
        val appId = tacPaymentOptions.appid
        val orderNo = "tactodo_open_" + System.currentTimeMillis()

        val params = HashMap<String, String>()
        params["user_id"] = userId
        params["channel"] = method
        params["out_trade_no"] = orderNo
        params["product_id"] = "product_test"
        params["currency_type"] = "CNY"
        params["amount"] = "1"
        params["product_name"] = "todolist"
        params["product_detail"] = "todolist_demo"
        params["ts"] = getGMTime()

        val url = makeOrderUrl(appId, params)

        val getOrderRequest = HttpRequest.Builder<String>()
                .url(URL(url))
                .method("GET")
                .build()
        val client = QCloudHttpClient.getDefault()
        val order = MutableLiveData<DataHolder<PayOrder>>()

        client.resolveRequest(getOrderRequest)
                .schedule()
                .addResultListener(object : QCloudResultListener<HttpResult<String>> {
                    override fun onSuccess(result: HttpResult<String>?) {
                        val content = result?.content()
                        if (content != null) {
                            val json = JSONObject(content)
                            val payInfo = json.getString("pay_info")
                            order.postValue(DataHolder(data = PayOrder(orderNo, payInfo, userId)))
                        } else {
                            order.postValue(DataHolder(serviceException = QCloudServiceException("content is null")))
                        }
                    }

                    override fun onFailure(clientException: QCloudClientException?,
                                           serviceException: QCloudServiceException?) {
                        order.postValue(DataHolder(clientException = clientException, serviceException = serviceException))
                    }
                })

        return order
    }

    private fun makeOrderUrl(appId: String, params: HashMap<String, String>): String {
        val flatParams = flatParams(params)
        val sourceToSign = flatParams + MIDAS_SECRET_KEY
        params["sign"] = encode(RSA_PRIVATE_KEY, sourceToSign)

        return "https://api.openmidas.com/v1/r/$appId/unified_order?${flatParams(params)}"
    }

    private fun getUrl(appId: String, params: HashMap<String, String>): String {
        params["appId"] = appId
        params["original_amount"] = params["amount"]!!

        return "http://carsonxu.com/tac/androidTodoOrder.php?domain=api.openmidas.com&{${flatParams(params)}"
    }

    private fun flatParams(params: Map<String, String>): String {
        val keys = params.keys.toTypedArray()
        Arrays.sort(keys)
        val buffer = StringBuilder(128)
        val buffer2 = StringBuilder()
        for (i in keys.indices) {
            buffer2.append(keys[i]).append("=").append(params[keys[i]])
            if (i != keys.size - 1) {
                buffer2.append("&")
            }
        }
        buffer.append(buffer2.toString())

        return buffer.toString()
    }

    private fun encode(rsaPrivateKey: String, contentToEncode: String): String {
        var privateKey = rsaPrivateKey
        privateKey = privateKey.replace("-----BEGIN ENCRYPTED PRIVATE KEY-----".toRegex(), "")
                .replace("-----END ENCRYPTED PRIVATE KEY-----".toRegex(), "").replace("\n".toRegex(), "")

        // 私钥需要进行Base64解密
        //byte[] b1 = Base64.getDecoder().decode(privateKey);
        val b1 = Base64Coder.decode(privateKey)

        try {
            // 将字节数组转换成PrivateKey对象
            val spec = PKCS8EncodedKeySpec(b1)
            val kf = KeyFactory.getInstance("RSA")
            val pk = kf.generatePrivate(spec)


            val privateSignature = java.security.Signature.getInstance("SHA256withRSA")
            privateSignature.initSign(pk)
            // 输入需要签名的内容
            privateSignature.update(contentToEncode.toByteArray(charset("UTF-8")))
            // 拿到签名后的字节数组
            val s = privateSignature.sign()

            // 将签名后拿到的字节数组做一个Base64编码，以便以字符串的形式保存
            //return Base64.getEncoder().encodeToString(s);
            return String(Base64Coder.encode(s))
        } catch (e: NoSuchAlgorithmException) {
            e.printStackTrace()
        } catch (e: InvalidKeyException) {
            e.printStackTrace()
        } catch (e: InvalidKeySpecException) {
            e.printStackTrace()
        } catch (e: SignatureException) {
            e.printStackTrace()
        } catch (e: UnsupportedEncodingException) {
            e.printStackTrace()
        }
        return ""
    }

    private fun getGMTime(): String {
        val timeZone = TimeZone.getTimeZone("GMT+8:00")
        // dateTime是格林威治时间
        val chineseMills = (System.currentTimeMillis() - timeZone.rawOffset) / 1000

        return chineseMills.toString() + ""
    }
}