var own_list, disp_list, mode, current_page;
var search_type = "title", load_count, load_num;
var sortmode, reverse;
var limit_config = {grid: 0, list: 0};

// ロード
$(function () {
  // 所有書籍一覧作成
  $.ajaxSetup({ async: false });
  $.getJSON("/api/get_list?type=user_book", data => own_list = data);  
  $.ajaxSetup({ async: true });
  // 表示件数読み込み
  limit_config["grid"] = $.cookie("mypageGridLimit") || 30
  limit_config["list"] = $.cookie("mypageListLimit") || 50
  // ソートモード読み込み
  sortmode = $.cookie("mypageSortMode") || "created_at"
  reverse = $.cookie("mypageIsReverse") || "desc"
  // 表示モード読み込み
  mode = ($.cookie("mypageListMode") || "grid").toLowerCase()
  $(`#${mode.toLowerCase()}button`).addClass("active")
  disp_list = own_list
  selSortMode(sortmode, reverse)
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

function setSearchType(obj, type){
  disp_list = own_list
  selSortMode(sortmode, reverse)
  $('#search').val("")
  search_type = type;
  document.getElementById("search-type").innerText = obj.innerText
}

// 検索
searchWord = function () {
  var searchText = $(this).val() // 検索ボックスに入力された値
  // 検索ボックスに値が入ってる場合
  if (searchText != '') {
    switch (search_type) {
      case 'title':
        disp_list = own_list.filter(function (item, index) {
          return normalizeStr(item.book.title).indexOf(normalizeStr(searchText)) >= 0
        });
        break
      case 'author':
        disp_list = own_list.filter(function (item, index) {
          return item.book.authors.filter(function (item, index) {
            return normalizeStr(item.name_yomi).indexOf(normalizeStr(searchText)) >= 0 ||
              normalizeStr(item.name).indexOf(normalizeStr(searchText)) >= 0
          }).length >= 1
        });
        break;
      case 'circle':
        disp_list = own_list.filter(function (item, index) {
          return normalizeStr(item.book.circle.name_yomi).indexOf(normalizeStr(searchText)) >= 0 ||
            normalizeStr(item.book.circle.name).indexOf(normalizeStr(searchText)) >= 0
        });
        break;
      case 'genre':
        disp_list = own_list.filter(function (item, index) {
          return item.book.genres.filter(function (item, index) {
            return normalizeStr(item.name_yomi).indexOf(normalizeStr(searchText)) >= 0 ||
              normalizeStr(item.name).indexOf(normalizeStr(searchText)) >= 0
          }).length >= 1
        });
        break;
    }
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
  selSortMode(option[0], option[1])
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
  var isReverse = (_reverse == "desc" ? true : false)
  switch (sortmode) {
    case "created_at":
      disp_list.sort(sortJSON(sortmode, isReverse))
      break;
    case "title":
      disp_list.sort(sortJSON("book", isReverse, "title"))
      break;
  }
  $.cookie("mypageSortMode", _sortmode, { expires: 30 });
  $.cookie("mypageIsReverse", _reverse, { expires: 30 });
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
            <img src="/images/cover/${disp_area[i].book.cover}" onclick="location.href='/book/${disp_area[i].book.id}'" onload="imgLoadEnd()"/>
            <p>${disp_area[i].book.title}</p>
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
        $("#ownlist").append(`<tr><td><a href='/book/${disp_area[i].book.id}'>${disp_area[i].book.title}</td><td>${disp_area[i].book.authors[0].name}</td></tr>`)
      }
      $("#limit-sel").append(`
        <option value="50">50</option>
        <option value="70">70</option>
        <option value="100">100</option>
      `)
      break;
  }
  $("#limit-sel").val(limit_config[mode])
  $("#sort-sel").val(sortmode+","+reverse)
}