---
title: frida hook
author: Payne
tags:
  - frida
categories:
  - - frida
    - hook
abbrlink: 3591261126
date: 2022-06-18 21:17:21
---

## frida启动方式

```bash
# frida -h
usage: frida [options] target

positional arguments:
  args                  extra arguments and/or target

optional arguments:
  -h, --help            show this help message and exit
  -D ID, --device ID    connect to device with the given ID
  -U, --usb             connect to USB device
  -R, --remote          connect to remote frida-server
  -H HOST, --host HOST  connect to remote frida-server on HOST
  --certificate CERTIFICATE
                        speak TLS with HOST, expecting CERTIFICATE
  --origin ORIGIN       connect to remote server with “Origin” header set to ORIGIN
  --token TOKEN         authenticate with HOST using TOKEN
  --keepalive-interval INTERVAL
                        set keepalive interval in seconds, or 0 to disable (defaults to -1 to auto-select based on transport)
  --p2p                 establish a peer-to-peer connection with target
  --stun-server ADDRESS
                        set STUN server ADDRESS to use with --p2p
  --relay address,username,password,turn-{udp,tcp,tls}
                        add relay to use with --p2p
  -f TARGET, --file TARGET
                        spawn FILE
  -F, --attach-frontmost
                        attach to frontmost application
  -n NAME, --attach-name NAME
                        attach to NAME
  -p PID, --attach-pid PID
                        attach to PID
  -W PATTERN, --await PATTERN
                        await spawn matching PATTERN
  --stdio {inherit,pipe}
                        stdio behavior when spawning (defaults to “inherit”)
  --aux option          set aux option when spawning, such as “uid=(int)42” (supported types are: string, bool, int)
  --realm {native,emulated}
                        realm to attach in
  --runtime {qjs,v8}    script runtime to use
  --debug               enable the Node.js compatible script debugger
  --squelch-crash       if enabled, will not dump crash report to console
  -O FILE, --options-file FILE
                        text file containing additional command line options
  --version             show program's version number and exit
  -l SCRIPT, --load SCRIPT
                        load SCRIPT
  -P PARAMETERS_JSON, --parameters PARAMETERS_JSON
                        parameters as JSON, same as Gadget
  -C USER_CMODULE, --cmodule USER_CMODULE
                        load CMODULE
  --toolchain {any,internal,external}
                        CModule toolchain to use when compiling from source code
  -c CODESHARE_URI, --codeshare CODESHARE_URI
                        load CODESHARE_URI
  -e CODE, --eval CODE  evaluate CODE
  -q                    quiet mode (no prompt) and quit after -l and -e
  -t TIMEOUT, --timeout TIMEOUT
                        seconds to wait before terminating in quiet mode
  --no-pause            automatically start main thread after startup
  -o LOGFILE, --output LOGFILE
                        output to log file
  --eternalize          eternalize the script before exit
  --exit-on-error       exit with code 1 after encountering any exception in the SCRIPT
  --auto-perform        wrap entered code with Java.perform
  --auto-reload         Enable auto reload of provided scripts and c module (on by default, will be required in the future)
  --no-auto-reload      Disable auto reload of provided scripts and c module
```

## Injection

> attach hook app运行中的
>
> spawn 重启app hook，适合hook app 启动时

### Shell

#### attach

```bash
frida -U -p pid -l script_hook.js
frida -U -n name -l script_hook.js
```

#### spawn

```bash
frida -U -f TARGET -l script_hook.js --no-pause
```

### Python script

```python
import sys
import frida
from loguru import logger
from pptrint import pprint



def message_callback(message, data):
  logger.info(f"[*] {message}")

  
device = frida.get_use_device(-1)

# attach
process = device.attach('className')
script = process.create_script('hook_script')
script.on('message', message_callback)
script.load()
sys.stdin.read()

# spawn
device = frida.get_use_device(-1)
pid = devices.spawn(['packageName'])
process = device.attach(pid)
script = process.create_script('hook_script')
script.on('message', message_callback)
script.load()
sys.stdin.read()
```



## Hook

```js
Java.perfrom(() => {
	console.log('start hook...');
	// hook script
});
```



### Hook 类方法

```js
Java.perfrom(() => {
	console.log('start hook...');
	// hook class script
  let class_name = Java.use('com.xxx.xxx.class_name');
	class_name.method.implementation = func() {
     // do something
     // this.xx
  }
});
```

### Hook 内部方法

```js
Java.perfrom(() => {
	console.log('start hook...');
	// hook class script
  // 类路径$内部类名
  let class_name = Java.use('com.xxx.xxx.class_name$xx');
	class_name.method.implementation = func() {
     // do something
     // this.xx
  }
});
```

待续...
