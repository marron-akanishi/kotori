var orig_list, disp_list, current_page;
const LIMIT = 100;

// ロード時に書籍一覧と著者一覧取得
$(function () {
  $.ajaxSetup({ async: false });
  $.getJSON(`/api/get_list?type=${name}`, data => orig_list = data);
  $.ajaxSetup({ async: true });
  disp_list = orig_list
  makePageNav();
  current_page = 1;
  viewChange();
});

// リストビューの更新
function viewChange() {
  $("#list").empty();
  $("#list").append("<tr><th>名前</th></tr>");
  disp_area = disp_list.slice((current_page - 1) * LIMIT, current_page * LIMIT)
  switch (name) {
    case "book":
      for (var i in disp_area) {
        $("#list").append(`<tr><td><a href='/book/${disp_area[i].id}?from=list'>${disp_area[i].title}</td></tr>`)
      }
      break;
    default:
      for (var i in disp_area) {
        $("#list").append(`<tr><td>${disp_area[i].name}</td></tr>`)
      }
      break;
  }
}

// ページャーの生成
function makePageNav() {
  $("#pagenav").empty();
  if(disp_list.length == 0) return;
  var page_count = Math.floor(disp_list.length / LIMIT);
  if (disp_list.length % LIMIT != 0) page_count++;
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
  if (current_page * LIMIT >= disp_list.length) $('#nextpage').addClass("disabled");
  if (current_page == 1) $('#prevpage').addClass("disabled");
  $('li[id^="selpage-"]').removeClass("active");
  $(`#selpage-${current_page}`).addClass("active");
  viewChange();
}

// タイトル検索
searchWord = function () {
  var searchText = $(this).val() // 検索ボックスに入力された値

  // 検索ボックスに値が入ってる場合
  if (searchText != '') {
    switch(name){
      case "book":
        disp_list = orig_list.filter(function (item, index) {
          if (item.title.indexOf(searchText) >= 0 ||
            item.title.indexOf(kanaToHira(searchText)) >= 0 ||
            item.title.indexOf(hiraToKana(searchText)) >= 0 ||
            item.title.toLowerCase().indexOf(searchText.toLowerCase()) >= 0 ||
            item.title.toUpperCase().indexOf(searchText.toUpperCase()) >= 0) return true;
        });
        break;
      default:
        disp_list = orig_list.filter(function (item, index) {
          if (item.name.indexOf(searchText) >= 0 ||
            item.name.indexOf(kanaToHira(searchText)) >= 0 ||
            item.name.indexOf(hiraToKana(searchText)) >= 0 ||
            item.name.toLowerCase().indexOf(searchText.toLowerCase()) >= 0 ||
            item.name.toUpperCase().indexOf(searchText.toUpperCase()) >= 0) return true;
        });
        break;
    }
    makePageNav();
    viewChange()
  } else {
    disp_list = orig_list
    makePageNav();
    viewChange()
  }
};

// カナ→ひら
function kanaToHira(str) {
  return str.replace(/[\u30a1-\u30f6]/g, function (match) {
    var chr = match.charCodeAt(0) - 0x60;
    return String.fromCharCode(chr);
  });
}

// ひら→カナ
function hiraToKana(str) {
  return str.replace(/[\u3041-\u3096]/g, function (match) {
    var chr = match.charCodeAt(0) + 0x60;
    return String.fromCharCode(chr);
  });
}

// searchWordの実行
$('#search').on('input', searchWord);