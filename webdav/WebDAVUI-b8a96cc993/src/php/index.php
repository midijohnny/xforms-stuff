<?php
	use Sabre\DAV;
	require 'vendor/autoload.php';

if (
    parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) === '/' &&
    in_array($_SERVER['REQUEST_METHOD'], ['GET', 'HEAD'], true)
) {
    header('Location: /main.html', true, 302);
    exit;
}


	$rootDirectory = new DAV\FS\Directory('public');
	$server = new DAV\Server($rootDirectory);
	$server->setBaseUri('/');
	$lockBackend = new DAV\Locks\Backend\File('data/locks');
	$lockPlugin = new DAV\Locks\Plugin($lockBackend);
	$server->addPlugin($lockPlugin);

	# $server->addPlugin(new DAV\Browser\Plugin());

	$contentType = new DAV\Browser\GuessContentType();
	$contentType->extensionMap += [
		'css'   => 'text/css',
        'js'    => 'text/javascript',
        'json'  => 'text/json',
		'svg'   => 'image/svg+xml',
    	'htm'   => 'text/html',
    	'html'  => 'text/html',
    	'xml'   => 'text/plain',
    	'xsl'   => 'text/plain',
    	'xhtml' => 'text/plain',
		'php'   => 'text/plain', # For demo: allow user to view php inline.
		'sh'    => 'text/plain'  # Ditto.
	];
	$server->addPlugin($contentType);

	$server->exec();
