/* наружний запрос группирует сессии по группам сплит/контроль */
SELECT sessionId % 2 AS group, avg(metric), varSamp(metric) FROM
(
    /* этот запрос расчитывает значение метрики для индивидуальной сессии */
    SELECT sessionId, sum(numerator) / sum(denominator) as metric
    FROM (
        /* внутренний запрос маскирует и именует (numerator/denominator) интересующие метрики (без группировки) */
        WITH
            /* определяем индексы нужных нам атрибутов */
            (name = 'viewdir_item_click' and attrValues[indexOf(attrNames, 'briefType')] = 'block') AS numeratorMask,
            (name = 'viewdir_feed_stat') AS denominatorMask
        SELECT
            /* здесь и далее в качестве sessionId используется хеш от ринга/пользователя. В итоге sessionId должен стать
               самостоятельным ключом */
            cityHash64((userId, ring)) as sessionId,
            /* маскированное значение маски для числителя */
            (numeratorMask ? value : 0) numerator,
            /* маскированное значение маски для знаменателя */
            (denominatorMask ? 1 : 0) denominator
        FROM metrics
        WHERE
            /* дублируем имена используемых метрик, чтобы оптимизатор понимал что
            не требуется делать scan всего partition'а (metrics отсортирована по name) */
            name IN('viewdir_item_click', 'viewdir_feed_stat') AND
            cityHash64((userId, ring)) IN (
                /* определяет список сессий, которые являются предметом анализа */
                WITH indexOf(attrNames, 'referrer') AS ref
                SELECT DISTINCT cityHash64((userId, ring))
                FROM metrics
                WHERE name = 'firsthit' and domain(attrValues[ref]) = 'www.google.com'
            )
    )
    GROUP BY sessionId
    HAVING sum(denominator) > 0
)
GROUP BY group