
/* среднее количество переходов по блочным объявлениям на одну выдачу для пользователей из гугла */

/*
                                  количество открытых блочных объявлений в сессиях из гугла
  среднее количество переходов = -----------------------------------------------------------
                                        количество выдач в сессиях из гугла
*/


/* наружний запрос группирует сессии по группам сплит/контроль */
SELECT sessionId % 2 AS group, sum(num) numerator, sum(denom) as denominamtor,
    toDecimal32(sum(num) / sum(denom), 4) ratio,
    toDecimal32(varSamp(num), 4) numeratorVariance,
    toDecimal32(varSamp(denom), 4) denominatorVariance
FROM (
    /* этот запрос расчитывает значение метрики для индивидуальной сессии */
    SELECT sessionId, sum(numerator) as num, sum(denominator) as denom
    FROM (
        /* внутренний запрос маскирует и именует (numerator/denominator) интересующие метрики (без группировки) */
        WITH
            /* определяем индексы нужных нам атрибутов */
            (name = 'viewdir_item_click' and attrValues[indexOf(attrNames, 'briefType')] = 'block') AS numeratorMask,
            (name = 'viewdir_feed_stat') AS denominatorMask
        SELECT
            /* здесь и далее в качестве sessionId используется хеш от ринга/пользователя. В итоге sessionId должен стать */
            /* самостоятельным ключом */
            sipHash64((userId, ring)) as sessionId,
            /* маскированное значение маски для числителя */
            (numeratorMask ? value : 0) numerator,
            /* маскированное значение маски для знаменателя */
            (denominatorMask ? 1 : 0) denominator
        FROM metrics
        WHERE
            /* дублируем имена используемых метрик, чтобы оптимизатор понимал что */
            /* не требуется делать scan всего partition'а (metrics отсортирована по name) */
            name IN('viewdir_item_click', 'viewdir_feed_stat') AND
            sipHash64((userId, ring)) IN (
                /* определяет список сессий, которые являются предметом анализа */
                WITH indexOf(attrNames, 'referrer') AS ref
                SELECT DISTINCT sipHash64((userId, ring))
                FROM metrics
                WHERE name = 'firsthit' and domain(attrValues[ref]) = 'www.google.com'
                AND (userId != 0 OR ring IS NOT NULL)
            )
    )
    GROUP BY sessionId
    HAVING sum(denominator) > 0
)
GROUP BY group