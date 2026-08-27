# Ty3r0X's Lair

A refactored version of my personal website, migrated from static XHTML to the [Zola](https://www.getzola.org/) static site generator while maintaining XHTML 1.1 compliance through hacky build scripts.

## Structure

```
Ty3r0X-Lair/
├── config.toml                 # Zola configuration
├── sass/                       # SASS source files
│   ├── main.scss               # Main entry point (imports all modules)
│   ├── _variables.scss         # Design tokens & variables
│   ├── _base.scss              # Typography & base elements
│   ├── _layout.scss            # Header, footer, content structure
│   ├── _navigation.scss        # Navbar & mobile menu
│   ├── _blog.scss              # Blog-specific components
│   ├── _tags.scss              # Tag system styling
│   ├── _utilities.scss         # Utility classes
│   └── _responsive.scss        # Media queries & responsive design
├── templates/                  # HTML templates
|   ├── base.html               # Main HTML code from which others derive from
│   └── ...
├── content/                    # Markdown content (some pages such as blog posts may contain )
├── static/                     # Static assets
│   ├── images/                 # Images
│   └── fonts/                  # Font files (storopia)
└── public/                     # Generated site
    └── main.css                # Compiled CSS output

```

## Quick Start

1. Install [Zola](https://www.getzola.org/documentation/getting-started/installation/)
2. Run `zola serve` to start development server
3. Visit `http://127.0.0.1:1111`

> [!IMPORTANT]
> Moderate LLM usage has been used to refactor my website. The initial code was yoinked from old [kalli.st](https://kalli.st) anyways (I was 16, don't judge), and since that got changed anyways, plus I couldn't handle the old spaghetti code, and since my constant lack of time to make it proper, I consider this fair use. Alas, there will be a massive audit once I get rid of university.
