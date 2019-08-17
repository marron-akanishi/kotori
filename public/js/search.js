var mode, orig_list, disp_list, current_page;
var sortmode, reverse;
const LIMIT = 20;

window.onload = () =>{
  if ($("#words").val() != "") {
    orig_list = JSON.parse(sessionStorage.result)
    $("#result").text(`結果：${orig_list.length}件`)
    disp_list = orig_list
    makePageNav(LIMIT);
    current_page = 1;
    viewChange();
  } else {
    sessionStorage.removeItem("result")
  }
}

// リストビューの更新
function viewChange() {
  $("#list").empty();
  disp_area = disp_list.slice((current_page - 1) * LIMIT, current_page * LIMIT)
  disp_area.forEach(data => {
    $("#list").append(`
      <div class="media border p-2 result-row" onclick="location.href='/book/${data.id}'">
        <img src="/images/cover/${data.cover}" height="100" class="mr-2" />
        <div class="media-body">
          <h5 class="mt-0">${data.title}</h5>
          <div style="color: #5f5f5f">
            <span>${data.authors[0].name}</span><br>
            <span>${data.circle.name}</span>
          </div>
        </div>
      </div>
    `)
  });
}

// フォームでEnterキーによる検索を有効化
$('#words').on('keypress', function (e) {
  if (e.keyCode == 13) startSearch()
})

// 検索実行
function startSearch(){
  $.ajax({
    url: '/api/search',
    type: 'POST',
    data: {
      'words': $('#words').val()
    }
  }).done((data) => {
    sessionStorage.setItem("result", data)
    orig_list = JSON.parse(data)
    $("#result").text(`結果：${orig_list.length}件`)
    disp_list = orig_list
    makePageNav(LIMIT);
    current_page = 1;
    viewChange();
  })
}

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