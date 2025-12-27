// ammo boxes

/obj/item/ammo_magazine/packet
	name = "box of some kind of ammo"
	desc = "A packet containing some kind of ammo."
	icon = 'icons/obj/items/ammo/packet.dmi'
	icon_state_mini = "ammo_packet"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_magazine/packet/attack_hand_alternate(mob/living/user)
	. = ..()
	if(current_rounds <= 0)
		balloon_alert(user, "Empty")
		return
	create_handful(user)

/obj/item/ammo_magazine/packet/p10x24mm
	name = "box of 10x24mm FMJ"
	desc = "A box containing 150 rounds of 10x24mm caseless."
	caliber = CALIBER_10X24_CASELESS
	icon_state = "box_10x24mm"
	ammo_band_icon = "box_10x24mm_band"
	default_ammo = /datum/ammo/bullet/rifle
	current_rounds = 150
	max_rounds = 150

/obj/item/ammo_magazine/packet/p602x41
	name = "box of 6.02x41mm"
	desc = "A box containing 125 rounds of 6.02x41mm."
	caliber = CALIBER_602X41
	icon_state = "box_602x41"
	default_ammo = /datum/ammo/bullet/rifle/type16
	current_rounds = 125
	max_rounds = 125

/obj/item/ammo_magazine/packet/pnato
	name = "box of 5.56x45mm"
	desc = "A box containing 150 rounds of 5.56x45mm."
	caliber = CALIBER_556X45
	icon_state = "box_556mm"
	default_ammo = /datum/ammo/bullet/rifle
	current_rounds = 150
	max_rounds = 150

/obj/item/ammo_magazine/packet/p10x265mm
	name = "box of 10x26.5mm"
	desc = "A box containing 100 rounds of 10x26.5mm caseless."
	caliber = CALIBER_10X265_CASELESS
	icon_state = "box_10x265mm"
	default_ammo = /datum/ammo/bullet/rifle/br64
	current_rounds = 100
	max_rounds = 100

/obj/item/ammo_magazine/packet/p10x27mm
	name = "box of 10x27mm"
	desc = "A box containing 100 rounds of 10x27mm caseless."
	caliber = CALIBER_10X27_CASELESS
	icon_state = "box_10x27mm"
	default_ammo = /datum/ammo/bullet/rifle/dmr37
	current_rounds = 100
	max_rounds = 100

/obj/item/ammo_magazine/packet/p10x25mm
	name = "box of 10x25mm FMJ"
	desc = "A box containing 125 rounds of 10x25mm caseless."
	caliber = CALIBER_10X25_CASELESS
	icon_state = "box_10x25mm"
	ammo_band_icon = "box_10x25mm_band"
	default_ammo = /datum/ammo/bullet/rifle/heavy
	current_rounds = 125
	max_rounds = 125

/obj/item/ammo_magazine/packet/p492x34mm
	name = "box of 4.92x34mm"
	desc = "A box containing 210 rounds of 4.92x34mm caseless."
	caliber = CALIBER_492X34_CASELESS
	icon_state = "box_492x34mm"
	default_ammo = /datum/ammo/bullet/rifle/hv
	current_rounds = 210
	max_rounds = 210

/obj/item/ammo_magazine/packet/p86x70mm
	name = "box of 8.6x70mm"
	desc = "A box containing 50 rounds of 8.6x70mm caseless."
	caliber = CALIBER_86X70
	icon_state = "box_86x70mm"
	default_ammo = /datum/ammo/bullet/sniper/pfc
	current_rounds = 50
	max_rounds = 50

/obj/item/ammo_magazine/packet/smart_minigun
	name = "SG-85 ammo bin"
	desc = "A hefty container stuffed to the absolute brim with 500 rounds for the SG-85 powerpack."
	icon_state = "box_smartminigun"
	default_ammo = /datum/ammo/bullet/smart_minigun
	caliber = CALIBER_10X26_CASELESS
	current_rounds = 500
	max_rounds = 500

