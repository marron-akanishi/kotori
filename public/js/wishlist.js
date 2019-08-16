var mode, orig_list, disp_list, current_page;
var sortmode, reverse;
const LIMIT = 100;

// ロード時に一覧取得
$(function () {
  $.ajaxSetup({ async: false });
  $.getJSON(`/api/get_list?type=wishlist`, data => orig_list = data);
  $.ajaxSetup({ async: true });
  disp_list = orig_list
  selSortMode("created_at", true)
});

// リストビューの更新
function viewChange() {
  $("#list").empty();
  disp_area = disp_list.slice((current_page - 1) * LIMIT, current_page * LIMIT)
  $("#list").append("<tr><th>タイトル</th><th style='width: 100px;'>操作</th></tr>");
  for (var i in disp_area) {
    let title;
    if (disp_area[i].book_id == null) {
      title = `<td>${disp_area[i].title}</td>`
    } else {
      title = `<td><a href='/book/${disp_area[i].book_id}'>${disp_area[i].title}</a></td>`
    }
    $("#list").append(`
      <tr id="list-${disp_area[i].id}">
        ${title}
        <td style="width: 100px;">
          <button type="button" class="btn btn-danger btn-sm" onclick="location.href='/user/wishlist/delete?id=${disp_area[i].id}'">
            <span class="oi oi-x"></span> 削除
          </button>
        </td>
      </tr>
    `)
  }
}

// タイトル検索
searchWord = function () {
  var searchText = $(this).val() // 検索ボックスに入力された値

  // 検索ボックスに値が入ってる場合
  if (searchText != '') {
    disp_list = orig_list.filter(function (item, index) {
      return normalizeStr(item.title).indexOf(normalizeStr(searchText)) >= 0
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
function setSort(obj){
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
  makePageNav(LIMIT);
  current_page = 1;
  viewChange();
}