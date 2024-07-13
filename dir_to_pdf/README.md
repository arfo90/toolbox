This script does the following:

1. It uses the `prawn` gem to create and manipulate PDFs. You'll need to install it with `gem install prawn`.
2. It accepts multiple input directories and an output file name as command-line arguments.
3. It recursively scans all directories and subdirectories for files.
4. It supports text files (.txt, .md, .js, .rb, .ru), images (.jpg, .jpeg, .png, .gif), and existing PDFs. // more extension can be added
5. It adds each supported file to the output PDF, starting a new page for each file.
6. It skips unsupported file types and reports errors for files it can't process.

To use the script:

1. Save it as `dir_to_pdf.rb`.
2. Make it executable: `chmod +x dir_to_pdf.rb`.
3. Run it like this:

```
./pdf_converter.rb -d /path/to/dir1,/path/to/dir2 -o output.pdf
```

This will process all files in `/path/to/dir1` and `/path/to/dir2` (and their subdirectories) and create `output.pdf`.

