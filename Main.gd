extends CanvasLayer


var gridsize = Vector2(30,17)
export(PackedScene) var Square
export(PackedScene) var Line

var current = false

var text = ""
var roomoffset = Vector2.ZERO

func select_square(s):
    if current:
        connect_square(current, s)   
    current = s
    print_connections()
    for child in $Box/Grid.get_children():
        child.selected = false
    $Line2D.clear_points()
    $Line2D.add_point(s.get_center())
    $Line2D.add_point(get_viewport().get_mouse_position())


func connect_square(f,t):
    if f != t:
        if f.connect_to(t):
            var line = Line.instance()
            add_child(line)
            line.set_line(f,t)
    else:
        if t.bluestar:
            t.bluestar = false
        else:
            for child in $Box/Grid.get_children():
                child.bluestar = false
            t.bluestar = true 

    

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
    $CanvasLayer/Help.hide()


func _on_Help_pressed():
    $CanvasLayer/Help.show()


func _on_Back_pressed():
    $Import.hide()


func _on_DoImport_pressed():
    var import = $Import/HBoxContainer/Label3/Import.text
    import = "{ " + import.replace('stars', '"stars": ').replace('bluestar', '"bluestar": ').replace('offset', '"offset": ').replace('lines', '"lines": ').replace("=","").replace("{","[").replace("}","]") + " }"
    var parsed = JSON.parse(import).result
    var lines = []
    if "lines" in parsed.keys():
        lines = parsed["lines"]
    var star_offset = Vector2.ZERO
    if "offset" in parsed.keys():
        star_offset = Vector2(parsed["offset"][0],parsed["offset"][1])
    var squares = []
    var roffset = Vector2.ZERO
    if "stars" in parsed.keys():
        var stars = parsed["stars"]
        if len(stars) > 0:
            roffset.x = floor(stars[0][0]/gridsize.x)
            roffset.y = floor(stars[0][1]/gridsize.y)
            $Box/HBoxContainer/Label3/X.text = str(roffset.x + 1)
            $Box/HBoxContainer/Label4/Y.text = str(roffset.y + 1)
            roomoffset = roffset
        for star in stars:
            star[0] -= roffset.x*gridsize.x+star_offset.x
            star[1] -= roffset.y*gridsize.y+star_offset.y
            for square in $Box/Grid.get_children():
                if square.pos == Vector2(star[0],star[1]):
                    squares.append(square)
                    break
        
        for i in len(stars):
            var extra = true
            for line in lines:
                for val in line:
                    if i == val-1:
                        extra = false
                    if not extra:
                        break
                if not extra:
                    break
            if extra:
                squares[i].extrastar = true   
        for line in lines:
            var from = line[0]-1
            var to = line[1]-1
            connect_square(squares[from], squares[to])
            
    if "bluestar" in parsed.keys():
        var b = parsed["bluestar"]-1
        connect_square(squares[b], squares[b])
    $Import/HBoxContainer/Label3/Import.text = ""
    $Import.hide()
                        
                    

func _on_Import_pressed():
    $Import.show()
