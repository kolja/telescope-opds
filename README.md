# Telescope-opds
Browse [opds](https://en.wikipedia.org/wiki/Open_Publication_Distribution_System) catalogs.

#### Installation

```lua
use 'kolja/telescope-opds'
```

#### Browse opds catalog

```lua
require('telescope').extensions.opds.browse({
        cmd = '/usr/bin/curl',      -- /usr/bin/curl is the default
        url = <opds-server>,        -- e.g. http://your.opds.server/catalog
        auth = 'user:password',     -- optional
        raw_preview = false,        -- render raw xml2lua output to preview

        -- open_fn will be called when you open a book from the catalog.
        -- you could (for example) use 'pandoc' to convert an epub to markdown
        -- and open it in a new buffer like this:

        open_fn = function(media_links)

          local media = {}
          local openers = {             -- openers for different media types
            epub = function(media)
              vim.cmd('enew!')
              vim.cmd('read! pandoc --from epub --to markdown "'..media.filename..'"')
            end,
            pdf = function(media)
              vim.cmd('!open /Applications/Skim.app "'..media.filename..'"')
            end
          }

          if #media_links == 0 then
            error("No media found!")
            return
          elseif #media_links == 1 then -- if exactily one media found, open it
            media = media_links[1]
            openers[media.type](media)
          else                          -- if multiple media found, let the user choose which one to open
            local choices = vim.tbl_map(function (media) return media.type .." : ".. media.title end, media_links)
            vim.ui.select(
              choices,
              { prompt = "Please choose:" },
              function(_, idx)
                if not idx then return end
                media = media_links[idx]
                openers[media.type](media)
              end)
          end
        end
    })
```

You can supply your own open_fn function.

When you open a book from the opds catalog (Keyboard shortcut `o`), it will be saved to a temporary directory
and your open_fn function will be called with media_links, a table with the following structure:
```lua
{
  {
    href = 'http://your.opds.server:8888/library/file/1/epub',
    title = 'Alice in Wonderland',
    type = 'epub',
    filename = '/tmp/.../Alice in Wonderland.epub' -- path to the downloaded file
  },
  {
    href = 'http://your.opds.server:8888/library/file/1/pdf',
    title = 'Alice in Wonderland',
    type = 'pdf',
    filename = '/tmp/.../Alice in Wonderland.pdf'
  }
}
```

#### Status

needs your feedback and code-review
