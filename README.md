# SwiftcodeMe

This repository contains the source code for the swiftcode.me website.

## Setup

1. Install the Publish command line tool:
   ```bash
   git clone https://github.com/JohnSundell/Publish.git
   cd Publish
   make
   # You might want to move the generated 'publish' binary to a directory in your PATH
   # For example: sudo mv publish /usr/local/bin/
   cd .. 
   rm -rf Publish # Optional: remove the cloned directory
   ```

2. Clone the repository:
   ```bash
   git clone https://github.com/muzix/swiftcode.me.git
   cd swiftcode.me
   ```

## Generating the website

To generate the static website, run the following command in your terminal:

```bash
publish generate
```

This will generate the website in the `Output` folder. 