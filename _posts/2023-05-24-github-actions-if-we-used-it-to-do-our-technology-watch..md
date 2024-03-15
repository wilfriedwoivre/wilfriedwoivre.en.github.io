---
layout: post
title: Github Actions - If we used it to do our technology watch
date: 2023-05-24
categories: [ "Divers", "Github Actions" ]
comments_id: 36 
---

Nowadays doing its technology watch can be complicated, there are lots of information sources, blogs, sites, social networks, newsletters, podcasts, videos, etc. And you have to sort it out, find the relevant information, read it, understand it, analyze it, etc. And it all takes time, a lot of time.

And if in addition you want to share your watch on Twitter or any other social network, it will take you even more time.

What if we automated all this?

So yes, my goal is to share on Twitter the articles I read, however I do not want to share all the articles of the RSS feeds that I am.

For that I had made a first version thanks to Azure. This was based on serverless components such as Azure Functions, Azure Logic Apps, and an Azure Table Storage to store the information I needed.

The workflow was as follows:

- **Azure Functions** : Daily, a function is triggered and will read all the RSS feeds that I am, and which will store the new items in an Azure Table Storage.
- **Azure Logic Apps** : Every morning, I receive an email with all the articles, and for each a link to *publish* or *ignore* the article.
- **Azure Function** : Regularly during the week, I publish an article on Twitter among those I wish. Of course the oldest first.
- **Azure Function**: Every week, a purge of old items is carried out so as not to spend money for nothing.

This solution was very good, however it had a cost, and I could not share it to everyone without the prerequisite to have an Azure account.

So I decided to use Github Action to do the same thing, and share the code on GitHub.

 You can find it [here](https://github.com/wilfriedwoivre/feedly)

The workflow is as follows :

- **Github Actions** : An action daily is triggered and will read all the RSS feeds that I am, and which will store new items in a CSV file. And for each article I will create an issue on my repository.
- **Github Actions** : Every morning, I look at the open issues and tag them to publish them during the week.
- **Github Actions** : Regularly during the week, I publish an article on Twitter among those I wish. Of course the oldest first.

To achieve all of this, I created a certain number of custom actions in Python. Let's start with the most important, the construction of the matrix to read all my RSS feeds without changing the definition of my workflows.

Here is the definition in my workflow:

```yaml
    - name: matrix-builder
      id: matrix-builder
      uses: ./.github/actions/build-matrix
```

And how I build my matrix in Python:

```python
    matrixOutput =  "matrix={\"include\":["
    
    for item in sources:
        if (to_bool(item.isActive)):
            matrixOutput += "{\"FeedName\":\""+item.siteName+"\", \"FeedLink\":\""+item.link+"\", \"FeedType\":\""+item.type+"\", \"Prefix\":\""+item.prefix+"\", \"Suffix\":\""+item.suffix+"\"},"

    matrixOutput = matrixOutput[:-1]
    matrixOutput += "]}"
    
    with open(os.environ["GITHUB_OUTPUT"], "a") as output:
        output.write(f"{matrixOutput}\n")
```

After I can use it at my will in my workflow side that

```yaml
  read-rss:
    needs:
      - generate-matrix
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      max-parallel: 1
      matrix: ${{ fromJson(needs.generate-matrix.outputs.matrix) }}

    steps:
    - uses: actions/checkout@v3

    - name: read-rss
      id: read-rss
      uses: ./.github/actions/readrss
      env:
        FeedName: ${{ matrix.FeedName }}
        FeedLink: ${{ matrix.FeedLink }}
        FeedType: ${{ matrix.FeedType }}
        AutoPublish: ${{ matrix.AutoPublish }}
        FeedPrefix: ${{ matrix.Prefix }}
        FeedSuffix: ${{ matrix.Suffix }}
        GithubRepository: ${{ github.repository }}
        GithubToken: ${{ secrets.GITHUB_TOKEN }}
```

And here is the result in my workflow:

![image]({{ site.url }}/images/2023/05/24/github-actions-if-we-used-it-to-do-our-technology-watch-img0.png "image")

And this is how I used a tool such as GitHub Action to be able to do my technological watch and share it on Twitter, and also share with you how I do this.
