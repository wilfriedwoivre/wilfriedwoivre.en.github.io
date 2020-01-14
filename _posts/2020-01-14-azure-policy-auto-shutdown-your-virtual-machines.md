---
layout: post
title: Azure Policy - Auto shutdown your virtual machines
date: 2020-01-14
categories: [ "Azure",  "Policy", "Virtual Machines" ]
---

Cloud Computing is delivered with multiple challenge, and the first one is Cost Management. It's mandatory to optimize your budget to not have any unpleasant surprise at the end of each month.
On Azure, you have some solutions to make your financial director happy like the following :

- Delete your unused resources... Delete after tests, no abandonned Azure Firewall or API management premium up and running
- Stop your VM all night for your dev/test environments ! Don't stop the prod, they have a business value !
- Set up autoscaling for your production environment.
- Make test environment with an auto delete daily routine. I made an Azure Function for that use case : [Azure Sandbox Utils](https://serverlesslibrary.net/sample/e677e615-a1d3-4c4a-80e3-3cedf5062554)

Back to the point to stop your Virtual Machines every night, except if there is your credit card beyond your account, you forget it 3 evening per week.
But, it's fully automatable with different possibilities:

- ***Auto-shutdown***: Available as built-in feature in Azure, on the blade of each VM, there are an option to configure AutoShutdown for your VM. You can configure shutdown hour, timezone, and you have the possibility to send an email before the shutdown.
  - **Advantage** : Possibility to configure each VM separatly, and define custom hour for each.
  - **Disadvantage** : Lot of work if you have 300 virtual machines. Not possible to restart virtual machine each morning.

- ***Azure Automation** : Azure Automation has a built in solution to manage your Virtual Machine. See [Azure Docs](https://docs.microsoft.com/en-us/azure/automation/automation-solution-vm-management)
  - **Advantage**: All of your VMs are configure to shutdown and start except if you have set any VM to exclude.
  - **Disadvantage**: Same hour for all of your Virtual Machine for each Azure Automation.

- ***Azure Automation & Tags***: It's possible to create a runbook to start and stop your VM with specific tags. You have some examples on Azure Automation Gallery.
  - **Advantage**: Each VM can have a specific and a unique tag. Script are managed by one Azure Automation. 
  - **Disadvantage**: Runbook to monitor and manage. More code, more bugs...

In my use case, i need to stop my VMs at a specific hour by VM, I start my VM only when i need them, because my calendar can change each day. So I only need a feature to stop my VMs. So i can use the first solution with built in auto shutdown configuration.

To avoid many click on Azure portal, I can use an ARM template to deploy auto shutdown resource:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "vmName": {
            "type": "string"
        },
        "location": {
            "type": "string"
        },
        "status": {
            "type": "string",
            "allowedValues": [
                "Enabled",
                "Disabled"
            ]
        },
        "shutdownHour": {
            "type": "string"
        },
        "timeZone": {
            "type": "string"
        }
    },
    "variables": {
        "shutdownHour": "[replace(parameters('shutdownHour'), ':', '')]"
    },
    "resources": [
        {
            "type": "Microsoft.DevTestLab/schedules",
            "apiVersion": "2016-05-15",
            "name": "[concat('shutdown-computevm-', parameters('vmName'))]",
            "location": "[parameters('location')]",
            "properties": {
                "status": "[parameters('status')]",
                "taskType": "ComputeVmShutdownTask",
                "dailyRecurrence": {
                    "time": "[variables('shutdownHour')]"
                },
                "timeZoneId": "[parameters('timeZone')]",
                "notificationSettings": {
                    "status": "Disabled",
                    "timeInMinutes": 30
                },
                "targetResourceId": "[resourceId('Microsoft.Compute/virtualMachines', parameters('vmName'))]"
            }
        }
    ],
    "outputs": {
        "policy": {
            "type": "string",
            "value": "[concat('Autoshutdown configured for VM', parameters('vmName'))]"
        }
    }
}
```

However, I create multiple VM each day with Terraform, ARM or Azure Portal, so I need to reminder each time to add the autoshutdown resource.

It's possible to make this resource for each VM from an Azure Policy with an effect **deployIfNotExists**

To send parameters to my ARM Template, I make a choice to use tags on my VMs, and use them as parameters like that :

```json
{
  "mode": "Indexed",
  "policyRule": {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Compute/virtualMachines"
        },
        {
          "field": "[concat('tags[', parameters('tagAutoShutdownEnabled'), ']')]",
          "exists": "true"
        },
        {
          "field": "[concat('tags[', parameters('tagAutoShutdownHour'), ']')]",
          "exists": "true"
        },
        {
          "field": "[concat('tags[', parameters('tagAutoShutdownTimeZone'), ']')]",
          "exists": "true"
        }
      ]
    },
    "then": {
      "effect": "deployIfNotExists",
      "details": {
        "type": "Microsoft.DevTestLab/schedules",
        "name": "[concat('shutdown-computevm-', field('name'))]",
        "existenceCondition": {
          "allOf": [
            {
              "field": "tags.AutoShutdown-Enabled",
              "equals": "[field('tags.AutoShutdown-Enabled')]"
            },
            {
              "field": "tags.AutoShutdown-Hour",
              "equals": "[field('tags.AutoShutdown-Hour')]"
            },
            {
              "field": "tags.AutoShutdown-TimeZone",
              "equals": "[field('tags.AutoShutdown-TimeZone')]"
            }
          ]
        },
        "roleDefinitionIds": [
          "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
        ],
        "deployment": {
          "properties": {
            "mode": "incremental",
            "template": {
              "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
              "contentVersion": "1.0.0.0",
              "parameters": {
                "vmName": {
                  "type": "string"
                },
                "location": {
                  "type": "string"
                },
                "status": {
                  "type": "string",
                  "allowedValues": [
                    "Enabled",
                    "Disabled"
                  ]
                },
                "shutdownHour": {
                  "type": "string"
                },
                "timeZone": {
                  "type": "string"
                }
              },
              "variables": {
                "shutdownHour": "[replace(parameters('shutdownHour'), ':', '')]"
              },
              "resources": [
                {
                  "type": "Microsoft.DevTestLab/schedules",
                  "apiVersion": "2016-05-15",
                  "name": "[concat('shutdown-computevm-', parameters('vmName'))]",
                  "location": "[parameters('location')]",
                  "tags": {
                    "AutoShutdown-Enabled": "[parameters('status')]",
                    "AutoShutdown-TimeZone": "[parameters('timeZone')]",
                    "AutoShutdown-Hour": "[parameters('shutdownHour')]"
                  },
                  "properties": {
                    "status": "[parameters('status')]",
                    "taskType": "ComputeVmShutdownTask",
                    "dailyRecurrence": {
                      "time": "[variables('shutdownHour')]"
                    },
                    "timeZoneId": "[parameters('timeZone')]",
                    "notificationSettings": {
                      "status": "Disabled",
                      "timeInMinutes": 30
                    },
                    "targetResourceId": "[resourceId('Microsoft.Compute/virtualMachines', parameters('vmName'))]"
                  }
                }
              ],
              "outputs": {
                "policy": {
                  "type": "string",
                  "value": "[concat('Autoshutdown configured for VM', parameters('vmName'))]"
                }
              }
            },
            "parameters": {
              "vmName": {
                "value": "[field('name')]"
              },
              "location": {
                "value": "[field('location')]"
              },
              "status": {
                "value": "[field('tags.AutoShutdown-Enabled')]"
              },
              "shutdownHour": {
                "value": "[field('tags.AutoShutdown-Hour')]"
              },
              "timeZone": {
                "value": "[field('tags.AutoShutdown-TimeZone')]"
              }
            }
          }
        }
      }
    }
  },
  "parameters": {
    "tagAutoShutdownEnabled": {
      "type": "String",
      "metadata": {
        "displayName": "Tag Name",
        "description": null
      },
      "defaultValue": "AutoShutdown-Enabled"
    },
    "tagAutoShutdownTimeZone": {
      "type": "String",
      "metadata": {
        "displayName": "Tag Name",
        "description": null
      },
      "defaultValue": "AutoShutdown-TimeZone"
    },
    "tagAutoShutdownHour": {
      "type": "String",
      "metadata": {
        "displayName": "Tag Name",
        "description": null
      },
      "defaultValue": "AutoShutdown-Hour"
    }
  }
}
```

You can use this gist to simplify copy paste : [Azure Policy Auto Shutdown](https://gist.github.com/wilfriedwoivre/8fc8040bbc655bd247de68e12e99f0e2)

If you have alreaduy use an Azure Policy with **deployIfNotExists**, you must know that this policy apply only if Azure assess it's necessary.
To validate, if the policy must be applied, Azure use properties **type** and **name** from your policy

```json
"effect": "deployIfNotExists",
"details": {
    "type": "Microsoft.DevTestLab/schedules",
    "name": "[concat('shutdown-computevm-', field('name'))]",
```

And after, Azure use property **existenceCondition**, where i use the same constraints as my policy rule. From Azure Policy, i can't read properties on DevTestLab object, so i use tags on my autoshutdown resource, and i compare them to tags on my Virtual Machine

```json
"existenceCondition": {
    "allOf": [
    {
        "field": "tags.AutoShutdown-Enabled",
        "equals": "[field('tags.AutoShutdown-Enabled')]"
    },
    {
        "field": "tags.AutoShutdown-Hour",
        "equals": "[field('tags.AutoShutdown-Hour')]"
    },
    {
        "field": "tags.AutoShutdown-TimeZone",
        "equals": "[field('tags.AutoShutdown-TimeZone')]"
    }
    ]
},
```

And it's done. I have a global policy on my subscription with a job to stop VM with my custom rules. And i can update these rules for each VM, only with a tag update.
