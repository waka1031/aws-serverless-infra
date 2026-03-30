var ALLOWED_IPS = ${allowed_ips};
function handler(event) {
  if (ALLOWED_IPS.indexOf(event.viewer.ip) === -1) {
    return {
      statusCode: 403,
      statusDescription: 'Forbidden',
    };
  }
  return event.request;
}
