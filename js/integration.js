/*
	JS functions to talk to Paho library and XForms.
	Where possible communication is done via events; which XForms has 'xf:action' set up.
	Where it is necessary to update the XForms model, we only update a 'buffer' instance.
	XForms app will copy information from this buffer to the main instance.

	See 'mqtt.xml' also - there is a block of javascript register various event listeners.
	
*/

// Don't call 'write_log' from here - will loop !
function dispatch_event(event_str) {
	console.debug("Dispatch Event", event_str);
	XsltForms_xmlevents.dispatch(mqtt_model, event_str);
	}
	
function notify_xforms(mqtt_model) {
	mqtt_model.rebuild();
	mqtt_model.recalculate();
	mqtt_model.revalidate();
	mqtt_model.refresh();
}

function get_mqtt_model() {
	return document.querySelector('#mqtt_model');
}

function write_log(note, topic='', payload='') {
	console.log('write_log');
	var mqtt_model=get_mqtt_model();
	var sharedinst=mqtt_model.getInstanceDocument('shared');
	var logentry=sharedinst.querySelector("logentry");
	logentry.setAttribute('note',note);
	logentry.setAttribute('topic',topic);
	logentry.setAttribute('payload',payload);
	dispatch_event('mqtt-do-write-log');
	notify_xforms(mqtt_model); // We should be calling this, but doesn't seem neccesary?
}

function do_connect() {
	console.log('do_connect');
	var mqtt_model=get_mqtt_model();
	var inst=mqtt_model.getInstanceDocument();
	var connection=inst.querySelector('connection');
	var hostname=connection.getAttribute('hostname');
	var port=Number(connection.getAttribute('port'));
	var clientID=connection.getAttribute('clientID');

	client = new Paho.Client(hostname, port, clientID);
	client.onConnectionLost = onConnectionLost;
	client.onMessageArrived = onMessageArrived;
	client.connect( {onSuccess:onConnect} );
	write_log(`Connecting to '${hostname}:${port}' with clientID '${clientID}'`);
}


function do_disconnect() {
	console.log('do_disconnect');
	write_log('mqtt-do-disconnect');
	client.disconnect();
	dispatch_event("mqtt-connection-lost");
}

function do_send() {
	console.debug('do_send');
	var mqtt_model=get_mqtt_model();
	var inst=mqtt_model.getInstanceDocument();
	var message=inst.querySelector('message');
	var topic=message.getAttribute('topic');
	var payload=message.getAttribute('payload');
	console.debug(`Topic: ${topic}. Payload ${payload}`);
	var msg = new Paho.Message(payload);
		msg.destinationName = topic;
		client.send(msg);
	dispatch_event("mqtt-message-sent");
}

function onConnect() {
	console.debug("onConnect");
	dispatch_event("mqtt-connect");
};

function onConnectionLost(responseObject) {
	if (responseObject.errorCode !== 0) {
		console.debug("onConnectionLost:"+responseObject.errorMessage);
		write_log('mqtt-connection-lost');
		dispatch_event("mqtt-connection-lost");
	}
};

function do_subscribe() {
	console.debug('do_subscribe');
	var mqtt_model=get_mqtt_model();
	var inst=mqtt_model.getInstanceDocument();
	var topics=inst.querySelectorAll('sub');
	for (var i=0;i<topics.length;i++) {
		var topic=topics[i].getAttribute('topic');
		console.debug("Subscribing to: ",topic);
		write_log('mqtt-subscribe', topic);
		dispatch_event('mqtt-subscribe');
		client.subscribe(topic);
	}

}

function onMessageArrived(msg) {
		console.debug(`onMessageArrived: ${msg.topic}, ${msg.payloadString}`);
		write_log('mqtt-message-received', msg.topic, msg.payloadString);
};

