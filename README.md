# visionOSXPC

Demonstrate two apps from different developer teams communicating with each other using NSXPC.

This project uses FileProvider and `NSFileProviderService` to create a register for `NSXPCListenerEndpoint`, allowing apps from different developer teams to communicate with each other over NSXPC APIs without requiring every app to implement their own file providers.

The project only uses public APIs available to the developer, so if app review is not too opinionated about what a file provider should do, maybe someone can actually submit a file provider app to host this register and allow apps to freely communicate with each other. (I'm kinda curious what's the expected use case for `NSFileProviderService` back when the file provider team introduced this API... if you know, feel free to email me 😆)

I guess technically you can also use socket once you involves a file but NSXPC is just more fun 😛

## How the demo works?

`XPCExchange` contains the example file provider hosting the register for `NSXPCListenerEndpoint`s, and the main app part exposes an XPC service to process text input.

`OtherApp` is configured under a separate developer team, and uses the register to get the `NSXPCListenerEndpoint` exposed by the XPCExchange app, and establish the NSXPCConnection so it can call the text service directly.

For each app, to perform the initial setup, you select the `Connect` option, and that opens the file picker. From there, navigate to the `XPCExchange` and select `Endpoints` file so we have the URL we can call to get the `NSFileProviderService`.

