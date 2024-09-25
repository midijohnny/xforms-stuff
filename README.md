# README

The following are example [Xforms] apps.

The majority of these can be viewed directly online:


- https://midijohnny.github.io/xforms-stuff/maker.xml
- https://midijohnny.github.io/xforms-stuff/predictor.xml
- https://midijohnny.github.io/xforms-stuff/mqtt.xml
- https://midijohnny.github.io/xforms-stuff/w3x.xml
- https://midijohnny.github.io/xforms-stuff/portal.xml
- https://midijohnny.github.io/xforms-stuff/resize.xml


## Using Browser Local Storage to save app-state.

The demo app XForms app [portal.xml] uses some XSLT-Forms-specific features (namely 'serialize' function and 'xf:setnode' tag)
and some javascript to allow it to save/load from the browser's localStorage. 

So when the user selects a theme, changes the state of the sidebar or selects which sections to show
This state can be restored (automatically on startup, or manually from menu option)
This App also loads a copy of its own source code (note, assuming the name is 'portal.xml'!)
Doing this allows us to calculate a checksum (SHA1) of the App Source itself, if the checksum of the current app
does not match the cached version of the data - then the cached element is discarded.

Loading the app itself allows us to examine the structure of the app as well, and this is presented on the app itself

The App was built using W3.CSS, Google's Material Symbols/Icons and XSLTForms 1.7.

![][local_storage_demo]

## XML-RPC integration with 'aria2'.

The file [aria2.xml] (a work in progress, still a number of issues to be resolved) is a single page app that communicates requests using [XML-RPC].
The main motivation for building this demo was to provide a way of downloading XML resources that XForms (actually XMLHTTPRequest) is unable to access due to [CORS] restrictions.
The example here takes an [OPML] (outline file, used frequently as a [linkbase] of Podcast [RSS] feeds, and then uses 'aria2' to fetch the XML).



### Notes:

## ISSUE 

The logic needs fixing : when an item is first selected, it doesn't correctly load and refresh the page - switching between another button and back again will work around the issue.
The problem happens when no locally cached RSS feeds are available - that is - on the first run.

## Running aria2

In order for this app to work at all, 'aria2' must be running on the localhost - and must be allowed to write to the location where the XForms app is served-from.
Like this:

```
#!/bin/bash
# run_aria2.sh
export TOKEN=supersecret
export DIR=./rsscache
aria2c \
	--enable-rpc=true \
	--rpc-secret="${TOKEN}" \
	--rpc-allow-origin-all \
	--dir ${DIR} \
	--log=/dev/stdout \
	--log-level=debug \
	--on-download-complete=./hook.sh
```

The 'hook.sh' is optional here and can be ommitted - it could be used to run validation against the downloaded file for instance.

Keep in the mind the security-implications of running this server that has access to the web-root of your web-server.
Also - it seems that aria2 can write to any location - on a request-by-request basis (rather than having a 'base' directory) - although this is constrained by operating system
permissions of course - but be careful when specifying the 'dir' parameters.

To run this whole thing more safely - probably best to run in a container such as docker.

The way this is setup (and the logic needs some work at the time of writing):

- The URL (which is restricted to just the RSS feed at this point, but could be expanded to include the cover-art and MP3s themselves) is used to form a checksum.
  This checksum is then used to provide aria2 with a unique 'GID' - this lets aria2 uniquely identify a particular download.
  Here we are using it to provide a way to label the downloaded file, and it in effect acts as a cache-identifier.
- Once the RSS XML is downloaded, XForms makes a second submission to retrieve the information and replace an XForms instance - 'podcast' - which represents the currently loaded 
podcast.
- The indvidual episodes of the selected podcast are presented to the user in an xforms:repeat - and an audio element is used to allow the user to play (pause etc) the selected episode.

