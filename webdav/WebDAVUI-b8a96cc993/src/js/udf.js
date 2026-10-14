function parentDir(url) {
    const parent=url.replace(/[^/]+\/$/, ''); 
	return parent;
}

function baseName(url) {
	const basename = url === '/' ? '/' : url.split('/').filter(Boolean).pop();
	return basename;
}
