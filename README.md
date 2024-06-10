# README

The following are example [Xforms] apps.

## TensorFlow JS Integration.

The file [predictor.xml] is a single page [Xforms] based web app to provide a simple test client for [Tensorflow.js].
The app has four client-side dependencies:

- [XSLTForms] to provide the [XForms] engine
- [Tensorflow.js] libraries
- Google's [Material Symbols and Icons] fonts.
- A pre-trainined model - [MobileNet] : this can be swapped out for a reference to alternative models.

See section below entitled 'Getting dependencies' for downloading and deploying [XSLTForms].

The [Tensorflow.js] library allows you to load and run AI Models directly in the browser.
This example uses a pre-trained [MobileNet] image classifier model.
These libraries are avaiable directly from a [CDN] - so nothing needs to be explicitly installed.

Provide an input image, and the model will tell you ('infer') what the image depicts.

The [Xforms] app has an instance called 'images' which contains a list of images and their attribution.
The corresponding images were downloaded from the [Creative Commons] library.
To add more images, download to the 'images' subdirectory and add corresponding entries to the file 'images.xml'.

Copy the main file 'predictor.xml' and subdirectory 'images' to a folder:

```
-> predictor.xml
  -- images/images.xml
  -- images/*.jpg (etc)
```

Start a webserver to serve the files, any webserver will do, for instance:

```
$ # Any of the following will work
$ python -m http.server 8080  # or...
$ php -S 0.0.0.0:8080 # or ...
$ althttpd # etc etc 
```

Point your browser to http://localhost:8080/predictor.xml
You can select images to preview by clicking on the table.
Click the button to load the TensorFlow model - it will take a few seconds to load.
Once loaded - the button will change to a 'robot' icon - select an image and click to run an inference on the selected image.

![][screenshot_tensorflow1]

## XForms app to Create XForms.

The file [maker.xml] is a single page [Xforms] based web app to provide a simple proof-of-concept - that it is possible to
create [XForms] components, using [Xforms] itself.

The example here lets you create a [select1] fragment - you can add/update/delete values/items.
The resultant XML is shown in 'raw' form as you edit, and you can download the XML fragment once done.

![][screenshot_maker]

## MQTT Integration

The file [mqtt.xml] is a single page [XForms] based web app to provide a simple test client for [MQTT] over [Websockets].
The app has three client-side dependencies:

- [XSLTForms] to provide the [XForms] engine
- [Paho] Javascript library to connect to [MQTT] server.
- Google's [Material Symbols and Icons] fonts.

It also requires an MQTT broker with Websocket support.
I used [Mosquitto].

## Use public test MQTT server.

You can use public internet-facing MQTT test brokers, for [HiveMQ] or [EMQX].
Remember when testing with public endpoint that your data isn't private.
Just edit the [mqtt.xml] (or just fill in the form directly of course) with the connection details.

At the time of writing :

```
hostname: broker.hivemq.com
port:8000
```

```
hostname: broker.emqx.io
port:8083
```

You can use [Mosquitto_Sub] / [Mosquitto_Pub] commands (see below) for testing with this.

## Tip:

You can send messages between different browser tabs - but use a different ```clientID``` for each.
The broker will disconnect any existing client that has the same ```clientID```.

## Setup for Mosquitto

