extends Node
class Vertex:
	var selected
	var pos

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func findRightMostVertex(sides, ignores):
	var found = null
	for line in sides:
		#first found?
		if((found == null) and !ignores.has(line.start)):
			found = line.start
		if((found == null) and !ignores.has(line.end)):
			found = line.end
		
		if(found != null):
			#Check if more to the right than the previous found
			if(line.start.pos.x > found.pos.x) and !ignores.has(line.start):
				found = line.start
			if(line.end.pos.x > found.pos.x) and !ignores.has(line.end):
				found = line.end
			
func doTracePath(history, fromhere, findme, sector, sides):
	var nextpath
	var result
	var nextvertex
	var allsides
	
	#found the vertec we are tracing to?
	if(fromhere == findme):
		return history
		
	#on the first run is null (otherwise the trace would end immeditely when it starts) Se set findme o the first run
	if(findme == null):
		findme == fromhere
	#Make a list of sides referring to the same sector
	
func doTrace(selectedLines):
	var todosides = {}
	var ignores={}
	var root
	var path
	var newpoly
	var start
	for line in selectedLines:
		todosides[line]=false
	#contiue until all lines have been processed
	while (todosides.size() > 0):
		#reset all visited indicators
		for line in selectedLines:
			if todosides.has(line):
				todosides[line]=false
		#Find the right-most vertex to start a trace with.
		#This guarantee's that we start out with an outer polygon and we just
		#have to check if it is inside a previously found polygon.
		start = findRightMostVertex(todosides, ignores)
		
		#no more possible start vert found?
		#then leave with what we have up till now
		if start == null:
			break
		
		path = doTrace
		
# Called when the node enters the scene tree for the first time.
func _ready():
	doTrace([{"Start":{"pos":Vector2(0,0)},"end":{"pos":Vector2(1,0)}},
			 {"Start":{"pos":Vector2(1,0)},"end":{"pos":Vector2(1,1)}},
			 {"Start":{"pos":Vector2(1,1)},"end":{"pos":Vector2(0,0)}}])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

