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
          local epub = vim.tbl_filter(function (link) return link.type == 'epub' end, media_links)[1]
          if epub then
            vim.cmd('enew!')
            vim.cmd('read! pandoc --from epub --to markdown "'..epub.filename..'"')
          else
            print('no epub found')
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
