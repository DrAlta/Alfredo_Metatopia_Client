extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var POV = Vector2(0, 0)
var portal_colors = PoolColorArray([Color(0,0,1), Color(1,1,0)])
var portal_queue = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
########
# calculate the intercection of a ray start at ray_org and passing through ray2 with the line seggemt from line_a to line_b
func ray_lineseg_intersection(ray_org: Vector2, ray2: Vector2, line_a: Vector2, line_b:Vector2):
	var s1 = ray2 - ray_org
	var s2 = line_b - line_a

	var s = (-s1.y * (ray2.x - line_a.x) + s1.x * (ray_org.y - line_a.y)) / (-s2.x *s1.y + s1.x * s2.y)
	var t = (s2.x * (ray2.y - line_a.y) + s2.y * (ray_org.x - line_a.x)) / (-s2.x *s1.y + s1.x * s2.y)
	if (s >= 0 && s <= 1 && t >= 0 && t <= 1):
		return Vector2(ray_org.x + (t * s1.x), ray_org.y + (t * s1.y))
	else:
		return null

########
#Draw  a sector
func draw_sector(sec_points: PoolVector2Array, tex):
	var uvs = PoolVector2Array( [Vector2(0,0),Vector2(0,1), Vector2(1,1), Vector2(1,0)] )
	draw_colored_polygon(sec_points, Color(1.0, 1.0, 1.0),uvs, tex)	

########
# transform the map(mapID) by the transformation matrix(trans_mat) and only drawing it in side the poligon (view_frustum)
func draw_map(mapID, trans_mat: Transform2D, view_frustum: PoolVector2Array, additional_lines: Array, rec_lvl):
	#draw the floors of the sectors
	var sec1_points = PoolVector2Array( [Vector2(0,0),Vector2(0,100), Vector2(100,100), Vector2(100,0)] )
	var sec1_tex = preload("res://WoodFloor041_1K_Color.jpg")
	
	var sec2_points = PoolVector2Array( [Vector2(0,100),Vector2(0,150), Vector2(100,150), Vector2(100,100)] )
	var sec2_tex = preload("res://Ground037_1K_Color.jpg")
	draw_sector(sec1_points, sec1_tex)
	draw_sector(sec2_points, sec2_tex)
	#draw walls
	
	#drawentity sprites
	var visibile_portals = null
	# return a list of portals
	for portal in visibile_portals:
		
		#draw outter glow of portals
		var portal_a_end = portal.a
		var portal_b_end = portal.b
		#calculate the ends of the portal edges
		for frustum_edge in view_frustum:
			var test_a = ray_lineseg_intersection(POV, portal.a, frustum_edge.a, frustum_edge.b)
			var test_b = ray_lineseg_intersection(POV, portal.b, frustum_edge.a, frustum_edge.b)
			if (test_a != null):
				portal_a_end = test_a
			if (test_b != null):
				portal_b_end = test_b
				
		draw_line(POV,portal_a_end, portal_colors[rec_lvl% (portal_colors.size+1)], 3.0, true)
		draw_line(POV,portal_b_end, portal_colors[rec_lvl% (portal_colors.size+1)], 3.0, true)
		var new_frustum = Geometry.merge_polygons_2d(view_frustum, PoolVector2Array( []))

	#draw portals
	#??? draw the map on the other side of the portal but clipping it to the 
	#area in trapazoid made by the portal and the to lines from the POV to the 
	#corners of the portal 
	#
	#loop though the visable portals:
	#  1. draw think lines for the portals for the outer glow, and
	#  2. add the porta 
	
	
	

########
func _draw():
	#get the visible area of the veiwport and set the inital frustum to it.
	var mapID = null
	var frustum = PoolVector2Array([Vector2(0,0),Vector2(0,1), Vector2(1,1), Vector2(1,0)])
	draw_map(mapID, Transform2D(), frustum, {}, 0)
