# Get all items from a large SharePoint List (Custom HTTP Endpoint)

---

Microsoft Graph is the backbone of Power Automate these days, but sometimes the connectors do not show us the full scope of the API. When that happens, you don't necessarily need to abandon Power Automate, just use the HTTPS connector instead! You'll have full access to the Graph API while keeping the benefits of the low-code and Microsoft-connected environment.

One of my biggest pet peeves is that the SharePoint List connectors have built in limiters and will not return large responses. I understand that Power Automate does this because currently it is not built to handle them, however business requirements and budget limits require some ingenuity. There have been a handful of times recently, when I've had to create and interact with large SharePoint lists. The standard SharePoint List connector has a limit of 200 items and my lists were 500 - 1,000 items, sometimes more. I had to come up with a way to get all the items using PowerAutomate.

## Trigger

This flow that I designed uses a HTTP Request trigger, but you can use whatever trigger you want. I chose that trigger so I can access this flow from other Power Automate flows as well as other external programs. I used a sample payload to generate the schema for this endpoint. It takes in a Site ID of the SharePoint site containing the list and the ID of the list itself. This information can be obtained from the relevant Graph API endpoints and won't change during the lifetime of the site or list.


![HTTP Trigger](images\01.png)

## Getting Graph OAuth Token

Although you are in the Power Automate environment, you'll still need to get an authentication token if you want to send calls via the HTTPS connector. I prefer to do this right at the beginning of your flow at the same time I'm setting up all my variables. It starts with an HTTPS block that will make the call for the authentication token.

