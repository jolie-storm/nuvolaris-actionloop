#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
FROM openwhisk/actionloop-v2:latest as builder

#Jolie docker
FROM <Jolie-image>

RUN mkdir -p /proxy/bin /proxy/lib /proxy/action
WORKDIR /proxy
COPY --from=builder bin/proxy /bin/proxy

#Launcher and compile
ADD lib/launcher.ol /proxy/lib/launcher.ol
ADD bin/compile /proxy/bin/compile

#Since the compile script is in python
# RUN apk update && apk add python3

RUN apt-get update
RUN apt-get install -y python3

#Set home variables
ENV JAVA_HOME=/opt/java/openjdk    
ENV PATH="${JAVA_HOME}/bin:${PATH}"

ENV JOLIE_HOME=/usr/lib/jolie
RUN export JOLIE_HOME

ENV OW_COMPILER=/proxy/bin/compile
ENTRYPOINT ["/bin/proxy"]

