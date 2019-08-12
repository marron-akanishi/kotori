var own_list, disp_list, mode, current_page;
var load_count, load_num;
var sortmode, reverse;
const LIST_LIMIT = 50;
const GRID_LIMIT = 30;

// ロード
$(function () {
  // 所有書籍一覧作成
  var user_books
  $.ajaxSetup({ async: false });
  $.getJSON("/api/get_list?type=user_book", data => own_list = data);  
  $.ajaxSetup({ async: true });
  // 表示モード切り替え
  mode = ($.cookie("mypageListMode") || "GRID").toUpperCase()
  $(`#${mode.toLowerCase()}button`).addClass("active")
  disp_list = own_list
  selSortMode("created_at", true)
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
      load_num = disp_area.length;
      load_count = 0;
      if(load_num != 0) $("#loading-gif").show();
      else $("#loading-gif").hide();
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
        $("#ownlist").append(`<tr><td><a href='/book/${disp_area[i].id}?from=mypage'>${disp_area[i].title}</td><td>${disp_area[i].authors[0].name}</td></tr>`)
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
      return normalizeStr(item.title).indexOf(normalizeStr(searchText)) >= 0
    });
    selSortMode(sortmode, reverse)
  } else {
    disp_list = own_list
    selSortMode(sortmode, reverse)
  }
};
// searchWordの実行
$('#search').on('input', searchWord);

// 並び替え選択
function setSort(obj) {
  var idx = obj.selectedIndex;
  var value = obj.options[idx].value;
  var option = value.split(",")
  var reverse = option[1] == "desc" ? true : false
  selSortMode(option[0], reverse)
}

// 並び替え実行
function selSortMode(_sortmode, _reverse){
  sortmode = _sortmode, reverse = _reverse
  disp_list.sort(sortJSON(sortmode, reverse))
  makePageNav(eval(mode + "_LIMIT"));
  current_page = 1;
  viewChange();
}