There is no support for authentication - so the broker must configured to allow anonymous access.
Mosquitto can deliver the app via HTTP if the option ```http_dir``` is setup.
Alternatively - you can run a separate web-server (it doesn't matter which) to deliver the app.

Here's an example of the configuration settings:

```
[...]
allow_anonymous true

# Regular TCP socket
listener 1883

listener 9001
protocol websockets

http_dir /home/joebloggs/www 
[...]
```

The 'http_dir' can be anything you want - that's where the files go.

On my Ubuntu system the configuration filepath is ```/etc/mosquitto/mosquitto.conf``` and requires root access to edit.
After changing the configuration the broker needs to be restarted:

``` {.bash}
$ sudo systemctl restart mosquitto.service
```

### Testing Mosquitto Setup

To test the broker you can use the commands:

- [Mosquitto_Sub]
- [Mosquitto_Pub]

For instance to subscribe to a topic "test" using the Mosquitto server on the local machine:

``` {.bash}
$ mosquitto_sub -h localhost -t 'test'
```

The command will loop until you CTRL-C it.

To publish a text message to the topic:

``` {.bash}
$ mosquitto_sub -h localhost -t 'test' -m "hello world"
```

Note: the commands use the default 1883 port, rather than the 9001 Websocket.

### Testing the app

Point your browser at your webserver.
If you are using Mosquitto itself, then the URL will be as follows:

```
http://localhost:9001/mqtt.xml
```

You should see something like this:

![][screenshot1]

By default the app will autoconnect, you can change this behaviour by editing the XForms instance 'mqtt' - contained within the HTML file, change ```autoconnect``` to 'false'.

``` {.xml}
	<xf:instance id="mqtt">
		<client xmlns="">

			<connection
				connected="false"
				hostname="localhost"
				port="9001"
				clientID="browser"
				autoconnect="true"
			/>

			<pub topic="camera/take_picture"/>
			<pub topic="topic1"/>
			<pub topic="topic2"/>
			<pub topic="topic3"/>
			<pub topic="topic4"/>
			<pub topic="echo"/>

			<sub topic="camera/image_received"/>
			<sub topic="topic6"/>
			<sub topic="echo"/>

			<log/>
	
			<message
				topic=""
				payload="hello world"
				comment="Outgoing message"/>
		</client>
	</xf:instance>
```

See the 'binds' as well - in particular know that the ```connection/@connected``` flag is automatically set to ```true``` when connected, and ```false``` when not.
So - the UI can automatically react to changes to this flag.

Try this:

- Connect into Mosquitto with the browser.
- Shutdown Mosquitto:

``` {.bash}
$ sudo systemctl stop mosquitto.service
```

XForms realizes immediately that the connection is lost - and will magically de-activate the 'send message' form and re-activate the login form.

![][screenshot2]


### Side note.

There seem to be multiple versions of the [Paho] libraries out there; some refer to the 'Paho.MQTT.Client' and others just 'Paho.Client'.
I'm using the latter - since I had some issues understanding how to retrieve the payload from the [PahoCDN] version (which requires 'Paho.MQTT.Client').

[XSLTForms] is available from a number of places as well - the version I'm using reports to be 1.7.
And I choose this particular download location (github) because I could automatically download - and it seems to be the latest version publically available.

You can also find it on [SourceForge].

### Troubleshooting.

If you find that the 'CONNECT' button isn't doing anything - or that 'autoconnect' is failing - bring up developer tools in your browser.
There are additional 'console.debug' log statements that might help.
Use the mosquitto_sub / mosquitto_pub commands to verify whether MQTT is working.
Check the websockets port is listening, use 'netstat' for instance:

``` {.bash}
$ netstat -an | grep LISTEN | grep -v 9001 | grep -v grep
```

You should see something like:

```
tcp6       0      0 :::9001                 :::*                    LISTEN  
```

## Getting dependencies.

For what its worth - there is a simple [Makefile] to download the [XSLTForms] and [Paho] libraries.
So you can just run 'make' from the project directory to fetch these.

``` {.bash}
$ make
```

Output should be something like:

```
git clone https://github.com/AlainCouthures/declarative4all.git
Cloning into 'declarative4all'...
remote: Enumerating objects: 8166, done.
remote: Counting objects: 100% (1568/1568), done.
remote: Compressing objects: 100% (719/719), done.
remote: Total 8166 (delta 1040), reused 1138 (delta 835), pack-reused 6598
Receiving objects: 100% (8166/8166), 13.89 MiB | 8.31 MiB/s, done.
Resolving deltas: 100% (5694/5694), done.
mkdir -p js
curl https://raw.githubusercontent.com/eclipse/paho.mqtt.javascript/master/src/paho-mqtt.js --output js/paho-mqtt.js --location
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 90293  100 90293    0     0   266k      0 --:--:-- --:--:-- --:--:--  266k
```



### Useful links:

A couple of useful resources for XForms and MQTT :

- [Xforms: A Tutorial]
- [Beginners Guide To The MQTT Protocol]

### Final notes:

There is no ability to edit the subscription or publication list from the UI - this is all read from the config file.
However: since this is based on XForms, this should be relatively straigtforward to implement: remembering that we need to tell the MQTT client about any changes.
(Or just allowing editing when the client is already disconnected might be simpler to implement).

The events like "mqtt-connect" are scattered all over the source file; it might be useful to have them all defined within an XForms instance.
The [Paho] library lists out explicit error codes - such as "AMQJSC0000I OK.", "AMQJSC0001E" - it would be good to expose these to the XForms instances as well.

There is no limit of the number of logging entries that will get written - this could be a problem if the browser is left unattended and is receiving messages.
It would be nice if the number of log self-managed itself - to automatically clear our entries when the 'buffer' goes over a certain limit. (and/or throw away old messages).

The app only sends and receives text messages: this is missing a trick. 
It could send and recieved XML messages - received messages could then update XForms model automatically.
Perhaps having a map of custom, app-specific events - based on the MQTT topics would be more useful.

[mqtt.xml]:								mqtt.xml
[Makefile]:								Makefile
[XForms]:								https://www.w3.org/TR/xforms
[XSLTForms]:    						http://www.agencexml.com/xsltforms
[HiveMQ]:								https://www.hivemq.com/mqtt/public-mqtt-broker/
[EMQX]:									https://www.emqx.com/en/mqtt/public-mqtt5-broker
[MQTT]:   								https://en.wikipedia.org/wiki/MQTT
[Websockets]:							https://en.wikipedia.org/wiki/WebSocket
[Paho]:   								https://eclipse.dev/paho/index.php?page=clients/js/index.php
[Mosquitto]:							https://mosquitto.org/
[Mosquitto_Sub]:						https://mosquitto.org/man/mosquitto_sub-1.html
[Mosquitto_Pub]:						https://mosquitto.org/man/mosquitto_pub-1.html
[PahoCDN]:									https://cdnjs.cloudflare.com/ajax/libs/paho-mqtt/1.0.1/mqttws31.js
[XForms: A Tutorial]:					https://homepages.cwi.nl/~steven/xforms11-for-html-authors/
[Beginners Guide To The MQTT Protocol]:	http://www.steves-internet-guide.com/mqtt/
[SourceForge]:							https://sourceforge.net/projects/xsltforms/

[screenshot1]: img/screenshot1.png
[screenshot2]: img/screenshot2.png

[select1]: https://en.wikibooks.org/wiki/XForms/Select1
[maker.xml]: maker.xml

[screenshot_maker]: img/maker.png

[TensorFlow.js]: https://www.tensorflow.org/js
[CDN]: https://en.wikipedia.org/wiki/Content_delivery_network
[Material Symbols and Icons]: https://fonts.google.com/icons
[MobileNet]: https://keras.io/api/applications/mobilenet/
[Creative Commons]: https://creativecommons.org/
[predictor.xml]: predictor.xml


[screenshot_tensorflow1]: img/jstensorflow.png
