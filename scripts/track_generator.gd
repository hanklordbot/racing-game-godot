extends Node3D

@export var radius_x := 60.0
@export var radius_z := 35.0
@export var road_width := 10.0
@export var wall_height := 2.0
@export var segments := 64

func _ready() -> void:
	_generate_road()
	_generate_walls()
	_generate_center_line()
	_generate_start_line()

func _generate_road() -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in segments:
		var a0 = TAU * i / float(segments)
		var a1 = TAU * (i + 1) / float(segments)
		var inner0 = Vector3(cos(a0) * (radius_x - road_width/2), 0, sin(a0) * (radius_z - road_width/2))
		var outer0 = Vector3(cos(a0) * (radius_x + road_width/2), 0, sin(a0) * (radius_z + road_width/2))
		var inner1 = Vector3(cos(a1) * (radius_x - road_width/2), 0, sin(a1) * (radius_z - road_width/2))
		var outer1 = Vector3(cos(a1) * (radius_x + road_width/2), 0, sin(a1) * (radius_z + road_width/2))
		st.set_normal(Vector3.UP)
		st.add_vertex(inner0); st.add_vertex(outer0); st.add_vertex(inner1)
		st.add_vertex(outer0); st.add_vertex(outer1); st.add_vertex(inner1)
	var mesh = st.commit()
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.name = "Road"
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.3, 0.35)
	mi.material_override = mat
	add_child(mi)
	# Road collision
	var sb = StaticBody3D.new()
	sb.name = "RoadBody"
	var cs = CollisionShape3D.new()
	cs.shape = mesh.create_trimesh_shape()
	sb.add_child(cs)
	add_child(sb)

func _generate_walls() -> void:
	_make_wall("OuterWall", road_width / 2.0)
	_make_wall("InnerWall", -road_width / 2.0)

func _make_wall(wall_name: String, offset: float) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in segments:
		var a0 = TAU * i / float(segments)
		var a1 = TAU * (i + 1) / float(segments)
		var rx = radius_x + offset
		var rz = radius_z + offset
		var p0 = Vector3(cos(a0) * rx, 0, sin(a0) * rz)
		var p1 = Vector3(cos(a1) * rx, 0, sin(a1) * rz)
		var p0t = p0 + Vector3.UP * wall_height
		var p1t = p1 + Vector3.UP * wall_height
		var n = (p0 - Vector3(cos(a0) * radius_x, 0, sin(a0) * radius_z)).normalized()
		if offset < 0: n = -n
		st.set_normal(n)
		st.add_vertex(p0); st.add_vertex(p1); st.add_vertex(p0t)
		st.add_vertex(p1); st.add_vertex(p1t); st.add_vertex(p0t)
	var mesh = st.commit()
	var mi = MeshInstance3D.new()
	mi.mesh = mesh; mi.name = wall_name
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.15, 0.15) if "Outer" in wall_name else Color(0.15, 0.15, 0.6)
	mi.material_override = mat
	add_child(mi)
	var sb = StaticBody3D.new()
	sb.name = wall_name + "Body"
	var cs = CollisionShape3D.new()
	cs.shape = mesh.create_trimesh_shape()
	sb.add_child(cs)
	add_child(sb)

func _generate_center_line() -> void:
	var path = Path3D.new()
	path.name = "CenterLine"
	var curve = Curve3D.new()
	for i in segments:
		var a = TAU * i / float(segments)
		curve.add_point(Vector3(cos(a) * radius_x, 0.1, sin(a) * radius_z))
	path.curve = curve
	add_child(path)

func _generate_start_line() -> void:
	var mi = MeshInstance3D.new()
	mi.name = "StartLine"
	var mesh = BoxMesh.new()
	mesh.size = Vector3(road_width, 0.05, 1.0)
	mi.mesh = mesh
	mi.position = Vector3(radius_x, 0.01, 0)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.WHITE
	mi.material_override = mat
	add_child(mi)
