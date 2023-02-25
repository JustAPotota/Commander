#define LIB_NAME "Commander"
#define MODULE_NAME "commander_ext"

#include <dmsdk/sdk.h>

dmScript::LuaCallbackInfo *debugCb;
dmScript::LuaCallbackInfo *infoCb;
dmScript::LuaCallbackInfo *warningCb;
dmScript::LuaCallbackInfo *errorCb;

static int SetListeners(lua_State *L)
{
	DM_LUA_STACK_CHECK(L, 0);

	debugCb = dmScript::CreateCallback(L, 1);
	infoCb = dmScript::CreateCallback(L, 2);
	warningCb = dmScript::CreateCallback(L, 3);
	errorCb = dmScript::CreateCallback(L, 4);

	if (!debugCb)
	{
		dmLogError("Failed to create logging callbacks");
		return 0;
	}

	dmLogInfo("Created callbacks");

	return 0;
}

static const luaL_reg Module_methods[] = {
	{"set_listeners", SetListeners},
	{0, 0}
};

static void LuaInit(lua_State *L)
{
	int top = lua_gettop(L);

	// Register lua names
	luaL_register(L, MODULE_NAME, Module_methods);

	lua_pop(L, 1);
	assert(top == lua_gettop(L));
}

static void RunCallback(dmScript::LuaCallbackInfo *cb, const char *domain, const char *message, size_t severity_length)
{
	if (!dmScript::IsCallbackValid(cb))
		return;

	lua_State *L = dmScript::GetCallbackLuaContext(cb);
	DM_LUA_STACK_CHECK(L, 0);

	if (!dmScript::SetupCallback(cb))
	{
		return;
	}

	lua_pushstring(L, domain);
	lua_pushstring(L, message + strlen(domain) + severity_length + 3);

	dmScript::PCall(L, 3, 0);
	dmScript::TeardownCallback(cb);
}

static void LogListener(LogSeverity severity, const char *domain, const char *message)
{
	if (severity <= LOG_SEVERITY_USER_DEBUG)
	{
		RunCallback(debugCb, domain, message, 5);
	} else if (severity == LOG_SEVERITY_INFO) {
		RunCallback(infoCb, domain, message, 4);
	} else if (severity == LOG_SEVERITY_WARNING) {
		RunCallback(warningCb, domain, message, 7);
	} else if (severity >= LOG_SEVERITY_ERROR) {
		RunCallback(errorCb, domain, message, 5);
	}
}

extern "C" void dmHashEnableReverseHash(bool enable);

static dmExtension::Result AppInit(dmExtension::AppParams *params)
{
	dmConfigFile::HConfig config = dmEngine::GetConfigFile(params);
	int32_t reverseHash = dmConfigFile::GetInt(config, "commander.reverse_hash", 1);
	if (reverseHash) {
		dmHashEnableReverseHash(true);
	}
	return dmExtension::RESULT_OK;
}

static dmExtension::Result ExtInit(dmExtension::Params *params)
{
	LuaInit(params->m_L);
	dmLog::RegisterLogListener(LogListener);
	return dmExtension::RESULT_OK;
}

DM_DECLARE_EXTENSION(CommanderExt, LIB_NAME, AppInit, 0, ExtInit, 0, 0, 0)