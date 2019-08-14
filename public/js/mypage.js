var own_list, disp_list, mode, current_page;
var load_count, load_num;
var sortmode, reverse;
var limit_config = {grid: 0, list: 0};

// ロード
$(function () {
  // 所有書籍一覧作成
  var user_books
  $.ajaxSetup({ async: false });
  $.getJSON("/api/get_list?type=user_book", data => own_list = data);  
  $.ajaxSetup({ async: true });
  // 表示件数読み込み
  limit_config["grid"] = $.cookie("mypageGridLimit") || 30
  limit_config["list"] = $.cookie("mypageListLimit") || 50
  // 表示モード切り替え
  mode = ($.cookie("mypageListMode") || "grid").toLowerCase()
  $(`#${mode.toLowerCase()}button`).addClass("active")
  disp_list = own_list
  selSortMode("created_at", true)
});

// リストモードの切り替え
$('input[name="listmode"]').change(function () {
  mode = $(this).val();
  $.cookie("mypageListMode", mode, { expires: 30 });
  makePageNav(limit_config[mode]);
  current_page = 1;
  viewChange();
});

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

// 表示件数選択
function setLimit(obj){
  var idx = obj.selectedIndex;
  limit_config[mode] = obj.options[idx].value;
  var target = mode.charAt(0).toUpperCase() + mode.slice(1).toLowerCase();
  $.cookie("mypage" + target + "Limit", limit_config[mode], { expires: 30 });
  selSortMode(sortmode, reverse)
}

// 並び替え実行
function selSortMode(_sortmode, _reverse){
  sortmode = _sortmode, reverse = _reverse
  disp_list.sort(sortJSON(sortmode, reverse))
  makePageNav(limit_config[mode]);
  current_page = 1;
  viewChange();
}

// リストビューの更新
function viewChange() {
  $("#ownlist").empty();
  $("#owngrid").empty();
  $("#limit-sel").empty();
  disp_area = disp_list.slice((current_page - 1) * limit_config[mode], current_page * limit_config[mode])
  switch (mode) {
    case "grid":
      $("#ownlist").hide();
      $("#owngrid").show();
      load_num = disp_area.length;
      load_count = 0;
      if (load_num != 0) $("#loading-gif").show();
      else $("#loading-gif").hide();
      for (var i in disp_area) {
        $("#owngrid").append(`
          <div class="cover">
            <img src="/images/cover/${disp_area[i].cover}" onclick="location.href='/book/${disp_area[i].id}'" onload="imgLoadEnd()"/>
            <p>${disp_area[i].title}</p>
          </div>
        `)
        $("#owngrid > .cover").hide();
      }
      $("#limit-sel").append(`
        <option value="20">20</option>
        <option value="30">30</option>
        <option value="40">40</option>
      `)
      break;
    case "list":
      $("#owngrid").hide();
      $("#loading-gif").hide();
      $("#ownlist").show();
      $("#ownlist").append(`<tr><th>タイトル</th><th>著者</th></tr>`)
      for (var i in disp_area) {
        $("#ownlist").append(`<tr><td><a href='/book/${disp_area[i].id}'>${disp_area[i].title}</td><td>${disp_area[i].authors[0].name}</td></tr>`)
      }
      $("#limit-sel").append(`
        <option value="50">50</option>
        <option value="70">70</option>
        <option value="100">100</option>
      `)
      break;
  }
  $("#limit-sel").val(limit_config[mode])
}