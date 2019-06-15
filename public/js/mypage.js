var own_list, author_list, mode;
$(function () {
  $.ajaxSetup({ async: false });
  $.getJSON("/mypage/ownlist", data => own_list = data);
  $.getJSON("/api/get_list?type=author", data => author_list = data);
  $.ajaxSetup({ async: true });
  mode = $.cookie("mypageListMode") || "grid"
  $(`#${mode}button`).addClass("active")
  modeChange(mode, own_list);
});

$('input[name="listmode"]').change(function () {
  mode = $(this).val();
  $.cookie("mypageListMode", mode);
  modeChange(mode, own_list);
});

function modeChange(disp_mode, disp_list) {
  $("#ownlist").empty();
  $("#owngrid").empty();
  switch (disp_mode) {
    case "grid":
      $("#ownlist").hide();
      $("#owngrid").show();
      for (var i in disp_list) {
        $("#owngrid").append(`
            <li style="display: inline;">
              <button onclick="location.href='/detail/book/${disp_list[i].id}?from=mypage'" class="btn btn-link thum">
                <img src="/images/cover/${disp_list[i].cover}" height="200px" />
                <p style="color: black;">${disp_list[i].title}</p>
              </button>
            </li>
          `)
      }
      break;
    case "list":
      $("#owngrid").hide();
      $("#ownlist").show();
      $("#ownlist").append(`<tr><th>タイトル</th><th>著者</th></tr>`)
      for (var i in disp_list) {
        var author = author_list.filter(function (item, index) {
          if (item.id == disp_list[i].author_id) return true;
        });
        $("#ownlist").append(`<tr><td><a href='/detail/book/${disp_list[i].id}?from=mypage'>${disp_list[i].title}</td><td>${author[0].name}</td></tr>`)
      }
      break;
  }
}

searchWord = function () {
  var searchResult,
    searchText = $(this).val() // 検索ボックスに入力された値

  // 検索ボックスに値が入ってる場合
  if (searchText != '') {
    var searchResult = own_list.filter(function (item, index) {
      if (item.title.indexOf(searchText) >= 0 ||
          item.title.indexOf(kanaToHira(searchText)) >= 0 ||
          item.title.indexOf(hiraToKana(searchText)) >= 0 ||
          item.title.toLowerCase().indexOf(searchText.toLowerCase()) >= 0 ||
          item.title.toUpperCase().indexOf(searchText.toUpperCase()) >= 0) return true;
    });
    modeChange(mode, searchResult)
  } else {
    modeChange(mode, own_list)
  }
};

function kanaToHira(str) {
  return str.replace(/[\u30a1-\u30f6]/g, function (match) {
    var chr = match.charCodeAt(0) - 0x60;
    return String.fromCharCode(chr);
  });
}

function hiraToKana(str) {
  return str.replace(/[\u3041-\u3096]/g, function (match) {
    var chr = match.charCodeAt(0) + 0x60;
    return String.fromCharCode(chr);
  });
}

// searchWordの実行
$('#search').on('input', searchWord);