var orig_list, disp_list, current_page;
var sortmode, reverse;
const LIMIT = 100;

// リストビューの更新
function viewChange() {
  $("#list").empty();
  disp_area = disp_list.slice((current_page - 1) * LIMIT, current_page * LIMIT)
  $("#list").append("<tr><th>タイトル</th></tr>");
  for (var i in disp_area) {
    $("#list").append(`<tr><td><a href='/book/${disp_area[i].id}?from=list'>${disp_area[i].title}</a></td></tr>`)
  }
}

// タイトル検索
searchWord = function () {
  var searchText = $(this).val() // 検索ボックスに入力された値

  // 検索ボックスに値が入ってる場合
  if (searchText != '') {
    disp_list = orig_list.filter(function (item, index) {
      return normalizeStr(item.name).indexOf(normalizeStr(searchText)) >= 0
    });
    selSortMode(sortmode, reverse)
  } else {
    disp_list = orig_list
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
function selSortMode(_sortmode, _reverse) {
  sortmode = _sortmode, reverse = _reverse
  disp_list.sort(sortJSON(sortmode, reverse))
  makePageNav(LIMIT);
  current_page = 1;
  viewChange();
}