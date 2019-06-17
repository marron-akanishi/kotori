var orig_list, disp_list, current_page;
const LIMIT = 100;

// ロード時に一覧取得
$(function () {
  $.ajaxSetup({ async: false });
  $.getJSON(`/api/get_list?type=${mode}`, data => orig_list = data);
  $.ajaxSetup({ async: true });
  disp_list = orig_list
  makePageNav(LIMIT);
  current_page = 1;
  viewChange();
});

// リストビューの更新
function viewChange() {
  $("#list").empty();
  disp_area = disp_list.slice((current_page - 1) * LIMIT, current_page * LIMIT)
  switch (mode) {
    case "book":
      $("#list").append("<tr><th>タイトル</th></tr>");
      for (var i in disp_area) {
        $("#list").append(`<tr><td><a href='/book/${disp_area[i].id}?from=list'>${disp_area[i].title}</a></td></tr>`)
      }
      break;
    default:
      $("#list").append("<tr><th>名前</th></tr>");
      for (var i in disp_area) {
        $("#list").append(`<tr><td><a href='/${mode}/${disp_area[i].id}'>${disp_area[i].name}</a></td></tr>`)
      }
      break;
  }
}

// タイトル検索
searchWord = function () {
  var searchText = $(this).val() // 検索ボックスに入力された値

  // 検索ボックスに値が入ってる場合
  if (searchText != '') {
    switch(mode){
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
    makePageNav(LIMIT);
    viewChange()
  } else {
    disp_list = orig_list
    makePageNav();
    viewChange(LIMIT)
  }
};

// searchWordの実行
$('#search').on('input', searchWord);