/obj/item/ammo_magazine/packet/scout_rifle
	name = "Box of A19 high velocity bullets"
	desc = "A box containing 150 rounds of A19 overpressured high velocity."
	icon_state = "box_tx8"
	default_ammo = /datum/ammo/bullet/rifle/tx8
	caliber = CALIBER_10X28_CASELESS
	current_rounds = 150
	max_rounds = 150

/obj/item/ammo_magazine/packet/scout_rifle/impact
	name = "Box of A19 high velocity impact bullets"
	desc = "A box containing 150 rounds of A19 impact high velocity."
	icon_state = "box_tx8_impact"
	default_ammo = /datum/ammo/bullet/rifle/tx8/impact

/obj/item/ammo_magazine/packet/scout_rifle/incendiary
	name = "Box of A19 high velocity incendiary bullets"
	desc = "A box containing 150 rounds of A19 incendiary high velocity."
	icon_state = "box_tx8_incendiary"
	default_ammo = /datum/ammo/bullet/rifle/tx8/incendiary

/obj/item/ammo_magazine/packet/sr81
	name = "box of low-pressure 8.6x70mm"
	desc = "A box containing 120 rounds of 8.6x70mm low velocity."
	icon_state = "box_t81"
	default_ammo = /datum/ammo/bullet/sniper/auto
	caliber = CALIBER_86X70
	current_rounds = 100
	max_rounds = 100

/obj/item/ammo_magazine/packet/standardautoshotgun
	name = "box of 16 Gauge shotgun slugs"
	desc = "A box containing 16 Gauge slugs, they look like they'd fit in the SH-15."
	icon_state = "box_16gslug"
	default_ammo = /datum/ammo/bullet/shotgun/sh15_slug
	caliber = CALIBER_16G
	current_rounds = 60
	max_rounds = 60

/obj/item/ammo_magazine/packet/standardautoshotgun/flechette
	name = "box of 16 Gauge shotgun flechette shells"
	desc = "A box containing 16 Gauge flechette shells, they look like they'd fit in the SH-15."
	icon_state = "box_16gflech"
	default_ammo = /datum/ammo/bullet/shotgun/sh15_flechette

// pistol packets

/obj/item/ammo_magazine/packet/p9mm
	name = "packet of 9mm"
	desc = "A packet containing 70 rounds of 9mm."
	caliber = CALIBER_9X19
	icon_state = "box_9mm"
	ammo_band_icon = "box_9mm_band"
	current_rounds = 70
	max_rounds = 70
	w_class = WEIGHT_CLASS_SMALL
	default_ammo = /datum/ammo/bullet/pistol

/obj/item/ammo_magazine/packet/magnum
	name = "packet of .44 magnum"
	desc = "A packet containing 49 rounds of .44 magnum."
	icon_state = "box_44mag" //Maybe change this
	default_ammo = /datum/ammo/bullet/revolver/r44
	caliber = CALIBER_44
	current_rounds = 49
	max_rounds = 49
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_magazine/packet/mateba
	name = "packet of .454 casull"
	desc = "A packet containing 42 rounds of .454 casull."
	icon_state = "box_454"
	default_ammo = /datum/ammo/bullet/revolver/highimpact
	caliber = CALIBER_454
	current_rounds = 42
	max_rounds = 42

/obj/item/ammo_magazine/packet/acp
	name = "box of pistol .45 ACP"
	desc = "A packet containing 50 rounds of pistol .45 ACP."
	icon_state = "box_.45acp"
	default_ammo = /datum/ammo/bullet/smg/acp
	caliber = CALIBER_45ACP
	current_rounds = 160
	max_rounds = 160

/obj/item/ammo_magazine/packet/rifle762x39
	name = "box of 7.62X39"
	desc = "A box containing 150 rounds of 7.62x39mm."
	icon_state = "box_7.62x39mm"
	default_ammo = /datum/ammo/bullet/rifle/mpi_km
	caliber = CALIBER_762X39
	current_rounds = 150
	max_rounds = 150

/obj/item/ammo_magazine/packet/svd762x54mmR
	name = "box of 7.62X54"
	icon_state = "box_7.62x54mm"
	default_ammo = /datum/ammo/bullet/sniper/svd
	caliber = CALIBER_762X54
	current_rounds = 50
	max_rounds = 50

