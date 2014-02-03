PKGCONFIG    ?= pkg-config --silence-errors

# The naming of Lua pkg-config files across distributions is quite a mess:
# - Fedora and Arch use lua.pc
# - Debian uses lua5.2.pc and lua5.1.pc
# - OpenBSD ports uses lua52.pc and lua51.pc
# - FreeBSD and some others seem to be considering lua-5.2.pc and lua-5.1.pc
LUA_PC_NAMES  = lua lua52 lua5.2 lua-5.2 lua51 lua5.1 lua-5.1 luajit

LUA_PC_FOUND  = $(strip $(foreach file, $(LUA_PC_NAMES), \
                $(if $(shell $(PKGCONFIG) --libs $(file)),$(file),)))

LUA_PC_FIRST  = $(firstword $(LUA_PC_FOUND))

LUA_PC        = $(if $(LUA_PC_FIRST),$(LUA_PC_FIRST), \
                $(error No pkg-config file found for Lua))

# Some distributions put the Lua headers in versioned sub-directories, which
# aren't in the default paths and hence must be included manually
LUA_CFLAGS    = $(shell $(PKGCONFIG) --cflags $(LUA_PC))

# luajit.pc and Debian's lua*.pc files have convenient module path variables
LUA_PC_LMOD   = $(shell $(PKGCONFIG) --variable=INSTALL_LMOD $(LUA_PC))
LUA_PC_CMOD   = $(shell $(PKGCONFIG) --variable=INSTALL_CMOD $(LUA_PC))

# Most other distros force you to piece together prefix/libdir/version
LUA_PREFIX    = $(shell $(PKGCONFIG) --variable=prefix $(LUA_PC))
LUA_LIBDIR    = $(shell $(PKGCONFIG) --variable=libdir $(LUA_PC))
LUA_VERSION   = $(shell $(PKGCONFIG) --modversion $(LUA_PC) | grep -o '^.\..')

# If you need to specify module paths manually, override just these two
LUA_LMOD_DIR  = $(strip $(if $(LUA_PC_LMOD), $(LUA_PC_LMOD), \
                $(LUA_PREFIX)/share/lua/$(LUA_VERSION)))
LUA_CMOD_DIR  = $(strip $(if $(LUA_PC_CMOD), $(LUA_PC_CMOD), \
                $(LUA_LIBDIR)/lua/$(LUA_VERSION)))