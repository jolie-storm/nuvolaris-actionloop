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

IMG=actionloop-demo-jolie-v1.11:latest
INVOKE=python3 ../tools/invoke.py
PREFIX=docker.io/<docker username>

build:
	docker build -t $(IMG) .

push: build
	docker login
	docker tag $(IMG) $(PREFIX)/$(IMG)
	docker push $(PREFIX)/$(IMG)

clean:
	docker rmi -f $(IMG)

start: build
	docker run -p 8080:8080 -ti -v $(PWD):/proxy $(IMG)

debug: build
	docker run -p 8080:8080 -ti --entrypoint=/bin/sh -v $(PWD):/proxy $(IMG)

.PHONY: build push clean start debug

## You need to execute make start in another terminal
test-single:
	$(INVOKE) init run ../example/hello.ol
	$(INVOKE) run '{}'
	$(INVOKE) run '{"name":"Mike"}'

test-src-zip:
	$(MAKE) -C ../example src.zip
	$(INVOKE) init run ../example/src.zip
	$(INVOKE) run '{}'
	$(INVOKE) run '{"name":"Mike"}'

test-bin-zip:
	$(MAKE) -C ../example bin.zip
	$(INVOKE) init run ../example/bin.zip
	$(INVOKE) run '{}'
	$(INVOKE) run '{"name":"Mike"}'
