extends Node2D

var from
var to

func set_line(f,t):
    from = f
    to = t
    var start = from.get_center()
    var end = to.get_center()
    global_position = start
    var dif = (end - start)
    $Button.margin_right = dif.length()
    rotation = dif.angle()


func _on_Button_pressed():
    from.disconnect_square(to)
    queue_free()
