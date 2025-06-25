(function (xhr) {
  console.log("哈哈哈哈 1");
  var XHR = XMLHttpRequest.prototype;

  var open = XHR.open;
  var send = XHR.send;
  var setRequestHeader = XHR.setRequestHeader;

  XHR.open = function (method, url) {
    console.log("哈哈哈哈 2");
    this._method = method;
    this._url = url;
    this._requestHeaders = {};
    this._startTime = new Date().toISOString();

    return open.apply(this, arguments);
  };

  XHR.setRequestHeader = function (header, value) {
    console.log("哈哈哈哈 3");
    this._requestHeaders[header] = value;
    return setRequestHeader.apply(this, arguments);
  };

  XHR.send = function (postData) {
    console.log("哈哈哈哈 4");
    this.addEventListener("load", function () {
      console.log("哈哈哈哈 5");
      var endTime = new Date().toISOString();

      var myUrl = this._url ? this._url.toLowerCase() : this._url;
      if (myUrl) {
        if (postData) {
          if (typeof postData === "string") {
            try {
              // here you get the REQUEST HEADERS, in JSON format, so you can also use JSON.parse
              this._requestHeaders = postData;
            } catch (err) {
              console.log(
                "Request Header JSON decode failed, transfer_encoding field could be base64"
              );
              console.log(err);
            }
          } else if (
            typeof postData === "object" ||
            typeof postData === "array" ||
            typeof postData === "number" ||
            typeof postData === "boolean"
          ) {
            // do something if you need
          }
        }

        // here you get the RESPONSE HEADERS
        var responseHeaders = this.getAllResponseHeaders();

        if (this.responseType != "blob" && this.responseText) {
          // responseText is string or null
          try {
            // here you get RESPONSE TEXT (BODY), in JSON format, so you can use JSON.parse
            var arr = this.responseText;

            // printing url, request headers, response headers, response body, to console

            console.log(this._url);
            console.log(JSON.parse(this._requestHeaders));
            console.log(responseHeaders);
            console.log(JSON.parse(arr));
          } catch (err) {
            console.log("Error in responseType try catch");
            console.log(err);
          }
        }
      }
    });

    return send.apply(this, arguments);
  };
  console.log("哈哈哈哈 6");
})(XMLHttpRequest);
