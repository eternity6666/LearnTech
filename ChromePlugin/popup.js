document.getElementById('fillForm').addEventListener('click', () => {
  chrome.scripting.executeScript({
    target: {tabId: chrome.tabs.TAB_ID},
    func: fillForm
  });
});