/obj/item/ammo_magazine/packet/p9mm/incendiary
	name = "packet of 9mm incendiary"
	desc = "A packet containing 70 rounds of 9mm incendiary."
	ammo_band_color = AMMO_BAND_COLOR_INCENDIARY
	default_ammo = /datum/ammo/bullet/pistol/incendiary

/obj/item/ammo_magazine/packet/p10x26mm
	name = "packet of 10x26mm"
	desc = "A packet containing 100 rounds of 10x26mm caseless."
	icon_state = "box_10x26mm"
	caliber = CALIBER_10X26_CASELESS
	default_ammo = /datum/ammo/bullet/rifle/machinegun
	w_class = WEIGHT_CLASS_SMALL
	current_rounds = 100
	max_rounds = 100

/obj/item/ammo_magazine/packet/p10x20mm
	name = "packet of 10x20mm"
	desc = "A packet containing 125 rounds of 10x20mm caseless."
	icon_state = "box_10x20mm"
	caliber = CALIBER_10X20_CASELESS
	default_ammo = /datum/ammo/bullet/smg
	w_class = WEIGHT_CLASS_SMALL
	current_rounds = 150
	max_rounds = 150

/obj/item/ammo_magazine/packet/p4570
	name = "packet of .45-70"
	desc = "A packet containing 50 rounds of .45-70 Government."
	caliber = CALIBER_4570
	icon_state = "box_4570rim_mag"
	icon_state_mini = "ammo_packet_blue"
	default_ammo = /datum/ammo/bullet/rifle/repeater
	w_class = WEIGHT_CLASS_SMALL
	current_rounds = 50
	max_rounds = 50

/obj/item/ammo_magazine/packet/p380acp
	name = "packet of .380 ACP"
	desc = "A packet containing 210 rounds of .380 ACP."
	caliber = CALIBER_380ACP
	icon_state = "box_380acp"
	default_ammo = /datum/ammo/bullet/pistol/tiny/ap
	w_class = WEIGHT_CLASS_SMALL
	current_rounds = 210
	max_rounds = 210

/obj/item/ammo_magazine/packet/long_special
	name = "box of .44 Long Special"
	desc = "A packet containing 40 rounds of .44 Long Special."
	icon_state = "44LSbox"
	default_ammo = /datum/ammo/bullet/revolver/rifle
	caliber = CALIBER_44LS
	current_rounds = 40
	icon_state_mini = "44LSbox"
	max_rounds = 40

/obj/item/ammo_magazine/packet/t25
	name = "box of 10x26mm high-pressure"
	desc = "A box containing 300 rounds of 10x26mm 'HP' caseless tuned for a smartgun."
	icon_state = "box_t25"
	default_ammo = /datum/ammo/bullet/rifle/t25
	caliber = CALIBER_10X26_CASELESS
	current_rounds = 300
	max_rounds = 300

/obj/item/ammo_magazine/packet/acp_smg
	name = "box of .45 ACP HP"
	desc = "A box containing common .45 ACP hollow-point rounds."
	icon_state = "box_45acp"
	default_ammo = /datum/ammo/bullet/smg/acp
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_45ACP
	current_rounds = 120
	max_rounds = 120

/obj/item/ammo_magazine/packet/t500
	name = "packet of .500 Nigro Express"
	icon_state = "boxt500"
	default_ammo = /datum/ammo/bullet/revolver/t500
	caliber = CALIBER_500
	w_class = WEIGHT_CLASS_SMALL
	current_rounds = 50
	max_rounds = 50
	used_casings = 5

/obj/item/ammo_magazine/packet/t500/qk
	name = "packet of .500 'Queen Killer'"
	icon_state = "boxt500_qk"
	default_ammo = /datum/ammo/bullet/revolver/t500/qk

/obj/item/ammo_magazine/packet/t500/slavs
	name = "packet of .500 'Slavs'"
	icon_state = "boxt500_sv"
	default_ammo = /datum/ammo/bullet/revolver/t500/slavs

