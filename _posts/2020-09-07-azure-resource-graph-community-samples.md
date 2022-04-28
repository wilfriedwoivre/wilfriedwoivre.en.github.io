---
layout: post
title: Azure Resource Graph - Community samples
date: 2020-09-07
categories: [ "Azure", "Resource Graph" ]
comments_id: 13
---

In previous articles, I have shown you that Resource Graph Explorer is ultra powerful for querying your various Azure subscriptions.

Now it's always more convenient to have a few queries on hand, because rewriting everything each time wastes time.

Microsoft provides a few examples on their site : [Simple queries](https://docs.microsoft.com/en-us/azure/governance/resource-graph/samples/starter?tabs=azure-cli) and [Advanced queries](https://docs.microsoft.com/en-us/azure/governance/resource-graph/samples/advanced?tabs=azure-cli)

However, I prefer "functional" queries, i.e. the ones I use during my work, because listing all KeyVaults with the name of the subscription is not something I do every day.

Therefore I have created a Github repository [Azure Resource Graph Queries](https://github.com/wilfriedwoivre/azure-resource-graph-queries) on which I invite everyone who wants to contribute to add Azure Resource Graph queries. You'll find all the queries I've already put on my blogs.

To contribute, nothing could be simpler:

- Via a Github issue, you just have to create a Github issue with your Resource Graph query to add.
- Via a pull request by adding both your query and an explanatory readme.

The bonus, the ARM template part and the button to deploy it is added automatically for your request, as for the others.

And to finish, a small example of a request to find all your subnets that don't have a Route Table.

```yaml
resources
| where type == "microsoft.network/virtualnetworks"
| project vnetName = name, subnets = (properties.subnets)
| mvexpand subnets
| extend subnetName = (subnets.name)
| extend hasRouteTable = isnotnull(subnets.properties.routeTable)
| where hasRouteTable == 0
| project vnetName, subnetName
```
