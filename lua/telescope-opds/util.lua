local util = {}

-- sometimes you get a table of tables,
-- sometimes (if it's the only element) you get the table all by itsself.
-- call nest(), to make sure you are working with nested tables all the time
util.nest = function(tbl)
    if (tbl==nil) then return nil end
    if (#tbl>0) then return tbl end
    if (next(tbl)~=nil) then return {tbl} end
    return nil
end

util.starts_with = function(str, start)
   return str:sub(1, #start) == start
end

util.last = function(t) return t[#t] end

util.rest = function(t)
    if (t==nil or #t<=1) then return nil end
    local rest = {}
    for i=2,#t do
		rest[#rest+1] = t[i]
	end
    return rest
end

util.flatten = function(t, sep, res)

    if type(t) ~= 'table' then return t end

    sep = sep or '.'
    res = res or {}

    for k, v in pairs(t) do
        if type(v) == 'table' then
            local v = util.flatten(v, sep, {})
            for k2, v2 in pairs(v) do
                res[k .. sep .. k2] = v2
            end
        else
            res[k] = v
        end
    end
    return res
end

return util
