public static class UtilitiesExtensions
{
    public static TDestination Translate<TSource, TDestination>(this TSource source, Action<TSource, TDestination>? translation = null)
        where TDestination : class, new()
    {
        return source.Translate(new TDestination(), translation);
    }

    public static TDestination Translate<TSource, TDestination>(this TSource source, TDestination destination, Action<TSource, TDestination>? translation = null)
    {
        if (source == null)
        {
            throw new ArgumentNullException(nameof(source));
        }

        if (destination == null)
        {
            throw new ArgumentNullException(nameof(destination));
        }

        var sourceProperties = typeof(TSource).GetProperties();

        foreach (var sourceProperty in sourceProperties)
        {
            if (!sourceProperty.CanRead)
            {
                continue;
            }

            var targetProperty = typeof(TDestination).GetProperty(sourceProperty.Name);

            if (targetProperty == null || !IsTargetPropertySettable(sourceProperty, targetProperty))
            {
                continue;
            }

            targetProperty.SetValue(destination, sourceProperty.GetValue(source, index: null), index: null);
        }

        translation?.Invoke(source, destination);

        return destination;
    }

    private static bool IsTargetPropertySettable(PropertyInfo sourceProperty, PropertyInfo targetProperty)
    {
        if (targetProperty == null)
        {
            return false;
        }

        if (!targetProperty.CanWrite)
        {
            return false;
        }

        var targetSetMethod = targetProperty.GetSetMethod(nonPublic: true);

        if (targetSetMethod != null && targetSetMethod.IsPrivate)
        {
            return false;
        }

        if (targetSetMethod != null && (targetSetMethod.Attributes & MethodAttributes.Static) != 0)
        {
            return false;
        }

        if (!targetProperty.PropertyType.IsAssignableFrom(sourceProperty.PropertyType))
        {
            return false;
        }

        return true;
    }
}
