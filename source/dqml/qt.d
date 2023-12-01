module dqml.qt;

public const int UserRole = 0x100;

enum ConnectionType : int
{
    Auto = 0,
    Direct,
    Queued,
    BlockingQueued,

    Unique = 0x80
}
