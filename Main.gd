extends CanvasLayer


var gridsize = Vector2(30,17)
export(PackedScene) var Square
export(PackedScene) var Line

var current = false

var text = ""
var roomoffset = Vector2.ZERO

func select_square(s):
    if current:
        if current != s:
            if current.connect_to(s):
                var line = Line.instance()
                add_child(line)
                line.set_line(current,s)
        else:
            if s.bluestar:
                s.bluestar = false
            else:
                for child in $Box/Grid.get_children():
                    child.bluestar = false
                s.bluestar = true
                
    current = s
    print_connections()
    for child in $Box/Grid.get_children():
        child.selected = false
    $Line2D.clear_points()
    $Line2D.add_point(s.get_center())
    $Line2D.add_point(get_viewport().get_mouse_position())

func _ready():
    for y in gridsize.y:
        for x in gridsize.x:
            var s = Square.instance()
            s.pos = Vector2(x,y)
            $Box/Grid.add_child(s)
            
func _process(delta):
    if Input.is_action_just_pressed("deselect"):
        current = false
        for child in $Box/Grid.get_children():
            child.selected = false
    if current:
        $Line2D.set_point_position(1, get_viewport().get_mouse_position())
        
    else:
        $Line2D.clear_points()
        

func print_connections():
    var index = 1
    var squares = []
    var stars = []
    var connects = []
    var bluestar = false
    for square in $Box/Grid.get_children():
        if len(square.connects_to) > 0:
            for to in square.connects_to:
                if not to in squares:
                    squares.append(to)
            if not square in squares:
                squares.append(square)
        if square.extrastar:
            if not square in squares:
                squares.append(square)
    for square in squares:
        if square.bluestar:
            bluestar = index
        stars.append(square.pos + Vector2(roomoffset.x*gridsize.x,roomoffset.y*gridsize.y))
        for to in square.connects_to:
            var toindex = squares.find(to) +1
            connects.append(Vector2(index,toindex))
        index += 1
    var starline = "stars={"
    for star in stars:
        starline += "{"+str(star.x)+","+str(star.y)+"},"
    starline += "},"
    var linesline = "lines={"
    for line in connects:
        linesline += "{"+str(line.x)+","+str(line.y)+"},"
    linesline += "},"
    print("--------------------")
    print(starline)
    print(linesline)
    text = starline + "\n" + linesline
    if bluestar:
        text += "\nbluestar=" + str(bluestar)+ ","
        print("bluestar=" + str(bluestar)+ ",")

func _on_Button_pressed():
    print_connections()
    OS.set_clipboard(text)


func _on_X_text_changed(new_text):
    if new_text.is_valid_integer():
        roomoffset.x = abs(int(new_text))-1
    else:
        $Box/HBoxContainer/Label3/X.text = ""


func _on_Y_text_changed(new_text):
    if new_text.is_valid_integer():
        roomoffset.y = abs(int(new_text))-1
    else:
        $Box/HBoxContainer/Label4/Y.text = ""


func _on_hidehelp_pressed():
    $Help.hide()


func _on_Help_pressed():
    $Help.show()
