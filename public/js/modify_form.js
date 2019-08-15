var author_list, circle_list, genre_list, event_list, tag_list;

// ロード時に一覧取得
$(function() {
  ["author", "circle", "genre", "event", "tag"].forEach((type) => {
    $.getJSON("/api/get_list?type="+type, data => eval(type+"_list = data"));
    setupSuggest(type)
  })
  document.onkeypress = () => {
    if(window.event.keyCode == 13) return false;
  }
})

// ファイル名表示
$('.custom-file-input').on('change', function () {
  $(this).next('.custom-file-label').html($(this)[0].files[0].name);
})

// 画像のプレビュー
$('#cover-img').on('change', function(e){
  var reader = new FileReader();
  reader.onload = function(e){
    $('#cover-preview').attr('src', e.target.result);
  }
  reader.readAsDataURL(e.target.files[0]);
});

// 複数用フォームでEnterキーによる追加を有効化
$('.add-form').on('keypress', function(e){
  if(e.keyCode == 13) addData(e.target.id)
})

// フォーム送信前に加工
function submitCheck() {
  $('#input-error').css("display", 'none');
  ["author", "genre", "tag"].forEach((type) => {
    var list = document.querySelectorAll(`#${type}-list button`)
    document.getElementsByName(type)[0].value = ""
    list.forEach((obj) => {document.getElementsByName(type)[0].value += obj.innerText + ","});
  })
  if ($("#author").val() == "" || $("#genre").val() == "" || $("#title").val() == "") {
    $('#input-error').css("display", 'block')
    return false;
  } else {
    $("form").submit();
  }
}

// サジェストの表示
function setupSuggest(type){
  $(`#${type}-input`).autocomplete({
    source: function (req, res) {
      var suggests = eval(type+"_list").filter(function (item, index) {
        return normalizeStr(item.name_yomi).indexOf(normalizeStr(req.term)) >= 0 ||
          normalizeStr(item.name).indexOf(normalizeStr(req.term)) >= 0
      });
      suggests = suggests.map(data => data.name)
      res(suggests)
    },
    autoFocus: false,
    delay: 100
  })
}

// 複数表示に追加
function addData(type){
  var data = document.getElementById(type).value
  if(data == "") return;
  document.getElementById(type.replace("input", "list")).insertAdjacentHTML('beforeend', `
    <button type="button" class="btn btn-outline-dark btn-sm" style="margin: 0 .25rem .5rem 0" onclick="delData()">${data}</button>
  `)
  document.getElementById(type).value = ""
}

// 複数表示から消去
function delData(){
  var target = event.target;
  target.parentNode.removeChild(target);
}