/obj/item/ammo_magazine/packet/t312
	name = "packet of .500 White Express"
	desc = "A box containing common .500 White Express rounds."
	icon_state = "boxt500_we"
	default_ammo = /datum/ammo/bullet/revolver/t312
	caliber = CALIBER_500_EMB
	w_class = WEIGHT_CLASS_SMALL
	current_rounds = 50
	max_rounds = 50
	used_casings = 5

/obj/item/ammo_magazine/packet/t312/Initialize(mapload)
	. = ..()
	if(prob(1))
		icon_state = "boxt500_ke"

/obj/item/ammo_magazine/packet/t312/med
	used_casings = 1

/obj/item/ammo_magazine/packet/t312/med/adrenaline
	name = "packet of .500 Adrenaline EMB"
	desc = "Contains adrenaline. These ammo have a stimulating effect on the patient's nervous system and heart, capable of saving a marine from a critical condition, and also allowing him to run longer than usual."
	icon_state = "boxt500_adr"
	default_ammo = /datum/ammo/bullet/revolver/t312/med/adrenaline

/obj/item/ammo_magazine/packet/t312/med/rr
	name = "packet of .500 Russian Red EMB"
	desc = "Contains 5 units of Russian Red. Use only when absolutely necessary. Heals a large amount of physical damage, but deals cloneloss damage."
	icon_state = "boxt500_rr"
	default_ammo = /datum/ammo/bullet/revolver/t312/med/rr

/obj/item/ammo_magazine/packet/t312/med/md
	name = "packet of .500 Meraderm EMB"
	desc = "The best EMB ammo that can heal multiple patient injuries without any side effects. Contains 2.5 units of Meralyne and 2.5 units of Dermaline."
	icon_state = "boxt500_md"
	default_ammo = /datum/ammo/bullet/revolver/t312/med/md

/obj/item/ammo_magazine/packet/t312/med/neu
	name = "packet of .500 Neuraline EMB"
	desc = "Contains 3.1 units of Neuraline and 1.9 Hyronalin. Warning: While the bullet is capable of taking a Marine out of critical condition, it will not neutralize all toxins from Neuraline."
	icon_state = "boxt500_neu"
	default_ammo = /datum/ammo/bullet/revolver/t312/med/neu

/obj/item/ammo_magazine/packet/standard_magnum
	name = "packet of .12x7mm"
	icon_state = "box_t76"
	default_ammo = /datum/ammo/bullet/revolver/t76
	caliber = CALIBER_12X7
	w_class = WEIGHT_CLASS_SMALL
	current_rounds = 50
	max_rounds = 50
	used_casings = 5

/obj/item/ammo_magazine/packet/p10x20mm/ap
	desc = "A packet containing 125 rounds of 10x20mm caseless."
	icon_state = "box_10x20mm_ap"
	default_ammo = /datum/ammo/bullet/smg/ap

/obj/item/ammo_magazine/packet/sg62
	name = "box of 10x27mm"
	desc = "A box containing 200 rounds of 10x27mm caseless."
	icon_state = "box_sg62"
	default_ammo = /datum/ammo/bullet/sg62
	caliber = CALIBER_10X27_CASELESS
	current_rounds = 200
	max_rounds = 200

/obj/item/ammo_magazine/packet/sg153
	name = "box of 12.7mm Smart Magnum"
	desc = "A box containing 25 rounds of 12.7mm spotting rifle rounds."
	icon_state = "sg153"
	default_ammo = /datum/ammo/bullet/sg153
	caliber = CALIBER_12X7
	current_rounds = 25
	max_rounds = 25

/obj/item/ammo_magazine/packet/musket
	name = "sack of musket lead rounds"
	desc = "A sack filled with lead bullets."
	icon_state = "musket_sack_m"
	default_ammo = /datum/ammo/bullet/sniper/musket
	max_rounds = 54
	caliber = CALIBER_19MM
	icon_state_mini = "musket_sack_m"

/obj/item/ammo_magazine/packet/musket/small
	name = "a small sack of musket lead rounds"
	desc = "A small sack filled with lead bullets."
	icon_state = "musket_sack_s"
	max_rounds = 27
	w_class = WEIGHT_CLASS_SMALL
	icon_state_mini = "musket_sack_s"
