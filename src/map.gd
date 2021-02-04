extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var POV = Vector2(0, 0)
var portal_colors = PoolColorArray([Color(0,0,1), Color(1,1,0)])
var portal_queue = Array()

var map = {
	"sectors" : [
		{
			"poly" : PoolVector2Array( [Vector2(0,0),Vector2(0,100), Vector2(100,100), Vector2(100,0)]),
			"tex": preload("res://WoodFloor041_1K_Color.jpg"),
			"tex_mat": Transform2D().scaled(Vector2(0.01, 0.01))
		},
		{
			"poly" : PoolVector2Array( [Vector2(0,0),Vector2(0,100), Vector2(100,100), Vector2(100,0)]),
			"tex": preload("res://Ground037_1K_Color.jpg"),
			"tex_mat": Transform2D().scaled(Vector2(0.01, 0.01))
		}
	],#end sectors
	"walls" : [
		
	],#end walls
	"portals": [
		{}
		
	]#end portals
}#end map

var sec2_points = PoolVector2Array( [Vector2(0,100),Vector2(0,150), Vector2(100,150), Vector2(100,100)] )
var sec2_tex = preload("res://Ground037_1K_Color.jpg")


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
func draw_sector(map_tran: Transform2D, sec_points: PoolVector2Array, tex, tex_mat: Transform2D):
	draw_colored_polygon(map_tran.xform(sec_points), Color(1.0, 1.0, 1.0),tex_mat.xform(sec_points), tex)	

########
# transform the map(mapID) by the transformation matrix(map_tran) and only drawing it in side the poligon (view_frustum)
func draw_map(mapID, map_tran: Transform2D, view_frustum: PoolVector2Array, additional_lines: Array, rec_lvl):
	#draw the floors of the sectors
	for sec in mapID.sectors:		
		draw_sector(map_tran, sec.poly, sec.tex, sec.tex_transform)
	#draw walls
	for wall in mapID.walls:
		var midway = Vector2((wall.start.pos.x + wall.end.pos.x) / 2, (wall.start.pos.y + wall.end.pos.y) / 2)
		draw_line(wall.start.pos, wall.end.pos, Color(1, 1, 1), 1, true)
		draw_line(midway, midway + \
			(Vector2(wall.start.pos.y - wall.end.pos.y, \
			- (wall.start.pos.x - wall.end.pos.x)).normalized()*40), Color(1, 1, 1), 1, true)

	#drawentity sprites
	
	##### process portals ####
	for portal in mapID.portals:
		if portal_is_in_frustrum:
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
					
			#draw other glow of portals
			draw_line(POV,portal_a_end, portal_colors[rec_lvl% (portal_colors.size+1)], 3.0, true)
			draw_line(POV,portal_b_end, portal_colors[rec_lvl% (portal_colors.size+1)], 3.0, true)
			#aply this maps transform to the portals tranform
			var origin = map_tran.x * portal.transform.origin.x + map_tran.y * portal.transform.origin.y + map_tran.origin
			var basis_x = map_tran.x * child.x.x + map_tran.y * portal.transform.x.y
			var basis_y = map_tran.x * portal.transform.y.x + map_tran.y * portal.transform.y.y

# Change the node's transform to what we just calculated.
transform = Transform2D(basis_x, basis_y, origin)
		#queue the portal for rendinging.
		portal_queue.append({
			"mapID" : portal.mapID,
			"lvl" : rec_lvl + 1,
			"line_a" : [portal.a, portal_a_end], 
			"line_b" : [portal.a, portal_b_end],
			"frustum" : Geometry.merge_polygons_2d(view_frustum, PoolVector2Array( []))
			"tran" : Transform2D(basis_x, basis_y, origin)

	#draw portal
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
	while not portal_queue.empty():
		portal = portal_queue.pop_front()
		draw_map(portal.mapID, portal.tran, frustum, [portal.line_a,portal, line_b], portal.lvl)