[W3 CSS] was used to style everything - it works pretty well, but I have some issues (not with W3 CSS itself - the way I'm using it), getting it to render on an iPhone.

Screenshots - shows the sidebar , different styles (w3 css), aria2 calls and with sidebar collapsed in play mode.

![][aria1]
![][aria2]
![][aria3]
![][aria4]


## Using W3 CSS with XForms.

### Editable Avatar List

The file [w3x.xml] is a single page app that uses [w3 css] to style a simple XForm-based demonstration.
The example is based on the [w3css list example].

There is no (explicit) Javascript used in this example, and although some minor CSS tweaks were needed, for the most part everything just fits together nicely.

Screenshots, showing the list of employees, a edit dialog for a single employee and a demonstration of the sidebar being shown.

![][list_details]
![][edit_details]
![][sidebar]

The theme can be changed by editing the following entry:

```
 <link rel="stylesheet" href="https://www.w3schools.com/lib/w3-theme-blue-grey.css"/>
```

Change the 'w3-theme-xxxx' to one of the others listed on the [w3css colour themes] page.

## UPDATE:

In fact we can make it so the theme is dynamically selected from a list of theme names, using an AVT on the ```link``` element itself.
I had to move the ```link``` element from ```head``` to the ```body``` for this to work:

```
<body class="w3-theme-dark">
	<link rel="stylesheet" href="https://www.w3schools.com/lib/{instance('app')/theme}"/>
[...]
```

Now the theme will change instantly in response to changes in the XForms model. (See the 'app' instance).

![][change_theme]

### Resizing content when sidebar expanded/collapsed.

The file [resize.xml] is a modified example from the W3 CSS site - [Slide the Page Content to the Right] - but instead of Javascript modifying the style,
we use XForms binds to keep a set of CSS properties to be set in response to the ```sidebar/@state``` being changed.

![][resize]


## Updated notes for MQTT.XML:

I recently discovered that [XSLTForms] has had a number of [XForms 2.0] features back-ported to it.
In particular - Attribute Value Templates - commonly known as [AVT] - can be used to simplify how controls etc are presented conditionally.
Also: it provides for modal dialogs - using the [xf:dialog] element - this feature provides an excellent way of de-cluttering the main screen.

So using these techniques, the UI now hopefully is a bit cleaner and simpler.

Additionally: moved the 'client' instance data into an external file - to unclutter the source code somewhat.


## AVTS

These can be used (for instance) to dynamically add CSS class identifiers to elements.

For instance: to make a button appear greyed-out.

First define a CSS rule, for instance:

``` {.xml}
<style type="text/css">
        <![CDATA[

	.disabled_control { color: grey }

	[...other styles...]

	/]]>
</style>
```

On the button(trigger) which you wish to disable - add logic to an AVT on the child label of the trigger.
Using the [if] function is useful here:

```{.xml}
<xf:trigger id="t_do_disconnect">
	<xf:label class="{if(@connected=false(),'disabled_control','')}">DISCONNECT</xf:label>
	<xf:hint>Disconnect from MQTT Broker</xf:hint>
	<xf:action ev:event="DOMActivate" if="@connected=true()">
		<xf:dispatch targetid="mqtt_model" name="mqtt-do-disconnect"/>
	</xf:action>
</xf:trigger>
```

Note: The control over whether the button is active or not - needs be done on the action element itself using the [if attribute].
The two mechanisms are totally different - but complementary.

# Modal Dialogs

These can be shown or hidden using the xf:show and xf:hide actions respectively.
The background form is automatically disabled when the modal is shown (and it visibly altered to make this more obvious).

Using a modal dialog allowed us to move the connection details out of the way, but they can be brought up by clicking the connected/disconnected button in the top-right of the UI now.

Note: The modals don't come with any 'close' methods by default - you must include another trigger which performs an xf:hide action.
I opted to add the action to the modal itself - using a bit of CSS and an 'X' character to generate a reasonable 'close' icon:

``` {.xml}
<xf:dialog id="connection">
	<xf:group ref="connection">
		<xf:trigger style="float: right">
			<xf:label>X</xf:label>
			<xf:action ev:event="DOMActivate">
				<xf:hide dialog="connection"/>
			</xf:action>
		</xf:trigger>
[...]
```

![][s1]
![][s2]
![][s3]






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

[s1]: img/s1_disconnected.png
[s2]: img/s2_modal.png
[s3]: img/s3_connected.png

[AVT]: https://www.w3.org/community/xformsusers/wiki/XForms_2.0#Attribute_Value_Templates
[xf:dialog]: https://www.w3.org/MarkUp/Forms/wiki/The_XForms_Dialog_Module
[if]: https://www.w3.org/TR/xforms/#fn-if
[if attribute]: https://www.w3.org/TR/xforms/#action-conditional
[XForms 2.0]: https://www.w3.org/community/xformsusers/wiki/XForms_2.0

[w3x.xml]: w3x.xml
[list_details]: img/list_details.png
[edit_details]: img/edit_details.png
[sidebar]:      img/sidebar.png
[change_theme]: img/change_theme.png
[w3 css]: https://www.w3schools.com/w3css/
[w3css list example]: https://www.w3schools.com/w3css/w3css_lists.asp
[w3css colour themes]: https://www.w3schools.com/w3css/w3css_color_themes.asp
[Slide the Page Content to the Right]: https://www.w3schools.com/w3css/tryit.asp?filename=tryw3css_sidebar_shift
[resize]: img/resize.png

[aria1]: img/aria1.png
[aria2]: img/aria2.png
[aria3]: img/aria3.png
[aria4]: img/aria4.png
[local_storage_demo]: img/local_storage_demo.png
