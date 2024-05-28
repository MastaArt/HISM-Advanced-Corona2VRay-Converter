/*
	Simple Installer
	by MastaMan
	Installer file
	
	https://3dground.net/
*/

struct simpleInstallerManager (
	script = "HISM-Advanced-Corona2VRay-Converter.ms",
	buttonName = "Advanced Corona2VRay Converter",
	scriptName = substituteString (getFilenameFile script) "-" " ",
	macroName = substituteString scriptName " " "_",
	currScript = getThisScriptFileName(),
	currPath = getFilenamePath currScript,
	
	fn install = (
		local executeScript = currPath + script
		
		if (not doesFileExist executeScript) do return messageBox (scriptName + " not found!\nPlease download script from GitHub and try again!") title: "Error!"
		
		local n = "\n"
		local ex = "macroScript " + macroName + n
		ex += "category:\"[3DGROUND]\"" + n
		ex += "toolTip:\"" + buttonName + "\"" + n
		ex += "buttontext:\"" + buttonName + "\"" + n
		ex += "(" + n
		ex += "on execute do (" + n
		ex += "try(fileIn(@\"" + executeScript + "\")) catch(messageBox \"Script not found! Please reinstall " + scriptName + "!\" title: \"Error!\")" + n
		ex += ")" + n
		ex += ")" + n
		
		execute ex
		
		m = scriptName + " installed success!" + n
		m += "You can find it in [3DGROUND] category." + n + n
		
		messageBox m title: "Installed" beep: false
	),
	
	fn run = (
		install()
	)
)


(simpleInstallerManager()).run()