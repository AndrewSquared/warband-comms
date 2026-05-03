<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="WarbandComms" version="3.6.0" date="05/02/2026" >
		<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Author name="Mainline + Enlil"/>
		<Description text="Warband ability cooldown communication and tracker UI" />
		<Files>
			<File name="WarbandComms.lua" />
			<File name="WarbandComms.xml" />
			<File name="ui-template.xml" />
			<File name="config-template.xml" />
			<File name="config.xml" />
			<File name="tests.lua" />
			<File name="ability_cooldowns.lua" />
			<File name="config.lua" />
			<File name="ui.lua" />
			<File name="slash.lua" />
			<File name="utils.lua" />
			<File name="career-data.lua" />
		</Files>
		<OnInitialize>
			<CallFunction name="WarbandComms.OnInitialize" />
		</OnInitialize>
		<OnUpdate>
			<CallFunction name="WarbandComms.OnUpdate" />
    	</OnUpdate>
        <OnShutdown>
        </OnShutdown>
		<SavedVariables>
			<SavedVariable name="WarbandComms.Settings" />
		</SavedVariables>
	</UiMod>
</ModuleFile>