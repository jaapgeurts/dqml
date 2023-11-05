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

/+
// TODO: fix this using mixins
public static string GeneratePluginMetaInfo(string name ) {
  return
  //"import ldc.attributes;\n"~
//    "@(section(\".qtmetadata\"))\n"~
    "immutable char[100] qt_pluginMetaData = \"QTMETADATA !\\x00\\x05\\x0f\\x" ~
        format("%0.2x", qPluginArchRequirements()) ~
        "\\xbf" ~
        "\\x02\\x78\\x28" ~ "org.qt-project.Qt.QQmlExtensionInterface" ~
        "\\x03\\x73" ~ name ~
        "\\xff\";\n\n";
}

// TODO: change to typeinfo
public static string GenerateInstanceCallback(string name) {

return "QObject* qt_plugin_instance() {\n" ~
    "  import core.runtime;\n"~
    "  Runtime.initialize();\n"~
    "  return cast(QObject*) new " ~ name ~ "().voidPointer();\n"~
    "}\n";
}

public template QML_PLUGIN(T)
{
  const char[] QML_PLUGIN = GeneratePluginMetaInfo(T.stringof) ~
        GenerateInstanceCallback(T.stringof);
}
+/

abstract class QQmlExtensionPlugin : QObject
{

    mixin Q_OBJECT;

    protected override void* createVoidPointer()
    {
        DosQQmlExtensionPluginCallbacks callbacks;
        callbacks.registerTypes = &registerTypesCallBack;

        return this.vptr = dos_qqmlextensionplugin_create(cast(void*) this,// TODO: add meta object support
                //                                                         metaObject().voidPointer(),
                //                                                         &staticSlotCallback,
                callbacks);

    }

    void initializeEngine(QQmlEngine engine, QUrl url);

    void registerTypes(string uri);

    protected extern (C) static void registerTypesCallBack(void* pluginPtr, void* uriPtr)
    {
        auto plugin = cast(QQmlExtensionPlugin)(pluginPtr);
        string uri = to!string(cast(char*) uriPtr);
        plugin.registerTypes(uri);
    }

}
