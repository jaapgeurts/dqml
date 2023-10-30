module dqml.qqmlengine;

import dqml.dothersideinterface;
import dqml.qqmlcontext;
import dqml.qurl;
import dqml.qobject;
import std.string;

class QQmlEngine
{
    this()
    {
        this.vptr = dos_qqmlengine_create();
    }

    ~this()
    {
        dos_qqmlengine_delete(this.vptr);
    }

    public void* voidPointer()
    {
        return this.vptr;
    }

    public QQmlContext rootContext()
    {
        void* contextVPtr = dos_qqmlengine_context(this.vptr);
        return new QQmlContext(contextVPtr);
    }

    public void addImportPath(string path)
    {
        dos_qqmlengine_add_import_path(this.vptr, path.toStringz());
    }

    private void* vptr;
}
