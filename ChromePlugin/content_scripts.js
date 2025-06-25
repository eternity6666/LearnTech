var s = document.createElement('script');
// must be listed in web_accessible_resources in manifest.json
s.src = chrome.runtime.getURL('injected.js');
s.onload = function() {
    this.remove();
};
(document.head || document.documentElement).appendChild(s);

// 页面加载完成后的初始化
document.addEventListener("DOMContentLoaded", () => {
  console.log("微信表情表单助手 content script 已加载");
});

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === "callFillForm") {
    console.log("收到 Popup 的消息:", request.data);
    var inputList = document.getElementsByClassName("weui-desktop-form__input");
    if (inputList.length >= 3) {
      inputList[1].value = "YZH";
      inputList[2].value = "你若喜欢 给个赞吧";
    }
  }

  // 如果是异步操作（如 fetch），必须返回 true
  return true;
});
