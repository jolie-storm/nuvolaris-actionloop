from runtime import Runtime 
from file import File
from console import Console
from json_utils import JsonUtils
from string_utils import StringUtils

//Import users action
from .main__ import Main

service Launcher {    

    embed Runtime as runtime
    embed File as file
    embed Console as console
    embed JsonUtils as JsonUtils
    embed StringUtils as StringUtils

    //Embed user action
    embed Main as Main

    init{
        looping = true
    }

    main{
        scope( launcherScope ){
            //error handling
            install( 
                default => errorResponse.error << launcherScope.default
                getJsonString@JsonUtils(errorResponse)(errorResponseJson)
                writeFile@file({filename = "/dev/fd/3" content=errorResponseJson + "\n" append = 1} )()
            )

            while(looping){ 

                myReadLine@console("in")(line)

                if(line == void){
                    looping = false
                }else{
                    getJsonValue@JsonUtils( line )( args )
                    payload = {}
                
                    foreach(key : args){
                        if(key == "value"){
                            payload << args.value
                        } else{
                            toUpperCase@StringUtils(key)(upperKey)
                            setenv@runtime({ key= "__OW_" + upperKey  value=args.(key)})()
                        }
                    }

                    //invoke action with payload
                    run@Main(payload)(response)

                    getJsonString@JsonUtils(response)(responseJson)

                    //write to fd3
                    writeFile@file({filename = "/dev/fd/3" content=responseJson + "\n" append = 1} )()
                }
            }
        }
    }
}
