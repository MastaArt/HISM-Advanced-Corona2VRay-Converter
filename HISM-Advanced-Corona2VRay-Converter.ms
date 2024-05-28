/*  
[INFO] 

NAME = HISM Advanced Corona2VRay Converter
VERSION = 1.0.1
AUTHOR = MastaMan
DEV = https://3dground.net
HELP = 
CLIENT = HISM

[1.0.0]
* Initial release =

[1.0.1]
+ Added: New installer=
+ Added: New type conversions=
* Changed: About section=
- BugFix: Small fixes=

[ABOUT]

Script converts complex materials or MultiOutputChannelTexmapToTexmap to more simplier=

[SCRIPT]
*/	

try(closeRolloutFloater fAdvancedCorona2VrayConverter) catch()
global fAdvancedCorona2VrayConverter = newRolloutFloater "Advanced Corona2VRay Converter" 300 300
global _rHAC2VC_Step0
global _rHAC2VC_About

rollout _rHAC2VC_Step0  "Convert To VRay" (
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

	group "MultiOutput Maps" (
		button btnRemoveCoronaColorCorrect "Remove CoronaColorCorrect" width: 260 height: 28
		button btnConvertCoronaTriplanar "Convert CoronaTriplanar" width: 260 height: 28
	)
	
	group "AO Maps" (
		button btnConvertCoronaAO "Convert CoronaAO" width: 260 height: 28
	)
	
	group "Randomizer Maps" (
		button btnConvertCoronaMappingRandomizer "Convert CoronaMappingRandomizer" width: 260 height: 28
	)
	
	fn processedMessage t p = (
		local m = (t as string) + ": " + (p as string)
		messageBox m title: "Scene processed!"
		return m
	)
	
	fn processCoronaMappingRandomizer = (
		local processed = 0
		
		for i in getClassInstances CoronaMappingRandomizer do (			
			if (i.input != undefined) do (
				local vbm = VRayBitmap()
				try (vbm.HDRIMapName = i.input.filename) catch ()
				local vuvwr = VRayUVWRandomizer()
				
				--vuvwr.mode_by_node_name = ????
				vuvwr.mode_by_face_id = i.randomizePolygon
				vuvwr.mode_by_render_id = i.randomizeMaterialGBuffer
				vuvwr.mode_by_element = i.randomizeMeshElement
				vuvwr.mode_by_instance_id = i.randomizeInstance
				vuvwr.mode_by_object_id = i.randomizeObjectGBuffer
				vuvwr.mode_by_uv_tile = i.randomizeTileId
				--vuvwr.mode_by_particle_id = ????
				vuvwr.mode_by_node_handle = i.randomizePrimitive
				vuvwr.seed = i.seed
				
				vuvwr.variance_u_min = i.offsetUfrom
				vuvwr.variance_u_max = i.offsetUto
				vuvwr.variance_u_step = i.offsetUstep
				
				vuvwr.variance_v_min = i.offsetVfrom
				vuvwr.variance_v_max = i.offsetVto
				vuvwr.variance_v_step = i.offsetVstep
				
				vuvwr.variance_rot_min = i.rotationUfrom
				vuvwr.variance_rot_max = i.rotationUto
				vuvwr.variance_rot_step = i.rotationUstep
				
				
				vuvwr.variance_uscale_min = i.scaleUfrom
				vuvwr.variance_uscale_max = i.scaleUto
				vuvwr.variance_uscale_step = i.scaleUstep
				
				vuvwr.variance_vscale_unlocked = not i.lockscale
				vuvwr.variance_vscale_min = i.scaleVfrom
				vuvwr.variance_vscale_max = i.scaleVto
				vuvwr.variance_vscale_step = i.scaleVstep
				
				vbm.mapSource = vuvwr
				
				replaceInstances i vbm
				
				processed += 1
			)
		)
		
		return processedMessage "CoronaMappingRandomizer" processed	
	)
		
	fn processCoronaAO = (
		local processed = 0
		
		for i in getClassInstances CoronaAO do (
			local d = VRayDirt()
			
			d.radius = i.maxDistance			
			d.occluded_color = i.colorOccluded			
			d.unoccluded_color = i.colorUnoccluded
			d.texmap_occluded_color = i.texmapOccluded			
			d.texmap_unoccluded_color = i.texmapUnoccluded			
			d.texmap_radius = i.texmapDistance
			
			case i.normalMode of (
				1: d.mode = 4
				2: d.mode = 5
				default: d.mode = 0
			)
			
			replaceInstances i d
			processed += 1
		)
		
		return processedMessage "CoronaAO" processed
	)
	
	fn processMultiOutputChannel type: #CoronaColorCorrect = (
		local processed = 0
		
		for m in getClassInstances VRayMtl do (
			local usedTriplanar = #()
			
			for p in __VRAY_TEXMAPS do (
				local v = getProperty m p
				if (v == undefined or classOf v != MultiOutputChannelTexmapToTexmap) do continue
				local id = v.outputChannelIndex	
				if (id == undefined) do continue
				
				-- For Corona Color Correct
				if (type == #CoronaColorCorrect and classOf v.sourceMap == CoronaColorCorrect) do (
					local t = case id of (
						1: v.sourceMap.inputTexmap
						default: v.sourceMap.additionalInputTexmap[id - 1]
					)	
					setProperty m p t
					
					processed += 1
				)	
				
				-- For Corona Triplanar
				if (type == #CoronaTriplanar and classOf v.sourceMap == CoronaTriplanar) do (
					local t = case id of (
						1: #(v.sourceMap.texmapX, v.sourceMap.texmapY, v.sourceMap.texmapZ)
						default: #(v.sourceMap.additionalTexmapX[id - 1], v.sourceMap.additionalTexmapy[id - 1], v.sourceMap.additionalTexmapZ[id - 1])
					)	
					
					if (usedTriplanar[id] != undefined) then (
						setProperty m p usedTriplanar[id]
					) else (
						local vtp = VRayTriplanarTex()
						vtp.texture = t[1]
						vtp.texture_y = t[2]
						vtp.texture_z = t[3]
						
						setProperty m p vtp
						usedTriplanar[id] = vtp
					)
					
					processed += 1					
				)			
			)
		)
		
		return processedMessage type processed
	)
	
	on btnRemoveCoronaColorCorrect pressed do (
		processMultiOutputChannel type: #CoronaColorCorrect
	)
	
	on btnConvertCoronaTriplanar pressed do (
		processMultiOutputChannel type: #CoronaTriplanar
	)
	
	on btnConvertCoronaAO pressed do (
		processCoronaAO()
	)
	
	on btnConvertCoronaMappingRandomizer pressed do (
		processCoronaMappingRandomizer()
	)
)

