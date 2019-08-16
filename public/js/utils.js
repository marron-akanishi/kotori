var limit, max_page;

// ページャーの生成
function makePageNav(page_limit) {
  limit = page_limit;
  $("#pagenav").empty();
  $("#listcount").text(`${disp_list.length}件`);
  if (disp_list.length == 0) return;
  max_page = Math.floor(disp_list.length / limit);
  if (disp_list.length % limit != 0) max_page++;
  $("#pagenav").append(`
    <li class="page-item" id="firstpage">
      <a class="page-link" href="#" aria-label="First" onclick="setPage('first')">
        <span aria-hidden="true">最初</span>
      </a>
    </li>
    <li class="page-item" id="prevpage">
      <a class="page-link" href="#" aria-label="Previous" onclick="setPage('prev')">
        <span aria-hidden="true">&lt;</span>
      </a>
    </li>
  `)
  $("#pagenav").append(`
    <li class="page-item disabled"><a class="page-link" href="#" id="pagenum">1/${max_page}</a></li>
  `)
  $("#pagenav").append(`
    <li class="page-item" id="nextpage">
      <a class="page-link" href="#" aria-label="Next" onclick="setPage('next')">
        <span aria-hidden="true">&gt;</span>
      </a>
    </li>
    <li class="page-item" id="lastpage">
      <a class="page-link" href="#" aria-label="Last" onclick="setPage('last')">
        <span aria-hidden="true">最後</span>
      </a>
    </li>
  `)
  $('#prevpage').addClass("disabled");
  $('#firstpage').addClass("disabled");
  if (max_page == 1) {
    $('#nextpage').addClass("disabled");
    $('#lastpage').addClass("disabled");
  }
}

// ページネーション
function setPage(page) {
  switch (page) {
    case "first":
      current_page = 1;
      break;
    case "last":
      current_page = max_page;
      break;
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
  if (current_page >= max_page) {
    $('#nextpage').addClass("disabled");
    $('#lastpage').addClass("disabled");
  } else {
    $('#nextpage').removeClass("disabled");
    $('#lastpage').removeClass("disabled");
  }
  if (current_page == 1) {
    $('#prevpage').addClass("disabled");
    $('#firstpage').addClass("disabled");
  } else {
    $('#prevpage').removeClass("disabled");
    $('#firstpage').removeClass("disabled");
  }
  $(`#pagenum`).text(`${current_page}/${max_page}`)
  //scrollTo(0,0)
  viewChange();
}

// カナ→ひら、全角→半角、スペース削除、小文字→大文字
function normalizeStr(str) {
  str = str.replace(/[\u30a1-\u30f6]/g, function (match) {
    return String.fromCharCode(match.charCodeAt(0) - 0x60);
  });
  str = str.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function (s) {
    return String.fromCharCode(s.charCodeAt(0) - 0xFEE0);
  });
  str = str.replace(/[\s 　]/g, "")
  return str.toUpperCase()
}

// 並び替え
function sortJSON(field, reverse, second_field){
  reverse = (reverse) ? -1 : 1;
  return function(a,b){
    a = a[field];
    b = b[field];
    if (typeof(second_field) != 'undefined'){
      a = a[second_field];
      b = b[second_field];
    }
    if (a<b) return reverse * -1;
    if (a>b) return reverse * 1;
    return 0;
  }
  
}