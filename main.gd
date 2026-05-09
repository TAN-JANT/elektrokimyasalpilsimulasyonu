extends Node2D

const potansiyel = {
	"Cu" : 0.34,
	"Zn" : -0.76,
	"Ag" : 0.80,    
	"H(Pt)" : 0.00,

	"Fe" : -0.44,
	"Al" : -1.66,
	"Pb" : -0.13,
	"Ni" : -0.25,
	"Au" : 1.50,
}

const degerlik = {
	"CuSO4" : 2,
	"ZnSO4" : 2,
	"AgNO3" : 1,
	"HCl"   : 1,

	"FeSO4" : 2,
	"Fe2(SO4)3" : 3,
	"Al2(SO4)3" : 3,
	"Pb(NO3)2" : 2,
	"NiSO4" : 2,
	"AuCl3" : 3
}

const cozelti = {
	"CuSO4" : "Cu",
	"ZnSO4" : "Zn",
	"AgNO3" : "Ag",
	"HCl"   : "H(Pt)",

	"FeSO4" : "Fe",
	"Fe2(SO4)3" : "Fe",
	"Al2(SO4)3" : "Al",
	"Pb(NO3)2" : "Pb",
	"NiSO4" : "Ni",
	"AuCl3" : "Au"
}

var pil_voltajları = []

var simulasyon = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func beher_ekle() -> void:
	var beher = preload("res://beher.tscn").instantiate()
	beher.setup_solution_dialog(cozelti.keys())
	$Entities.add_child(beher)


func _on_button_2_pressed() -> void:
	$Entities.add_child(preload("res://tuz_koprusu.tscn").instantiate())
	


func _on_button_3_pressed() -> void:
	var elektrot = preload("res://elektrot.tscn").instantiate()
	elektrot.setup_electrode_dialog(potansiyel.keys())
	$Entities.add_child(elektrot)


func _on_button_6_pressed() -> void:
	if simulasyon:
		simulasyon = false
		for c in $Entities.get_children():
			if c.is_in_group("Elektrot"):
				c.get_child(4).text = ""
			if c.is_in_group("Tuz_Koprusu"):
				c.get_child(6).text = ""
		return
	var elektrotlar = []
	var kablolar    = []
	simulasyon = true
	for c in $Entities.get_children():
		if c.is_in_group("Elektrot"):
			elektrotlar.append(c)
		if c.is_in_group("Kablo"):
			kablolar.append(c)
		
	print(elektrotlar)
	var indx = 0
	for e in elektrotlar:
		var b1 = null
		var e1 = null
		var b2 = null
		var e2 = null
		var tuz = null
		e1 = e
		var _n = e.elektrot_beherdemi()
		if _n != null:
			b1 = _n
		else:
			continue
		if b1 != null:
			tuz = b1.tuz_koprusu_varmi()
		else:
			continue
		_n = tuz.diger_beheri_ara(b1)
		if  _n != null:
			b2 = _n
		else:
			continue
		if b2 != null:
			e2 = b2.elektrot_varmi()
		else:
			continue
		if (b1 != null) and (b2 != null) and (tuz != null) and (e2 != null):
			var E0 = max(potansiyel[e1.electrode],potansiyel[e2.electrode]) - min(potansiyel[e1.electrode],potansiyel[e2.electrode])
			var Ep = 0
			print(e1.electrode)
			print(e2.electrode)
			print("E0:",E0)
			var n = ekok(degerlik[b1.solution_type],degerlik[b2.solution_type])
			if cozelti[b1.solution_type]  != e1.electrode or cozelti[b2.solution_type]  != e2.electrode:
				Ep = 0
				continue
			var giren_molar = 0
			var urun_molar = 0
			if E0 == 0:
				#
				giren_molar = max(pow(b1.molarity,n/degerlik[b1.solution_type]),pow(b2.molarity,n/degerlik[b2.solution_type]))
				urun_molar = min(pow(b1.molarity,n/degerlik[b1.solution_type]),pow(b2.molarity,n/degerlik[b2.solution_type]))
				var w = pow(b1.molarity,n/degerlik[b1.solution_type])
				var m = pow(b2.molarity,n/degerlik[b2.solution_type])
				if  w > m:
					e1.get_child(4).text = "katot"
					e2.get_child(4).text = "anot"
				else:
					e1.get_child(4).text = "anot"
					e2.get_child(4).text = "katot"
			else: 
				if potansiyel[e1.electrode] > potansiyel[e2.electrode]:
					#
					urun_molar = pow(b2.molarity,n/degerlik[b2.solution_type])
					giren_molar = pow(b1.molarity,n/degerlik[b1.solution_type])
					e1.pozitif_uc = false
					e1.pil_numara = indx
					e2.get_child(4).text = "anot"
					e2.pozitif_uc = true
					e1.get_child(4).text = "katot"
					e2.pil_numara = indx
					indx += 1
				else:
					#
					urun_molar = pow(b1.molarity,n/degerlik[b1.solution_type])
					giren_molar = pow(b2.molarity,n/degerlik[b2.solution_type])
					e1.pozitif_uc = true
					e1.pil_numara = indx
					e2.get_child(4).text = "katot"
					e2.pozitif_uc = false
					e1.get_child(4).text = "anot"
					e2.pil_numara = indx
					indx += 1
			print(n)
			print(urun_molar)
			print(giren_molar)
			print(log(urun_molar/giren_molar))
			Ep = E0 - (0.0592 / n) * (log(urun_molar/giren_molar) / log(10))
			tuz.get_child(6).text = str(abs(Ep)).substr(0,5) + "V"
			print(Ep)
			
		if e2 != null:
			elektrotlar.erase(e2)
		else:
			continue
	

		
			
func ebob(a,b):
	var temp
	while b != 0:
		temp = b
		b = a % b
		a = temp
	return temp

func ekok(a,b):
	return a*b / ebob(a,b)


func _on_button_4_pressed() -> void:
	if $CanvasLayer.scale.y == 1:
		$CanvasLayer.scale.y = 2 
		return 
	$CanvasLayer.scale.y = 1 
	