rollout _rHAC2VC_About "About" (
	label lblDummy1 ""
    
	label lblName "" 
	label lblVer ""
	label lblClient ""
	
	label lblDummy2 ""
	
	label lblAuthor ""
	hyperlink lblCopy ""  align: #center
	
	label lblDummy3 ""
	
	group "Description" (
		dotNetControl edtDescription "System.Windows.Forms.Textbox" align:#center height: 300
	)
	
	
	timer tmrRestart "" active: false interval: 300
	    
	fn downloadFile url dl = (
		deleteFile dl
		w = dotNetObject "System.Net.WebClient"			
		try(
			spm = dotNetClass "System.Net.ServicePointManager"
			spm.SecurityProtocol = spm.SecurityProtocol.TLS12				
			w.DownloadFile (url + "?time=" + timestamp() as string) dl				
		) catch(
			return false
		)
		
		return true
	)
	
	fn bgUpdate = (
		local url = "raw_url"
		
		local files = #(
			"file1.ms",
			"Install.mcr"
		)
		
		this = getThisScriptFileName()
		dl = this + ".tmp"
		p = getFilenamePath this
		r = downloadFile (url + files[1]) dl
		if(not r or not doesFileExist dl) do return print "Can't download updates!"
		vn = getIniSetting dl "INFO" "VERSION"
		vo = getIniSetting this "INFO" "VERSION"
		
		if(vn > vo) do (
			deleteFile this
			renameFile dl this
			
			for f in files do (				
				downloadFile (url + f) (p + f)
			)
			
			tmrRestart.active = true
		)
		
		deleteFile dl
	)
	
	fn updateWorker = (
		m = dotnetobject "CSharpUtilities.SynchronizingBackgroundWorker"
		m.WorkerSupportsCancellation = true 
		m.CancelAsync() 
		dotNet.addEventHandler m "DoWork" bgUpdate
		m.RunWorkerAsync()	
	)
	
    fn getScriptInfo s releaseInfo: "" =  (
        if(releaseInfo != "") do (
            local r = getINISetting s releaseInfo
            return r
        )
		
        local v = getINISetting s "INFO" "VERSION"
        local a = getINISetting s "INFO" "AUTHOR"
        local n = getINISetting s "INFO" "NAME"
        local o = ""
		for i in (getINISetting s "ABOUT") do o += i + "\r\n"
        local d = getINISetting s "INFO" "DEV"
        local h = getINISetting s "INFO" "HELP"
        local c = getINISetting s "INFO" "CLIENT"
        
		struct data (version, author, name, description, developer, client, help, releases)
		
        local r = for i in (getINISetting s) where (i != "INFO" and i != "ABOUT" and i != "SCRIPT" and i != "COPY") collect i
		
		return (data version: v author: a name: n description: o developer: d client: c help: h releases: r)
    )
	
	on tmrRestart tick do (
		this = getThisScriptFileName()
		try(fileIn this) catch()
		vo = getIniSetting this "INFO" "VERSION"
		m = ("Script updated to version " + vo + "!\n\n\n")
		for c in (getIniSetting this vo) do (
			m += c + "\n"
		)
		
		messageBox m title: "Success!" beep: false
		tmrRestart.active = false
	)

    on _rHAC2VC_About open do (
		edtDescription.MultiLine = true
		edtDescription.WordWrap = true
		edtDescription.ReadOnly = true
		edtDescription.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
		edtDescription.ScrollBars = (dotNetClass "System.Windows.Forms.ScrollBars").Vertical
		
		local thisScript = getThisScriptFilename()
        local i = getScriptInfo thisScript
		
        lblName.caption = i.name
        lblAuthor.caption = i.author
        lblVer.caption = i.version
        lblCopy.address = lblCopy.caption = i.developer
        lblClient.caption = i.client
		edtDescription.text = i.description
			
			
		local releaseNotes = ""	
		for ii in i.releases.count to 1 by -1 do (
			local v = i.releases[ii]
			local r = getScriptInfo thisScript releaseInfo: v
			
			releaseNotes += "\r\n" + v + "\r\n"
			for j in r do releaseNotes += j + "\r\n"
		)
		
		edtDescription.text += releaseNotes
		
		try (fAdvancedCorona2VrayConverter.title = i.name + " v" +  i.version) catch()
		
		--updateWorker()
    )		
)


addRollout ::_rHAC2VC_Step0 ::fAdvancedCorona2VrayConverter rolledUp:false
addRollout ::_rHAC2VC_About ::fAdvancedCorona2VrayConverter rolledUp:true
