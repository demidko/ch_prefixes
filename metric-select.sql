SELECT cityHash64(groupId) % 2 AS group, varSamp(nominator), count(*) FROM (
    WITH arrayFirst(i -> i.1 == 'briefType', attributes).2 AS brief
    SELECT
        userId as groupId,
        countIf(1, brief == 'block') as nominator
    FROM metrics
    WHERE userId != 0
    AND name = 'viewdir_item_click'
    GROUP BY groupId
) GROUP BY group