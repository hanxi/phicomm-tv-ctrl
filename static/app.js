var isSupportTouch = "ontouchend" in document ? true : false;
document.oncontextmenu = function(e){
    e.preventDefault();
};

function click_vibrate(){
    if ("vibrate" in navigator){
        navigator.vibrate(50);
    }
}

$(".direction").on(isSupportTouch ? "touchstart" : "mousedown",function(){
    click_vibrate();
    var o=$(this);
    $("#direction-btns").css({"background-position":o.attr("data-bp")});
    postKeyCode(o.attr("data-key"));
    console.log("keycode:" + o.attr("data-key"));
})
$(".otherbtn").on(isSupportTouch ? "touchstart" : "mousedown", function() {
    click_vibrate();
    var o = $(this);
    o.css({
        "background-position": o.attr("data-bp")
    });
    postKeyCode(o.attr("data-key"));
    console.log("keycode:" + o.attr("data-key"));
})
$(".direction,.otherbtn").on(isSupportTouch ? "touchend touchmove" : "mouseup mousemove", function() {
    $("#direction-btns,.direction,.otherbtn").css({
        "background-position": ""
    });
})

function postKeyCode(keyCode){
    $.ajax({
        type: 'POST',
        url: '/keyevent',
        data: '{"keycode":'+keyCode+',"longclick":false}', // or JSON.stringify ({name: 'jonas'}),
        success: function(data) { console.log('data: ' + data); },
        contentType: "application/json",
        dataType: 'json'
    });
}

$.get('/host', function(ret){
    $('#host').text(ret);
})

