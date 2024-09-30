public static class PerformanceHelper
{
    static Dictionary<string, TimeSpan> prevElapse = new Dictionary<string, TimeSpan>(StringComparer.OrdinalIgnoreCase);
    static Dictionary<string, Stopwatch> swatchs = new Dictionary<string, Stopwatch>(StringComparer.OrdinalIgnoreCase);

    static Func<bool> enableLogging;
    static Action<string> writeMessage;

    public static void Initialize(Func<bool> enableLogging, Action<string> writeMessage)
    {
        PerformanceHelper.enableLogging = enableLogging;
        PerformanceHelper.writeMessage = writeMessage;
    }

    public static void Start(string groupId)
    {
        if (!enableLogging())
        {
            return;
        }

        if (!swatchs.ContainsKey(groupId))
        {
            swatchs[groupId] = new Stopwatch();
        }

        swatchs[groupId].Reset();
        swatchs[groupId].Start();
    }

    public static void Log(string groupId, string message = null)
    {
        if (!enableLogging())
        {
            return;
        }

        if (!swatchs.ContainsKey(groupId))
        {
            throw new ArgumentNullException($"Call {nameof(PerformanceHelper)}.{nameof(Start)}(\"{groupId}\") first");
        }

        var swElapsed = swatchs[groupId].Elapsed;

        if (!prevElapse.ContainsKey(groupId))
        {
            prevElapse[groupId] = TimeSpan.Zero;
        }

        var elapsed = swElapsed - prevElapse[groupId];

        prevElapse[groupId] = elapsed;

        if (!string.IsNullOrWhiteSpace(message))
        {
            writeMessage($"{FormatElapsedTime(elapsed)}: {groupId} - {message}");
        }
        else
        {
            writeMessage($"{FormatElapsedTime(elapsed)}: {groupId}");
        }
    }

    public static void Stop(string groupId, string message = null)
    {
        if (!enableLogging())
        {
            return;
        }

        if (!swatchs.ContainsKey(groupId))
        {
            throw new ArgumentNullException($"Call {nameof(PerformanceHelper)}.{nameof(Start)}(\"{groupId}\") first");
        }

        var sw = swatchs[groupId];

        sw.Stop();

        if (prevElapse.ContainsKey(groupId))
        {
            prevElapse[groupId] = TimeSpan.Zero;
        }

        if (!string.IsNullOrWhiteSpace(message))
        {
            writeMessage($"{FormatElapsedTime(sw.Elapsed)}: {groupId} - {message}");
        }
        else
        {
            writeMessage($"{FormatElapsedTime(sw.Elapsed)}: {groupId}");
        }
    }

    static string FormatElapsedTime(TimeSpan ts)
    {
        return string.Format("{0:00}:{1:00}:{2:00}.{3:000}", ts.Hours, ts.Minutes, ts.Seconds, ts.Milliseconds);
    }

    static string FormatElapsedTimeMS(TimeSpan ts)
    {
        return string.Format("{0:00}:{1:00}:{2:0000}", ts.Minutes, ts.Seconds, ts.Milliseconds);
    }
}
