JWT
=====

# 什么是JWT ？

JSON Web Token（JWT）是一种用于在网络应用中实现用户认证和授权的开放标准，它基于JSON（JavaScript对象表示法）格式。
JWT通常用于在用户登录成功后，将用户信息（如用户名、密码）进行加密，并返回给用户，用户在每次请求时，将加密后的信息发送给服务器，服务器可以通过解密信息来验证用户身份。

# Usage

### 验证令牌签名算法

- 使用 [jwt.io](https://jwt.io/) 解码令牌，查看 `alg` 字段。
- 如果是第三方服务生成的令牌，确认其签名算法是否为 `RS256`。

### 创建密钥文件

创建密钥文件需要使用 openssl 命令行工具。

#### 可以通过以下命令生成：

```bash
openssl genrsa -out private_key.pem 2048
openssl rsa -in private_key.pem -pubout -out public_key.pem
```

# Issue

# Reference

