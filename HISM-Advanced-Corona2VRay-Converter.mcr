/*  
[INFO] 

NAME = HISM Advanced Corona2VRay Converter
VERSION = 1.0.0
AUTHOR = MastaMan
DEV = https://3dground.net
HELP = 
CLIENT = HISM

[1.0.0]

* Initial release =

[ABOUT]

Script converts complex materials or MultiOutputChannelTexmapToTexmap to more simplier=

[SCRIPT]
*/	


macroScript HISM_Advanced_Corona2VRay_Converter
category:"[3DGROUND]"
toolTip:"Advanced Corona2VRay Converter"
buttontext:"Adv. Cr2Vr Conv."
(
	try(closeRolloutFloater fAdvancedCorona2VrayConverter) catch()
	global fAdvancedCorona2VrayConverter = newRolloutFloater "Advanced Corona2VRay Converter" 300 250
	global _rHAC2VC_Step0
	global _rHAC2VC_About

	rollout _rHAC2VC_Step0  "Main" (
		local __VRAY_TEXMAPS = #(
			#texmap_diffuse, 
			#texmap_reflection, 
			#texmap_refraction, 
			#texmap_bump, 
			#texmap_reflectionGlossiness, 
			#texmap_refractionGlossiness, 
			#texmap_refractionIOR, 
			#texmap_displacement, 
			#texmap_translucent, 
			#texmap_translucency_amount, 
			#texmap_environment, 
			#texmap_hilightGlossiness, 
			#texmap_reflectionIOR, 
			#texmap_opacity, 
			#texmap_roughness, 
			#texmap_anisotropy, 
			#texmap_anisotropy_rotation, 
			#texmap_refraction_fog, 
			#texmap_refraction_fog_depth, 
			#texmap_self_illumination, 
			#texmap_gtr_tail_falloff, 
			#texmap_metalness, 
			#texmap_sheen, 
			#texmap_sheen_glossiness, 
			#texmap_coat_color, 
			#texmap_coat_amount, 
			#texmap_coat_glossiness, 
			#texmap_coat_ior, 
			#texmap_coat_bump, 
			#texmap_thinFilm_thickness, 
			#texmap_thinFilm_ior
		)

		group "Remove CoronaColorCorrect" (
			button btnRemoveCoronaColorCorrect "Remove CoronaColorCorrect" width: 260 height: 35
		)
		
		fn removeMultiOutputChannel = (
			for m in getClassInstances VRayMtl do (
				for p in __VRAY_TEXMAPS do (
					local v = getProperty m p
					if (v == undefined or classOf v != MultiOutputChannelTexmapToTexmap) do continue
					local id = v.outputChannelIndex	
					if (id == undefined) do continue
					
					-- For Corona Color Correct
					if (classOf v.sourceMap == CoronaColorCorrect) do (				
						local t = case id of (
							1: v.sourceMap.inputTexmap
							default: v.sourceMap.additionalInputTexmap[id - 1]
						)	
						setProperty m p t				
					)				
				)
			)
			
			messageBox "Done!" title: "Success!"
		)
		
		on btnRemoveCoronaColorCorrect pressed do (
			removeMultiOutputChannel()
		)
	)

	rollout _rHAC2VC_About "About" 
	(
		label lblName "" align: #center
		label lblVer "" align: #center
		
		label lblAuthor "" height: 30 align: #center
		hyperlink lblCopy ""  align: #center
		
		fn getScriptInfo s releaseInfo: "" =  (
			if(releaseInfo != "") do
			(
				r = getINISetting s releaseInfo
				return r
			)
			
			v = getINISetting s "INFO" "VERSION"
			a = getINISetting s "INFO" "AUTHOR"
			n = getINISetting s "INFO" "NAME"
			o = getINISetting s "ABOUT"
			c = getINISetting s "INFO" "DEV"
			h = getINISetting s "INFO" "HELP"
			
			r = for i in (getINISetting s) where (i != "ABOUT" and i != "SCRIPT" and i != "COPY") collect i
			
			return #(n, a, v, o, r, c, h)
		)

		on _rHAC2VC_About open do
		(
			local i = getScriptInfo (getThisScriptFilename())
			
			lblName.caption = i[1]
			lblAuthor.caption = i[2]
			lblVer.caption = i[3]
			lblCopy.address  = lblCopy.caption = i[6]
		)
	)

	addRollout ::_rHAC2VC_Step0 ::fAdvancedCorona2VrayConverter rolledUp:false
	addRollout ::_rHAC2VC_About ::fAdvancedCorona2VrayConverter rolledUp:true
)	