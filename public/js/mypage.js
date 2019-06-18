var own_list, author_list, disp_list, mode, current_page;
var load_count, load_num;
const LIST_LIMIT = 50;
const GRID_LIMIT = 30;

// ロード時に書籍一覧と著者一覧取得
$(function () {
  $.ajaxSetup({ async: false });
  $.getJSON("/api/get_list?type=ownlist", data => own_list = data);
  $.getJSON("/api/get_list?type=author", data => author_list = data);
  $.ajaxSetup({ async: true });
  mode = $.cookie("mypageListMode").toUpperCase() || "GRID"
  $(`#${mode.toLowerCase()}button`).addClass("active")
  disp_list = own_list
  makePageNav(eval(mode + "_LIMIT"));
  current_page = 1;
  viewChange();
});

// リストモードの切り替え
$('input[name="listmode"]').change(function () {
  mode = $(this).val();
  $.cookie("mypageListMode", mode);
  makePageNav(eval(mode + "_LIMIT"));
  current_page = 1;
  viewChange();
});

// リストビューの更新
function viewChange() {
  $("#ownlist").empty();
  $("#owngrid").empty();
  disp_area = disp_list.slice((current_page - 1) * eval(mode + "_LIMIT"), current_page * eval(mode + "_LIMIT"))
  switch (mode) {
    case "GRID":
      $("#ownlist").hide();
      $("#owngrid").show();
      $("#loading-gif").show();
      load_num = disp_area.length;
      load_count = 0;
      for (var i in disp_area) {
        $("#owngrid").append(`
          <div class="cover">
            <img src="/images/cover/${disp_area[i].cover}" onclick="location.href='/book/${disp_area[i].id}?from=mypage'" onload="imgLoadEnd()"/>
            <p>${disp_area[i].title}</p>
          </div>
        `)
        $("#owngrid > .cover").hide();
      }
      break;
    case "LIST":
      $("#owngrid").hide();
      $("#loading-gif").hide();
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

// 画像読み込み完了
function imgLoadEnd() {
  load_count++;
  if(load_count == load_num){
    $("#loading-gif").hide();
    $("#owngrid > .cover").show();
  }
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
    makePageNav(eval(mode + "_LIMIT"));
    viewChange()
  } else {
    disp_list = own_list
    makePageNav(eval(mode + "_LIMIT"));
    viewChange()
  }
};

// searchWordの実行
$('#search').on('input', searchWord);