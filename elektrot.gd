extends CharacterBody2D

var dragging := false
var popup
var offset = Vector2.ZERO

var electrode_dialog
var electrode := "Zn"
var pil_numara = -1
var pozitif_uc = null


func setup_electrode_dialog(list: Array) -> void:
	electrode_dialog = AcceptDialog.new()
	electrode_dialog.title = "Elektrot Seç"

	var option_button := OptionButton.new()

	for s in list:
		option_button.add_item(s)

	electrode_dialog.add_child(option_button)
	electrode_dialog.confirmed.connect(
		_on_electrode_selected.bind(option_button)
	)

	add_child(electrode_dialog)

func _ready():
	collision_layer = 1
	collision_mask = 1
	modulate = Color.hex(0x7f8c8dFF)   # Gri - Çinko
	$Elektrot.text = "Zn"
	# Area2D input event
	$UI.connect("input_event", _on_interaction_input)
	
	# Popup menü
	popup = PopupMenu.new()
	popup.add_item("Nesneyi Sil", 0)
	popup.add_item("Elektrot Seç", 1)
	popup.connect("id_pressed", _on_popup_item_selected)
	add_child(popup)
	



func _on_interaction_input(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			# sadece sol tuş ile drag başlasın
			dragging = true
			offset = get_global_mouse_position() - global_position
		else:
			if dragging:
				dragging = false
				# tıklamayı bırakınca popup aç
				popup.position = event.global_position
				popup.popup()


func _physics_process(delta):
	if dragging:
		var target = get_global_mouse_position() - offset
		var motion = target - global_position
		move_and_collide(motion)


func _on_popup_item_selected(id):
	match id:
		0:
			queue_free()  # nesneyi sil
		1:
			electrode_dialog.popup_centered()  # Elektrot tipi seç

func _on_electrode_selected(option_button):
	electrode = option_button.get_item_text(option_button.get_selected())
	print("Elektrot seçildi:", electrode)
	$Elektrot.text = electrode  # sahnede varsa bir Label veya benzeri
	if electrode == "H(Pt)":
		$Sprite2D.frame = 4
		modulate = Color.WHITE
		return
		
	var electrode_colors = {
		"Zn" : Color.hex(0x7f8c8dFF),
		"Cu" : Color.hex(0xb87333FF),
		"Ag" : Color.hex(0xc0c0c0FF),
		"Fe" : Color.hex(0x6b6b6bFF),
		"Al" : Color.hex(0xbdc3c7FF),
		"Pb" : Color.hex(0x5d6d7eFF),
		"Ni" : Color.hex(0x95a5a6FF),
		"Au" : Color.hex(0xffd700FF)
	}
	$Sprite2D.frame = 3
	modulate = electrode_colors[electrode]
		
			
		

func elektrot_beherdemi():
	var beher = null 
	for i in $Object_Interact.get_overlapping_areas():
		
		if i.get_parent().is_in_group("Beher"):
			assert(beher == null,"Elektrotu nasıl iki behere batırdın?")
			beher = i.get_parent()
		
	return beher
