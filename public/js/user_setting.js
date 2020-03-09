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
  var nobeer = $('#list-form').Nobeer({
    domList:[
      "#site-name",
      "#url-input",
      "#import-status"
    ],
    show:function(){
      this.slideDown()
    },
    hide:function(del){
      this.slideUp(del)
    },
    pipe:function(i){
      this.attr('class','form-row mt-1')
      this.find('input').attr('name',`input${i}`);
    },
    idx: 1
  })
  $('#form-add').click(nobeer.add);
  $('#form-del').click(nobeer.remove);
}

$('#export-btn').on('click',function(){
  // データの用意
  var book_list, export_data;
  $.ajaxSetup({ async: false });
  $.getJSON("/api/get_list?type=user_book", data => book_list = data);  
  $.ajaxSetup({ async: true });
  export_data = book_list.map((value) => {
    return [
      value.book.title,
      value.book.authors[0].name,
      value.book.circle.name,
      value.book.published_at,
      value.book.is_adult,
      value.memo,
      value.is_digital
    ]
  })
  // CSVの作成
  //var bom = new Uint8Array([0xEF, 0xBB, 0xBF]);
  var title = ["タイトル", "著者", "サークル", "発売日", "18禁", "メモ", "電子書籍版", "\r\n"]
  var csv_data = export_data.map(function(l){return l.join(',')}).join('\r\n');
  var blob = new Blob([title, csv_data], { type: 'text/csv' });
  var url = window.URL.createObjectURL(blob);
  // ダウンロードリンク生成
  var a = document.getElementById('download-link');
  a.download = 'export.csv';
  a.href = url;
  $('#download-link')[0].click();
});

// ファイル名表示
$('.custom-file-input').on('change', function () {
  $(this).next('.custom-file-label').html($(this)[0].files[0].name);
})

function api_key_update(){
  fetch("/user/api_update").then(res => res.text()).then(text => $("#apiKey").val(text));
  document.querySelector("#api-msg").innerText = "APIキーを更新しました";
}

function apiCopy(){
  document.getElementById("apiKey").select();
  document.execCommand("copy");
  document.querySelector("#api-msg").innerText = "APIキーをコピーしました";
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