# Minecraft (Java) Server

This is a dockerized version of the Minecraft (Java) Server for easy usage on Linux, MacOs or Windows.


**Please note: This server setup is only compatible with Minecraft: Java Edition.**


## Build the server

Build the default version
```bash
make build
```

Build a specific version
```bash
make build SERVER_VERSION=1.14.4
```


## Start the server

Start normally
```bash
# Note, you must explicitly accept the EULA via the below shown argument
make run ACCEPT_EULA=true
```

Adjust the listening port
```bash
make run ACCEPT_EULA=true PORT=64000
```

Adjust Java XMX memory settings
```bash
make run ACCEPT_EULA=true JAVA_XMX=1024M
```


## Further reading

https://www.minecraft.net/en-us/download/server/
