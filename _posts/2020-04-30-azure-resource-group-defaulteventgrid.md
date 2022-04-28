---
layout: post
title: Azure - Resource Group DEFAULT-EVENTGRID
date: 2020-04-30
categories: [ "Azure", "Event Grid"  ]
comments_id: 12
---

If, like me, you logged into your Azure portal this morning, you may have seen a new resource group called **DEFAULT-EVENTGRID** located in West US 2 (at least for me).

As the name suggests, there is a connection with Event Grid ....

Let's take a look at its content now, a priori there is nothing, unless you activate the hidden resources, you will see a resource of this type *microsoft.eventgrid/systemtopics*

The name of the resource is a simple concatenation of 2 GUIDs.

Now, if you have localization constraints for your resource groups, or if you like everything to be tidy in its place, it's possible to create your event grid subscription from an ARM template rather than portal.

Here is an ARM template which creates a topic on updating subscription resources, and which sends the messages to a storage queue.

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "eventSubName": {
      "type": "string",
      "defaultValue": "subToResources",
      "metadata": {
        "description": "The name of the event subscription to create."
      }
    },
    "eventGridTopicName": {
      "type": "string"
    },
    "storageName": {
      "type": "string"
    }
  },
  "resources": [
    {
      "name": "[parameters('eventGridTopicName')]",
      "type": "Microsoft.EventGrid/systemTopics",
      "location": "global",
      "apiVersion": "2020-04-01-preview",
      "properties": {
        "source": "[subscription().id]",
        "topicType": "microsoft.resources.subscriptions"
      }
    },
    {
      "type": "Microsoft.EventGrid/systemTopics/eventSubscriptions",
      "name": "[concat(parameters('eventGridTopicName'), '/', parameters('eventSubName'))]",
      "apiVersion": "2020-04-01-preview",
      "dependsOn": [
        "[parameters('eventGridTopicName')]"
      ],
      "properties": {
        "destination": {
          "endpointType": "StorageQueue",
          "properties": {
            "queueName": "eventgridqueue",
            "resourceId": "[resourceId('Microsoft.Storage/storageAccounts', parameters('storageName'))]"
          }
        }
      }
    }
  ]
}
```

And voila, I was able to delete this resource group located in West US 2.