The information in the block is all straight out of the [Microsoft Graph documentation for this endpoint.](https://docs.microsoft.com/en-us/graph/auth-v2-service)

```
URL: https://login.microsoftonline.com/<tenant_id>/oauth2/v2.0/token

Headers:
	Host: login.microsoftonline.com
	Content-Type: application/x-www-form-urlencoded

Body:
	client_id=<client_it>
	&scope=https://graph.microsoft.com/.default
	&client_secret=<client_secret>
	&grant_type=client_credentials
```

Originally, I placed a Parse Json block after this call to get the token. Once parsed, the token would appear as an option in the Dynamic <find name> menu. After working with Power Automate more, I've become more familiar with how to access information that exists, but doesn't appear in that menu. Now I can simply have an Initialize Variable block to save the token.

Here's the code that gets the token from the response:

```
body('Get_Auth_Token')?['access_token']
```

I include the keyword "Bearer" in the variable so I don't have to remember to add it to each call. Also, makes the blocks look a bit cleaner with only a variable name in the field.

![Get Authentication Token](images\02.png)

## Initializing Loop Variables

When you send a request to a Graph API endpoint and the results are larger than it can include in its response, it will include a URL called the "nextLink" that has a skip token embedded. If you send a request using that URL, the endpoint will see the token, skip the results you have already received, and send a new batch. Depending on how many total results there are, you may have to repeat this process numerous times to get everything. In Power Automate, sending the request is the easiest part. Figuring out how to save the results all to the same variable is a bit trickier. This is probably my 3rd or 4th version of the loop, slimmed down to almost the fewest blocks possible.

First, you'll need the Array variable that will hold the results of all your requests. Second, you need a String variable that will hold the request URLs and also control the loop. The initialization value is the first request URL you'll send.

![Initialize Loop Variables](images\03.png)

We don't know how many times the loop will need to run, but we do know that the last response will not include a nexLink URL. Power Automate and Strings can be a bit strange so I tested out some different options for the right hand side of the loop control equation. Surprisingly, leaving it completely blank is the easiest and most reliable solution.

![Loop Control Statement](images\04.png)

## Now for the Loop!

The first step in the loop is the HTTPS block that sends the request to the Graph API. Since this example is only used GET requests, the setup is fairly straightforward. Remember to click "Advanced Options" so you can enter the Authentication information!

```
Method: GET
URL: <url variable>
Authentication: Raw
Value: <authToken variable>
```

![Get list items](images\05.png)

Next, we use a Parse Json block to read the response. This step is not strictly needed as you can still access the response information the same way I did with the OAuth token, but it makes configuring the next blocks easier. Make sure you choose the Body of the previous block, not the Value, because we want to parse the entire response. Responses from the Graph API wrap the results within a Value property to separate them from other metadata in the response, like the nextLink URL, like this:

```json
{
  "@odata.nextLink": "https://...",
  "value":
	[
    {"name": "myfile.jpg", "size": 2048, "file": {} },
    {"name": "Documents", "folder": { "childCount": 4} },
    {"name": "Photos", "folder": { "childCount": 203} },
    {"name": "my sheet(1).xlsx", "size": 197 }
  ]
}
```

![Parse response of list items](images\06.png)

(Usually, you will only need the results of the call so you would use Value instead of the Body. This is one of the few exceptions since we need that Next Link value.)

When first building a flow, I use the Generate from Sample button to create a starting schema, and then modify it to fit my needs, especially when I have large responses with many properties. This is what the Parse JSON schema looks like after I've edited it and removed the fields I don't need. 

```json
{
    "type": "object",
    "properties": {
        "@@odata.nextLink": {
            "type": "string"
        },
        "value": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "fields": {
                        "type": "object"
                    }
                },
                "required": [
                    "fields"
                ]
            }
        }
    }
}
```

For this flow specifically, I removed most of the schema, leaving only the `fields` and the `@@odata.nextLink` properties. Those are the only items I'll be using in my flow so there's not much reason to parse the other data. Since this is a generic flow to be used with any list, we also don't want to specify the names of the sub-properties within the `fields` property. The `@@odata.nextLink` property is not required so the automation doesn't throw an error when it reaches the end of the list and there is no Next Link to follow.

This is what the unedited generated schema would look like:

```json
{
    "type": "object",
    "properties": {
        "@@odata.context": {
            "type": "string"
        },
        "@@odata.nextLink": {
            "type": "string"
        },
        "value": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "@@odata.etag": {
                        "type": "string"
                    },
                    "createdDateTime": {
                        "type": "string"
                    },
                    "eTag": {
                        "type": "string"
                    },
                    "id": {
                        "type": "string"
                    },
                    "lastModifiedDateTime": {
                        "type": "string"
                    },
                    "webUrl": {
                        "type": "string"
                    },
                    "createdBy": {
                        "type": "object",
                        "properties": {
                            "user": {
                                "type": "object",
                                "properties": {
                                    "email": {
                                        "type": "string"
                                    },
                                    "id": {
                                        "type": "string"
                                    },
                                    "displayName": {
                                        "type": "string"
                                    }
                                }
                            }
                        }
                    },
                    "lastModifiedBy": {
                        "type": "object",
                        "properties": {
                            "user": {
                                "type": "object",
                                "properties": {
                                    "email": {
                                        "type": "string"
                                    },
                                    "id": {
                                        "type": "string"
                                    },
                                    "displayName": {
                                        "type": "string"
                                    }
                                }
                            }
                        }
                    },
                    "parentReference": {
                        "type": "object",
                        "properties": {
                            "siteId": {
                                "type": "string"
                            }
                        }
                    },
                    "contentType": {
                        "type": "object",
                        "properties": {
                            "id": {
                                "type": "string"
                            },
                            "name": {
                                "type": "string"
                            }
                        }
                    },
                    "fields@odata.context": {
                        "type": "string"
                    },
                    "fields": {
                        "type": "object",
                        "properties": {
                            "@@odata.etag": {
                                "type": "string"
                            },
                            "Title": {
                                "type": "string"
                            },
                            "LinkTitleNoMenu": {
                                "type": "string"
                            },
                            "LinkTitle": {
                                "type": "string"
                            },
                            "id": {
                                "type": "string"
                            },
                            "ContentType": {
                                "type": "string"
                            },
                            "Modified": {
                                "type": "string"
                            },
                            "Created": {
                                "type": "string"
                            },
                            "AuthorLookupId": {
                                "type": "string"
                            },
                            "EditorLookupId": {
                                "type": "string"
                            },
                            "_UIVersionString": {
                                "type": "string"
                            },
                            "Attachments": {
                                "type": "boolean"
                            },
                            "Edit": {
                                "type": "string"
                            },
                            "ItemChildCount": {
                                "type": "string"
                            },
                            "FolderChildCount": {
                                "type": "string"
                            },
                            "_ComplianceFlags": {
                                "type": "string"
                            },
                            "_ComplianceTag": {
                                "type": "string"
                            },
                            "_ComplianceTagWrittenTime": {
                                "type": "string"
                            },
                            "_ComplianceTagUserId": {
                                "type": "string"
                            }
                        }
                    }
                },
                "required": [
                    "@@odata.etag",
                    "createdDateTime",
                    "eTag",
                    "id",
                    "lastModifiedDateTime",
                    "webUrl",
                    "createdBy",
                    "lastModifiedBy",
                    "parentReference",
                    "contentType",
                    "fields@odata.context",
                    "fields"
                ]
            }
        }
    }
}
```

After that, the loop is almost completed, with only three short actions to complete.

![Complete Loop by Saving List Items](images\07.png)

The first one is a Compose block with the following expression in it:

```jsx
union(variables('listItems'), body('Parse_response')?['value'])
```

This expressions combines the two lists and outputs them as a new combined array, which we then save to the listItems variable with a Set Variable block.

Last but not least, we extract the Next Link URL, if one came with the response, and save it to the `url` variable that is controlling the loop. If no Next Link came with the response, `url` just becomes null and will therefore end the loop.

Once the loop has completed, the full list of items is returned as a response to the original request that triggered this flow.

![Return all List Items](images\08.png)

### Limitation

This automation works very well for short lists with less than 1k - 2k items total. It is able to compile the list within the standard timeout limit for most API calls. Once you get above 2k items or so, this flow will still return all the items, but it will take longer and could exceed the timeout limit. You can change that limit manually in some cases, but there is another way to accommodate larger lists that I will post and article on in the future.

### Conclusion

Power Automate is a great tool for all sorts of automations, but sometimes we need to get a bit creative when business requirements exceed the built-in limits of this tool. When I approach a new automation project, I usually start with PowerAutomate and then move up to more flexible tools if needed.

Here is the whole flow from start to finish. I hope you this demo will help you with your automation projects and inspire you to discover more interesting ways Power Automate can be used.

![Complete Flow](images\09.png)