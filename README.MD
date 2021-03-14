## nginx-RPC

#### 参考资料

* [openresty](http://openresty.org/en/installation.html)

### 安装依赖

yum -y install libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl 

### 下载项目并安装nginx
``` 
   
    cd html
    mkdir src
    cd src && sh ./../shell/install.sh --prefix=/data/hmprogram/nginx-lua --openresty-version=1.13.6.2
    cd ../
    rm -rf src
    chown -R huimin.huimin /data/webserver/service-rpc
```

### 启动nginx
```
    cd /data/hmprogram/nginx-lua && ./sbin/nginx -c /data/hmprogram/nginx-lua/nginx/conf/nginx.conf
```

### 接口说明

1. 聚合接口
	* 地址: /agg
	* 请求方式: POST body
	* 参数 
	
	名称|数据类型|取值范围|说明
	--:|:-----:|:-----:|---
	server_name|string|length<255|eureka中注册的服务名称,例如promotion-v1
	method|string||请求方式、不限定请求方式
	uri|string||请求路径
	args|array||请求参数
	body|string||body内容，格式请在头中声名
	headers|array| | 头信息
	* 请求参数示例
	
	```
	[
    {
        "server_name": "promotion-v1",
        "method": "post",
        "uri": "/product/promotionRule/validateCartPromotion",
        "body": "{\"app_name\":\"shopcar-v3\",\"product_list\":[{\"id\":143531,\"count\":1,\"isUpdate\":0,\"sku_id\":8263,\"unit_price\":4900,\"is_gift\":0,\"promotion_id\":10032927,\"is_full_purchase\":1,\"promotion_num\":1,\"full_purchase_promotion\":0},{\"id\":143532,\"count\":1,\"isUpdate\":0,\"sku_id\":8269,\"unit_price\":3700,\"is_gift\":0,\"promotion_id\":10032927,\"is_full_purchase\":1,\"promotion_num\":1,\"full_purchase_promotion\":0},{\"id\":143536,\"count\":1,\"isUpdate\":0,\"sku_id\":777,\"unit_price\":0,\"is_gift\":1,\"promotion_id\":10032915,\"is_full_purchase\":1,\"promotion_num\":1,\"full_purchase_promotion\":0},{\"id\":143533,\"count\":1,\"isUpdate\":0,\"sku_id\":14488,\"unit_price\":4200,\"is_gift\":0,\"promotion_id\":10032916,\"is_full_purchase\":1,\"promotion_num\":1,\"full_purchase_promotion\":0},{\"id\":143534,\"count\":1,\"isUpdate\":0,\"sku_id\":14487,\"unit_price\":3500,\"is_gift\":0,\"promotion_id\":10032916,\"is_full_purchase\":1,\"promotion_num\":1,\"full_purchase_promotion\":0},{\"id\":143535,\"count\":1,\"isUpdate\":0,\"sku_id\":44772,\"unit_price\":5000,\"is_gift\":0,\"promotion_id\":10032915,\"is_full_purchase\":1,\"promotion_num\":1,\"full_purchase_promotion\":0},{\"id\":143537,\"count\":2,\"isUpdate\":0,\"sku_id\":45431,\"unit_price\":4800,\"is_gift\":0,\"promotion_id\":10032913,\"is_full_purchase\":1,\"promotion_num\":1,\"full_purchase_promotion\":0}],\"events\":[{\"id\":1,\"num\":1,\"promotionType\":0,\"event_name\":\"product_add\",\"promotion_id\":10032913,\"sku_id\":45431,\"select_product\":[],\"unit_price\":4800,\"is_full_purchase\":1}],\"market_info\":{\"appName\":\"shopcar-v3\",\"store_id\":104,\"market_id\":176247,\"client\":30,\"user_type\":1,\"branch_id\":3,\"user_level\":0,\"business_type\":17,\"user_tags\":[9,26,36]},\"atomic_event\":0}",
        "headers": {
            "Content-type": "application/json; charset=utf8",
            "Accept": "application/json;charset=utf8"
        }
    },
    {
        "server_name": "promotion-v1",
        "method": "get",
        "uri": "/product/promotion/promotionStore",
        "args": {
            "promotion_ids": "10000220,10000066"
        },
        "headers": {
            "Content-type": "application/json; charset=utf8"
        }
    },
    {
        "server_name": "hmmq-v1",
        "method": "post",
        "uri": "/normal/send",
        "body": "{\"deliverTime\":[],\"key\":\"promotion-v1\",\"msg\":\"dfsdf\",\"shardingKey\":\"dfjskdfj\",\"tag\":\"sdfhsdf\",\"topic\":\"hm\"}",
        "headers": {
            "Content-type": "application/json; charset=utf8"
        }
    }
]
	```
	
2. 单个请求网关

```
$url = 'https://127.0.0.1:8090/dev/promotion-v1/product/?id=11';
$data = [
	'name' => 111,
	'val' => 'werr'
];
$ch = curl_init();
curl_setopt($ch, CURLOPT_HTTP_VERSION, 3);
curl_setopt($ch, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_2_0);
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
```
