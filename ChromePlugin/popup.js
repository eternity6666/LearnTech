document.getElementById("fillForm").addEventListener("click", async () => {
  console.log("Button clicked!");

  // 获取当前活动的 Chrome 标签页
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  
  // 发送消息到 content_script
  chrome.tabs.sendMessage(
    tab.id,
    { action: "callFillForm", data: {} },
  );
});
