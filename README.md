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
    openers = {
      -- fields on media are: title, filename, type and href
      epub = function(media)
        vim.cmd('enew!')
        vim.cmd('read! pandoc --from epub --to markdown "'..media.filename..'"')
      end,
      pdf = function(media)
        vim.cmd('!open /Applications/Skim.app "'..media.filename..'"')
      end
    }
})
```
When you select a book from the opds catalog, it will be saved to a temporary directory
and an opener function will be called that matches the media type.
The media object that is passed to it looks like this:
```lua
{
    href = 'http://your.opds.server:8888/library/file/1/epub',
    title = 'Alice in Wonderland',
    type = 'epub', -- or 'pdf'
    filename = '/tmp/.../Alice in Wonderland.epub' -- path to the downloaded file
}
```

#### Status

needs your feedback and code-review
