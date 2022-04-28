---
layout: post
title: Pulumi - Store your state in Azure Storage
date: 2020-02-26
categories: [ "Azure", "Pulumi" ]
comments_id: 9
---

The Cloud is no longer a platform for personal projects, the industrialization of its use has become nearly mandatory.

There are several ways to automate your Cloud environment:

- Use the tools provided by the publisher: ARM for Azure or Cloud Formation for AWS
- Go through third-party tools like Terraform, or Pulumi.

Pulumi is different from Terraform in that they have chosen to use existing technologies like C # or Python rather than like Terraform which has its own development language HCL.

However between Pulumi and Terraform, we see similarities, and the first concerns the presence of a state.
By default Terraform offers a state based on a local file, while Pulumi offers a state hosted on their SAAS platform, as we can see below:

![]({{ site.url }}/images/2020/03/02/pulumi-store-your-state-in-azure-storage-img1.png)
(source : [https://www.pulumi.com/docs/intro/concepts/state/](https://www.pulumi.com/docs/intro/concepts/state/))

We will see how to set up our *state* in Azure Blob Storage Azure.
For this we need an Azure storage account and a container, all via az cli as below:

```bash
RESOURCE_GROUP_NAME="pulumi-demo-blog"
STORAGE_ACCOUNT_NAME="pulumidemo"
STORAGE_CONTAINER_NAME="pulumi-state"
az storage account create -n $STORAGE_ACCOUNT_NAME -g $RESOURCE_GROUP_NAME -l westeurope --sku Standard_LRS --https-only --kind StorageV2

CONNECTION_STRING=$(az storage account show-connection-string -n $stoName -g $rgName -o tsv)  

az storage container create -n $STORAGE_CONTAINER_NAME --connection-string $CONNECTION_STRING
```

Before starting any creation of stack through pulumi, the CLI asks you to create a **state**, you have several choices which are to date the following :

- Pulumi SAAS
- Local
- Azure Blob
- AWS S3

For our case, we will use Azure Blob through a SAS Key, the pulumi documentation indicates that we must perform this operation to use our newly created storage account :

```bash
pulumi login --cloud-url azblob://pulumi-state
```

If we naively execute this command on a new console, we have this output :

```bash
error: problem logging in: unable to open bucket azblob://pulumi-state: azureblob.OpenBucket: accountName is required
```

By digging a little the documentation and the various articles of blog, we see that it is necessary to indicate in variable of environment the following information :

- AZURE_STORAGE_ACCOUNT: For the name of your storage account
- AZURE_STORAGE_KEY: For the key to your storage account
- AZURE_STORAGE_SAS_TOKEN: If you prefer SAS Key

You can find this information on the SDK Go documentation for Azure:
[https://pkg.go.dev/gocloud.dev/blob/azureblob?tab=doc](https://pkg.go.dev/gocloud.dev/blob/azureblob?tab=doc)

We will therefore generate our SAS Key, then add our 2 environment variables that interests us, that is to say **AZURE_STORAGE_ACCOUNT** and **AZURE_STORAGE_SAS_TOKEN**

```bash
end=`date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'`
az storage account generate-sas --permissions cdlruwap --account-name $STORAGE_ACCOUNT_NAME --services b --resource-types sco --expiry $end -o tsv
```

And now, it is possible to relaunch our login.

And then it is possible to create our pulumi stack, as for example via the following command :

```bash
pulumi new azure-python
```

And voila, you have the possibility of using pulumi with a Backend at your home and more on the SAAS in Pulumi.
