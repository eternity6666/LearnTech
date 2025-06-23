// 定义要填充的表单数据
const formData = {
  name: "John Doe",
  email: "john.doe@example.com",
  phone: "1234567890"
};

// 填充表单
function fillForm() {
  const nameField = document.querySelector('input[name="name"]');
  const emailField = document.querySelector('input[name="email"]');
  const phoneField = document.querySelector('input[name="phone"]');

  if (nameField) nameField.value = formData.name;
  if (emailField) emailField.value = formData.email;
  if (phoneField) phoneField.value = formData.phone;
}

// 检查网页加载完成后执行填充操作
window.addEventListener('load', fillForm);

