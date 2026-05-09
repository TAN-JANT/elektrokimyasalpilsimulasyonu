extends Line2D

var dragging_uc1 = false
var dragging_uc2 = false
var offset_uc1 : Vector2
var offset_uc2 : Vector2
const SEGMENT_COUNT := 32  # eğrinin pürüzsüzlüğü

func _ready() -> void:
	$Uc1.connect("input_event", _on_interaction_uc1)
	$Uc2.connect("input_event", _on_interaction_uc2)
	
	points = []  # boşalt
	update_curve()
func _on_interaction_uc1(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			if Global.aktif_uc == null or Global.aktif_uc == self:
				Global.aktif_uc = self
				dragging_uc1 = true
				offset_uc1 = $Uc1.get_global_mouse_position() - $Uc1.global_position
		else:
			dragging_uc1 = false
			if not dragging_uc2:
				Global.aktif_uc = null

func _on_interaction_uc2(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			if Global.aktif_uc == null:
				Global.aktif_uc = self
				dragging_uc2 = true
				offset_uc2 = $Uc2.get_global_mouse_position() - $Uc2.global_position
		else:
			dragging_uc2 = false
			if not dragging_uc1:
				Global.aktif_uc = null



func _physics_process(delta):
	if dragging_uc1:
		var target1 = $Uc1.get_global_mouse_position() - offset_uc1
		$Uc1.global_position = target1
		update_curve()

	if dragging_uc2:
		var target2 = $Uc2.get_global_mouse_position() - offset_uc2
		$Uc2.global_position = target2
		update_curve()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_curve():
	var p0 = $Uc1.global_position
	var p3 = $Uc2.global_position
	
	# kontrol noktalarını hesapla
	var dx = abs(p3.x - p0.x)
	var p1 = p0 + Vector2(dx * 0.5, 0)
	var p2 = p3 - Vector2(dx * 0.5, 0)
	
	clear_points()
	for i in range(SEGMENT_COUNT + 1):
		var t = float(i) / SEGMENT_COUNT
		var pos = cubic_bezier(p0, p1, p2, p3, t)
		add_point(pos)


func cubic_bezier(p0, p1, p2, p3, t):
	var inv = 1.0 - t
	return inv * inv * inv * p0 \
		+ 3.0 * inv * inv * t * p1 \
		+ 3.0 * inv * t * t * p2 \
		+ t * t * t * p3

func baglıları_bul():
	
	if len($Uc1.get_overlapping_areas()) > 1:
		push_error("Uçlara sadece tek bir şey bağla")
	
	if len($Uc2.get_overlapping_areas()) > 1:
		push_error("Uçlara sadece tek bir şey bağla")
	
	return [$Uc1.get_overlapping_areas()[0],$Uc2.get_overlapping_areas()[0]]
	 
	
