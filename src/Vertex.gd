extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var vertices = [{"selected" : false, "pos" : Vector2(100, 100)}, {"selected" : false, "pos" : Vector2(200, 100)}, {"selected" : false, "pos" : Vector2(150, 200)}] setget updatevetex
var linedefs = [{"selected" : false, "start" : vertices[2], "end" : vertices[0]}, {"selected" : false, "start" : vertices[0], "end" : vertices[1]}, {"selected" : false, "start" : vertices[1], "end" : vertices[2]}]
var selLinedef = null

func sqr(x):
	return x * x
	
func dist2(a :Vector2,  b : Vector2):
	return sqr(a.x - b.x) + sqr(a.y - b.y)
	
func dist2LineSeg(p : Vector2, a : Vector2, b : Vector2):
	var l2 =dist2(a, b)
	if (l2 == 0 ):
		return dist2(p, a)
	var t = ((p.x - a.x) * (b.x - a.x) + (p.y - a.y) * (b.y - a.y)) / l2
	t = max(0, min(1, t))
	return dist2(p, \
		Vector2(a.x + t * (b.x - a.x), \
			a.y + t * (b.y - a.y) \
		)
	)
func updatevetex(a):
	print ("a" + str(a))


func _draw():
	var mpos = get_global_mouse_position()
#draw linedefs
	for linedef in linedefs:
		var midway = Vector2((linedef.start.pos.x + linedef.end.pos.x) / 2, (linedef.start.pos.y + linedef.end.pos.y) / 2)
		if linedef.selected:
			draw_line(linedef.start.pos, linedef.end.pos, Color(1, 1, 1), 2, true)
			draw_line(linedef.start.pos, linedef.end.pos, Color(1, 0, 0), 1, true)
			draw_line(midway, midway + \
			(Vector2(linedef.start.pos.y - linedef.end.pos.y, \
			- (linedef.start.pos.x - linedef.end.pos.x)).normalized()*40), Color(1, 1, 1), 1, true)
		else:
			draw_line(linedef.start.pos, linedef.end.pos, Color(1, 1, 1), 1, true)
			draw_line(midway, midway + \
			(Vector2(linedef.start.pos.y - linedef.end.pos.y, \
			- (linedef.start.pos.x - linedef.end.pos.x)).normalized()*40), Color(1, 1, 1), 1, true)


#	for i in range(vertices.size()):
#		draw_line(vertices[i].pos, vertices[i - 1].pos, Color(1, 1, 1), 1, true)
#		var midway = Vector2((vertices[i].pos.x + vertices[i - 1].pos.x) / 2, (vertices[i].pos.y + vertices[i - 1].pos.y) / 2)
#		draw_line(midway, midway + (Vector2(vertices[i -1].pos.y - vertices[i].pos.y, - (vertices[i - 1].pos.x - vertices[i].pos.x)).normalized()*40), Color(1, 1, 1), 1, true)

	for vertex in vertices:
		if vertex.selected :
			draw_circle(vertex.pos, 3, Color(1,1,1))
			draw_circle(vertex.pos, 2, Color(1,0,0))
		else :
			draw_circle(vertex.pos, 3, Color(1,1,1))
			draw_circle(vertex.pos, 2, Color(0.8,0.8,0))
			
		
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	var mpos = get_global_mouse_position()
	if event is InputEventMouseButton and event.is_pressed():
		#print("clicked")
		self.vertices.append({"selected" : false, "pos" : mpos})
		#print(verties)
		#update()
	else:
		#select vertex
		var sqrdist = INF 
		var selected= null
		for vertex in vertices:
			var newdist = pow(vertex.pos.x - mpos.x,2)  + pow(vertex.pos.y -mpos.y,2)
			vertex.selected=false
			if newdist < sqrdist:
				selected=vertex
				sqrdist=newdist
		selected.selected=true
		#select linedef
		sqrdist = INF 
		selected= null
		for linedef in linedefs:
			var newdist = dist2LineSeg(mpos, linedef.start.pos, linedef.end.pos)
			linedef.selected=false
			if newdist < sqrdist:
				selected=linedef
				sqrdist=newdist
		selected.selected=true


	update()
