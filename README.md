# Ty3r0X's Lair - Static Site Template made with Zola

A refactored version of my personal website, migrated from static XHTML to the [Zola](https://www.getzola.org/) static site generator while maintaining XHTML 1.1 compliance.

## Structure

```
Ty3r0X-Lair/
├── config.toml                 # Zola configuration
├── sass/                       # 📁 SASS source files
│   ├── main.scss               # 🎯 Main entry point (imports all modules)
│   ├── _variables.scss         # 🎨 Design tokens & variables
│   ├── _base.scss              # 📝 Typography & base elements
│   ├── _layout.scss            # 📐 Header, footer, content structure
│   ├── _navigation.scss        # 🧭 Navbar & mobile menu
│   ├── _blog.scss              # 📖 Blog-specific components
│   ├── _tags.scss              # 🏷️  Tag system styling
│   ├── _utilities.scss         # 🛠️  Utility classes
│   └── _responsive.scss        # 📱 Media queries & responsive design
├── templates/                  # 🎨 HTML templates
│   └── base.html
├── content/                    # 📄 Markdown content
├── static/                     # 📁 Static assets
│   ├── images/                 # 🖼️  Images (bg.gif, logo, etc.)
│   └── fonts/                  # 🔤 Font files (storopia)
└── public/                     # 📦 Generated site
    └── main.css                # ✅ Compiled CSS output

```

## Quick Start

1. Install [Zola](https://www.getzola.org/documentation/getting-started/installation/)
2. Run `zola serve` to start development server
3. Visit `http://127.0.0.1:1111` to see the site

## Features

- XHTML 1.1 Compliant
- Complete blog system with tags
- Dark theme with purple/green accents
- Responsive design
- Code syntax highlighting
