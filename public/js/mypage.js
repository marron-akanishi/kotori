var own_list = [], disp_list, mode, current_page;
var load_count, load_num;
var name, sortmode, reverse;
const LIST_LIMIT = 50;
const GRID_LIMIT = 30;

// ロード
$(function () {
  // 所有書籍一覧作成
  var books, authors, book_authors, user_books
  $.ajaxSetup({ async: false });
  $.getJSON("/api/get_list?type=book", data => books = data);
  $.getJSON("/api/get_list?type=author", data => authors = data);
  $.getJSON("/api/get_list?type=book_authors", data => book_authors = data);
  $.getJSON("/api/get_list?type=user_books", data => user_books = data);  
  $.ajaxSetup({ async: true });
  for (var i in user_books) {
    var book = books.filter(function (item, index) {
      if (item.id == user_books[i].id) return true;
    });
    var author = authors.filter(function (item, index) {
      var book_author = book_authors.filter(function (item, index) {
        if (item.book_id == user_books[i].id) return true;
      })
      if (item.id == book_author[0].author_id) return true;
    });
    own_list.push({id: user_books[i].book_id, title: book[0].title, cover: book[0].cover, author: author[0].name, created_at: user_books[i].created_at})
  }
  // 表示モード切り替え
  mode = ($.cookie("mypageListMode") || "GRID").toUpperCase()
  $(`#${mode.toLowerCase()}button`).addClass("active")
  disp_list = own_list
  selSortMode("所有登録日(昇順)", "created_at", false)
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
        $("#ownlist").append(`<tr><td><a href='/book/${disp_area[i].id}?from=mypage'>${disp_area[i].title}</td><td>${disp_area[i].author}</td></tr>`)
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
    selSortMode(name, sortmode, reverse)
  } else {
    disp_list = own_list
    selSortMode(name, sortmode, reverse)
  }
};
// searchWordの実行
$('#search').on('input', searchWord);

// 並び替え
function selSortMode(_name, _sortmode, _reverse){
  name = _name, sortmode = _sortmode, reverse = _reverse
  $("#sort-sel").html(name)
  disp_list.sort(sortJSON(sortmode, reverse))
  makePageNav(eval(mode + "_LIMIT"));
  current_page = 1;
  viewChange();
}