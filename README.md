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
        url = <opds-server>,        -- e.g. http://your.opds.server/root
        raw_preview = false,        -- render raw xml2lua output to preview
        open_fn = function(media_links)
                       -- code to download and display goes here...
                  end
    })
```

#### Status

needs your feedback and code-review
