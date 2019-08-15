var limit;

// ページャーの生成
function makePageNav(page_limit) {
  limit = page_limit;
  $("#pagenav").empty();
  $("#listcount").text(`${disp_list.length}件`);
  if (disp_list.length == 0) return;
  var page_count = Math.floor(disp_list.length / limit);
  if (disp_list.length % limit != 0) page_count++;
  $("#pagenav").append(`
    <li class="page-item" id="prevpage">
      <a class="page-link" href="#" aria-label="Previous" onclick="setPage('prev')">
        <span aria-hidden="true">&laquo;</span>
      </a>
    </li>
  `)
  for (var i = 1; i <= page_count; i++) {
    $("#pagenav").append(`<li class="page-item" id="selpage-${i}"><a class="page-link" href="#" onclick="setPage(${i})">${i}</a></li>`)
  }
  $("#pagenav").append(`
    <li class="page-item" id="nextpage">
      <a class="page-link" href="#" aria-label="Next" onclick="setPage('next')">
        <span aria-hidden="true">&raquo;</span>
      </a>
    </li>
  `)
  $('#prevpage').addClass("disabled");
  $('#selpage-1').addClass("active");
  if (page_count == 1) $('#nextpage').addClass("disabled");
}

// ページネーション
function setPage(page) {
  switch (page) {
    case "prev":
      current_page--;
      break;
    case "next":
      current_page++;
      break;
    default:
      current_page = page
      break;
  }
  $('li[id$="page"]').removeClass("disabled");
  if (current_page * limit >= disp_list.length) $('#nextpage').addClass("disabled");
  if (current_page == 1) $('#prevpage').addClass("disabled");
  $('li[id^="selpage-"]').removeClass("active");
  $(`#selpage-${current_page}`).addClass("active");
  viewChange();
}

// カナ→ひら、全角→半角、スペース削除、小文字→大文字
function normalizeStr(str) {
  str = str.replace(/[\u30a1-\u30f6]/g, function (match) {
    return String.fromCharCode(match.charCodeAt(0) - 0x60);
  });
  str = str.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function (s) {
    return String.fromCharCode(s.charCodeAt(0) - 0xFEE0);
  });
  str = str.replace(/[\s 　]/g, "")
  return str.toUpperCase()
}

// 並び替え
function sortJSON(field, reverse, second_field){
  reverse = (reverse) ? -1 : 1;
  return function(a,b){
    a = a[field];
    b = b[field];
    if (typeof(second_field) != 'undefined'){
      a = a[second_field];
      b = b[second_field];
    }
    if (a<b) return reverse * -1;
    if (a>b) return reverse * 1;
    return 0;
  }
  
}