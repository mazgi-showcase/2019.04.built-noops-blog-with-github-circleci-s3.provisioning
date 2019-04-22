'use strict';
exports.handler = (event, context, callback) => {
  const request = event.Records[0].cf.request;
  const originalUri = request.uri;
  const replacedUri = originalUri.replace(/\/$/, '/index.html');

  //console.log('Request URI: ' + originalUri + ' => ' + replacedUri);

  request.uri = replacedUri;
  return callback(null, request);
}
