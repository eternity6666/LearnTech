// 填充表单
function fillForm() {
  const formData = {
    kw: "遥遥领先"
  };
  const kwField = document.querySelector('input[id="kw"]');
  console.log('kw:', kwField);
  if (kwField) {
    kwField.value = formData.kw;
    console.log('kw field filled!', kwField.value);
  }
}

document.getElementById('fillForm').addEventListener('click', () => {
  console.log('Button clicked!');

  // 获取当前活动标签页的 tabId
  chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
    if (tabs && tabs.length > 0) {
      const tabId = tabs[0].id;

      // 使用 chrome.scripting 执行脚本
      chrome.scripting.executeScript({
        target: { tabId: tabId },
        func: fillForm
      });
    } else {
      console.error('No active tab found!');
    }
  });
});