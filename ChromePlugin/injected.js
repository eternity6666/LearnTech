(function (xhr) {
  var XHR = xhr.prototype;
  var open = XHR.open;
  var send = XHR.send;
  var setRequestHeader = XHR.setRequestHeader;

  XHR.open = function (method, url) {
    this._method = method;
    this._url = url;
    this._requestHeaders = {};
    this._startTime = new Date().toISOString();

    return open.apply(this, arguments);
  };

  XHR.setRequestHeader = function (header, value) {
    this._requestHeaders[header] = value;
    return setRequestHeader.apply(this, arguments);
  };

  function newPostDataIfNeed(postData) {
    try {
      jsonData = JSON.parse(postData);
      jsonData["rewardInfo"] = {
        agreement: true,
        word: "你若喜欢 给个赞吧",
      };
      jsonData["downloadArea"] = ["DEF"];
      jsonData["isFree"] = false;
      jsonData["stickerStyle"] = ["文字内容", "文字内容"];
      jsonData["character"] = ["日常"];
      jsonData["topic"] = "万能通用";
      jsonData["copyright"] = "YZH";
      jsonData["isStatic"] = true;
      jsonData["styleType"] = 1;
      myLocation = "香港";
      jsonData["name"] = myLocation + "的风";
      jsonData["description"] = "想你的风吹到了" + myLocation;
      console.log("new jsonData: ", jsonData);
      return JSON.stringify(jsonData);
    } catch (err) {
      console.log("newPostDataIfNeed error", err);
    }
    return postData;
  }

  XHR.send = function (postData) {
    var myUrl = this._url ? this._url.toLowerCase() : this._url;
    console.log("load inject start:", myUrl);
    console.log("originArguments:", arguments[0]);
    console.log("originArguments dataType: ", typeof arguments[0]);
    if (
      myUrl &&
      myUrl.includes(
        "/cgi-bin/mmemoticonwebnode-bin/api/sticker/album/updatestickerdraft"
      )
    ) {
      const newArguments = newPostDataIfNeed(arguments[0], myUrl);
      arguments[0] = newArguments;
      console.log("newArguments:", newArguments);
    }

    this.addEventListener("load", function () {
      if (myUrl) {
        // here you get the RESPONSE HEADERS
        var responseHeaders = this.getAllResponseHeaders();
        console.log("responseHeaders:", responseHeaders);

        if (this.responseType != "blob" && this.responseText) {
          // responseText is string or null
          try {
            // here you get RESPONSE TEXT (BODY), in JSON format, so you can use JSON.parse
            // printing url, request headers, response headers, response body, to console
            console.log("originResponseText:", this.responseText);
            // https://sticker.weixin.qq.com/cgi-bin/mmemoticon-bin/stikerpage
          } catch (err) {
            console.log("Error in responseType try catch", err);
          }
        }
      }
    });
    return send.apply(this, arguments);
  };
})(XMLHttpRequest);
