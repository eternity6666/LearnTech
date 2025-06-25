function httpRequest(stickerID, headers = {}) {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    const url =
      "/cgi-bin/mmemoticon-bin/BindRedPacketCover?f=json&stickerid=" +
      stickerID +
      "&cover_url=https:%2F%2Fsupport.weixin.qq.com%2Fcgi-bin%2Fmmsupport-bin%2Fshowredpacket%3Fpurchase_token%3DNPC_fTlZVt3WMTC%26is_sell%3D1&req_type=1";

    xhr.open("GET", url, true); // 第三个参数 true 表示异步

    // 设置请求头
    for (const [key, value] of Object.entries(headers)) {
      xhr.setRequestHeader(key, value);
    }

    xhr.onload = function () {
      if (xhr.status >= 200 && xhr.status < 300) {
        resolve({
          status: xhr.status,
          data: xhr.responseText,
        });
      } else {
        reject({
          status: xhr.status,
          statusText: xhr.statusText,
        });
      }
    };

    xhr.onerror = function () {
      reject({
        status: xhr.status,
        statusText: "网络请求失败",
      });
    };

    xhr.ontimeout = function () {
      reject({
        status: 408,
        statusText: "请求超时",
      });
    };

    xhr.send();
  });
}

function trySendUpdateRedCover(response) {
  const KEY = "trySendUpdateRedCover";
  function isIn(stickerID) {
    return (localStorage.getItem(KEY) ?? "").split(",").includes(stickerID);
  }
  function putIn(stickerID) {
    var list = (localStorage.getItem(KEY) ?? "").split(",");
    list.push(stickerID);
    localStorage.setItem(KEY, list);
  }
  const json = JSON.parse(response);
  if (json && json.List) {
    const list = json.List;
    list.forEach((stickerItem) => {
      const { StikerID, Status, TotalDownloadNum, TotalSendNum, Name } =
        stickerItem;
      if (Status === 7) {
        if (!isIn(StikerID)) {
          const requestLog = `request: ${Name} ${StikerID} download=${TotalDownloadNum} send=${TotalSendNum}`;
          console.log(requestLog);
          httpRequest(StikerID)
            .then((response) => {
              if (response.data === '{"base_resp":{"ret":0,"err_msg":"ok"}}') {
                if (!isIn(StikerID)) {
                  putIn(StikerID);
                }
              }
            })
            .catch((error) => {
              console.log(StikerID, error);
            });
        }
      }
    });
  }
}

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
    // console.log("load inject start:", myUrl);
    // console.log("originArguments:", arguments[0]);
    // console.log("originArguments dataType: ", typeof arguments[0]);
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
        // console.log("responseHeaders:", responseHeaders);

        if (this.responseType != "blob" && this.responseText) {
          // responseText is string or null
          try {
            if (
              myUrl.includes("/cgi-bin/mmemoticon-bin/home?lang=zh_cn&f=json")
            ) {
              trySendUpdateRedCover(this.responseText);
            }
            // here you get RESPONSE TEXT (BODY), in JSON format, so you can use JSON.parse
            // printing url, request headers, response headers, response body, to console
            // console.log("originResponseText:", this.responseText);
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
