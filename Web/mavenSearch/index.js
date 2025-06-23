function searchMaven() {
  const query = encodeURIComponent(
    document.getElementById("query").value.trim()
  );
  if (!query) return;

  const links = {
    "Maven Central": `https://search.maven.org/search?q=${query}`,
    MVNRepository: `https://mvnrepository.com/search?q=${query}`,
    "Aliyun Maven": `https://developer.aliyun.com/mvn/search?keyword=${query}`,
    "Google Maven": `https://maven.google.com/web/index.html#${query}`,
    "Tencent Maven": `https://mirrors.tencent.com/mirrors/api/mirrors/search?value=${query}`,
  };

  // https://mirrors.tencent.com/tlinux/4.2/AppStream/source/tree/Packages/rsyslog-8.2312.0-4.tl4.src.rpm
  const resultsDiv = document.getElementById("results");
  resultsDiv.innerHTML = "";

  for (const [name, url] of Object.entries(links)) {
    const a = document.createElement("a");
    a.href = url;
    a.target = "_blank";
    a.textContent = `在 ${name} 中搜索 "${decodeURIComponent(query)}"`;
    resultsDiv.appendChild(a);
  }
}
