var own_list, author_list, disp_list, mode, current_page;
const LIMIT = 50;

// ロード時に書籍一覧と著者一覧取得
$(function () {
  $.ajaxSetup({ async: false });
  $.getJSON("/api/get_list?type=ownlist", data => own_list = data);
  $.getJSON("/api/get_list?type=author", data => author_list = data);
  $.ajaxSetup({ async: true });
  mode = $.cookie("mypageListMode") || "grid"
  $(`#${mode}button`).addClass("active")
  disp_list = own_list
  makePageNav();
  current_page = 1;
  viewChange(mode);
});

// リストモードの切り替え
$('input[name="listmode"]').change(function () {
  mode = $(this).val();
  $.cookie("mypageListMode", mode);
  current_page = 1;
  viewChange(mode);
});

// リストビューの更新
function viewChange(disp_mode) {
  $("#ownlist").empty();
  $("#owngrid").empty();
  disp_area = disp_list.slice((current_page - 1) * LIMIT, current_page * LIMIT)
  switch (disp_mode) {
    case "grid":
      $("#ownlist").hide();
      $("#owngrid").show();
      for (var i in disp_area) {
        $("#owngrid").append(`
            <div class="cover">
              <img src="/images/cover/${disp_area[i].cover}" onclick="location.href='/book/${disp_area[i].id}?from=mypage'" />
              <p>${disp_area[i].title}</p>
            </div>
          `)
      }
      break;
    case "list":
      $("#owngrid").hide();
      $("#ownlist").show();
      $("#ownlist").append(`<tr><th>タイトル</th><th>著者</th></tr>`)
      for (var i in disp_area) {
        var author = author_list.filter(function (item, index) {
          if (item.id == disp_area[i].author_id) return true;
        });
        $("#ownlist").append(`<tr><td><a href='/book/${disp_area[i].id}?from=mypage'>${disp_area[i].title}</td><td>${author[0].name}</td></tr>`)
      }
      break;
  }
}

// ページャーの生成
function makePageNav(){
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
function setPage(page){
  switch(page){
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
  viewChange(mode);
}

// タイトル検索
searchWord = function () {
  var searchText = $(this).val() // 検索ボックスに入力された値

  // 検索ボックスに値が入ってる場合
  if (searchText != '') {
    disp_list = own_list.filter(function (item, index) {
      if (item.title.indexOf(searchText) >= 0 ||
          item.title.indexOf(kanaToHira(searchText)) >= 0 ||
          item.title.indexOf(hiraToKana(searchText)) >= 0 ||
          item.title.toLowerCase().indexOf(searchText.toLowerCase()) >= 0 ||
          item.title.toUpperCase().indexOf(searchText.toUpperCase()) >= 0) return true;
    });
    makePageNav();
    viewChange(mode)
  } else {
    disp_list = own_list
    makePageNav();
    viewChange(mode)
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