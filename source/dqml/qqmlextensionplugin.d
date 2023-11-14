module dqml.qqmlextensionplugin;

import std.conv : to;
import std.string : format;

import dqml.dothersideinterface;
import dqml.qobject;
import dqml.qqmlengine;
import dqml.qmetaobject;
import dqml.qurl;
import dqml.qdeclarative;
import dqml.qobjectgenerators;
import dqml.qvariant;
import dqml.qqmlengine;

// inline constexpr unsigned char qPluginArchRequirements()
byte qPluginArchRequirements()
{
    return 0;
    /*
{
    return 0
#ifndef QT_NO_DEBUG
            | 1
#endif
#ifdef __AVX2__
            | 2
#  ifdef __AVX512F__
            | 4
#  endif
#endif
    ;
}*/
}

char[] encodeStringToCBOR(string inputString)
{
    size_t strLen = inputString.length;

    char[] cborArray;

    size_t index = 0;

    // Write CBOR major type for a string (3)
    if (strLen < 24)
    {
        cborArray ~= format("\\x%0.2x", cast(char)(0b011_00000 | strLen));
    }
    else if (strLen < 256)
    {
        cborArray ~= format("\\x%0.2x", cast(char) 0b011_00100); // Indefinite length for text
        cborArray ~= format("\\x%0.2x", cast(char) strLen);
    }
    else
    {
        throw new Exception("Strings larger than 255 are not implemented");
    }

    // Copy the string data to the CBOR array
    cborArray ~= inputString;

    return cborArray.dup;
}

template GenerateMetaData(T)
{

    const char[] GenerateMetaData = "@section(\".qtmetadata\")\n"
        ~ "immutable char[100] qt_pluginMetaData = \"QTMETADATA !\\x00\\x05\\x0f\\x"
        ~ format("%0.2x", qPluginArchRequirements()) ~ "\\xbf"
        ~ "\\x02" ~ "\\x78\\x28" ~ "org.qt-project.Qt.QQmlExtensionInterface"
        ~ "\\x03" ~ encodeStringToCBOR(T.stringof) ~ "\\xff\";\n\n";
}



mixin template PluginMetaData(T : QQmlExtensionPlugin)
{
    extern(C) {

        void init_runtime_cb() {
            import core.runtime;
            import std.stdio;

            // // initialize the D runtime
            // call back to QT side to execute function on main thread which initializes the D runtime

            // and wait until initialization is complete
            rt_init();
            writeln("Init runtime");
        }

        void* qt_plugin_instance()
        {
            import std.stdio;
            writeln("D Side calling init");
            dos_initialize_runtime(&init_runtime_cb);

            T plugin = new T();
            // GC.addRoot(cast(void*) plugin);
            // GC.setAttr(cast(void*) plugin, GC.BlkAttr.NO_MOVE);
            return plugin.voidPointer();
        }
    }
    //pragma(msg, GenerateMetaData!MqttPlugin);
    version (GNU)
    {
        import gcc.attributes;
    }
    version (LDC)
    {
        import ldc.attributes;
    }
    mixin(GenerateMetaData!MqttPlugin);
}

class QQmlExtensionPlugin
{

    this()
    {
        DosQQmlExtensionPluginCallbacks callbacks;
        callbacks.registerTypes = &registerTypesCallBack;
        callbacks.initializeEngine = &initializeEngineCallback;

        vptr = dos_qqmlextensionplugin_create(cast(void*) this, // TODO: add meta object support
                // metaObject().voidPointer(),
                // &staticSlotCallback,
                callbacks);
    }

    ~this()
    {
        import std.stdio;

        writeln("DSide destruct");
        //dos_qqmlextensionplugin_delete(vptr);
    }

    public void* voidPointer()
    {
        return this.vptr;
    }

    // TODO: empty body is required otherwise the function
    // is not available at runtime.????
    void initializeEngine(QQmlEngine engine, string uri)
    {
    }

    // TODO: empty body is required otherwise the function
    // is not available at runtime.????
    void registerTypes(string uri)
    {
    }

    protected extern (C) static void initializeEngineCallback(void* pluginPtr,
            void* enginePtr, void* uriPtr)
    {
        auto plugin = cast(QQmlExtensionPlugin)(pluginPtr);
        auto engine = new QQmlEngine(enginePtr);
        string uri = to!string(cast(char*) uriPtr);
        plugin.initializeEngine(engine, uri);
    }

    protected extern (C) static void registerTypesCallBack(void* pluginPtr, void* uriPtr)
    {
        auto plugin = cast(QQmlExtensionPlugin)(pluginPtr);
        string uri = to!string(cast(char*) uriPtr);
        plugin.registerTypes(uri);
    }

    private void* vptr;
}

