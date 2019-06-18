var author_list, circle_list, genre_list, event_list;

// ロード時に一覧取得
$(function() {
  $.ajaxSetup({ async: false });
  $.getJSON("/api/get_list?type=author", data => author_list = data);
  $.getJSON("/api/get_list?type=circle", data => circle_list = data);
  $.getJSON("/api/get_list?type=genre", data => genre_list = data);
  $.getJSON("/api/get_list?type=event", data => event_list = data);
  $.ajaxSetup({ async: true });
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

// 一覧画面の表示
$('#listModal').on('show.bs.modal', function (event) {
  var button = $(event.relatedTarget) // モーダル切替えボタン
  var target = button.data('whatever') // data-* 属性から情報を抽出
  var modal = $(this)
  nameLabel = {"author": "著者", "circle": "サークル", "genre": "ジャンル", "event": "イベント"}
  modal.find('.modal-title').text(nameLabel[target] + "リストから選択")
  modal.find('.modal-body').empty()
  list = eval(target + "_list")
  for (var i in list) {
    modal.find('.modal-body').append(
      `<button type="button" class="btn btn-outline-primary" onclick="setVal('${target}', '${list[i].name}')" style="margin: 2px">${list[i].name}</button>`
    )
  }
})

// 一覧画面から選択
function setVal(target, value){
  document.getElementById(target).value = value
  $('#listModal').modal('hide')
}