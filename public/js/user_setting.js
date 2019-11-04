var site_list = {melon: "メロンブックス", tora: "とらのあな", lashin: "らしんばん"}
var status_list = {wait: "待ち", ok: "OK", error: "NG", duplicate: "重複"}

var getDevice = (function () {
  var ua = navigator.userAgent;
  if (ua.indexOf('iPhone') > 0 || ua.indexOf('iPod') > 0 || ua.indexOf('Android') > 0 && ua.indexOf('Mobile') > 0) {
    return 'sp';
  } else if (ua.indexOf('iPad') > 0 || ua.indexOf('Android') > 0) {
    return 'tab';
  } else {
    return 'other';
  }
})();

window.onload = () => {
  if(getDevice != "other") $(".sm-hidden").hide();
}

// ファイル名表示
$('.custom-file-input').on('change', function () {
  $(this).next('.custom-file-label').html($(this)[0].files[0].name);
})

function api_key_update(){
  fetch("/user/api_update").then(res => res.text()).then(text => $("#apiKey").val(text));
}

function apiCopy(){
  document.getElementById("apiKey").select();
  document.execCommand("copy");
}

function url_list_add(){
  if (document.getElementById("urllist").files.length == 0) return;
  // CSVロード
  var reader = new FileReader();
  reader.onload = function (e) {
    const url_list = parseCSV(e.target.result)
    console.log(url_list)
    reloadTable(url_list)
    url_list.forEach((data, i) => {
      if(site_list[data["type"]] && data["url"]){
        setTimeout(() => {
          sendData(data).done(result => {
            console.log(result)
            url_list[i]["status"] = result
            reloadTable(url_list)
          }).fail(() => {
            url_list[i]["status"] = "error"
            reloadTable(url_list)
          });
        }, 1500*i)
      } else {
        url_list[i]["status"] = "error"
      }
    });
  }
  reader.readAsText(document.getElementById("urllist").files[0]);
}

function parseCSV(text){
  var result = [];
  var tmp = text.split(/\r?\n/g)
  tmp.forEach(line => {
    var data = {}
    data["type"] = line.split(',')[0]
    data["url"] = line.split(',')[1]
    data["status"] = "wait"
    if(data["url"]){
      result.push(data)
    }
  });
  return result;
}

// Ajax通信
function sendData(data){
  return $.ajax({
    url: '/user/add_books',
    type: 'POST',
    data: {mode: data["type"], url: data["url"]}
  });
}

// テーブル更新
function reloadTable(list){
  var target = $("#urladd-status");
  target.empty();
  target.append("<tr><th>サイト</th><th>URL</th><th>状態</th></tr>");  
  list.forEach(data => {
    const type = site_list[data["type"]] ? site_list[data["type"]] : "不明"
    const status = status_list[data["status"]]
    target.append(`
      <tr>
        <td>${type}</td>
        <td>${data["url"]}</td>
        <td>${status}</td>
      </tr>
    `)
  })
}