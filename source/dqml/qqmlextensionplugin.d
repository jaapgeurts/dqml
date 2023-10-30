module dqml.qqmlextensionplugin;

import dqml.dothersideinterface;
import dqml.qqmlengine;
import dqml.qurl;
import std.string;

abstract class QQmlExtensionPlugin
{
    this(void* vptr)
    {
        this.vptr = vptr;
    }

    public void* voidPointer()
    {
        return vptr;
    }

    void initializeEngine(QQmlEngine *engine, QUrl url)
    {
        dos_qqmlextensionplugin_initializeEngine(this.vptr, engine, url.voidPointer());
    }

    void registerTypes(string uri);

    private void* vptr;
}
