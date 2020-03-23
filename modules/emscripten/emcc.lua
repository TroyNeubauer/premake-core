--Copied from the emcc premake lua file: 
--https://github.com/premake/premake-core/blob/5354556d99f90f89bcc249a01447c664aeac2f02/src/tools/emcc.lua
print("beginning emcc")
include("src/tools/clang.lua")

local p = premake

p.tools.emcc = {}
local emcc = p.tools.emcc
local clang = p.tools.clang
local config = p.config


--
-- Build a list of flags for the C preprocessor corresponding to the
-- settings in a particular project configuration.
--
-- @param cfg
--    The project configuration.
-- @return
--    An array of C preprocessor flags.
--

function emcc.getcppflags(cfg)

	-- Just pass through to clang for now
	local flags = clang.getcppflags(cfg)
	return flags

end


--
-- Build a list of C compiler flags corresponding to the settings in
-- a particular project configuration. These flags are exclusive
-- of the C++ compiler flags, there is no overlap.
--
-- @param cfg
--    The project configuration.
-- @return
--    An array of C compiler flags.
--

emcc.shared = {
	architecture = {
		x86 = "-m32",
		x86_64 = "-m32",--Always use m32 since webassembly is a 32 bit standard
	},
	flags = clang.shared.flags,
	floatingpoint = {
		Fast = "-ffast-math",
	},
	strictaliasing = clang.shared.strictaliasing,
	optimize = {
		Off = "-O0",
		On = "-O2",
		Debug = "-O0",
		Full = "-O3",
		Size = "-Os",
		Speed = "-O3",
	},
	pic = {
		On = "",--No PIC
	},
	vectorextensions = clang.shared.vectorextensions,
	isaextensions = clang.shared.isaextensions,
	warnings = clang.shared.warnings,
	symbols = clang.shared.symbols,
	unsignedchar = clang.shared.unsignedchar,
	omitframepointer = clang.shared.omitframepointer
}

emcc.cflags = table.merge(clang.cflags, {
})


function emcc.getcflags(cfg)
	local shared = config.mapFlags(cfg, emcc.shared)
	local cflags = config.mapFlags(cfg, emcc.cflags)

	local flags = table.join(shared, cflags)
	flags = table.join(flags, emcc.getwarnings(cfg))
	
	return flags
end

function emcc.getwarnings(cfg)
	return clang.getwarnings(cfg)
end


--
-- Build a list of C++ compiler flags corresponding to the settings
-- in a particular project configuration. These flags are exclusive
-- of the C compiler flags, there is no overlap.
--
-- @param cfg
--    The project configuration.
-- @return
--    An array of C++ compiler flags.
--

emcc.cxxflags = table.merge(clang.cxxflags, {
})


function emcc.getcxxflags(cfg)
	local shared = config.mapFlags(cfg, emcc.shared)
	local cxxflags = config.mapFlags(cfg, emcc.cxxflags)
	local flags = table.join(shared, cxxflags)
	flags = table.join(flags, emcc.getwarnings(cfg))
	return flags
end


--
-- Returns a list of defined preprocessor symbols, decorated for
-- the compiler command line.
--
-- @param defines
--    An array of preprocessor symbols to define; as an array of
--    string values.
-- @return
--    An array of symbols with the appropriate flag decorations.
--

function emcc.getdefines(defines)

	-- Just pass through to clang for now
	local flags = clang.getdefines(defines)
	return flags

end

function emcc.getundefines(undefines)

	-- Just pass through to clang for now
	local flags = clang.getundefines(undefines)
	return flags

end



--
-- Returns a list of forced include files, decorated for the compiler
-- command line.
--
-- @param cfg
--    The project configuration.
-- @return
--    An array of force include files with the appropriate flags.
--

function emcc.getforceincludes(cfg)

	-- Just pass through to clang for now
	local flags = clang.getforceincludes(cfg)
	return flags

end


--
-- Returns a list of include file search directories, decorated for
-- the compiler command line.
--
-- @param cfg
--    The project configuration.
-- @param dirs
--    An array of include file search directories; as an array of
--    string values.
-- @return
--    An array of symbols with the appropriate flag decorations.
--

