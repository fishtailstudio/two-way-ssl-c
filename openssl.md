# 证书相关概念

## 什么是x509证书链

x509证书一般会用到三类文件，key，csr，crt。

- **key** 是私用密钥，openssl格式，通常是rsa算法。
- **csr** 是证书请求文件，用于申请证书。在制作csr文件的时候，必须使用自己的私钥来签署申请，还可以设定一个密钥。
- **crt** 是CA认证后的证书文件，签署人用自己的key给你签署的凭证。

## 证书类别

- **根证书** 生成服务器证书，客户端证书的基础。自签名。
- **服务器证书** 由根证书签发。配置在服务器上。
- **客户端证书** 由根证书签发。配置在服务器上，并发送给客户，让客户安装在浏览器里。

## openssl中有如下后缀名的文件

- .key格式：私有的密钥
- .csr格式：证书签名请求（证书请求文件），含有公钥信息，certificate signing request的缩写
- .crt格式：证书文件，certificate的缩写
- .crl格式：证书吊销列表，Certificate Revocation List的缩写
- .pem格式：用于导出，导入证书时候的证书的格式，有证书开头，结尾的格式
- .p12 "或者 “.pfx” : 用于实现存储许多加密对象在一个单独的文件中。通常用它来打包一个私钥及有关的 X.509 证书，或者打包信任链的全部项目。

# 生成CA证书

## 生成CA私钥

```sh
openssl genrsa -out ca.key 1024
```

## 生成证书请求

生成CA机构自己的证书申请文件

```sh
openssl req -new -key ca.key -out ca.csr -subj "/C=CN/ST=ZJ/L=HZ/O=HW/OU=DDM/CN=root/emailAddress=root@example.com"
```

## 生成自签名证书

CA机构用自己的私钥和证书申请文件生成自己签名的证书，俗称自签名证书，这里可以理解为根证书。

```sh
openssl x509 -req -in ca.csr -signkey ca.key -days 365 -out ca.crt
```

# 生成服务端证书

## 生成RSA密钥

```sh
openssl genrsa -out server.key 1024
```

## 生成证书请求

根据服务器私钥文件生成证书请求文件，这个文件中会包含申请人的一些信息，所以执行下面这行命令过程中需要用户在命令行输入一些用户信息。

```sh
openssl req -new -key server.key -out server.csr -subj "/C=CN/ST=ZJ/L=HZ/O=HW/OU=DDM/CN=root/emailAddress=root@example.com"
```

这个命令将会生成一个证书请求，当然，用到了前面生成的密钥 `server.key` 文件。
这里将生成一个新的文件 `server.csr`，即一个**证书请求文件**，你可以拿着这个文件去数字证书颁发机构（即CA）申请一个数字证书。CA会给你一个新的文件`server.crt`，那才是你的数字证书。

## 生成服务端证书

根据CA机构的自签名证书ca.crt或者叫根证书、CA机构的私钥ca.key、服务器的证书申请文件server.csr生成服务端证书

```sh
openssl x509 -req -CA ca.crt -CAkey ca.key -CAcreateserial -in server.csr -days 365 -out server.crt
```

# 生成客户端证书

```sh
openssl genrsa -out client.key 1024
openssl req -new -key client.key -out client.csr -subj "/C=CN/ST=ZJ/L=HZ/O=HW/OU=DDM/CN=root/emailAddress=root@example.com"
openssl x509 -req -CA ca.crt -CAkey ca.key -CAcreateserial -in client.csr -days 365 -out client.crt
```

## 命令汇总

```sh
openssl genrsa -out ca.key 1024
openssl req -new -nodes -key ca.key -out ca.pem -subj "/C=CN/ST=ZJ/L=HZ/O=HW/OU=DDM/CN=root/emailAddress=root@example.com"
openssl x509 -req -in ca.pem -signkey ca.key -days 365 -out ca.pem

openssl genrsa -out server.key 1024
openssl req -new -nodes -key server.key -out server.pem -subj "/C=CN/ST=ZJ/L=HZ/O=HW/OU=DDM/CN=root/emailAddress=root@example.com"
openssl x509 -req -CA ca.pem -CAkey ca.key -CAcreateserial -in server.pem -days 365 -out server.pem

openssl genrsa -out client.key 1024
openssl req -new -nodes -key client.key -out client.pem -subj "/C=CN/ST=ZJ/L=HZ/O=HW/OU=DDM/CN=root/emailAddress=root@example.com"
openssl x509 -req -CA ca.pem -CAkey ca.key -CAcreateserial -in client.pem -days 365 -out client.pem
```

# 证书导出

生成pem格式证书
有时需要用到pem格式的证书，可以用以下方式合并证书文件（crt）和私钥文件（key）来生成

```sh
cat client.crt client.key > client.pem 
cat server.crt server.key > server.pem
```

# 证书验证

在一个终端执行

```sh
openssl s_server -CAfile keys/ca.crt -cert keys/server.crt -key keys/server.key -Verify 1
```

在另一个终端执行

```sh
openssl s_client -CAfile keys/ca.crt -cert keys/client.crt -key keys/client.key
```

# 加密通信

```sh
./openssl server 50000 keys/ca.crt keys/server.crt keys/server.key
```

```sh
./openssl client 127.0.0.1:50000 keys/ca.crt keys/client.crt keys/client.key
```