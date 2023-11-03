module dqml.qqmlengine;

import dqml.dothersideinterface;
import dqml.qqmlcontext;
import dqml.qurl;
import dqml.qobject;
import std.string;

class QQmlEngine
{
    this(void* vptr)
    {
        this.vptr = vptr;
    }

    public void* voidPointer()
    {
        return vptr;
    }

    private void* vptr;
}
