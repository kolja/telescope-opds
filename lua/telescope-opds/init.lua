
local Job = require('plenary.job')
local xml2lua = require('telescope-opds.xml2lua')
local handler = require('telescope-opds.xmlhandler.tree')
local url = require('telescope-opds.neturl')
local state = require('telescope.actions.state')
local actions = require('telescope.actions')
local finders = require('telescope.finders')
local previewer = require('telescope.previewers.buffer_previewer')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')
local util = require('telescope-opds.util')

local opds = {}

local request = function(opt)

    local t = {}
    handler = handler:new()
    local parser = xml2lua.parser(handler)
    local opds = url.parse(opt.url)
    opds.path = util.last(opt.path).href

    local read = function(j, ret)
        parser:parse(table.concat(j:result()))
        for k,v in pairs(handler.root.feed.entry) do
            t[k] = v
        end
    end

    Job:new({
        command = opt.cmd,
        args = {tostring(opds:normalize())},
        on_exit = read
    }):sync()

    return t
end

local find_links = function(item)
    local links = {}
    for key,link in pairs(util.nest(item.link)) do
        if (util.starts_with(link._attr['type'], "application/atom+xml")) then
            links['next'] = link._attr['href']
        end
        if (util.starts_with(link._attr['type'], "application/epub+zip") or
            util.starts_with(link._attr['type'], "application/pdf")) then

            links.media = links.media or {}
            table.insert(links.media, link._attr)
        end
    end
    return links
end

local entry_maker = function(item)
    return {
        value = item,
        ordinal = item.title,
        display = item.title,
        links = find_links(item)
    }
end

local render_preview = function(entry, raw)

    local page = {}
    local l = false

    if (raw) then
        return vim.split(vim.inspect(entry), "\n")
    end
    
    if (entry.author) then 
        local authors = vim.fn.map(util.nest(entry.author), function(_,author) return author.name end)
        table.insert(page, table.concat(authors, ", ")) 
        table.insert(page, "")
    end
    if (entry.title) then 
        table.insert(page, entry.title) 
        table.insert(page, "")
    end
    if (entry.category) then 
        l = true
        local cats = vim.fn.map(util.nest(entry.category), function(_,cat) return cat._attr.label end)
        table.insert(page, 'tags:\t'..table.concat(cats, ", ")) 
    end
    if (entry['dcterms:language']) then 
        l = true
        table.insert(page, 'lang:\t'..entry['dcterms:language']) 
    end
    if (entry.content) then
        if l then table.insert(page, '') end
        entry.content._attr = nil
        local content = util.flatten(entry.content)
        for i=1, #content do page[#page+1] = content[i]
    end
    end

    return page
end

opds.browse = function(opt)

    --[[ 
    opt = {
        cmd = '/usr/bin/curl',
        url = <opds-server>,
        raw_preview = false, -- render raw xml2lua output to preview
        open_fn = function(media_links) ... end
    }
    --]]
    
    opt.cmd = opt.cmd or '/usr/bin/curl'

    if (opt.path==nil or #opt.path==0) then 
        opt.path = {{name="/", href=url.parse(opt.url).path}}
    end
    
    local response = request(opt)

    pickers.new(opt, {
        prompt_title = 'opds',
        finder    = finders.new_table {
            results = response,
            entry_maker = entry_maker
        },
        previewer = previewer.new_buffer_previewer({
            title = function(arg)
                local breadcrumbs = util.rest(opt.path)
                if (breadcrumbs==nil) then return "opds" end
                return table.concat(vim.fn.map(breadcrumbs, 
                                    function(_,item) return item.name end), " > ")
            end,
            define_preview = function(self, entry, status) 
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, 
                render_preview(response[entry.index], opt.raw_preview))
            end,
        }),
        sorter = sorters.get_generic_fuzzy_sorter(),
        selection_strategy = "reset",

        attach_mappings = function(prompt_bufnr, map)

            local follow_link = function(num)
                actions.close(num)
                local entry = state.get_selected_entry()
                if (entry.links['next'] ~= nil) then
                    table.insert(opt.path, {name=entry.display,href=entry.links['next']})
                    opds.browse(opt)
                end
                return true
            end

            local back_link = function(num)
                actions.close(num)
                if (#opt.path == 1) then return true end
                table.remove(opt.path)
                opds.browse(opt)
                return true
            end

            local toggle_raw = function(num)
                opt.raw_preview = not opt.raw_preview
                local bufnr = state.get_current_picker(num).previewer.state.bufnr
                local entry = state.get_selected_entry().value
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, 
                                            render_preview(entry, opt.raw_preview))
            end  

            local open = function(num)
                local entry = state.get_selected_entry()
                if (entry.links.media==nil) then 
                    print('this entry has not media link') 
                    return
                end
                if (opt.open_fn==nil) then
                    print('set function \'open_fn = function(<media-link>) ... end\' to open media')
                    return 
                end

                local opds = url.parse(opt.url)
                local links = vim.fn.map( entry.links.media, function(_,v)
                    local href = v.href
                    opds.path = href 
                    v.href = tostring(opds:normalize())
                    return v
                end)
                opt.open_fn(links)
                return true
            end

            map('i', '<CR>' , follow_link)
            map('n', '<CR>' , follow_link)
            map('n', 'l'    , follow_link)
            map('n', '<ESC>', back_link)
            map('n', 'h'    , back_link)
            map('n', 'r'    , toggle_raw)
            map('n', 'o'    , open)

            return true
        end
    }):find()
end

return opds
