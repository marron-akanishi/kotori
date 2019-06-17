var limit;

// ページャーの生成
function makePageNav(page_limit) {
  limit = page_limit;
  $("#pagenav").empty();
  $("#listcount").text(`${disp_list.length}件`);
  if (disp_list.length == 0) return;
  var page_count = Math.floor(disp_list.length / limit);
  if (disp_list.length % limit != 0) page_count++;
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
function setPage(page) {
  switch (page) {
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
  if (current_page * limit >= disp_list.length) $('#nextpage').addClass("disabled");
  if (current_page == 1) $('#prevpage').addClass("disabled");
  $('li[id^="selpage-"]').removeClass("active");
  $(`#selpage-${current_page}`).addClass("active");
  viewChange();
}

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