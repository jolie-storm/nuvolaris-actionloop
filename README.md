# nuvolaris-actionloop

This repository contains what is necessary to use Actions in Apache OpenwWhisk with Jolie inside Nuvolaris. 

### Setting up the Jolie environment 

To use the Jolie action language runtime it is needed to use the provided version of the Jolie source code, since it has added and modified functionality. The following functions are either added or modified: myReadLine, setEnv and getEnv. myReadline is found in the  Console Service, and setEnv + getEnv are found in the Runtime Service.

### Building and using the Jolie Action Language Runtime docker image
Before building the Jolie Action Language Runtime docker image it is needed to change the reference to the Jolie image in actionloop-demo-jolie-v1.11/jolie1.11/Dockerfile

```
FROM openwhisk/actionloop-v2:latest as builder

#Jolie docker
FROM <Jolie-image>

RUN mkdir -p /proxy/bin /proxy/lib /proxy/action
WORKDIR /proxy
COPY --from=builder bin/proxy /bin/proxy
```

Note that if you build a new runtime with docker in your local machine  you can use it to create an action with

```
nuv action create ... -docker <runtime-image>
```

but if you install nuvolaris with docker, nuvolaris will not see the image unless you publish it in a public repository (Dockerhub). 

You can work around this problem with the kind load command:
https://kind.sigs.k8s.io/docs/user/quick-start/#loading-an-image-into-your-cluster
you can invoke the kind embedded in nuv with

```
nuv kind load docker-image <runtime-image> --name=nuvolaris
```

Loading the image into the cluster has not been tested but should be possible. What was used in testing was uploading the image to a public repository so changing `-docker <runtime-image>` to `-docker docker.io/<your-image>`. 

It is possible to build the Jolie action language’s Dockerfile by using a
Makefile provided by the ActionLoop proxy, and also to push the image to a
public repository. Just edit the `docker.io/<username>` at `actionloop-demo-jolie-v1.11/jolie1.11/Makefile`:

```
IMG=actionloop-demo-jolie-v1.11:latest
INVOKE=python3 ../tools/invoke.py
PREFIX=docker.io/<username>
```

Then do
```
make push
```



## Apache OpenWhisk runtimes for Jolie
Creating Jolie action are similar to that of [other actions](https://github.com/apache/openwhisk/blob/master/docs/actions.md#the-basics).

As for now the service of an action has to be called ’Main’ but the operation, which in this case is called ’run’, can be named anything but it needs
to be specified using the --main flag.

When executing Jolie actions the --kind
flag pointing to the runtime has to be either loaded into Nuvolaris or using
--docker if it is published in a public repository

A simple `hello world` function would be:


```java
/*
For now.
Service has to be named: Main
Method can be named anything
*/

service Main {    

    inputPort mainIp {
        location: "local"
        RequestResponse: run(undefined)(undefined)
    }

    //Important to be able to handle several requests
    execution: concurrent

    main{

        run(request)(response){
            if(is_defined(request.name)){
                name = request.name
            }else{
                name = "Stranger"
            }
            greeting = "Hello " + name
            response.greeting << greeting    
        }

    }
}
```

Name this file `hello.ol` and an action can be created doing:

```
nuv wsk action create <action-name> <source-file> --main <main-operation-name> --docker docker.io/<runtime-image>
```

In this case creating the action would look as followed:

```
nuv wsk action create helloJolie hello.ol --main run --docker docker.io/<runtime-image>
```
```
ok: created action helloJolie
```

Invoking the action with the parameter `World!`:

```
nuv wsk action invoke helloJolie --result --param name World!
```
```
{
    "greeting": "Hello World!"
}
```

__NOTE:__ all parameters are can be passed from the CLI to the action using `--param <key> <value>`,  where key is the property name and value is any valid JSON value. The action can then access the params in the `request` i.e. `request.<param>`   

### Zip files
Jolie actions can also be packaged into ZIP files with other files. The source
file containing the entry point (the operation specified by --main) must have
the filename ’main.ol’ such that the compile script can find it. After creating the ZIP, it just needs to be added when making the action:

```
nuv wsk action create <action-name> <ZIP-file> --main <main-function-name> --docker docker.io/<runtime-image>
```


### Relative imports

To use relative imports a new file is created called `main.ol`. To pass several files to create an action they need to be in a ZIP file, and that is also the reason why the new file has the filename 'main.ol' since that is one of the requirements for [ZIP files](#zip-files). `main.ol` looks as follows:

```java
/*
For now.
Service has to be named: Main
Method can be named anything
*/

from .hello import Main as Main2

service Main {    

    embed Main2 as helloMain

    inputPort mainIp {
        location: "local"
        RequestResponse: run(undefined)(undefined)
    }

    //Important to be able to handle several requests
    execution: concurrent

    main{

        run(request)(response){
            run@helloMain(request)(responseImport)
            response << responseImport
        }

    }
}
```

It passes the request to 'hello.ol', shown [previously](#apache-openwhisk-runtimes-for-jolie), and sends the response from 'hello.ol' back to the invoker. To try and use this, first ZIP the sources and then update the 'helloJolie' action:

```
zip src.zip main.ol hello.ol
 adding: main.ol (deflated 48%)
 adding: hello.ol (deflated 51%)
```
```
nuv wsk action update helloJolie src.zip --main run --docker docker.io/<runtime-image>
```
```
ok: updated action helloJolie
```

Invoking the action now produces the exact same responses as before, since it is just the 'hello.ol' that eventually handles the request, but it shows that relative imports indeed does work, which is helpful to create more complex work.