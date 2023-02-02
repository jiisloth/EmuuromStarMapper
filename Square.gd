extends Control

var connects_to = []
var selected =  false
var bluestar =  false
var pos = Vector2()
var extrastar = false

func _on_Button_pressed():
    print(pos)
    get_parent().get_parent().get_parent().select_square(self)
    selected = true
    
    
func _process(delta):
    if bluestar:
        $Lines/Back.color = Color("#205477")
    else:
        $Lines/Back.color = Color("#000000")
        
    if selected:
        $ColorRect.color = Color("#ff0000")
    elif extrastar:
        $ColorRect.color = Color("#fff500")
    else:
        $ColorRect.color = Color("#584809")

func get_center():
    return $CenterContainer/Control/Pos.global_position

func connect_to(s):
    if not s in connects_to and not self in s.connects_to:
        connects_to.append(s)
        return true
    return false
    
func disconnect_square(s):
    if s in connects_to:
        connects_to.erase(s)


func _on_Button2_pressed():
    extrastar = !extrastar
