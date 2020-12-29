SELECT cityHash64(groupId) % 2 AS group, varSamp(value), count(*) FROM (
    WITH indexOf(attrNames, 'briefType') AS briefType, indexOf(attrNames, 'searchPos') AS searchPos
    SELECT userId as groupId, toUInt8(attrValues[searchPos]) as value
    FROM metrics
    WHERE name = 'viewdir_item_click' AND attrValues[briefType] = 'block' and userId > 0
) GROUP BY group