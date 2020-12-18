SELECT cityHash64(userId) % 2 AS group, sum(nominator), count(*) FROM (
    WITH arrayFirst(i -> i.1 == 'briefType', attributes).2 AS brief
    SELECT
        userId,
        countIf(1, brief == 'block') as nominator
    FROM metrics
    WHERE userId != 0
    AND name = 'viewdir_item_click'
    GROUP BY userId
) GROUP BY group