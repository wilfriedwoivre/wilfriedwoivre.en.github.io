---
layout: post
title: Bicep - Use the local mode
date: 2025-08-06
categories: [ "Azure", "Bicep" ]
comments_id: 56 
---

It can be frustrating to always have to trigger a Bicep deployment to Azure while you are still writing your script. And of course you don't want to run your deployment after blindly building your Landing Zone after 1 week of hard work. (or 2 hours if you use AVM.)

Fortunately, Bicep offers a "local" mode that allows you to validate your Bicep code without deploying to Azure. This can be particularly useful for checking syntax, resource types, and dependencies between resources.

However, be aware that this does not take everything into account, since you are not actually deploying the resources.

It can nevertheless be very useful when you want to quickly check syntax, or when you are working on custom functions that can be complex.

To do this, you need to edit your Bicep configuration file: bicepconfig.json

```json
{
   "experimentalFeaturesEnabled": {
    "localDeploy": true
  }
}
```

And then you can edit your bicep file with the targetscope set to local:

```bicep
targetScope = 'local'


var test = 'Hello, Bicep!'


output greeting string = test

```

And frankly, this is quite practical when you work on somewhat complex functions or when you can calculate locally (and while mobile without an internet connection)