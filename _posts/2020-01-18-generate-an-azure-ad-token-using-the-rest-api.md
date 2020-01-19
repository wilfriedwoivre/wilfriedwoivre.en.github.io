---
layout: post
title: Generate an Azure AD Token using the REST API
date: 2020-01-18
categories: [ "Azure", "Powershell", "Azure Active Directory" ]
---

Recently, I had to access to a storage account using an application account, so I set up a SPN which has an RBAC right on my storage account, as I show in this blog post: [http://blog.woivre.fr/blog/2018/09/connectez-vous-a-vos-comptes-de-stockage-via-azure-active-directory](http://blog.woivre.fr/blog/2018/09/connectez-vous-a-vos-comptes-de-stockage-via-azure-active-directory)

Now I need to generate my access token, thing that may be easy using ADAL libraries, however for my usecase I had the following constraints :
* Application account and a certificate authentication
* No additional libraries (Ciao ADAL)
* Powershell

First, we need to generate a JWT Token. As a reminder a JWT Token has the following syntax : **base64(header).base64(payload).base64(signature)**

Let's start by building our header. To achieve this, we need to get the hash of our certificate :

```powershell
$cert = Get-Item Cert:\CurrentUser\My\$ThumbprintValue

$hash = $cert.GetCertHash()
$hashValue = [System.Convert]::ToBase64String($hash)  -replace '\+','-' -replace '/','_' -replace '='
```

Now, it's possible to build our header and payload as following :

```powershell
[hashtable]$header = @{alg = 'RS256'; typ= "JWT"; x5t = $thumprintValue}
[hashtable]$payload = @{aud = "https://login.microsoftonline.com/$TenantUrl/oauth2/token"; iss = $applicationId; sub=$applicationId; jti = "22b3bb26-e046-42df-9c96-65dbd72c1c81"; exp = $exp; nbf= 1536160449}
```

Now that we have all the information, we need to generate our signature and construct the token :

```powershell
$headerjson = $header | ConvertTo-Json -Compress
$payloadjson = $payload | ConvertTo-Json -Compress

$headerjsonbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($headerjson)) -replace '\+','-' -replace '/','_' -replace '='
$payloadjsonbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($payloadjson)) -replace '\+','-' -replace '/','_' -replace '='

$jwt = $headerjsonbase64 + "." + $payloadjsonbase64
$toSign = [System.Text.Encoding]::UTF8.GetBytes($jwt)

$Signature = [Convert]::ToBase64String($rsa.SignData($toSign,[Security.Cryptography.HashAlgorithmName]::SHA256,[Security.Cryptography.RSASignaturePadding]::Pkcs1)) -replace '\+','-' -replace '/','_' -replace '='

$token = "$headerjsonbase64.$payloadjsonbase64.$Signature"
```

You can check that the creation the JWT Token on some sites such as : [https://jwt.io/](https://jwt.io/)

Here is it. We have the JWT Token which allows us to get the Access Token : 

```powershell

$url = "https://login.microsoftonline.com/$TenantUrl/oauth2/token"
$body = "resource=https%3A%2F%2F$storageAccountName.blob.core.windows.net%2F&client_id=$applicationId&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer&client_assertion=$token&grant_type=client_credentials"
$responseToken = Invoke-WebRequest -Method POST -ContentType "application/x-www-form-urlencoded"  -Headers @{"accept"="application/json"} -Body $body $url -Verbose

$accessToken = ($responseToken.Content | ConvertFrom-Json).access_token
```

After generating the token, it is possible to add it to the headers so we can call the storage account's REST API.

```powershell
$headerSMA =  @{"Authorization" = "Bearer " + $accessToken; "x-ms-version" = "2017-11-09"}
Invoke-WebRequest -Headers $headerSMA -Method GET "https://$storageAccountName.blob.core.windows.net/$containerName/$blobName"  -OutFile $outFile
```

That's how we request the Azure API without using the ADAL. even if it is more easier using ADAL and you have less things to know.