function emcc.getincludedirs(cfg, dirs, sysdirs)

	-- Just pass through to clang for now
	local flags = clang.getincludedirs(cfg, dirs, sysdirs)
	return flags

end

emcc.getrunpathdirs = clang.getrunpathdirs

--
-- get the right output flag.
--
function emcc.getsharedlibarg(cfg)
	return clang.getsharedlibarg(cfg)
end

--
-- Build a list of linker flags corresponding to the settings in
-- a particular project configuration.
--
-- @param cfg
--    The project configuration.
-- @return
--    An array of linker flags.
--

emcc.ldflags = {
	architecture = {
		x86 = "-m32",
		x86_64 = "-m32",
	},
	flags = {
		LinkTimeOptimization = "-flto",
	},
	kind = {
		SharedLib = function(cfg)
			local r = { emcc.getsharedlibarg(cfg) }
			if cfg.system == "windows" and not cfg.flags.NoImportLib then
				table.insert(r, '-Wl,--out-implib="' .. cfg.linktarget.relpath .. '"')
			elseif cfg.system == p.LINUX then
				table.insert(r, '-Wl,-soname=' .. p.quoted(cfg.linktarget.name))
			elseif table.contains(os.getSystemTags(cfg.system), "darwin") then
				table.insert(r, '-Wl,-install_name,' .. p.quoted('@rpath/' .. cfg.linktarget.name))
			end
			return r
		end,
		WindowedApp = function(cfg)
			if cfg.system == p.WINDOWS then return "-mwindows" end
		end,
	},
	system = {
		wii = "$(MACHDEP)",
	}
}

function emcc.getldflags(cfg)
	local flags = config.mapFlags(cfg, emcc.ldflags)
	return flags
end



--
-- Build a list of additional library directories for a particular
-- project configuration, decorated for the tool command line.
--
-- @param cfg
--    The project configuration.
-- @return
--    An array of decorated additional library directories.
--

function emcc.getLibraryDirectories(cfg)

	-- Just pass through to clang for now
	local flags = clang.getLibraryDirectories(cfg)
	return flags

end


--
-- Build a list of libraries to be linked for a particular project
-- configuration, decorated for the linker command line.
--
-- @param cfg
--    The project configuration.
-- @param systemOnly
--    Boolean flag indicating whether to link only system libraries,
--    or system libraries and sibling projects as well.
-- @return
--    A list of libraries to link, decorated for the linker.
--

function emcc.getlinks(cfg, systemonly, nogroups)
	return clang.getlinks(cfg, systemonly, nogroups)
end


--
-- Return a list of makefile-specific configuration rules. This will
-- be going away when I get a chance to overhaul these adapters.
--
-- @param cfg
--    The project configuration.
-- @return
--    A list of additional makefile rules.
--

function emcc.getmakesettings(cfg)

	-- Just pass through to clang for now
	local flags = clang.getmakesettings(cfg)
	return flags

end


--
-- Retrieves the executable command name for a tool, based on the
-- provided configuration and the operating environment. I will
-- be moving these into global configuration blocks when I get
-- the chance.
--
-- @param cfg
--    The configuration to query.
-- @param tool
--    The tool to fetch, one of "cc" for the C compiler, "cxx" for
--    the C++ compiler, or "ar" for the static linker.
-- @return
--    The executable command name for a tool, or nil if the system's
--    default value should be used.
--

emcc.tools = {
	cc = "emcc",
	cxx = "em++",
	ar = "emar"
}

function emcc.gettoolname(cfg, tool)
	return emcc.tools[tool]
end

filter "system:emscripten"
	toolset "emcc"
	print "Assigning emcc"


filter { "system:emscripten", "kind:ConsoleApp or WindowedApp" }
	targetextension ".html"
	
filter { "system:emscripten", "kind:SharedLib" }
	targetprefix ""
	targetextension ".bc"

filter { "system:emscripten", "kind:StaticLib" }
	targetprefix ""
	targetextension ".bc"


print "Finished loading emscripten module"