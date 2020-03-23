

workspace("test")
	architecture "x64"
	language "C++"
	cppdialect "C++17"
	intrinsics "on"
	systemversion "latest"
	staticruntime "off"
	

	configurations
	{
		"Debug",
		"Release",
	}

	project "Hazel"
		kind "ConsoleApp"

		files
		{
			"src/**"
		}
